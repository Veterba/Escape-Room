## A player bullet: flies straight and bursts into sparks when it hits a wall.
class_name PlayerBullet
extends Area2D

const IMPACT_SPARK := preload("res://scenes/fx/impact_spark.tscn")

var damage := 0
var _velocity := Vector2.ZERO


func setup(direction: Vector2, bullet_damage: int) -> void:
	_velocity = direction * Config.balance.player_bullet_speed
	damage = bullet_damage
	rotation = direction.angle()


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += _velocity * delta


func _on_body_entered(_body: Node2D) -> void:
	var spark: Node2D = IMPACT_SPARK.instantiate()
	spark.global_position = global_position
	get_tree().current_scene.add_child(spark)
	queue_free()
