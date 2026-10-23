## Tests for the boss round: the Ammo Wraith's phases switch at 66 % and 33 %, beating it opens
## the exit, and the round has no timer.
extends TestCase

const ROUND := preload("res://scenes/round/round.tscn")
const AMMO_WRAITH := preload("res://scenes/enemies/ammo_wraith.tscn")
const PLAYER := preload("res://scenes/player/player.tscn")
const LOG_PATH := "user://test_runs.csv"


func _make_boss_round() -> Round:
	Game.current_map_id = &"boss"
	var round_node: Round = ROUND.instantiate()
	round_node.run_log_path = LOG_PATH
	world.add_child(round_node)
	return round_node


func test_phases_switch_at_66_and_33_percent() -> void:
	var cfg := Config.balance
	assert_eq(AmmoWraith.phase_for(1.0), 1, "full health: phase 1")
	assert_eq(AmmoWraith.phase_for(cfg.boss_phase2_at), 2, "at 66 %: phase 2")
	assert_eq(AmmoWraith.phase_for(cfg.boss_phase3_at), 3, "at 33 %: phase 3")
	world.add_child(PLAYER.instantiate())
	var boss: AmmoWraith = AMMO_WRAITH.instantiate()
	world.add_child(boss)
	boss.take_damage(ceili(cfg.boss_hp * (1.0 - cfg.boss_phase2_at)), Vector2.RIGHT)
	assert_eq(boss.phase, 2, "losing a third of its hit points starts phase 2")
	assert_true(boss._pause_left > 0.0, "with a roar between phases")
	boss.take_damage(ceili(cfg.boss_hp * (cfg.boss_phase2_at - cfg.boss_phase3_at)), Vector2.RIGHT)
	assert_eq(boss.phase, 3, "losing another third starts phase 3")


func test_beating_the_boss_opens_the_exit() -> void:
	var round_node := _make_boss_round()
	var dungeon := round_node.map as DungeonFloor
	var boss_room := dungeon.objective_room
	assert_true(not boss_room.opens_on_clear.is_empty(), "the boss room is joined to the exit")
	assert_true(boss_room.opens_on_clear.all(func(door: Door) -> bool: return door.is_closed()), "the exit starts shut")

	round_node.player.global_position = dungeon.cell_center(boss_room.rect.position + Vector2i(3, 3))
	boss_room._physics_process(STEP)
	var marker: EnemySpawn = boss_room.get_children().filter(func(child: Node) -> bool: return child is EnemySpawn)[0]
	marker._physics_process(Config.balance.arena_spawn_time + STEP)
	var boss: AmmoWraith = boss_room.get_children().filter(func(child: Node) -> bool: return child is AmmoWraith)[0]
	boss.take_damage(boss.max_hp, Vector2.RIGHT)
	boss_room._physics_process(STEP)
	assert_true(boss_room.opens_on_clear.all(func(door: Door) -> bool: return not door.is_closed()), "the exit opens")


func test_boss_round_has_no_timer() -> void:
	var round_node := _make_boss_round()
	round_node.timer._process(Config.balance.round_length + 1.0)
	assert_eq(round_node.result, Round.Result.NONE, "no timeout")
	assert_true(round_node.timer.elapsed > Config.balance.round_length, "the time played still counts")
