## A map built from a text layout: walls, floor, the player's start, and what stands where.
## After building, it bakes the navigation mesh that enemies use to walk around walls.
## Walls, characters and chests are y-sorted: whatever stands lower on screen is drawn in front.
##
## Layout legend: '#' wall, 'x' crate (a wall that looks like a crate), '.' floor,
## 'P' player start, 'C' secret code, 'K' a spot for the code chest (one of them is picked at
## random), 'G' gun chest, 'H' hourglass, 'b' red barrel, 'g' Grunt Kin, 'f' Fuse Kin,
## 's' Shade Kin, 'w' Wing Kin, 'D' door, 'E' the exit, ' ' nothing at all (the dark outside
## the rooms).
## Every letter but '#', 'x' and ' ' stands on floor.
##
## Rooms of a room type (RoomStyles) get that type's tiles: random floor variants, a tall wall face
## on the north wall, wall tops elsewhere and short faces on inner walls. Crates become room
## objects of matching size standing on invisible blocking tiles, or pillars. Without a room type
## a cell keeps the old tiles (the Boss Chamber).
class_name GameMap
extends Node2D

const TILE_SIZE := 16
const SOURCE_ID := 0
## Atlas coordinates of the tiles in art/game/tiles.png.
const FLOOR_TILES: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(4, 0)]
## How often each floor tile is picked: mostly plain, some cracked, some chipped.
const FLOOR_WEIGHTS: Array[float] = [8.0, 1.0, 1.0]
const WALL_TOP := Vector2i(2, 0)
const WALL_FACE := Vector2i(3, 0)
const CRATE_TILE := Vector2i(5, 0)
## The sides of a cell, in the order wall tops name their edges.
const SIDES := {"n": Vector2i.UP, "s": Vector2i.DOWN, "e": Vector2i.RIGHT, "w": Vector2i.LEFT}
const WALL := "#"
const CRATE := "x"
const FLOOR := "."
const VOID := " "
const PLAYER_START := "P"
const CODE_CHEST_SPOT := "K"
const CODE_CHEST := preload("res://scenes/world/code_chest.tscn")
## What each letter in the layout places on the map.
const ENTITIES := {
	"C": preload("res://scenes/world/code_pickup.tscn"),
	"G": preload("res://scenes/world/gun_chest.tscn"),
	"H": preload("res://scenes/world/hourglass_pickup.tscn"),
	"b": preload("res://scenes/world/barrel.tscn"),
	"D": preload("res://scenes/floor/door.tscn"),
	"E": preload("res://scenes/world/exit_pickup.tscn"),
	"g": preload("res://scenes/enemies/grunt_kin.tscn"),
	"f": preload("res://scenes/enemies/fuse_kin.tscn"),
	"s": preload("res://scenes/enemies/shade_kin.tscn"),
	"w": preload("res://scenes/enemies/wing_kin.tscn"),
}

@export var map_id: StringName
## The room type whose tiles and objects the whole map uses (see RoomStyles), or empty for the
## old tiles. DungeonFloor picks one per room instead.
@export var room_type: StringName
## One string per row of tiles, using the legend above.
@export var layout: PackedStringArray

## Where the player starts, in pixels.
var spawn_position := Vector2.ZERO
## The whole map in pixels, used to keep the camera inside.
var bounds := Rect2i()
## Cells with plain floor and nothing on them (where arena enemies may appear).
var free_floor_cells: Array[Vector2i] = []

@onready var _navigation: NavigationRegion2D = $Navigation
@onready var _floor: TileMapLayer = $Navigation/Floor
@onready var _walls: TileMapLayer = $Navigation/Walls


func _ready() -> void:
	bounds = Rect2i(Vector2i.ZERO, Vector2i(layout[0].length(), layout.size()) * TILE_SIZE)
	_build()
	_bake_navigation()


