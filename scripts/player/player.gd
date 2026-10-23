## The player: walks, aims, shoots, rolls, switches guns, uses things with E, throws smoke bombs,
## loses hearts when hit, and can be handcuffed by an Officer Kin (mash E to break free).
##
## He is Telly, a walking TV (the approved hero design). His look: the front view when aiming
## down or level, the back view when aiming up, the whole sprite mirrored when aiming left. One
## hand holds the gun at the corner of the box on the aiming side, placed by the HeroRig. The
## screen is his face: shouting, the reload bar and X eyes are drawn over it. Rolling, only the
## TV tumbles, with a small hop.
class_name Player
extends CharacterBody2D

signal hearts_changed(hearts: int)
signal smoke_bombs_changed(count: int)
## Lost a heart.
signal hurt
signal died
## Handcuffed by an Officer Kin.
signal trapped
## Broke free from the handcuffs.
signal escaped
## While handcuffed: presses of E still needed to break free.
signal presses_left_changed(presses_left: int)

enum State { NORMAL, ROLLING, DEAD, TRAPPED }

## Pixels from the middle of a 24x24 frame to its top-left corner.
const FRAME_HALF := Vector2(12, 12)
const SMOKE_PUFF := preload("res://scenes/fx/death_puff.tscn")
const SMOKE_WAVE := preload("res://scenes/fx/smoke_wave.tscn")
## The knife slash when breaking free: how far it swings, in radians, and in how many seconds.
const KNIFE_SLASH_ARC := PI
const KNIFE_SLASH_TIME := 0.2
## How much each press of E squashes the hero while trapped.
const MASH_SQUASH := 0.1

## Where the hand sits, the gun's kick and tip, the faces and the roll hop.
@export var rig: HeroRig

var state := State.NORMAL
var hearts: int = Config.balance.player_hearts
var smoke_bombs: int = Config.balance.smoke_bombs_start

var _roll_direction := Vector2.ZERO
var _roll_elapsed := 0.0
var _roll_cooldown_left := 0.0
var _hit_invulnerable_left := 0.0
var _knockback := Vector2.ZERO
## Presses of E still needed to break free, and the officer who did it.
var _presses_left := 0
var _trapped_by: OfficerKin
## Seconds in which officers cannot trap the player again.
var _officer_immunity_left := 0.0
## Where the hero aims (a unit vector), and how his look follows it.
var _aim := Vector2.RIGHT
var _aiming_left := false
var _back_view := false
## Pixels the gun and the hand are pushed back by the last shot; it fades to 0.
var _recoil := 0.0
## Seconds left of the shouting face and of the X eyes.
var _shout_left := 0.0
var _hurt_left := 0.0
## Where the body sprite rests (the roll lifts it for the hop).
var _body_rest := Vector2.ZERO

@onready var body: AnimatedSprite2D = $Body
@onready var juice: Juice = $Juice
@onready var face: Sprite2D = $Face
@onready var arm: Node2D = $Arm
@onready var gun_pivot: Node2D = $Arm/GunPivot
@onready var gun: Gun = $Arm/GunPivot/Gun
@onready var guns: GunInventory = $Guns
@onready var camera: GameCamera = $Camera
@onready var _interactor: Interactor = $Interactor
@onready var _knife: Sprite2D = $Knife


func _ready() -> void:
	gun.holder = self
	guns.setup(gun, Config.balance.pop_pistol)
	gun.fired.connect(_on_fired)
	_body_rest = body.position


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	_roll_cooldown_left = maxf(_roll_cooldown_left - delta, 0.0)
	_officer_immunity_left = maxf(_officer_immunity_left - delta, 0.0)
	_update_hit_invulnerability(delta)
	if state == State.TRAPPED:
		velocity = Vector2.ZERO
		if Input.is_action_just_pressed(&"interact"):
			mash()
	elif state == State.ROLLING:
		_update_roll(delta)
	else:
		_update_normal(delta)
	if state != State.ROLLING and state != State.DEAD:
		_place_arm(delta)
	_update_face(delta)
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
	_hurt_left = rig.hurt_face_time
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


