# Architecture

How Escape Boom is put together. Updated at the end of every part.

## Folders

| Folder | What is in it |
|---|---|
| `art/source/` | Original art copied from the vault. Never used directly (a `.gdignore` hides it from Godot). The retexture references are in `art/source/retexture/` under their own numbers. |
| `art/game/` | Game-ready PNGs made by the two scripts in `tools/`, and `menu_tv.txt`, the menu TV's character grid. |
| `art/fonts/` | JetBrains Mono ExtraBold for the password menu, with its licence (OFL). |
| `config/` | `balance.tres` (every tunable number) and the scripts that define its fields. |
| `scenes/` | Godot scenes (`.tscn`) and resources (`.tres`), grouped by feature. |
| `scripts/` | The GDScript for those scenes, in the same groups. |
| `shaders/` | The hit flash shader. |
| `tests/` | The headless test runner and the tests. |
| `tools/` | Python art scripts, and `export.sh`, which builds the Windows and macOS releases from `export_presets.cfg`. |

## Autoloads

Autoloads are scripts Godot creates once at startup and keeps for the whole game; any script can
use them by name.

- `Config` (`scripts/autoload/config.gd`) loads `config/balance.tres` once. Scripts read numbers as
  `Config.balance.player_move_speed`. No gameplay numbers are written into scripts.
- `Audio` (`scripts/autoload/audio.gd`) has an empty `play_sfx()`. The calls mark where sounds
  will go; sound is out of scope for now.
- `Events` (`scripts/autoload/events.gd`) holds game-wide signals: `code_collected`, `hourglass_collected`,
  `enemy_died` and `wave_started`. The code can be picked up anywhere in a map (or, later, be
  dropped by the boss), so it announces itself here instead of needing a wire to the round.
  `hourglass_collected` works the same way: the round adds the time.
  `wave_started` is sent by the arena's waves; the code chest, the HUD line and the F3 overlay
  listen to it, so none of them needs to know where the waves live.
- `Game` (`scripts/autoload/game.gd`) moves between the menu and rounds, picks the map type
  (uniform random, or the one forced with `--map=`) and makes its map: a `DungeonFloor` for the
  arena and boss types, the `Labyrinth` for the maze.

`scripts/strings.gd` (`Strings`) is not an autoload: it only holds constants, all player-facing text.

## Game flow

```
PasswordScreen (scenes/ui/password_screen.tscn)  --right code-->  Game.start_round()  -->  Round   (main scene: once per launch)
MainMenu (scenes/ui/main_menu.tscn)  --Play-->  Game.start_round()  -->  Round   (reached from the Menu buttons)
Round  --win / death / timeout-->  EndScreen  --Play again-->  Game.start_round()  (new random map type)
                                              --Menu-->        Game.go_to_menu()
```

## The round scene

```
Round (scenes/round/round.tscn)               builds the map, decides the result, writes the run log
├── DungeonFloor or Labyrinth (added at runtime, both GameMaps)
│   ├── Navigation (NavigationRegion2D)       walkable area, baked at runtime around the walls
│   │   ├── Floor (TileMapLayer)              floor tiles, always underneath (z_index -10)
│   │   └── Walls (TileMapLayer)              wall tiles with collision, y-sorted
│   ├── Darkness, Vision                      Labyrinth only: CanvasModulate and PointLight2D
│   ├── chests, barrels, doors, enemies, code placed from the text layout
│   └── Room (DungeonFloor only, one per room) locks fight and boss rooms; their enemies live here
│       └── ArenaWaves (arena room only)      sends the waves; EnemySpawn effects become enemies
├── Player (scenes/player/player.tscn)        Telly; how he holds the gun and shows faces: config/hero_rig.tres
│   ├── Hurtbox (Area2D)                      where enemy bullets hit: the middle of the body
│   ├── Body (AnimatedSprite2D)               the hero frames, from hero_frames.tres
│   ├── Face (Sprite2D)                       shout, reload bar or X eyes drawn over the screen
│   ├── Juice                                 shared game-feel component
│   ├── Arm                                   at the hand's spot; before Body in the back view
│   │   ├── GunPivot                          turns the gun around its grip towards the mouse
│   │   │   └── Gun (scenes/guns/gun.tscn)    the gun in hand: sprite, muzzle, flash, ejection port
│   │   └── Hand (Sprite2D)                   the one hand, on the grip
│   ├── Guns (GunInventory)                   the carried guns and their ammo
│   ├── Interactor                            finds the nearest chest or gun and handles E
│   └── Camera (GameCamera)
├── RoundTimer                                5:00 countdown (counts up in boss rounds); pausing stops it
├── HUD, PauseMenu, EndScreen, DebugOverlay, FloorMap   CanvasLayers drawn on top of the world
└── (bullets, casings, puffs and drops are added here at runtime)
```

