## The guns the player carries: the Pop Pistol plus up to two more. Each keeps its own ammo.
class_name GunInventory
extends Node

## Emitted when a gun is added, replaced or switched.
signal changed

var guns: Array[OwnedGun] = []
var current := 0

## The gun node in the player's hand.
var _hand: Gun


func setup(hand: Gun, starter: GunStats) -> void:
	_hand = hand
	guns = [OwnedGun.new(starter)]
	_equip(0)


## Switches to the gun in slot `index` (0 is the Pop Pistol). Ignores empty slots.
func select(index: int) -> void:
	if index >= 0 and index < guns.size() and index != current:
		_equip(index)


## Switches to the next (+1) or previous (-1) gun, wrapping around.
func cycle(step: int) -> void:
	select(posmod(current + step, guns.size()))


## Takes `new_gun` into hand. A gun the player already has refills that gun's reserve instead.
## With every slot full, the gun in hand is swapped out (the Pop Pistol is never dropped, so
## holding it swaps out the last slot). Returns the gun that was dropped, or null.
func pick_up(new_gun: OwnedGun) -> OwnedGun:
	for i in guns.size():
		if guns[i].stats == new_gun.stats:
			guns[i].reserve = guns[i].stats.reserve_ammo
			_equip(i)
			return null
	if guns.size() < Config.balance.gun_slots:
		guns.append(new_gun)
		_equip(guns.size() - 1)
		return null
	var slot := current if current != 0 else guns.size() - 1
	var dropped := guns[slot]
	guns[slot] = new_gun
	_equip(slot)
	return dropped


## Ammo box: gives the gun in hand `share` of its full reserve. Returns false if that does nothing.
func refill_current_reserve(share: float) -> bool:
	var gun := guns[current]
	if gun.is_reserve_full():
		return false
	gun.refill_reserve(share)
	_hand.changed.emit()
	return true


func _equip(index: int) -> void:
	current = index
	_hand.equip(guns[index])
	changed.emit()
