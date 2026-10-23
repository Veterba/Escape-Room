## The map of a round: one floor of rooms (FloorGenerator) ending in the objective room, which is
## the Boss Chamber, the Labyrinth or the Enemy Arena. The whole floor is built as one GameMap,
## then every room gets a Room node that runs it. Inside the labyrinth everything outside a
## circle around the player is dark: a CanvasModulate darkens the map and a PointLight2D that
## follows the player lights it.
class_name DungeonFloor
extends GameMap

const OFFICER := preload("res://scenes/enemies/officer_kin.tscn")
const GUN_CHEST := "G"
const HOURGLASS := "H"
const SHADE := "s"
const WING := "w"

## Which objective room ends the floor: &"boss", &"maze" or &"arena". Set before adding it.
var objective: StringName
var plan: FloorGenerator
var rooms: Array[Room] = []
var objective_room: Room
## The labyrinth, when it is the objective.
var maze: MazeGenerator

@onready var _darkness: CanvasModulate = $Darkness
@onready var _vision: PointLight2D = $Vision


func _ready() -> void:
	map_id = objective
	var rng := RandomNumberGenerator.new()
	plan = FloorGenerator.new(rng, _objective_size())
	plan.stamp_room(plan.objective, _objective_layout(rng))
	layout = plan.layout
	super._ready()
	for room_plan in plan.rooms:
		_add_room(room_plan)
	if maze:
		_add_officers(rng)
	# Enemies placed by the layout stay in their room if they fly.
	for child in get_children():
		var enemy := child as Enemy
		if enemy and room_at(enemy.global_position):
			enemy.leash = room_at(enemy.global_position).inside_area()
	# The light texture's radius is half its width at scale 1.
	_vision.texture_scale = Config.balance.maze_vision_radius / (_vision.texture.get_width() / 2.0)


func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	if player == null or maze == null:
		return
	var in_maze := room_at(player.global_position) == objective_room
	_darkness.visible = in_maze
	_vision.visible = in_maze
	_vision.global_position = player.global_position


## The room that contains `point` (in global pixels), or null in a corridor.
func room_at(point: Vector2) -> Room:
	var tile := Vector2i((point / TILE_SIZE).floor())
	for room in rooms:
		if room.rect.has_point(tile):
			return room
	return null


func _add_room(room_plan: FloorGenerator.RoomPlan) -> void:
	var room := Room.new()
	room.kind = room_plan.kind
	room.depth = room_plan.depth
	room.rect = room_plan.rect
	room.map = self
	add_child(room)
	rooms.append(room)
	for door: Door in get_tree().get_nodes_in_group(&"doors"):
		if is_ancestor_of(door) and room.rect.has_point(_floor.local_to_map(door.position)):
			room.doors.append(door)
	if room_plan.kind == FloorGenerator.Kind.OBJECTIVE:
		objective_room = room
	if room_plan.kind == FloorGenerator.Kind.OBJECTIVE and objective == &"arena":
		room.waves = ArenaWaves.new()
		room.waves.room = room
		room.add_child(room.waves)


func _objective_size() -> Vector2i:
	match objective:
		&"maze":
			return MazeGenerator.tile_size()
		&"arena":
			return ObjectiveRooms.ARENA_SIZE
	return ObjectiveRooms.BOSS_SIZE


func _objective_layout(rng: RandomNumberGenerator) -> PackedStringArray:
	match objective:
		&"maze":
			return _maze_layout(rng)
		&"arena":
			return ObjectiveRooms.arena(rng)
	return ObjectiveRooms.boss(rng)


## A new maze whose start is the cell at its door: the gun chest and the hourglass go in dead
## ends, the Shade and Wing Kin far from the start.
func _maze_layout(rng: RandomNumberGenerator) -> PackedStringArray:
	var cfg := Config.balance
	var size := MazeGenerator.tile_size()
	var side := plan.objective_door_side()
	var door_tile := size / 2 + Vector2i(side.x * (size.x / 2), side.y * (size.y / 2))
	var start := MazeGenerator.cell_at(door_tile).clamp(Vector2i.ZERO, Vector2i(cfg.maze_cols, cfg.maze_rows) - Vector2i.ONE)
	maze = MazeGenerator.generate(rng, start)
	var contents := {maze.code_cell: "C"}
	var dead_ends := maze.dead_ends.duplicate()
	dead_ends.shuffle()
	contents[dead_ends[0]] = GUN_CHEST
	contents[dead_ends[1]] = HOURGLASS
	for i in cfg.maze_shades + cfg.maze_wings:
		contents[_far_maze_cell(contents)] = SHADE if i < cfg.maze_shades else WING
	return maze.to_layout(contents)


## A random maze cell far from the start with nothing in it yet.
func _far_maze_cell(taken: Dictionary) -> Vector2i:
	var cells: Array[Vector2i] = []
	for cell: Vector2i in maze.distances:
		if maze.distances[cell] >= Config.balance.maze_enemy_min_cells and not taken.has(cell):
			cells.append(cell)
	return cells.pick_random()


## Officers patrol routes along the maze's corridors (a route cannot be one letter in the layout).
func _add_officers(rng: RandomNumberGenerator) -> void:
	var cfg := Config.balance
	var origin := Vector2(plan.objective.rect.position * TILE_SIZE)
	for i in cfg.maze_officers:
		var officer: OfficerKin = OFFICER.instantiate()
		for cell in maze.corridor_from(_far_maze_cell({}), cfg.maze_patrol_cells, rng):
			officer.waypoints.append(origin + MazeGenerator.cell_center(cell))
		officer.position = officer.waypoints[0]
		add_child(officer)
