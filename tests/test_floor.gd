## Tests for floors: room count, every tile reachable from the start with the objective at the
## end of the longest path, and fight rooms that lock until they are cleared.
extends TestCase

const ROUND := preload("res://scenes/round/round.tscn")
const LOG_PATH := "user://test_runs.csv"
const SEEDS := 20
## Tiles the player cannot walk on.
const BLOCKED := [GameMap.WALL, GameMap.CRATE, GameMap.VOID]


func test_floors_are_connected_and_end_in_the_objective() -> void:
	var cfg := Config.balance
	for i in SEEDS:
		var rng := RandomNumberGenerator.new()
		rng.seed = i
		var plan := FloorGenerator.new(rng, ObjectiveRooms.ARENA_SIZE)
		plan.stamp_room(plan.objective, ObjectiveRooms.arena(rng))
		var count := plan.rooms.size()
		assert_true(count >= cfg.floor_min_rooms and count <= cfg.floor_max_rooms, "seed %d: %d rooms" % [i, count])
		var deepest := 0
		for room in plan.rooms:
			deepest = maxi(deepest, room.depth)
		assert_eq(plan.objective.depth, deepest, "seed %d: the objective is the deepest room" % i)
		var reached := _walkable_from_start(plan.layout)
		var walkable := 0
		for row in plan.layout:
			for symbol in row:
				walkable += 0 if BLOCKED.has(symbol) else 1
		assert_eq(reached.size(), walkable, "seed %d: every walkable tile can be reached" % i)
		for room in plan.rooms:
			assert_true(reached.has(room.rect.get_center()), "seed %d: room at %s can be reached" % [i, room.rect.position])


func test_fight_room_locks_until_cleared() -> void:
	Game.current_map_id = &"arena"
	var round_node: Round = ROUND.instantiate()
	round_node.run_log_path = LOG_PATH
	world.add_child(round_node)
	var room: Room = null
	for candidate in round_node.map.rooms:
		if candidate.kind == FloorGenerator.Kind.FIGHT:
			room = candidate
	assert_true(not room.doors.is_empty(), "the fight room has doors")
	assert_true(not room.doors[0].is_closed(), "doors start open")

	round_node.player.global_position = room.inside_area().get_center()
	room._physics_process(STEP)
	assert_true(room.doors.all(func(door: Door) -> bool: return door.is_closed()), "walking in locks every door")
	assert_true(room.enemies_left() > 0, "enemies appear")

	for child in room.get_children():
		if child is Enemy or child is EnemySpawn:
			child.free()
	room._physics_process(STEP)
	assert_true(room.doors.all(func(door: Door) -> bool: return not door.is_closed()), "a cleared room opens")


## Every walkable tile that can be reached from 'P', by flood fill.
func _walkable_from_start(layout: PackedStringArray) -> Dictionary:
	var start := Vector2i.ZERO
	for y in layout.size():
		if layout[y].contains(GameMap.PLAYER_START):
			start = Vector2i(layout[y].find(GameMap.PLAYER_START), y)
	var reached := {start: true}
	var queue: Array[Vector2i] = [start]
	while not queue.is_empty():
		var tile: Vector2i = queue.pop_front()
		for step in FloorGenerator.STEPS:
			var next := tile + step
			if not reached.has(next) and not BLOCKED.has(layout[next.y][next.x]):
				reached[next] = true
				queue.append(next)
	return reached
