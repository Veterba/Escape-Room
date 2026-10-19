"""Draws the art we make ourselves (tiles, bullets, casings, flashes, hands, UI frames) into art/game/.

Every sprite is a grid of characters, one per pixel, using only the palette from file 25.
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
}

# 16x16 tiles. The tile set atlas is these five tiles side by side, in this order.
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

FLOOR_CASINGS = [
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSBBBMSSSSSSSSA",
    "SSSAAAASSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSASSSA",
    "SSSSSSSSSSASSSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSMBBBSSSA",
    "SSSSSSSSAAAASSSA",
    "SSSSSSSSSSSSSSSA",
    "SSSSSSSSSSSSSSSA",
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

TILES = [FLOOR_PLAIN, FLOOR_CRACKED, FLOOR_CASINGS, WALL_TOP, WALL_FACE]

PLAYER_BULLET = [
    ".AAAA.",
    "ABBBBA",
    "ABOBBA",
    "ABBBBA",
    "ABBBBA",
    ".AAAA.",
]

SHELL_CASING = [
    "OBBM",
    "BBBM",
]

MUZZLE_FLASH = [
    "O..B..O",
    ".OBBBO.",
    ".BBOBB.",
    "BBOOOBB",
    ".BBOBB.",
    ".OBBBO.",
    "O..B..O",
]

HAND = [
    ".AA.",
    "AOOA",
    "AOOA",
    ".AA.",
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
        "shell_casing": SHELL_CASING,
        "muzzle_flash": MUZZLE_FLASH,
        "hand": HAND,
        "ui_panel": UI_PANEL,
    }
    for name, grid in sprites.items():
        draw(grid).save(GAME_DIR / f"{name}.png")
    print(f"tiles.png and {len(sprites)} sprites written to {GAME_DIR}")


if __name__ == "__main__":
    main()
