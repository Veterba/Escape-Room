## An explosion: damages what is inside its radius once, shakes the camera and shows a burst.
class_name Explosion
extends Node2D

const SCENE := preload("res://scenes/fx/explosion.tscn")
const FLASH_COLOR := Color("#F0B43C")
## Seconds the bright blast circle takes to fade.
const FLASH_FADE_TIME := 0.15

var radius := 0.0
## Damage to each enemy inside the radius.
var enemy_damage := 0
var hurts_enemies := true
## If true, the player inside the radius loses a heart (unless invulnerable).
var hurts_player := false


static func create(blast_radius: float, damage: int, damages_enemies: bool, damages_player: bool) -> Explosion:
	var explosion: Explosion = SCENE.instantiate()
	explosion.radius = blast_radius
	explosion.enemy_damage = damage
	explosion.hurts_enemies = damages_enemies
	explosion.hurts_player = damages_player
	return explosion


func _ready() -> void:
	if hurts_enemies:
		for enemy: Enemy in get_tree().get_nodes_in_group(&"enemies"):
			if _reaches(enemy):
				enemy.take_damage(enemy_damage, enemy.global_position - global_position)
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player:
		if hurts_player and _reaches(player):
			player.take_hit(player.global_position - global_position)
		player.camera.shake(Config.balance.explosion_shake)
	Audio.play_sfx(&"explosion")
	var fade := create_tween()
	fade.tween_property(self, "self_modulate:a", 0.0, FLASH_FADE_TIME)
	$Burst.finished.connect(queue_free)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, FLASH_COLOR)


func _reaches(target: Node2D) -> bool:
	return global_position.distance_to(target.global_position) <= radius
