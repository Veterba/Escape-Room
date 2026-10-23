## A soft oval shadow on the floor under a flying enemy.
class_name GroundShadow
extends Node2D

## Half the width and half the height of the shadow, in pixels, and how dark it is.
@export var radius := Vector2(5.0, 2.0)
@export var darkness := 0.45


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, radius)
	draw_circle(Vector2.ZERO, 1.0, Color(0.0, 0.0, 0.0, darkness))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
