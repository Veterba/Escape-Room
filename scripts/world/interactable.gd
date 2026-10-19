## Base for things the player uses with E: shows an "E" prompt and a hold bar while in focus.
## Subclasses override can_interact() and interact().
class_name Interactable
extends Node2D

const PROMPT_FONT_SIZE := 16
const BAR_SIZE := Vector2(16, 3)
const PROMPT_COLOR := Color("#F3E7D3")
const BAR_BACK_COLOR := Color("#0B0810")
const BAR_FILL_COLOR := Color("#F0B43C")

## Seconds E must be held to use it. 0 means a single press.
var hold_time := 0.0
## Pixels above the node's origin where the prompt is drawn.
@export var prompt_height := 20.0

var _focused := false
var _progress := 0.0


func _enter_tree() -> void:
	add_to_group(&"interactables")


func can_interact() -> bool:
	return true


func interact(_player: Player) -> void:
	pass


## Shows or hides the prompt; `progress` (0 to 1) fills the hold bar.
func set_focus(focused: bool, progress: float) -> void:
	_focused = focused
	_progress = progress
	queue_redraw()


func _draw() -> void:
	if not _focused:
		return
	var font := ThemeDB.fallback_font
	var text_width := font.get_string_size(Strings.INTERACT_PROMPT, HORIZONTAL_ALIGNMENT_LEFT, -1, PROMPT_FONT_SIZE).x
	draw_string(font, Vector2(-text_width / 2.0, -prompt_height), Strings.INTERACT_PROMPT,
			HORIZONTAL_ALIGNMENT_LEFT, -1, PROMPT_FONT_SIZE, PROMPT_COLOR)
	if hold_time > 0.0:
		var bar := Rect2(Vector2(-BAR_SIZE.x / 2.0, -prompt_height + 3.0), BAR_SIZE)
		draw_rect(bar, BAR_BACK_COLOR)
		draw_rect(Rect2(bar.position, Vector2(bar.size.x * _progress, bar.size.y)), BAR_FILL_COLOR)
