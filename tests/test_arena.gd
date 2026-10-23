## Tests for the Enemy Arena: waves and their limits, the chained code chest and its HUD line,
## and chain-exploding barrels.
extends TestCase

const ROUND := preload("res://scenes/round/round.tscn")
const BARREL := preload("res://scenes/world/barrel.tscn")
const PLAYER := preload("res://scenes/player/player.tscn")
const GRUNT := preload("res://scenes/enemies/grunt_kin.tscn")
const LOG_PATH := "user://test_runs.csv"


func _make_arena_round() -> Round:
	Game.current_map_id = &"arena"
	var round_node: Round = ROUND.instantiate()
	round_node.run_log_path = LOG_PATH
	world.add_child(round_node)
	return round_node


func _spawns() -> Array[Node]:
	return world.get_tree().get_nodes_in_group(&"enemy_spawns")


func _code_chest(round_node: Round) -> CodeChest:
	for child in round_node.map.get_children():
		if child is CodeChest:
			return child
	return null


func test_waves_follow_the_mix_and_the_limits() -> void:
	var cfg := Config.balance
	var round_node := _make_arena_round()
	var waves := round_node.map.objective_room.waves
	waves.active = true
	waves._physics_process(STEP)
	assert_eq(waves.wave, 1, "wave 1 starts at once")
	assert_eq(_spawns().size(), cfg.arena_waves[0].grunts, "wave 1 sends its mix")
	for spawn: Node2D in _spawns():
		var distance := spawn.global_position.distance_to(round_node.player.global_position)
		assert_true(distance >= cfg.arena_spawn_min_distance, "spawn %d px from the player" % distance)

	waves._physics_process(cfg.arena_wave_interval / 2.0)
	assert_eq(waves.wave, 1, "no new wave while enough enemies are alive")
	waves._physics_process(cfg.arena_wave_interval / 2.0)
	assert_eq(waves.wave, 2, "a new wave after the interval")

	for spawn in _spawns():
		spawn.free()
	waves._physics_process(STEP)
	assert_eq(waves.wave, 3, "a new wave at once when fewer than %d are alive" % cfg.arena_min_alive)

	for i in 5:
		waves.start_next_wave()
		assert_true(waves.alive_count() <= cfg.arena_max_alive, "never more than %d alive" % cfg.arena_max_alive)


func test_spawn_effect_creates_an_awake_enemy() -> void:
	var round_node := _make_arena_round()
	round_node.map.objective_room.waves.start_next_wave()
	var spawn: EnemySpawn = _spawns()[0]
	spawn._physics_process(Config.balance.arena_spawn_time + STEP)
	var enemies := world.get_tree().get_nodes_in_group(&"enemies")
	assert_eq(enemies.size(), 1, "the enemy appears after the spawn effect")
	assert_true((enemies[0] as Enemy).awake, "and is awake at once")


func test_code_chest_is_chained_until_the_unlock_wave() -> void:
	var unlock_wave := Config.balance.arena_chest_unlock_wave
	var round_node := _make_arena_round()
	var chest := _code_chest(round_node)
	var status: Label = round_node.get_node("HUD/Root/ArenaStatus")
	assert_true(chest != null, "the arena has a code chest")
	assert_true(not chest.can_interact(), "locked at the start")
	Events.wave_started.emit(unlock_wave - 1)
	assert_true(chest.locked, "still locked before wave %d" % unlock_wave)
	assert_eq(status.text, "Chest locked: wave %d/%d" % [unlock_wave - 1, unlock_wave], "HUD line while locked")
	Events.wave_started.emit(unlock_wave)
	assert_true(chest.can_interact(), "open from wave %d" % unlock_wave)
	assert_eq(status.text, "Chest open!", "HUD line once open")


func test_opening_the_code_chest_takes_a_hold_that_a_hit_cancels() -> void:
	var cfg := Config.balance
	var round_node := _make_arena_round()
	var player := round_node.player
	var chest := _code_chest(round_node)
	chest.unlock()
	player.global_position = chest.global_position + Vector2(0, 16)
	var interactor: Interactor = player.get_node("Interactor")

	for i in steps_for(cfg.code_chest_open_time / 2.0):
		interactor.update(STEP, player, true)
	player.take_hit(Vector2.RIGHT)
	for i in steps_for(cfg.code_chest_open_time / 2.0):
		interactor.update(STEP, player, true)
	assert_true(chest.can_interact(), "a hit cancels the hold: still closed")

	interactor.update(STEP, player, false)  # Let go of E, then hold it again.
	for i in steps_for(cfg.code_chest_open_time):
		interactor.update(STEP, player, true)
	assert_true(not chest.can_interact(), "a full hold opens it")
	var dropped_code := false
	for child in round_node.map.get_children():
		dropped_code = dropped_code or (child is Pickup and (child as Pickup).kind == Pickup.Kind.CODE)
	assert_true(dropped_code, "it drops the code")


func test_gun_chests_are_coloured_by_rarity() -> void:
	var round_node := _make_arena_round()
	for child in round_node.map.get_children():
		var chest := child as GunChest
		if chest:
			assert_eq(chest.get_node("Sprite").self_modulate, chest._gun.chest_color, "chest colour matches its gun")


func test_barrels_hurt_everyone_and_chain_explode() -> void:
	var cfg := Config.balance
	var player: Player = PLAYER.instantiate()
	player.position = Vector2(-20, 0)
	world.add_child(player)
	var grunt: Enemy = GRUNT.instantiate()
	grunt.position = Vector2(0, 20)
	world.add_child(grunt)
	var first: Barrel = BARREL.instantiate()
	var second: Barrel = BARREL.instantiate()
	second.position = Vector2(cfg.barrel_blast_radius - 10.0, 0)
	world.add_child(first)
	world.add_child(second)

	first.ignite()
	first._physics_process(cfg.barrel_fuse_time + STEP)
	await world.get_tree().process_frame  # The blast is added at the end of the frame.
	assert_eq(player.hearts, cfg.player_hearts - 1, "the player loses one heart")
	assert_true(not is_instance_valid(grunt) or grunt.hp == cfg.grunt_hp - cfg.barrel_damage, "the grunt takes the damage")
	assert_true(second.is_lit(), "the barrel in range is lit by the blast")
