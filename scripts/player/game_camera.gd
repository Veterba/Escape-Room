## The camera: follows the player smoothly, stays inside the room, and can shake.
class_name GameCamera
extends Camera2D

var _shake_strength := 0.0


func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = Config.balance.camera_smoothing_speed


## Keeps the view inside `bounds` (in pixels), so the player never sees outside the room.
func set_bounds(bounds: Rect2i) -> void:
	limit_left = bounds.position.x
	limit_top = bounds.position.y
	limit_right = bounds.end.x
	limit_bottom = bounds.end.y
	reset_smoothing()


## Shakes the view by up to `strength` pixels, fading out. Does nothing if shake is off in the config.
func shake(strength: float) -> void:
	if Config.balance.screen_shake_enabled:
		_shake_strength = maxf(_shake_strength, strength)


func _process(delta: float) -> void:
	if _shake_strength <= 0.0:
		offset = Vector2.ZERO
		return
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).round() * _shake_strength
	_shake_strength = move_toward(_shake_strength, 0.0, Config.balance.screen_shake_decay * delta)
