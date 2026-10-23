## The in-game HUD: hearts top-left; the timer top-centre (red and pulsing in the last minute);
## gun, ammo and smoke bombs top-right; the map name for a moment at the start. In the Enemy
## Arena, one line under the timer says whether the code chest is still chained.
class_name Hud
extends CanvasLayer

const HEART_TEXTURE := preload("res://art/game/item_heart.png")
const TIMER_COLOR := Color("#F0B43C")
const TIMER_WARNING_COLOR := Color("#E0403A")
## A lost heart is drawn as a dark shadow.
const LOST_HEART_TINT := Color(0.15, 0.12, 0.2, 0.8)
## Timer pulses per second and how much it grows (0.15 = 15 %) in the last minute.
const PULSE_RATE := 2.0
const PULSE_SIZE := 0.15
## Seconds the map name takes to fade out.
const MAP_NAME_FADE_TIME := 0.4

var _player: Player
var _timer: RoundTimer
var _pulse_time := 0.0

@onready var _hearts: HBoxContainer = $Root/Hearts
@onready var _timer_label: Label = $Root/TimerLabel
@onready var _map_name: Label = $Root/MapName
@onready var _arena_status: Label = $Root/ArenaStatus
@onready var _gun_icon: TextureRect = $Root/Loadout/Row/GunIcon
@onready var _ammo_label: Label = $Root/Loadout/Row/AmmoLabel
@onready var _smoke_label: Label = $Root/Loadout/Row/SmokeLabel


## Connects the HUD to the player and timer it shows.
func bind(player: Player, timer: RoundTimer, map_id: StringName) -> void:
	_player = player
	_timer = timer
	player.gun.changed.connect(_refresh_gun)
	player.hearts_changed.connect(_show_hearts)
	player.smoke_bombs_changed.connect(_show_smoke_bombs)
	Events.wave_started.connect(_show_arena_status)
	_refresh_gun()
	_show_hearts(player.hearts)
	_show_smoke_bombs(player.smoke_bombs)
	_show_map_name(Strings.MAP_NAMES[map_id])


func _process(delta: float) -> void:
	if _timer == null:
		return
	_timer_label.text = RoundTimer.format(ceili(_timer.time_left))
	_timer_label.pivot_offset = _timer_label.size / 2.0
	if _timer.time_left <= Config.balance.timer_warning_time:
		_pulse_time += delta
		_timer_label.modulate = TIMER_WARNING_COLOR
		_timer_label.scale = Vector2.ONE * (1.0 + PULSE_SIZE * absf(sin(_pulse_time * PULSE_RATE * PI)))
	else:
		_timer_label.modulate = TIMER_COLOR
		_timer_label.scale = Vector2.ONE


func _show_hearts(count: int) -> void:
	for child in _hearts.get_children():
		child.queue_free()
	for i in Config.balance.player_hearts:
		var heart := TextureRect.new()
		heart.texture = HEART_TEXTURE
		heart.modulate = Color.WHITE if i < count else LOST_HEART_TINT
		_hearts.add_child(heart)


## Only the arena sends waves, so the line never shows on the other maps.
func _show_arena_status(wave: int) -> void:
	var unlock_wave := Config.balance.arena_chest_unlock_wave
	_arena_status.visible = true
	if wave >= unlock_wave:
		_arena_status.text = Strings.CHEST_OPEN
	else:
		_arena_status.text = Strings.CHEST_LOCKED_FORMAT % [wave, unlock_wave]


func _show_smoke_bombs(count: int) -> void:
	_smoke_label.text = str(count)


func _show_map_name(map_name: String) -> void:
	_map_name.text = map_name
	_map_name.modulate.a = 1.0
	var fade := create_tween()
	fade.tween_interval(Config.balance.map_name_show_time)
	fade.tween_property(_map_name, "modulate:a", 0.0, MAP_NAME_FADE_TIME)


func _refresh_gun() -> void:
	var gun := _player.gun
	_gun_icon.texture = gun.stats.icon
	if gun.is_reloading:
		_ammo_label.text = Strings.RELOADING
		return
	var reserve := Strings.INFINITE_AMMO if gun.stats.infinite_reserve else str(gun.reserve)
	_ammo_label.text = Strings.AMMO_FORMAT % [gun.in_magazine, reserve]
