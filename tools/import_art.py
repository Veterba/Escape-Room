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
    "03": ("enemy_grunt_kin", 22),
    "05": ("enemy_fuse_kin", 22),
}

# Guns and items: source file prefix -> output name.
NATIVE_ART = {
    "14": "item_rusty_knife",
    "15": "item_secret_code",
    "16": "item_heart",
    "17": "item_ammo_box",
    "20": "item_hourglass",
    "21": "item_exit_key",
}

# Items lying on the floor use a half-size copy, so they stay small next to the 24 px hero.
# The full-size drawings are still used in the HUD.
FLOOR_ITEMS = ["item_heart", "item_ammo_box", "item_hourglass"]
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
# The guns as held in the hand, 1 px = 1 game pixel (their grip and muzzle points are in
# balance.tres).
HELD_GUNS = ["pop_pistol", "brass_revolver", "scattershot", "fuse_launcher", "gold_detonator"]
HELD_GUN_DIR = "retexture/42_guns"
# The secret code item: a key.
KEY_SOURCE = "retexture/41_key.png"
KEY_OUTPUT = "key.png"
# The chests: still pictures and horizontal strips of equal frames, copied as they are into
# art/game/chests/. The two opening strips also show the item rising out (a revolver, the key);
# in the game the chest's own gun or key rises instead, so those pixels are taken out (see
# open_chest_frame below).
CHEST_DIR = "retexture/40_chests"
CHEST_OUTPUT_DIR = "chests"
CHESTS = ["gun_chest_locked", "gun_chest_ready", "gun_chest_open",
          "code_chest_chained", "code_chest_unchain", "code_chest_open"]
# Opening strips: (file, frame size, first frame with the item in it). Frame i shows the chest
# at k = i / (frames - 1) of its opening.
OPEN_STRIPS = [("gun_chest_open", 30, 4), ("code_chest_open", 34, 3)]
OUTLINE = (0x07, 0x06, 0x0D, 255)

# The approved enemies, one row each, in 32x32 cells with their feet on the cell's bottom edge.
# Columns: move 1-4, warning 1-2, hit (white), dying; the Glitch has three more: twitch and two
# teleport frames. Output: art/game/enemies/<name>_<column>.png.
ENEMY_SHEET = "retexture/37_enemies_sheet.png"
ENEMY_DIR = "enemies"
ENEMY_CELL = 32
ENEMY_ROWS = [("watcher", 8), ("ram", 8), ("glitch", 11), ("trojan", 8)]

# Art from the retexture references lives in art/source/retexture/, under its own numbers.
# The password menu's TV as a character grid (columns x rows). The source file has the trailing
# spaces of each row cut off, so every row is padded back to the full width.
MENU_TV_SOURCE = "retexture/15_menu_tv_ascii.txt"
MENU_TV_OUTPUT = "menu_tv.txt"
MENU_TV_SIZE = (89, 68)

# Root, the boss (retexture spec, "Approved boss: Root"): its windows, the cursor, and red-titled
# copies of the windows for phase 3. The eye is drawn by the game, so the main window's eye is
# cleared.
ROOT_PARTS_DIR = "retexture/44_boss_root"
ROOT_DIR = "root"
ROOT_WINDOWS = 5
ROOT_EYE_AREA = (2, 5, 35, 27)  # left, top, right, bottom (exclusive), inside the main window
ROOT_WINDOW_BACK = "#0d1822"
# Title bar colours (and their lighter top row) -> the red of phase 3.
ROOT_TITLE_ROWS = range(1, 4)
ROOT_TITLES = {"#b62649": "#ff5873", "#c4516d": "#ff798f", "#27a3a3": "#ff5873", "#52b5b5": "#ff798f"}

