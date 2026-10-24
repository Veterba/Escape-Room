## Tests for the boss round and Root: its phases switch at 66 % and 33 %, it cannot be hit while
## it teleports or roars, damage to the error windows never counts towards its hit points, a
## destroyed error window comes back, it drops the code on death, beating it opens the exit, and
## the round has no timer.
extends TestCase

const ROUND := preload("res://scenes/round/round.tscn")
const ROOT := preload("res://scenes/enemies/root.tscn")
const PLAYER := preload("res://scenes/player/player.tscn")
const LOG_PATH := "user://test_runs.csv"


func _make_boss_round() -> Round:
	Game.current_map_id = &"boss"
	var round_node: Round = ROUND.instantiate()
	round_node.run_log_path = LOG_PATH
	world.add_child(round_node)
	return round_node


## Walks into the boss room of a new boss round and lets Root appear there.
func _meet_root(round_node: Round) -> Root:
	var dungeon := round_node.map as DungeonFloor
	var boss_room := dungeon.objective_room
	round_node.player.global_position = dungeon.cell_center(boss_room.rect.position + Vector2i(3, 3))
	boss_room._physics_process(STEP)
	var marker: EnemySpawn = boss_room.get_children().filter(func(child: Node) -> bool: return child is EnemySpawn)[0]
	marker._physics_process(Config.balance.arena_spawn_time + STEP)
	return boss_room.get_children().filter(func(child: Node) -> bool: return child is Root)[0]


## Damage that brings Root down to just below `share` of its hit points.
func _damage_to(root: Root, share: float) -> int:
	return root.hp - floori(root.max_hp * share) + 1


## Runs Root's clock until it stops roaring and splitting.
func _wait_out_roar(root: Root) -> void:
	var cfg := Config.balance
	for i in steps_for(cfg.root_phase_pause + cfg.root_split_time) + 3:
		root._physics_process(STEP)


func test_phases_switch_at_66_and_33_percent() -> void:
	var cfg := Config.balance
	assert_eq(Root.phase_for(1.0), 1, "full health: phase 1")
	assert_eq(Root.phase_for(cfg.root_phase2_at), 2, "at 66 %: phase 2")
	assert_eq(Root.phase_for(cfg.root_phase3_at), 3, "at 33 %: phase 3")
	world.add_child(PLAYER.instantiate())
	var root: Root = ROOT.instantiate()
	world.add_child(root)
	root.take_damage(_damage_to(root, cfg.root_phase2_at), Vector2.RIGHT)
	assert_eq(root.phase, 2, "losing a third of its hit points starts phase 2")
	assert_eq(root.state, Root.State.ROAR, "with a roar between phases")
	_wait_out_roar(root)
	root.take_damage(_damage_to(root, cfg.root_phase3_at), Vector2.RIGHT)
	assert_eq(root.phase, 3, "losing another third starts phase 3")


func test_cannot_be_hit_while_teleporting_or_roaring() -> void:
	var cfg := Config.balance
	world.add_child(PLAYER.instantiate())
	var root: Root = ROOT.instantiate()
	world.add_child(root)
	root.start_teleport()
	var hp := root.hp
	for i in steps_for(cfg.root_teleport_out_time + cfg.root_teleport_gone_time + cfg.root_teleport_in_time) - 2:
		root.take_damage(1, Vector2.RIGHT)
		root._physics_process(STEP)
	assert_eq(root.hp, hp, "no damage while teleporting")
	for i in 3:
		root._physics_process(STEP)
	root.take_damage(_damage_to(root, cfg.root_phase2_at), Vector2.RIGHT)
	assert_eq(root.state, Root.State.ROAR, "roaring into phase 2")
	hp = root.hp
	root.take_damage(1, Vector2.RIGHT)
	assert_eq(root.hp, hp, "no damage while roaring")


func test_error_windows_have_their_own_hit_points_and_come_back() -> void:
	var cfg := Config.balance
	var round_node := _make_boss_round()
	var root := _meet_root(round_node)
	root.take_damage(_damage_to(root, cfg.root_phase3_at), Vector2.RIGHT)
	assert_eq(root.phase, 3, "straight into phase 3")
	_wait_out_roar(root)
	assert_eq(root.error_windows.size(), 5, "five error windows split off")
	var window: ErrorWindow = root.error_windows[0]
	for i in steps_for(cfg.root_split_time) + 2:
		window._physics_process(STEP)
	var root_hp := root.hp
	window.take_damage(cfg.error_window_hp, Vector2.RIGHT)
	assert_eq(root.hp, root_hp, "damage to an error window does not count towards Root's")
	assert_eq(window.state, ErrorWindow.State.BURST, "a destroyed error window bursts")
	for i in steps_for(ErrorWindow.BURST_TIME + cfg.error_window_return_time - 0.1):
		window._physics_process(STEP)
	assert_true(window.state == ErrorWindow.State.AWAY, "it stays away until its time is up")
	for i in steps_for(0.1 + cfg.error_window_teleport_in_time) + 3:
		window._physics_process(STEP)
	assert_eq(window.state, ErrorWindow.State.FLOAT, "then it comes back")
	assert_eq(window.hp, cfg.error_window_hp, "with all its hit points")


func test_root_drops_the_code_on_death() -> void:
	var round_node := _make_boss_round()
	var root := _meet_root(round_node)
	var room := root.get_parent()
	root.take_damage(root.hp, Vector2.RIGHT)
	assert_eq(root.state, Root.State.DYING, "its windows start closing")
	for i in steps_for(Root.DEATH_START + Root.DEATH_ORDER.size() * Root.DEATH_STEP) + 2:
		if is_instance_valid(root):
			root._physics_process(STEP)
	await world.get_tree().process_frame
	assert_true(not is_instance_valid(root) or root.is_queued_for_deletion(), "Root is gone")
	assert_true(room.get_children().any(func(child: Node) -> bool: return child is KeyPickup), "the code dropped")


func test_beating_the_boss_opens_the_exit() -> void:
	var round_node := _make_boss_round()
	var boss_room := (round_node.map as DungeonFloor).objective_room
	assert_true(not boss_room.opens_on_clear.is_empty(), "the boss room is joined to the exit")
	assert_true(boss_room.opens_on_clear.all(func(door: Door) -> bool: return door.is_closed()), "the exit starts shut")
	var root := _meet_root(round_node)
	root.take_damage(root.hp, Vector2.RIGHT)
	for i in steps_for(Root.DEATH_START + Root.DEATH_ORDER.size() * Root.DEATH_STEP) + 2:
		if is_instance_valid(root):
			root._physics_process(STEP)
	await world.get_tree().process_frame
	boss_room._physics_process(STEP)
	assert_true(boss_room.opens_on_clear.all(func(door: Door) -> bool: return not door.is_closed()), "the exit opens")


func test_boss_round_has_no_timer() -> void:
	var round_node := _make_boss_round()
	round_node.timer._process(Config.balance.round_length + 1.0)
	assert_eq(round_node.result, Round.Result.NONE, "no timeout")
	assert_true(round_node.timer.elapsed > Config.balance.round_length, "the time played still counts")
