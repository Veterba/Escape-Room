## Random rolls for loot: which gun a chest gives and what a dead enemy drops.
class_name Loot

# Paths, not preloads: the pickup scenes use the Player class, which already needs this script.
const HEART_PICKUP := "res://scenes/world/heart_pickup.tscn"
const AMMO_PICKUP := "res://scenes/world/ammo_pickup.tscn"


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
	var roll := rng.randf()
	if roll < cfg.ammo_drop_chance:
		return load(AMMO_PICKUP)
	if roll < cfg.ammo_drop_chance + cfg.heart_drop_chance:
		return load(HEART_PICKUP)
	return null
