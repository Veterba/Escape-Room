## A gun lying on the floor. Press E to take it; if your hands are full, your gun is dropped here.
class_name GunPickup
extends Interactable

const SCENE := preload("res://scenes/world/gun_pickup.tscn")

## The gun, with whatever ammo it has.
var owned: OwnedGun


func _ready() -> void:
	$Sprite.texture = owned.stats.icon


func interact(player: Player) -> void:
	var dropped := player.guns.pick_up(owned)
	if dropped:
		var pickup: GunPickup = SCENE.instantiate()
		pickup.owned = dropped
		pickup.position = position
		get_parent().add_child.call_deferred(pickup)
	Audio.play_sfx(&"pickup")
	queue_free()
