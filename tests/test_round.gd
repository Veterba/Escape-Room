## Tests for a whole round: timeout, death and the code each end it with the right result,
## and every finished round writes one line to the run log.
extends TestCase

const ROUND := preload("res://scenes/round/round.tscn")
const LOG_PATH := "user://test_runs.csv"


func _make_round() -> Round:
	DirAccess.remove_absolute(LOG_PATH)
	Game.current_map_id = &"arena"
	var round_node: Round = ROUND.instantiate()
	round_node.run_log_path = LOG_PATH
	world.add_child(round_node)
	return round_node


func _log_lines() -> PackedStringArray:
	var lines := FileAccess.get_file_as_string(LOG_PATH).strip_edges().split("\n")
	DirAccess.remove_absolute(LOG_PATH)
	return lines


func test_timer_reaching_zero_is_a_timeout_loss() -> void:
	var round_node := _make_round()
	round_node.timer.time_left = STEP
	round_node.timer._process(STEP)
	assert_eq(round_node.result, Round.Result.TIMEOUT, "result")
	var lines := _log_lines()
	assert_eq(lines.size(), 2, "run log has a header and one round")
	assert_true(lines[1].contains(",arena,timeout,"), "run log line names map and result: " + lines[1])


func test_losing_every_heart_is_a_death_loss() -> void:
	var round_node := _make_round()
	var player := round_node.player
	for i in Config.balance.player_hearts:
		player.take_hit(Vector2.RIGHT)
		for step in steps_for(Config.balance.hit_invulnerable_time):
			player._physics_process(STEP)
	assert_eq(player.hearts, 0, "no hearts left")
	assert_eq(round_node.result, Round.Result.DEATH, "result")
	assert_eq(round_node.hearts_lost, Config.balance.player_hearts, "hearts lost are counted")
	_log_lines()


func test_picking_up_the_code_wins() -> void:
	var round_node := _make_round()
	Events.code_collected.emit()
	assert_eq(round_node.result, Round.Result.WIN, "result")
	Events.code_collected.emit()
	assert_eq(_log_lines().size(), 2, "a second pickup does not end the round again")


func test_gun_used_most_is_logged() -> void:
	var round_node := _make_round()
	round_node.player.gun.try_fire()
	assert_eq(round_node.gun_used_most(), "pop_pistol", "gun used most")
	_log_lines()
