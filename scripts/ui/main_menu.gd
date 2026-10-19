## Main menu: title, Play and Quit. With --map=... on the command line it starts that map at once.
extends Control


func _ready() -> void:
	$Center/Items/Play.pressed.connect(func() -> void: Game.start_round())
	$Center/Items/Quit.pressed.connect(get_tree().quit)
	$Center/Items/Play.grab_focus()
	# Only the first time, so the Menu button still works while testing with --map.
	if Game.forced_map_id() != &"" and Game.current_map_id == &"":
		Game.start_round.call_deferred()
