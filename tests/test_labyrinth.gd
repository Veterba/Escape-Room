## Tests for the Labyrinth: the maze generator over 50 seeds, the hourglass, and the trap.
extends TestCase

const PLAYER := preload("res://scenes/player/player.tscn")
const OFFICER := preload("res://scenes/enemies/officer_kin.tscn")
const SEEDS := 50


func test_every_maze_is_reachable_with_the_code_farthest_and_60_to_90_s_away() -> void:
	var cfg := Config.balance
	for i in SEEDS:
		var rng := RandomNumberGenerator.new()
		rng.seed = i
		var maze := MazeGenerator.generate(rng)
		assert_eq(maze.distances.size(), cfg.maze_cols * cfg.maze_rows, "seed %d: every cell is reachable" % i)
		var farthest: int = maze.distances.values().max()
		assert_eq(maze.distances[maze.code_cell], farthest, "seed %d: the code is in the farthest cell" % i)
		var seconds := maze.walk_time()
		assert_true(seconds >= cfg.maze_min_walk_time and seconds <= cfg.maze_max_walk_time,
				"seed %d: shortest walk %.0f s" % [i, seconds])
		_assert_layout_connects_start_to_code(maze, i)


## Flood fill over the built layout's tiles, so the text map matches the maze.
func _assert_layout_connects_start_to_code(maze: MazeGenerator, seed_number: int) -> void:
	var layout := maze.to_layout({maze.start: "P", maze.code_cell: "C"})
	var start := Vector2i.ZERO
	for y in layout.size():
		if layout[y].contains("P"):
			start = Vector2i(layout[y].find("P"), y)
	var seen := {start: true}
	var queue: Array[Vector2i] = [start]
	var found_code := false
	while not queue.is_empty():
		var tile: Vector2i = queue.pop_front()
		found_code = found_code or layout[tile.y][tile.x] == "C"
		for step in MazeGenerator.DIRECTIONS:
			var next := tile + step
			if not seen.has(next) and layout[next.y][next.x] != GameMap.WALL:
				seen[next] = true
				queue.append(next)
	assert_true(found_code, "seed %d: the code can be walked to on the tiles" % seed_number)


func test_hourglass_adds_30_s_only_once() -> void:
	var timer := RoundTimer.new()
	world.add_child(timer)
	timer.start(100.0)
	assert_true(timer.add_bonus_once(Config.balance.hourglass_bonus_time), "first hourglass counts")
	assert_true(not timer.add_bonus_once(Config.balance.hourglass_bonus_time), "a second one does not")
	assert_eq(timer.time_left, 100.0 + Config.balance.hourglass_bonus_time, "time added once")


func test_ten_presses_of_e_break_the_handcuffs_without_losing_a_heart() -> void:
	var player: Player = PLAYER.instantiate()
	world.add_child(player)
	var officer: OfficerKin = OFFICER.instantiate()
	officer.position = Vector2(10, 0)
	world.add_child(officer)
	assert_true(player.trap(officer), "the officer handcuffs the player")
	for i in Config.balance.trap_presses - 1:
		player.mash()
	assert_eq(player.state, Player.State.TRAPPED, "still trapped one press short")
	player.mash()
	assert_eq(player.state, Player.State.NORMAL, "free after %d presses" % Config.balance.trap_presses)
	assert_eq(player.hearts, Config.balance.player_hearts, "no heart lost")
	assert_eq(officer.mode, OfficerKin.Mode.STUN, "the officer is stunned")
	assert_true(officer._knockback.length() > 0.0, "and thrown back, so he is not still touching the player")
	assert_true(not player.trap(officer), "officers cannot trap again right away")