func _build() -> void:
	var rng := RandomNumberGenerator.new()
	var crates := _crate_covers(rng)
	var code_chest_spots: Array[Vector2] = []
	for y in layout.size():
		for x in layout[y].length():
			var cell := Vector2i(x, y)
			var symbol := layout[y][x]
			var type := _room_type_at(cell)
			if symbol == VOID:
				continue
			if type.is_empty():
				if symbol == WALL:
					_walls.set_cell(cell, SOURCE_ID, _wall_tile_at(x, y))
					continue
				if symbol == CRATE:
					_walls.set_cell(cell, SOURCE_ID, CRATE_TILE)
					continue
				_floor.set_cell(cell, SOURCE_ID, FLOOR_TILES[rng.rand_weighted(FLOOR_WEIGHTS)])
			else:
				var source: int = RoomStyles.TILE_SOURCES[type]
				if symbol == WALL:
					_walls.set_cell(cell, source, _room_wall_tile(cell))
					continue
				_floor.set_cell(cell, source, Vector2i(rng.randi_range(0, RoomStyles.FLOOR_VARIANTS - 1), 0))
				if symbol == CRATE:
					_walls.set_cell(cell, source, RoomStyles.BLOCKER)
					continue
			var center := _floor.map_to_local(cell)
			if symbol == FLOOR:
				free_floor_cells.append(cell)
			elif symbol == PLAYER_START:
				spawn_position = center
			elif symbol == CODE_CHEST_SPOT:
				code_chest_spots.append(center)
			elif ENTITIES.has(symbol):
				var entity: Node2D = ENTITIES[symbol].instantiate()
				entity.position = center
				add_child(entity)
	if not code_chest_spots.is_empty():
		var chest: Node2D = CODE_CHEST.instantiate()
		chest.position = code_chest_spots.pick_random()
		add_child(chest)
	for group: Rect2i in crates:
		_cover(group, crates[group], rng)


## The centre of `cell` in pixels.
func cell_center(cell: Vector2i) -> Vector2:
	return _floor.map_to_local(cell)


## The layout letter at `cell`; outside the map it is nothing (VOID).
func symbol_at(cell: Vector2i) -> String:
	if cell.y < 0 or cell.y >= layout.size() or cell.x < 0 or cell.x >= layout[cell.y].length():
		return VOID
	return layout[cell.y][cell.x]


## Swaps the floor tile at `cell` for another tile of its room type's atlas (a grate, hazard
## stripes).
func set_floor_tile(cell: Vector2i, atlas_coords: Vector2i) -> void:
	_floor.set_cell(cell, RoomStyles.TILE_SOURCES[_room_type_at(cell)], atlas_coords)


## Adds a room object standing at `base` (pixels), with its light if it glows.
func add_prop(prop: StringName, base: Vector2) -> RoomProp:
	var sprite := RoomProp.make(prop, base)
	add_child(sprite)
	if RoomStyles.GLOWING.has(prop):
		var spec: LightSpec = Config.lighting.get(RoomStyles.GLOWING[prop])
		add_child(RoomLight.make(spec, base + sprite.offset))
	return sprite


## The room type of the room `cell` belongs to (empty for the old tiles).
func _room_type_at(_cell: Vector2i) -> StringName:
	return room_type


## Groups the layout's crates into blocks and picks what each block becomes (RoomStyles.LOOKS
## "cover"): a list of objects, or a pillar. Pillars are turned into walls in the layout right
## away, so they are built as walls. Returns the other blocks with their objects.
func _crate_covers(rng: RandomNumberGenerator) -> Dictionary:
	var covers := {}
	var seen := {}
	for y in layout.size():
		for x in layout[y].length():
			var start := Vector2i(x, y)
			var type := _room_type_at(start)
			if layout[y][x] != CRATE or seen.has(start) or type.is_empty():
				continue
			var group := Rect2i(start, Vector2i.ONE)
			var todo: Array[Vector2i] = [start]
			seen[start] = true
			while not todo.is_empty():
				var cell: Vector2i = todo.pop_back()
				group = group.expand(cell + Vector2i.ONE)
				for step: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
					if symbol_at(cell + step) == CRATE and not seen.has(cell + step):
						seen[cell + step] = true
						todo.append(cell + step)
			var choices: Dictionary = RoomStyles.LOOKS[type]["cover"]
			var props: Array = []
			if choices.has(group.size):
				var options: Array = choices[group.size]
				props = options[rng.randi_range(0, options.size() - 1)]
			if props == [&"pillar"]:
				for cell_y in range(group.position.y, group.end.y):
					var row := layout[cell_y]
					for cell_x in range(group.position.x, group.end.x):
						row[cell_x] = WALL
					layout[cell_y] = row
			else:
				covers[group] = props
	return covers


