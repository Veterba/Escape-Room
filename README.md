# Escape Boom

A top-down roguelite shooter in the style of Enter the Gungeon, made as a school project.
One random map type per round: get the secret code before the 5:00 timer runs out, or beat the boss.

Current version: **0.12.1** (brighter rooms, new HUD gun and smoke bomb).

## Requirements

- **Godot 4.7.2** (stable, standard build, not .NET). Built and tested with `4.7.2.stable.official.ed1daf0bf`.
- Python 3 with Pillow, only to regenerate the art: `python3 -m pip install --user pillow`.

## Run the game

From the repo root:

```sh
godot --path .
```

Or open the folder in the Godot editor and press F5. On a fresh clone, run the import step from
the test section once first (the editor does it automatically).

To skip the menu and force the map type (for testing), add `--map=boss`, `--map=maze` or `--map=arena`:

```sh
godot --path . --map=arena
```

The game opens on the password menu: an ASCII television in green phosphor. Type the 4-digit
access code (Backspace erases) and press Enter or click TRY CODE; the right code goes straight
into a round. The code is in `config/balance.tres` (`1234` for now). The main menu (from the
Menu buttons in the pause and end screens) is the same TV with PLAY and QUIT.
`--map=` skips it.

Every round picks one of three map types at random, and builds it fresh:

- **Enemy Arena:** a floor of 5–6 rooms joined by corridors, with no loading in between. You
  start in a room with one way out. Fight rooms lock their doors until every enemy is dead;
  chest rooms hold a gun chest. The last room is the arena (crates and barrels placed fresh each
  round): survive the waves; the code chest's chains break at wave 4, the last one, and the
  arena's two gun chests unlock then too. Hold E on the code chest for 2 s and the key (the
  secret code) rises out of it.
  5:00 timer.
- **Labyrinth:** one big dark maze, the start in a corner and the code at the far end. Officer
  Kin (Watcher cameras) handcuff you (mash E to break free), Shade Kin (Glitch ghosts) drift
  through walls and teleport now and then, and an hourglass in a
  dead end adds 30 s. 5:00 timer, and no map.
- **Boss Chamber:** a floor like the arena's, ending in the boss room. Root, a virus made of
  windows, has three phases (glides and Belt Lash; plus Bullet Rain and teleports; then it splits
  into its main window and five error windows that fight on their own). Beat it and it drops the
  code (walk over it to win); the door to the exit room opens too. No timer: you only lose by
  dying. A scripted fight (a C-rank gun, half the shots hitting, no dodging needed) beat Root in
  2.6–3.1 minutes over 4 runs.

Press Tab for a map of the rooms you have seen (arena and boss floors).

### Controls

| Action | Input |
|---|---|
| Move | WASD |
| Aim | Mouse |
| Shoot (hold for auto-fire) | Left mouse button, or F |
| Dodge roll | Space or right mouse button |
| Reload | R |
| Switch gun | Mouse wheel, or 1 / 2 / 3 |
| Open a chest (hold), take a gun, break handcuffs (mash) | E |
| Smoke bomb (a wave that clears every enemy bullet on screen) | Q |
| Pause | Esc |
| Map | Tab |
| Debug overlay | F3 |

### Run log

Every finished round adds a line to `runs.csv` in Godot's user folder
(on macOS `~/Library/Application Support/Godot/app_userdata/Escape Boom/runs.csv`, on Windows
`%APPDATA%\Godot\app_userdata\Escape Boom\runs.csv`). Columns: date, map, result
(win/death/timeout), seconds used, hearts lost, times trapped, gun used most.

## Run the tests

Tests run headless with our own small runner (`tests/run_tests.gd`). The first command imports
the project, which a fresh clone needs once so Godot knows the script class names:

```sh
godot --headless --path . --import
godot --headless --path . -s tests/run_tests.gd
```

The runner prints one line per test and exits with code 1 if any test fails.

## Regenerate the art

```sh
python3 tools/import_art.py   # art/source/ -> art/game/ (characters, guns, items)
python3 tools/draw_art.py     # our own pixel art: tiles, bullet, casing, flash, hand, UI frame
```

Both scripts are safe to run again at any time. Replace a file in `art/source/` with the same
number prefix and re-run `import_art.py` to swap in new art.

## Build for Windows and macOS

Install the export templates for Godot 4.7.2 once: open the Godot editor, choose
Editor → Manage Export Templates → Download and Install. They must match the Godot version
exactly. Then, from the repo root:

```sh
tools/export.sh
```

It writes `builds/EscapeBoom-windows.zip` (one `.exe` with the game inside) and
`builds/EscapeBoom-macos.zip` (one app for Apple Silicon and Intel Macs). If `godot` is not on
the PATH, point the script at it: `GODOT=/path/to/godot tools/export.sh`.

The builds are not signed with a developer certificate, so both systems warn the first time:

- **macOS:** unzip, then right-click `Escape Boom.app`, choose Open, then Open again.
- **Windows:** unzip, run `EscapeBoom.exe`; when SmartScreen appears, click More info, then
  Run anyway.

## Tuning

Every gameplay number lives in `config/balance.tres` (its fields are documented in
`config/balance_config.gd`). Change a value there and restart the game.

## Project layout

See `docs/ARCHITECTURE.md`.
