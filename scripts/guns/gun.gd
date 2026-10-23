## The gun in the player's hand: fires bullets from its muzzle, counts ammo, reloads, and plays
## its own juice (a 2-frame muzzle flash, shell casings). The recoil moves the hand with the gun,
## so the player does it. Which gun it is comes from the OwnedGun it holds.
class_name Gun
extends Node2D

## Emitted whenever the ammo count, the reload state or the gun in hand changes.
signal changed
## Emitted on every shot (used to find the gun used most in a round).
signal fired(stats: GunStats)

const BULLET := preload("res://scenes/guns/player_bullet.tscn")
const SHELL_CASING := preload("res://scenes/fx/shell_casing.tscn")
## How much casings lean backwards (away from the aim) as they fly out of the gun.
const EJECT_BACKWARD_TILT := 0.5
## The muzzle flash: a bigger first frame, then a smaller one.
const FLASH_BIG := preload("res://art/game/muzzle_flash_big.png")
const FLASH_SMALL := preload("res://art/game/muzzle_flash_small.png")

## The character holding the gun. Casings fall to the floor at its feet.
var holder: Node2D
## The gun currently in hand, with its ammo.
var owned: OwnedGun
var stats: GunStats:
	get:
		return owned.stats
var in_magazine: int:
	get:
		return owned.in_magazine
var reserve: int:
	get:
		return owned.reserve
var is_reloading := false

var _cooldown_left := 0.0
var _reload_left := 0.0

@onready var _sprite: Sprite2D = $Sprite
@onready var _muzzle: Marker2D = $Muzzle
@onready var _flash: Sprite2D = $Muzzle/Flash
@onready var _eject: Marker2D = $Eject
@onready var _sparkles: CPUParticles2D = $Sparkles


## How far the reload is, from 0 (just started) to 1 (done); 0 when not reloading.
func reload_progress() -> float:
	if not is_reloading:
		return 0.0
	return clampf(1.0 - _reload_left / stats.reload_time, 0.0, 1.0)


## Puts `gun` in the hand. Its ammo is kept as it was; a running reload is cancelled.
func equip(gun: OwnedGun) -> void:
	owned = gun
	# The gun node sits at the grip, so the art is shifted to put its grip pixel on the hand.
	_sprite.texture = stats.held_texture
	_sprite.offset = -stats.grip
	_muzzle.position = stats.muzzle - stats.grip
	_eject.position = stats.eject - stats.grip
	_sparkles.emitting = stats.sparkles
	is_reloading = false
	_cooldown_left = 0.0
	changed.emit()


func _process(delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)
	if is_reloading:
		_reload_left -= delta
		if _reload_left <= 0.0:
			_finish_reload()


## Fires one shot if the gun is ready. An empty magazine starts a reload instead.
## Returns true if the gun fired.
func try_fire() -> bool:
	if is_reloading or _cooldown_left > 0.0:
		return false
	if owned.in_magazine == 0:
		start_reload()
		return false
	owned.in_magazine -= 1
	_cooldown_left = 1.0 / stats.fire_rate
	_spawn_bullets()
	_play_shot_juice()
	Audio.play_sfx(&"gun_shot")
	fired.emit(stats)
	changed.emit()
	if owned.in_magazine == 0:
		start_reload()
	return true


## Starts a reload unless the magazine is full or there is no ammo left to load.
func start_reload() -> void:
	var has_ammo := stats.infinite_reserve or owned.reserve > 0
	if is_reloading or owned.in_magazine == stats.magazine_size or not has_ammo:
		return
	is_reloading = true
	_reload_left = stats.reload_time
	Audio.play_sfx(&"gun_reload")
	changed.emit()


func _finish_reload() -> void:
	var missing := stats.magazine_size - owned.in_magazine
	var loaded := missing if stats.infinite_reserve else mini(missing, owned.reserve)
	owned.in_magazine += loaded
	if not stats.infinite_reserve:
		owned.reserve -= loaded
	is_reloading = false
	changed.emit()


## Spawns one bullet per pellet, fanned out evenly over the gun's spread.
func _spawn_bullets() -> void:
	# The gun's x axis points where it aims, even when it is flipped for aiming left.
	var aim := global_transform.x.normalized()
	var spread := deg_to_rad(stats.spread_degrees)
	for i in stats.pellets:
		var offset := 0.0
		if stats.pellets > 1:
			offset = lerpf(-spread / 2.0, spread / 2.0, float(i) / (stats.pellets - 1))
		var bullet: PlayerBullet = BULLET.instantiate()
		bullet.global_position = _muzzle.global_position
		bullet.setup(aim.rotated(offset), stats)
		get_tree().current_scene.add_child(bullet)


func _play_shot_juice() -> void:
	var cfg := Config.balance
	_flash.texture = FLASH_BIG
	_flash.visible = true
	get_tree().create_timer(cfg.muzzle_flash_time / 2.0).timeout.connect(_shrink_flash)
	get_tree().create_timer(cfg.muzzle_flash_time).timeout.connect(_hide_flash)
	if stats.ejects_casings:
		_eject_casing()


func _shrink_flash() -> void:
	if is_instance_valid(_flash):
		_flash.texture = FLASH_SMALL


func _hide_flash() -> void:
	if is_instance_valid(_flash):
		_flash.visible = false


func _eject_casing() -> void:
	var casing: ShellCasing = SHELL_CASING.instantiate()
	var eject_point := _eject.global_position
	var floor_y := holder.global_position.y if holder else eject_point.y
	casing.global_position = Vector2(eject_point.x, floor_y)
	get_tree().current_scene.add_child(casing)
	# Casings fly up out of the gun and slightly backwards, like a real ejection port.
	var aim := global_transform.x.normalized()
	var up := -global_transform.y.normalized()
	casing.launch((up - aim * EJECT_BACKWARD_TILT).normalized(), floor_y - eject_point.y)
