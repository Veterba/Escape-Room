## The secret code item, drawn as a key (the approved look): it floats 2 px up and down above a
## small shadow, in a soft golden glow, and a glint runs across it every second or so. Walking
## over it wins, like any code pickup.
class_name KeyPickup
extends Pickup

## The float: pixels up and down, and how fast (radians per second).
const FLOAT_HEIGHT := 2.0
const FLOAT_SPEED := 2.5
## How high the key hangs over its shadow, in pixels (the middle of the key).
const HOVER := 15.0
## The shadow: half its width and height in pixels, and how dark. It shrinks a little as the key
## rises.
const SHADOW_SIZE := Vector2(6.0, 1.6)
const SHADOW_SHRINK := 0.5
const SHADOW_COLOR := Color(0.0, 0.0, 0.0, 0.45)
## The glint: steps per second, the steps in one cycle, and how many of them show the glint.
## It hops 3 px along the key's top on each step it shows, starting from its left side.
const GLINT_RATE := 3.0
const GLINT_STEPS := 6
const GLINT_SHOWN := 2
const GLINT_START := Vector2(-3.0, -5.0)
const GLINT_HOP := 3.0

@onready var _glow: Sprite2D = $Glow
@onready var _glint: Sprite2D = $Glint


func _process(delta: float) -> void:
	_time += delta
	var lift := roundf(sin(_time * FLOAT_SPEED) * FLOAT_HEIGHT)
	_sprite.position.y = -HOVER + lift
	_glow.position.y = _sprite.position.y
	var step := int(_time * GLINT_RATE) % GLINT_STEPS
	_glint.visible = step < GLINT_SHOWN
	_glint.position = Vector2(_sprite.position.x, _sprite.position.y) + GLINT_START + Vector2(step * GLINT_HOP, 0.0)
	queue_redraw()


func _draw() -> void:
	var lift := sin(_time * FLOAT_SPEED) * FLOAT_HEIGHT
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(SHADOW_SIZE.x + lift * SHADOW_SHRINK, SHADOW_SIZE.y))
	draw_circle(Vector2.ZERO, 1.0, SHADOW_COLOR)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
