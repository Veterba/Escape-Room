## Lays out one floor, Enter the Gungeon style: 6-8 rooms on a coarse grid, each joined to the
## room it grew from by a straight corridor, with the objective room at the end of the longest
## path. The result is one big GameMap layout, so the whole floor is one map and there is no
## loading between rooms. Space outside rooms and corridors stays empty (dark).
class_name FloorGenerator
extends RefCounted

enum Kind { START, FIGHT, CHEST, OBJECTIVE, EXIT }

## One room of the floor.
class RoomPlan:
	var kind: Kind
	## Position on the coarse grid of rooms.
	var grid := Vector2i.ZERO
	var size := Vector2i.ZERO
	## Where the room sits on the floor, in tiles, walls included.
	var rect := Rect2i()
	## Rooms between this one and the start.
	var depth := 0
	var parent: RoomPlan
	var layout: PackedStringArray
	## The corridor to the parent room, in tiles, walls included.
	var corridor := Rect2i()


const VOID := " "
const DOOR := "D"
## Floor tiles across a corridor.
const CORRIDOR_WIDTH := 3
## Empty tiles around the whole floor.
const MARGIN := 2
const STEPS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

var rooms: Array[RoomPlan] = []
var objective: RoomPlan
var layout: PackedStringArray

var _grid: Array[PackedStringArray] = []


## `objective_size` is the size in tiles of the objective room; its layout is stamped later with
## stamp_room(). With `with_exit`, an exit room is added behind the objective (the boss floor).
func _init(rng: RandomNumberGenerator, objective_size: Vector2i, with_exit := false) -> void:
	_make_tree(rng, with_exit)
	_pick_kinds(rng)
	for room in rooms:
		if room.kind == Kind.OBJECTIVE:
			room.size = objective_size
		else:
			room.layout = _template_for(room, rng)
			room.size = Vector2i(room.layout[0].length(), room.layout.size())
	_place_rooms()
	for room in rooms:
		if room != objective:
			stamp_room(room, room.layout)
	for room in rooms:
		if room.parent:
			room.corridor = _dig_corridor(room.parent, room)


## Copies `room_layout` into the floor at the room's place, keeping the door tiles already dug.
func stamp_room(room: RoomPlan, room_layout: PackedStringArray) -> void:
	room.layout = room_layout
	for y in room_layout.size():
		for x in room_layout[y].length():
			var tile := room.rect.position + Vector2i(x, y)
			if _grid[tile.y][tile.x] != DOOR:
				_grid[tile.y][tile.x] = room_layout[y][x]
	_write_layout()


## Start at the middle, then keep adding a room next to a random room (never a second one next
## to the start) until the floor has all but one room. The objective is added last, next to the
## deepest room that has space (and space behind it for the exit room, if there is one).
func _make_tree(rng: RandomNumberGenerator, with_exit: bool) -> void:
	var cfg := Config.balance
	var count := rng.randi_range(cfg.floor_min_rooms, cfg.floor_max_rooms)
	var start := RoomPlan.new()
	start.kind = Kind.START
	rooms.append(start)
	while rooms.size() < count - 1:
		var from: RoomPlan = rooms[rng.randi_range(0, rooms.size() - 1)]
		# The start room has only one way out.
		if from == start and rooms.size() > 1:
			continue
		var free := _free_steps(from.grid)
		if not free.is_empty():
			_add_room(from, from.grid + free[rng.randi_range(0, free.size() - 1)])
	var by_depth := rooms.duplicate()
	by_depth.sort_custom(func(a: RoomPlan, b: RoomPlan) -> bool: return a.depth > b.depth)
	for room: RoomPlan in by_depth:
		var free := _free_steps(room.grid)
		if with_exit:
			free = free.filter(func(step: Vector2i) -> bool: return not _free_steps(room.grid + step).is_empty())
		if free.is_empty():
			continue
		objective = _add_room(room, room.grid + free[rng.randi_range(0, free.size() - 1)])
		objective.kind = Kind.OBJECTIVE
		if with_exit:
			var behind := _free_steps(objective.grid)
			_add_room(objective, objective.grid + behind[rng.randi_range(0, behind.size() - 1)]).kind = Kind.EXIT
		return


func _add_room(parent: RoomPlan, grid: Vector2i) -> RoomPlan:
	var room := RoomPlan.new()
	room.kind = Kind.FIGHT
	room.grid = grid
	room.parent = parent
	room.depth = parent.depth + 1
	rooms.append(room)
	return room


func _free_steps(grid: Vector2i) -> Array[Vector2i]:
	var free: Array[Vector2i] = []
	for step in STEPS:
		if rooms.all(func(room: RoomPlan) -> bool: return room.grid != grid + step):
			free.append(step)
	return free


