## One tile of a doorway between a room and its corridor. Open, it is just floor; closed, a gate
## blocks the player, enemies and bullets (physics layer 1, like a wall).
class_name Door
extends StaticBody2D

@onready var _shape: CollisionShape2D = $Shape
@onready var _gate: Sprite2D = $Gate


func close() -> void:
	_shape.set_deferred(&"disabled", false)
	_gate.visible = true


func open() -> void:
	_shape.set_deferred(&"disabled", true)
	_gate.visible = false


func is_closed() -> bool:
	return _gate.visible
