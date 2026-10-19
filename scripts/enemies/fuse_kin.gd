## Fuse Kin: runs at the player. Close up it lights a 1.2 s fuse, blinking faster and faster,
## then explodes (36 px, one heart). It also explodes when killed.
class_name FuseKin
extends Enemy

## Seconds left on the fuse, or below 0 while it is not lit.
var _fuse_left := -1.0
var _blink_phase := 0.0


func _ready() -> void:
	hp = Config.balance.fuse_hp


func is_fuse_lit() -> bool:
	return _fuse_left >= 0.0


func _physics_process(delta: float) -> void:
	var cfg := Config.balance
	var player := target_player()
	var desired := Vector2.ZERO
	if player:
		desired = path_velocity(player.global_position, cfg.fuse_speed)
		var in_range := global_position.distance_to(player.global_position) <= cfg.fuse_trigger_distance
		if in_range and not is_fuse_lit():
			_fuse_left = cfg.fuse_time
			Audio.play_sfx(&"fuse_lit")
	move(desired, delta)
	if is_fuse_lit():
		_burn_fuse(delta)


## Blinks white, faster as the fuse runs out, and explodes at the end.
func _burn_fuse(delta: float) -> void:
	var cfg := Config.balance
	_fuse_left -= delta
	var burnt := 1.0 - clampf(_fuse_left / cfg.fuse_time, 0.0, 1.0)
	_blink_phase += lerpf(cfg.fuse_blink_rate_start, cfg.fuse_blink_rate_end, burnt) * delta
	var flash := 1.0 if fmod(_blink_phase, 1.0) < 0.5 else 0.0
	(body.material as ShaderMaterial).set_shader_parameter(&"flash_amount", flash)
	if _fuse_left <= 0.0:
		die()


## Killed or out of fuse, it always goes off.
func die() -> void:
	var blast := Explosion.create(Config.balance.fuse_blast_radius, 0, false, true)
	blast.global_position = global_position
	get_tree().current_scene.add_child.call_deferred(blast)
	super.die()
