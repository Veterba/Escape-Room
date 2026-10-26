## Tests for the Enemy Arena: waves and their limits, the chained code chest and its HUD line,
## and chain-exploding barrels.
extends TestCase

const ROUND := preload("res://scenes/round/round.tscn")
const BARREL := preload("res://scenes/world/barrel.tscn")
const PLAYER := preload("res://scenes/player/player.tscn")
const GRUNT := preload("res://scenes/enemies/grunt_kin.tscn")
const GUN_CHEST := preload("res://scenes/world/gun_chest.tscn")
const LOG_PATH := "user://test_runs.csv"
## Extra seconds to wait for a drop: headless frames can be slow and long, so a drop animation
## may need a frame or two more than its own time.
const DROP_SLACK := 0.5


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
	var waves := (round_node.map as DungeonFloor).objective_room.waves
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

	while waves.wave < cfg.arena_chest_unlock_wave:
		waves.start_next_wave()
		assert_true(waves.alive_count() <= cfg.arena_max_alive, "never more than %d alive" % cfg.arena_max_alive)
	for spawn in _spawns():
		spawn.free()
	waves._physics_process(cfg.arena_wave_interval)
	assert_eq(waves.wave, cfg.arena_chest_unlock_wave, "no waves after the one that unlocks the chest")


func test_spawn_effect_creates_an_awake_enemy() -> void:
	var round_node := _make_arena_round()
	(round_node.map as DungeonFloor).objective_room.waves.start_next_wave()
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
	assert_true(not chest.can_interact(), "the chains are still falling")
	chest._process(Config.balance.code_chest_unchain_time)
	assert_true(chest.can_interact(), "open from wave %d, once the chains are off" % unlock_wave)
	assert_eq(status.text, "Chest open!", "HUD line once open")


func test_opening_the_code_chest_takes_a_hold_that_a_hit_cancels() -> void:
	var cfg := Config.balance
	var round_node := _make_arena_round()
	var player := round_node.player
	var chest := _code_chest(round_node)
	chest.unlock()
	chest._process(cfg.code_chest_unchain_time)
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
	chest._process(cfg.chest_open_time)
	await wait(CodeChest.DROP_TIME + DROP_SLACK)  # The key drops in front of the chest.
	var dropped_code := false
	for child in round_node.map.get_children():
		dropped_code = dropped_code or (child is Pickup and (child as Pickup).kind == Pickup.Kind.CODE)
	# The player stands where the key lands, so he may already have picked it up and won.
	assert_true(dropped_code or round_node.result == Round.Result.WIN, "it drops the code")


func test_arena_gun_chests_stay_locked_until_the_unlock_wave() -> void:
	var unlock_wave := Config.balance.arena_chest_unlock_wave
	var round_node := _make_arena_round()
	var dungeon := round_node.map as DungeonFloor
	var arena_chests: Array[GunChest] = []
	for child in dungeon.get_children():
		if child is GunChest and dungeon.room_at(child.global_position) == dungeon.objective_room:
			arena_chests.append(child)
	assert_eq(arena_chests.size(), 2, "the arena has 2 gun chests")
	for chest in arena_chests:
		assert_eq(chest.state, GunChest.State.LOCKED, "locked at the start")
	Events.wave_started.emit(unlock_wave)
	for chest in arena_chests:
		assert_eq(chest.state, GunChest.State.READY, "ready from wave %d" % unlock_wave)


func test_gun_chest_opens_and_drops_its_gun() -> void:
	var cfg := Config.balance
	var chest: GunChest = GUN_CHEST.instantiate()
	world.add_child(chest)
	assert_true(chest.can_interact(), "a chest outside the arena is ready")
	chest.interact(null)
	assert_true(not chest.can_interact(), "opening")
	chest._process(cfg.chest_open_time)
	assert_eq(chest.state, GunChest.State.OPEN, "open after chest_open_time")
	await wait(GunChest.DROP_TIME + DROP_SLACK)
	var dropped: GunPickup = null
	for child in world.get_children():
		if child is GunPickup:
			dropped = child
	assert_true(dropped != null, "its gun lies in front of it")
	assert_eq(dropped.owned.stats, chest._gun, "the gun that rose out of it")


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
	# On a slow frame its short fuse may already have burnt down: gone means it went off too.
	assert_true(not is_instance_valid(second) or second.is_lit(), "the barrel in range is lit by the blast")
