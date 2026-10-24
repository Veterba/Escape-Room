"""Draws the art we make ourselves (bullets, casings, flashes, hands, UI frames, room details) into art/game/.

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
    # Floor details of the rooms (colours from the approved station page).
    "n": (0x12, 0x12, 0x20, 255),  # oil
    "N": (0x2A, 0x2A, 0x44, 255),  # oil sheen
    "d": (0x4A, 0x4F, 0x6B, 255),  # debris, light
    "D": (0x2C, 0x2F, 0x45, 255),  # debris, dark
    "z": (0x10, 0x11, 0x19, 255),  # debris shadow
    "p": (0xD8, 0xD2, 0xC0, 255),  # paper
    "P": (0x8A, 0x84, 0x78, 255),  # paper lines
    "c": (0x0B, 0x0B, 0x12, 255),  # cable
    "C": (0x33, 0x36, 0x4F, 255),  # cable shine
    "u": (0x14, 0x20, 0x2A, 255),  # floor light strip
    "U": (0x2A, 0xA6, 0xA6, 255),  # floor light strip, lit
    "v": (0x2A, 0x6A, 0x48, 255),  # green puddle
    "V": (0x3F, 0x9A, 0x62, 255),  # green puddle, middle
    "i": (0x6A, 0x2A, 0x52, 255),  # pink puddle
    "I": (0x9A, 0x3A, 0x72, 255),  # pink puddle, middle
    # The red-lit pylons in the corners of the Boss Chamber (approved boss page).
    "o": (0x07, 0x06, 0x0D, 255),  # outline
    "q": (0x2B, 0x2E, 0x45, 255),  # body
    "Q": (0x55, 0x5C, 0x80, 255),  # body, top edge
    "x": (0x19, 0x1A, 0x26, 255),  # foot
    "r": (0xB6, 0x26, 0x49, 255),  # red stripes
    "e": (0x58, 0x5E, 0x72, 255),  # head
    "L": (0xFF, 0x58, 0x73, 255),  # light
    # The smoke bomb (redrawn to match the station art: outline, 3 shades, a teal band).
    "F": (0x58, 0x5E, 0x78, 255),  # body, light
    "G": (0x3A, 0x3E, 0x58, 255),  # body
    "H": (0x2A, 0x2C, 0x43, 255),  # body, dark
    "J": (0x88, 0x90, 0xA6, 255),  # shine
    "K": (0x74, 0xF2, 0xE0, 255),  # band, lit
    "X": (0x27, 0xA3, 0xA3, 255),  # band
    "f": (0x8A, 0x6A, 0x44, 255),  # fuse
    "Y": (0xFF, 0xD1, 0x66, 255),  # spark
    "Z": (0xFF, 0x9F, 0x43, 255),  # spark, orange
}

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


# Flat details lying on the rooms' floors (art/game/rooms/details/).
OIL = [
    "...nnnnnnnn...",
    ".nnNnnnNnnnNn.",
    "nnnnnnnnnnnnnn",
    ".nnnnnnnnnnnn.",
    "...nnnnnnnn...",
]

DEBRIS = [
    "dd.......DDD....",
    "zz..d.....zzz.d.",
    "....z.DD......z.",
    ".DDD..zz...dd...",
    ".zzz.......zz...",
]

PAPERS = [
    "pppppp.......",
    "pPPPPp..ppppp",
    "pppppp..pPPPp",
    "pPPPpp..ppppp",
    "pppppp..pPPpp",
    "........ppppp",
]

CABLE = [
    "CC........................CCC...",
    "ccCC....................CCccc...",
    "..ccCCC...........CCCCCcc...CC..",
    ".....ccCCCCCCCCCCCccccc.....ccCC",
    "..........ccccccccc...........cc",
]

FLOOR_STRIP = [
    "UUUuuuUUUuuuUUUuuuUUUuuuUUUuuuUU",
    "uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu",
]

PUDDLE_GREEN = [
    ".....vvvvvvvvvv.....",
    "..vvvvvvVVVVvvvvvv..",
    ".vvvvVVVVVVVVVVvvvv.",
    "vvvvVVVVVVVVVVVVvvvv",
    ".vvvvVVVVVVVVVVvvvv.",
    "..vvvvvvVVVVvvvvvv..",
    ".....vvvvvvvvvv.....",
]

PUDDLE_PINK = [
    "....iiiiiiiiii....",
    "..iiiiiIIIIiiiiii.",
    ".iiiIIIIIIIIIIiiii",
    "iiiiIIIIIIIIIIIii.",
    ".iiiiiiIIIIiiiii..",
    "...iiiiiiiiiii....",
]

# The smoke bomb, on the floor and (twice as big) in the HUD.
SMOKE_BOMB = [
    "........Y..",
    ".......YWYZ",
    "......ofY..",
    ".....of....",
    "...oeeeo...",
    "..ooFFFoo..",
    ".oFJFGGGHo.",
    "oFJFGGGGGHo",
    "oKKKKKKXXXo",
    "oXXXXXXXXXo",
    "oGGGGGGGHHo",
    ".oGGGGGHHo.",
    "..ooHHHoo..",
    "....ooo....",
]

# A pylon with red stripes and a red light on top (a room object of the Boss Chamber).
PYLON = [
    "................",
    ".......oo.......",
    "......oLLo......",
    "......oLLo......",
    ".....oeeeeo.....",
    ".....oeeeeo.....",
    ".....oeeeeo.....",
    ".....oeeeeo.....",
    ".....oeeeeo.....",
    "...oooeeeeooo...",
    "..oQQQQQQQQQQo..",
    "..oqqqqqqqqqqo..",
    "..oqqqqqqqqqqo..",
    "..oqqqqqqqqqqo..",
    "..oqrrrrrrrrqo..",
    "..oqqqqqqqqqqo..",
    "..oqqqqqqqqqqo..",
    "..oqqqqqqqqqqo..",
    "..oqrrrrrrrrqo..",
    "..oqqqqqqqqqqo..",
    "..oqqqqqqqqqqo..",
    "..oqqqqqqqqqqo..",
    "..oqrrrrrrrrqo..",
    "..oqqqqqqqqqqo..",
    "..oqqqqqqqqqqo..",
    "..oqqqqqqqqqqo..",
    "..oqrrrrrrrrqo..",
    "..oqqqqqqqqqqo..",
    ".oxxxxxxxxxxxxo.",
    ".oxxxxxxxxxxxxo.",
    ".oxxxxxxxxxxxxo.",
    ".oxxxxxxxxxxxxo.",
    "..oooooooooooo..",
    "................",
]

DETAILS = {
    "oil": OIL, "debris": DEBRIS, "papers": PAPERS, "cable": CABLE, "floor_strip": FLOOR_STRIP,
    "puddle_green": PUDDLE_GREEN, "puddle_pink": PUDDLE_PINK,
}


def draw(grid: list[str]) -> Image.Image:
    width = len(grid[0])
    assert all(len(row) == width for row in grid), "every row of a sprite must have the same length"
    image = Image.new("RGBA", (width, len(grid)))
    for y, row in enumerate(grid):
        for x, char in enumerate(row):
            image.putpixel((x, y), PALETTE[char])
    return image


def main() -> None:
    GAME_DIR.mkdir(parents=True, exist_ok=True)
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
        "smoke_bomb": SMOKE_BOMB,
    }
    for name, grid in sprites.items():
        draw(grid).save(GAME_DIR / f"{name}.png")
    details_dir = GAME_DIR / "rooms" / "details"
    details_dir.mkdir(parents=True, exist_ok=True)
    for name, grid in DETAILS.items():
        draw(grid).save(details_dir / f"{name}.png")
    props_dir = GAME_DIR / "rooms" / "props"
    props_dir.mkdir(parents=True, exist_ok=True)
    draw(PYLON).save(props_dir / "pylon.png")
    print(f"{len(sprites)} sprites, {len(DETAILS)} floor details and the pylon written to {GAME_DIR}")


if __name__ == "__main__":
    main()
