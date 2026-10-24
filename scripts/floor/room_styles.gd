## How each room type looks (retexture spec, "Rooms"): its tiles, the objects along its north
## wall and on it, what stands where its layout has crates, and the small details on its floor.
## The pictures are in art/game/rooms/ (made by tools/import_art.py and tools/draw_art.py); the
## lights are in config/lighting.tres.
class_name RoomStyles

## Fight, chest, start and exit rooms pick one of these at random.
const ROOM_TYPES: Array[StringName] = [&"control", &"server", &"lab", &"storage"]
## The tile source of each room type in scenes/maps/dungeon_tiles.tres. The Boss Chamber is built
## from the arena's tiles.
const TILE_SOURCES := {&"control": 1, &"server": 2, &"lab": 3, &"storage": 4, &"maze": 5, &"arena": 6, &"boss": 6}

## Where the tiles are in each room type's atlas (see tools/import_art.py).
const FLOOR_VARIANTS := 8
const GRATE := Vector2i(8, 0)
const HAZARD := Vector2i(9, 0)
## An empty tile that only blocks movement: under room objects that stand where a crate was.
const BLOCKER := Vector2i(10, 0)
## Wall tops, by which sides have a light edge (the sides next to the floor).
const WALL_TOPS := {
	"": Vector2i(0, 1), "n": Vector2i(1, 1), "s": Vector2i(2, 1), "e": Vector2i(3, 1), "w": Vector2i(4, 1),
	"ns": Vector2i(5, 1), "ew": Vector2i(6, 1), "nw": Vector2i(7, 1), "ne": Vector2i(8, 1),
	"sw": Vector2i(9, 1), "se": Vector2i(10, 1),
}
## Short faces of inner walls and pillars (2 variants), the north wall's tall faces under a wall
## top (6 variants, 3 tiles high), and the room's top corners next to a tall face.
const SHORT_FACES := [Vector2i(0, 2), Vector2i(1, 2)]
const TALL_FACES := [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3)]
const CORNER_FACE_EAST := Vector2i(6, 3)
const CORNER_FACE_WEST := Vector2i(7, 3)

## Room objects: frames in the picture strip, and frames per second when it has more than one.
const PROPS := {
	&"arm": [8, 2.0], &"barrel": [1, 0.0], &"beacon": [8, 3.0], &"bin": [1, 0.0], &"box": [1, 0.0],
	&"cables": [1, 0.0], &"chair": [1, 0.0], &"console": [8, 8.0], &"cooler": [1, 0.0],
	&"crate": [1, 0.0], &"crateM": [1, 0.0], &"cryo": [2, 2.0], &"desk": [2, 2.0],
	&"extinguisher": [1, 0.0], &"fusebox": [2, 2.0], &"generator": [8, 12.0], &"island": [4, 6.0],
	&"lamp": [1, 0.0], &"lockers": [1, 0.0], &"monitor": [4, 12.0], &"rack": [4, 4.0],
	&"shelf": [1, 0.0], &"sign": [1, 0.0], &"strip_light": [1, 0.0], &"tank": [8, 6.0],
	&"tankP": [8, 6.0], &"terminal": [2, 2.0], &"toolbox": [1, 0.0], &"tube": [1, 0.0],
	&"tvpile": [4, 8.0], &"valves": [1, 0.0], &"vent": [1, 0.0], &"pylon": [1, 0.0],
}
## Objects that glow, and which light of config/lighting.tres they carry.
const GLOWING := {&"tank": &"tank", &"tankP": &"tank_pink", &"console": &"console", &"monitor": &"monitor", &"cryo": &"cryo"}
## Objects hung on the north wall: pixels from the top of the wall face down to the object's top
## (as on the approved page).
const ON_WALL_HEIGHT := {
	&"lamp": 10, &"tube": 8, &"strip_light": 26, &"beacon": 10, &"fusebox": 12, &"vent": 16,
	&"terminal": 10, &"sign": 12, &"valves": 2, &"cables": 8, &"extinguisher": 14, &"monitor": 6,
}
## Objects that stand against the north wall sink this many pixels into the floor in front of it.
const WALL_STAND_SINK := 3

