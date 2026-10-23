## Tests for the pause menu: Esc's panel pauses the round, gives RESUME the keyboard once the
## panel has booted, draws sharp text while open, and resuming puts everything back.
extends TestCase

const ROUND := preload("res://scenes/round/round.tscn")


func test_pause_and_resume() -> void:
	Game.current_map_id = &"arena"
	var round_node: Round = ROUND.instantiate()
	round_node.run_log_path = "user://test_runs.csv"
	world.add_child(round_node)
	var pause: PauseMenu = round_node.get_node("PauseMenu")
	pause._set_paused(true)
	assert_true(world.get_tree().paused, "the round is paused")
	assert_eq(pause.get_window().content_scale_mode, Window.CONTENT_SCALE_MODE_CANVAS_ITEMS, "sharp text while paused")
	pause._on_booted()
	assert_true((pause.get_node("View/Art/Items/Resume") as Button).has_focus(), "RESUME has the keyboard")
	pause._set_paused(false)
	assert_true(not world.get_tree().paused, "resumed")
	assert_eq(pause.get_window().content_scale_mode, Window.CONTENT_SCALE_MODE_VIEWPORT, "back to pixel art")
