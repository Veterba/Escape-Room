## Root, the boss of the Boss Chamber (Build Spec 8.1; its look: retexture spec, "Approved boss:
## Root"). A main window with one huge eye, five error windows under it that make its cloak, a
## crown of three cursors and two cursors for hands. It draws itself from these parts: each
## error window follows its place with a delay, so the cloak trails behind when Root glides.
## Phase 1 (above 66 %): glides to a new point in the upper half of the room every 2.2-3.7 s,
##   and fires Belt Lash, two sweeping arcs of bullets, every 3 s.
## Phase 2 (66-33 %): also Bullet Rain, a ring of 16, every 4 s, and a teleport every 6 s that
##   ends with Bullet Rain.
## Phase 3 (below 33 %): everything 1.3 times faster. The error windows fly off and fight on
##   their own (ErrorWindow); the main window teleports every 3.5 s, fires a ring of 12 after
##   each teleport and an aimed burst of 3 every 1.6 s.
## It roars for 1.5 s between phases. It cannot be hit while it roars, splits, teleports or dies:
## bullets pass through. On death its windows close one by one and it drops the code.
class_name Root
extends Enemy

enum State { IDLE, LASH, RAIN, ROAR, SPLIT, TELEPORT_OUT, GONE, TELEPORT_IN, DYING }

const ERROR_WINDOW := preload("res://scenes/enemies/error_window.tscn")
const CODE_PICKUP := preload("res://scenes/world/code_pickup.tscn")
const MAIN := preload("res://art/game/root/main.png")
const MAIN_RED := preload("res://art/game/root/main_red.png")
const CURSOR := preload("res://art/game/root/cursor.png")
const WINDOWS: Array[Texture2D] = [
	preload("res://art/game/root/window_1.png"), preload("res://art/game/root/window_2.png"),
	preload("res://art/game/root/window_3.png"), preload("res://art/game/root/window_4.png"),
	preload("res://art/game/root/window_5.png"),
]

