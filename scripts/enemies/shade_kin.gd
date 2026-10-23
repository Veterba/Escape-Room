## Shade Kin: drifts slowly straight at the player, through walls, half see-through. Every 3-6 s
## it either twitches (looks only) or teleports: it tears apart (0.4 s), is gone (0.35 s) and
## appears again 50-90 px from the player (0.4 s). While teleporting it cannot hurt or be hit.
## Touching it costs a heart.
## Looks: the Glitch, a ghost file with one eye. It tears into slipping rows and squeezes into a
## bright line, with a few sparks where it leaves and where it appears.
class_name ShadeKin
extends Enemy

enum Mode { FLOAT, TWITCH, TEAR, GONE, UNFOLD }

const SPARKS := preload("res://scenes/fx/impact_spark.tscn")
## How see-through it is (1 is solid).
const ALPHA := 0.72
## During a twitch the picture jumps up to this many pixels sideways.
const TWITCH_JUMP := 2.0

var mode := Mode.FLOAT
## Seconds left in the twitch or the current step of a teleport.
var _mode_left := 0.0
## Seconds until the next twitch or teleport.
var _next_event := 0.0

@onready var _contact: Area2D = $Contact
@onready var _hitbox_shape: CollisionShape2D = $Hitbox/Shape
@onready var _shadow: Node2D = $Shadow


func _ready() -> void:
	hp = Config.balance.shade_hp
	body.modulate.a = ALPHA
	_next_event = randf_range(Config.balance.shade_event_min, Config.balance.shade_event_max)


## True while it tears apart, is gone or unfolds again: it cannot hurt or be hit then.
func is_teleporting() -> bool:
	return mode == Mode.TEAR or mode == Mode.GONE or mode == Mode.UNFOLD


func take_damage(amount: int, direction: Vector2) -> void:
	if not is_teleporting():
		super.take_damage(amount, direction)


## Tears apart now; it reappears near the player.
func start_teleport() -> void:
	_set_mode(Mode.TEAR, Config.balance.shade_tear_time)
	_hitbox_shape.set_deferred(&"disabled", true)
	_spark()


func _physics_process(delta: float) -> void:
	var cfg := Config.balance
	var player := target_player()
	var desired := Vector2.ZERO
	if not is_teleporting():
		hurt_touching_player(_contact)
		if player:
			desired = global_position.direction_to(player.global_position) * cfg.shade_speed
	move(desired, delta)
	_update_mode(delta, player)


func _update_mode(delta: float, player: Player) -> void:
	var cfg := Config.balance
	_mode_left -= delta
	match mode:
		Mode.FLOAT:
			if player == null:
				return
			_next_event -= delta
			if _next_event <= 0.0:
				if randf() < cfg.shade_twitch_chance:
					_set_mode(Mode.TWITCH, cfg.shade_twitch_time)
				else:
					start_teleport()
		Mode.TWITCH:
			body.play(&"twitch")
			body.position.x += roundf(randf_range(-TWITCH_JUMP, TWITCH_JUMP))
			if _mode_left <= 0.0:
				_back_to_float()
		Mode.TEAR:
			var torn := 1.0 - clampf(_mode_left / cfg.shade_tear_time, 0.0, 1.0)
			_show_teleport_frame(torn)
			if _mode_left <= 0.0:
				_set_mode(Mode.GONE, cfg.shade_gone_time)
				body.visible = false
				_shadow.visible = false
		Mode.GONE:
			if _mode_left <= 0.0:
				var target := player.global_position if player else global_position
				global_position = target + Vector2.from_angle(randf() * TAU) * randf_range(cfg.shade_appear_min, cfg.shade_appear_max)
				reset_physics_interpolation()  # A jump, not a fast move.
				body.visible = true
				_shadow.visible = true
				_spark()
				_set_mode(Mode.UNFOLD, cfg.shade_tear_time)
		Mode.UNFOLD:
			var torn := clampf(_mode_left / cfg.shade_tear_time, 0.0, 1.0)
			_show_teleport_frame(torn)
			if _mode_left <= 0.0:
				_hitbox_shape.set_deferred(&"disabled", false)
				_back_to_float()


## `torn` goes from 0 (whole) to 1 (squeezed into a line): the teleport frames, and the shadow
## fading with it.
func _show_teleport_frame(torn: float) -> void:
	body.animation = &"teleport"
	body.frame = mini(int(torn * body.sprite_frames.get_frame_count(&"teleport")), body.sprite_frames.get_frame_count(&"teleport") - 1)
	_shadow.modulate.a = 1.0 - torn


func _set_mode(new_mode: Mode, seconds: float) -> void:
	mode = new_mode
	_mode_left = seconds


func _back_to_float() -> void:
	var cfg := Config.balance
	mode = Mode.FLOAT
	_shadow.modulate.a = 1.0
	_next_event = randf_range(cfg.shade_event_min, cfg.shade_event_max)


func _spark() -> void:
	var spark: Node2D = SPARKS.instantiate()
	spark.global_position = body.global_position
	get_tree().current_scene.add_child.call_deferred(spark)
