## Officer Kin: patrols fixed waypoints back and forth. If the player steps into his vision cone
## (80 px, 60 degrees) he chases for up to 4 s. Touching the player handcuffs them (no heart
## lost, only time). When the player breaks free he is stunned for 3 s. He never shoots.
## Looks: the Watcher, a dome camera on wheels; it stares and lights up while it chases.
class_name OfficerKin
extends Enemy

enum Mode { PATROL, CHASE, CUFFING, STUN }

## How close counts as reaching a waypoint, in pixels. More than the Nav agent's 6 px, where it stops.
const WAYPOINT_REACHED := 8.0

## The patrol route in global pixels. He walks to the last one, then back to the first.
var waypoints: Array[Vector2] = []
var mode := Mode.PATROL
var _waypoint := 0
var _route_step := 1
## Seconds left in the chase or the stun.
var _mode_left := 0.0
## Where he looks: the way he last walked.
var _facing := Vector2.DOWN

@onready var _contact: Area2D = $Contact


func _ready() -> void:
	hp = Config.balance.officer_hp


func _physics_process(delta: float) -> void:
	var cfg := Config.balance
	var player := get_tree().get_first_node_in_group(&"player") as Player
	_cuff_touching_player()
	var desired := Vector2.ZERO
	match mode:
		Mode.PATROL:
			if player and sees(player):
				mode = Mode.CHASE
				_mode_left = cfg.officer_chase_time
			else:
				desired = _patrol_velocity()
		Mode.CHASE:
			_mode_left -= delta
			if player == null or player.state == Player.State.DEAD or _mode_left <= 0.0:
				mode = Mode.PATROL
			else:
				desired = path_velocity(player.global_position, cfg.officer_chase_speed)
		Mode.STUN:
			_mode_left -= delta
			if _mode_left <= 0.0:
				mode = Mode.PATROL
	move(desired, delta)
	if mode == Mode.CHASE:
		body.play(&"tell")
	if desired != Vector2.ZERO:
		_facing = desired.normalized()
	body.flip_h = _facing.x < 0.0


## True if the player is inside the vision cone and no wall is in between.
func sees(player: Player) -> bool:
	var cfg := Config.balance
	var to_player := player.global_position - global_position
	if to_player.length() > cfg.officer_vision_distance:
		return false
	if absf(_facing.angle_to(to_player)) > deg_to_rad(cfg.officer_vision_angle) / 2.0:
		return false
	return can_see(player.hurtbox_position())


## Called by the player on breaking free: stunned, and thrown back along `away`, so he is not
## still touching the player when the stun wears off.
func stun(away: Vector2) -> void:
	mode = Mode.STUN
	_mode_left = Config.balance.officer_stun_time
	_knockback = away.normalized() * Config.balance.officer_escape_push


func _patrol_velocity() -> Vector2:
	if waypoints.is_empty():
		return Vector2.ZERO
	if global_position.distance_to(waypoints[_waypoint]) <= WAYPOINT_REACHED:
		if _waypoint + _route_step < 0 or _waypoint + _route_step >= waypoints.size():
			_route_step = -_route_step
		_waypoint = clampi(_waypoint + _route_step, 0, waypoints.size() - 1)
	return path_velocity(waypoints[_waypoint], Config.balance.officer_patrol_speed)


## Handcuffs a player he touches. He waits beside them until they break free.
func _cuff_touching_player() -> void:
	if mode == Mode.STUN or mode == Mode.CUFFING:
		return
	for area in _contact.get_overlapping_areas():
		var player := area.owner as Player
		if player.trap(self):
			mode = Mode.CUFFING
			Audio.play_sfx(&"handcuffs")
