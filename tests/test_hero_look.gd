## Tests for how the hero, Telly, looks: the view and the mirroring follow the aim, the hand sits
## at the rig's front or back spot, the roll shows only the TV through its 5 frames, and the
## reload bar fills over the gun's reload time. Gameplay is covered by test_player.gd.
extends TestCase

const PLAYER := preload("res://scenes/player/player.tscn")


func _make_player() -> Player:
	var player: Player = PLAYER.instantiate()
	world.add_child(player)
	return player


## Aims at `angle` (radians, 0 = right, positive = down) and updates the look, like a frame does.
func _aim(player: Player, angle: float) -> void:
	player._aim_at(player.global_position + player.rig.aim_origin + Vector2.from_angle(angle) * 50.0)
	player._play_body(false)
	player._place_arm(0.0)
	player._update_face(0.0)


func test_view_and_mirroring_follow_the_aim() -> void:
	var player := _make_player()
	_aim(player, 0.0)
	assert_eq(player.body.animation, &"idle", "aiming level: front view")
	assert_true(not player.body.flip_h, "aiming right: not mirrored")
	assert_true(player.arm.get_index() > player.body.get_index(), "front view: the gun is in front")
	_aim(player, -PI / 2.0)
	assert_eq(player.body.animation, &"idle_back", "aiming up: back view")
	assert_true(player.arm.get_index() < player.body.get_index(), "back view: the gun is behind the body")
	_aim(player, PI)
	assert_true(player.body.flip_h, "aiming left: mirrored")
	assert_eq(player.gun_pivot.scale.y, -1.0, "aiming left: the gun is flipped, never upside down")


func test_hand_sits_at_the_rig_spot_on_the_aiming_side() -> void:
	var player := _make_player()
	var rig := player.rig
	var center := player.body.position
	_aim(player, 0.0)
	assert_eq(player.arm.position, (center + rig.front_hand + Vector2.RIGHT * rig.hand_orbit).round(), "front view, aiming right")
	_aim(player, PI)
	var mirrored := Vector2(-rig.front_hand.x, rig.front_hand.y)
	assert_eq(player.arm.position, (center + mirrored + Vector2.LEFT * rig.hand_orbit).round(), "front view, aiming left")
	var up := -PI / 2.0 + 0.1  # Straight up, a little to the right.
	_aim(player, up)
	assert_eq(player.arm.position, (center + rig.back_hand + Vector2.from_angle(up) * rig.hand_orbit).round(), "back view, by the ear")


func test_roll_shows_only_the_tv_through_five_frames() -> void:
	var player := _make_player()
	var cfg := Config.balance
	player.start_roll(Vector2.LEFT)
	assert_true(not player.arm.visible, "no hand or gun while rolling")
	assert_true(player.body.flip_h, "rolling left is mirrored")
	var seen := {}
	for i in steps_for(cfg.roll_duration):
		player._physics_process(STEP)
		if player.state == Player.State.ROLLING:
			seen[player.body.frame] = true
			assert_true(player.body.position.y <= -12.0, "the TV hops, never sinks")
	assert_eq(seen.size(), 5, "all 5 tumble frames are shown over the roll")
	assert_eq(player.state, Player.State.NORMAL, "the roll still takes roll_duration")
	assert_true(player.arm.visible, "the hand and gun come back")


func test_reload_bar_fills_over_the_reload_time() -> void:
	var player := _make_player()
	player.gun.owned.in_magazine = 0
	player.gun.start_reload()
	var faces := player.rig.reload_faces
	_aim(player, 0.0)
	assert_eq(player.face.texture, faces[0], "the bar starts empty")
	player.gun._process(player.gun.stats.reload_time * 0.8)
	_aim(player, 0.0)
	assert_eq(player.face.texture, faces[faces.size() - 1], "near the end it is full")
	assert_true(player.face.visible, "the face shows on the screen")
