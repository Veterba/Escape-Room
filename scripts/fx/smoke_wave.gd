## The smoke bomb's wave: a ring that rushes out from the player to the edge of the screen and
## fades, so it is clear that every enemy bullet on screen was wiped out.
extends Node2D

const COLOR := Color("#F3E7D3")
## The ring reaches past the corners of the 640x360 view.
const END_RADIUS := 380.0
const WIDTH := 3.0
const TIME := 0.35

var _radius := 0.0


func _ready() -> void:
	var wave := create_tween().set_parallel()
	wave.tween_property(self, "_radius", END_RADIUS, TIME).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	wave.tween_property(self, "modulate:a", 0.0, TIME)
	wave.chain().tween_callback(queue_free)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 64, COLOR, WIDTH)