## Key decisions

- **One balance resource.** `BalanceConfig` is a `Resource` with typed `@export` fields; the values
  are in `config/balance.tres`, and only there: the fields have no defaults in the script. (The
  Godot editor drops every value that equals a script default when it saves a `.tres`, which
  emptied most of the file twice.) Each gun is a `GunStats` sub-resource inside it, so a gun's numbers
  and its art sit together: `icon` (the big drawing, for the HUD), `held_texture` (the small
  drawing in the hand and on the floor) and the grip, muzzle and ejection pixels of the held drawing.
- **Y-sorting.** `Round`, the map, the navigation region and the `Walls` layer all have
  `y_sort_enabled`, so their children are drawn in order of their y position, as if they were one
  list: a character lower on screen is drawn in front. Wall tiles sort by the top of the tile
  (`y_sort_origin = -8` in `dungeon_tiles.tres`), so a character beside or below a wall is drawn
  in front of it. The gun goes behind the hero by moving before the body in the player's own
  draw order, not by z_index (that would lift it above walls and other characters).
- **One explosion rule.** `Explosion` damages every enemy and the player inside its radius, if a
  ray from the centre to the target's body hits no wall. Only the Gold Detonator passes
  `hurts_player = false`. Rockets explode a few pixels back from the wall they hit, so the
  centre is never inside the wall.
- **Idle enemies.** An enemy stays idle until it sees the player (a ray to the player hits no
  wall) or the player comes within `enemy_wake_distance`; after that it stays awake.
- **Maps as text.** A map is a `GameMap` with a `layout`: one string per row of tiles (the
  legend is at the top of `scripts/maps/game_map.gd`: `#` wall, `x` crate, `.` floor, `D` door,
  space for nothing, letters for the start, chests, barrels, enemies and the code). The script
  builds the tiles and entities, then bakes the navigation mesh. A crate is a wall tile with
  crate art, so it blocks everything a wall blocks.
- **Three map types.** The arena and boss types are floors of rooms (below); the maze type is one
  `Labyrinth` (`scripts/maps/labyrinth.gd`), which extends `GameMap`, gets its layout from
  `MazeGenerator` before the base `_ready()` builds it, and adds officers with patrol routes.
  Boss rounds start the `RoundTimer` with `count_down = false`: it only counts the time played.
- **A floor is built as one map.** `FloorGenerator` (`scripts/floor/floor_generator.gd`)
  grows a tree of 6-8 rooms on a coarse grid (each new room next to a random existing one), puts
  the objective room next to the deepest room, and makes dead ends chest rooms. The start room
  never gets a second neighbour, so it has one way out. On a boss floor an exit room is added
  behind the boss room. Every grid column
  is as wide as its widest room and every row as tall as its tallest, and rooms sit in the
  middle of their cell, so a room and the one it grew from always line up and the corridor
  between them is straight. The rooms' layouts and the corridors are stamped into one big
  layout. Start, chest and fight rooms are hand-made (`scripts/floor/room_layouts.gd`); the arena
  and the boss room are generated (`scripts/floor/objective_rooms.gd`, mirrored left to right,
  every crate and pillar keeping a free tile around it so nothing gets walled off), so the whole floor is one `GameMap` and walking
  between rooms needs no loading. `DungeonFloor` (`scripts/floor/dungeon_floor.gd`) extends
  `GameMap`: it gets the floor layout before the base `_ready()` builds it, then adds a `Room`
  node per room.
- **Rooms.** A `Room` knows its rectangle and its doors (`Door` tiles on its wall). A room with
  `enemies_on_enter` (fight rooms, with harder mixes deeper in from `floor_fights`, and the boss
  room, with the Ammo Wraith) closes its doors when the player is two tiles past the doorway and
  spawns them as its own children, so "cleared" just means it has no enemy children left. Then
  it opens its doors and the doors in `opens_on_clear`: for the boss room, the exit room's, which
  start shut. The arena room starts its `ArenaWaves` instead.
- **The Ammo Wraith** (`scripts/enemies/ammo_wraith.gd`) picks its phase from its share of hit
  points (`phase_for()`). Phase 3 runs every attack clock 1.3 times faster rather than changing
  each interval. Belt Lash queues its bullets with a delay each, so one sweep is spread over
  time. Its health goes to the HUD through `Events.boss_health_changed`.
- **The floor map** (`scripts/ui/floor_map.gd`) draws the rooms straight from `DungeonFloor.rooms`:
  rooms walked into are filled, rooms joined to them are outlined.
