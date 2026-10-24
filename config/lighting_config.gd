## Every light in the game's rooms: one RoomLighting per room type, the lights of glowing room
## objects and how broken lights move. The values live only in res://config/lighting.tres (the
## fields have no defaults here, so the editor never drops a value from that file).
class_name LightingConfig
extends Resource

@export_group("Room types")
@export var control: RoomLighting
@export var server: RoomLighting
@export var lab: RoomLighting
@export var storage: RoomLighting
@export var maze: RoomLighting
@export var arena: RoomLighting
## The Boss Chamber keeps its old look: no tint.
@export var boss_ambient: Color
## Seconds the tint takes to change when the player walks into another room.
@export var tint_fade_time: float

@export_group("Glowing objects")
@export var tank: LightSpec
@export var tank_pink: LightSpec
@export var console: LightSpec
@export var monitor: LightSpec
@export var cryo: LightSpec
## The glow over the code chest in the Enemy Arena.
@export var code_chest: LightSpec

@export_group("Broken lights")
## How fast a broken light drifts between its two colours (radians per second; a full swing
## takes 2 pi divided by this).
@export var drift_speed: float
## Now and then it dims softly: how often (radians per second), how deep (a share of its
## energy) and how short each dip is (higher is shorter).
@export var dim_speed: float
@export var dim_depth: float
@export var dim_sharpness: float

@export_group("Arena alarm")
## The red alarm light that slowly sweeps the Enemy Arena on an oval around its middle.
@export var alarm: LightSpec
## The oval's half width and half height, as a share of the room's inside.
@export var alarm_sweep: Vector2
## Radians per second around the oval.
@export var alarm_speed: float

@export_group("Labyrinth")
## Red emergency lights on the Labyrinth's inner walls (their light is maze.wall_light).
@export var maze_emergency_lights: int


## The lighting of a room type (&"control", &"server", &"lab", &"storage", &"maze", &"arena").
func for_room(room_type: StringName) -> RoomLighting:
	return get(room_type)
