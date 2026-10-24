## The bot check (Build Spec section 10): shows that every map type can be won in time with the
## Pop Pistol plus one C-rank gun (the Brass Revolver) when half the shots hit.
## - Floors (arena and boss rounds): over 50 generated floors, the shortest walk from the start to
##   the objective room, the detour through the chest rooms, and the time to kill the fight rooms.
## - Enemy Arena: the code chest unlocks when its wave starts; waves come at least every 30 s.
## - Labyrinth: the shortest walk to the code, and the worst case of walking every corridor.
## - Boss: a scripted player fights Root with the Brass Revolver, half its shots hitting, in real
##   boss rounds, and walks over the code when it drops.
## Usage: godot --headless --path . --fixed-fps 60 -s tools/bot_check.gd
## Nothing here is referred to by class name at the top, because the game's autoloads (Config)
## only exist once the check has started.
extends SceneTree

const SEEDS := 50
const BOSS_FIGHTS := 4
## Share of shots that hit.
const ACCURACY := 0.5
## Seconds a frame lasts in the boss fights (run with --fixed-fps 60).
const FRAME := 1.0 / 60.0
## The longest a boss fight may run before the check gives up on it.
const BOSS_GIVE_UP := 600.0

var _cfg: Resource
var _rng := RandomNumberGenerator.new()


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_cfg = root.get_node("Config").balance
	var pistol := _dps(_cfg.pop_pistol)
	var revolver := _dps(_cfg.brass_revolver)
	print("Damage per second at %d %% hits: Pop Pistol %.2f, Brass Revolver %.2f" % [ACCURACY * 100, pistol, revolver])
	var arena := _floor_numbers(&"arena", pistol)
	var boss := _floor_numbers(&"boss", pistol)
	var unlock: float = (_cfg.arena_chest_unlock_wave - 1) * _cfg.arena_wave_interval
	print("Enemy Arena: the code chest unlocks at most %.0f s after the waves start, then %.0f s to open it" % [unlock, _cfg.code_chest_open_time])
	print("  arena round, worst floor: %s (timer %s)" % [_clock(arena[1] + unlock + _cfg.code_chest_open_time), _clock(_cfg.round_length)])
	_maze_numbers()
	var fights: Array[float] = []
	for i in BOSS_FIGHTS:
		fights.append(await _boss_fight(i + 1))
	fights.sort()
	print("Boss: Root beaten in %s-%s with the Brass Revolver (%d fights), plus %s on the floor before it (worst)" % [
		_clock(fights[0]), _clock(fights[-1]), BOSS_FIGHTS, _clock(boss[1])])
	quit()


## Damage per second of `gun` over whole magazines and reloads, at ACCURACY.
func _dps(gun: Resource) -> float:
	var magazine_time: float = gun.magazine_size / gun.fire_rate + gun.reload_time
	return gun.magazine_size * gun.damage * gun.pellets * ACCURACY / magazine_time


## Prints the floor numbers for `objective` and returns [median, worst] seconds for the walk to
## the objective room, the chest detours and the fight rooms (with the pistol only).
func _floor_numbers(objective: StringName, dps: float) -> Array[float]:
	var floor_generator: GDScript = load("res://scripts/floor/floor_generator.gd")
	var objective_rooms: GDScript = load("res://scripts/floor/objective_rooms.gd")
	var totals: Array[float] = []
	var walks: Array[float] = []
	var detours: Array[float] = []
	var fights: Array[float] = []
	for i in SEEDS:
		_rng.seed = i
		var is_boss := objective == &"boss"
		var plan = floor_generator.new(_rng, objective_rooms.BOSS_SIZE if is_boss else objective_rooms.ARENA_SIZE, is_boss)
		plan.stamp_room(plan.objective, objective_rooms.boss(_rng) if is_boss else objective_rooms.arena(_rng))
		var steps := _steps_from_start(plan.layout)
		var walk := _walk(steps, plan.objective.rect)
		var detour := 0.0
		var hit_points := 0
		for room in plan.rooms:
			if room.kind == floor_generator.Kind.CHEST:
				detour += 2.0 * _walk(steps, room.rect)
			elif room.kind == floor_generator.Kind.FIGHT:
				var mix: Resource = _cfg.floor_fights[mini(room.depth, _cfg.floor_fights.size()) - 1]
				hit_points += mix.grunts * _cfg.grunt_hp + mix.fuses * _cfg.fuse_hp + mix.rockets * _cfg.rocket_hp + mix.wings * _cfg.wing_hp
		var fight: float = hit_points / dps + _cfg.arena_spawn_time
		walks.append(walk)
		detours.append(detour)
		fights.append(fight)
		totals.append(walk + detour + fight)
	for list: Array[float] in [walks, detours, fights, totals]:
		list.sort()
	print("%s floors (%d): walk to the objective %s-%s, chest detours up to %s, fight rooms up to %s with the pistol; all of it %s median, %s worst" % [
		objective.capitalize(), SEEDS, _clock(walks[0]), _clock(walks[-1]), _clock(detours[-1]), _clock(fights[-1]),
		_clock(totals[SEEDS / 2]), _clock(totals[-1])])
	return [totals[SEEDS / 2], totals[-1]]


