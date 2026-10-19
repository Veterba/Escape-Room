## Grunt Kin: walks towards the player, stops at about 120 px when it can see them,
## and fires one bullet every 1.5 s. It never shoots through walls.
class_name GruntKin
extends Enemy

var _fire_cooldown := 0.0


func _ready() -> void:
	hp = Config.balance.grunt_hp
	_fire_cooldown = Config.balance.grunt_fire_interval


func _physics_process(delta: float) -> void:
	var cfg := Config.balance
	var player := target_player()
	if player == null:
		move(Vector2.ZERO, delta)
		return
	var aim_point := player.hurtbox_position()
	var sees_player := can_see(aim_point)
	var close_enough := global_position.distance_to(player.global_position) <= cfg.grunt_stop_distance
	var desired := Vector2.ZERO
	if not (sees_player and close_enough):
		desired = path_velocity(player.global_position, cfg.grunt_speed)
	move(desired, delta)

	_fire_cooldown -= delta
	if sees_player and _fire_cooldown <= 0.0:
		shoot(aim_point - (global_position + EYE_OFFSET), cfg.grunt_bullet_speed)
		_fire_cooldown = cfg.grunt_fire_interval
