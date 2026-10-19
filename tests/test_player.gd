## Tests for the player's dodge roll: invulnerability window, distance and cooldown.
extends TestCase

const PLAYER := preload("res://scenes/player/player.tscn")


func _make_player() -> Player:
	var player: Player = PLAYER.instantiate()
	world.add_child(player)
	return player


## Advances the player by `seconds` of physics frames.
func _step(player: Player, seconds: float) -> void:
	for i in steps_for(seconds):
		player._physics_process(STEP)


func test_roll_is_invulnerable_only_for_the_first_part() -> void:
	var player := _make_player()
	assert_true(not player.is_invulnerable(), "not invulnerable before rolling")
	player.start_roll(Vector2.RIGHT)
	_step(player, 0.30)
	assert_true(player.is_invulnerable(), "invulnerable 0.30 s into the roll")
	_step(player, 0.07)
	assert_true(not player.is_invulnerable(), "vulnerable again 0.37 s into the roll")


func test_roll_covers_about_70_px() -> void:
	var cfg := Config.balance
	var player := _make_player()
	player.start_roll(Vector2.RIGHT)
	_step(player, STEP)
	# Speed times duration is the distance; real movement needs the physics engine running.
	var distance := player.velocity.length() * cfg.roll_duration
	assert_near(distance, cfg.roll_distance, 0.5, "roll distance")
	_step(player, cfg.roll_duration)
	assert_eq(player.state, Player.State.NORMAL, "roll is over after its duration")


func test_roll_has_a_cooldown() -> void:
	var player := _make_player()
	player.start_roll(Vector2.RIGHT)
	_step(player, Config.balance.roll_duration)
	assert_true(not player.start_roll(Vector2.RIGHT), "cannot roll right after a roll")
	_step(player, Config.balance.roll_cooldown)
	assert_true(player.start_roll(Vector2.RIGHT), "can roll again after the cooldown")
