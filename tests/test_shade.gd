## Tests for the Shade Kin's teleport: it tears apart, is gone and appears again 50-90 px from
## the player, and while teleporting it can neither hurt nor be hit.
extends TestCase

const PLAYER := preload("res://scenes/player/player.tscn")
const SHADE := preload("res://scenes/enemies/shade_kin.tscn")


func test_teleport_lands_near_the_player_and_is_harmless_on_the_way() -> void:
	var cfg := Config.balance
	var player: Player = PLAYER.instantiate()
	world.add_child(player)
	var shade: ShadeKin = SHADE.instantiate()
	shade.position = Vector2(4, 0)  # Touching the player.
	world.add_child(shade)
	shade.awake = true
	await world.get_tree().physics_frame  # Lets the contact area see the player.
	shade.start_teleport()
	var hp := shade.hp
	var moved := false
	# Each of the three steps starts on the frame after the last one ends: a few frames of slack.
	for i in steps_for(cfg.shade_tear_time * 2.0 + cfg.shade_gone_time) + 3:
		if shade.is_teleporting():
			shade.take_damage(1, Vector2.RIGHT)
			assert_eq(shade.hp, hp, "cannot be hit while teleporting")
		shade._physics_process(STEP)
		moved = moved or shade.mode == ShadeKin.Mode.UNFOLD
	assert_eq(player.hearts, cfg.player_hearts, "cannot hurt while teleporting")
	assert_true(moved, "it unfolded again")
	assert_eq(shade.mode, ShadeKin.Mode.FLOAT, "floating again afterwards")
	var distance := shade.global_position.distance_to(player.global_position)
	assert_true(distance >= cfg.shade_appear_min - 1.0 and distance <= cfg.shade_appear_max + 1.0, "appeared %d px from the player" % distance)
	shade.take_damage(1, Vector2.RIGHT)
	assert_eq(shade.hp, hp - 1, "can be hit again once it is back")
