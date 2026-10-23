"""Converts the source art in art/source/ into game-ready, true-pixel PNGs in art/game/.

Re-runnable: run `python3 tools/import_art.py` from the repo root after replacing any source file.
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIR = ROOT / "art" / "source"
GAME_DIR = ROOT / "art" / "game"

# Pixel art that was scaled up exactly 16x: shrink by 16 to get the true pixels.
UPSCALE_FACTOR = 16

# Characters cut from a screenshot (non-integer scale): shrink to a target height in pixels.
# Source file prefix -> (output name, target height).
CHARACTERS = {
    "02": ("boss_ammo_wraith", 64),
    "03": ("enemy_grunt_kin", 22),
    "04": ("enemy_officer_kin", 22),
    "05": ("enemy_fuse_kin", 22),
    "06": ("enemy_rocket_kin", 28),
    "07": ("enemy_wing_kin", 22),
    "08": ("enemy_shade_kin", 22),
}

# Guns and items: source file prefix -> output name.
NATIVE_ART = {
    "09": "gun_pop_pistol",
    "10": "gun_brass_revolver",
    "11": "gun_scattershot",
    "12": "gun_fuse_launcher",
    "13": "gun_gold_detonator",
    "14": "item_rusty_knife",
    "15": "item_secret_code",
    "16": "item_heart",
    "17": "item_ammo_box",
    "18": "item_smoke_bomb",
    "19": "item_code_chest",
    "20": "item_hourglass",
    "21": "item_exit_key",
}

# Items lying on the floor use a half-size copy, so they stay small next to the 24 px hero.
# The full-size drawings are still used in the HUD.
FLOOR_ITEMS = ["item_secret_code", "item_heart", "item_ammo_box", "item_smoke_bomb", "item_hourglass"]
FLOOR_ITEM_SHRINK = 2

# The hero, Telly: every approved frame in one sheet, 1 px = 1 game pixel, in 24x24 cells.
# Each row is one animation: (output name, number of frames), top to bottom.
HERO_SHEET = "retexture/17_hero_sheet.png"
HERO_DIR = "hero"
HERO_CELL = 24
HERO_ROWS = [
    ("idle", 3), ("walk_front", 4), ("walk_back", 4), ("roll", 5),
    ("hit", 2), ("reload", 4), ("shoot", 1), ("die", 4),
]
# The screen-face: where the screen's inside is in a cell (left, top, width, height). The faces
# for shouting, reloading and being hurt are cut from there, so the game can show them on any
# body frame (also while walking).
HERO_FACE = (8, 6, 11, 8)
HERO_FACES = {"shout": ("shoot", 0), "hurt": ("hit", 1),
              "reload_0": ("reload", 0), "reload_1": ("reload", 1), "reload_2": ("reload", 2), "reload_3": ("reload", 3)}
# Standing in the back view is not a frame of its own in the sheet: it is the first walk-back
# frame (both feet down) without its 1 px dip, made by lifting the body back up onto the legs.
HERO_LEG_ROWS = 3
# The starting gun as held in the hand, 1 px = 1 game pixel.
STARTER_GUN_SOURCE = "retexture/18_gun_starter.png"
STARTER_GUN_OUTPUT = "held_pop_pistol.png"

# Art from the retexture references lives in art/source/retexture/, under its own numbers.
# The password menu's TV as a character grid (columns x rows). The source file has the trailing
# spaces of each row cut off, so every row is padded back to the full width.
MENU_TV_SOURCE = "retexture/15_menu_tv_ascii.txt"
MENU_TV_OUTPUT = "menu_tv.txt"
MENU_TV_SIZE = (89, 68)

# Files 22-25 are map layout references and the palette: they are never used in game.


def find_source(prefix: str) -> Path:
    matches = sorted(SOURCE_DIR.glob(f"{prefix}_*.png"))
    if not matches:
        raise FileNotFoundError(f"No source file starting with {prefix}_ in {SOURCE_DIR}")
    return matches[0]


def harden_alpha(image: Image.Image) -> Image.Image:
    """Makes every pixel fully opaque or fully transparent, so there are no soft edges."""
    alpha = image.getchannel("A").point(lambda a: 255 if a >= 128 else 0)
    image.putalpha(alpha)
    return image


def convert_character(source: Path, target_height: int) -> Image.Image:
    image = Image.open(source).convert("RGBA")
    width = round(image.width * target_height / image.height)
    return harden_alpha(image.resize((width, target_height), Image.NEAREST))


def convert_native(source: Path) -> Image.Image:
    image = Image.open(source).convert("RGBA")
    if image.width % UPSCALE_FACTOR or image.height % UPSCALE_FACTOR:
        raise ValueError(f"{source.name} is {image.size}, not a multiple of {UPSCALE_FACTOR}")
    size = (image.width // UPSCALE_FACTOR, image.height // UPSCALE_FACTOR)
    # Pillow's nearest filter samples the centre of each 16x16 block.
    return harden_alpha(image.resize(size, Image.NEAREST))


def convert_hero() -> None:
    sheet = Image.open(SOURCE_DIR / HERO_SHEET).convert("RGBA")
    out_dir = GAME_DIR / HERO_DIR
    out_dir.mkdir(exist_ok=True)
    frames = {}
    for row, (name, count) in enumerate(HERO_ROWS):
        for i in range(count):
            box = (i * HERO_CELL, row * HERO_CELL, (i + 1) * HERO_CELL, (row + 1) * HERO_CELL)
            frames[(name, i)] = sheet.crop(box)
            frames[(name, i)].save(out_dir / f"{name}_{i}.png")
    left, top, width, height = HERO_FACE
    for face, key in HERO_FACES.items():
        frames[key].crop((left, top, left + width, top + height)).save(out_dir / f"face_{face}.png")
    frames[("walk_back", 0)].save(out_dir / "idle_back_1.png")
    out_dir.joinpath("idle_back_0.png").unlink(missing_ok=True)
    _lift_onto_legs(frames[("walk_back", 0)], frames[("idle", 0)]).save(out_dir / "idle_back_0.png")
    print(f"{HERO_DIR}/  {sum(count for _, count in HERO_ROWS) + 2} frames and {len(HERO_FACES)} faces")


def _lift_onto_legs(dipped: Image.Image, standing_front: Image.Image) -> Image.Image:
    """The dipped back-view frame with its body 1 px higher. The legs' top row, hidden under the
    dipped body, is the standing front view's, mirrored (the back view is the front mirrored)."""
    size = HERO_CELL
    legs_top = size - HERO_LEG_ROWS
    lifted = Image.new("RGBA", (size, size))
    lifted.paste(dipped.crop((0, 1, size, legs_top + 1)), (0, 0))
    lifted.paste(standing_front.crop((0, legs_top, size, legs_top + 1)).transpose(Image.FLIP_LEFT_RIGHT), (-1, legs_top))
    lifted.paste(dipped.crop((0, legs_top + 1, size, size)), (0, legs_top + 1))
    return lifted


