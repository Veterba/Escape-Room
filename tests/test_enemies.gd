## Tests for the Grunt and Fuse Kin (waking up, dying, exploding), and the smoke bomb.
extends TestCase

const PLAYER := preload("res://scenes/player/player.tscn")
const GRUNT := preload("res://scenes/enemies/grunt_kin.tscn")
const FUSE := preload("res://scenes/enemies/fuse_kin.tscn")
const ENEMY_BULLET := preload("res://scenes/enemies/enemy_bullet.tscn")


func _add(scene: PackedScene, at: Vector2) -> Node2D:
	var node: Node2D = scene.instantiate()
	node.position = at
	world.add_child(node)
	return node


func test_grunt_dies_after_its_hit_points() -> void:
	var grunt: Enemy = _add(GRUNT, Vector2.ZERO)
	for i in Config.balance.grunt_hp - 1:
		grunt.take_damage(1, Vector2.RIGHT)
	assert_true(not grunt.is_queued_for_deletion(), "alive with 1 hp left")
	grunt.take_damage(1, Vector2.RIGHT)
	assert_true(grunt.is_queued_for_deletion(), "dead at 0 hp")


func test_fuse_kin_explodes_when_killed_and_costs_a_heart() -> void:
	var player: Player = _add(PLAYER, Vector2.ZERO)
	var fuse: Enemy = _add(FUSE, Vector2(Config.balance.fuse_blast_radius - 5.0, 0))
	fuse.take_damage(Config.balance.fuse_hp, Vector2.RIGHT)
	await world.get_tree().process_frame  # The explosion is added at the end of the frame.
	assert_eq(player.hearts, Config.balance.player_hearts - 1, "player inside the blast loses a heart")


func test_fuse_kin_blast_misses_a_player_outside_the_radius() -> void:
	var player: Player = _add(PLAYER, Vector2.ZERO)
	var fuse: Enemy = _add(FUSE, Vector2(Config.balance.fuse_blast_radius + 5.0, 0))
	fuse.take_damage(Config.balance.fuse_hp, Vector2.RIGHT)
	await world.get_tree().process_frame
	assert_eq(player.hearts, Config.balance.player_hearts, "no heart lost outside the blast")


func test_smoke_bomb_clears_enemy_bullets_on_screen() -> void:
	var player: Player = _add(PLAYER, Vector2.ZERO)
	var near: Node2D = _add(ENEMY_BULLET, Vector2(100, 0))
	var far: Node2D = _add(ENEMY_BULLET, Vector2(5000, 0))
	await world.get_tree().process_frame  # Lets the camera settle on the player.
	assert_true(player.use_smoke_bomb(), "smoke bomb used")
	assert_true(near.is_queued_for_deletion(), "bullet on screen is gone")
	assert_true(not far.is_queued_for_deletion(), "bullet off screen stays")
	assert_eq(player.smoke_bombs, Config.balance.smoke_bombs_start - 1, "one bomb used up")
	assert_true(not player.use_smoke_bomb(), "no bombs left")


func test_enemy_idles_until_it_sees_or_is_near_the_player() -> void:
	var wake := Config.balance.enemy_wake_distance
	_add(PLAYER, Vector2.ZERO)
	await add_wall(Rect2(Vector2(20, -100), Vector2(16, 200)))
	var far_behind_wall: Enemy = _add(GRUNT, Vector2(wake + 40, 0))
	var near_behind_wall: Enemy = _add(GRUNT, Vector2(wake - 40, 0))
	var far_in_sight: Enemy = _add(GRUNT, Vector2(-(wake + 100), 0))
	assert_eq(far_behind_wall.target_player(), null, "far and behind a wall: still idle")
	assert_true(not far_behind_wall.awake, "far and behind a wall: not awake")
	assert_true(near_behind_wall.target_player() != null, "within %d px: awake even behind a wall" % wake)
	assert_true(far_in_sight.target_player() != null, "far but in sight: awake")


func test_awake_enemy_stays_awake() -> void:
	var player: Player = _add(PLAYER, Vector2.ZERO)
	var grunt: Enemy = _add(GRUNT, Vector2(50, 0))
	grunt.target_player()
	player.position = Vector2(-1000, 0)
	await add_wall(Rect2(Vector2(-500, -100), Vector2(16, 200)))
	assert_true(grunt.target_player() != null, "still chasing after losing sight")


func test_smoke_bombs_carry_at_most_two() -> void:
	var player: Player = _add(PLAYER, Vector2.ZERO)
	var most := Config.balance.smoke_bombs_max
	while player.smoke_bombs < most:
		assert_true(player.add_smoke_bomb(), "picks up a smoke bomb below the limit")
	assert_true(not player.add_smoke_bomb(), "no pickup at %d" % most)
	assert_eq(player.smoke_bombs, most, "count stays at the limit")
