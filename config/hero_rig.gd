## How the hero, Telly, holds his gun and shows his face, from the approved hero design: where his
## one hand sits in the front and back views, how the gun kicks and tips, the faces drawn on his
## screen, and his hop when rolling. The values live in config/hero_rig.tres (the fields have no
## defaults here, so the editor never drops a value from that file).
class_name HeroRig
extends Resource

@export_group("Hand and gun")
## Where the hand sits when aiming right, in pixels from the middle of the body (mirrored when
## aiming left). Front view: by the lower corner of the box, just under the screen.
@export var front_hand: Vector2
## Back view: higher, next to the ear. The gun is drawn behind the body then.
@export var back_hand: Vector2
## How far the hand follows the aim around its spot: sideways and up and down, in pixels.
@export var hand_orbit: Vector2
## The back view shows when the aim points up more than this (the sine of the angle; -0.3 is
## about 17 degrees above level).
@export var back_view_below: float
## Where the hero aims from, in pixels from his feet: the middle of the body.
@export var aim_origin: Vector2
## Radians the muzzle kicks up for each pixel of recoil.
@export var kick_per_pixel: float
## Radians the muzzle tips up at the middle of a reload.
@export var reload_tip: float

@export_group("Face")
## Where the inside of the screen starts in a 24x24 frame, in pixels.
@export var face_cell: Vector2
## Faces drawn over the screen: shouting while shooting, X eyes after a hit, and the loading bar
## filling while reloading (one picture per quarter of the reload).
@export var shout_face: Texture2D
@export var hurt_face: Texture2D
@export var reload_faces: Array[Texture2D]
## Seconds the shout and the X eyes stay on the screen.
@export var shout_face_time: float
@export var hurt_face_time: float
## How far the body has dipped in each walk frame, in pixels, so a face drawn over the screen
## dips with it.
@export var walk_dip: PackedInt32Array

@export_group("Roll")
## Pixels the TV hops up at the middle of a roll.
@export var roll_hop: float