def convert_menu_tv() -> None:
    width, height = MENU_TV_SIZE
    rows = (SOURCE_DIR / MENU_TV_SOURCE).read_text().split("\n")
    rows = [row.rstrip("\r") for row in rows][:height]
    if len(rows) != height or max(len(row) for row in rows) > width:
        raise ValueError(f"{MENU_TV_SOURCE} must be at most {width} columns and exactly {height} rows")
    (GAME_DIR / MENU_TV_OUTPUT).write_text("\n".join(row.ljust(width) for row in rows) + "\n")
    print(f"{MENU_TV_OUTPUT}  {width}x{height} characters")


def main() -> None:
    GAME_DIR.mkdir(parents=True, exist_ok=True)
    for prefix, (name, height) in CHARACTERS.items():
        out = convert_character(find_source(prefix), height)
        out.save(GAME_DIR / f"{name}.png")
        print(f"{name}.png  {out.width}x{out.height}")
    for prefix, name in NATIVE_ART.items():
        out = convert_native(find_source(prefix))
        out.save(GAME_DIR / f"{name}.png")
        print(f"{name}.png  {out.width}x{out.height}")
        if name in FLOOR_ITEMS:
            small = out.resize((out.width // FLOOR_ITEM_SHRINK, out.height // FLOOR_ITEM_SHRINK), Image.NEAREST)
            small.save(GAME_DIR / f"floor_{name}.png")
            print(f"floor_{name}.png  {small.width}x{small.height}")
    convert_menu_tv()
    convert_hero()
    Image.open(SOURCE_DIR / STARTER_GUN_SOURCE).convert("RGBA").save(GAME_DIR / STARTER_GUN_OUTPUT)
    print(STARTER_GUN_OUTPUT)


if __name__ == "__main__":
    main()
