## Main menu on the ASCII TV: the title, PLAY and QUIT. Reached from the Menu buttons of the pause
## and end screens. Mouse or keyboard: Up and Down choose, Enter presses.
extends TvMenu

## Sizes in cells: the title's font, and the space between the title and the buttons.
const TITLE_FONT := 3.0
const TITLE_SPACING := 0.25
const GAP := 2.4

@onready var _items: VBoxContainer = $Tv/Screen/Items
@onready var _title: Label = $Tv/Screen/Items/Title
@onready var _play: Button = $Tv/Screen/Items/Play
@onready var _quit: Button = $Tv/Screen/Items/Quit


func _ready() -> void:
	super._ready()
	_items.add_theme_constant_override(&"separation", int(GAP * cell))
	_title.text = Strings.GAME_TITLE
	_title.add_theme_font_override(&"font", spaced_font(TITLE_FONT * cell, TITLE_SPACING))
	_title.add_theme_font_size_override(&"font_size", int(round(TITLE_FONT * cell)))
	_title.add_theme_color_override(&"font_color", PHOSPHOR)
	_title.add_theme_stylebox_override(&"normal", box(GLASS, Color.TRANSPARENT, 0))
	for button: Button in [_play, _quit]:
		style_button(button, PHOSPHOR, DARK, true)
	_play.text = Strings.PLAY.to_upper()
	_quit.text = Strings.QUIT.to_upper()
	_play.pressed.connect(func() -> void: Game.start_round())
	_quit.pressed.connect(get_tree().quit)


func _on_booted() -> void:
	super._on_booted()
	# Only now, so Enter cannot press a button that is not shown yet.
	_play.grab_focus()
