## A gun chest: hold E to open it, and it drops a random gun (C 50 %, B 30 %, A 15 %, S 5 %).
class_name GunChest
extends Interactable

const GUN_PICKUP := preload("res://scenes/world/gun_pickup.tscn")
## Opened chests are drawn darker.
const OPENED_TINT := Color(0.5, 0.5, 0.5)
## Pixels below the chest where the gun lands.
const DROP_OFFSET := Vector2(0, 20)

var _opened := false


func _ready() -> void:
	hold_time = Config.balance.gun_chest_open_time


func can_interact() -> bool:
	return not _opened


func interact(_player: Player) -> void:
	_opened = true
	modulate = OPENED_TINT
	set_focus(false, 0.0)
	var rng := RandomNumberGenerator.new()
	var pickup: GunPickup = GUN_PICKUP.instantiate()
	pickup.owned = OwnedGun.new(Loot.roll_chest_gun(rng))
	pickup.position = position + DROP_OFFSET
	get_parent().add_child(pickup)
	Audio.play_sfx(&"chest_open")