- **The maze generator.** `MazeGenerator` (`scripts/maps/maze_generator.gd`) carves a grid of
  cells with a recursive backtracker (each cell 2x2 floor tiles, walls one tile thick), finds the
  distance of every cell from the start corner with a BFS, and puts the code in the farthest one.
  It retries until the shortest walk is inside the 60-90 s window in `balance.tres`.
- **Darkness** is a `CanvasModulate` that turns the whole labyrinth almost black, plus a
  `PointLight2D` with a round gradient texture that follows the player. The HUD is on a
  `CanvasLayer`, so it stays bright.
- **Chests.** A gun chest picks its gun when it appears; it is locked (the Enemy Arena's, until
  the unlock wave), ready, opening or open, each with its approved picture or strip (a `Sprite2D`
  with `hframes`). Opening, the strip plays over `chest_open_time` while the chest's own gun rises
  out of it, then drops in front as the pickup. The code chest goes chained, unchaining (the
  chains break), ready, opening (the key rises) and open. The exported opening strips had a
  revolver and the key drawn in, so `import_art.py` redraws those pixels the way the approved page
  draws the chest without them (`open_chest_frame()`), and the game draws the real item instead.
- **The key** (`KeyPickup`) is the secret code item: it floats 2 px over a shadow drawn in
  `_draw()`, with an additive glow sprite and a glint sprite that hops across its top.
- **Handcuffs.** `Player` has a `TRAPPED` state: no moving, shooting or rolling, and each press
  of E counts down. Touch is checked by the officer (its `Contact` area), the escape by the
  player, who then stuns the officer. `Player.trapped` / `escaped` signals drive the HUD and the
  run log's trap count. Contact damage (Rocket Kin, Shade Kin) is one shared `Enemy` method.
- **Arena waves.** `ArenaWaves` counts enemies plus spawn effects still playing, so a wave never
  goes over the limit of 12. The wave mixes are `ArenaWave` resources in a list in
  `balance.tres`; waves past the end of the list repeat the last mix.
- **Barrels.** A `Barrel` is a `StaticBody2D` on its own physics layer (8): the player, enemies and
  bullets collide with it, but explosion and sight rays (walls only) pass it. A player bullet or
  a blast lights it; after a short fuse it explodes through the shared `Explosion`, which lights
  every barrel it reaches, so rows of barrels go off one by one. Enemies path around barrels; once
  one is gone they still walk around the empty spot (the navigation is not rebaked).
- **Enemy looks.** The Officer, Rocket, Shade and Wing Kin wear the approved retexture looks
  (Watcher, Ram, Glitch, Trojan), cut by `import_art.py` from `37_enemies_sheet.png` into
  `art/game/enemies/`. Their scripts and names stay the same; each `SpriteFrames` has `idle`,
  `walk`, `tell` (the warning before an attack), `hit` and `die`. Three switches on `Enemy` serve
  these frames: `procedural_walk` off (the frames already move), `hover` for flyers (they bob over
  a `GroundShadow`), and `fades_on_death` (the dying frame stays and fades). The Grunt and Fuse
  Kin keep their old look until their new one is chosen.
- **Shade Kin teleports.** `ShadeKin` floats in `FLOAT`; every 3-6 s it `TWITCH`es (looks only) or
  teleports through `TEAR`, `GONE` and `UNFOLD`. While teleporting its hitbox is off, contact
  damage is skipped and `take_damage()` does nothing, so it can neither hurt nor be hit.
- **Rocket Kin** is a small state machine (`WANDER`, `TELEGRAPH`, `DASH`, `STUN`). Contact damage
  checks the overlapping player hurtbox every frame, and the player's own invulnerability keeps it
  to one heart per touch.
- **Navigation baked at runtime.** The `NavigationRegion2D` covers the whole map and Godot cuts
  the wall collision out of it, shrunk by the enemy's radius so enemies do not scrape corners.
  Each enemy has a `NavigationAgent2D` that asks for the next point on the path.
- **The gun in hand vs. the guns carried.** `Gun` is the one node in the hand that shoots. Each
  carried gun is an `OwnedGun` (stats plus its own ammo). Switching guns hands a different
  `OwnedGun` to the same `Gun` node, so ammo is kept per gun without extra nodes.
- **Hitboxes separate from feet.** Characters collide with walls at their feet (top-down
  convention), but bullets hit a circle around the body: the player's `Hurtbox` and each enemy's
  `Hitbox`. Otherwise bullets aimed at the body would fly past.
- **Bullets are monitorable Area2Ds.** In Godot 4.7 an `Area2D` with `monitorable = false` does
  not notice tile walls (`TileMapLayer` bodies), so bullets keep the default `monitorable = true`.
  `tests/test_walls.gd` fires both kinds of bullet at a real tile wall.
