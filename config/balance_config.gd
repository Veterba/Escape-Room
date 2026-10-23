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
## Chance that a dead enemy drops a smoke bomb.
@export var smoke_drop_chance: float = 0.03
## Share of the current gun's full reserve an ammo box gives back.
@export var ammo_box_refill: float = 0.5

@export_group("Enemies")
## An idle enemy wakes up when it sees the player or the player comes this close, in pixels.
@export var enemy_wake_distance: float = 160.0
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
## Damage the blast does to enemies caught in it (the player always loses one heart).
@export var fuse_blast_damage: int = 5
## Blinks per second at the start and at the end of the fuse.
@export var fuse_blink_rate_start: float = 3.0
@export var fuse_blink_rate_end: float = 20.0

@export_group("Rocket Kin")
@export var rocket_hp: int = 6
@export var rocket_speed: float = 40.0
## While wandering, it walks to a random point up to this many pixels away.
@export var rocket_wander_distance: float = 64.0
## Seconds it shakes and shows its aim line before dashing.
@export var rocket_telegraph_time: float = 0.6
@export var rocket_dash_speed: float = 260.0
## Seconds it is stunned after the dash hits something.
@export var rocket_stun_time: float = 1.0

@export_group("Wing Kin")
@export var wing_hp: int = 4
@export var wing_speed: float = 70.0
## The distance it tries to keep from the player.
@export var wing_keep_distance: float = 100.0
## It stops moving while it is within this many pixels of the keep distance.
@export var wing_distance_slack: float = 10.0
## Seconds between spreads.
@export var wing_fire_interval: float = 2.0
@export var wing_bullets: int = 3
## Degrees between two neighbouring bullets of one spread.
@export var wing_spread_step: float = 15.0
@export var wing_bullet_speed: float = 120.0

@export_group("Enemy Arena")
## Wave 1 is the first entry. Waves after the last entry repeat the last entry.
@export var arena_waves: Array[ArenaWave] = []
## Seconds between waves.
@export var arena_wave_interval: float = 30.0
## The next wave starts at once when fewer than this many enemies are alive.
@export var arena_min_alive: int = 3
## Never more than this many enemies alive; a wave that would go over skips the rest.
@export var arena_max_alive: int = 12
## Seconds the spawn effect plays before the enemy appears.
@export var arena_spawn_time: float = 0.8
## Enemies never appear closer than this to the player, in pixels.
@export var arena_spawn_min_distance: float = 120.0
## Enemies appear on floor this many tiles or less from the edge of the map.
@export var arena_spawn_edge_tiles: int = 3
## The code chest is chained shut until this wave starts.
@export var arena_chest_unlock_wave: int = 5
## Seconds E must be held to open the code chest.
@export var code_chest_open_time: float = 2.0
## Crate groups and barrels in the generated arena (placed in mirrored pairs, so even numbers).
@export var arena_crate_groups: int = 10
@export var arena_barrels: int = 10

@export_group("Barrels")
@export var barrel_blast_radius: float = 40.0
## Damage the blast does to enemies (the player always loses one heart).
@export var barrel_damage: int = 8
## Seconds between a barrel being hit and its explosion, so chains go off one by one.
@export var barrel_fuse_time: float = 0.1

@export_group("Labyrinth")
## Size of the maze in cells. Each cell is 2x2 floor tiles plus a wall tile.
@export var maze_cols: int = 16
@export var maze_rows: int = 12
## The generator keeps only mazes where walking the shortest path to the code takes this long.
@export var maze_min_walk_time: float = 40.0
@export var maze_max_walk_time: float = 60.0
@export var maze_officers: int = 4
@export var maze_shades: int = 2
@export var maze_wings: int = 1
## Cells an officer's patrol route walks along.
@export var maze_patrol_cells: int = 5
## Enemies are placed at least this many cells (along the corridors) from the start.
@export var maze_enemy_min_cells: int = 6
## The player sees only this far, in pixels; the rest is dark.
@export var maze_vision_radius: float = 140.0
## Seconds the hourglass adds to the timer, at most once per round.
@export var hourglass_bonus_time: float = 30.0

@export_group("Officer Kin")
@export var officer_hp: int = 8
@export var officer_patrol_speed: float = 45.0
@export var officer_chase_speed: float = 85.0
## The vision cone: how far, and how wide in degrees.
@export var officer_vision_distance: float = 80.0
@export var officer_vision_angle: float = 60.0
## Seconds a chase lasts at most.
@export var officer_chase_time: float = 4.0
## Seconds the officer is stunned after the player breaks free.
@export var officer_stun_time: float = 3.0
## Presses of E that break the handcuffs.
@export var trap_presses: int = 10
## Seconds after breaking free in which officers cannot trap the player again.
@export var trap_immunity_time: float = 3.0

@export_group("Shade Kin")
@export var shade_hp: int = 4
@export var shade_speed: float = 35.0

@export_group("Floor")
## How many rooms a floor has, the start and the objective room included.
@export var floor_min_rooms: int = 6
@export var floor_max_rooms: int = 8
## Chest rooms on a floor (at most; they go at dead ends).
@export var floor_chest_rooms: int = 2
## Tiles of corridor between two rooms side by side.
@export var floor_corridor_tiles: int = 4
## The doors of a fight room close once the player is this many tiles inside it.
@export var floor_lock_inset_tiles: int = 2
## The enemies of a fight room by its depth: the first entry for rooms next to the start, and
## rooms deeper than the list use the last entry.
@export var floor_fights: Array[ArenaWave] = []

@export_group("Password screen")
## The password from the previous escape room task.
@export var password: String = "1234"

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
