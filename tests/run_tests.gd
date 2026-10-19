## Headless test runner. Runs every test_* method in res://tests/test_*.gd and exits with
## code 1 if any test fails. Usage: godot --headless --path . -s tests/run_tests.gd
extends SceneTree

const TEST_DIR := "res://tests/"


func _initialize() -> void:
	_run_all.call_deferred()


func _run_all() -> void:
	var passed := 0
	var failed := 0
	for file in DirAccess.get_files_at(TEST_DIR):
		if not (file.begins_with("test_") and file.ends_with(".gd")) or file == "test_case.gd":
			continue
		var script: GDScript = load(TEST_DIR + file)
		for method in script.get_script_method_list():
			var test_name: String = method["name"]
			if not test_name.begins_with("test_"):
				continue
			var failures := await _run_one(script, test_name)
			if failures.is_empty():
				passed += 1
				print("  ok    %s.%s" % [file.get_basename(), test_name])
			else:
				failed += 1
				print("  FAIL  %s.%s" % [file.get_basename(), test_name])
				for failure in failures:
					print("        - " + failure)
	print("\n%d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)


func _run_one(script: GDScript, test_name: String) -> Array[String]:
	var test: TestCase = script.new()
	test.world = Node2D.new()
	root.add_child(test.world)
	current_scene = test.world  # Bullets, casings and puffs are spawned into the current scene.
	await test.call(test_name)
	current_scene = null
	test.world.free()
	return test.failures
