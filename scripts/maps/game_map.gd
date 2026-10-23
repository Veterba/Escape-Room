## A map built from a text layout: walls, floor, the player's start, and what stands where.
## After building, it bakes the navigation mesh that enemies use to walk around walls.
## Walls, characters and chests are y-sorted: whatever stands lower on screen is drawn in front.
##
## Layout legend: '#' wall, 'x' crate (a wall that looks like a crate), '.' floor,
## 'P' player start, 'C' secret code, 'K' a spot for the code chest (one of them is picked at
## random), 'G' gun chest, 'H' hourglass, 'b' red barrel, 'g' Grunt Kin, 'f' Fuse Kin,
## 's' Shade Kin, 'w' Wing Kin. Every letter but '#' and 'x' stands on floor.
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
const WALL := "#"
const CRATE := "x"
const FLOOR := "."
const PLAYER_START := "P"
const CODE_CHEST_SPOT := "K"
const CODE_CHEST := preload("res://scenes/world/code_chest.tscn")
## What each letter in the layout places on the map.
const ENTITIES := {
	"C": preload("res://scenes/world/code_pickup.tscn"),
	"G": preload("res://scenes/world/gun_chest.tscn"),
	"H": preload("res://scenes/world/hourglass_pickup.tscn"),
	"b": preload("res://scenes/world/barrel.tscn"),
	"g": preload("res://scenes/enemies/grunt_kin.tscn"),
	"f": preload("res://scenes/enemies/fuse_kin.tscn"),
	"s": preload("res://scenes/enemies/shade_kin.tscn"),
	"w": preload("res://scenes/enemies/wing_kin.tscn"),
}

@export var map_id: StringName
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
	var code_chest_spots: Array[Vector2] = []
	for y in layout.size():
		for x in layout[y].length():
			var cell := Vector2i(x, y)
			var symbol := layout[y][x]
			if symbol == WALL:
				_walls.set_cell(cell, SOURCE_ID, _wall_tile_at(x, y))
				continue
			if symbol == CRATE:
				_walls.set_cell(cell, SOURCE_ID, CRATE_TILE)
				continue
			_floor.set_cell(cell, SOURCE_ID, FLOOR_TILES[rng.rand_weighted(FLOOR_WEIGHTS)])
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


## The centre of `cell` in pixels.
func cell_center(cell: Vector2i) -> Vector2:
	return _floor.map_to_local(cell)


## A wall with floor right below it shows its front face; any other wall shows its top.
func _wall_tile_at(x: int, y: int) -> Vector2i:
	var is_last_row := y + 1 >= layout.size()
	if not is_last_row and layout[y + 1][x] != WALL:
		return WALL_FACE
	return WALL_TOP


## Covers the whole map with a walkable area, then lets Godot cut the walls out of it.
func _bake_navigation() -> void:
	var outline := PackedVector2Array([
		Vector2(bounds.position), Vector2(bounds.end.x, bounds.position.y),
		Vector2(bounds.end), Vector2(bounds.position.x, bounds.end.y),
	])
	_navigation.navigation_polygon.clear_outlines()
	_navigation.navigation_polygon.add_outline(outline)
	_navigation.bake_navigation_polygon(false)
