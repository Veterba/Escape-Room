## The numbers and art data for one gun. Each gun is a sub-resource inside balance.tres.
class_name GunStats
extends Resource

## Short name used in the run log, for example "pop_pistol".
@export var id: StringName
## The big drawing: used in the HUD.
@export var icon: Texture2D
## The small drawing (10-16 px long) shown in the hero's hand and for guns lying on the floor.
@export var held_texture: Texture2D
@export var bullet_texture: Texture2D
## Pixel in held_texture where the hand holds the gun. The gun rotates around this point.
@export var grip: Vector2
## Pixel in held_texture where bullets come out.
@export var muzzle: Vector2
## Pixel in held_texture where spent shell casings fly out.
@export var eject: Vector2
@export var ejects_casings: bool = true
## Gold sparkles around the gun in hand. They stay upright when the gun turns.
@export var sparkles: bool = false

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
## Blasts hurt the player too, unless this is off (only the Gold Detonator).
@export var blast_hurts_player: bool = true
## Chance weight when a gun chest picks a gun. 0 means chests never give it.
@export var chest_weight: float = 0.0
## Tint of a gun chest holding this gun, so its colour shows the rarity.
@export var chest_color: Color = Color.WHITE
