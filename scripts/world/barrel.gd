## A red barrel: blocks movement and bullets, and explodes when shot or caught in a blast
## (40 px: damage to enemies, one heart off the player). Barrels in range of the blast go off
## next, one after another, so a row of barrels chain-explodes.
class_name Barrel
extends StaticBody2D

## Seconds left until the explosion, or below 0 while the barrel is not lit.
var _fuse_left := -1.0


func is_lit() -> bool:
	return _fuse_left >= 0.0


## Starts the short fuse. Hitting a lit barrel again does nothing.
func ignite() -> void:
	if not is_lit():
		_fuse_left = Config.balance.barrel_fuse_time


func _physics_process(delta: float) -> void:
	if not is_lit():
		return
	_fuse_left -= delta
	if _fuse_left <= 0.0:
		_explode()


func _explode() -> void:
	var cfg := Config.balance
	var blast := Explosion.create(cfg.barrel_blast_radius, cfg.barrel_damage, true)
	blast.global_position = global_position
	get_tree().current_scene.add_child.call_deferred(blast)
	queue_free()
