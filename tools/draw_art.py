"""Draws the art we make ourselves (tiles, bullets, casings, flashes, hands, UI frames) into art/game/.

Every sprite is a grid of characters, one per pixel, using the palette from file 25 (the hero's
hand and muzzle flash use the approved hero palette from the retexture spec).
Re-runnable: run `python3 tools/draw_art.py` from the repo root.
"""
from pathlib import Path

from PIL import Image

GAME_DIR = Path(__file__).resolve().parent.parent / "art" / "game"

PALETTE = {
    ".": (0, 0, 0, 0),           # transparent
    "B": (0xF0, 0xB4, 0x3C, 255),  # brass, main accent
    "R": (0xE0, 0x40, 0x3A, 255),  # red
    "T": (0x3F, 0xC1, 0xB0, 255),  # teal
    "O": (0xF3, 0xE7, 0xD3, 255),  # bone, text
    "M": (0x4A, 0x42, 0x58, 255),  # mortar
    "S": (0x2C, 0x26, 0x36, 255),  # stone
    "A": (0x0B, 0x08, 0x10, 255),  # abyss, outlines and background
    # The hero's palette (retexture spec), for his hand and muzzle flash.
    "k": (0x00, 0x00, 0x00, 255),  # outline
    "t": (0xC0, 0xAD, 0x7E, 255),  # body tan
    "h": (0xFF, 0xFE, 0xD2, 255),  # highlight
    "y": (0xFF, 0xFF, 0x81, 255),  # face yellow
    "l": (0xFF, 0xF7, 0xC2, 255),  # flash core
    # The key's glint (approved retexture page).
    "g": (0xFF, 0xD1, 0x66, 255),  # gold
    "W": (0xFF, 0xFF, 0xFF, 255),  # white
}

# 16x16 tiles. The tile set atlas is these tiles side by side, in the order of TILES below.
# New tiles go at the end, so the atlas coordinates of the old ones never change.
FLOOR_PLAIN = [
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSMSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSMSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "AAAAAAAAAAAAAAAA",
]

FLOOR_CRACKED = [
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSASSSA",
    "SSSSSSSSSSASSSSA",
    "SSSSSSSSSASSSSSA",
    "SSSSSSSSAASSSSSA",
    "SSSSSSSASSSSSSSA",
    "SSSSSSASSSSSSSSA",
    "SSSSSSASSSSSSSSA",
    "SSSSSASSSSSSSSSA",
    "SSSAASSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSMSSA",
    "SSSSSSSSSSSSSSSA",
    "AAAAAAAAAAAAAAAA",
]

# A floor tile with its top-left corner chipped off.
FLOOR_CHIPPED = [
    "AAAMSSSSSSSSSSSA",
    "AAMSSSSSSSSSSSSA",
    "AMSSSSSSSSSSSSSA",
    "MSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSMSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSMSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "AAAAAAAAAAAAAAAA",
]

# A crate in the arena: cover that never breaks. Top face, then the front with a diagonal brace.
CRATE = [
    "AAAAAAAAAAAAAAAA",
    "AOOOOOOOOOOOOOOA",
    "AOBBBBBBBBBBBBBA",
    "AOBBBBBBBBBBBBBA",
    "ABBBBBBBBBBBBBBA",
    "AAAAAAAAAAAAAAAA",
    "ABBBBBBBBBBBBBBA",
    "ABMMMMMMMMMMBBBA",
    "ABMMMMMMMMBBMMBA",
    "ABMMMMMMBBMMMMBA",
    "ABMMMMBBMMMMMMBA",
    "ABMMBBMMMMMMMMBA",
    "ABBBMMMMMMMMMMBA",
    "ABBBBBBBBBBBBBBA",
    "AAAAAAAAAAAAAAAA",
    "AAAAAAAAAAAAAAAA",
]