## The middle of Root, from its feet (its position, on the floor under it).
const CENTER := Vector2(0, -34)
## Where each window sits, from the middle: 0 is the main window, 1-5 the error windows.
const PLACES: Array[Vector2] = [
	Vector2(0, -16), Vector2(-17, 6), Vector2(17, 6), Vector2(-26, 22), Vector2(0, 25), Vector2(26, 22),
]
## How quickly each window catches up with its place (share of the way per second): the main
## window at once, the error windows further out more slowly, so the cloak trails.
const FOLLOW: Array[float] = [14.0, 6.2, 5.4, 4.6, 3.8, 3.0]
## Every window bobs up and down this many pixels, this fast (radians per second).
const BOB := 1.0
const BOB_SPEED := 2.0
## The error windows, drawn back to front before the main window.
const DRAW_ORDER: Array[int] = [3, 4, 5, 1, 2]
## Teleporting out, the error windows close in this order; in, they open in this one.
const CLOSE_ORDER: Array[int] = [5, 3, 4, 2, 1]
const OPEN_ORDER: Array[int] = [1, 2, 4, 3, 5]
## Dying, every window closes in turn, the main window last.
const DEATH_ORDER: Array[int] = [5, 3, 4, 2, 1, 0]
## Dying: seconds before the first window closes, between windows, and for one to close.
const DEATH_START := 0.4
const DEATH_STEP := 0.25
const DEATH_CLOSE := 0.2
## The crown: three cursors over the main window (top left corners, from the window's middle),
## bobbing.
const CROWN: Array[Vector2] = [Vector2(-13, -27), Vector2(-3, -30), Vector2(7, -27)]
const CROWN_BOB_SPEED := 3.0
## Pixels the crown sinks while it vanishes.
const CROWN_SINK := 6.0
## The hands: cursors left and right of the middle (top left corners). They sway gently, and
## swing hard during Belt Lash.
const LEFT_HAND := Vector2(-44, -4)
const RIGHT_HAND := Vector2(36, -4)
const HAND_SWAY := 2.0
const HAND_SWAY_SPEED := 1.6
const LASH_SWING := 8.0
const LASH_SWING_SPEED := 9.0
## The eye, in the main window (pixels from its middle): it blinks for a moment every few
## seconds, opens wide to roar, attack and in phase 3, and its pupil looks at the player.
const EYE := Vector2(0, 2)
const EYE_HALF_WIDTH := 8
const EYE_HEIGHT := 3.5
const EYE_WIDE := 1.5
const PUPIL_REACH := Vector2(3, 1.5)
const BLINK_EVERY := 4.2
const BLINK_TIME := 0.12
const EYE_WHITE := Color("#f4f4ff")
const EYE_LID := Color("#b62649")
const EYE_LASH := Color("#ffd3da")
const PUPIL := Color("#ff5873")
const PUPIL_CORE := Color("#1a0610")
## Bullet Rain winds up with a loading spinner around the eye: dots, its size, its speed.
const SPINNER_DOTS := 8
const SPINNER_SIZE := Vector2(15, 12)
const SPINNER_SPEED := 6.0
const SPINNER_COLORS: Array[Color] = [Color("#ff5873"), Color("#74f2e0")]
## A few pixels drip off under the cloak: how many, over what area (from the middle), and how
## often they change (per second).
const DRIPS := 10
const DRIP_AREA := Rect2(-36, 30, 72, 10)
const DRIP_RATE := 8.0
const DRIP_COLORS: Array[Color] = [Color("#b62649"), Color("#32315c")]
## Its shadow on the floor: half width and height, and how dark. In phase 3 only the main
## window is left, with a smaller shadow closer under it.
const SHADOW := Vector2(30, 3)
const SHADOW_ALONE := Vector2(16, 3)
const SHADOW_ALONE_AT := Vector2(0, 6)
const SHADOW_COLOR := Color(0, 0, 0, 0.35)
## Seconds it shows white after a hit.
const HIT_FLASH_TIME := 0.06
## Title bars flash this many times a second while it roars.
const ROAR_FLASH_RATE := 8.0
## Dying, small squares burst off it for this long, this far from its middle.
const DEATH_BURST_TIME := 2.0
const DEATH_BURST_REACH := 30.0
const DEATH_BURST_SIZE := 4.0
## Error windows fly off to points on an oval around the room's middle, this wide and high.
const SPLIT_SPREAD := Vector2(120, 60)
## Its feet stay at least this many tiles below the north wall, so its windows never reach over
## the wall, and this many above the south wall.
const TOP_CLEARANCE := 5
const BOTTOM_CLEARANCE := 2
## Its hitbox in phases 1-2 (the whole body) and in phase 3 (only the main window), from the
## middle.
const BODY_BOX := Rect2(-30, -32, 60, 62)
const MAIN_BOX := Rect2(-19, -32, 38, 32)

var state := State.IDLE
var phase := 1
var max_hp := 1
## The error windows fighting on their own in phase 3.
var error_windows: Array[ErrorWindow] = []
var _state_time := 0.0
var _time := 0.0
## Where each window is now, from Root's position.
var _windows: Array[Vector2] = []
var _glide_to := Vector2.ZERO
var _glide_left := 0.0
var _lash_left := 0.0
var _lash_aim := 0.0
var _lash_fire_left := 0.0
var _rain_left := 0.0
var _teleport_left := 0.0
var _burst_left := 0.0
var _flash_left := 0.0

@onready var _hitbox: CollisionShape2D = $Hitbox/Shape
@onready var _glow: PointLight2D = $Glow


func _ready() -> void:
	var cfg := Config.balance
	max_hp = cfg.root_hp
	hp = max_hp
	awake = true
	_glide_to = position
	for place in PLACES:
		_windows.append(CENTER + place)
	_lash_left = cfg.root_lash_interval
	_rain_left = cfg.root_rain_interval
	_teleport_left = cfg.root_teleport_interval
	_burst_left = cfg.root_burst_interval
	_glow.texture = RoomLight.GLOW
	_set_hitbox(BODY_BOX)
	Events.boss_health_changed.emit(1.0)


