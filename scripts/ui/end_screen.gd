## The win or lose screen: "ESCAPED!" with the code and time, or "BOOM" with the reason.
class_name EndScreen
extends CanvasLayer

@onready var _title: Label = $Center/Panel/Items/Title
@onready var _subtitle: Label = $Center/Panel/Items/Subtitle
@onready var _code: Label = $Center/Panel/Items/Code
@onready var _time: Label = $Center/Panel/Items/Time


func _ready() -> void:
	visible = false
	$Center/Panel/Items/Buttons/PlayAgain.pressed.connect(func() -> void: Game.start_round())
	$Center/Panel/Items/Buttons/Menu.pressed.connect(Game.go_to_menu)


func show_result(result: Round.Result, secret_code: String, seconds_used: float) -> void:
	var won := result == Round.Result.WIN
	_title.text = Strings.WIN_TITLE if won else Strings.LOSE_TITLE
	if won:
		_subtitle.text = Strings.SECRET_CODE
	elif result == Round.Result.TIMEOUT:
		_subtitle.text = Strings.REASON_TIMEOUT
	else:
		_subtitle.text = Strings.REASON_DEATH
	_code.text = secret_code
	_code.visible = won
	_time.text = Strings.TIME_USED_FORMAT % RoundTimer.format(int(seconds_used))
	_time.visible = won
	visible = true