## Chest rooms go at dead ends (rooms nothing grows from); every other room is a fight.
func _pick_kinds(rng: RandomNumberGenerator) -> void:
	var leaves: Array[RoomPlan] = []
	for room in rooms:
		if room.kind == Kind.FIGHT and rooms.all(func(other: RoomPlan) -> bool: return other.parent != room):
			leaves.append(room)
	leaves.shuffle()
	for i in mini(Config.balance.floor_chest_rooms, leaves.size()):
		leaves[i].kind = Kind.CHEST


func _template_for(room: RoomPlan, rng: RandomNumberGenerator) -> PackedStringArray:
	match room.kind:
		Kind.START:
			return RoomLayouts.START
		Kind.CHEST:
			return RoomLayouts.CHEST
		Kind.EXIT:
			return RoomLayouts.EXIT
	return RoomLayouts.FIGHTS[rng.randi_range(0, RoomLayouts.FIGHTS.size() - 1)]


## Every column of the grid is as wide as its widest room, every row as tall as its tallest,
## with a corridor's length between them. Rooms sit in the middle of their column and row, so
## neighbours line up and the corridor between them is straight.
func _place_rooms() -> void:
	var low := Vector2i.ZERO
	for room in rooms:
		low = low.min(room.grid)
	var widths := {}
	var heights := {}
	for room in rooms:
		room.grid -= low
		widths[room.grid.x] = maxi(widths.get(room.grid.x, 0), room.size.x)
		heights[room.grid.y] = maxi(heights.get(room.grid.y, 0), room.size.y)
	var gap := Config.balance.floor_corridor_tiles
	var column_centers := _centers(widths, gap)
	var row_centers := _centers(heights, gap)
	var floor_size := Vector2i.ZERO
	for room in rooms:
		var center := Vector2i(column_centers[room.grid.x], row_centers[room.grid.y])
		room.rect = Rect2i(center - room.size / 2, room.size)
		floor_size = floor_size.max(room.rect.end)
	floor_size += Vector2i.ONE * MARGIN
	for y in floor_size.y:
		var row := PackedStringArray()
		row.resize(floor_size.x)
		row.fill(VOID)
		_grid.append(row)


## The middle of each column (or row), given how wide each one is.
func _centers(sizes: Dictionary, gap: int) -> Array[int]:
	var centers: Array[int] = []
	var edge := MARGIN
	for i in sizes.size():
		centers.append(edge + sizes[i] / 2)
		edge += sizes[i] + gap
	return centers


## A straight corridor, CORRIDOR_WIDTH tiles wide with a wall on each side, from the middle of
## one room's side to the facing room. The two room-wall tiles it passes through become doors.
## Returns the corridor's area, walls included.
func _dig_corridor(a: RoomPlan, b: RoomPlan) -> Rect2i:
	# Always dig to the right or downwards, from `first` to `second`.
	var first := a
	var second := b
	if (b.grid - a.grid).x + (b.grid - a.grid).y < 0:
		first = b
		second = a
	var along := second.grid - first.grid
	var across := Vector2i(along.y, along.x)
	var start := _side_tile(first, along)
	var end := _side_tile(second, -along)
	var length := (end - start).x + (end - start).y
	for i in length + 1:
		for offset in range(-CORRIDOR_WIDTH / 2 - 1, CORRIDOR_WIDTH / 2 + 2):
			var tile := start + along * i + across * offset
			if absi(offset) > CORRIDOR_WIDTH / 2:
				if _grid[tile.y][tile.x] == VOID:
					_grid[tile.y][tile.x] = GameMap.WALL
			elif i == 0 or i == length:
				_grid[tile.y][tile.x] = DOOR
			else:
				_grid[tile.y][tile.x] = GameMap.FLOOR
	_write_layout()
	var side := across * (CORRIDOR_WIDTH / 2 + 1)
	return Rect2i(start - side, Vector2i.ONE).merge(Rect2i(end + side, Vector2i.ONE))


## The tile in the middle of `room`'s side that faces `direction`.
func _side_tile(room: RoomPlan, direction: Vector2i) -> Vector2i:
	var center := room.rect.position + room.size / 2
	if direction.x > 0:
		return Vector2i(room.rect.end.x - 1, center.y)
	if direction.x < 0:
		return Vector2i(room.rect.position.x, center.y)
	if direction.y > 0:
		return Vector2i(center.x, room.rect.end.y - 1)
	return Vector2i(center.x, room.rect.position.y)


func _write_layout() -> void:
	layout = PackedStringArray()
	for row in _grid:
		layout.append("".join(row))