## The phase for `hp_share` (hit points left, from 1 to 0).
static func phase_for(hp_share: float) -> int:
	var cfg := Config.balance
	if hp_share > cfg.root_phase2_at:
		return 1
	if hp_share > cfg.root_phase3_at:
		return 2
	return 3


## True while it roars, splits, teleports or dies: it cannot be hit then.
func is_invulnerable() -> bool:
	return state in [State.ROAR, State.SPLIT, State.TELEPORT_OUT, State.GONE, State.TELEPORT_IN, State.DYING]


func take_damage(amount: int, _direction: Vector2) -> void:
	if is_invulnerable():
		return
	hp -= amount
	_flash_left = HIT_FLASH_TIME
	Events.boss_health_changed.emit(maxf(hp, 0) / float(max_hp))
	if hp <= 0:
		die()
		return
	var new_phase := phase_for(float(hp) / max_hp)
	if new_phase != phase:
		phase = new_phase
		_set_state(State.ROAR)
		player_camera_shake(Config.balance.root_roar_shake)
		Audio.play_sfx(&"boss_roar")


## Its windows close one by one and the error windows vanish; then it drops the code (_finish).
func die() -> void:
	Events.boss_health_changed.emit(0.0)
	_set_state(State.DYING)
	for window in error_windows:
		window.vanish()
	error_windows.clear()
	player_camera_shake(Config.balance.root_roar_shake)


## Starts teleporting now (from phase 2 it does this by itself).
func start_teleport() -> void:
	_set_state(State.TELEPORT_OUT)
	Audio.play_sfx(&"boss_fade")


func _physics_process(delta: float) -> void:
	var cfg := Config.balance
	_time += delta
	_state_time += delta
	_flash_left -= delta
	var player := target_player()
	# Phase 3 runs its clocks and bullets faster.
	var speed := cfg.root_phase3_speedup if phase == 3 else 1.0
	match state:
		State.IDLE, State.LASH, State.RAIN:
			_glide(delta, player)
			if state == State.IDLE and player:
				_choose_attack(delta * speed, player)
			elif state == State.LASH:
				_lash(delta, speed)
			elif state == State.RAIN and _state_time >= cfg.root_rain_windup:
				_ring(cfg.root_rain_bullets, cfg.root_rain_bullet_speed * speed)
				_set_state(State.IDLE)
		State.ROAR:
			if _state_time >= cfg.root_phase_pause:
				if phase == 3:
					_split()
				else:
					_set_state(State.IDLE)
		State.SPLIT:
			if _state_time >= cfg.root_split_time:
				_teleport_left = cfg.root_phase3_teleport_interval
				_set_state(State.IDLE)
		State.TELEPORT_OUT:
			if _state_time >= cfg.root_teleport_out_time:
				_set_state(State.GONE)
		State.GONE:
			if _state_time >= cfg.root_teleport_gone_time:
				_land(player)
				_set_state(State.TELEPORT_IN)
		State.TELEPORT_IN:
			if _state_time >= cfg.root_teleport_in_time:
				if phase == 3:
					_ring(cfg.root_phase3_ring_bullets, cfg.root_phase3_ring_speed * speed)
					_set_state(State.IDLE)
				else:
					_set_state(State.RAIN)
		State.DYING:
			if _state_time >= DEATH_START + DEATH_ORDER.size() * DEATH_STEP:
				_finish()
				return
	_follow_places(delta)
	_update_glow()
	queue_redraw()


