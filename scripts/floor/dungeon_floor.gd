## The map of an arena or boss round: one floor of rooms (FloorGenerator) that ends in the
## objective room, the Enemy Arena or the Boss Chamber. A boss floor also has an exit room behind
## the boss: its door opens when the boss is dead, and stepping on the exit wins. The whole floor
## is built as one GameMap, then every room gets a Room node that runs it.
class_name DungeonFloor
extends GameMap

const AMMO_WRAITH := preload("res://scenes/enemies/ammo_wraith.tscn")

## Which objective room ends the floor: &"arena" or &"boss". Set before adding the floor.
var objective: StringName
var plan: FloorGenerator
var rooms: Array[Room] = []
var objective_room: Room


func _ready() -> void:
	map_id = objective
	var rng := RandomNumberGenerator.new()
	var is_boss := objective == &"boss"
	plan = FloorGenerator.new(rng, ObjectiveRooms.BOSS_SIZE if is_boss else ObjectiveRooms.ARENA_SIZE, is_boss)
	plan.stamp_room(plan.objective, ObjectiveRooms.boss(rng) if is_boss else ObjectiveRooms.arena(rng))
	layout = plan.layout
	super._ready()
	var room_of := {}
	for room_plan in plan.rooms:
		room_of[room_plan] = _add_room(room_plan)
	for room_plan in plan.rooms:
		if room_plan.parent:
			room_of[room_plan].parent_room = room_of[room_plan.parent]
	# The Enemy Arena's gun chests stay locked until the wave that unlocks the code chest.
	if objective == &"arena":
		for child in get_children():
			var chest := child as GunChest
			if chest and objective_room.rect.has_point(_floor.local_to_map(chest.position)):
				chest.lock_until_wave(Config.balance.arena_chest_unlock_wave)
	# The exit stays shut until the boss is dead.
	for room in rooms:
		if room.kind == FloorGenerator.Kind.EXIT:
			for door in room.doors:
				door.close()
			objective_room.opens_on_clear = room.doors


## The room that contains `point` (in global pixels), or null in a corridor.
func room_at(point: Vector2) -> Room:
	var tile := Vector2i((point / TILE_SIZE).floor())
	for room in rooms:
		if room.rect.has_point(tile):
			return room
	return null


func _add_room(room_plan: FloorGenerator.RoomPlan) -> Room:
	var cfg := Config.balance
	var room := Room.new()
	room.kind = room_plan.kind
	room.depth = room_plan.depth
	room.rect = room_plan.rect
	room.map = self
	if room.kind == FloorGenerator.Kind.FIGHT:
		room.enemies_on_enter = Room.enemies_for(cfg.floor_fights[mini(room.depth, cfg.floor_fights.size()) - 1])
	elif room.kind == FloorGenerator.Kind.OBJECTIVE:
		objective_room = room
		if objective == &"boss":
			room.enemies_on_enter = [AMMO_WRAITH]
			room.boss_room = true
	add_child(room)
	rooms.append(room)
	for door: Door in get_tree().get_nodes_in_group(&"doors"):
		if is_ancestor_of(door) and room.rect.has_point(_floor.local_to_map(door.position)):
			room.doors.append(door)
	if room.kind == FloorGenerator.Kind.OBJECTIVE and objective == &"arena":
		room.waves = ArenaWaves.new()
		room.waves.room = room
		room.add_child(room.waves)
	return room
