## Tests that bullets stop at real tile walls (the TileMapLayer the maps are built from), for the
## player's bullets and the enemies'.
extends TestCase

const PLAYER_BULLET := preload("res://scenes/guns/player_bullet.tscn")
const ENEMY_BULLET := preload("res://scenes/enemies/enemy_bullet.tscn")
const TILES := preload("res://scenes/maps/dungeon_tiles.tres")
## A wall column this many tiles to the right of the bullets.
const WALL_COLUMN := 4


func test_bullets_stop_at_tile_walls() -> void:
	var walls := TileMapLayer.new()
	walls.tile_set = TILES
	for y in range(-3, 4):
		walls.set_cell(Vector2i(WALL_COLUMN, y), GameMap.SOURCE_ID, GameMap.WALL_TOP)
	world.add_child(walls)
	var player_bullet: PlayerBullet = PLAYER_BULLET.instantiate()
	player_bullet.setup(Vector2.RIGHT, Config.balance.pop_pistol)
	var enemy_bullet: EnemyBullet = ENEMY_BULLET.instantiate()
	enemy_bullet.setup(Vector2.RIGHT, Config.balance.player_bullet_speed)
	enemy_bullet.position = Vector2(0, GameMap.TILE_SIZE)
	world.add_child(player_bullet)
	world.add_child(enemy_bullet)
	# Long enough to fly well past the wall if nothing stopped them.
	for i in steps_for(WALL_COLUMN * 2.0 * GameMap.TILE_SIZE / Config.balance.player_bullet_speed):
		await world.get_tree().physics_frame
	assert_true(not is_instance_valid(player_bullet) or player_bullet.is_queued_for_deletion(), "player bullet stops at the wall")
	assert_true(not is_instance_valid(enemy_bullet) or enemy_bullet.is_queued_for_deletion(), "enemy bullet stops at the wall")
