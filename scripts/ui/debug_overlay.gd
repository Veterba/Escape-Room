## F3 toggles a debug overlay: FPS, map, seconds left, player position, enemy count.
class_name DebugOverlay
extends CanvasLayer

var _round: Round

@onready var _label: Label = $Label


func _ready() -> void:
	visible = false


func bind(round_node: Round) -> void:
	_round = round_node


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"debug_overlay"):
		visible = not visible


func _process(_delta: float) -> void:
	if not visible or _round == null:
		return
	var player_position := _round.player.global_position
	_label.text = Strings.DEBUG_FORMAT % [
		Engine.get_frames_per_second(),
		Strings.MAP_NAMES[_round.map.map_id],
		_round.timer.time_left,
		player_position.x, player_position.y,
		get_tree().get_node_count_in_group(&"enemies"),
	]
