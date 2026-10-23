## Shade Kin: drifts slowly straight at the player, through walls. Half see-through and
## flickering. Touching it costs a heart.
class_name ShadeKin
extends Enemy

## How see-through it is: the alpha jumps between these two values every frame.
const ALPHA_MIN := 0.35
const ALPHA_MAX := 0.6

@onready var _contact: Area2D = $Contact


func _ready() -> void:
	hp = Config.balance.shade_hp


func _physics_process(delta: float) -> void:
	var player := target_player()
	hurt_touching_player(_contact)
	var desired := Vector2.ZERO
	if player:
		desired = global_position.direction_to(player.global_position) * Config.balance.shade_speed
	move(desired, delta)
	body.modulate.a = randf_range(ALPHA_MIN, ALPHA_MAX)
