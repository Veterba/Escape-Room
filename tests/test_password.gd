## Tests for the password screen: a wrong password clears the field, and it is asked only once
## per launch (it is the main scene, and "Menu" goes straight to the main menu).
extends TestCase

const PASSWORD_SCREEN := preload("res://scenes/ui/password_screen.tscn")


func test_only_the_password_from_the_config_is_right() -> void:
	assert_true(PasswordScreen.is_correct(Config.balance.password), "the configured password is right")
	assert_true(not PasswordScreen.is_correct(Config.balance.password + "0"), "anything else is wrong")


func test_wrong_password_clears_the_field() -> void:
	var screen: PasswordScreen = PASSWORD_SCREEN.instantiate()
	world.add_child(screen)
	screen.submit("wrong")
	assert_eq(screen.field.text, "", "the field is cleared")
	assert_true(screen.is_inside_tree(), "the screen stays")


func test_asked_once_per_launch() -> void:
	var main_scene: String = ProjectSettings.get_setting("application/run/main_scene")
	assert_eq(main_scene, PASSWORD_SCREEN.resource_path, "the game opens on the password screen")
	assert_true(Game.MENU_SCENE != main_scene, "Menu buttons go to the main menu, not back to the password")