## Picks up a smoke bomb. Returns false if the player already carries the most allowed.
func add_smoke_bomb() -> bool:
	if smoke_bombs >= Config.balance.smoke_bombs_max:
		return false
	smoke_bombs += 1
	smoke_bombs_changed.emit(smoke_bombs)
	return true


## Handcuffs the player: no moving, shooting or rolling until E is pressed 10 times. Returns
## false if that cannot happen now (rolling, dead, already trapped, or just broke free).
func trap(officer: OfficerKin) -> bool:
	if state != State.NORMAL or _officer_immunity_left > 0.0:
		return false
	state = State.TRAPPED
	_presses_left = Config.balance.trap_presses
	_trapped_by = officer
	body.play(&"idle_back" if _back_view else &"idle")
	trapped.emit()
	presses_left_changed.emit(_presses_left)
	return true


## One press of E while trapped. The last one breaks the handcuffs with a knife slash, which
## stuns the officer and throws him back, and keeps officers off the player for a moment.
## No heart is lost.
func mash() -> void:
	if state != State.TRAPPED:
		return
	_presses_left -= 1
	juice.squash(MASH_SQUASH)
	presses_left_changed.emit(_presses_left)
	if _presses_left > 0:
		return
	state = State.NORMAL
	_officer_immunity_left = Config.balance.trap_immunity_time
	if is_instance_valid(_trapped_by):
		_trapped_by.stun(_trapped_by.global_position - global_position)
	_slash_knife()
	Audio.play_sfx(&"knife_slash")
	escaped.emit()


## Starts a dodge roll in `direction`. Returns false if a roll is running or on cooldown.
func start_roll(direction: Vector2) -> bool:
	if state != State.NORMAL or _roll_cooldown_left > 0.0:
		return false
	state = State.ROLLING
	_roll_direction = direction.normalized()
	_roll_elapsed = 0.0
	arm.visible = false  # Only the TV rolls: no body, legs, hand or gun.
	body.animation = &"roll"
	body.flip_h = _roll_direction.x < 0.0
	juice.play_roll(Config.balance.roll_duration)
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
	for effect: PackedScene in [SMOKE_PUFF, SMOKE_WAVE]:
		var node: Node2D = effect.instantiate()
		node.global_position = global_position
		get_tree().current_scene.add_child(node)
	camera.shake(Config.balance.hit_shake)
	Audio.play_sfx(&"smoke_bomb")
	return true


func _update_normal(delta: float) -> void:
	var input := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var is_moving := input != Vector2.ZERO
	velocity = input * Config.balance.player_move_speed
	var aim := _aim_at(get_global_mouse_position())
	_play_body(is_moving)
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


## The 5 tumble frames are spread over the roll's time, and the TV hops up and down once.
func _update_roll(delta: float) -> void:
	var cfg := Config.balance
	_roll_elapsed += delta
	velocity = _roll_direction * cfg.roll_distance / cfg.roll_duration
	var progress := clampf(_roll_elapsed / cfg.roll_duration, 0.0, 1.0)
	var frames := body.sprite_frames.get_frame_count(&"roll")
	body.frame = mini(int(progress * frames), frames - 1)
	body.position = _body_rest - Vector2(0.0, roundf(sin(progress * PI) * rig.roll_hop))
	if _roll_elapsed >= cfg.roll_duration:
		state = State.NORMAL
		_roll_cooldown_left = cfg.roll_cooldown
		body.position = _body_rest
		arm.visible = true


## Counts down the invulnerability after a hit, blinking the hero while it lasts.
func _update_hit_invulnerability(delta: float) -> void:
	if _hit_invulnerable_left <= 0.0:
		return
	_hit_invulnerable_left = maxf(_hit_invulnerable_left - delta, 0.0)
	var blink_phase := fmod(_hit_invulnerable_left * Config.balance.hit_blink_rate, 1.0)
	body.visible = _hit_invulnerable_left == 0.0 or blink_phase >= 0.5


