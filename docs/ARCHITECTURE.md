# Architecture

How Escape Boom is put together. Updated at the end of every part.

## Folders

| Folder | What is in it |
|---|---|
| `art/source/` | Original art copied from the vault. Never used directly (a `.gdignore` hides it from Godot). |
| `art/game/` | Game-ready PNGs made by the two scripts in `tools/`. |
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
- `Game` (`scripts/autoload/game.gd`) moves between the menu and rounds, picks the map
  (uniform random, or the one forced with `--map=`), and lists the three map scenes.

`scripts/strings.gd` (`Strings`) is not an autoload: it only holds constants, all player-facing text.

## Game flow

```
PasswordScreen (scenes/ui/password_screen.tscn)  --right password-->  MainMenu   (main scene: once per launch)
MainMenu (scenes/ui/main_menu.tscn)  --Play-->  Game.start_round()  -->  Round
Round  --win / death / timeout-->  EndScreen  --Play again-->  Game.start_round()  (new random map)
                                              --Menu-->        Game.go_to_menu()
```

## The round scene

```
Round (scenes/round/round.tscn)               loads the map, decides the result, writes the run log
├── <map>  (added at runtime, e.g. scenes/maps/enemy_arena.tscn)
│   ├── Navigation (NavigationRegion2D)       walkable area, baked at runtime around the walls
│   │   ├── Floor (TileMapLayer)              floor tiles, always underneath (z_index -10)
│   │   └── Walls (TileMapLayer)              wall tiles with collision, y-sorted
│   ├── chests, barrels, enemies, the code    placed from the map's text layout
│   └── Waves (ArenaWaves, arena only)        sends the waves; EnemySpawn effects become enemies
├── Player (scenes/player/player.tscn)
│   ├── Body (AnimatedSprite2D)               hero art, animations from hero_frames.tres
│   ├── Hurtbox (Area2D)                      where enemy bullets hit: the middle of the body
│   ├── Juice                                 shared game-feel component
│   ├── GunPivot                              rotates towards the mouse
│   │   └── Gun (scenes/guns/gun.tscn)        the gun in hand: sprite, hand, muzzle, ejection port
│   ├── Guns (GunInventory)                   the carried guns and their ammo
│   ├── Interactor                            finds the nearest chest or gun and handles E
│   └── Camera (GameCamera)
├── RoundTimer                                10:00 countdown; a normal node, so pausing stops it
├── HUD, PauseMenu, EndScreen, DebugOverlay   CanvasLayers drawn on top of the world
└── (bullets, casings, puffs and drops are added here at runtime)
```

## Key decisions

- **One balance resource.** `BalanceConfig` is a `Resource` with typed `@export` fields; the values
  are in `config/balance.tres`. Each gun is a `GunStats` sub-resource inside it, so a gun's numbers
  and its art sit together: `icon` (the big drawing, for the HUD and the floor), `held_texture`
  (the small drawing in the hand) and the grip, muzzle and ejection pixels of the held drawing.
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
- **Maps as text.** A map is a `GameMap` scene with a `layout`: one string per row of tiles
  (`#` wall, `x` crate, `.` floor, `P` start, `C` code, `K` code chest spot, `G` gun chest,
  `b` barrel, `g` Grunt Kin, `f` Fuse Kin). The script builds the tiles and entities, then bakes
  the navigation mesh. A crate is a wall tile with crate art, so it blocks everything a wall
  blocks. With several `K` spots, one is picked at random for the code chest.
- **The labyrinth is generated, then built like any map.** `MazeGenerator`
  (`scripts/maps/maze_generator.gd`) carves a grid of cells with a recursive backtracker (each
  cell 2x2 floor tiles, walls one tile thick), finds the distance of every cell from the start
  with a BFS, and puts the code in the farthest one. It retries until the shortest walk takes
  60-90 s, then writes a normal text layout. `Labyrinth` (`scripts/maps/labyrinth.gd`) extends
  `GameMap`: it fills in the layout before the base `_ready()` builds it, then adds the officers
  with patrol routes along corridors (routes cannot be written as one letter in the layout).
- **Darkness** is a `CanvasModulate` that turns the whole map almost black, plus a `PointLight2D`
  with a round gradient texture that follows the player. The HUD is on a `CanvasLayer`, so it
  stays bright.
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
- **Physics layers.** 1 walls (and crates, chests), 2 player, 3 enemies, 4 player bullets,
  5 enemy bullets, 6 player hurtbox, 7 enemy hitboxes, 8 barrels (named in `project.godot`).
  The Wing Kin and the Shade Kin collide with nothing, which is how they pass over and through walls.
- **Pausing.** `get_tree().paused = true` stops every normal node, including `RoundTimer`. The
  pause menu and end screen use `process_mode = Always`, so they keep working.
- **Animations ready for real sheets.** Every character uses an `AnimatedSprite2D` with a
  `SpriteFrames` resource that has `idle`, `walk`, `roll`, `hit` and `die`. Today each has one
  frame. Real sheets go into the `.tres` files; the code only calls `play(&"walk")` and so on.
- **Juice in one component.** `scripts/fx/juice.gd` (`Juice`) does the walk bob, footstep squash,
  roll spin, hit flash and puffs for whatever sprite it points at; the player and every enemy use
  it. Gun juice (muzzle flash, recoil, casings) lives in `Gun`.
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