# Seen from above: the top of a wall, dark bricks.
WALL_TOP = [
    "SSSSSSSASSSSSSSA",
    "SSSSSSSASSSSSSSA",
    "SSSSSSSASSSSSSSA",
    "AAAAAAAAAAAAAAAA",
    "SSSASSSSSSSASSSS",
    "SSSASSSSSSSASSSS",
    "SSSASSSSSSSASSSS",
    "AAAAAAAAAAAAAAAA",
    "SSSSSSSASSSSSSSA",
    "SSSSSSSASSSSSSSA",
    "SSSSSSSASSSSSSSA",
    "AAAAAAAAAAAAAAAA",
    "SSSASSSSSSSASSSS",
    "SSSASSSSSSSASSSS",
    "SSSASSSSSSSASSSS",
    "AAAAAAAAAAAAAAAA",
]

# The front of a wall that faces the player: a light cap, lighter bricks, a shadow at the foot.
WALL_FACE = [
    "MMMMMMMMMMMMMMMM",
    "AAAAAAAAAAAAAAAA",
    "MMMMMMMSMMMMMMMS",
    "MMMMMMMSMMMMMMMS",
    "MMMMMMMSMMMMMMMS",
    "SSSSSSSSSSSSSSSS",
    "MMMSMMMMMMMSMMMM",
    "MMMSMMMMMMMSMMMM",
    "MMMSMMMMMMMSMMMM",
    "SSSSSSSSSSSSSSSS",
    "MMMMMMMSMMMMMMMS",
    "MMMMMMMSMMMMMMMS",
    "MMMMMMMSMMMMMMMS",
    "SSSSSSSSSSSSSSSS",
    "AAAAAAAAAAAAAAAA",
    "AAAAAAAAAAAAAAAA",
]

TILES = [FLOOR_PLAIN, FLOOR_CRACKED, WALL_TOP, WALL_FACE, FLOOR_CHIPPED, CRATE]

PLAYER_BULLET = [
    ".AAAA.",
    "ABBBBA",
    "ABOBBA",
    "ABBBBA",
    "ABBBBA",
    ".AAAA.",
]

# Gungeon-style enemy bullet: big, round, bright outline so it reads on the dark floor.
ENEMY_BULLET = [
    "..OOOO..",
    ".ORRRRO.",
    "ORROORRO",
    "ORROORRO",
    "ORRRRRRO",
    "ORRRRRRO",
    ".ORRRRO.",
    "..OOOO..",
]

# Wing Kin bullet: the same shape in teal.
WING_BULLET = [
    "..OOOO..",
    ".OTTTTO.",
    "OTTOOTTO",
    "OTTOOTTO",
    "OTTTTTTO",
    "OTTTTTTO",
    ".OTTTTO.",
    "..OOOO..",
]

# Red barrel: explodes when shot.
BARREL = [
    "..AAAAAAAA..",
    ".ARRRRRRRRA.",
    "ARMMMMMMMMRA",
    "ARRRRRRRRRRA",
    "AMMMMMMMMMMA",
    "AROORRRRRRRA",
    "AROORRRRRRRA",
    "ARORRRRRRRRA",
    "ARRRRRRRRRRA",
    "AMMMMMMMMMMA",
    "AROORRRRRRRA",
    "ARORRRRRRRRA",
    "ARRRRRRRRRRA",
    ".ARRRRRRRRA.",
    "..AAAAAAAA..",
]

# A gate across a doorway while a fight room is locked: iron bars between brass rails.
DOOR = [
    "AAAAAAAAAAAAAAAA",
    "ABBBBBBBBBBBBBBA",
    "AAAAAAAAAAAAAAAA",
    ".AM.AM.AM.AM.AM.",
    ".AM.AM.AM.AM.AM.",
    ".AM.AM.AM.AM.AM.",
    ".AM.AM.AM.AM.AM.",
    ".AO.AO.AO.AO.AO.",
    ".AM.AM.AM.AM.AM.",
    ".AM.AM.AM.AM.AM.",
    ".AM.AM.AM.AM.AM.",
    ".AM.AM.AM.AM.AM.",
    "AAAAAAAAAAAAAAAA",
    "ABBBBBBBBBBBBBBA",
    "AAAAAAAAAAAAAAAA",
    "................",
]