## In phases 1-2 a new point in the upper half of the room every few seconds; in phase 3 a new
## point anywhere, well away from the player, more often. It closes in on the point smoothly.
func _glide(delta: float, player: Player) -> void:
	var cfg := Config.balance
	_glide_left -= delta
	if _glide_left <= 0.0:
		if phase == 3:
			_glide_left = cfg.root_phase3_glide_interval
			_glide_to = _spot(cfg.root_phase3_glide_min_distance, false, player)
		else:
			_glide_left = randf_range(cfg.root_glide_min, cfg.root_glide_max)
			_glide_to = _spot(0.0, true, player)
	var follow := cfg.root_phase3_glide_follow if phase == 3 else cfg.root_glide_follow
	position += (_glide_to - position) * minf(1.0, delta * follow)


## The clocks run only while it is idle; the first one due starts its attack.
func _choose_attack(step: float, player: Player) -> void:
	var cfg := Config.balance
	_lash_left -= step
	_rain_left -= step
	_teleport_left -= step
	_burst_left -= step
	if phase == 3:
		if _teleport_left <= 0.0:
			_teleport_left = cfg.root_phase3_teleport_interval
			start_teleport()
		elif _burst_left <= 0.0:
			_burst_left = cfg.root_burst_interval
			_burst(player)
		return
	if phase == 2 and _teleport_left <= 0.0:
		_teleport_left = cfg.root_teleport_interval
		start_teleport()
	elif _lash_left <= 0.0:
		_lash_left = cfg.root_lash_interval
		_lash_aim = (player.hurtbox_position() - _main_window()).angle()
		_lash_fire_left = 0.0
		_set_state(State.LASH)
	elif phase == 2 and _rain_left <= 0.0:
		_rain_left = cfg.root_rain_interval
		_set_state(State.RAIN)


## Belt Lash: two arms of bullets that start on either side of the player and sweep across each
## other.
func _lash(delta: float, speed: float) -> void:
	var cfg := Config.balance
	var half := deg_to_rad(cfg.root_lash_arc) / 2.0
	_lash_fire_left -= delta
	while _lash_fire_left <= 0.0:
		_lash_fire_left += cfg.root_lash_fire_interval
		var k := minf(1.0, _state_time / cfg.root_lash_time)
		for side in [-1.0, 1.0]:
			_shoot_from_main(Vector2.from_angle(_lash_aim + side * (half - 2.0 * half * k)), cfg.root_lash_bullet_speed * speed)
	if _state_time >= cfg.root_lash_time:
		_set_state(State.IDLE)


## A ring of `count` bullets in every direction.
func _ring(count: int, bullet_speed: float) -> void:
	var turn := randf() * TAU  # So rings do not always leave the same gaps.
	for i in count:
		_shoot_from_main(Vector2.from_angle(turn + TAU * i / count), bullet_speed)


## Phase 3: a short fan of bullets aimed at the player.
func _burst(player: Player) -> void:
	var cfg := Config.balance
	var aim := (player.hurtbox_position() - _main_window()).angle()
	var spread := deg_to_rad(cfg.root_burst_spread)
	for i in cfg.root_burst_bullets:
		_shoot_from_main(Vector2.from_angle(aim + (i - (cfg.root_burst_bullets - 1) / 2.0) * spread), cfg.root_burst_speed * cfg.root_phase3_speedup)


func _shoot_from_main(direction: Vector2, bullet_speed: float) -> void:
	eye_offset = _windows[0]
	shoot(direction, bullet_speed)


## Phase 3 starts: the five error windows fly off to points around the room and fight on their
## own; only the main window stays.
func _split() -> void:
	_set_state(State.SPLIT)
	_set_hitbox(MAIN_BOX)
	var room := get_parent() as Room
	var middle := room.inside_area().get_center() if room else global_position
	for i in range(1, PLACES.size()):
		var window: ErrorWindow = ERROR_WINDOW.instantiate()
		window.index = i
		window.room = room
		window.position = position + _windows[i]
		# Fanned out over the upper side of an oval around the room's middle.
		var angle := -PI * 0.95 + (i - 1) * PI * 0.95 / 2.0
		window.fly_to = middle + Vector2(cos(angle), sin(angle)) * SPLIT_SPREAD
		get_parent().add_child(window)
		error_windows.append(window)


