## Finds the nearest thing the player can use with E, and handles pressing or holding E on it.
class_name Interactor
extends Node

var _target: Interactable
var _held := 0.0
## After a use, E must be let go before the next use, so one press never opens two things.
var _wait_for_release := false


## Call every frame with the player's feet position and whether E is down.
func update(delta: float, player: Player, is_pressed: bool) -> void:
	var nearest := _find_nearest(player.global_position)
	if nearest != _target:
		if is_instance_valid(_target):
			_target.set_focus(false, 0.0)
		_target = nearest
		_held = 0.0
	if not is_pressed:
		_wait_for_release = false
		_held = 0.0
	if _target == null:
		return
	if is_pressed and not _wait_for_release:
		_held += delta
		if _held >= _target.hold_time:
			_wait_for_release = true
			_held = 0.0
			_target.interact(player)
	if is_instance_valid(_target) and _target.can_interact():
		var progress := _held / _target.hold_time if _target.hold_time > 0.0 else 0.0
		_target.set_focus(true, progress)


## Stops a hold in progress (being hit cancels opening a chest).
func cancel() -> void:
	_held = 0.0
	_wait_for_release = true


func _find_nearest(from: Vector2) -> Interactable:
	var best: Interactable = null
	var best_distance := Config.balance.interact_range
	for node in get_tree().get_nodes_in_group(&"interactables"):
		var item := node as Interactable
		var distance := from.distance_to(item.global_position)
		if item.can_interact() and distance <= best_distance:
			best = item
			best_distance = distance
	return best
