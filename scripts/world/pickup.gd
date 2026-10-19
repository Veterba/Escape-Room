## An item on the floor that is picked up by walking over it: a heart, an ammo box, a smoke bomb
## or the code. Hearts, ammo and smoke bombs stay on the floor if they would do nothing right now.
class_name Pickup
extends Area2D

enum Kind { HEART, AMMO, CODE, SMOKE_BOMB }

## Pixels the item floats up and down.
const BOB_HEIGHT := 2.0
## Bobs per second.
const BOB_RATE := 1.5

@export var kind: Kind

var _time := 0.0

@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_time += delta
	_sprite.position.y = -roundf(absf(sin(_time * BOB_RATE * PI)) * BOB_HEIGHT)


func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player and _apply(player):
		Audio.play_sfx(&"pickup")
		queue_free()


## Gives the item to the player. Returns false if it would do nothing, so it stays on the floor.
func _apply(player: Player) -> bool:
	match kind:
		Kind.HEART:
			return player.heal()
		Kind.AMMO:
			return player.guns.refill_current_reserve(Config.balance.ammo_box_refill)
		Kind.CODE:
			Events.code_collected.emit()
			return true
		Kind.SMOKE_BOMB:
			return player.add_smoke_bomb()
	return false
