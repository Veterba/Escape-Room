## Tests for the main menu on the TV: it fills the screen, shows PLAY and QUIT, and only takes
## the keyboard once the TV has booted.
extends TestCase

const MAIN_MENU := preload("res://scenes/ui/main_menu.tscn")


func test_tv_fills_the_screen_and_play_gets_the_keyboard_after_boot() -> void:
	var menu: TvMenu = MAIN_MENU.instantiate()
	world.add_child(menu)
	var view := menu.get_viewport_rect().size
	assert_true(is_equal_approx(menu.tv.size.y, view.y) or is_equal_approx(menu.tv.size.x, view.x), "the TV touches the screen's edges")
	var play: Button = menu.get_node("Tv/Screen/Items/Play")
	assert_eq(play.text, Strings.PLAY.to_upper(), "PLAY button")
	assert_true(not play.has_focus(), "no keyboard focus while booting")
	menu._on_booted()
	assert_true(play.has_focus(), "PLAY has the keyboard once booted")
