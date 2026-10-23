## Autoload: moves between the menu and rounds, and picks the objective room for each round's floor.
extends Node

## The objective rooms a floor can end in.
const MAP_IDS: Array[StringName] = [&"boss", &"maze", &"arena"]
const FLOOR_SCENE := preload("res://scenes/floor/dungeon_floor.tscn")
const ROUND_SCENE := "res://scenes/round/round.tscn"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
const MAP_ARGUMENT := "--map="

## The objective of the round being played (or about to start).
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


func go_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)
