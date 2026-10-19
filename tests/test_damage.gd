## Tests for damage and hearts: invulnerability while rolling and after a hit, healing, death.
extends TestCase

const PLAYER := preload("res://scenes/player/player.tscn")


func _make_player() -> Player:
	var player: Player = PLAYER.instantiate()
	world.add_child(player)
	return player


func _step(player: Player, seconds: float) -> void:
	for i in steps_for(seconds):
		player._physics_process(STEP)


func test_a_hit_costs_one_heart() -> void:
	var player := _make_player()
	assert_true(player.take_hit(Vector2.RIGHT), "hit lands")
	assert_eq(player.hearts, Config.balance.player_hearts - 1, "one heart lost")


func test_no_damage_early_in_a_roll() -> void:
	var player := _make_player()
	player.start_roll(Vector2.RIGHT)
	_step(player, 0.2)
	assert_true(not player.take_hit(Vector2.RIGHT), "hit is ignored mid-roll")
	assert_eq(player.hearts, Config.balance.player_hearts, "no heart lost")


func test_invulnerable_for_a_second_after_a_hit() -> void:
	var player := _make_player()
	player.take_hit(Vector2.RIGHT)
	_step(player, Config.balance.hit_invulnerable_time - 0.1)
	assert_true(not player.take_hit(Vector2.RIGHT), "second hit within 1 s is ignored")
	_step(player, 0.1)
	assert_true(player.take_hit(Vector2.RIGHT), "hit lands again after 1 s")


func test_zero_hearts_is_death() -> void:
	var player := _make_player()
	var deaths := [0]
	player.died.connect(func() -> void: deaths[0] += 1)
	for i in Config.balance.player_hearts:
		player.take_hit(Vector2.RIGHT)
		_step(player, Config.balance.hit_invulnerable_time)
	assert_eq(player.state, Player.State.DEAD, "player is dead")
	assert_eq(deaths[0], 1, "died fires once")
	assert_true(not player.take_hit(Vector2.RIGHT), "a dead player cannot be hit")


func test_heal_never_goes_above_full() -> void:
	var player := _make_player()
	assert_true(not player.heal(), "no heal at full hearts")
	player.take_hit(Vector2.RIGHT)
	assert_true(player.heal(), "heals when hurt")
	assert_eq(player.hearts, Config.balance.player_hearts, "back to full")