# Rooms (retexture spec, "Rooms"): every room type gets one tile atlas of 16 px cells.
# Room type -> (floor style, wall style) of the parts in 38_room_parts.
ROOM_PARTS_DIR = "retexture/38_room_parts"
ROOMS_DIR = "rooms"
ROOM_STYLES = {
    "control": ("plate", "violet"), "server": ("server", "blue"), "lab": ("lab", "lab"),
    "storage": ("storage", "rust"), "maze": ("dark", "dark"), "arena": ("arena", "arena"),
}
# The atlas, 11 cells wide:
#   row 0: the 8 floor variants, the grate, the hazard stripes, an empty cell (an invisible
#          blocker under room objects)
#   row 1: the 11 wall tops: plain, then a light edge on n, s, e, w, ns, ew, nw, ne, sw, se
#   row 2: the 2 short wall faces (inner walls and pillars)
#   rows 3-5: the 6 north wall faces with a wall top above (16x48 each), then the top corners
#          of the room: a plain top over two tops with an edge towards the wall face (east,
#          then west)
ROOM_ATLAS_CELLS = (11, 6)
TILE = 16
WALL_TOP_PLAIN, WALL_TOP_S, WALL_TOP_E, WALL_TOP_W = 0, 2, 3, 4
# The pipe along the north wall (as on the approved page; the maze has none): its rows, from
# 4 px below the top of the wall face.
WALL_PIPE = [(0, "#5a6080"), (1, "#3a3e55"), (2, "#3a3e55"), (3, "#202235")]
WALL_PIPE_TOP = 4
NO_PIPE = ["maze"]
# The tile set that both floors and the Labyrinth use: one atlas source per room type, in the order
# of ROOM_STYLES (sources 1-6).
TILESET = ROOT / "scenes" / "maps" / "dungeon_tiles.tres"
TILESET_UID = "uid://ckqprfhxgw3bx"
# Walls are drawn in y order by the top edge of their cell, and block movement on their cell only
# (a tall north wall face reaches up over the dark above the room).
WALL_SORT = -8
TALL_ORIGIN = 16
SQUARE = "PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)"
# Room objects copied as they are: horizontal strips of equal frames (the frame counts are in
# scripts/floor/room_styles.gd).
ROOM_PROPS = [
    "arm", "barrel", "beacon", "bin", "box", "cables", "chair", "console", "cooler", "crate",
    "crateM", "cryo", "desk", "extinguisher", "fusebox", "generator", "island", "lamp", "lockers",
    "monitor", "rack", "shelf", "sign", "strip_light", "tank", "tankP", "terminal", "toolbox",
    "tube", "tvpile", "valves", "vent",
]

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


def convert_enemies() -> None:
    sheet = Image.open(SOURCE_DIR / ENEMY_SHEET).convert("RGBA")
    out_dir = GAME_DIR / ENEMY_DIR
    out_dir.mkdir(exist_ok=True)
    for row, (name, count) in enumerate(ENEMY_ROWS):
        for i in range(count):
            box = (i * ENEMY_CELL, row * ENEMY_CELL, (i + 1) * ENEMY_CELL, (row + 1) * ENEMY_CELL)
            sheet.crop(box).save(out_dir / f"{name}_{i}.png")
    print(f"{ENEMY_DIR}/  {sum(count for _, count in ENEMY_ROWS)} frames")


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


def _hex(color: str, alpha: int = 255) -> tuple:
    return (int(color[1:3], 16), int(color[3:5], 16), int(color[5:7], 16), alpha)


def open_chest_frame(name: str, k: float) -> Image.Image:
    """An opening chest at k (0..1) without the item rising out of it, drawn the way the approved
    page "Escape Boom Station" draws it (rectangles, then a 1 px outline around everything)."""
    size = 30 if name == "gun_chest_open" else 34
    image = Image.new("RGBA", (size, size))
    def rect(x, y, w, h, color):
        for yy in range(max(y, 0), min(y + h, size)):
            for xx in range(max(x, 0), min(x + w, size)):
                image.putpixel((xx, yy), color)
    lift = round(min(1, k * 1.6) * 6)
    if name == "gun_chest_open":
        oy = 10
        if k > .25:
            rect(3, oy + 6 - lift, 24, lift + 2, _hex("#74f2e0", round(min(1, (k - .25) * 2) * .55 * 255)))
        for x, y, w, h, c in [(1, oy + 7, 28, 12, "#26283c"), (1, oy + 7, 28, 1, "#3a3e58"), (2, oy + 9, 26, 8, "#2c2f46"),
                              (1, oy + 17, 28, 2, "#191a26"), (0, oy + 10, 2, 4, "#585e72"), (28, oy + 10, 2, 4, "#363a4a"),
                              (3, oy + 19, 4, 1, "#14151f"), (23, oy + 19, 4, 1, "#14151f")]:
            rect(x, y, w, h, _hex(c))
        for x, y in [(3, oy + 9), (26, oy + 9), (3, oy + 15), (26, oy + 15)]:
            rect(x, y, 1, 1, _hex("#585e72"))
        ly = oy - lift
        for x, y, w, h, c in [(1, ly, 28, 7, "#3a3e58"), (1, ly, 28, 1, "#6a7090"), (1, ly + 5, 28, 2, "#2b2e45"),
                              (6, ly + 2, 18, 2, "#30344c"), (2, ly + 6, 26, 1, "#74f2e0"),
                              (11, oy + 9, 8, 7, "#14151f"), (11, oy + 9, 8, 1, "#0b0b12")]:
            rect(x, y, w, h, _hex(c))
        for x, y in [(12, oy + 12), (13, oy + 13), (14, oy + 14), (15, oy + 13), (16, oy + 12), (17, oy + 11)]:
            rect(x, y, 1, 1, _hex("#68d57e"))
    else:
        oy = 12
        if k > .2:
            rect(4, oy + 6 - lift, 26, lift + 2, _hex("#ffd166", round(min(1, (k - .2) * 2) * .6 * 255)))
        ly = oy - lift
        for x, y, w, h, c in [(2, oy + 7, 30, 13, "#2b2638"), (2, oy + 7, 30, 1, "#4a4260"), (3, oy + 9, 28, 9, "#332d44"),
                              (2, oy + 18, 30, 2, "#18151f"), (2, oy + 7, 2, 13, "#cd7e1f"), (30, oy + 7, 2, 13, "#6c3912"),
                              (2, oy + 18, 30, 1, "#6c3912"), (2, ly, 30, 8, "#3d3650"), (2, ly, 30, 1, "#6a6088"),
                              (2, ly + 6, 30, 2, "#cd7e1f"), (2, ly + 6, 30, 1, "#ffd166"), (14, oy + 9, 6, 7, "#cd7e1f"),
                              (15, oy + 10, 4, 5, "#ffd166"), (16, oy + 11, 2, 2, "#3a1f0a"), (16, oy + 13, 2, 2, "#3a1f0a")]:
            rect(x, y, w, h, _hex(c))
    filled = {(x, y) for y in range(size) for x in range(size) if image.getpixel((x, y))[3] > 0}
    for y in range(size):
        for x in range(size):
            if (x, y) not in filled and any(n in filled for n in [(x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)]):
                image.putpixel((x, y), OUTLINE)
    return image


