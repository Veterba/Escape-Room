## An enemy bullet: big and round, flies straight, costs the player a heart. It passes through
## a player who is invulnerable (rolling, or just hit), as in Enter the Gungeon.
class_name EnemyBullet
extends Area2D

const IMPACT_SPARK := preload("res://scenes/fx/impact_spark.tscn")
## Its picture has two frames; it shimmers between them this many times a second.
const SHIMMER_FRAMES := 2
const SHIMMER_RATE := 10.0

var _velocity := Vector2.ZERO
var _time := 0.0

@onready var _sprite: Sprite2D = $Sprite


func setup(direction: Vector2, speed: float) -> void:
	_velocity = direction.normalized() * speed


func _ready() -> void:
	_sprite.hframes = SHIMMER_FRAMES
	body_entered.connect(_on_wall_hit)
	area_entered.connect(_on_hurtbox_entered)


func _physics_process(delta: float) -> void:
	position += _velocity * delta
	_time += delta
	_sprite.frame = int(_time * SHIMMER_RATE) % SHIMMER_FRAMES


## Removes the bullet with a small spark (also used by the smoke bomb).
func pop() -> void:
	var spark: Node2D = IMPACT_SPARK.instantiate()
	spark.global_position = global_position
	get_tree().current_scene.add_child.call_deferred(spark)
	queue_free()


func _on_wall_hit(_body: Node2D) -> void:
	pop()


func _on_hurtbox_entered(hurtbox: Area2D) -> void:
	var player := hurtbox.owner as Player
	if player.is_invulnerable():
		return
	player.take_hit(_velocity)
	queue_free()
