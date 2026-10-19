# Escape Boom

A top-down roguelite shooter in the style of Enter the Gungeon, made as a school project.
One random map per round, a 10:00 timer, find the secret code before time runs out.

Current version: **0.1.0** (Part A: player, Pop Pistol and a test room).

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

### Controls (Part A)

| Action | Input |
|---|---|
| Move | WASD |
| Aim | Mouse |
| Shoot (hold for auto-fire) | Left mouse button |
| Dodge roll | Space or right mouse button |
| Reload | R |

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

## Tuning

Every gameplay number lives in `config/balance.tres` (its fields are documented in
`config/balance_config.gd`). Change a value there and restart the game.

## Project layout

See `docs/ARCHITECTURE.md`.
