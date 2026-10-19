## A map built from a text layout: walls, floor, the player's start, and what stands where.
## After building, it bakes the navigation mesh that enemies use to walk around walls.
## Walls, characters and chests are y-sorted: whatever stands lower on screen is drawn in front.
##
## Layout legend: '#' wall, '.' floor, 'P' player start, 'C' secret code,
## 'G' gun chest, 'g' Grunt Kin, 'f' Fuse Kin. Every letter stands on floor.
class_name GameMap
extends Node2D

const TILE_SIZE := 16
const SOURCE_ID := 0
## Atlas coordinates of the tiles in art/game/tiles.png.
const FLOOR_TILES: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0)]
## How often each floor tile is picked: mostly plain, some cracked.
const FLOOR_WEIGHTS: Array[float] = [9.0, 1.0]
const WALL_TOP := Vector2i(2, 0)
const WALL_FACE := Vector2i(3, 0)
const WALL := "#"
const PLAYER_START := "P"
## What each letter in the layout places on the map.
const ENTITIES := {
	"C": preload("res://scenes/world/code_pickup.tscn"),
	"G": preload("res://scenes/world/gun_chest.tscn"),
	"g": preload("res://scenes/enemies/grunt_kin.tscn"),
	"f": preload("res://scenes/enemies/fuse_kin.tscn"),
}

@export var map_id: StringName
## One string per row of tiles, using the legend above.
@export var layout: PackedStringArray

## Where the player starts, in pixels.
var spawn_position := Vector2.ZERO
## The whole map in pixels, used to keep the camera inside.
var bounds := Rect2i()

@onready var _navigation: NavigationRegion2D = $Navigation
@onready var _floor: TileMapLayer = $Navigation/Floor
@onready var _walls: TileMapLayer = $Navigation/Walls


func _ready() -> void:
	bounds = Rect2i(Vector2i.ZERO, Vector2i(layout[0].length(), layout.size()) * TILE_SIZE)
	_build()
	_bake_navigation()


func _build() -> void:
	var rng := RandomNumberGenerator.new()
	for y in layout.size():
		for x in layout[y].length():
			var cell := Vector2i(x, y)
			var symbol := layout[y][x]
			if symbol == WALL:
				_walls.set_cell(cell, SOURCE_ID, _wall_tile_at(x, y))
				continue
			_floor.set_cell(cell, SOURCE_ID, FLOOR_TILES[rng.rand_weighted(FLOOR_WEIGHTS)])
			var center := _floor.map_to_local(cell)
			if symbol == PLAYER_START:
				spawn_position = center
			elif ENTITIES.has(symbol):
				var entity: Node2D = ENTITIES[symbol].instantiate()
				entity.position = center
				add_child(entity)


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
