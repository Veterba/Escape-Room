## The first screen of the game: an ASCII television (AsciiArt) whose screen asks for the access
## code from the previous escape room task. Type 4 digits (Backspace erases, Enter or the button
## tries the code). A wrong code turns the cells and the button red, shakes the button and makes
## the TV shimmer harder; the right one shows "ACCESS GRANTED" and goes straight into a round.
## It is the main scene and every "Menu" button goes to the main menu, so it is asked only once
## per launch. The TV, its CRT look and the sharp text come from TvMenu.
class_name PasswordScreen
extends TvMenu

enum State { BOOTING, ENTERING, WRONG, GRANTED }

const CODE_LENGTH := 4
## The button's text once it has turned red.
const BAD_TEXT := Color("#1a0306")
## Sizes in cells, from the approved design.
const GAP := 1.8
const CODE_CELL_SIZE := Vector2(5.0, 6.6)
const CODE_CELL_GAP := 1.0
const PROMPT_FONT := 1.15
const DIGIT_FONT := 3.6
const HINT_FONT := 0.95
const GRANTED_FONT := 2.2
## The granted banner's padding (sideways, up and down), in font sizes.
const GRANTED_PADDING := Vector2(0.8, 0.4)
## Extra space between letters, as a share of the font size.
const PROMPT_SPACING := 0.35
const GRANTED_SPACING := 0.3
## Seconds: colour change, button shake, digit pop, cursor blink, and the granted wait.
const RECOLOR_TIME := 0.35
const SHAKE_TIME := 0.42
## Button shake: pixels at each step (from the approved design: -8, 7, -4, 2, back to 0).
const SHAKE_STEPS: Array[float] = [-8.0, 7.0, -4.0, 2.0, 0.0]
const POP_TIME := 0.25
const POP_SCALE := 1.12
const BLINK_TIME := 0.5
const GRANTED_TIME := 1.2

var state := State.BOOTING
var code := ""

var _cells: Array[Panel] = []
## 0 = phosphor green, 1 = red. Tweened when a code is wrong.
var _alarm := 0.0
var _blink := 0.0

@onready var _items: VBoxContainer = $Tv/Screen/Items
@onready var _prompt: Label = $Tv/Screen/Items/Prompt
@onready var _cell_row: HBoxContainer = $Tv/Screen/Items/Cells
@onready var _button: Button = $Tv/Screen/Items/Try
@onready var _hint: Label = $Tv/Screen/Items/Hint
@onready var _granted: Control = $Tv/Granted
@onready var _granted_label: Label = $Tv/Granted/Label


func _ready() -> void:
	# Testing with --map skips the password and goes straight to that map.
	if Game.forced_map_id() != &"":
		Game.start_round.call_deferred()
		return
	super._ready()
	_layout()
	_button.pressed.connect(submit)
	_granted.visible = false
	_set_alarm(0.0)


static func is_correct(text: String) -> bool:
	return text == Config.balance.password


## Adds one digit, if there is room. A new digit after a wrong code turns everything green again.
func type_digit(digit: String) -> void:
	if state == State.GRANTED or state == State.BOOTING or code.length() >= CODE_LENGTH:
		return
	if state == State.WRONG:
		_calm_down()
	code += digit
	_show_code()
	_pop(_cells[code.length() - 1])
	tv.shimmer_burst()
	Audio.play_sfx(&"menu_type")


func erase() -> void:
	if state != State.ENTERING or code.is_empty():
		return
	code = code.left(code.length() - 1)
	_show_code()


## Tries the code: the right one opens the game, a wrong one sounds the alarm and clears the cells.
func submit() -> void:
	if state != State.ENTERING:
		return
	if is_correct(code):
		_grant()
	else:
		_alarm_wrong()


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.unicode >= "0".unicode_at(0) and key.unicode <= "9".unicode_at(0):
		type_digit(char(key.unicode))
	elif key.keycode == KEY_BACKSPACE:
		erase()
	elif key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER:
		submit()
	else:
		return
	get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	_blink += delta
	for i in _cells.size():
		var cursor: ColorRect = _cells[i].get_node("Cursor")
		cursor.visible = i == code.length() and state != State.GRANTED and fmod(_blink, 2.0 * BLINK_TIME) < BLINK_TIME


