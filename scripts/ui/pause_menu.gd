## Esc pauses the round (the timer stops with everything else) and shows RESUME / RESTART ROUND /
## MENU on an ASCII art panel in green phosphor, like the TV menus but without the TV: the panel
## boots up, shimmers and glows the same way, over the dimmed round. Mouse or keyboard: Up and
## Down choose, Enter presses, Esc resumes.
##
## While paused the window draws at its real resolution so the small characters stay sharp
## (see TvMenu); nothing moves then, so the round behind looks the same.
class_name PauseMenu
extends CanvasLayer

## The panel in cells, and the seed that draws it (the same panel every time).
const PANEL_SIZE := Vector2i(46, 34)
const PANEL_SEED := 7
## Cells are as big as on the TV menus: the TV's 68 rows fill the screen's height.
const CELL_ROWS := 68
## Sizes in cells: the title, and the space between the items.
const TITLE_FONT := 2.6
const TITLE_SPACING := 0.25
const GAP := 1.6
## How dark the round behind the panel gets.
const DIM := Color(0.0, 0.0, 0.0, 0.6)

## Off once the round has ended, so Esc cannot unpause the end screen.
var enabled := true

@onready var _view: Control = $View
@onready var _art: AsciiArt = $View/Art
@onready var _items: VBoxContainer = $View/Art/Items
@onready var _title: Label = $View/Art/Items/Title
@onready var _resume: Button = $View/Art/Items/Resume
@onready var _restart: Button = $View/Art/Items/Restart
@onready var _menu: Button = $View/Art/Items/Menu
@onready var _crt: ColorRect = $View/Crt


func _ready() -> void:
	_view.visible = false
	$View/Dim.color = DIM
	var cell := get_viewport().get_visible_rect().size.y / CELL_ROWS
	_art.set_art(AsciiArt.panel(PANEL_SIZE, PANEL_SEED))
	_art.set_cell_size(cell)
	_art.position = (get_viewport().get_visible_rect().size - _art.size) / 2.0
	_crt.position = _art.position
	_crt.size = _art.size
	# The panel is solid: the round does not show through between the characters.
	var back: ColorRect = $View/Back
	back.color = PhosphorStyle.DARK
	back.position = _art.position + Vector2.ONE * cell
	back.size = _art.size - Vector2.ONE * 2.0 * cell
	_items.size = _art.size
	_items.add_theme_constant_override(&"separation", int(GAP * cell))
	_title.text = Strings.PAUSED.to_upper()
	PhosphorStyle.style_heading(_title, cell, TITLE_FONT, TITLE_SPACING)
	for button: Button in [_resume, _restart, _menu]:
		PhosphorStyle.style_button(button, cell, PhosphorStyle.PHOSPHOR, PhosphorStyle.DARK, true)
	_resume.text = Strings.RESUME.to_upper()
	_restart.text = Strings.RESTART_ROUND.to_upper()
	_menu.text = Strings.MENU.to_upper()
	_resume.pressed.connect(_set_paused.bind(false))
	_restart.pressed.connect(func() -> void: Game.start_round(Game.current_map_id))
	_menu.pressed.connect(Game.go_to_menu)
	_art.booted.connect(_on_booted)


func _exit_tree() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT


func _unhandled_input(event: InputEvent) -> void:
	if enabled and event.is_action_pressed(&"pause"):
		_set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()


func _set_paused(paused: bool) -> void:
	get_tree().paused = paused
	_view.visible = paused
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS if paused else Window.CONTENT_SCALE_MODE_VIEWPORT
	if paused:
		_items.modulate.a = 0.0
		_art.boot()


## The buttons fade in once the panel has booted, and only then take the keyboard.
func _on_booted() -> void:
	create_tween().tween_property(_items, "modulate:a", 1.0, TvMenu.FADE_TIME)
	_resume.grab_focus()
