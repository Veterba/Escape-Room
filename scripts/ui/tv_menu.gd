## Base for the menus shown on the ASCII TV: the password menu and the main menu. The TV
## (an AsciiArt of art/game/menu_tv.txt) fills the screen, the CRT shader lies over it, and the menu's own UI goes on the
## TV's screen, sized in TV cells. The UI fades in once the TV has booted.
##
## The rest of the game renders at 640x360 and scales the pixels up. Characters 5 px tall would
## turn to mush that way, so while a TV menu is open the window draws at its real resolution
## (content scale mode "canvas items"), and switches back when it closes.
class_name TvMenu
extends Control

const TV_ART_PATH := "res://art/game/menu_tv.txt"
# The shared look, under short names for the menus.
const FONT := PhosphorStyle.FONT
const PHOSPHOR := PhosphorStyle.PHOSPHOR
const PHOSPHOR_DIM := PhosphorStyle.PHOSPHOR_DIM
const BAD := PhosphorStyle.BAD
const GLASS := PhosphorStyle.GLASS
const DARK := PhosphorStyle.DARK
const GLOW_SIZE := PhosphorStyle.GLOW_SIZE
## Where the menu UI sits on the TV's screen, in cells: left, top, width, height.
const SCREEN_CELLS := Rect2(14, 11, 48, 40)
## Seconds for the menu UI to fade in or out.
const FADE_TIME := 0.4

## Pixels per TV cell (cells are square).
var cell := 1.0
var booted := false

@onready var tv: AsciiArt = $Tv
@onready var screen: Control = $Tv/Screen
@onready var _crt: ColorRect = $Crt


func _ready() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	# As big as the screen allows, keeping the TV's shape.
	tv.set_art(AsciiArt.read_file(TV_ART_PATH))
	var view := get_viewport_rect().size
	cell = minf(view.x / tv.columns, view.y / tv.rows)
	tv.set_cell_size(cell)
	tv.position = (view - tv.size) / 2.0
	screen.position = SCREEN_CELLS.position * cell
	screen.size = SCREEN_CELLS.size * cell
	_crt.position = tv.position
	_crt.size = tv.size
	screen.modulate.a = 0.0
	tv.booted.connect(_on_booted)


func _exit_tree() -> void:
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT


func _on_booted() -> void:
	booted = true
	create_tween().tween_property(screen, "modulate:a", 1.0, FADE_TIME)


func style_button(button: Button, ink: Color, text: Color = DARK, lit_when_chosen := false) -> void:
	PhosphorStyle.style_button(button, cell, ink, text, lit_when_chosen)


func box(fill: Color, border: Color, glow: int) -> StyleBoxFlat:
	return PhosphorStyle.box(fill, border, glow)


func spaced_font(font_size: float, spacing: float) -> FontVariation:
	return PhosphorStyle.spaced_font(font_size, spacing)