## Everything is sized in TV cells, so the screen UI keeps the approved proportions.
func _layout() -> void:
	_items.add_theme_constant_override(&"separation", int(GAP * cell))
	_cell_row.add_theme_constant_override(&"separation", int(CODE_CELL_GAP * cell))

	_prompt.text = Strings.ACCESS_PROMPT
	_prompt.add_theme_font_override(&"font", spaced_font(PROMPT_FONT * cell, PROMPT_SPACING))
	_prompt.add_theme_font_size_override(&"font_size", int(round(PROMPT_FONT * cell)))
	_prompt.add_theme_stylebox_override(&"normal", box(GLASS, Color.TRANSPARENT, 0))
	_hint.text = Strings.ACCESS_HINT
	_hint.add_theme_font_override(&"font", FONT)
	_hint.add_theme_font_size_override(&"font_size", int(round(HINT_FONT * cell)))
	_hint.add_theme_color_override(&"font_color", PHOSPHOR_DIM)
	_hint.add_theme_stylebox_override(&"normal", box(GLASS, Color.TRANSPARENT, 0))
	_button.text = Strings.TRY_CODE
	_button.focus_mode = Control.FOCUS_NONE  # Enter is handled once, above.
	_granted.position = screen.position
	_granted.size = screen.size
	_granted_label.text = Strings.ACCESS_GRANTED
	_granted_label.add_theme_font_override(&"font", spaced_font(GRANTED_FONT * cell, GRANTED_SPACING))
	_granted_label.add_theme_font_size_override(&"font_size", int(round(GRANTED_FONT * cell)))
	_granted_label.add_theme_color_override(&"font_color", DARK)
	var banner := box(PHOSPHOR, PHOSPHOR, GLOW_SIZE * 2)
	var banner_padding := GRANTED_PADDING * GRANTED_FONT * cell
	banner.content_margin_left = banner_padding.x
	banner.content_margin_right = banner_padding.x
	banner.content_margin_top = banner_padding.y
	banner.content_margin_bottom = banner_padding.y
	_granted_label.add_theme_stylebox_override(&"normal", banner)

	for i in CODE_LENGTH:
		var panel := Panel.new()
		panel.custom_minimum_size = CODE_CELL_SIZE * cell
		panel.pivot_offset = panel.custom_minimum_size / 2.0
		panel.add_theme_stylebox_override(&"panel", box(GLASS, PHOSPHOR, GLOW_SIZE))
		var digit := Label.new()
		digit.name = "Digit"
		digit.set_anchors_preset(Control.PRESET_FULL_RECT)
		digit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		digit.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		digit.add_theme_font_override(&"font", FONT)
		digit.add_theme_font_size_override(&"font_size", int(round(DIGIT_FONT * cell)))
		panel.add_child(digit)
		var cursor := ColorRect.new()
		cursor.name = "Cursor"
		cursor.color = PHOSPHOR
		cursor.position = Vector2(0.22, 0.82) * panel.custom_minimum_size
		cursor.size = Vector2(0.56 * panel.custom_minimum_size.x, maxf(1.0, cell * 0.5))
		panel.add_child(cursor)
		_cell_row.add_child(panel)
		_cells.append(panel)


func _on_booted() -> void:
	super._on_booted()
	state = State.ENTERING


func _show_code() -> void:
	for i in _cells.size():
		(_cells[i].get_node("Digit") as Label).text = code[i] if i < code.length() else ""


## A typed digit jumps into its cell: bigger and bright for a moment, then back.
func _pop(panel: Panel) -> void:
	var look := panel.get_theme_stylebox(&"panel") as StyleBoxFlat
	var digit: Label = panel.get_node("Digit")
	var pop := create_tween().set_parallel()
	panel.scale = Vector2.ONE * POP_SCALE
	look.bg_color = _ink()
	digit.add_theme_color_override(&"font_color", DARK)
	pop.tween_property(panel, "scale", Vector2.ONE, POP_TIME).set_ease(Tween.EASE_OUT)
	pop.tween_property(look, "bg_color", GLASS, POP_TIME)
	pop.tween_method(func(t: float) -> void: digit.add_theme_color_override(&"font_color", DARK.lerp(_ink(), t)), 0.0, 1.0, POP_TIME)


func _alarm_wrong() -> void:
	state = State.WRONG
	tv.mood = AsciiArt.Mood.BAD
	create_tween().tween_method(_set_alarm, _alarm, 1.0, RECOLOR_TIME)
	var shake := create_tween()
	var rest := _button.position.x
	for offset in SHAKE_STEPS:
		shake.tween_property(_button, "position:x", rest + offset, SHAKE_TIME / SHAKE_STEPS.size())
	# The cells clear once the shake is over; they stay red until the next digit.
	shake.tween_callback(func() -> void:
		code = ""
		_show_code()
		tv.mood = AsciiArt.Mood.IDLE)
	Audio.play_sfx(&"password_wrong")


func _calm_down() -> void:
	state = State.ENTERING
	tv.mood = AsciiArt.Mood.IDLE
	create_tween().tween_method(_set_alarm, _alarm, 0.0, RECOLOR_TIME)


func _grant() -> void:
	state = State.GRANTED
	tv.mood = AsciiArt.Mood.GRANTED
	_granted.visible = true
	_granted.modulate.a = 0.0
	var fade := create_tween().set_parallel()
	fade.tween_property(screen, "modulate:a", 0.0, FADE_TIME)
	fade.tween_property(_granted, "modulate:a", 1.0, FADE_TIME)
	fade.chain().tween_interval(GRANTED_TIME)
	fade.chain().tween_callback(func() -> void: Game.start_round())
	Audio.play_sfx(&"access_granted")


## The colour of the cells, the digits and the button: green, red, or in between.
func _ink() -> Color:
	return PHOSPHOR.lerp(BAD, _alarm)


func _set_alarm(amount: float) -> void:
	_alarm = amount
	var ink := _ink()
	var glow := Color(ink, 0.35)
	for panel in _cells:
		var look := panel.get_theme_stylebox(&"panel") as StyleBoxFlat
		look.border_color = ink
		look.shadow_color = glow
		(panel.get_node("Digit") as Label).add_theme_color_override(&"font_color", ink)
		(panel.get_node("Cursor") as ColorRect).color = ink
	style_button(_button, ink, DARK if _alarm < 0.5 else BAD_TEXT)

