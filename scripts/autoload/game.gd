## Autoload: moves between the menu and rounds, and picks the map type for each round.
extends Node

## The map types: the boss and arena rounds are floors of rooms, the maze is one labyrinth.
const MAP_IDS: Array[StringName] = [&"boss", &"maze", &"arena"]
const FLOOR_SCENE := preload("res://scenes/floor/dungeon_floor.tscn")
const LABYRINTH_SCENE := preload("res://scenes/maps/labyrinth.tscn")
const ROUND_SCENE := "res://scenes/round/round.tscn"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
const MAP_ARGUMENT := "--map="

## The map type of the round being played (or about to start).
var current_map_id: StringName


## The map forced with --map=boss|maze|arena on the command line, or an empty name.
func forced_map_id() -> StringName:
	for argument in OS.get_cmdline_args() + OS.get_cmdline_user_args():
		if argument.begins_with(MAP_ARGUMENT):
			var map_id := StringName(argument.trim_prefix(MAP_ARGUMENT))
			if MAP_IDS.has(map_id):
				return map_id
			push_error("Unknown map '%s'. Use boss, maze or arena." % map_id)
	return &""


## A uniform random map, unless one is forced on the command line.
func pick_map_id() -> StringName:
	var forced := forced_map_id()
	if forced != &"":
		return forced
	return MAP_IDS.pick_random()


## Starts a round on `map_id`, or on a freshly picked map if none is given.
func start_round(map_id: StringName = &"") -> void:
	current_map_id = map_id if map_id != &"" else pick_map_id()
	get_tree().paused = false
	get_tree().change_scene_to_file(ROUND_SCENE)


## The map for `map_id`, ready to be added to a round.
func make_map(map_id: StringName) -> GameMap:
	if map_id == &"maze":
		return LABYRINTH_SCENE.instantiate()
	var dungeon: DungeonFloor = FLOOR_SCENE.instantiate()
	dungeon.objective = map_id
	return dungeon


## Only the boss round has no timer: it ends when the boss is beaten or the player dies.
func has_timer(map_id: StringName) -> bool:
	return map_id != &"boss"


func go_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)
