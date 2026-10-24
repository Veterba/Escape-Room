## The light of one room type (retexture spec, "Lighting"): a dark tint over everything in the
## room, the room's wall lights, its broken light and a soft light in its middle.
class_name RoomLighting
extends Resource

## The dark tint over the whole room. Lights add their colour on top of it.
@export var ambient: Color
## Every wall light of the room (lamps; strip lights in the server hall; red emergency lights in
## the maze).
@export var wall_light: LightSpec
## How much the wall lights' brightness swings, as a share of their energy (0 is steady), and how
## fast (radians per second).
@export var breathe: float
@export var breathe_speed: float
## The broken light starts at its colour here and drifts to broken_to and back (energy 0: the
## room has no broken light).
@export var broken: LightSpec
@export var broken_to: Color
## A soft light in the middle of the room (energy 0: none).
@export var fill: LightSpec
