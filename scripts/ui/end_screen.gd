## The win or lose screen: "ESCAPED!" with the code, the time and the word for the next escape
## room task, or "BOOM" with the reason, on an
## ASCII art panel in green phosphor like the pause panel: it boots up, shimmers and glows over
## the dimmed round. BOOM is written in red. PLAY AGAIN and MENU fade in once the panel is up.
##
## While it shows, the window draws at its real resolution so the small characters stay sharp
## (see TvMenu).
class_name EndScreen
extends CanvasLayer

## The panel in cells, and the seed that draws it (the same panel every time).
const PANEL_SIZE := Vector2i(52, 42)
const PANEL_SEED := 11
## Cells are as big as on the TV menus: the TV's 68 rows fill the screen's height.
const CELL_ROWS := 68
## Sizes in cells: the title, the code, the lines of text, the letter spacing, and the space
## between the items and between the buttons.
const TITLE_FONT := 3.4
const CODE_FONT := 3.0
const TEXT_FONT := 1.4
const SPACING := 0.25
const GAP := 1.2
const BUTTON_GAP := 2.0
const DIM := Color(0.0, 0.0, 0.0, 0.6)

@onready var _view: Control = $View
@onready var _art: AsciiArt = $View/Art
@onready var _items: VBoxContainer = $View/Art/Items
@onready var _title: Label = $View/Art/Items/Title
@onready var _subtitle: Label = $View/Art/Items/Subtitle
@onready var _code: Label = $View/Art/Items/Code
@onready var _time: Label = $View/Art/Items/Time
@onready var _next_label: Label = $View/Art/Items/NextLabel
@onready var _next_word: Label = $View/Art/Items/NextWord
@onready var _buttons: HBoxContainer = $View/Art/Items/Buttons
@onready var _play_again: Button = $View/Art/Items/Buttons/PlayAgain
@onready var _menu: Button = $View/Art/Items/Buttons/Menu
@onready var _cell: float = get_viewport().get_visible_rect().size.y / CELL_ROWS


func _ready() -> void:
	visible = false
	$View/Dim.color = DIM
	_art.set_art(AsciiArt.panel(PANEL_SIZE, PANEL_SEED))
	_art.set_cell_size(_cell)
	_art.position = (get_viewport().get_visible_rect().size - _art.size) / 2.0
	$View/Crt.position = _art.position
	$View/Crt.size = _art.size
	# The panel is solid: the round does not show through between the characters.
	var back: ColorRect = $View/Back
	back.color = PhosphorStyle.DARK
	back.position = _art.position + Vector2.ONE * _cell
	back.size = _art.size - Vector2.ONE * 2.0 * _cell
	_items.size = _art.size
	_items.add_theme_constant_override(&"separation", int(GAP * _cell))
	_buttons.add_theme_constant_override(&"separation", int(BUTTON_GAP * _cell))
	PhosphorStyle.style_heading(_title, _cell, TITLE_FONT, SPACING)
	PhosphorStyle.style_heading(_code, _cell, CODE_FONT, SPACING)
	PhosphorStyle.style_heading(_next_word, _cell, CODE_FONT, SPACING)
	for label: Label in [_subtitle, _time, _next_label]:
		PhosphorStyle.style_heading(label, _cell, TEXT_FONT, SPACING)
	for button: Button in [_play_again, _menu]:
		PhosphorStyle.style_button(button, _cell, PhosphorStyle.PHOSPHOR, PhosphorStyle.DARK, true)
	_play_again.text = Strings.PLAY_AGAIN.to_upper()
	_menu.text = Strings.MENU.to_upper()
	_play_again.pressed.connect(func() -> void: Game.start_round())
	_menu.pressed.connect(Game.go_to_menu)
	_art.booted.connect(_on_booted)


func _exit_tree() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT


func show_result(result: Round.Result, secret_code: String, seconds_used: float) -> void:
	var won := result == Round.Result.WIN
	_title.text = (Strings.WIN_TITLE if won else Strings.LOSE_TITLE).to_upper()
	_title.add_theme_color_override(&"font_color", PhosphorStyle.PHOSPHOR if won else PhosphorStyle.BAD)
	if won:
		_subtitle.text = Strings.SECRET_CODE
	elif result == Round.Result.TIMEOUT:
		_subtitle.text = Strings.REASON_TIMEOUT
	else:
		_subtitle.text = Strings.REASON_DEATH
	_subtitle.text = _subtitle.text.to_upper()
	_code.text = secret_code
	_code.visible = won
	_time.text = (Strings.TIME_USED_FORMAT % RoundTimer.format(int(seconds_used))).to_upper()
	_time.visible = won
	_next_label.text = Strings.NEXT_TASK_WORD.to_upper()
	_next_word.text = Config.balance.next_task_word.to_upper()
	_next_label.visible = won
	_next_word.visible = won
	visible = true
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	_items.modulate.a = 0.0
	_art.boot()


## The buttons fade in once the panel has booted, and only then take the keyboard.
func _on_booted() -> void:
	create_tween().tween_property(_items, "modulate:a", 1.0, TvMenu.FADE_TIME)
	_play_again.grab_focus()