def _close(a: tuple, b: tuple) -> bool:
    return (a[3] == 0 and b[3] == 0) or all(abs(p - q) <= 3 for p, q in zip(a, b))


def convert_chests() -> None:
    out_dir = GAME_DIR / CHEST_OUTPUT_DIR
    out_dir.mkdir(exist_ok=True)
    for name in CHESTS:
        image = Image.open(SOURCE_DIR / CHEST_DIR / f"{name}.png").convert("RGBA")
        for strip, size, first_item_frame in OPEN_STRIPS:
            if name != strip:
                continue
            frames = image.width // size
            for i in range(first_item_frame, frames):
                clean = open_chest_frame(name, i / (frames - 1))
                for y in range(size):
                    for x in range(size):
                        pixel = image.getpixel((i * size + x, y))
                        if not _close(pixel, clean.getpixel((x, y))):
                            image.putpixel((i * size + x, y), clean.getpixel((x, y)))
        image.save(out_dir / f"{name}.png")
    print(f"{CHEST_OUTPUT_DIR}/  {len(CHESTS)} chest pictures and strips")


def _part(name: str) -> Image.Image:
    return Image.open(SOURCE_DIR / ROOM_PARTS_DIR / f"{name}.png").convert("RGBA")


def _cell(strip: Image.Image, i: int, height: int = TILE) -> Image.Image:
    return strip.crop((i * TILE, 0, (i + 1) * TILE, height))


def convert_rooms() -> None:
    out_dir = GAME_DIR / ROOMS_DIR
    (out_dir / "props").mkdir(parents=True, exist_ok=True)
    for room, (floor, wall) in ROOM_STYLES.items():
        atlas = Image.new("RGBA", (ROOM_ATLAS_CELLS[0] * TILE, ROOM_ATLAS_CELLS[1] * TILE))
        floors = _part(f"floor_{floor}")
        for i in range(8):
            atlas.paste(_cell(floors, i), (i * TILE, 0))
        atlas.paste(_part("floor_grate"), (8 * TILE, 0))
        atlas.paste(_part("floor_hazard"), (9 * TILE, 0))
        tops = _part(f"wall_top_{wall}")
        atlas.paste(tops, (0, TILE))
        atlas.paste(_part(f"wall_short_{wall}"), (0, 2 * TILE))
        faces = _part(f"wall_{wall}")
        for i in range(6):
            face = _cell(faces, i, 2 * TILE)
            if room not in NO_PIPE:
                for dy, color in WALL_PIPE:
                    for x in range(TILE):
                        face.putpixel((x, WALL_PIPE_TOP + dy), _hex(color))
            atlas.paste(_cell(tops, WALL_TOP_S), (i * TILE, 3 * TILE))
            atlas.paste(face, (i * TILE, 4 * TILE))
        for i, edge in [(6, WALL_TOP_E), (7, WALL_TOP_W)]:
            atlas.paste(_cell(tops, WALL_TOP_PLAIN), (i * TILE, 3 * TILE))
            atlas.paste(_cell(tops, edge), (i * TILE, 4 * TILE))
            atlas.paste(_cell(tops, edge), (i * TILE, 5 * TILE))
        atlas.save(out_dir / f"tiles_{room}.png")
    for name in ROOM_PROPS:
        _part(name).save(out_dir / "props" / f"{name}.png")
    print(f"{ROOMS_DIR}/  {len(ROOM_STYLES)} tile atlases, {len(ROOM_PROPS)} objects")


