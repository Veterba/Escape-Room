## Tests for guns: fire rate, magazine, automatic and manual reload, pellets.
extends TestCase

const GUN := preload("res://scenes/guns/gun.tscn")


func _make_gun(stats: GunStats) -> Gun:
	var gun: Gun = GUN.instantiate()
	world.add_child(gun)
	gun.equip(OwnedGun.new(stats))
	return gun


func _make_pistol() -> Gun:
	return _make_gun(Config.balance.pop_pistol)


func _step(gun: Gun, seconds: float) -> void:
	for i in steps_for(seconds):
		gun._process(STEP)


func test_fire_rate_limits_shots() -> void:
	var gun := _make_pistol()
	assert_true(gun.try_fire(), "first shot fires")
	assert_true(not gun.try_fire(), "second shot at once is blocked")
	_step(gun, 1.0 / gun.stats.fire_rate)
	assert_true(gun.try_fire(), "shot fires again after 1 / fire rate")
	assert_eq(gun.in_magazine, gun.stats.magazine_size - 2, "each shot uses one bullet")


func test_empty_magazine_reloads_by_itself() -> void:
	var gun := _make_pistol()
	for i in gun.stats.magazine_size:
		gun.try_fire()
		_step(gun, 1.0 / gun.stats.fire_rate)
	assert_eq(gun.in_magazine, 0, "magazine is empty")
	assert_true(gun.is_reloading, "reload starts by itself")
	_step(gun, gun.stats.reload_time)
	assert_true(not gun.is_reloading, "reload is done after the reload time")
	assert_eq(gun.in_magazine, gun.stats.magazine_size, "magazine is full again")


func test_manual_reload_only_when_not_full() -> void:
	var gun := _make_pistol()
	gun.start_reload()
	assert_true(not gun.is_reloading, "no reload with a full magazine")
	gun.try_fire()
	gun.start_reload()
	assert_true(gun.is_reloading, "reload starts after one shot")
	assert_true(not gun.try_fire(), "cannot shoot while reloading")


func test_scattershot_fires_six_pellets_per_shot() -> void:
	_make_gun(Config.balance.scattershot).try_fire()
	var bullets := world.get_children().filter(func(node: Node) -> bool: return node is PlayerBullet)
	assert_eq(bullets.size(), 6, "pellets per shot")


func test_reload_takes_ammo_from_the_reserve() -> void:
	var gun := _make_gun(Config.balance.brass_revolver)
	gun.try_fire()
	gun.start_reload()
	_step(gun, gun.stats.reload_time)
	assert_eq(gun.in_magazine, gun.stats.magazine_size, "magazine refilled")
	assert_eq(gun.reserve, gun.stats.reserve_ammo - 1, "one bullet taken from the reserve")