# The exit of the boss floor: a hatch with steps going down.
EXIT_HATCH = [
    "AAAAAAAAAAAAAAAA",
    "ABBBBBBBBBBBBBBA",
    "ABAAAAAAAAAAAABA",
    "ABAMMMMMMMMMMABA",
    "ABAAAAAAAAAAAABA",
    "ABASSSSSSSSSSABA",
    "ABAAAAAAAAAAAABA",
    "ABAAMMMMMMMMAABA",
    "ABAAAAAAAAAAAABA",
    "ABAAASSSSSSAAABA",
    "ABAAAAAAAAAAAABA",
    "ABAAAAAAAAAAAABA",
    "ABAAAAAAAAAAAABA",
    "ABAAAAAAAAAAAABA",
    "ABBBBBBBBBBBBBBA",
    "AAAAAAAAAAAAAAAA",
]

# Fuse Launcher rocket, pointing right.
ROCKET = [
    ".AAAAA..",
    "AMRRRRA.",
    "ABRRRROA",
    "AMRRRRA.",
    ".AAAAA..",
]

# Gold Detonator bullet: brass with a teal core.
GOLD_BULLET = [
    ".AAAA.",
    "ABBBBA",
    "ABTTBA",
    "ABTTBA",
    "ABBBBA",
    ".AAAA.",
]

SHELL_CASING = [
    "OBBM",
    "BBBM",
]

# The muzzle flash, two frames: the first is bigger. Drawn pointing right; its left edge sits one
# pixel past the muzzle, its middle row on the muzzle.
MUZZLE_FLASH_BIG = [
    ".y...",
    "lll.y",
    "llly.",
    "lll.y",
    ".y...",
]

MUZZLE_FLASH_SMALL = [
    ".y...",
    "lll..",
    "llly.",
    "lll..",
    ".y...",
]

# The glint that runs across the key now and then: a white spark with gold around it.
KEY_GLINT = [
    ".g.",
    "gWg",
    ".g.",
]

# The hero's one hand: a small tan fist on the gun's grip.
HAND = [
    "kkkk",
    "khtk",
    "kttk",
    "kkkk",
]

# A 9-slice frame for HUD panels: 3 px margins on every side.
UI_PANEL = [
    ".AAAAAA.",
    "AMMMMMMA",
    "AMAAAAMA",
    "AMAAAAMA",
    "AMAAAAMA",
    "AMAAAAMA",
    "AMMMMMMA",
    ".AAAAAA.",
]


def draw(grid: list[str]) -> Image.Image:
    width = len(grid[0])
    assert all(len(row) == width for row in grid), "every row of a sprite must have the same length"
    image = Image.new("RGBA", (width, len(grid)))
    for y, row in enumerate(grid):
        for x, char in enumerate(row):
            image.putpixel((x, y), PALETTE[char])
    return image


def draw_atlas(tiles: list[list[str]]) -> Image.Image:
    atlas = Image.new("RGBA", (16 * len(tiles), 16))
    for index, tile in enumerate(tiles):
        atlas.paste(draw(tile), (16 * index, 0))
    return atlas


def main() -> None:
    GAME_DIR.mkdir(parents=True, exist_ok=True)
    draw_atlas(TILES).save(GAME_DIR / "tiles.png")
    sprites = {
        "bullet_player": PLAYER_BULLET,
        "bullet_enemy": ENEMY_BULLET,
        "bullet_rocket": ROCKET,
        "bullet_gold": GOLD_BULLET,
        "bullet_wing": WING_BULLET,
        "barrel": BARREL,
        "door": DOOR,
        "exit_hatch": EXIT_HATCH,
        "shell_casing": SHELL_CASING,
        "muzzle_flash_big": MUZZLE_FLASH_BIG,
        "muzzle_flash_small": MUZZLE_FLASH_SMALL,
        "hand": HAND,
        "key_glint": KEY_GLINT,
        "ui_panel": UI_PANEL,
    }
    for name, grid in sprites.items():
        draw(grid).save(GAME_DIR / f"{name}.png")
    print(f"tiles.png and {len(sprites)} sprites written to {GAME_DIR}")


if __name__ == "__main__":
    main()
