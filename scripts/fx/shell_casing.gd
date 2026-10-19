## A spent shell casing: flies out of the gun, bounces on the floor and stays there for the round.
## The flight is faked in 2D: `_height` is how far above the floor the casing is.
class_name ShellCasing
extends Node2D

var _floor_velocity := Vector2.ZERO
var _height := 0.0
var _lift_speed := 0.0
var _bounces_left := 0

@onready var _sprite: Sprite2D = $Sprite


## Starts the casing `height` pixels above the floor, flying sideways in `direction`.
func launch(direction: Vector2, height: float) -> void:
	var cfg := Config.balance
	var jitter := cfg.casing_randomness
	_floor_velocity = direction * cfg.casing_eject_speed * randf_range(1.0 - jitter, 1.0 + jitter)
	_height = height
	_lift_speed = cfg.casing_eject_lift * randf_range(1.0 - jitter, 1.0 + jitter)
	_bounces_left = cfg.casing_bounces
	rotation = randf() * TAU


func _process(delta: float) -> void:
	var cfg := Config.balance
	_lift_speed -= cfg.casing_gravity * delta
	_height += _lift_speed * delta
	position += _floor_velocity * delta
	rotation += cfg.casing_spin * delta
	if _height <= 0.0:
		_height = 0.0
		if _bounces_left == 0:
			set_process(false)  # Settled: it now stays on the floor until the round ends.
		else:
			_bounces_left -= 1
			_lift_speed = -_lift_speed * cfg.casing_bounciness
			_floor_velocity *= cfg.casing_bounciness
	_sprite.position.y = -_height