- **ASCII art screens are real text.** `AsciiArt` (`scripts/ui/ascii_art.gd`) draws a picture
  made of characters, one per square cell, with `draw_char()`: the menu TV (read from the 89x68
  grid in `art/game/menu_tv.txt`) or a panel it generates (the pause menu). Because every cell is
  drawn on its own, the boot-up and the shimmer can change single characters. The look (phosphor
  colours, the font, glowing boxes and buttons) is in `PhosphorStyle`
  (`scripts/ui/phosphor_style.gd`), sized in cells. The glow, scanlines, sweeping band and
  flicker are one shader over the picture (`shaders/crt.gdshader`) that reads the screen
  underneath it. Plain `.txt` files are not exported by default, so the export presets include
  `art/game/*.txt`.
- **Sharp text for ASCII screens.** The game renders at 640x360 and scales the pixels up, which
  would turn 5 px characters to mush. So while an ASCII screen is open the window uses the
  `canvas_items` content scale mode (text drawn at the real resolution) and goes back to
  `viewport` when it closes: the TV menus do it while they exist, the pause menu while paused.
- **The TV menus share one base.** `TvMenu` (`scripts/ui/tv_menu.gd`) sizes the TV to fill the
  screen, lays the CRT shader over it, places the menu's screen area in TV cells and fades the UI
  in after the boot-up. `PasswordScreen` and the main menu extend it and only add their own UI.
- **Smooth motion.** Physics runs 60 times a second; `physics/common/physics_interpolation`
  draws everything in between, so motion is smooth on 120 Hz screens too. Teleports (the spawn,
  the boss's Fade) call `reset_physics_interpolation()` so they jump instead of sliding. Enemies
  ask their `NavigationAgent2D` for a new path only when the target moved more than 8 px.
- **Physics layers.** 1 walls (and crates, chests), 2 player, 3 enemies, 4 player bullets,
  5 enemy bullets, 6 player hurtbox, 7 enemy hitboxes, 8 barrels (named in `project.godot`).
  The Shade Kin collides with nothing, which is how it drifts through walls. The Wing Kin
  collides like every other enemy: if it could fly over walls it could hover where the player's
  bullets never reach it.
- **Pausing.** `get_tree().paused = true` stops every normal node, including `RoundTimer`. The
  pause menu and end screen use `process_mode = Always`, so they keep working.
- **Animations ready for real sheets.** Every character uses an `AnimatedSprite2D` with a
  `SpriteFrames` resource that has `idle`, `walk`, `roll`, `hit` and `die`. The enemies still have
  one frame each. Real sheets go into the `.tres` files; the code only calls `play(&"walk")`.
- **The hero, Telly.** `tools/import_art.py` cuts the approved sheet (`17_hero_sheet.png`, 24x24
  cells, one animation per row) into `art/game/hero/`, cuts the screen-faces out of it, and makes
  the standing back view (the first walk-back frame with its 1 px dip lifted). The walk frames
  already have the dip, so the player does not get the procedural walk bob. Shouting, the reload
  bar and the X eyes are a `Face` sprite over the screen, so they show on any body frame (also
  while walking). The view comes from the aim: back view when aiming up, mirrored when aiming
  left. The `Arm` sits at the rig's front or back hand spot on the aiming side and is drawn
  before the body in the back view. A shot pushes the arm back and kicks the muzzle; a reload
  tips it. All these numbers are in `HeroRig` (`config/hero_rig.tres`), not in the script. The
  roll sets the 5 tumble frames from its progress, so they always fill `roll_duration`.
- **Juice in one component.** `scripts/fx/juice.gd` (`Juice`) does the walk bob, footstep squash,
  roll dust, hit flash and puffs for whatever sprite it points at; the player and every enemy use
  it. The gun's own juice (the 2-frame muzzle flash, casings) lives in `Gun`.
- **Fake height for casings.** A casing is a 2D node that tracks how high above the floor it is
  and moves its sprite up by that much. That is enough for a top-down bounce without 3D physics.
- **Draw order with z_index.** Floor tiles are at -10, casings and dust at -5, items on the floor
  at -1, characters, walls and chests at 0 (y-sorted among themselves), bullets, sparks and
  blasts at 5.
- **Own test runner instead of GUT.** About 60 lines, no third-party code to vendor or keep in
  step with the Godot version. Tests advance time by calling `_physics_process` / `_process` with a
  fixed step, so they are fast and do not depend on the frame rate. A test file that fails to
  compile counts as a failure, and so does any engine or script error during a test (the runner
  listens to Godot's log through a `Logger`).
