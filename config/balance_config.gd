## Every tunable number in the game. The values live only in res://config/balance.tres: the fields
## have no defaults here, so the editor never drops a value from that file for matching a default.
class_name BalanceConfig
extends Resource

@export_group("Round")
## Seconds on the round timer (arena and maze; boss rounds have none).
@export var round_length: float
## The timer turns red and pulses when this many seconds are left.
@export var timer_warning_time: float
## Seconds the map name is shown at the start of a round.
@export var map_name_show_time: float
## Seconds between the win or loss and the end screen, so the last moment can be seen.
@export var end_screen_delay: float

@export_group("Player")
@export var player_hearts: int
## Pixels per second.
@export var player_move_speed: float
## Seconds the player cannot be hurt again after a hit.
@export var hit_invulnerable_time: float
## Blinks per second while invulnerable after a hit.
@export var hit_blink_rate: float
@export var smoke_bombs_start: int
@export var smoke_bombs_max: int
## Pixels from the player's feet within which E reaches a chest or a gun on the floor.
@export var interact_range: float

@export_group("Dodge roll")
@export var roll_duration: float
## Pixels covered by one roll.
@export var roll_distance: float
## The player cannot be hurt for this many seconds from the start of a roll.
@export var roll_invulnerable_time: float
## Seconds after a roll ends before the next one can start.
@export var roll_cooldown: float

@export_group("Guns")
## Pixels per second.
@export var player_bullet_speed: float
@export var pop_pistol: GunStats
@export var brass_revolver: GunStats
@export var scattershot: GunStats
@export var fuse_launcher: GunStats
@export var gold_detonator: GunStats
## How many guns the player can carry, the Pop Pistol included.
@export var gun_slots: int
## Seconds E must be held to open a gun chest.
@export var gun_chest_open_time: float

@export_group("Drops")
## Chance that a dead enemy drops an ammo box.
@export var ammo_drop_chance: float
## Chance that a dead enemy drops a heart.
@export var heart_drop_chance: float
## Chance that a dead enemy drops a smoke bomb.
@export var smoke_drop_chance: float
## Share of the current gun's full reserve an ammo box gives back.
@export var ammo_box_refill: float

@export_group("Enemies")
## An idle enemy wakes up when it sees the player or the player comes this close, in pixels.
@export var enemy_wake_distance: float
## Pixels per second an enemy is pushed back when hit; it fades quickly.
@export var enemy_knockback_speed: float
## Pixels per second the player is pushed back when hit.
@export var player_knockback_speed: float
## How fast any knockback fades, in pixels per second squared.
@export var knockback_decay: float

@export_group("Grunt Kin")
@export var grunt_hp: int
@export var grunt_speed: float
## The grunt stops walking when it is this close to the player and can see them.
@export var grunt_stop_distance: float
## Seconds between shots.
@export var grunt_fire_interval: float
@export var grunt_bullet_speed: float
## Seconds before a shot in which its eyes flare and red spots break out, as a warning.
@export var grunt_tell_time: float

@export_group("Fuse Kin")
@export var fuse_hp: int
@export var fuse_speed: float
## The fuse starts burning when the Fuse Kin is this close to the player.
@export var fuse_trigger_distance: float
## Seconds from the fuse starting to the explosion.
@export var fuse_time: float
@export var fuse_blast_radius: float
## Damage the blast does to enemies caught in it (the player always loses one heart).
@export var fuse_blast_damage: int
## Blinks per second at the start and at the end of the fuse.
@export var fuse_blink_rate_start: float
@export var fuse_blink_rate_end: float

@export_group("Rocket Kin")
@export var rocket_hp: int
@export var rocket_speed: float
## While wandering, it walks to a random point up to this many pixels away.
@export var rocket_wander_distance: float
## Seconds it shakes and shows its aim line before dashing.
@export var rocket_telegraph_time: float
@export var rocket_dash_speed: float
## Seconds it is stunned after the dash hits something.
@export var rocket_stun_time: float

@export_group("Wing Kin")
@export var wing_hp: int
@export var wing_speed: float
## The distance it tries to keep from the player.
@export var wing_keep_distance: float
## It stops moving while it is within this many pixels of the keep distance.
@export var wing_distance_slack: float
## Seconds between spreads.
@export var wing_fire_interval: float
@export var wing_bullets: int
## Degrees between two neighbouring bullets of one spread.
@export var wing_spread_step: float
@export var wing_bullet_speed: float
## Seconds before a spread in which its eye opens wide as a warning.
@export var wing_tell_time: float

