## The look shared by every ASCII art screen (the TV menus and the pause menu): green phosphor
## colours, the menu font, glowing boxes and buttons. Sizes are given in cells of the ASCII art,
## so everything keeps the approved proportions at any screen size.
class_name PhosphorStyle

const FONT := preload("res://art/fonts/JetBrainsMono-ExtraBold.ttf")
const PHOSPHOR := Color("#46ff8f")
const PHOSPHOR_DIM := Color("#1f8f4c")
const BAD := Color("#ff4658")
const GLASS := Color("#06140a")
const DARK := Color("#030a05")
## Buttons: font size in cells, extra space between letters (a share of the font size), and
## padding sideways and up and down (in font sizes), from the approved design.
const BUTTON_FONT := 1.35
const BUTTON_SPACING := 0.2
const BUTTON_PADDING := Vector2(1.8, 0.7)
## Pixels of glow around boxes and buttons.
const GLOW_SIZE := 6


## A phosphor button in `ink`, for cells `cell` pixels wide: filled with `text`-coloured letters,
## inverted (dark with `ink` letters) while the mouse is over it or it has the keyboard focus.
## With `lit_when_chosen` it is the other way round, so in a list of buttons the chosen one
## lights up.
static func style_button(button: Button, cell: float, ink: Color, text: Color = DARK, lit_when_chosen := false) -> void:
	button.add_theme_font_override(&"font", spaced_font(BUTTON_FONT * cell, BUTTON_SPACING))
	button.add_theme_font_size_override(&"font_size", int(round(BUTTON_FONT * cell)))
	var padding := BUTTON_PADDING * BUTTON_FONT * cell
	for style in [&"normal", &"pressed", &"hover", &"focus"]:
		var filled: bool = (style == &"normal" or style == &"pressed") != lit_when_chosen
		var look := box(ink if filled else GLASS, ink, GLOW_SIZE)
		look.content_margin_left = padding.x
		look.content_margin_right = padding.x
		look.content_margin_top = padding.y
		look.content_margin_bottom = padding.y
		button.add_theme_stylebox_override(style, look)
	for color in [&"font_color", &"font_pressed_color"]:
		button.add_theme_color_override(color, ink if lit_when_chosen else text)
	for color in [&"font_hover_color", &"font_focus_color", &"font_hover_pressed_color"]:
		button.add_theme_color_override(color, text if lit_when_chosen else ink)


## A box with a 1 px border and a soft glow (the shadow, in the border's colour).
static func box(fill: Color, border: Color, glow: int) -> StyleBoxFlat:
	var look := StyleBoxFlat.new()
	look.bg_color = fill
	look.border_color = border
	look.set_border_width_all(1 if border.a > 0.0 else 0)
	look.shadow_color = Color(border, 0.35)
	look.shadow_size = glow
	look.set_content_margin_all(2.0)
	look.anti_aliasing = false
	return look


## The menu font with extra space between letters: `spacing` is a share of the font size.
static func spaced_font(font_size: float, spacing: float) -> FontVariation:
	var spaced := FontVariation.new()
	spaced.base_font = FONT
	spaced.spacing_glyph = int(round(font_size * spacing))
	return spaced


## Styles `label` as a phosphor heading: `font` cells tall, letters spaced by `spacing`, on a
## dark strip so it reads over the ASCII art.
static func style_heading(label: Label, cell: float, font: float, spacing: float) -> void:
	label.add_theme_font_override(&"font", spaced_font(font * cell, spacing))
	label.add_theme_font_size_override(&"font_size", int(round(font * cell)))
	label.add_theme_color_override(&"font_color", PHOSPHOR)
	label.add_theme_stylebox_override(&"normal", box(GLASS, Color.TRANSPARENT, 0))
