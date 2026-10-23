## Tests for the password menu: only the password from the config is right, a wrong code turns
## the cells red and clears them, the right one is granted, only 4 digits fit, and the menu is
## asked only once per launch (it is the main scene; "Menu" goes to the main menu).
extends TestCase

const PASSWORD_SCREEN := preload("res://scenes/ui/password_screen.tscn")


## A menu that has finished booting, ready for typing.
func _make_screen() -> PasswordScreen:
	var screen: PasswordScreen = PASSWORD_SCREEN.instantiate()
	world.add_child(screen)
	screen._on_booted()
	return screen


func _type(screen: PasswordScreen, digits: String) -> void:
	for digit in digits:
		screen.type_digit(digit)


func test_only_the_password_from_the_config_is_right() -> void:
	assert_true(PasswordScreen.is_correct(Config.balance.password), "the configured password is right")
	assert_true(not PasswordScreen.is_correct(Config.balance.password + "0"), "anything else is wrong")


func test_wrong_code_turns_red_and_clears() -> void:
	var screen := _make_screen()
	_type(screen, "0000")
	screen.submit()
	assert_eq(screen.state, PasswordScreen.State.WRONG, "a wrong code is refused")
	await wait(PasswordScreen.SHAKE_TIME + PasswordScreen.RECOLOR_TIME)
	assert_true(screen._alarm > 0.9, "the cells and the button are red")
	assert_eq(screen.code, "", "the cells are cleared after the shake")
	screen.type_digit("1")
	assert_eq(screen.state, PasswordScreen.State.ENTERING, "typing again calms it down")


func test_right_code_is_granted() -> void:
	var screen := _make_screen()
	_type(screen, Config.balance.password)
	screen.submit()
	assert_eq(screen.state, PasswordScreen.State.GRANTED, "access granted")


func test_only_four_digits_and_backspace() -> void:
	var screen := _make_screen()
	_type(screen, "123456")
	assert_eq(screen.code, "1234", "only 4 digits fit")
	screen.erase()
	assert_eq(screen.code, "123", "Backspace erases the last digit")


func test_asked_once_per_launch() -> void:
	var main_scene: String = ProjectSettings.get_setting("application/run/main_scene")
	assert_eq(main_scene, PASSWORD_SCREEN.resource_path, "the game opens on the password menu")
	assert_true(Game.MENU_SCENE != main_scene, "Menu buttons go to the main menu, not back to the password")
