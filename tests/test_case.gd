## Base class for tests: assertion helpers and a fresh world node to put test nodes in.
class_name TestCase
extends RefCounted

## Step length used when a test advances time by hand: one physics frame at 60 FPS.
const STEP := 1.0 / 60.0

## A fresh empty scene for every test; the runner frees it afterwards.
var world: Node2D
var failures: Array[String] = []


## Frames needed to cover `seconds`, plus one so float rounding never leaves a timer a hair above zero.
func steps_for(seconds: float) -> int:
	return ceili(seconds / STEP) + 1


func assert_true(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		failures.append("%s (expected %s, got %s)" % [message, expected, actual])


func assert_near(actual: float, expected: float, tolerance: float, message: String) -> void:
	if absf(actual - expected) > tolerance:
		failures.append("%s (expected %s ± %s, got %s)" % [message, expected, tolerance, actual])


## Waits for real time to pass, for things driven by tweens and timers.
func wait(seconds: float) -> void:
	await world.get_tree().create_timer(seconds).timeout
