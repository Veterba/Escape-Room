## The Labyrinth: a new maze every round (MazeGenerator), turned into a layout and built like any
## other map. The gun chest and the hourglass go in dead ends, enemies far from the start, and
## officers get patrol routes along corridors. Everything outside a circle around the player is
## dark: a CanvasModulate darkens the map and a PointLight2D that follows the player lights it.
## It is built with the maze room type's tiles, with red emergency lights on a few inner walls.
class_name Labyrinth
extends GameMap

const OFFICER := preload("res://scenes/enemies/officer_kin.tscn")
const GUN_CHEST := "G"
const HOURGLASS := "H"
const SHADE := "s"
const WING := "w"

var maze: MazeGenerator

@onready var _vision: PointLight2D = $Vision
@onready var _darkness: CanvasModulate = $Darkness


func _ready() -> void:
	var cfg := Config.balance
	var rng := RandomNumberGenerator.new()
	maze = MazeGenerator.generate(rng)
	var contents := {maze.start: PLAYER_START, maze.code_cell: "C"}
	var dead_ends := maze.dead_ends.duplicate()
	dead_ends.shuffle()
	contents[dead_ends[0]] = GUN_CHEST
	contents[dead_ends[1]] = HOURGLASS
	var far_cells: Array[Vector2i] = []
	for cell: Vector2i in maze.distances:
		if maze.distances[cell] >= cfg.maze_enemy_min_cells and not contents.has(cell):
			far_cells.append(cell)
	far_cells.shuffle()
	for i in cfg.maze_shades:
		contents[far_cells.pop_back()] = SHADE
	for i in cfg.maze_wings:
		contents[far_cells.pop_back()] = WING
	layout = maze.to_layout(contents)
	super._ready()

	for i in cfg.maze_officers:
		var officer: OfficerKin = OFFICER.instantiate()
		for cell in maze.corridor_from(far_cells.pop_back(), cfg.maze_patrol_cells, rng):
			officer.waypoints.append(MazeGenerator.cell_center(cell))
		officer.position = officer.waypoints[0]
		add_child(officer)

	# The light texture's radius is half its width at scale 1.
	_vision.texture_scale = cfg.maze_vision_radius / (_vision.texture.get_width() / 2.0)
	_darkness.color = Config.lighting.maze.ambient
	RoomDecor.dress(self, Rect2i(Vector2i.ZERO, Vector2i(layout[0].length(), layout.size())), room_type, rng)


func _process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	if player:
		_vision.global_position = player.global_position