## What each room type puts where:
## - wall_light: the light on its north wall, one every LAMP_SPACING tiles
## - broken_light: the object of its broken lights (tinted with the light's colour), and how many
## - wall_middle: an object hung in the middle of the north wall (or nothing)
## - along_wall: objects standing against the north wall
## - on_wall: small objects hung on the north wall
## - cover: what stands where the layout has a group of crates, by the group's size in tiles.
##   Each choice is a row of objects spread across the bottom of the group (a group one tile wide
##   gets its object on every tile); &"pillar" turns the crates into an inner wall instead.
##   A size not listed gets one small object per tile.
## - small: single objects for crates on their own
## - details: flat details lying on the floor
const LOOKS := {
	&"control": {
		"wall_light": &"lamp", "broken_light": &"tube", "broken_lights": 1, "wall_middle": &"",
		"along_wall": [&"console", &"rack", &"monitor", &"lockers", &"tank", &"terminal"],
		"on_wall": [&"fusebox", &"vent", &"sign", &"cables"],
		"cover": {
			Vector2i(2, 2): [[&"rack", &"rack"], [&"lockers"], [&"tvpile"], [&"tank", &"tank"]],
			Vector2i(3, 1): [[&"island"]],
			Vector2i(1, 3): [[&"rack"]],
		},
		"small": [&"crate", &"crateM", &"box", &"bin"],
		"details": [&"oil", &"debris", &"debris", &"cable", &"floor_strip", &"papers"],
	},
	&"server": {
		"wall_light": &"strip_light", "broken_light": &"strip_light", "broken_lights": 1, "wall_middle": &"",
		"along_wall": [&"rack", &"rack", &"rack", &"monitor", &"cooler"],
		"on_wall": [&"fusebox", &"cables", &"vent"],
		"cover": {
			Vector2i(2, 2): [[&"rack", &"rack"]],
			Vector2i(3, 1): [[&"rack", &"rack", &"rack"]],
			Vector2i(1, 3): [[&"rack"]],
		},
		"small": [&"crateM", &"bin", &"box"],
		"details": [&"cable", &"cable", &"floor_strip", &"debris", &"oil"],
	},
	&"lab": {
		"wall_light": &"lamp", "broken_light": &"tube", "broken_lights": 1, "wall_middle": &"",
		"along_wall": [&"tank", &"tank", &"tankP", &"console", &"generator", &"cooler"],
		"on_wall": [&"valves", &"extinguisher", &"terminal", &"vent"],
		"cover": {
			Vector2i(2, 2): [[&"tank", &"tankP"], [&"generator"], [&"arm"], [&"desk"]],
			Vector2i(3, 1): [[&"island"], [&"cryo"]],
			Vector2i(1, 3): [[&"tank"]],
		},
		"small": [&"crateM", &"bin", &"cooler", &"chair"],
		"details": [&"puddle_green", &"puddle_green", &"puddle_pink", &"debris", &"oil"],
	},
	&"storage": {
		"wall_light": &"lamp", "broken_light": &"tube", "broken_lights": 1, "wall_middle": &"",
		"along_wall": [&"shelf", &"shelf", &"lockers", &"crate"],
		"on_wall": [&"sign", &"extinguisher", &"vent", &"fusebox"],
		"cover": {
			Vector2i(2, 2): [[&"shelf"], [&"crate", &"crateM"], [&"lockers"], [&"tvpile"]],
			Vector2i(3, 1): [[&"crate", &"crateM", &"crate"], [&"box", &"crate", &"box"]],
			Vector2i(1, 3): [[&"crate"]],
		},
		"small": [&"crate", &"crateM", &"box", &"toolbox"],
		"details": [&"oil", &"debris", &"debris", &"papers"],
	},
	&"maze": {
		"wall_light": &"beacon", "broken_light": &"", "broken_lights": 0, "wall_middle": &"",
		"along_wall": [],
		"on_wall": [&"vent", &"cables"],
		"cover": {},
		"small": [&"crate"],
		"details": [&"debris", &"oil", &"debris"],
	},
	&"arena": {
		"wall_light": &"lamp", "broken_light": &"", "broken_lights": 0, "wall_middle": &"beacon",
		"along_wall": [&"crateM", &"crate", &"tvpile"],
		"on_wall": [&"sign", &"vent", &"sign"],
		"cover": {
			Vector2i(2, 2): [[&"pillar"]],
			Vector2i(2, 1): [[&"pillar"]],
			Vector2i(3, 1): [[&"crate", &"crateM", &"crate"]],
			Vector2i(1, 3): [[&"crate"]],
		},
		"small": [&"crate", &"crateM"],
		"details": [&"floor_strip", &"debris", &"oil"],
	},
	&"boss": {
		"wall_light": &"lamp", "broken_light": &"tube", "broken_lights": 2, "wall_middle": &"monitor",
		"along_wall": [],
		"on_wall": [&"vent", &"sign"],
		"cover": {},
		"small": [&"crate"],
		"details": [&"floor_strip", &"debris", &"oil"],
	},
}
## One wall light every this many tiles of north wall.
const LAMP_SPACING := 10
## Along the north wall, the chance that a free tile starts a standing object or gets a small
## object hung on it (otherwise it stays bare).
const ALONG_WALL_CHANCE := 0.45
const ON_WALL_CHANCE := 0.25
## The Boss Chamber: a ring of hazard stripes around its middle (its radius in tiles, how thick,
## and how much it is squashed from top to bottom), a grate in the middle, and a pylon one tile
## in from each corner.
const BOSS_RING_RADIUS := 4.2
const BOSS_RING_WIDTH := 0.6
const BOSS_RING_SQUASH := 1.3
const BOSS_GRATE_RADIUS := 1.3
const BOSS_PYLON_INSET := 2
## Floor details: one for every this many floor tiles, and grates.
const TILES_PER_DETAIL := 24
const TILES_PER_GRATE := 70


## The picture of a room object or floor detail.
static func texture(prop: StringName) -> Texture2D:
	if PROPS.has(prop):
		return load("res://art/game/rooms/props/%s.png" % prop)
	return load("res://art/game/rooms/details/%s.png" % prop)


## The wall top with light edges on `edges` (some of "n", "s", "e", "w", in that order). A wall
## can show at most two edges; with three or four it keeps east and west, or else north and south.
static func wall_top(edges: String) -> Vector2i:
	if edges.length() > 2:
		edges = "ew" if edges.contains("e") and edges.contains("w") else "ns"
	return WALL_TOPS[edges]
