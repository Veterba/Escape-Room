## The round timer: counts down from 10:00, or only counts the time played in a boss round, which
## has no time limit. It is a normal node, so it stops while the game is paused.
class_name RoundTimer
extends Node

signal timed_out

var time_left := 0.0
## Seconds played this round (for the win screen and the run log).
var elapsed := 0.0
var running := false
## False in a boss round: no countdown and no timeout, only the time played.
var counts_down := true
## The hourglass bonus is given at most once per round.
var bonus_given := false


static func format(total_seconds: int) -> String:
	return "%d:%02d" % [total_seconds / 60, total_seconds % 60]


func start(seconds: float, count_down := true) -> void:
	counts_down = count_down
	time_left = seconds
	elapsed = 0.0
	running = true
	bonus_given = false


## Adds `seconds` the first time it is called in a round. Returns false if the bonus was already given.
func add_bonus_once(seconds: float) -> bool:
	if bonus_given:
		return false
	bonus_given = true
	time_left += seconds
	return true


func stop() -> void:
	running = false


func _process(delta: float) -> void:
	if not running:
		return
	elapsed += delta
	if not counts_down:
		return
	time_left = maxf(time_left - delta, 0.0)
	if time_left == 0.0:
		running = false
		timed_out.emit()
