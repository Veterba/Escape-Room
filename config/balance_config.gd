## Every tunable number in the game. The values live in res://config/balance.tres.
class_name BalanceConfig
extends Resource

@export_group("Round")
## Seconds on the round timer.
@export var round_length: float = 600.0
## The timer turns red and pulses when this many seconds are left.
@export var timer_warning_time: float = 60.0
## Seconds the map name is shown at the start of a round.
@export var map_name_show_time: float = 2.0
## Seconds between the win or loss and the end screen, so the last moment can be seen.
@export var end_screen_delay: float = 0.8

@export_group("Player")
@export var player_hearts: int = 3
## Pixels per second.
@export var player_move_speed: float = 110.0
## Seconds the player cannot be hurt again after a hit.
@export var hit_invulnerable_time: float = 1.0
## Blinks per second while invulnerable after a hit.
@export var hit_blink_rate: float = 12.0
@export var smoke_bombs_start: int = 1
## Not used yet: nothing in the spec gives the player more smoke bombs.
@export var smoke_bombs_max: int = 2
## Pixels from the player's feet within which E reaches a chest or a gun on the floor.
@export var interact_range: float = 24.0

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
@export var brass_revolver: GunStats
@export var scattershot: GunStats
@export var fuse_launcher: GunStats
@export var gold_detonator: GunStats
## How many guns the player can carry, the Pop Pistol included.
@export var gun_slots: int = 3
## Seconds E must be held to open a gun chest.
@export var gun_chest_open_time: float = 0.5

@export_group("Drops")
## Chance that a dead enemy drops an ammo box.
@export var ammo_drop_chance: float = 0.10
## Chance that a dead enemy drops a heart.
@export var heart_drop_chance: float = 0.05
## Share of the current gun's full reserve an ammo box gives back.
@export var ammo_box_refill: float = 0.5

@export_group("Enemies")
## Pixels per second an enemy is pushed back when hit; it fades quickly.
@export var enemy_knockback_speed: float = 90.0
## Pixels per second the player is pushed back when hit.
@export var player_knockback_speed: float = 120.0
## How fast any knockback fades, in pixels per second squared.
@export var knockback_decay: float = 900.0

@export_group("Grunt Kin")
@export var grunt_hp: int = 5
@export var grunt_speed: float = 50.0
## The grunt stops walking when it is this close to the player and can see them.
@export var grunt_stop_distance: float = 120.0
## Seconds between shots.
@export var grunt_fire_interval: float = 1.5
@export var grunt_bullet_speed: float = 120.0

@export_group("Fuse Kin")
@export var fuse_hp: int = 3
@export var fuse_speed: float = 90.0
## The fuse starts burning when the Fuse Kin is this close to the player.
@export var fuse_trigger_distance: float = 40.0
## Seconds from the fuse starting to the explosion.
@export var fuse_time: float = 1.2
@export var fuse_blast_radius: float = 36.0
## Blinks per second at the start and at the end of the fuse.
@export var fuse_blink_rate_start: float = 3.0
@export var fuse_blink_rate_end: float = 20.0

@export_group("Camera")
## How fast the camera catches up with the player. Higher is snappier.
@export var camera_smoothing_speed: float = 8.0
@export var screen_shake_enabled: bool = true
## Shake strength in pixels lost per second.
@export var screen_shake_decay: float = 30.0
## Shake strength in pixels when the player is hit.
@export var hit_shake: float = 3.0
## Shake strength in pixels for an explosion.
@export var explosion_shake: float = 4.0

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
