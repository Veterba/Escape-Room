## One of Root's five error windows, fighting on its own in phase 3 (Build Spec 8.1). It flies
## off to its spot, then floats, keeping 70-110 px from the player. Every 2.1-2.9 s it fires one
## aimed bullet; its title bar flashes for 0.4 s first. Every 3.5-6 s it teleports on its own
## (closing and opening like a window). It flies over walls and pillars; its bullets stop at
## walls. Destroyed, it bursts into falling pixels, is gone for 6 s and comes back.
## Its hit points are its own: damage to it never counts towards Root's.
## Looks: its window with a red title bar, its content turning to static now and then.
class_name ErrorWindow
extends Enemy

enum State { FLY, FLOAT, TELEPORT_OUT, GONE, TELEPORT_IN, BURST, AWAY }

const WING_BULLET := preload("res://scenes/enemies/wing_bullet.tscn")
const RED_WINDOWS: Array[Texture2D] = [
	preload("res://art/game/root/window_1_red.png"), preload("res://art/game/root/window_2_red.png"),
	preload("res://art/game/root/window_3_red.png"), preload("res://art/game/root/window_4_red.png"),
	preload("res://art/game/root/window_5_red.png"),
]
const STATIC_WINDOWS: Array[Texture2D] = [
	preload("res://art/game/root/window_1_static.png"), preload("res://art/game/root/window_2_static.png"),
	preload("res://art/game/root/window_3_static.png"), preload("res://art/game/root/window_4_static.png"),
	preload("res://art/game/root/window_5_static.png"),
]
const STATIC_FRAMES := 4
## Its content may turn to static this many times a second, with this chance; the static
## flickers this many frames a second.
const STATIC_CHECKS := 3.0
const STATIC_CHANCE := 0.45
const STATIC_RATE := 12.0
## Flying off from Root: share of the way to its spot per second.
const FLY_FOLLOW := 3.0
## It keeps its distance from a point this far above the player's feet.
const ABOVE_PLAYER := Vector2(0, -40)
## A gentle sway on top of its movement: pixels per second and how fast.
const SWAY := 6.0
const SWAY_SPEED := Vector2(1.7, 1.3)
## It bobs this many pixels, this fast.
const BOB := 1.5
const BOB_SPEED := 2.2
## The title bar flashes this many times a second in the warning before a shot.
const WARNING_FLASH_RATE := 12.0
## Seconds it shows white after a hit.
const HIT_FLASH_TIME := 0.08
## Destroyed: seconds it bursts, the pieces, how far they fly and how far they fall.
const BURST_TIME := 0.45
const BURST_PIECES := 10
const BURST_REACH := 20.0
const BURST_FALL := 10.0
const BURST_COLORS: Array[Color] = [Color("#b62649"), Color("#0d1822")]
## Its shadow: half width and height, how far below its middle, and how dark.
const SHADOW := Vector2(8, 2)
const SHADOW_AT := Vector2(0, 16)
const SHADOW_COLOR := Color(0, 0, 0, 0.3)
## Tries to find a landing spot far enough from the player.
const SPOT_TRIES := 40

## Which of Root's windows it is (1-5).
var index := 1
## Root's room: it stays inside it.
var room: Room
## Where it flies to when Root splits.
var fly_to := Vector2.ZERO
var state := State.FLY
var _state_time := 0.0
var _time := 0.0
var _fire_left := 0.0
var _teleport_left := 0.0
var _flash_left := 0.0
var _static := false
## Gone for good once Root is dead.
var _vanishing := false
var _burst_pieces: Array[Vector2] = []

@onready var _hitbox: CollisionShape2D = $Hitbox/Shape
@onready var _glow: PointLight2D = $Glow


func _ready() -> void:
	var cfg := Config.balance
	hp = cfg.error_window_hp
	awake = true
	eye_offset = Vector2.ZERO
	_fire_left = randf_range(cfg.error_window_fire_min, cfg.error_window_fire_max)
	_teleport_left = randf_range(cfg.error_window_teleport_min, cfg.error_window_teleport_max)
	var spec := Config.lighting.error_window_glow
	_glow.texture = RoomLight.GLOW
	_glow.color = spec.color
	_glow.texture_scale = spec.radius / (RoomLight.GLOW.get_width() / 2.0)


## True while it can be hit: flying off or floating.
func is_hittable() -> bool:
	return state == State.FLY or state == State.FLOAT


func take_damage(amount: int, _direction: Vector2) -> void:
	if not is_hittable():
		return
	hp -= amount
	_flash_left = HIT_FLASH_TIME
	if hp <= 0:
		_burst()


## Root is dead: it bursts and is gone for good.
func vanish() -> void:
	_vanishing = true
	_burst()


