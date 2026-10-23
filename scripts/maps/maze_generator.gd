## Builds the labyrinth with a recursive backtracker: a grid of cells, each cell 2x2 floor tiles
## with walls one tile thick between them, so every corridor is 2 tiles wide. The start is the
## top-left corner; the code goes in the cell farthest from it (by BFS along the corridors).
## generate() retries until walking the shortest path to the code takes 60-90 s.
class_name MazeGenerator
extends RefCounted

## Tiles from one cell to the next: 2 floor tiles plus 1 wall tile.
const CELL_TILES := 3
const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
## generate() gives up after this many mazes outside the time window and keeps the last one.
const MAX_ATTEMPTS := 100

var cols: int
var rows: int
var start := Vector2i.ZERO
var code_cell := Vector2i.ZERO
## For every cell, the neighbouring cells it has an opening to.
var links := {}
## For every cell, the number of steps from the start along the corridors.
var distances := {}
## Cells with only one opening, other than the start and the code cell.
var dead_ends: Array[Vector2i] = []


## A new maze whose shortest walk to the code is inside the time window in balance.tres.
static func generate(rng: RandomNumberGenerator) -> MazeGenerator:
	var cfg := Config.balance
	var maze: MazeGenerator
	for attempt in MAX_ATTEMPTS:
		maze = MazeGenerator.new(cfg.maze_cols, cfg.maze_rows, rng)
		var seconds := maze.walk_time()
		if seconds >= cfg.maze_min_walk_time and seconds <= cfg.maze_max_walk_time:
			return maze
	push_warning("No maze inside the time window after %d tries." % MAX_ATTEMPTS)
	return maze


## The centre of `cell` in pixels.
static func cell_center(cell: Vector2i) -> Vector2:
	return Vector2(cell * CELL_TILES + Vector2i.ONE) * GameMap.TILE_SIZE + Vector2.ONE * GameMap.TILE_SIZE


func _init(maze_cols: int, maze_rows: int, rng: RandomNumberGenerator) -> void:
	cols = maze_cols
	rows = maze_rows
	_carve(rng)
	distances = _distances_from(start)
	for cell: Vector2i in distances:
		if distances[cell] > distances[code_cell]:
			code_cell = cell
	for cell: Vector2i in links:
		if links[cell].size() == 1 and cell != start and cell != code_cell:
			dead_ends.append(cell)


## Seconds the player needs to walk the shortest path from the start to the code.
func walk_time() -> float:
	var pixels: float = distances[code_cell] * CELL_TILES * GameMap.TILE_SIZE
	return pixels / Config.balance.player_move_speed


## The maze as a GameMap layout. `contents` maps a cell to the layout letter placed in it.
func to_layout(contents: Dictionary) -> PackedStringArray:
	var width := cols * CELL_TILES + 1
	var height := rows * CELL_TILES + 1
	var grid: Array[PackedStringArray] = []
	for y in height:
		var row := PackedStringArray()
		row.resize(width)
		row.fill(GameMap.WALL)
		grid.append(row)
	for cell: Vector2i in links:
		var corner := cell * CELL_TILES + Vector2i.ONE
		for dy in 2:
			for dx in 2:
				grid[corner.y + dy][corner.x + dx] = GameMap.FLOOR
		# Open the wall towards the right and lower neighbours (the others open from their side).
		for next: Vector2i in links[cell]:
			var step: Vector2i = next - cell
			if step == Vector2i.RIGHT:
				grid[corner.y][corner.x + 2] = GameMap.FLOOR
				grid[corner.y + 1][corner.x + 2] = GameMap.FLOOR
			elif step == Vector2i.DOWN:
				grid[corner.y + 2][corner.x] = GameMap.FLOOR
				grid[corner.y + 2][corner.x + 1] = GameMap.FLOOR
		if contents.has(cell):
			grid[corner.y][corner.x] = contents[cell]
	var layout := PackedStringArray()
	for row in grid:
		layout.append("".join(row))
	return layout


## A path of up to `length` cells that starts at `from` and never turns back.
func corridor_from(from: Vector2i, length: int, rng: RandomNumberGenerator) -> Array[Vector2i]:
	var path: Array[Vector2i] = [from]
	while path.size() < length:
		var options: Array[Vector2i] = []
		for next: Vector2i in links[path[-1]]:
			if not path.has(next):
				options.append(next)
		if options.is_empty():
			break
		path.append(options[rng.randi_range(0, options.size() - 1)])
	return path


## Recursive backtracker, written with a stack: walk to a random unvisited neighbour and knock
## down the wall between; at a dead end, step back until a cell has unvisited neighbours.
func _carve(rng: RandomNumberGenerator) -> void:
	for y in rows:
		for x in cols:
			links[Vector2i(x, y)] = [] as Array[Vector2i]
	var visited := {start: true}
	var stack: Array[Vector2i] = [start]
	while not stack.is_empty():
		var cell: Vector2i = stack[-1]
		var options: Array[Vector2i] = []
		for direction in DIRECTIONS:
			var next := cell + direction
			if links.has(next) and not visited.has(next):
				options.append(next)
		if options.is_empty():
			stack.pop_back()
			continue
		var next := options[rng.randi_range(0, options.size() - 1)]
		links[cell].append(next)
		links[next].append(cell)
		visited[next] = true
		stack.append(next)


func _distances_from(from: Vector2i) -> Dictionary:
	var result := {from: 0}
	var queue: Array[Vector2i] = [from]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_front()
		for next: Vector2i in links[cell]:
			if not result.has(next):
				result[next] = result[cell] + 1
				queue.append(next)
	return result
