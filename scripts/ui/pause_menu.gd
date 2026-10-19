## Esc pauses the round (the timer stops with everything else) and shows Resume / Restart / Menu.
class_name PauseMenu
extends CanvasLayer

## Off once the round has ended, so Esc cannot unpause the end screen.
var enabled := true

@onready var _panel: Control = $Center


func _ready() -> void:
	_panel.visible = false
	$Center/Panel/Items/Resume.pressed.connect(_set_paused.bind(false))
	$Center/Panel/Items/Restart.pressed.connect(func() -> void: Game.start_round(Game.current_map_id))
	$Center/Panel/Items/Menu.pressed.connect(Game.go_to_menu)


func _unhandled_input(event: InputEvent) -> void:
	if enabled and event.is_action_pressed(&"pause"):
		_set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	_panel.visible = paused
