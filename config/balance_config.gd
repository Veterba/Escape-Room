## Every tunable number in the game. The values live in res://config/balance.tres.
class_name BalanceConfig
extends Resource

@export_group("Player")
@export var player_hearts: int = 3
## Pixels per second.
@export var player_move_speed: float = 110.0
@export var smoke_bombs_start: int = 1

@export_group("Dodge roll")
@export var roll_duration: float = 0.45
## Pixels covered by one roll.
@export var roll_distance: float = 70.0
## The player cannot be hurt for this many seconds from the start of a roll.
@export var roll_invulnerable_time: float = 0.35
## Seconds after a roll ends before the next one can start.
@export var roll_cooldown: float = 0.6

@export_group("Guns")
## Pixels per second.
@export var player_bullet_speed: float = 300.0
@export var pop_pistol: GunStats

@export_group("Camera")
## How fast the camera catches up with the player. Higher is snappier.
@export var camera_smoothing_speed: float = 8.0
@export var screen_shake_enabled: bool = true
## Shake strength in pixels lost per second.
@export var screen_shake_decay: float = 30.0

@export_group("Juice")
## Pixels the sprite rises at the top of each step.
@export var walk_bob_height: float = 2.0
## Footsteps per second while walking.
@export var walk_step_rate: float = 6.0
## How much the sprite squashes on each footstep (0.1 = 10 %).
@export var footstep_squash: float = 0.12
## How much the sprite squashes at the start of a roll.
@export var roll_squash: float = 0.25
## Seconds for a squash to spring back to normal.
@export var squash_return_time: float = 0.12
## Seconds the sprite stays white after a hit.
@export var hit_flash_time: float = 0.08
## Seconds the muzzle flash is visible.
@export var muzzle_flash_time: float = 0.05
## Pixels the gun kicks back on each shot.
@export var recoil_kick: float = 2.0
## Seconds for the gun to return after the kick.
@export var recoil_return_time: float = 0.08

@export_group("Shell casings")
## Sideways speed in pixels per second when a casing is ejected.
@export var casing_eject_speed: float = 50.0
## Random variation of the eject speeds (0.3 = up to 30 % faster or slower), so casings scatter.
@export var casing_randomness: float = 0.3
## Upward speed of a casing when it is ejected, in pixels per second.
@export var casing_eject_lift: float = 80.0
## Pulls the casing back to the floor, in pixels per second squared.
@export var casing_gravity: float = 500.0
## Share of the speed kept on each bounce.
@export var casing_bounciness: float = 0.4
## How many times a casing bounces before it settles for good.
@export var casing_bounces: int = 2
## Spin in radians per second while the casing is in the air.
@export var casing_spin: float = 18.0
