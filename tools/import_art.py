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
    "01": ("hero", 24),
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


if __name__ == "__main__":
    main()
