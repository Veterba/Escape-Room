## Generates the Enemy Arena and the Boss Chamber fresh every round, as GameMap layouts. Both are
## mirrored left to right, so they look built rather than random. Crates and pillars always keep
## one free tile around them, so every floor tile stays reachable.
class_name ObjectiveRooms

const ARENA_SIZE := Vector2i(48, 31)
## The code chest's four fixed spots and the two gun chests (spec 8.3), as tiles in the arena.
const ARENA_CODE_SPOTS: Array[Vector2i] = [Vector2i(5, 3), Vector2i(42, 3), Vector2i(4, 14), Vector2i(43, 14)]
const ARENA_GUN_CHESTS: Array[Vector2i] = [Vector2i(14, 25), Vector2i(33, 25)]
## Crate shapes the arena is built from, in tiles.
const CRATE_SHAPES: Array[Vector2i] = [Vector2i(2, 2), Vector2i(3, 1), Vector2i(1, 3), Vector2i(2, 1)]
## Tiles along the walls and around chests and doors that stay free (spawns, doors, walking).
const KEEP_CLEAR := 3
## Tries to place one crate group or barrel before giving up on it.
const PLACE_TRIES := 50

const BOSS_SIZE := Vector2i(30, 20)
## The four pillars are 2x2 and sit this many tiles (or more) from the walls and the middle.
const PILLAR_SIZE := Vector2i(2, 2)
const PILLAR_MIN := Vector2i(4, 3)
const PILLAR_MAX := Vector2i(10, 6)


static func arena(rng: RandomNumberGenerator) -> PackedStringArray:
	var cfg := Config.balance
	var grid := _empty_room(ARENA_SIZE)
	var reserved: Array[Rect2i] = _door_lanes(ARENA_SIZE)
	for spot in ARENA_CODE_SPOTS + ARENA_GUN_CHESTS:
		grid[spot.y][spot.x] = GameMap.CODE_CHEST_SPOT if ARENA_CODE_SPOTS.has(spot) else "G"
		reserved.append(Rect2i(spot, Vector2i.ONE).grow(2))
	for i in cfg.arena_crate_groups / 2:
		var shape := CRATE_SHAPES[rng.randi_range(0, CRATE_SHAPES.size() - 1)]
		_place_mirrored(grid, reserved, shape, GameMap.CRATE, rng)
	for i in cfg.arena_barrels / 2:
		_place_mirrored(grid, reserved, Vector2i.ONE, "b", rng)
	return _to_layout(grid)


## Four mirrored pillars; the Ammo Wraith appears in the middle when the player walks in.
static func boss(rng: RandomNumberGenerator) -> PackedStringArray:
	var grid := _empty_room(BOSS_SIZE)
	var center := BOSS_SIZE / 2
	var offset := Vector2i(rng.randi_range(PILLAR_MIN.x, PILLAR_MAX.x), rng.randi_range(PILLAR_MIN.y, PILLAR_MAX.y))
	for x in [center.x - offset.x - PILLAR_SIZE.x, center.x + offset.x]:
		for y in [center.y - offset.y - PILLAR_SIZE.y, center.y + offset.y]:
			_fill(grid, Rect2i(Vector2i(x, y), PILLAR_SIZE), GameMap.WALL)
	return _to_layout(grid)


## Floor with a wall all around.
static func _empty_room(size: Vector2i) -> Array[PackedStringArray]:
	var grid: Array[PackedStringArray] = []
	for y in size.y:
		var row := PackedStringArray()
		row.resize(size.x)
		row.fill(GameMap.FLOOR)
		if y == 0 or y == size.y - 1:
			row.fill(GameMap.WALL)
		row[0] = GameMap.WALL
		row[size.x - 1] = GameMap.WALL
		grid.append(row)
	return grid


## The strip along the walls and the straight lanes in from the middle of each side, where doors
## may open, stay free.
static func _door_lanes(size: Vector2i) -> Array[Rect2i]:
	var center := size / 2
	return [
		Rect2i(0, 0, size.x, KEEP_CLEAR), Rect2i(0, size.y - KEEP_CLEAR, size.x, KEEP_CLEAR),
		Rect2i(0, 0, KEEP_CLEAR, size.y), Rect2i(size.x - KEEP_CLEAR, 0, KEEP_CLEAR, size.y),
		Rect2i(center.x - 2, 0, 5, size.y), Rect2i(0, center.y - 2, size.x, 5),
	]


## Puts `shape` at a random free place on the left half and its mirror image on the right half.
## Each placed shape reserves one tile around itself, so nothing ever touches and paths stay open.
static func _place_mirrored(grid: Array[PackedStringArray], reserved: Array[Rect2i], shape: Vector2i,
		symbol: String, rng: RandomNumberGenerator) -> void:
	var width := grid[0].size()
	for attempt in PLACE_TRIES:
		var at := Vector2i(rng.randi_range(1, width / 2 - shape.x), rng.randi_range(1, grid.size() - 1 - shape.y))
		var rect := Rect2i(at, shape)
		var mirror := Rect2i(Vector2i(width - at.x - shape.x, at.y), shape)
		if reserved.any(func(taken: Rect2i) -> bool: return taken.intersects(rect.grow(1)) or taken.intersects(mirror.grow(1))):
			continue
		_fill(grid, rect, symbol)
		_fill(grid, mirror, symbol)
		reserved.append(rect)
		reserved.append(mirror)
		return


static func _fill(grid: Array[PackedStringArray], rect: Rect2i, symbol: String) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			grid[y][x] = symbol


static func _to_layout(grid: Array[PackedStringArray]) -> PackedStringArray:
	var layout := PackedStringArray()
	for row in grid:
		layout.append("".join(row))
	return layout
