## Tests for the round timer: counts down, stops while paused, signals when it reaches 0.
extends TestCase


func _make_timer(seconds: float) -> RoundTimer:
	var timer := RoundTimer.new()
	world.add_child(timer)
	timer.start(seconds)
	return timer


func test_counts_down() -> void:
	var timer := _make_timer(600.0)
	for i in steps_for(1.0):
		timer._process(STEP)
	assert_true(timer.time_left < 599.0, "a second of play takes a second off")
	assert_near(timer.elapsed + timer.time_left, 600.0, 0.001, "elapsed and time left add up")


func test_stops_while_paused() -> void:
	var timer := _make_timer(600.0)
	world.get_tree().paused = true
	await wait(0.3)
	assert_eq(timer.time_left, 600.0, "no time passes while paused")
	world.get_tree().paused = false
	await wait(0.3)
	assert_true(timer.time_left < 600.0, "time runs again after unpausing")


func test_signals_once_at_zero() -> void:
	var timer := _make_timer(0.5)
	var signals := [0]
	timer.timed_out.connect(func() -> void: signals[0] += 1)
	for i in steps_for(1.0):
		timer._process(STEP)
	assert_eq(timer.time_left, 0.0, "stops at 0:00")
	assert_eq(signals[0], 1, "timed_out fires exactly once")