## Appears again somewhere in the room, far enough from the player, its windows in place.
func _land(player: Player) -> void:
	var cfg := Config.balance
	var distance := cfg.root_phase3_teleport_min_distance if phase == 3 else cfg.root_teleport_min_distance
	position = _spot(distance, false, player)
	_glide_to = position
	for i in PLACES.size():
		_windows[i] = CENTER + PLACES[i]
	reset_physics_interpolation()  # A jump, not a fast move.


## The code drops where it was, and it is gone.
func _finish() -> void:
	var code: Node2D = CODE_PICKUP.instantiate()
	code.position = position
	get_parent().add_child.call_deferred(code)
	Events.enemy_died.emit(self)
	queue_free()


## A random point (Root's feet) on free floor in its room, at least `min_distance` from the
## player; with `upper_half`, in the upper half of the room. Stays put if there is none.
func _spot(min_distance: float, upper_half: bool, player: Player) -> Vector2:
	var room := get_parent() as Room
	if room == null:
		return position
	var top := room.rect.position.y + TOP_CLEARANCE
	var bottom := room.rect.end.y - 1 - BOTTOM_CLEARANCE
	var middle := room.rect.get_center().y
	var spots: Array[Vector2] = []
	for cell in room.map.free_floor_cells:
		var inside := cell.x > room.rect.position.x + 2 and cell.x < room.rect.end.x - 3 and cell.y >= top and cell.y <= bottom
		if not inside or (upper_half and cell.y > middle):
			continue
		var spot := room.map.cell_center(cell)
		if player == null or (spot + CENTER).distance_to(player.global_position) >= min_distance:
			spots.append(spot)
	return spots.pick_random() if not spots.is_empty() else position


## Every window closes in on its place with its own delay, bobbing gently.
func _follow_places(delta: float) -> void:
	for i in PLACES.size():
		var place := CENTER + PLACES[i] + Vector2(0, roundf(sin(_time * BOB_SPEED + i) * BOB))
		_windows[i] += (place - _windows[i]) * minf(1.0, delta * FOLLOW[i])


func _set_state(new_state: State) -> void:
	state = new_state
	_state_time = 0.0
	_hitbox.set_deferred(&"disabled", is_invulnerable())


func _set_hitbox(box: Rect2) -> void:
	(_hitbox.shape as RectangleShape2D).size = box.size
	_hitbox.position = CENTER + box.get_center()


## The red glow around it fades out and in with the teleport.
func _update_glow() -> void:
	var cfg := Config.balance
	var spec := Config.lighting.root_glow_alone if phase == 3 else Config.lighting.root_glow
	var strength := 1.0
	match state:
		State.TELEPORT_OUT:
			strength = 1.0 - _state_time / cfg.root_teleport_out_time
		State.GONE:
			strength = 0.0
		State.TELEPORT_IN:
			strength = _state_time / cfg.root_teleport_in_time
		State.DYING:
			strength = 1.0 - minf(1.0, _state_time / (DEATH_START + DEATH_ORDER.size() * DEATH_STEP))
	_glow.position = CENTER
	_glow.color = spec.color
	_glow.energy = spec.energy * clampf(strength, 0.0, 1.0)
	_glow.texture_scale = spec.radius / (RoomLight.GLOW.get_width() / 2.0)


## The main window's middle, in global pixels.
func _main_window() -> Vector2:
	return global_position + _windows[0]


func player_camera_shake(strength: float) -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player:
		player.camera.shake(strength)


# --- Drawing ---------------------------------------------------------------------------------