@export_group("Enemy Arena")
## Wave 1 is the first entry. Waves after the last entry repeat the last entry.
@export var arena_waves: Array[ArenaWave]
## Seconds between waves.
@export var arena_wave_interval: float
## The next wave starts at once when fewer than this many enemies are alive.
@export var arena_min_alive: int
## Never more than this many enemies alive; a wave that would go over skips the rest.
@export var arena_max_alive: int
## Seconds the spawn effect plays before the enemy appears.
@export var arena_spawn_time: float
## Enemies never appear closer than this to the player, in pixels.
@export var arena_spawn_min_distance: float
## Enemies appear on floor this many tiles or less from the edge of the map.
@export var arena_spawn_edge_tiles: int
## The code chest is chained shut until this wave starts. It is also the last wave.
@export var arena_chest_unlock_wave: int
## Seconds E must be held to open the code chest.
@export var code_chest_open_time: float
## Seconds a chest takes to open (the lid lifts and the gun or key rises out), and the code
## chest's chains to break and fall.
@export var chest_open_time: float
@export var code_chest_unchain_time: float
## Crate groups and barrels in the generated arena (placed in mirrored pairs, so even numbers).
@export var arena_crate_groups: int
@export var arena_barrels: int

@export_group("Barrels")
@export var barrel_blast_radius: float
## Damage the blast does to enemies (the player always loses one heart).
@export var barrel_damage: int
## Seconds between a barrel being hit and its explosion, so chains go off one by one.
@export var barrel_fuse_time: float

@export_group("Labyrinth")
## Size of the maze in cells. Each cell is 2x2 floor tiles plus a wall tile.
@export var maze_cols: int
@export var maze_rows: int
## The generator keeps only mazes where walking the shortest path to the code takes this long.
@export var maze_min_walk_time: float
@export var maze_max_walk_time: float
@export var maze_officers: int
@export var maze_shades: int
@export var maze_wings: int
## Cells an officer's patrol route walks along.
@export var maze_patrol_cells: int
## Enemies are placed at least this many cells (along the corridors) from the start.
@export var maze_enemy_min_cells: int
## The player sees only this far, in pixels; the rest is dark.
@export var maze_vision_radius: float
## Seconds the hourglass adds to the timer, at most once per round.
@export var hourglass_bonus_time: float

@export_group("Officer Kin")
@export var officer_hp: int
@export var officer_patrol_speed: float
@export var officer_chase_speed: float
## The vision cone: how far, and how wide in degrees.
@export var officer_vision_distance: float
@export var officer_vision_angle: float
## Seconds a chase lasts at most.
@export var officer_chase_time: float
## Seconds the officer is stunned after the player breaks free.
@export var officer_stun_time: float
## Pixels per second the knife slash throws the officer back (it fades like any knockback).
@export var officer_escape_push: float
## Presses of E that break the handcuffs.
@export var trap_presses: int
## Seconds after breaking free in which officers cannot trap the player again.
@export var trap_immunity_time: float

@export_group("Shade Kin")
@export var shade_hp: int
@export var shade_speed: float
## Seconds between its twitches and teleports (random between the two).
@export var shade_event_min: float
@export var shade_event_max: float
## Chance that the next event is a twitch (looks only) rather than a teleport.
@export var shade_twitch_chance: float
@export var shade_twitch_time: float
## A teleport: seconds to tear apart (and to unfold again), seconds gone, and how far from the
## player it appears (random between the two, in pixels).
@export var shade_tear_time: float
@export var shade_gone_time: float
@export var shade_appear_min: float
@export var shade_appear_max: float

