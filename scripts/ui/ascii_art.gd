## A picture made of text characters, drawn one character per cell: the menu TV (read from
## art/game/menu_tv.txt) or a generated panel (the pause menu). Because every cell is drawn on its
## own, the picture can boot up row by row out of noise and shimmer: a few characters at a time
## step one level lighter or denser on the ramp and settle back.
class_name AsciiArt
extends Control

## Emitted when the boot-up has drawn the last row.
signal booted

enum Mood { IDLE, BAD, GRANTED }

const FONT := preload("res://art/fonts/JetBrainsMono-ExtraBold.ttf")
## Characters from light to dense. Noise, shimmer and generated panels use it.
const RAMP := " .:+*?%S#@"
const PHOSPHOR := Color("#46ff8f")
## The font is a little larger than the cell, as in the approved design.
const FONT_SCALE := 1.02

## Boot-up: rows revealed per step, seconds per step, and how many rows of noise lead the way.
const BOOT_ROWS_PER_STEP := 2
const BOOT_STEP_TIME := 0.022
const BOOT_NOISE_ROWS := 4
## Shimmer: seconds between steps, characters changed per step in each mood (for a picture the
## size of the menu TV; smaller pictures change fewer), and how long a changed character stays
## changed (random between the two).
const SHIMMER_STEP_TIME := 0.09
const SHIMMER_IDLE := 18
const SHIMMER_BAD := 140
const SHIMMER_GRANTED := 200
const SHIMMER_FULL_CELLS := 89 * 68
const SHIMMER_HOLD_MIN := 0.18
const SHIMMER_HOLD_MAX := 0.5
## Typing adds this much extra shimmer, which fades by BURST_FADE per step.
const BURST_ON_TYPE := 40
const BURST_FADE := 6

## A generated panel: from the outside in, the bands of its frame (ramp levels, each one cell
## wide), then the field inside. Characters drift one level either way at random, so the panel
## looks drawn by hand like the TV; the same seed always gives the same panel.
const PANEL_BANDS: Array[int] = [2, 6, 9, 8, 5]
const PANEL_FIELD := 2
## Share of the field's characters that drift a level, so the field reads as even dots like the
## TV's screen.
const PANEL_FIELD_NOISE := 0.12
const PANEL_CORNER := 2

var mood := Mood.IDLE
## Pixels per cell: its height (the characters are this big), and its width, which can be wider
## to spread the picture across a wide screen (the characters keep their shape).
var cell := 1.0
var cell_width := 1.0
var columns := 0
var rows := 0

var _art: Array[PackedStringArray] = []
var _shown: Array[PackedStringArray] = []
## Characters changed by the shimmer: [row, column, seconds left].
var _changed: Array[Array] = []
var _burst := 0
var _booting := true
var _boot_row := 0
var _step_left := 0.0


## The lines of a character grid file.
static func read_file(path: String) -> PackedStringArray:
	return FileAccess.get_file_as_string(path).split("\n", false)


## A panel `size` cells big: a dense frame with rounded corners around a light dotted field.
static func panel(size: Vector2i, seed_number: int) -> PackedStringArray:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_number
	var lines := PackedStringArray()
	for y in size.y:
		var line := ""
		for x in size.x:
			var edge := mini(mini(x, y), mini(size.x - 1 - x, size.y - 1 - y))
			var corner := Vector2(mini(x, size.x - 1 - x), mini(y, size.y - 1 - y))
			if corner.x + corner.y < PANEL_CORNER:
				line += " "
				continue
			var level := PANEL_FIELD
			if edge < PANEL_BANDS.size():
				level = PANEL_BANDS[edge] + rng.randi_range(-1, 1)
			elif rng.randf() < PANEL_FIELD_NOISE:
				level += rng.randi_range(-1, 1)
			level = clampi(level, 1, RAMP.length() - 1)
			line += RAMP[level]
		lines.append(line)
	return lines


## Shows `lines` (all the same length) and boots it up from the top.
func set_art(lines: PackedStringArray) -> void:
	_art.clear()
	for line in lines:
		var row := PackedStringArray()
		for character in line:
			row.append(character)
		_art.append(row)
	rows = _art.size()
	columns = _art[0].size()
	boot()