func _physics_process(delta: float) -> void:
	var cfg := Config.balance
	_time += delta
	_state_time += delta
	_flash_left -= delta
	var player := target_player()
	match state:
		State.FLY:
			position += (fly_to - position) * minf(1.0, delta * FLY_FOLLOW)
			if _state_time >= cfg.root_split_time:
				_set_state(State.FLOAT)
		State.FLOAT:
			if player:
				_float(delta, player)
		State.TELEPORT_OUT:
			if _state_time >= cfg.error_window_teleport_out_time:
				_set_state(State.GONE)
		State.GONE:
			if _state_time >= cfg.error_window_teleport_gone_time:
				_land(player)
				_set_state(State.TELEPORT_IN)
		State.TELEPORT_IN:
			if _state_time >= cfg.error_window_teleport_in_time:
				_teleport_left = randf_range(cfg.error_window_teleport_min, cfg.error_window_teleport_max)
				_set_state(State.FLOAT)
		State.BURST:
			if _state_time >= BURST_TIME:
				if _vanishing:
					queue_free()
					return
				_set_state(State.AWAY)
		State.AWAY:
			if _state_time >= cfg.error_window_return_time:
				hp = cfg.error_window_hp
				_land(player)
				_set_state(State.TELEPORT_IN)
	if int(_time * STATIC_CHECKS) != int((_time - delta) * STATIC_CHECKS):
		_static = randf() < STATIC_CHANCE
	_glow.energy = Config.lighting.error_window_glow.energy * _open()
	queue_redraw()


## Keeps its distance from the player, shoots now and then, and teleports now and then.
func _float(delta: float, player: Player) -> void:
	var cfg := Config.balance
	var target := player.global_position + ABOVE_PLAYER
	var distance := global_position.distance_to(target)
	var want := 0.0
	if distance > cfg.error_window_max_distance:
		want = 1.0
	elif distance < cfg.error_window_min_distance:
		want = -1.0
	var sway := Vector2(sin(_time * SWAY_SPEED.x + index), cos(_time * SWAY_SPEED.y + index)) * SWAY
	position += (global_position.direction_to(target) * want * cfg.error_window_speed + sway) * delta
	if room:
		var inside := room.inside_area()
		position = position.clamp(inside.position, inside.end)
	_fire_left -= delta
	if _fire_left <= 0.0:
		_fire_left = randf_range(cfg.error_window_fire_min, cfg.error_window_fire_max)
		shoot(global_position.direction_to(player.hurtbox_position()), cfg.error_window_bullet_speed, WING_BULLET)
	_teleport_left -= delta
	if _teleport_left <= 0.0:
		_set_state(State.TELEPORT_OUT)


## Comes back at a random point in the room, far enough from the player.
func _land(player: Player) -> void:
	if room == null:
		return
	var inside := room.inside_area()
	var spot := position
	for i in SPOT_TRIES:
		spot = Vector2(randf_range(inside.position.x, inside.end.x), randf_range(inside.position.y, inside.end.y))
		if player == null or spot.distance_to(player.global_position) >= Config.balance.error_window_teleport_min_distance:
			break
	position = spot
	reset_physics_interpolation()  # A jump, not a fast move.


func _burst() -> void:
	_burst_pieces.clear()
	for i in BURST_PIECES:
		_burst_pieces.append(Vector2.from_angle(randf() * TAU) * randf() * BURST_REACH)
	_set_state(State.BURST)


func _set_state(new_state: State) -> void:
	state = new_state
	_state_time = 0.0
	_hitbox.set_deferred(&"disabled", not is_hittable())


## How open its window is: 1 whole, 0 closed.
func _open() -> float:
	var cfg := Config.balance
	match state:
		State.TELEPORT_OUT:
			return 1.0 - _state_time / cfg.error_window_teleport_out_time
		State.TELEPORT_IN:
			return _state_time / cfg.error_window_teleport_in_time
		State.GONE, State.BURST, State.AWAY:
			return 0.0
	return 1.0


func _draw() -> void:
	if state == State.BURST:
		var k := _state_time / BURST_TIME
		for i in _burst_pieces.size():
			var at := _burst_pieces[i] * k + Vector2(0, k * k * BURST_FALL)
			draw_rect(Rect2(at.round(), Vector2(2, 2)), BURST_COLORS[i % 2])
		return
	var open := _open()
	if open <= 0.0:
		return
	draw_set_transform(SHADOW_AT, 0.0, Vector2(SHADOW.x * open, SHADOW.y))
	draw_circle(Vector2.ZERO, 1.0, SHADOW_COLOR)
	draw_set_transform(Vector2.ZERO)
	var texture := RED_WINDOWS[index - 1]
	var at := Vector2(0, roundf(sin(_time * BOB_SPEED + index) * BOB))
	var warning := state == State.FLOAT and _fire_left < Config.balance.error_window_warning_time
	var flash := warning and int(_time * WARNING_FLASH_RATE) % 2 == 0
	if _static and not flash and open >= 1.0 and _flash_left <= 0.0:
		_draw_static(at)
		return
	RootWindow.draw(self, texture, at, open, flash, _flash_left > 0.0)


## One frame of its static strip, in place of its window.
func _draw_static(at: Vector2) -> void:
	var strip := STATIC_WINDOWS[index - 1]
	var size := Vector2(strip.get_width() / float(STATIC_FRAMES), strip.get_height())
	var frame := int(_time * STATIC_RATE) % STATIC_FRAMES
	draw_texture_rect_region(strip, Rect2((at - size / 2.0).round(), size), Rect2(Vector2(frame * size.x, 0), size))
