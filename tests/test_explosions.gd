## Tests for explosions: one rule for every blast. They hurt enemies and the player in the
## radius, the Gold Detonator spares the player, and walls block them.
extends TestCase

const PLAYER := preload("res://scenes/player/player.tscn")
const GRUNT := preload("res://scenes/enemies/grunt_kin.tscn")
const FUSE := preload("res://scenes/enemies/fuse_kin.tscn")


func _add(scene: PackedScene, at: Vector2) -> Node2D:
	var node: Node2D = scene.instantiate()
	node.position = at
	world.add_child(node)
	return node


func _explode(stats: GunStats, at: Vector2) -> void:
	var blast := Explosion.create(stats.blast_radius, stats.damage, stats.blast_hurts_player)
	blast.position = at
	world.add_child(blast)


func test_fuse_launcher_blast_hurts_enemies_and_the_player() -> void:
	var player: Player = _add(PLAYER, Vector2(15, 0))
	var grunt: Enemy = _add(GRUNT, Vector2(-15, 0))
	_explode(Config.balance.fuse_launcher, Vector2.ZERO)
	assert_eq(player.hearts, Config.balance.player_hearts - 1, "player in the blast loses a heart")
	assert_true(grunt.hp <= 0, "grunt in the blast takes the damage")


func test_gold_detonator_never_hurts_the_player() -> void:
	var gold := Config.balance.gold_detonator
	var player: Player = _add(PLAYER, Vector2(10, 0))
	var grunt: Enemy = _add(GRUNT, Vector2(-10, 0))
	_explode(gold, Vector2.ZERO)
	assert_eq(player.hearts, Config.balance.player_hearts, "player is spared")
	assert_eq(grunt.hp, Config.balance.grunt_hp - gold.damage, "grunt still takes the damage")


func test_walls_block_blasts() -> void:
	await add_wall(Rect2(Vector2(8, -40), Vector2(8, 80)))
	var player: Player = _add(PLAYER, Vector2(25, 0))
	var grunt: Enemy = _add(GRUNT, Vector2(25, 15))
	_explode(Config.balance.fuse_launcher, Vector2.ZERO)
	assert_eq(player.hearts, Config.balance.player_hearts, "player behind the wall is safe")
	assert_eq(grunt.hp, Config.balance.grunt_hp, "grunt behind the wall is safe")


func test_fuse_kin_blast_hurts_other_enemies() -> void:
	var grunt: Enemy = _add(GRUNT, Vector2(20, 0))
	var fuse: Enemy = _add(FUSE, Vector2.ZERO)
	fuse.take_damage(Config.balance.fuse_hp, Vector2.RIGHT)
	await world.get_tree().process_frame  # The blast is added at the end of the frame.
	var hp_left := Config.balance.grunt_hp - Config.balance.fuse_blast_damage
	if hp_left > 0:
		assert_eq(grunt.hp, hp_left, "grunt caught in the blast is hurt")
	else:
		assert_true(not is_instance_valid(grunt), "grunt caught in the blast is killed")
