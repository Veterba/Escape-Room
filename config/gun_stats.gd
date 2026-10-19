## The numbers and art data for one gun. Each gun is a sub-resource inside balance.tres.
class_name GunStats
extends Resource

@export var texture: Texture2D
## Pixel in the texture where the hand holds the gun. The gun rotates around this point.
@export var grip: Vector2
## Pixel in the texture where bullets come out.
@export var muzzle: Vector2
## Pixel in the texture where spent shell casings fly out.
@export var eject: Vector2

@export var damage: int = 1
## Shots per second while the fire button is held.
@export var fire_rate: float = 4.0
@export var magazine_size: int = 8
## Spare ammo outside the magazine. Ignored when infinite_reserve is on.
@export var reserve_ammo: int = 0
@export var infinite_reserve: bool = false
## Seconds a reload takes.
@export var reload_time: float = 1.0
