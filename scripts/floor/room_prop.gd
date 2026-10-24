## A room object or floor detail: a picture standing on its position (the middle of its bottom
## edge). Animated objects play their strip of frames on a loop, each from its own random frame.
class_name RoomProp
extends Sprite2D

var fps := 0.0
var _time := 0.0


## A prop named in RoomStyles.PROPS (or a floor detail) standing at `base`.
static func make(prop: StringName, base: Vector2) -> RoomProp:
	var sprite := RoomProp.new()
	sprite.texture = RoomStyles.texture(prop)
	if RoomStyles.PROPS.has(prop):
		sprite.hframes = RoomStyles.PROPS[prop][0]
		sprite.fps = RoomStyles.PROPS[prop][1]
	sprite.offset = Vector2(0, -sprite.texture.get_height() / 2.0)
	sprite.position = base
	return sprite


func _ready() -> void:
	_time = randf() * hframes
	set_process(hframes > 1)


func _process(delta: float) -> void:
	_time += delta * fps
	frame = int(_time) % hframes