def _tile(lines: list, x: int, y: int, solid: bool, tall: bool = False) -> None:
    if tall:
        lines.append(f"{x}:{y}/size_in_atlas = Vector2i(1, 3)")
    lines.append(f"{x}:{y}/0 = 0")
    if tall:
        lines.append(f"{x}:{y}/0/texture_origin = Vector2i(0, {TALL_ORIGIN})")
    if solid:
        lines.append(f"{x}:{y}/0/y_sort_origin = {WALL_SORT}")
        lines.append(f"{x}:{y}/0/physics_layer_0/polygon_0/points = {SQUARE}")


def write_tileset() -> None:
    styles = list(ROOM_STYLES)
    out = [f'[gd_resource type="TileSet" format=3 uid="{TILESET_UID}"]', ""]
    for i, room in enumerate(styles, 1):
        out.append(f'[ext_resource type="Texture2D" path="res://art/game/{ROOMS_DIR}/tiles_{room}.png" id="{i}_tiles"]')
    out.append("")
    for i, room in enumerate(styles, 1):
        out += [f'[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_{i}"]', f'texture = ExtResource("{i}_tiles")']
        for x in range(11):
            _tile(out, x, 0, x == 10)
            _tile(out, x, 1, True)
        for x in range(2):
            _tile(out, x, 2, True)
        for x in range(8):
            _tile(out, x, 3, True, tall=True)
        out.append("")
    out += ["[resource]", "physics_layer_0/collision_layer = 1", "physics_layer_0/collision_mask = 0"]
    for i in range(1, len(styles) + 1):
        out.append(f'sources/{i} = SubResource("TileSetAtlasSource_{i}")')
    TILESET.write_text("\n".join(out) + "\n")
    print(f"{TILESET.name}  {len(styles)} tile sources")


def _root_part(name: str) -> Image.Image:
    return Image.open(SOURCE_DIR / ROOT_PARTS_DIR / f"{name}.png").convert("RGBA")


def _red_title(image: Image.Image) -> Image.Image:
    red = image.copy()
    swaps = {_hex(old): _hex(new) for old, new in ROOT_TITLES.items()}
    for y in ROOT_TITLE_ROWS:
        for x in range(red.width):
            red.putpixel((x, y), swaps.get(red.getpixel((x, y)), red.getpixel((x, y))))
    return red


def convert_root() -> None:
    out_dir = GAME_DIR / ROOT_DIR
    out_dir.mkdir(exist_ok=True)
    main = _root_part("main_window_eye").crop((0, 0, 38, 30))
    left, top, right, bottom = ROOT_EYE_AREA
    for y in range(top, bottom):
        for x in range(left, right):
            main.putpixel((x, y), _hex(ROOT_WINDOW_BACK))
    main.save(out_dir / "main.png")
    _red_title(main).save(out_dir / "main_red.png")
    for i in range(1, ROOT_WINDOWS + 1):
        window = _root_part(f"window_{i}")
        window.save(out_dir / f"window_{i}.png")
        _red_title(window).save(out_dir / f"window_{i}_red.png")
        _root_part(f"window_{i}_phase3").save(out_dir / f"window_{i}_static.png")
    _root_part("cursor").save(out_dir / "cursor.png")
    print(f"{ROOT_DIR}/  the main window, {ROOT_WINDOWS} error windows and the cursor")


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
    convert_enemies()
    for gun in HELD_GUNS:
        Image.open(SOURCE_DIR / HELD_GUN_DIR / f"{gun}.png").convert("RGBA").save(GAME_DIR / f"held_{gun}.png")
    print(f"held_*.png  {len(HELD_GUNS)} guns")
    Image.open(SOURCE_DIR / KEY_SOURCE).convert("RGBA").save(GAME_DIR / KEY_OUTPUT)
    convert_chests()
    convert_rooms()
    write_tileset()
    convert_root()


if __name__ == "__main__":
    main()