func _maze_numbers() -> void:
	var maze_generator: GDScript = load("res://scripts/maps/maze_generator.gd")
	var shortest: Array[float] = []
	var everything: Array[float] = []
	for i in SEEDS:
		_rng.seed = i
		var maze = maze_generator.generate(_rng)
		shortest.append(maze.walk_time())
		# Walking every corridor there and back: each link between two cells twice.
		var cell_pixels: float = maze_generator.CELL_TILES * 16.0
		everything.append(2.0 * (maze.cols * maze.rows - 1) * cell_pixels / _cfg.player_move_speed)
	shortest.sort()
	everything.sort()
	print("Labyrinth (%d): shortest walk to the code %s-%s; walking every corridor %s (timer %s, +%.0f s hourglass)" % [
		SEEDS, _clock(shortest[0]), _clock(shortest[-1]), _clock(everything[-1]), _clock(_cfg.round_length), _cfg.hourglass_bonus_time])


## Tiles from the start to every reachable tile of `layout`.
func _steps_from_start(layout: PackedStringArray) -> Dictionary:
	var start := Vector2i.ZERO
	for y in layout.size():
		if layout[y].contains("P"):
			start = Vector2i(layout[y].find("P"), y)
	var steps := {start: 0}
	var todo: Array[Vector2i] = [start]
	var i := 0
	while i < todo.size():
		var cell := todo[i]
		i += 1
		for step: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var next := cell + step
			if next.y < 0 or next.y >= layout.size() or next.x < 0 or next.x >= layout[next.y].length():
				continue
			if layout[next.y][next.x] in ["#", "x", " "] or steps.has(next):
				continue
			steps[next] = steps[cell] + 1
			todo.append(next)
	return steps


## Seconds to walk from the start to the nearest reachable tile of the middle of `rect`.
func _walk(steps: Dictionary, rect: Rect2i) -> float:
	var best := INF
	var middle := rect.get_center()
	for cell: Vector2i in steps:
		if rect.grow(-1).has_point(cell) and cell.distance_to(middle) <= 2.0:
			best = minf(best, steps[cell])
	return best * 16.0 / _cfg.player_move_speed


## One boss round: the player stands in the boss room and shoots Root (hits only count when Root
## can be hit), never losing hearts, then walks over the code. Returns the seconds the fight took.
func _boss_fight(number: int) -> float:
	_rng.seed = number
	var game := root.get_node("Game")
	game.start_round(&"boss")
	await process_frame
	await process_frame
	var round_node := current_scene
	var room = round_node.map.objective_room
	var player = round_node.player
	player.global_position = round_node.map.cell_center(room.rect.position + Vector2i(room.rect.size.x / 2, room.rect.size.y - 4))
	player.reset_physics_interpolation()
	var gun: Resource = _cfg.brass_revolver
	var boss: Node = null
	var started := -1.0
	var time := 0.0
	var cooldown := 0.0
	var shots_left: int = gun.magazine_size
	var reloading := 0.0
	while round_node.result == 0 and time < BOSS_GIVE_UP:
		await physics_frame
		time += FRAME
		player.hearts = _cfg.player_hearts
		# A freed node also equals null, so "not found yet" is kept in `started`.
		if started < 0.0:
			for child in room.get_children():
				if child.has_method("start_teleport"):
					boss = child
					started = time
			continue
		if not is_instance_valid(boss):
			for child in room.get_children():
				if child.get("kind") == 2:  # The code (Pickup.Kind.CODE).
					player.global_position = child.global_position
			continue
		if reloading > 0.0:
			reloading -= FRAME
			if reloading <= 0.0:
				shots_left = gun.magazine_size
			continue
		cooldown -= FRAME
		if cooldown <= 0.0:
			cooldown = 1.0 / gun.fire_rate
			shots_left -= 1
			if _rng.randf() < ACCURACY and not boss.is_invulnerable():
				boss.take_damage(gun.damage, Vector2.UP)
			if shots_left <= 0:
				reloading = gun.reload_time
	var won: bool = round_node.result == 1
	print("  boss fight %d: %s in %s" % [number, "won" if won else "NOT WON", _clock(time - started)])
	return time - started if won else INF


func _clock(seconds: float) -> String:
	if seconds == INF:
		return "never"
	return "%d:%02d" % [int(seconds) / 60, int(seconds) % 60]
