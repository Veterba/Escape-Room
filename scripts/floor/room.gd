## One room of a floor. A room with enemies_on_enter (a fight room, the boss room) locks its doors
## when the player walks in, sends those enemies, and opens the doors once they are all dead,
## together with any doors in opens_on_clear (the exit, after the boss). The arena room starts
## its waves when the player first walks in. Start, chest and exit rooms just sit there.
class_name Room
extends Node2D

const ENEMY_SPAWN := preload("res://scenes/fx/enemy_spawn.tscn")
const GRUNT := preload("res://scenes/enemies/grunt_kin.tscn")
const FUSE := preload("res://scenes/enemies/fuse_kin.tscn")
const ROCKET := preload("res://scenes/enemies/rocket_kin.tscn")
const WING := preload("res://scenes/enemies/wing_kin.tscn")

var kind: FloorGenerator.Kind
## How the room looks (a room type of RoomStyles).
var room_type: StringName
## Rooms between this one and the start.
var depth := 0
## Where the room is, in tiles, walls included.
var rect := Rect2i()
var map: GameMap
## The room this one grew from (null for the start), for the map overlay.
var parent_room: Room
var doors: Array[Door] = []
## Enemies sent when the player walks in; the doors stay locked until they are all dead.
var enemies_on_enter: Array[PackedScene] = []
## Doors elsewhere that open when this room is cleared.
var opens_on_clear: Array[Door] = []
## The boss room: the boss appears in the middle.
var boss_room := false
## The arena's waves, if this is the arena room.
var waves: ArenaWaves
var entered := false
var cleared := false


func _ready() -> void:
	y_sort_enabled = true


## The room in global pixels, without its walls.
func inside_area() -> Rect2:
	return Rect2(rect.grow(-1).position * GameMap.TILE_SIZE, rect.grow(-1).size * GameMap.TILE_SIZE)


func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	if player == null:
		return
	if not entered:
		# Only well past the doorway, so a closing door never lands on the player.
		var trigger := inside_area().grow(-Config.balance.floor_lock_inset_tiles * GameMap.TILE_SIZE)
		if trigger.has_point(player.global_position):
			entered = true
			_on_entered(player)
	elif not enemies_on_enter.is_empty() and not cleared and enemies_left() == 0:
		cleared = true
		for door in doors + opens_on_clear:
			door.open()
		Audio.play_sfx(&"doors_open")


## Enemies of this room still alive or still appearing.
func enemies_left() -> int:
	var count := 0
	for child in get_children():
		if (child is Enemy or child is EnemySpawn) and not child.is_queued_for_deletion():
			count += 1
	return count


## Puts enemies on free floor inside the room, at least the usual distance from the player.
## With `near_middle` they take the free spots closest to the room's middle instead of random ones.
func spawn(enemies: Array[PackedScene], player: Node2D, near_middle := false) -> void:
	var cells: Array[Vector2i] = []
	for cell in map.free_floor_cells:
		var center := map.cell_center(cell)
		var far_enough := center.distance_to(player.global_position) >= Config.balance.arena_spawn_min_distance
		if rect.grow(-1).has_point(cell) and far_enough:
			cells.append(cell)
	if near_middle:
		var middle := rect.get_center()
		cells.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.distance_squared_to(middle) < b.distance_squared_to(middle))
	else:
		cells.shuffle()
	for i in mini(enemies.size(), cells.size()):
		var marker: EnemySpawn = ENEMY_SPAWN.instantiate()
		marker.scene = enemies[i]
		marker.position = map.cell_center(cells[i])
		add_child(marker)


## The enemies of one wave mix, as a list of scenes.
static func enemies_for(mix: ArenaWave) -> Array[PackedScene]:
	var enemies: Array[PackedScene] = []
	for entry: Array in [[GRUNT, mix.grunts], [FUSE, mix.fuses], [ROCKET, mix.rockets], [WING, mix.wings]]:
		for i in entry[1]:
			enemies.append(entry[0])
	return enemies


func _on_entered(player: Node2D) -> void:
	if waves:
		waves.active = true
	if enemies_on_enter.is_empty():
		return
	for door in doors:
		door.close()
	spawn(enemies_on_enter, player, boss_room)
	Audio.play_sfx(&"doors_close")
