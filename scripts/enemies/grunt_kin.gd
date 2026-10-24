## Grunt Kin: walks towards the player, stops at about 120 px when it can see them,
## and fires one bullet every 1.5 s. It never shoots through walls.
## Looks: Static, an infected .exe file. It holds the Brass Revolver in a floating violet hand,
## turned towards the player, and its bullets leave from the muzzle. Before each shot its eyes
## flare and red spots break out over the page (the warning frames).
class_name GruntKin
extends Enemy

## Where the gun hand floats, from its feet, on the side it aims to (as on the approved page).
const HAND_SPOT := Vector2(11, -10)
## The hand sits one pixel along the aim from that spot.
const HAND_REACH := 1.0

var _fire_cooldown := 0.0
var _flash_left := 0.0

@onready var _pivot: Node2D = $GunPivot
@onready var _gun: Sprite2D = $GunPivot/Gun
@onready var _flash: Sprite2D = $GunPivot/Flash


func _ready() -> void:
	var revolver := Config.balance.brass_revolver
	hp = Config.balance.grunt_hp
	_fire_cooldown = Config.balance.grunt_fire_interval
	_gun.texture = revolver.held_texture
	_gun.offset = -revolver.grip
	_gun.position = Vector2(HAND_REACH, 0)
	_flash.position = _gun.position + revolver.muzzle - revolver.grip
	_flash.visible = false


func _physics_process(delta: float) -> void:
	var cfg := Config.balance
	var player := target_player()
	_flash_left -= delta
	_flash.visible = _flash_left > 0.0
	if player == null:
		move(Vector2.ZERO, delta)
		return
	var aim_point := player.hurtbox_position()
	var sees_player := can_see(aim_point)
	var close_enough := global_position.distance_to(player.global_position) <= cfg.grunt_stop_distance
	var desired := Vector2.ZERO
	if not (sees_player and close_enough):
		desired = path_velocity(player.global_position, cfg.grunt_speed)
	move(desired, delta)
	_aim_gun(aim_point)

	_fire_cooldown -= delta
	if sees_player and _fire_cooldown <= cfg.grunt_tell_time:
		body.play(&"tell")
	if sees_player and _fire_cooldown <= 0.0:
		eye_offset = _muzzle() - global_position
		shoot(aim_point - _muzzle(), cfg.grunt_bullet_speed)
		_fire_cooldown = cfg.grunt_fire_interval
		_flash_left = cfg.muzzle_flash_time


## Turns the gun towards `point`, the hand floating on that side; aiming left, the gun is flipped
## so it is never upside down.
func _aim_gun(point: Vector2) -> void:
	var left := point.x < global_position.x
	_pivot.position = Vector2(-HAND_SPOT.x if left else HAND_SPOT.x, HAND_SPOT.y)
	_pivot.rotation = (point - _pivot.global_position).angle()
	_pivot.scale.y = -1.0 if left else 1.0


func _muzzle() -> Vector2:
	return _pivot.to_global(_flash.position)