func _slash_knife() -> void:
	_knife.visible = true
	_knife.rotation = -KNIFE_SLASH_ARC / 2.0
	var slash := create_tween()
	slash.tween_property(_knife, "rotation", KNIFE_SLASH_ARC / 2.0, KNIFE_SLASH_TIME)
	slash.tween_callback(_knife.hide)


## Static on the screen, the screen goes dark, then he falls over sideways.
func _die() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	arm.visible = false
	face.visible = false
	body.position = _body_rest
	body.visible = true
	body.play(&"die")
	died.emit()


## Turns the hero towards `target`: front or back view, mirrored when aiming left. Returns the
## aim direction.
func _aim_at(target: Vector2) -> Vector2:
	_aim = (target - (global_position + rig.aim_origin)).normalized()
	if _aim == Vector2.ZERO:
		_aim = Vector2.RIGHT
	_aiming_left = _aim.x < 0.0
	_back_view = _aim.y < rig.back_view_below
	body.flip_h = _aiming_left
	return _aim


## Walking or standing, in the front or the back view. While a face is drawn over the screen and
## he stands still, the body holds its first idle frame, so the face sits right on the screen.
func _play_body(is_moving: bool) -> void:
	if is_moving:
		body.play(&"walk_back" if _back_view else &"walk")
	elif _face_texture() != null and not _back_view:
		body.animation = &"idle"
		body.stop()
	else:
		body.play(&"idle_back" if _back_view else &"idle")


## Puts the hand on the corner of the box on the aiming side and turns the gun around it.
## Front view: by the lower corner, the gun in front. Back view: by the ear, the gun behind the
## body. A shot pushes hand and gun back and kicks the muzzle up; a reload tips the muzzle up and
## back down. Aiming left, the gun is flipped so it is never upside down.
func _place_arm(delta: float) -> void:
	var cfg := Config.balance
	_recoil = move_toward(_recoil, 0.0, cfg.recoil_kick / cfg.recoil_return_time * delta)
	var side := -1.0 if _aiming_left else 1.0
	var spot := rig.back_hand if _back_view else rig.front_hand
	var hand := _body_rest + Vector2(spot.x * side, spot.y) + _aim * rig.hand_orbit - _aim * _recoil
	arm.position = hand.round()
	var tip := _recoil * rig.kick_per_pixel + sin(gun.reload_progress() * PI) * rig.reload_tip
	gun_pivot.rotation = _aim.angle() - side * tip
	gun_pivot.scale.y = side
	# Behind the body by being drawn before it (a z_index would also lift it above walls).
	if _back_view != (arm.get_index() < body.get_index()):
		move_child(arm, body.get_index() if _back_view else face.get_index() + 1)


## The face drawn over the screen right now: X eyes after a hit, the loading bar while reloading,
## the shout just after a shot, or none (the body frame's own face).
func _face_texture() -> Texture2D:
	if _hurt_left > 0.0:
		return rig.hurt_face
	if gun.is_reloading:
		var count := rig.reload_faces.size()
		return rig.reload_faces[mini(int(gun.reload_progress() * count), count - 1)]
	if _shout_left > 0.0:
		return rig.shout_face
	return null


func _update_face(delta: float) -> void:
	_shout_left = maxf(_shout_left - delta, 0.0)
	_hurt_left = maxf(_hurt_left - delta, 0.0)
	var texture := _face_texture()
	var shows := texture != null and not _back_view and body.visible
	face.visible = shows and (state == State.NORMAL or state == State.TRAPPED)
	if not face.visible:
		return
	face.texture = texture
	face.flip_h = _aiming_left
	var left := rig.face_cell.x
	if _aiming_left:
		left = FRAME_HALF.x * 2.0 - rig.face_cell.x - texture.get_width()
	var dip := 0
	if body.animation == &"walk":
		dip = rig.walk_dip[body.frame]
	face.position = _body_rest - FRAME_HALF + Vector2(left, rig.face_cell.y + dip)


func _on_fired(_stats: GunStats) -> void:
	_recoil = Config.balance.recoil_kick
	_shout_left = rig.shout_face_time
