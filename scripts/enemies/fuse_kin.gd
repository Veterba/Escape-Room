## Fuse Kin: runs at the player. Close up it lights a 1.2 s fuse, blinking faster and faster,
## then explodes (36 px): one heart off the player, and damage to enemies caught in it.
## It also explodes when killed.
## Looks: Countdown, a round bomb whose face is a blue crash screen. A spark flickers at the tip
## of its fuse while it runs. Once the fuse is lit the screen turns red and counts 3-2-1, the
## 1 blinking faster and faster (the warning frames).
class_name FuseKin
extends Enemy

## The warning frames: "3", "2", then "1" dark and "1" bright, which take turns.
const COUNT_FRAMES: Array[int] = [0, 1]
const ONE_DARK := 2
const ONE_BRIGHT := 3
## The spark: two pixels at the fuse tip it jumps between (in the 24 x 24 frame, facing right),
## how often it jumps, and its colour.
const SPARK_SPOTS: Array[Vector2] = [Vector2(14, 4), Vector2(15, 3)]
const SPARK_RATE := 12.0
const SPARK_COLOR := Color("#ffd166")
const FRAME_SIZE := 24.0

## Seconds left on the fuse, or below 0 while it is not lit.
var _fuse_left := -1.0
var _blink_phase := 0.0


func _ready() -> void:
	hp = Config.balance.fuse_hp


func is_fuse_lit() -> bool:
	return _fuse_left >= 0.0


func _physics_process(delta: float) -> void:
	var cfg := Config.balance
	var player := target_player()
	var desired := Vector2.ZERO
	if player:
		desired = path_velocity(player.global_position, cfg.fuse_speed)
		var in_range := global_position.distance_to(player.global_position) <= cfg.fuse_trigger_distance
		if in_range and not is_fuse_lit():
			_fuse_left = cfg.fuse_time
			Audio.play_sfx(&"fuse_lit")
	move(desired, delta)
	if is_fuse_lit():
		_burn_fuse(delta)
	queue_redraw()


## Counts down 3-2-1 on its screen, the 1 blinking faster as the fuse runs out, and explodes at
## the end.
func _burn_fuse(delta: float) -> void:
	var cfg := Config.balance
	_fuse_left -= delta
	var burnt := 1.0 - clampf(_fuse_left / cfg.fuse_time, 0.0, 1.0)
	_blink_phase += lerpf(cfg.fuse_blink_rate_start, cfg.fuse_blink_rate_end, burnt) * delta
	body.animation = &"tell"
	var third := int(burnt * 3.0)
	if third < COUNT_FRAMES.size():
		body.frame = COUNT_FRAMES[third]
	else:
		body.frame = ONE_BRIGHT if fmod(_blink_phase, 1.0) < 0.5 else ONE_DARK
	if _fuse_left <= 0.0:
		die()


## The spark at the fuse tip, while it runs.
func _draw() -> void:
	if is_fuse_lit():
		return
	var spot := SPARK_SPOTS[int(Time.get_ticks_msec() / 1000.0 * SPARK_RATE) % SPARK_SPOTS.size()]
	if body.flip_h:
		spot.x = FRAME_SIZE - 1.0 - spot.x
	draw_rect(Rect2(body.position + spot - Vector2.ONE * FRAME_SIZE / 2.0, Vector2.ONE), SPARK_COLOR)


## Killed or out of fuse, it always goes off.
func die() -> void:
	var cfg := Config.balance
	var blast := Explosion.create(cfg.fuse_blast_radius, cfg.fuse_blast_damage, true)
	blast.global_position = global_position
	get_tree().current_scene.add_child.call_deferred(blast)
	super.die()
