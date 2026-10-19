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
| `tools/` | Python art scripts. |

## Autoloads

Autoloads are scripts Godot creates once at startup and keeps for the whole game; any script can
use them by name.

- `Config` (`scripts/autoload/config.gd`) loads `config/balance.tres` once. Scripts read numbers as
  `Config.balance.player_move_speed`. No gameplay numbers are written into scripts.
- `Audio` (`scripts/autoload/audio.gd`) has an empty `play_sfx()`. The calls mark where sounds
  will go; sound is out of scope for now.

`scripts/strings.gd` (`Strings`) is not an autoload: it only holds constants, all player-facing text.

## Scenes

```
TestRoom (scenes/rooms/test_room.tscn)        builds the room from a text layout
├── Tiles (TileMapLayer)                      floor and walls; wall tiles have collision
├── Player (scenes/player/player.tscn)
│   ├── Body (AnimatedSprite2D)               hero art, animations from hero_frames.tres
│   ├── Juice                                 shared game-feel component
│   ├── GunPivot                              rotates towards the mouse
│   │   └── Gun (scenes/guns/gun.tscn)        sprite, hand, muzzle, ejection port
│   └── Camera (GameCamera)
├── HUD (scenes/ui/hud.tscn)                  a CanvasLayer, drawn on top of everything
└── (bullets, casings and particle puffs are added here at runtime)
```

## Key decisions

- **One balance resource.** `BalanceConfig` is a `Resource` with typed `@export` fields; the values
  are in `config/balance.tres`. Guns are `GunStats` sub-resources inside it, so a gun's numbers and
  its art data (grip, muzzle and ejection pixels) sit together.
- **Animations ready for real sheets.** Every character uses an `AnimatedSprite2D` with a
  `SpriteFrames` resource that has `idle`, `walk`, `roll`, `hit` and `die`. Today each has one
  frame. Real sheets go into the `.tres` file; the code only calls `play(&"walk")` and so on.
- **Juice in one component.** `scripts/fx/juice.gd` (`Juice`) does the walk bob, footstep squash,
  roll spin, hit flash and puffs for whatever sprite it points at. Enemies will reuse it.
  Gun juice (muzzle flash, recoil, casings) lives in `Gun`, because every gun needs it.
- **Fake height for casings.** A casing is a 2D node that tracks how high above the floor it is
  and moves its sprite up by that much. That is enough for a top-down bounce without 3D physics.
- **Draw order with z_index.** Floor tiles are at -10, casings and dust at -5, characters at 0,
  bullets and sparks at 5. The gun goes behind the hero only when aiming steeply up.
- **Physics layers.** 1 walls, 2 player, 3 enemies, 4 player bullets, 5 enemy bullets
  (named in `project.godot`).
- **Own test runner instead of GUT.** About 50 lines, no third-party code to vendor or keep in
  step with the Godot version. Tests advance time by calling `_physics_process` / `_process` with a
  fixed step, so they are fast and do not depend on the frame rate.
