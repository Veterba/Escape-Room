## A coloured light in a room (config/lighting.tres). Steady, breathing (its brightness swings
## gently), broken (it drifts slowly between two colours and now and then dims softly, never a
## hard on and off) or sweeping (it moves on an oval, like the arena's alarm light). An object
## lit by it, such as the tube of a broken light, can be tinted with its colour.
class_name RoomLight
extends PointLight2D

enum Kind { STEADY, BREATHING, BROKEN, SWEEPING }

const GLOW := preload("res://scenes/fx/light_glow.tres")

var kind := Kind.STEADY
var spec: LightSpec
## Breathing: how much of its energy it swings and how fast (radians per second).
var breathe := 0.0
var breathe_speed := 0.0
## Broken: the colour it drifts to.
var broken_to: Color
## Sweeping: the middle of the oval and its half width and height, in pixels.
var sweep_center := Vector2.ZERO
var sweep := Vector2.ZERO
## Tinted with the light's colour and brightness (or null).
var tinted: CanvasItem
var _time := 0.0


static func make(light_spec: LightSpec, at: Vector2) -> RoomLight:
	var light := RoomLight.new()
	light.spec = light_spec
	light.position = at
	return light


func _ready() -> void:
	texture = GLOW
	# The glow texture's radius is half its width at scale 1.
	texture_scale = spec.radius / (GLOW.get_width() / 2.0)
	color = spec.color
	energy = spec.energy
	_time = randf() * TAU / maxf(Config.lighting.drift_speed, 0.01)
	set_process(kind != Kind.STEADY)
	_tint()


func _process(delta: float) -> void:
	var cfg := Config.lighting
	_time += delta
	match kind:
		Kind.BREATHING:
			energy = spec.energy * (1.0 + breathe * sin(_time * breathe_speed))
		Kind.BROKEN:
			color = spec.color.lerp(broken_to, (sin(_time * cfg.drift_speed) + 1.0) / 2.0)
			var dip := pow(maxf(0.0, sin(_time * cfg.dim_speed)), cfg.dim_sharpness)
			energy = spec.energy * (1.0 - cfg.dim_depth * dip)
		Kind.SWEEPING:
			var angle := _time * Config.lighting.alarm_speed
			position = sweep_center + Vector2(cos(angle) * sweep.x, sin(angle) * sweep.y)
	_tint()


func _tint() -> void:
	if tinted:
		var brightness := energy / spec.energy
		tinted.modulate = Color(color.r * brightness, color.g * brightness, color.b * brightness)
