## A player bullet: flies straight and damages the first enemy hitbox it touches. Bullets of
## blast guns explode instead, on an enemy or a wall.
class_name PlayerBullet
extends Area2D

const IMPACT_SPARK := preload("res://scenes/fx/impact_spark.tscn")

var _stats: GunStats
var _velocity := Vector2.ZERO
var _spent := false

@onready var _sprite: Sprite2D = $Sprite


func setup(direction: Vector2, gun: GunStats) -> void:
	_stats = gun
	_velocity = direction * Config.balance.player_bullet_speed
	rotation = direction.angle()


func _ready() -> void:
	_sprite.texture = _stats.bullet_texture
	body_entered.connect(_on_hit.unbind(1))  # Walls and chests: no damage.
	area_entered.connect(func(hitbox: Area2D) -> void: _on_hit(hitbox.owner as Enemy))


func _physics_process(delta: float) -> void:
	position += _velocity * delta


## `enemy` is null when the bullet hit a wall.
func _on_hit(enemy: Enemy = null) -> void:
	# A bullet can touch two things in one frame; it only ever hits the first.
	if _spent:
		return
	_spent = true
	if _stats.blast_radius > 0.0:
		var blast := Explosion.create(_stats.blast_radius, _stats.damage, true, _stats.blast_hurts_player)
		blast.global_position = global_position
		get_tree().current_scene.add_child.call_deferred(blast)
	else:
		if enemy:
			enemy.take_damage(_stats.damage, _velocity)
		var spark: Node2D = IMPACT_SPARK.instantiate()
		spark.global_position = global_position
		get_tree().current_scene.add_child.call_deferred(spark)
	queue_free()
