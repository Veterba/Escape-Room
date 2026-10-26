# Escape Boom

A top-down roguelite shooter in the style of Enter the Gungeon, made as a school project.
One random map type per round: get the secret code before the 5:00 timer runs out, or beat the boss.

Current version: **0.14.9** (the word for the next task is RE).

## Install on Windows (no Godot needed)

1. Open the repository on GitHub and go to **Releases** (right-hand side of the main page).
2. Under the newest version, download `EscapeBoom-windows.zip`.
3. Right-click the zip, choose **Extract All**, and open the extracted folder.
4. Double-click `EscapeBoom.exe`. The game is not signed, so Windows SmartScreen warns the first
   time: click **More info**, then **Run anyway**.

Nothing is installed: the `.exe` holds the whole game. To remove it, delete the folder. Saved run
logs live in `%APPDATA%\Godot\app_userdata\Room\`.

### Making a new Windows release

GitHub builds the Windows version by itself (`.github/workflows/windows-release.yml`): push a
version tag and, a few minutes later, the zip appears on the Releases page.

```sh
git tag v0.14.9
git push origin v0.14.9
```

The build can also be started by hand: **Actions** → **Windows release** → **Run workflow**; the
zip is then a download at the bottom of that run's page.

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
into a round. The code is in `config/balance.tres` (`password`, now `6342`). Winning shows only the word for the next escape room task (`next_task_word` there, now `RE`); losing shows no words. The main menu (from the
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
  dying.

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
(on macOS `~/Library/Application Support/Godot/app_userdata/Room/runs.csv`, on Windows
`%APPDATA%\Godot\app_userdata\Room\runs.csv`). Columns: date, map, result
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
python3 tools/import_art.py   # art/source/ -> art/game/ (hero, enemies, Root, guns, chests, rooms, tile set)
python3 tools/draw_art.py     # our own pixel art: bullets, casing, flash, hand, UI frame, smoke bomb, floor details
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

- **macOS:** unzip, then right-click `Room.app`, choose Open, then Open again.
- **Windows:** unzip, run `EscapeBoom.exe`; when SmartScreen appears, click More info, then
  Run anyway.

## Tuning

Every gameplay number lives in `config/balance.tres` (its fields are documented in
`config/balance_config.gd`). Every room light (tint, colours, strengths, radii, how broken lights
drift) lives in `config/lighting.tres` (documented in `config/lighting_config.gd` and
`config/room_lighting.gd`). Change a value there and restart the game.

## Bot check: can every map be won in time?

`tools/bot_check.gd` measures every map type with the Pop Pistol plus one C-rank gun (the Brass
Revolver), assuming half the shots hit:

```sh
godot --headless --path . --fixed-fps 60 -s tools/bot_check.gd
```

- Floors are generated 50 times; it walks the shortest path to the objective room and through
  every chest room and back, and counts the fight rooms' hit points at the pistol's damage.
- The Enemy Arena's code chest unlocks when wave 4 starts, and a wave starts at least every 30 s.
- The Labyrinth's walk times come from the generated mazes (50 seeds).
- The boss is a real fight: a scripted player in a boss round shoots Root with the Brass
  Revolver (half the shots hit, and only while Root can be hit), then walks over the code.

Results (v0.14.0; 110 px/s walking, Pop Pistol 1.33 and Brass Revolver 2.05 damage per second):

| Map | What was measured | Time | Limit |
|---|---|---|---|
| Enemy Arena | floor to the arena: walking, chest rooms, fight rooms (pistol) | 1:02 median, 1:27 worst | |
| Enemy Arena | plus the waves until the code chest unlocks (90 s at most) and opening it (2 s) | 2:59 worst | 5:00 timer |
| Labyrinth | shortest walk to the code | 1:01–1:29 | 5:00 timer (+0:30 hourglass) |
| Labyrinth | walking every corridor of the maze (the worst case for a lost player) | 4:03 | 5:00 timer |
| Boss Chamber | floor to the boss room (same rules as the arena floor) | 0:57 median, 1:17 worst | no timer |
| Boss Chamber | the fight with Root (220 hit points), 4 scripted fights | 2:09–2:48 | target 3–4 min |

Every map can be won inside its limit with room to spare. Root's hit points were lowered from the
spec's 250 to 220 after playtesting showed the fight was too hard: a new player hits far less than
half their shots and has to dodge, so the real fight is longer than the bot's.

## Project layout

See `docs/ARCHITECTURE.md`.
