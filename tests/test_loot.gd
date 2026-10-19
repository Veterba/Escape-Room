## Tests for loot: gun chest weights over 10 000 rolls, and the gun inventory rules.
extends TestCase

const PLAYER := preload("res://scenes/player/player.tscn")
const ROLLS := 10000
## Allowed difference between measured and expected share, in percentage points.
const TOLERANCE := 2.0


func test_chest_weights_hold_over_10000_rolls() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	var counts := {}
	for i in ROLLS:
		var gun := Loot.roll_chest_gun(rng)
		counts[gun] = counts.get(gun, 0) + 1
	var total_weight := 0.0
	for gun in Loot.chest_guns():
		total_weight += gun.chest_weight
	for gun in Loot.chest_guns():
		var measured: float = 100.0 * counts.get(gun, 0) / ROLLS
		var expected: float = 100.0 * gun.chest_weight / total_weight
		assert_near(measured, expected, TOLERANCE, "share of %s in %%" % gun.id)


func test_enemy_drop_rates_hold_over_10000_rolls() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 6789
	var counts := {}
	for i in ROLLS:
		var drop := Loot.roll_enemy_drop(rng)
		var key: String = drop.resource_path if drop else "none"
		counts[key] = counts.get(key, 0) + 1
	assert_near(100.0 * counts.get(Loot.AMMO_PICKUP, 0) / ROLLS, 100.0 * Config.balance.ammo_drop_chance,
			TOLERANCE, "ammo box share in %")
	assert_near(100.0 * counts.get(Loot.HEART_PICKUP, 0) / ROLLS, 100.0 * Config.balance.heart_drop_chance,
			TOLERANCE, "heart share in %")


func test_inventory_holds_pistol_plus_two() -> void:
	var cfg := Config.balance
	var player: Player = PLAYER.instantiate()
	world.add_child(player)
	var guns := player.guns
	assert_eq(guns.pick_up(OwnedGun.new(cfg.brass_revolver)), null, "slot 2 is free")
	assert_eq(guns.pick_up(OwnedGun.new(cfg.scattershot)), null, "slot 3 is free")
	assert_eq(guns.guns.size(), 3, "three guns carried")
	var dropped := guns.pick_up(OwnedGun.new(cfg.fuse_launcher))
	assert_eq(dropped.stats, cfg.scattershot, "the gun in hand is swapped out")
	guns.select(0)
	dropped = guns.pick_up(OwnedGun.new(cfg.gold_detonator))
	assert_eq(dropped.stats, cfg.fuse_launcher, "holding the pistol swaps out the last slot")
	assert_eq(guns.guns[0].stats, cfg.pop_pistol, "the pistol is never dropped")


func test_switching_keeps_each_guns_ammo() -> void:
	var player: Player = PLAYER.instantiate()
	world.add_child(player)
	player.guns.pick_up(OwnedGun.new(Config.balance.brass_revolver))
	player.gun.try_fire()
	player.guns.select(0)
	assert_eq(player.gun.stats, Config.balance.pop_pistol, "pistol in hand")
	player.guns.select(1)
	assert_eq(player.gun.in_magazine, Config.balance.brass_revolver.magazine_size - 1, "revolver kept its ammo")
