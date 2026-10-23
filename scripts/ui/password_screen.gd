## The first screen of the game: the password from the previous escape room task. Enter checks
## it; a wrong password shakes the field and clears it. It is the main scene, and every "Menu"
## button goes to the main menu, so it is asked only once per launch.
class_name PasswordScreen
extends Control

## Pixels the field moves to each side, and how many times, when the password is wrong.
const SHAKE_DISTANCE := 6.0
const SHAKES := 3
## Seconds for one move of the shake.
const SHAKE_STEP_TIME := 0.04

@onready var field: LineEdit = $Center/Items/FieldHolder/Field


func _ready() -> void:
	$Center/Items/Title.text = Strings.GAME_TITLE
	$Center/Items/Prompt.text = Strings.PASSWORD_PROMPT
	$Center/Items/Hint.text = Strings.PASSWORD_HINT
	field.text_submitted.connect(submit)
	field.grab_focus()
	# Testing with --map skips the password and goes straight to that map.
	if Game.forced_map_id() != &"":
		Game.go_to_menu.call_deferred()


static func is_correct(text: String) -> bool:
	return text == Config.balance.password


## Opens the menu on the right password; otherwise shakes and clears the field.
func submit(text: String) -> void:
	if is_correct(text):
		Game.go_to_menu()
		return
	field.clear()
	var shake := create_tween()
	for i in SHAKES:
		shake.tween_property(field, "position:x", SHAKE_DISTANCE, SHAKE_STEP_TIME)
		shake.tween_property(field, "position:x", -SHAKE_DISTANCE, SHAKE_STEP_TIME)
	shake.tween_property(field, "position:x", 0.0, SHAKE_STEP_TIME)
	Audio.play_sfx(&"password_wrong")