## Puts room objects on a block of crates: `props` spread across its bottom (on every tile if
## the block is one tile wide), or one small object per tile when there is no choice for its size.
func _cover(group: Rect2i, props: Array, rng: RandomNumberGenerator) -> void:
	var small: Array = RoomStyles.LOOKS[_room_type_at(group.position)]["small"]
	if props.is_empty() or group.size.x == 1:
		for y in range(group.position.y, group.end.y):
			for x in range(group.position.x, group.end.x):
				var prop: StringName = props[0] if not props.is_empty() else small[rng.randi_range(0, small.size() - 1)]
				add_prop(prop, Vector2(cell_center(Vector2i(x, y)).x, (y + 1) * TILE_SIZE))
		return
	var width := group.size.x * TILE_SIZE
	for i in props.size():
		var x := group.position.x * TILE_SIZE + (i + 0.5) * width / props.size()
		add_prop(props[i], Vector2(roundf(x), group.end.y * TILE_SIZE))


## A wall with floor right below it shows its front face; any other wall shows its top.
func _wall_tile_at(x: int, y: int) -> Vector2i:
	var is_last_row := y + 1 >= layout.size()
	if not is_last_row and not layout[y + 1][x] in [WALL, VOID, CRATE]:
		return WALL_FACE
	return WALL_TOP


## Which wall tile a wall of a room type shows (retexture spec, "Rooms"):
## - the north wall (floor below it, the dark above) shows its tall face under a wall top, and
##   the top corners next to it reach up with it;
## - an inner wall (nothing dark around it: the Labyrinth's inner walls, pillars) with floor
##   below shows a short face;
## - every other wall shows its top, with a light edge on the sides next to floor.
func _room_wall_tile(cell: Vector2i) -> Vector2i:
	if is_open(cell + Vector2i.DOWN):
		if is_tall_face(cell):
			return RoomStyles.TALL_FACES[cell.x % RoomStyles.TALL_FACES.size()]
		if is_inner(cell):
			return RoomStyles.SHORT_FACES[cell.x % RoomStyles.SHORT_FACES.size()]
	elif symbol_at(cell + Vector2i.UP) == VOID:
		if is_tall_face(cell + Vector2i.RIGHT):
			return RoomStyles.CORNER_FACE_EAST
		if is_tall_face(cell + Vector2i.LEFT):
			return RoomStyles.CORNER_FACE_WEST
	var edges := ""
	for side: String in SIDES:
		if is_open(cell + SIDES[side]):
			edges += side
	return RoomStyles.wall_top(edges)


## Floor, or anything standing on floor (crates included).
func is_open(cell: Vector2i) -> bool:
	return not symbol_at(cell) in [WALL, VOID]


## A north wall: floor below it and the dark above.
func is_tall_face(cell: Vector2i) -> bool:
	return symbol_at(cell) == WALL and is_open(cell + Vector2i.DOWN) and symbol_at(cell + Vector2i.UP) == VOID


## A wall with no dark (or map edge) in any of the 8 cells around it.
func is_inner(cell: Vector2i) -> bool:
	for dy in [-1, 0, 1]:
		for dx in [-1, 0, 1]:
			if symbol_at(cell + Vector2i(dx, dy)) == VOID:
				return false
	return true


## Covers the whole map with a walkable area, then lets Godot cut the walls out of it.
func _bake_navigation() -> void:
	var outline := PackedVector2Array([
		Vector2(bounds.position), Vector2(bounds.end.x, bounds.position.y),
		Vector2(bounds.end), Vector2(bounds.position.x, bounds.end.y),
	])
	_navigation.navigation_polygon.clear_outlines()
	_navigation.navigation_polygon.add_outline(outline)
	_navigation.bake_navigation_polygon(false)
