## Tests for the shared juice: the hit flash turns on and switches off after its time.
extends TestCase

const PLAYER := preload("res://scenes/player/player.tscn")


func test_hit_flash_turns_off_after_its_time() -> void:
	var player: Player = PLAYER.instantiate()
	world.add_child(player)
	var material := player.body.material as ShaderMaterial
	player.juice.hit_flash()
	assert_eq(material.get_shader_parameter(&"flash_amount"), 1.0, "sprite is white right after a hit")
	await wait(Config.balance.hit_flash_time + 0.1)
	assert_eq(material.get_shader_parameter(&"flash_amount"), 0.0, "sprite is back to normal")
