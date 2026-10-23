## Reusable "game feel" for any character: walk bob, footstep squash, roll dust, hit flash, puffs.
## Add it as a child node and point `sprite` at the character's AnimatedSprite2D.
class_name Juice
extends Node

const DUST_PUFF := preload("res://scenes/fx/dust_puff.tscn")
const DEATH_PUFF := preload("res://scenes/fx/death_puff.tscn")

## The sprite to animate. Its material must use shaders/hit_flash.gdshader for the hit flash.
@export var sprite: Node2D

var _rest_position: Vector2
## Counts footsteps: each whole number is one step.
var _step_phase := 0.0
var _scale_tween: Tween
var _flash_tween: Tween


func _ready() -> void:
	_rest_position = sprite.position


## Call every frame. Bobs the sprite up and down while moving, with a squash on each footstep.
func update_walk(delta: float, is_moving: bool) -> void:
	if not is_moving:
		_step_phase = 0.0
		sprite.position = _rest_position
		return
	var previous_step := int(_step_phase)
	_step_phase += delta * Config.balance.walk_step_rate
	var lift := absf(sin(PI * _step_phase)) * Config.balance.walk_bob_height
	sprite.position = _rest_position - Vector2(0.0, roundf(lift))
	if int(_step_phase) != previous_step:
		squash(Config.balance.footstep_squash)


## Squeezes the sprite wide and short, then springs it back.
func squash(amount: float) -> void:
	if _scale_tween:
		_scale_tween.kill()
	sprite.scale = Vector2(1.0 + amount, 1.0 - amount)
	_scale_tween = create_tween()
	_scale_tween.tween_property(sprite, "scale", Vector2.ONE, Config.balance.squash_return_time)


## A dust puff at the start of a roll and another one `duration` seconds later, at its end.
## (The roll itself is drawn frame by frame, without spinning.)
func play_roll(duration: float) -> void:
	spawn_dust()
	get_tree().create_timer(duration, false).timeout.connect(spawn_dust)


## Turns the sprite white for a moment.
func hit_flash() -> void:
	var material := sprite.material as ShaderMaterial
	if _flash_tween:
		_flash_tween.kill()
	material.set_shader_parameter(&"flash_amount", 1.0)
	_flash_tween = create_tween()
	_flash_tween.tween_interval(Config.balance.hit_flash_time)
	_flash_tween.tween_callback(material.set_shader_parameter.bind(&"flash_amount", 0.0))


func spawn_dust() -> void:
	_spawn_at_feet(DUST_PUFF)


func spawn_death_puff() -> void:
	_spawn_at_feet(DEATH_PUFF)


func _spawn_at_feet(scene: PackedScene) -> void:
	var puff: Node2D = scene.instantiate()
	puff.global_position = (get_parent() as Node2D).global_position
	get_tree().current_scene.add_child(puff)
