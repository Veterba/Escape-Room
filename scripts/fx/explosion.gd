## An explosion. One rule for all of them (Fuse Launcher, Gold Detonator, Fuse Kin, barrels):
## it damages every enemy and the player inside its radius, unless a wall is in the way.
## Only the Gold Detonator's blasts spare the player (hurts_player = false).
class_name Explosion
extends Node2D

const SCENE := preload("res://scenes/fx/explosion.tscn")
const FLASH_COLOR := Color("#F0B43C")
## Seconds the bright blast circle takes to fade.
const FLASH_FADE_TIME := 0.15
## Physics layer 1: walls. Only walls block a blast.
const WALL_MASK := 1

var radius := 0.0
## Damage to each enemy inside the radius. The player always loses one heart.
var enemy_damage := 0
var hurts_player := true


static func create(blast_radius: float, damage: int, damages_player: bool) -> Explosion:
	var explosion: Explosion = SCENE.instantiate()
	explosion.radius = blast_radius
	explosion.enemy_damage = damage
	explosion.hurts_player = damages_player
	return explosion


func _ready() -> void:
	for enemy: Enemy in get_tree().get_nodes_in_group(&"enemies"):
		if _reaches(enemy.hitbox_position()):
			enemy.take_damage(enemy_damage, enemy.global_position - global_position)
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player:
		if hurts_player and _reaches(player.hurtbox_position()):
			player.take_hit(player.global_position - global_position)
		player.camera.shake(Config.balance.explosion_shake)
	Audio.play_sfx(&"explosion")
	var fade := create_tween()
	fade.tween_property(self, "self_modulate:a", 0.0, FLASH_FADE_TIME)
	$Burst.finished.connect(queue_free)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, FLASH_COLOR)


## True if `point` is inside the radius and no wall stands between it and the centre.
func _reaches(point: Vector2) -> bool:
	if global_position.distance_to(point) > radius:
		return false
	var query := PhysicsRayQueryParameters2D.create(global_position, point, WALL_MASK)
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()
