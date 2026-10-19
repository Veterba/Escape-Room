## Part A test room: builds walls and floor from a text layout, places the player and the HUD.
class_name TestRoom
extends Node2D

const TILE_SIZE := 16
const SOURCE_ID := 0
## Atlas coordinates of the tiles in art/game/tiles.png.
const FLOOR_TILES: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
## How often each floor tile is picked: mostly plain, some cracks and casings.
const FLOOR_WEIGHTS: Array[float] = [8.0, 1.0, 1.0]
const WALL_TOP := Vector2i(3, 0)
const WALL_FACE := Vector2i(4, 0)

## '#' is a wall, '.' is floor, 'P' is floor where the player starts.
const LAYOUT: Array[String] = [
	"################################################",
	"################################################",
	"#..............................................#",
	"#..............................................#",
	"#..............................................#",
	"#.....##..............................##.......#",
	"#.....##..............................##.......#",
	"#..............................................#",
	"#..............................................#",
	"#....................########..................#",
	"#....................########..................#",
	"#..........................##..................#",
	"#..........................##..................#",
	"#..............................................#",
	"#..............................................#",
	"#.....##.......................................#",
	"#.....##.......................................#",
	"#..............................................#",
	"#......................P.......................#",
	"#..............................................#",
	"#..............................................#",
	"#.........##.........................##........#",
	"#.........##.........................##........#",
	"#..............................................#",
	"#..............................................#",
	"#..............................................#",
	"################################################",
]

@onready var _tiles: TileMapLayer = $Tiles
@onready var _player: Player = $Player
@onready var _hud: Hud = $HUD


func _ready() -> void:
	_build_tiles()
	var room_size := Vector2i(LAYOUT[0].length(), LAYOUT.size()) * TILE_SIZE
	_player.camera.set_bounds(Rect2i(Vector2i.ZERO, room_size))
	_hud.bind(_player)


func _build_tiles() -> void:
	var rng := RandomNumberGenerator.new()
	for y in LAYOUT.size():
		for x in LAYOUT[y].length():
			var cell := Vector2i(x, y)
			match LAYOUT[y][x]:
				"#":
					_tiles.set_cell(cell, SOURCE_ID, _wall_tile_at(x, y))
				"P":
					_player.position = _tiles.map_to_local(cell)
					_tiles.set_cell(cell, SOURCE_ID, FLOOR_TILES[0])
				_:
					_tiles.set_cell(cell, SOURCE_ID, FLOOR_TILES[rng.rand_weighted(FLOOR_WEIGHTS)])


## A wall with floor right below it shows its front face; any other wall shows its top.
func _wall_tile_at(x: int, y: int) -> Vector2i:
	var is_last_row := y + 1 >= LAYOUT.size()
	if not is_last_row and LAYOUT[y + 1][x] != "#":
		return WALL_FACE
	return WALL_TOP