@export_group("Root (the boss)")
@export var root_hp: int
## Share of hit points where phase 2 and phase 3 start (0.66 = 66 %).
@export var root_phase2_at: float
@export var root_phase3_at: float
## Seconds it roars between phases (it cannot be hit then), and how hard the screen shakes.
@export var root_phase_pause: float
@export var root_roar_shake: float
## In phase 3 its clocks and bullets run this many times faster.
@export var root_phase3_speedup: float
## Phases 1-2: seconds between glides to a new point in the upper half of the room (random
## between the two), and how quickly it closes in on that point (share of the way per second).
@export var root_glide_min: float
@export var root_glide_max: float
@export var root_glide_follow: float
## Belt Lash: seconds between lashes, how long one lasts, seconds between the pairs of bullets
## it fires, the degrees each of its two arms sweeps (they cross), and the bullets' speed.
@export var root_lash_interval: float
@export var root_lash_time: float
@export var root_lash_fire_interval: float
@export var root_lash_arc: float
@export var root_lash_bullet_speed: float
## Bullet Rain (from phase 2): seconds between rings, bullets in a ring, seconds it winds up
## (the loading spinner) before firing, and the bullets' speed.
@export var root_rain_interval: float
@export var root_rain_bullets: int
@export var root_rain_windup: float
@export var root_rain_bullet_speed: float
## Teleport (from phase 2): seconds between teleports, how far from the player it lands at
## least, and the seconds it takes to close, stay gone and open again.
@export var root_teleport_interval: float
@export var root_teleport_min_distance: float
@export var root_teleport_out_time: float
@export var root_teleport_gone_time: float
@export var root_teleport_in_time: float
## Phase 3: seconds the error windows take to fly off, then the main window alone: seconds
## between teleports and the least distance from the player, the ring after each teleport
## (bullets, speed), the aimed burst between teleports (seconds between, bullets, degrees
## between bullets, speed), and its glides (seconds between, follow, least distance from the
## player).
@export var root_split_time: float
@export var root_phase3_teleport_interval: float
@export var root_phase3_teleport_min_distance: float
@export var root_phase3_ring_bullets: int
@export var root_phase3_ring_speed: float
@export var root_burst_interval: float
@export var root_burst_bullets: int
@export var root_burst_spread: float
@export var root_burst_speed: float
@export var root_phase3_glide_interval: float
@export var root_phase3_glide_follow: float
@export var root_phase3_glide_min_distance: float

@export_group("Error windows (Root, phase 3)")
@export var error_window_hp: int
## They keep between these distances from the player (pixels), moving this fast.
@export var error_window_min_distance: float
@export var error_window_max_distance: float
@export var error_window_speed: float
## Seconds between aimed shots (random between the two), the title bar's warning before each,
## and the bullet's speed.
@export var error_window_fire_min: float
@export var error_window_fire_max: float
@export var error_window_warning_time: float
@export var error_window_bullet_speed: float
## Their own teleports: seconds between (random between the two), seconds to close, gone and
## open, and the least distance from the player where they land.
@export var error_window_teleport_min: float
@export var error_window_teleport_max: float
@export var error_window_teleport_out_time: float
@export var error_window_teleport_gone_time: float
@export var error_window_teleport_in_time: float
@export var error_window_teleport_min_distance: float
## Seconds a destroyed error window stays gone before it comes back.
@export var error_window_return_time: float

@export_group("Floor")
## How many rooms a floor has, the start and the objective room included.
@export var floor_min_rooms: int
@export var floor_max_rooms: int
## Chest rooms on a floor (at most; they go at dead ends).
@export var floor_chest_rooms: int
## Tiles of corridor between two rooms side by side.
@export var floor_corridor_tiles: int
## The doors of a fight room close once the player is this many tiles inside it.
@export var floor_lock_inset_tiles: int
## The enemies of a fight room by its depth: the first entry for rooms next to the start, and
## rooms deeper than the list use the last entry.
@export var floor_fights: Array[ArenaWave]

@export_group("Password screen")
## The password from the previous escape room task.
@export var password: String

@export_group("Camera")
## How fast the camera catches up with the player. Higher is snappier.
@export var camera_smoothing_speed: float
@export var screen_shake_enabled: bool
## Shake strength in pixels lost per second.
@export var screen_shake_decay: float
## Shake strength in pixels when the player is hit.
@export var hit_shake: float
## Shake strength in pixels for an explosion.
@export var explosion_shake: float

@export_group("Juice")
## Pixels the sprite rises at the top of each step.
@export var walk_bob_height: float
## Footsteps per second while walking.
@export var walk_step_rate: float
## How much the sprite squashes on each footstep (0.1 = 10 %).
@export var footstep_squash: float
## Seconds for a squash to spring back to normal.
@export var squash_return_time: float
## Seconds the sprite stays white after a hit.
@export var hit_flash_time: float
## Seconds the muzzle flash is visible.
@export var muzzle_flash_time: float
## Pixels the gun and the hand jump back on each shot.
@export var recoil_kick: float
## Seconds for the gun and the hand to come back after the kick.
@export var recoil_return_time: float

@export_group("Shell casings")
## Sideways speed in pixels per second when a casing is ejected.
@export var casing_eject_speed: float
## Random variation of the eject speeds (0.3 = up to 30 % faster or slower), so casings scatter.
@export var casing_randomness: float
## Upward speed of a casing when it is ejected, in pixels per second.
@export var casing_eject_lift: float
## Pulls the casing back to the floor, in pixels per second squared.
@export var casing_gravity: float
## Share of the speed kept on each bounce.
@export var casing_bounciness: float
## How many times a casing bounces before it settles for good.
@export var casing_bounces: int
## Spin in radians per second while the casing is in the air.
@export var casing_spin: float
