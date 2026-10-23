## Wing Kin: flies over walls and pits, keeps about 100 px from the player, and fires a
## spread of 3 teal bullets (15 degrees apart) every 2 s, only when it can see them.
class_name WingKin
extends Enemy

const WING_BULLET := preload("res://scenes/enemies/wing_bullet.tscn")

var _fire_cooldown := 0.0


func _ready() -> void:
	hp = Config.balance.wing_hp
	_fire_cooldown = Config.balance.wing_fire_interval


func _physics_process(delta: float) -> void:
	var cfg := Config.balance
	var player := target_player()
	if player == null:
		move(Vector2.ZERO, delta)
		return
	# Closer than the keep distance it backs off, farther it comes closer. It has no wall
	# collision, so it flies straight instead of using the navigation path.
	var gap := global_position.distance_to(player.global_position) - cfg.wing_keep_distance
	var desired := Vector2.ZERO
	if absf(gap) > cfg.wing_distance_slack:
		desired = global_position.direction_to(player.global_position) * signf(gap) * cfg.wing_speed
	move(desired, delta)
	_stay_inside_map()

	_fire_cooldown -= delta
	var aim_point := player.hurtbox_position()
	if _fire_cooldown <= 0.0 and can_see(aim_point):
		fire_spread(aim_point - (global_position + EYE_OFFSET))
		_fire_cooldown = cfg.wing_fire_interval


## Fires wing_bullets bullets fanned around `aim`, wing_spread_step degrees apart.
func fire_spread(aim: Vector2) -> void:
	var cfg := Config.balance
	var step := deg_to_rad(cfg.wing_spread_step)
	for i in cfg.wing_bullets:
		var offset := (i - (cfg.wing_bullets - 1) / 2.0) * step
		shoot(aim.rotated(offset), cfg.wing_bullet_speed, WING_BULLET)


## Flying over walls must not take it off the map: it stays inside the outer wall.
func _stay_inside_map() -> void:
	var map := get_parent() as GameMap
	if map == null:
		return
	var inside := Rect2(map.bounds).grow(-GameMap.TILE_SIZE)
	global_position = global_position.clamp(inside.position, inside.end)
