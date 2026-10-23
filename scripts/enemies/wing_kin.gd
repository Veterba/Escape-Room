## Wing Kin: a flying enemy that keeps about 100 px from the player and fires a spread of 3 teal
## bullets (15 degrees apart) every 2 s, only when it can see them. It flies over pits, but not
## over walls: otherwise it could hover where the player's bullets cannot reach it.
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
	# Farther than the keep distance it comes closer along the navigation path; closer, it backs
	# straight off (sliding along walls).
	var gap := global_position.distance_to(player.global_position) - cfg.wing_keep_distance
	var desired := Vector2.ZERO
	if gap > cfg.wing_distance_slack:
		desired = path_velocity(player.global_position, cfg.wing_speed)
	elif gap < -cfg.wing_distance_slack:
		desired = player.global_position.direction_to(global_position) * cfg.wing_speed
	move(desired, delta)

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

