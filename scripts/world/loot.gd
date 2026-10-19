## Random rolls for loot: which gun a chest gives and what a dead enemy drops.
class_name Loot

# Paths, not preloads: the pickup scenes use the Player class, which already needs this script.
const HEART_PICKUP := "res://scenes/world/heart_pickup.tscn"
const AMMO_PICKUP := "res://scenes/world/ammo_pickup.tscn"
const SMOKE_PICKUP := "res://scenes/world/smoke_pickup.tscn"


## Every gun a chest can give, with its chest_weight as the chance weight.
static func chest_guns() -> Array[GunStats]:
	var cfg := Config.balance
	return [cfg.brass_revolver, cfg.scattershot, cfg.fuse_launcher, cfg.gold_detonator]


static func roll_chest_gun(rng: RandomNumberGenerator) -> GunStats:
	var guns := chest_guns()
	var weights := PackedFloat32Array()
	for gun in guns:
		weights.append(gun.chest_weight)
	return guns[rng.rand_weighted(weights)]


## The pickup a dead enemy drops, or null for nothing.
static func roll_enemy_drop(rng: RandomNumberGenerator) -> PackedScene:
	var cfg := Config.balance
	# One roll, split into back-to-back ranges: ammo, then heart, then smoke bomb, then nothing.
	var roll := rng.randf()
	for drop: Array in [[cfg.ammo_drop_chance, AMMO_PICKUP], [cfg.heart_drop_chance, HEART_PICKUP],
			[cfg.smoke_drop_chance, SMOKE_PICKUP]]:
		if roll < drop[0]:
			return load(drop[1])
		roll -= drop[0]
	return null
