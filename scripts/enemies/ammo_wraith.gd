## The Ammo Wraith, boss of the Boss Chamber, with three phases:
## 1 (above 66 % hit points): Belt Lash, two sweeping arcs of bullets every 3 s.
## 2 (66-33 %): Belt Lash plus Bullet Rain, a ring of 16 bullets every 4 s.
## 3 (below 33 %): everything 1.3 times faster, plus Fade: it teleports to a spot at least
##    100 px from the player and fires a ring.
## Between phases it stops for 1.5 s and roars, shaking the screen. The HUD shows its health.
class_name AmmoWraith
extends Enemy

## Height of its eyes above its feet: it is 64 px tall.
const BOSS_EYES := Vector2(0, -32)
## Death puffs in its final burst, spread this many pixels around it.
const DEATH_PUFFS := 6
const DEATH_SPREAD := 24.0

var phase := 1
var max_hp := 1
## Seconds left in the roar between phases.
var _pause_left := 0.0
var _lash_cooldown := 0.0
var _rain_cooldown := 0.0
var _fade_cooldown := 0.0
## Belt Lash bullets still to fire, each [seconds until it fires, angle in radians].
var _lash_queue: Array[Array] = []


func _ready() -> void:
	var cfg := Config.balance
	max_hp = cfg.boss_hp
	hp = max_hp
	eye_offset = BOSS_EYES
	_lash_cooldown = cfg.boss_lash_interval
	_rain_cooldown = cfg.boss_rain_interval
	_fade_cooldown = cfg.boss_fade_interval
	Events.boss_health_changed.emit(1.0)


## The phase for `hp_share` (hit points left, from 1 to 0).
static func phase_for(hp_share: float) -> int:
	var cfg := Config.balance
	if hp_share > cfg.boss_phase2_at:
		return 1
	if hp_share > cfg.boss_phase3_at:
		return 2
	return 3


func take_damage(amount: int, direction: Vector2) -> void:
	super.take_damage(amount, direction)
	_knockback = Vector2.ZERO  # Too heavy to be pushed back.
	Events.boss_health_changed.emit(maxf(hp, 0) / float(max_hp))
	var new_phase := phase_for(float(hp) / max_hp)
	if hp > 0 and new_phase != phase:
		phase = new_phase
		_roar()


func _physics_process(delta: float) -> void:
	var player := target_player()
	if player == null:
		move(Vector2.ZERO, delta)
		return
	if _pause_left > 0.0:
		_pause_left -= delta
		move(Vector2.ZERO, delta)
		return
	var cfg := Config.balance
	# Phase 3 runs every clock faster, so all attacks come 1.3 times as often.
	var step := delta * (cfg.boss_phase3_speedup if phase == 3 else 1.0)
	move(path_velocity(player.global_position, cfg.boss_speed), delta)
	_update_lash(step, player)
	if phase >= 2:
		_rain_cooldown -= step
		if _rain_cooldown <= 0.0:
			_rain_cooldown = cfg.boss_rain_interval
			fire_ring()
	if phase == 3:
		_fade_cooldown -= step
		if _fade_cooldown <= 0.0:
			_fade_cooldown = cfg.boss_fade_interval
			_fade(player)


## A ring of boss_rain_bullets bullets in every direction.
func fire_ring() -> void:
	var cfg := Config.balance
	var turn := randf() * TAU  # So rings do not always leave the same gaps.
	for i in cfg.boss_rain_bullets:
		shoot(Vector2.from_angle(turn + TAU * i / cfg.boss_rain_bullets), _bullet_speed())


func die() -> void:
	Events.boss_health_changed.emit(0.0)
	for i in DEATH_PUFFS:
		var puff: Node2D = Juice.DEATH_PUFF.instantiate()
		puff.global_position = global_position + eye_offset + Vector2.from_angle(TAU * i / DEATH_PUFFS) * DEATH_SPREAD
		get_tree().current_scene.add_child(puff)
	player_camera_shake(Config.balance.boss_roar_shake)
	super.die()


## Belt Lash: queues one sweep across the player and one back, then fires them as their time comes.
func _update_lash(step: float, player: Player) -> void:
	var cfg := Config.balance
	_lash_cooldown -= step
	if _lash_cooldown <= 0.0:
		_lash_cooldown = cfg.boss_lash_interval
		var aim := (player.hurtbox_position() - (global_position + eye_offset)).angle()
		var arc := deg_to_rad(cfg.boss_lash_arc)
		for i in cfg.boss_lash_bullets:
			var along := float(i) / (cfg.boss_lash_bullets - 1)
			var delay := along * cfg.boss_lash_sweep_time
			_lash_queue.append([delay, aim - arc / 2.0 + arc * along])
			_lash_queue.append([cfg.boss_lash_sweep_time + delay, aim + arc / 2.0 - arc * along])
	for bullet in _lash_queue:
		bullet[0] -= step
		if bullet[0] <= 0.0:
			shoot(Vector2.from_angle(bullet[1]), _bullet_speed())
	_lash_queue = _lash_queue.filter(func(bullet: Array) -> bool: return bullet[0] > 0.0)


## Fade: vanishes in a puff and reappears on free floor in its room, far enough from the player.
func _fade(player: Player) -> void:
	var room := get_parent() as Room
	if room == null:
		return
	var spots: Array[Vector2] = []
	for cell in room.map.free_floor_cells:
		var spot := room.map.cell_center(cell)
		if room.rect.grow(-2).has_point(cell) and spot.distance_to(player.global_position) >= Config.balance.boss_fade_min_distance:
			spots.append(spot)
	if spots.is_empty():
		return
	juice.spawn_death_puff()
	global_position = spots.pick_random()
	reset_physics_interpolation()  # A jump, not a fast move: no smoothing in between.
	juice.spawn_death_puff()
	fire_ring()
	Audio.play_sfx(&"boss_fade")


func _roar() -> void:
	_pause_left = Config.balance.boss_phase_pause
	_lash_queue.clear()
	juice.hit_flash()
	player_camera_shake(Config.balance.boss_roar_shake)
	Audio.play_sfx(&"boss_roar")


func _bullet_speed() -> float:
	var cfg := Config.balance
	return cfg.boss_bullet_speed * (cfg.boss_phase3_speedup if phase == 3 else 1.0)


func player_camera_shake(strength: float) -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player:
		player.camera.shake(strength)
