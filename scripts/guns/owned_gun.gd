## A gun the player carries: its stats plus its own ammo, kept while other guns are in hand.
class_name OwnedGun
extends RefCounted

var stats: GunStats
var in_magazine: int
var reserve: int


func _init(gun_stats: GunStats) -> void:
	stats = gun_stats
	in_magazine = stats.magazine_size
	reserve = stats.reserve_ammo


func is_reserve_full() -> bool:
	return stats.infinite_reserve or reserve >= stats.reserve_ammo


## Adds `share` (0.5 = half) of the full reserve, never above the full reserve.
func refill_reserve(share: float) -> void:
	reserve = mini(reserve + ceili(stats.reserve_ammo * share), stats.reserve_ammo)
