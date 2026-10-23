## The 0.8 s spawn effect in arena and fight rooms: a red ring closes in, then the enemy appears,
## already awake. It counts as alive while it plays, so waves never overshoot the limit.
class_name EnemySpawn
extends Node2D

const COLOR := Color("#E0403A")
## Radius of the ring when it starts, in pixels.
const START_RADIUS := 12.0
const RING_WIDTH := 1.0

## The enemy to create.
var scene: PackedScene
var _time_left := 0.0


func _ready() -> void:
	_time_left = Config.balance.arena_spawn_time


func _physics_process(delta: float) -> void:
	_time_left -= delta
	queue_redraw()
	if _time_left > 0.0:
		return
	var enemy: Enemy = scene.instantiate()
	enemy.position = position
	enemy.awake = true
	get_parent().add_child(enemy)
	queue_free()


func _draw() -> void:
	var left := clampf(_time_left / Config.balance.arena_spawn_time, 0.0, 1.0)
	draw_arc(Vector2.ZERO, maxf(START_RADIUS * left, 1.0), 0.0, TAU, 16, COLOR, RING_WIDTH)