## Starts the boot-up again from the first row.
func boot() -> void:
	_shown = _blank()
	_changed.clear()
	_booting = true
	_boot_row = 0
	_step_left = 0.0
	mood = Mood.IDLE


## Size the picture to `pixels` per character, and `width` pixels per column (square cells if
## left out).
func set_cell_size(pixels: float, width := 0.0) -> void:
	cell = pixels
	cell_width = width if width > 0.0 else pixels
	size = Vector2(columns * cell_width, rows * cell)
	queue_redraw()


## A burst of extra shimmer, when a digit is typed.
func shimmer_burst() -> void:
	_burst = BURST_ON_TYPE


func _process(delta: float) -> void:
	if _art.is_empty():
		return
	_step_left -= delta
	if _step_left > 0.0:
		return
	if _booting:
		_step_left = BOOT_STEP_TIME
		_boot_step()
	else:
		_step_left = SHIMMER_STEP_TIME
		_shimmer_step()
	queue_redraw()


func _draw() -> void:
	var font_size := int(round(cell * FONT_SCALE))
	var baseline := (cell - FONT.get_height(font_size)) / 2.0 + FONT.get_ascent(font_size)
	for y in _shown.size():
		for x in _shown[y].size():
			var character := _shown[y][x]
			if character == " ":
				continue
			var width := FONT.get_char_size(character.unicode_at(0), font_size).x
			draw_char(FONT, Vector2(x * cell_width + (cell_width - width) / 2.0, y * cell + baseline), character, font_size, PHOSPHOR)


## Rows above the boot line are the real picture, the next few are noise, the rest still empty.
func _boot_step() -> void:
	for y in rows:
		for x in columns:
			var real := _art[y][x]
			if y < _boot_row:
				_shown[y][x] = real
			elif y < _boot_row + BOOT_NOISE_ROWS and real != " ":
				_shown[y][x] = RAMP[randi_range(1, RAMP.length() - 1)]
			else:
				_shown[y][x] = " "
	_boot_row += BOOT_ROWS_PER_STEP
	if _boot_row >= rows + BOOT_NOISE_ROWS:
		_booting = false
		_shown = _copy(_art)
		booted.emit()


## Puts back characters whose time is up, then nudges a few new ones along the ramp. Idle, a
## character moves one step either way; upset (wrong code, access granted), up to two steps.
func _shimmer_step() -> void:
	for change in _changed:
		change[2] -= SHIMMER_STEP_TIME
		if change[2] <= 0.0:
			_shown[change[0]][change[1]] = _art[change[0]][change[1]]
	_changed = _changed.filter(func(change: Array) -> bool: return change[2] > 0.0)
	var count := SHIMMER_IDLE + _burst
	match mood:
		Mood.BAD:
			count = SHIMMER_BAD
		Mood.GRANTED:
			count = SHIMMER_GRANTED
	count = ceili(count * float(rows * columns) / SHIMMER_FULL_CELLS)
	for i in count:
		var y := randi_range(0, rows - 1)
		var x := randi_range(0, columns - 1)
		var real := _art[y][x]
		if real == " ":
			continue
		var step := (1 if randf() < 0.5 else -1) if mood == Mood.IDLE else randi_range(-2, 1)
		var level := clampi(RAMP.find(real) + step, 1, RAMP.length() - 1)
		_shown[y][x] = RAMP[level]
		_changed.append([y, x, randf_range(SHIMMER_HOLD_MIN, SHIMMER_HOLD_MAX)])
	_burst = maxi(0, _burst - BURST_FADE)


func _blank() -> Array[PackedStringArray]:
	var blank: Array[PackedStringArray] = []
	for y in rows:
		var row := PackedStringArray()
		row.resize(columns)
		row.fill(" ")
		blank.append(row)
	return blank


func _copy(lines: Array[PackedStringArray]) -> Array[PackedStringArray]:
	var copy: Array[PackedStringArray] = []
	for row in lines:
		copy.append(row.duplicate())
	return copy
