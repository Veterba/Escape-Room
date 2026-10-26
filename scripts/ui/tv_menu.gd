## Base for the menus shown on the ASCII TV: the password menu and the main menu. The TV
## (an AsciiArt of art/game/menu_tv.txt) fills the whole screen: its rows fill the height and its
## columns spread out to fill the width. The CRT shader lies over it, and the menu's own UI goes
## on the TV's screen, sized by the TV's character height. The UI fades in once the TV has booted.
##
## The rest of the game renders at 640x360 and scales the pixels up by whole steps. Characters 5 px
## tall would turn to mush that way, so while a TV menu is open the window draws at its real
## resolution (content scale mode "canvas items") and fills the whole window, whatever its shape
## (no black bars around the menu), and switches back when it closes. The background and the CRT
## look cover the whole window, so nothing looks cut off.
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

## Pixels per TV cell: its height, which also sizes the menu UI.
var cell := 1.0
var booted := false

@onready var tv: AsciiArt = $Tv
@onready var screen: Control = $Tv/Screen


func _ready() -> void:
	var window := get_window()
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	window.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL
	tv.set_art(AsciiArt.read_file(TV_ART_PATH))
	_fit_tv()
	get_viewport().size_changed.connect(_fit_tv)
	screen.modulate.a = 0.0
	tv.booted.connect(_on_booted)


func _exit_tree() -> void:
	var window := get_window()
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	window.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	window.content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER


## The TV over the whole window. Columns are never narrower than the characters, so on a window
## narrower than the TV it fills the width instead and sits in the middle.
func _fit_tv() -> void:
	var view := get_viewport_rect().size
	var width := view.x / tv.columns
	cell = minf(view.y / tv.rows, width)
	tv.set_cell_size(cell, width)
	tv.position = (view - tv.size) / 2.0
	var scale := Vector2(width, cell)
	screen.position = SCREEN_CELLS.position * scale
	screen.size = SCREEN_CELLS.size * scale


func _on_booted() -> void:
	booted = true
	create_tween().tween_property(screen, "modulate:a", 1.0, FADE_TIME)


func style_button(button: Button, ink: Color, text: Color = DARK, lit_when_chosen := false) -> void:
	PhosphorStyle.style_button(button, cell, ink, text, lit_when_chosen)


func box(fill: Color, border: Color, glow: int) -> StyleBoxFlat:
	return PhosphorStyle.box(fill, border, glow)


func spaced_font(font_size: float, spacing: float) -> FontVariation:
	return PhosphorStyle.spaced_font(font_size, spacing)
