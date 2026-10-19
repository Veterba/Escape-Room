## The player: walks with WASD, aims at the mouse, shoots, reloads and dodge rolls.
class_name Player
extends CharacterBody2D

enum State { NORMAL, ROLLING }

## The gun is drawn behind the hero when the aim points up more steeply than this (-0.5 = 30 degrees).
const AIM_UP_BEHIND_THRESHOLD := -0.5

var state := State.NORMAL
var hearts: int = Config.balance.player_hearts
var smoke_bombs: int = Config.balance.smoke_bombs_start

var _roll_direction := Vector2.ZERO
var _roll_elapsed := 0.0
var _roll_cooldown_left := 0.0

@onready var body: AnimatedSprite2D = $Body
@onready var juice: Juice = $Juice
@onready var gun_pivot: Node2D = $GunPivot
@onready var gun: Gun = $GunPivot/Gun
@onready var camera: GameCamera = $Camera


func _ready() -> void:
	gun.holder = self
	gun.equip(Config.balance.pop_pistol)


func _physics_process(delta: float) -> void:
	_roll_cooldown_left = maxf(_roll_cooldown_left - delta, 0.0)
	if state == State.ROLLING:
		_update_roll(delta)
	else:
		_update_normal(delta)
	move_and_slide()


## True while the player cannot be hurt: the first part of a roll.
func is_invulnerable() -> bool:
	return state == State.ROLLING and _roll_elapsed < Config.balance.roll_invulnerable_time


## Starts a dodge roll in `direction`. Returns false if a roll is running or on cooldown.
func start_roll(direction: Vector2) -> bool:
	if state == State.ROLLING or _roll_cooldown_left > 0.0:
		return false
	state = State.ROLLING
	_roll_direction = direction.normalized()
	_roll_elapsed = 0.0
	gun_pivot.visible = false  # Hands and gun are hidden mid-roll, as in Enter the Gungeon.
	body.play(&"roll")
	juice.play_roll(Config.balance.roll_duration, _roll_direction)
	Audio.play_sfx(&"roll")
	return true


func _update_normal(delta: float) -> void:
	var input := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var is_moving := input != Vector2.ZERO
	velocity = input * Config.balance.player_move_speed
	var aim := _aim_at(get_global_mouse_position())
	body.play(&"walk" if is_moving else &"idle")
	juice.update_walk(delta, is_moving)

	if Input.is_action_just_pressed(&"roll"):
		# Roll where the player is walking; standing still, roll towards the mouse.
		start_roll(input if is_moving else aim)
	elif Input.is_action_pressed(&"shoot"):
		gun.try_fire()
	if Input.is_action_just_pressed(&"reload"):
		gun.start_reload()


func _update_roll(delta: float) -> void:
	var cfg := Config.balance
	_roll_elapsed += delta
	velocity = _roll_direction * cfg.roll_distance / cfg.roll_duration
	if _roll_elapsed >= cfg.roll_duration:
		state = State.NORMAL
		_roll_cooldown_left = cfg.roll_cooldown
		gun_pivot.visible = true


## Turns the hero and the gun towards `target`. Returns the aim direction.
func _aim_at(target: Vector2) -> Vector2:
	var aim := (target - gun_pivot.global_position).normalized()
	var aiming_left := aim.x < 0.0
	gun_pivot.rotation = aim.angle()
	# Flipping the pivot upside down keeps the gun right side up when aiming left.
	gun_pivot.scale.y = -1.0 if aiming_left else 1.0
	# When aiming steeply up, the gun is drawn behind the hero.
	gun_pivot.z_index = -1 if aim.y < AIM_UP_BEHIND_THRESHOLD else 1
	body.flip_h = aiming_left
	return aim
