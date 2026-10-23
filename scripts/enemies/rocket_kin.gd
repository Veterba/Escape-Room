## Rocket Kin: wanders until it can see the player. Then it shakes for 0.6 s with a red line
## showing where it will go, dashes in a straight line until it hits something, and is
## stunned for 1 s. Touching it costs a heart.
## Looks: the Ram, a heavy robot with a dozer blade; its visor flares while it telegraphs.
class_name RocketKin
extends Enemy

enum Mode { WANDER, TELEGRAPH, DASH, STUN }

## Pixels the sprite shakes sideways while telegraphing.
const SHAKE := 1.0
## Length of the red aim line in pixels.
const AIM_LINE_LENGTH := 48.0

var mode := Mode.WANDER
## Seconds left in the telegraph or the stun.
var _mode_left := 0.0
var _dash_direction := Vector2.ZERO
var _wander_point := Vector2.ZERO
var _has_wander_point := false

@onready var _aim_line: Line2D = $AimLine
@onready var _contact: Area2D = $Contact


func _ready() -> void:
	hp = Config.balance.rocket_hp


func _physics_process(delta: float) -> void:
	var cfg := Config.balance
	var player := target_player()
	hurt_touching_player(_contact)
	match mode:
		Mode.WANDER:
			_wander(delta, player)
		Mode.TELEGRAPH:
			move(Vector2.ZERO, delta)
			body.play(&"tell")
			body.position.x += roundf(randf_range(-SHAKE, SHAKE))
			_mode_left -= delta
			if _mode_left <= 0.0:
				mode = Mode.DASH
				_aim_line.visible = false
				Audio.play_sfx(&"rocket_dash")
		Mode.DASH:
			move(_dash_direction * cfg.rocket_dash_speed, delta)
			if get_slide_collision_count() > 0:
				mode = Mode.STUN
				_mode_left = cfg.rocket_stun_time
		Mode.STUN:
			move(Vector2.ZERO, delta)
			_mode_left -= delta
			if _mode_left <= 0.0:
				mode = Mode.WANDER


## Walks to random nearby points. Seeing the player starts the telegraph, aimed where they stand now.
func _wander(delta: float, player: Player) -> void:
	var cfg := Config.balance
	if player == null:
		move(Vector2.ZERO, delta)
		return
	if can_see(player.hurtbox_position()):
		mode = Mode.TELEGRAPH
		_mode_left = cfg.rocket_telegraph_time
		_dash_direction = global_position.direction_to(player.global_position)
		_aim_line.points = [Vector2.ZERO, _dash_direction * AIM_LINE_LENGTH]
		_aim_line.visible = true
		_has_wander_point = false
		move(Vector2.ZERO, delta)
		return
	if not _has_wander_point or _nav.is_navigation_finished():
		_wander_point = global_position + Vector2.from_angle(randf() * TAU) * cfg.rocket_wander_distance
		_has_wander_point = true
	move(path_velocity(_wander_point, cfg.rocket_speed), delta)