## How open each window is, how open the eye is, and whether the crown and hands show, for the
## current moment: [opens (6 floats), eye, crown, hands].
func _look() -> Array:
	var cfg := Config.balance
	var opens: Array[float] = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
	var eye := 0.0 if fmod(_time, BLINK_EVERY) < BLINK_TIME else 1.0
	var crown := 1.0
	var hands := true
	match state:
		State.TELEPORT_OUT:
			var k := _state_time / cfg.root_teleport_out_time
			for j in CLOSE_ORDER.size():
				opens[CLOSE_ORDER[j]] = 1.0 - RootWindow.step(k, j * 0.08, j * 0.08 + 0.14)
			eye = 1.0 - smoothstep(0.0, 1.0, RootWindow.step(k, 0.5, 0.64))
			opens[0] = 1.0 - RootWindow.step(k, 0.68, 0.86)
			crown = 1.0 - RootWindow.step(k, 0.4, 0.5)
			hands = k < 0.45
		State.GONE:
			opens.fill(0.0)
			crown = 0.0
			hands = false
		State.TELEPORT_IN:
			var k := _state_time / cfg.root_teleport_in_time
			opens[0] = RootWindow.step(k, 0.0, 0.16)
			for j in OPEN_ORDER.size():
				opens[OPEN_ORDER[j]] = RootWindow.step(k, 0.2 + j * 0.08, 0.34 + j * 0.08)
			# The eye opens only when Root is whole again.
			eye = smoothstep(0.0, 1.0, RootWindow.step(k, 0.74, 0.9))
			crown = RootWindow.step(k, 0.6, 0.7)
			hands = k > 0.62
		State.ROAR:
			eye = 1.0
		State.DYING:
			for j in DEATH_ORDER.size():
				var start := DEATH_START + j * DEATH_STEP
				opens[DEATH_ORDER[j]] = 1.0 - RootWindow.step(_state_time, start, start + DEATH_CLOSE)
			eye = 1.0 if _state_time < DEATH_START + DEATH_STEP else 0.0
			crown = 1.0 if _state_time < DEATH_START + 2.0 * DEATH_STEP else 0.0
			hands = crown > 0.0
	return [opens, eye, crown, hands]


func _draw() -> void:
	var look := _look()
	var opens: Array[float] = look[0]
	var alone := phase == 3 and state != State.ROAR
	var white := _flash_left > 0.0
	var flash := state == State.ROAR and int(_state_time * ROAR_FLASH_RATE) % 2 == 0
	var wide := 1.0 if state in [State.ROAR, State.RAIN, State.DYING] or phase == 3 else 0.0
	if state != State.GONE:
		_draw_shadow(CENTER + SHADOW_ALONE_AT if alone else CENTER + Vector2(0, 36), SHADOW_ALONE if alone else SHADOW)
	if not alone and state in [State.IDLE, State.LASH, State.RAIN]:
		_draw_drips()
	if not alone:
		for i in DRAW_ORDER:
			RootWindow.draw(self, WINDOWS[i - 1], _windows[i].round(), opens[i], flash, white)
	var main := _windows[0].round()
	var crown: float = look[2]
	if crown > 0.3:
		for k in CROWN.size():
			var bob := roundf(sin(_time * CROWN_BOB_SPEED + k)) + roundf((1.0 - crown) * CROWN_SINK)
			draw_texture(CURSOR, main + CROWN[k] + Vector2(0, bob))
	RootWindow.draw(self, MAIN_RED if phase == 3 else MAIN, main, opens[0], flash, white)
	if opens[0] >= 1.0 and not white:
		var aim := (target_position() - (global_position + main)).angle()
		_draw_eye(main + EYE, look[1], wide, aim)
	if look[3]:
		var swing := sin(_time * LASH_SWING_SPEED) * LASH_SWING if state == State.LASH else sin(_time * HAND_SWAY_SPEED) * HAND_SWAY
		draw_set_transform(CENTER + LEFT_HAND + Vector2(CURSOR.get_width(), roundf(swing)), 0.0, Vector2(-1, 1))
		draw_texture(CURSOR, Vector2.ZERO)
		draw_set_transform(Vector2.ZERO)
		draw_texture(CURSOR, CENTER + RIGHT_HAND - Vector2(0, roundf(swing)))
	if state == State.RAIN:
		for k in SPINNER_DOTS:
			var angle := _time * SPINNER_SPEED + k * TAU / SPINNER_DOTS
			var dot := main + EYE + Vector2(cos(angle) * SPINNER_SIZE.x, sin(angle) * SPINNER_SIZE.y)
			draw_rect(Rect2(dot.round() - Vector2.ONE, Vector2(2, 2)), SPINNER_COLORS[k % 2])
	if state == State.DYING and _state_time < DEATH_BURST_TIME:
		var burst := RandomNumberGenerator.new()
		burst.seed = int(_state_time * 10.0)
		for k in 3:
			var at := CENTER + Vector2.from_angle(burst.randf() * TAU) * burst.randf() * DEATH_BURST_REACH
			draw_rect(Rect2(at.round() - Vector2.ONE * DEATH_BURST_SIZE / 2.0, Vector2.ONE * DEATH_BURST_SIZE), SPINNER_COLORS[k % 2])


