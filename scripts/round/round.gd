## One round: builds the map, starts the timer, and decides the result. Win: the code is picked up
## (or, on the boss floor, the exit is reached).
## Lose: the player runs out of hearts, or the timer reaches 0:00 (boss rounds have no timer). Then it shows the end screen
## and writes a line to the run log.
class_name Round
extends Node2D

enum Result { NONE, WIN, DEATH, TIMEOUT }

## Result names written to the run log.
const RESULT_NAMES := {Result.WIN: "win", Result.DEATH: "death", Result.TIMEOUT: "timeout"}
const NO_GUN := "none"

var map: GameMap
## A random 4-digit code, new every round.
var secret_code := ""
var result := Result.NONE
var hearts_lost := 0
## How often an Officer Kin handcuffed the player.
var times_trapped := 0
## Where the run log is written. Tests point it somewhere else.
var run_log_path := RunLog.DEFAULT_PATH

## Shots fired per gun id, to find the gun used most.
var _shots_by_gun := {}

@onready var player: Player = $Player
@onready var timer: RoundTimer = $RoundTimer
@onready var _hud: Hud = $HUD
@onready var _pause_menu: PauseMenu = $PauseMenu
@onready var _end_screen: EndScreen = $EndScreen
@onready var _debug_overlay: DebugOverlay = $DebugOverlay
@onready var _floor_map: FloorMap = $FloorMap


func _ready() -> void:
	map = Game.make_map(Game.current_map_id)
	add_child(map)
	move_child(map, 0)  # Drawn first, under everything else.
	player.global_position = map.spawn_position
	player.reset_physics_interpolation()
	player.camera.set_bounds(map.bounds)
	secret_code = "%04d" % randi_range(0, 9999)

	player.hurt.connect(func() -> void: hearts_lost += 1)
	player.died.connect(end_round.bind(Result.DEATH))
	player.gun.fired.connect(_count_shot)
	timer.timed_out.connect(end_round.bind(Result.TIMEOUT))
	Events.code_collected.connect(end_round.bind(Result.WIN))
	Events.hourglass_collected.connect(_add_hourglass_time)
	player.trapped.connect(func() -> void: times_trapped += 1)

	timer.start(Config.balance.round_length, Game.has_timer(Game.current_map_id))
	_hud.bind(player, timer, map.map_id)
	_debug_overlay.bind(self)
	_floor_map.bind(self)


## Ends the round once; later calls are ignored (for example a hit after the win).
func end_round(new_result: Result) -> void:
	if result != Result.NONE:
		return
	result = new_result
	timer.stop()
	_pause_menu.enabled = false
	RunLog.append(run_log_path, _log_row())
	# A short pause before the end screen, so the player sees the death puff or the pickup.
	var delay := create_tween()
	delay.tween_interval(Config.balance.end_screen_delay)
	delay.tween_callback(_show_end_screen)


func gun_used_most() -> String:
	var best := NO_GUN
	var best_shots := 0
	for gun_id: StringName in _shots_by_gun:
		if _shots_by_gun[gun_id] > best_shots:
			best = gun_id
			best_shots = _shots_by_gun[gun_id]
	return best


func _add_hourglass_time() -> void:
	timer.add_bonus_once(Config.balance.hourglass_bonus_time)


func _show_end_screen() -> void:
	get_tree().paused = true
	_end_screen.show_result(result, secret_code, timer.elapsed)


func _count_shot(stats: GunStats) -> void:
	_shots_by_gun[stats.id] = _shots_by_gun.get(stats.id, 0) + 1


func _log_row() -> PackedStringArray:
	return [
		Time.get_datetime_string_from_system(false, true),
		map.map_id,
		RESULT_NAMES[result],
		str(int(timer.elapsed)),
		str(hearts_lost),
		str(times_trapped),
		gun_used_most(),
	]
