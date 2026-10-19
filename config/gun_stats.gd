## The numbers and art data for one gun. Each gun is a sub-resource inside balance.tres.
class_name GunStats
extends Resource

## Short name used in the run log, for example "pop_pistol".
@export var id: StringName
@export var texture: Texture2D
@export var bullet_texture: Texture2D
## Pixel in the texture where the hand holds the gun. The gun rotates around this point.
@export var grip: Vector2
## Pixel in the texture where bullets come out.
@export var muzzle: Vector2
## Pixel in the texture where spent shell casings fly out.
@export var eject: Vector2
@export var ejects_casings: bool = true

## Damage of one bullet, or of its blast if blast_radius is above 0.
@export var damage: int = 1
## Shots per second while the fire button is held.
@export var fire_rate: float = 4.0
@export var magazine_size: int = 8
## Spare ammo outside the magazine, and the most the gun can carry. Ignored when infinite_reserve is on.
@export var reserve_ammo: int = 0
@export var infinite_reserve: bool = false
## Seconds a reload takes.
@export var reload_time: float = 1.0
## Bullets per shot, spread evenly over spread_degrees.
@export var pellets: int = 1
@export var spread_degrees: float = 0.0
## Above 0, every bullet explodes with this radius in pixels.
@export var blast_radius: float = 0.0
@export var blast_hurts_player: bool = false
## Chance weight when a gun chest picks a gun. 0 means chests never give it.
@export var chest_weight: float = 0.0