## Where the eye looks: the player, or straight down.
func target_position() -> Vector2:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	return player.global_position if player else global_position + Vector2.DOWN


## The eye: `open` 0 is shut (a lid line with lashes), 1 open; `wide` opens it wider; its pupil
## looks along `aim`.
func _draw_eye(at: Vector2, open: float, wide: float, aim: float) -> void:
	var height := (EYE_HEIGHT + wide * EYE_WIDE) * open
	if open < 0.14:
		draw_rect(Rect2(at + Vector2(-EYE_HALF_WIDTH, 0), Vector2(EYE_HALF_WIDTH * 2 + 1, 1)), EYE_LASH)
		for x in [-6, -2, 2, 6]:
			draw_rect(Rect2(at + Vector2(x, 1), Vector2.ONE), EYE_LID)
		return
	for x in range(-EYE_HALF_WIDTH, EYE_HALF_WIDTH + 1):
		var half := roundf(sqrt(maxf(0.0, 1.0 - pow(x / (EYE_HALF_WIDTH + 0.5), 2.0))) * height)
		draw_rect(Rect2(at + Vector2(x, -half), Vector2(1, half * 2.0 + 1.0)), EYE_WHITE)
	draw_rect(Rect2(at + Vector2(-EYE_HALF_WIDTH, -roundf(height) - 1.0), Vector2(EYE_HALF_WIDTH * 2 + 1, 1)), EYE_LID)
	if open > 0.4:
		var pupil := at + Vector2(roundf(cos(aim) * PUPIL_REACH.x), roundf(sin(aim) * PUPIL_REACH.y * open))
		draw_rect(Rect2(pupil + Vector2(-3, -2), Vector2(6, 5)), PUPIL)
		draw_rect(Rect2(pupil + Vector2(-2, -3), Vector2(4, 7)), PUPIL)
		draw_rect(Rect2(pupil + Vector2(-1, -1), Vector2(2, 3)), PUPIL_CORE)
		draw_rect(Rect2(pupil + Vector2(-2, -2), Vector2.ONE), EYE_LASH)


func _draw_shadow(at: Vector2, size: Vector2) -> void:
	draw_set_transform(at, 0.0, size)
	draw_circle(Vector2.ZERO, 1.0, SHADOW_COLOR)
	draw_set_transform(Vector2.ZERO)


func _draw_drips() -> void:
	var drips := RandomNumberGenerator.new()
	drips.seed = int(_time * DRIP_RATE)
	for k in DRIPS:
		var at := CENTER + DRIP_AREA.position + Vector2(drips.randf() * DRIP_AREA.size.x, drips.randf() * DRIP_AREA.size.y)
		draw_rect(Rect2(at.round(), Vector2.ONE), DRIP_COLORS[k % 2])
