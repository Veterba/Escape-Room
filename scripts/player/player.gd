## The player: walks, aims, shoots, rolls, switches guns, uses things with E, throws smoke bombs,
## and loses hearts when hit.
class_name Player
extends CharacterBody2D

signal hearts_changed(hearts: int)
signal smoke_bombs_changed(count: int)
## Lost a heart.
signal hurt
signal died

enum State { NORMAL, ROLLING, DEAD }

## The gun is drawn behind the hero when the aim points up more steeply than this (-0.5 = 30 degrees).
const AIM_UP_BEHIND_THRESHOLD := -0.5
const SMOKE_PUFF := preload("res://scenes/fx/death_puff.tscn")

var state := State.NORMAL
var hearts: int = Config.balance.player_hearts
var smoke_bombs: int = Config.balance.smoke_bombs_start

var _roll_direction := Vector2.ZERO
var _roll_elapsed := 0.0
var _roll_cooldown_left := 0.0
var _hit_invulnerable_left := 0.0
var _knockback := Vector2.ZERO

@onready var body: AnimatedSprite2D = $Body
@onready var juice: Juice = $Juice
@onready var gun_pivot: Node2D = $GunPivot
@onready var gun: Gun = $GunPivot/Gun
@onready var guns: GunInventory = $Guns
@onready var camera: GameCamera = $Camera
@onready var _interactor: Interactor = $Interactor


func _ready() -> void:
	gun.holder = self
	guns.setup(gun, Config.balance.pop_pistol)


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	_roll_cooldown_left = maxf(_roll_cooldown_left - delta, 0.0)
	_update_hit_invulnerability(delta)
	if state == State.ROLLING:
		_update_roll(delta)
	else:
		_update_normal(delta)
	velocity += _knockback
	_knockback = _knockback.move_toward(Vector2.ZERO, Config.balance.knockback_decay * delta)
	move_and_slide()


## True while the player cannot be hurt: early in a roll, just after a hit, or dead.
func is_invulnerable() -> bool:
	var early_in_roll := state == State.ROLLING and _roll_elapsed < Config.balance.roll_invulnerable_time
	return state == State.DEAD or _hit_invulnerable_left > 0.0 or early_in_roll


## Where enemies aim: the middle of the hero's body.
func hurtbox_position() -> Vector2:
	return $Hurtbox/Shape.global_position


## Costs one heart unless invulnerable. `from_direction` is where the hit pushes the player.
## Returns true if a heart was lost.
func take_hit(from_direction: Vector2) -> bool:
	if is_invulnerable():
		return false
	var cfg := Config.balance
	hearts -= 1
	hurt.emit()
	hearts_changed.emit(hearts)
	juice.hit_flash()
	camera.shake(cfg.hit_shake)
	_knockback = from_direction.normalized() * cfg.player_knockback_speed
	_interactor.cancel()
	Audio.play_sfx(&"player_hit")
	if hearts <= 0:
		_die()
	else:
		_hit_invulnerable_left = cfg.hit_invulnerable_time
	return true


## Heals one heart. Returns false if hearts are already full.
func heal() -> bool:
	if state == State.DEAD or hearts >= Config.balance.player_hearts:
		return false
	hearts += 1
	hearts_changed.emit(hearts)
	return true


## Starts a dodge roll in `direction`. Returns false if a roll is running or on cooldown.
func start_roll(direction: Vector2) -> bool:
	if state != State.NORMAL or _roll_cooldown_left > 0.0:
		return false
	state = State.ROLLING
	_roll_direction = direction.normalized()
	_roll_elapsed = 0.0
	gun_pivot.visible = false  # Hands and gun are hidden mid-roll, as in Enter the Gungeon.
	body.play(&"roll")
	juice.play_roll(Config.balance.roll_duration, _roll_direction)
	Audio.play_sfx(&"roll")
	return true


## Throws a smoke bomb: every enemy bullet on screen disappears. Returns false if none are left.
func use_smoke_bomb() -> bool:
	if smoke_bombs == 0:
		return false
	smoke_bombs -= 1
	smoke_bombs_changed.emit(smoke_bombs)
	var view_size := get_viewport_rect().size / camera.zoom
	var view := Rect2(camera.get_screen_center_position() - view_size / 2.0, view_size)
	for bullet: EnemyBullet in get_tree().get_nodes_in_group(&"enemy_bullets"):
		if view.has_point(bullet.global_position):
			bullet.pop()
	var puff: Node2D = SMOKE_PUFF.instantiate()
	puff.global_position = global_position
	get_tree().current_scene.add_child(puff)
	Audio.play_sfx(&"smoke_bomb")
	return true


func _update_normal(delta: float) -> void:
	var input := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var is_moving := input != Vector2.ZERO
	velocity = input * Config.balance.player_move_speed
	var aim := _aim_at(get_global_mouse_position())
	body.play(&"walk" if is_moving else &"idle")
	juice.update_walk(delta, is_moving)
	_interactor.update(delta, self, Input.is_action_pressed(&"interact"))

	if Input.is_action_just_pressed(&"roll"):
		# Roll where the player is walking; standing still, roll towards the mouse.
		start_roll(input if is_moving else aim)
	elif Input.is_action_pressed(&"shoot"):
		gun.try_fire()
	if Input.is_action_just_pressed(&"reload"):
		gun.start_reload()
	if Input.is_action_just_pressed(&"smoke_bomb"):
		use_smoke_bomb()
	_handle_gun_switching()


func _handle_gun_switching() -> void:
	if Input.is_action_just_pressed(&"next_gun"):
		guns.cycle(1)
	elif Input.is_action_just_pressed(&"previous_gun"):
		guns.cycle(-1)
	for slot in Config.balance.gun_slots:
		if Input.is_action_just_pressed(StringName("gun_%d" % (slot + 1))):
			guns.select(slot)


func _update_roll(delta: float) -> void:
	var cfg := Config.balance
	_roll_elapsed += delta
	velocity = _roll_direction * cfg.roll_distance / cfg.roll_duration
	if _roll_elapsed >= cfg.roll_duration:
		state = State.NORMAL
		_roll_cooldown_left = cfg.roll_cooldown
		gun_pivot.visible = true


## Counts down the invulnerability after a hit, blinking the hero while it lasts.
func _update_hit_invulnerability(delta: float) -> void:
	if _hit_invulnerable_left <= 0.0:
		return
	_hit_invulnerable_left = maxf(_hit_invulnerable_left - delta, 0.0)
	var blink_phase := fmod(_hit_invulnerable_left * Config.balance.hit_blink_rate, 1.0)
	body.visible = _hit_invulnerable_left == 0.0 or blink_phase >= 0.5


func _die() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	gun_pivot.visible = false
	body.play(&"die")
	body.visible = false
	juice.spawn_death_puff()
	died.emit()


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
