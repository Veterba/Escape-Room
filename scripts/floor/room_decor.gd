## Dresses a room of a room type (retexture spec, "Rooms" and "Lighting"): wall lights, objects
## standing against the north wall and hung on it, the broken light, a soft light in the middle,
## details and grates on the floor, and hazard stripes in front of the doors. The Enemy Arena
## also gets its sweeping alarm light and stripes around the code chest; the Labyrinth gets red
## emergency lights on its inner walls instead of anything on its north wall.
## None of it blocks movement: room objects that do are placed by GameMap where crates were.
class_name RoomDecor

## Floor details lie above the floor and below everything else.
const DETAIL_Z := -9
## Pixels a floor detail may sit off the middle of its tile.
const DETAIL_JITTER := 4
## Tiles of hazard stripes inward from a door, and around the code chest (width, height).
const DOOR_HAZARD_DEPTH := 3
const CODE_CHEST_HAZARD := Vector2i(5, 3)
## Pixels from the top of a short inner wall face down to an emergency light.
const EMERGENCY_LIGHT_HEIGHT := 2


static func dress(map: GameMap, rect: Rect2i, room_type: StringName, rng: RandomNumberGenerator) -> void:
	var lighting := Config.lighting.for_room(room_type)
	if room_type == &"maze":
		_emergency_lights(map, rect, lighting, rng)
	else:
		_dress_north_wall(map, rect, room_type, lighting, rng)
		_mark_doors(map, rect)
	if lighting.fill.energy > 0.0:
		map.add_child(RoomLight.make(lighting.fill, map.cell_center(rect.get_center())))
	if room_type == &"arena":
		_dress_arena(map, rect)
	_dress_floor(map, rect.grow(-1), room_type, rng)


## Wall lights spread evenly along the north wall, the broken light on a random free spot, then
## from left to right objects standing against the wall or hung on it, with bare spots between.
static func _dress_north_wall(map: GameMap, rect: Rect2i, room_type: StringName, lighting: RoomLighting, rng: RandomNumberGenerator) -> void:
	var look: Dictionary = RoomStyles.LOOKS[room_type]
	var y := rect.position.y
	var free: Array[int] = []
	for x in range(rect.position.x + 1, rect.end.x - 1):
		var near_door := map.symbol_at(Vector2i(x - 1, y)) == FloorGenerator.DOOR or map.symbol_at(Vector2i(x + 1, y)) == FloorGenerator.DOOR
		if map.is_tall_face(Vector2i(x, y)) and not near_door:
			free.append(x)
	if free.is_empty():
		return
	var lamps := maxi(1, roundi(float(rect.size.x) / RoomStyles.LAMP_SPACING))
	for i in lamps:
		if free.is_empty():
			return
		var x := _nearest(free, rect.position.x + roundi((i + 0.5) * rect.size.x / lamps))
		var lamp := _hang(map, look["wall_light"], x, y, free)
		var light := _light_on(lamp, lighting.wall_light)
		# Strip lights are drawn white: they take their light's colour.
		if look["wall_light"] == &"strip_light":
			light.tinted = lamp
		_breathe(light, lighting)
		map.add_child(light)
	if lighting.broken.energy > 0.0 and not free.is_empty():
		var tube := _hang(map, look["broken_light"], free[rng.randi_range(0, free.size() - 1)], y, free)
		var light := _light_on(tube, lighting.broken)
		light.kind = RoomLight.Kind.BROKEN
		light.broken_to = lighting.broken_to
		light.tinted = tube
		map.add_child(light)
	if room_type == &"arena" and not free.is_empty():
		_hang(map, &"beacon", _nearest(free, rect.get_center().x), y, free)
	var along: Array = look["along_wall"]
	var on_wall: Array = look["on_wall"]
	for x in free.duplicate():
		if not free.has(x):
			continue
		var roll := rng.randf()
		if roll < RoomStyles.ALONG_WALL_CHANCE and not along.is_empty():
			var prop: StringName = along[rng.randi_range(0, along.size() - 1)]
			var tiles := ceili(_width(prop) / float(GameMap.TILE_SIZE))
			if range(x, x + tiles).all(func(column: int) -> bool: return free.has(column)):
				for column in range(x, x + tiles):
					free.erase(column)
				map.add_prop(prop, Vector2(x * GameMap.TILE_SIZE + tiles * GameMap.TILE_SIZE / 2.0, (y + 1) * GameMap.TILE_SIZE + RoomStyles.WALL_STAND_SINK))
		elif roll < RoomStyles.ALONG_WALL_CHANCE + RoomStyles.ON_WALL_CHANCE and not on_wall.is_empty():
			_hang(map, on_wall[rng.randi_range(0, on_wall.size() - 1)], x, y, free)


## Hangs `prop` on the tall north wall face above (x, y), as high as the approved page has it,
## and takes the tiles it covers off `free`.
static func _hang(map: GameMap, prop: StringName, x: int, y: int, free: Array[int]) -> RoomProp:
	var tiles := ceili(_width(prop) / float(GameMap.TILE_SIZE))
	for column in range(x, x + tiles):
		free.erase(column)
	var face_top := (y - 1) * GameMap.TILE_SIZE
	return _hang_at(map, prop, Vector2(x * GameMap.TILE_SIZE + tiles * GameMap.TILE_SIZE / 2.0, (y + 1) * GameMap.TILE_SIZE - 1), face_top + RoomStyles.ON_WALL_HEIGHT[prop])


## Hangs `prop` with its top at `top` (pixels). Its position stays at the bottom of the wall, so
## it is drawn over the wall and behind anyone standing in front of the wall.
static func _hang_at(map: GameMap, prop: StringName, base: Vector2, top: float) -> RoomProp:
	var sprite := map.add_prop(prop, base)
	sprite.offset.y = top + sprite.texture.get_height() / 2.0 - base.y
	return sprite


## A light in the middle of `sprite`'s picture (not added to the map yet, so it can be set up).
static func _light_on(sprite: RoomProp, spec: LightSpec) -> RoomLight:
	return RoomLight.make(spec, sprite.position + sprite.offset)


## Makes `light` breathe if the room type's wall lights do.
static func _breathe(light: RoomLight, lighting: RoomLighting) -> void:
	if lighting.breathe > 0.0:
		light.kind = RoomLight.Kind.BREATHING
		light.breathe = lighting.breathe
		light.breathe_speed = lighting.breathe_speed


## The Labyrinth's red emergency lights: on random short faces of its inner walls.
static func _emergency_lights(map: GameMap, rect: Rect2i, lighting: RoomLighting, rng: RandomNumberGenerator) -> void:
	var faces: Array[Vector2i] = []
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var cell := Vector2i(x, y)
			if map.symbol_at(cell) == GameMap.WALL and map.is_inner(cell) and map.is_open(cell + Vector2i.DOWN):
				faces.append(cell)
	faces.shuffle()
	for cell in faces.slice(0, Config.lighting.maze_emergency_lights):
		var base := Vector2(map.cell_center(cell).x, (cell.y + 1) * GameMap.TILE_SIZE - 1)
		var light := _light_on(_hang_at(map, &"beacon", base, cell.y * GameMap.TILE_SIZE + EMERGENCY_LIGHT_HEIGHT), lighting.wall_light)
		_breathe(light, lighting)
		map.add_child(light)


## The alarm light sweeping the hall, and hazard stripes and a golden glow around the code chest.
static func _dress_arena(map: GameMap, rect: Rect2i) -> void:
	var cfg := Config.lighting
	var inside := rect.grow(-1)
	var alarm := RoomLight.make(cfg.alarm, map.cell_center(rect.get_center()))
	alarm.kind = RoomLight.Kind.SWEEPING
	alarm.sweep_center = alarm.position
	alarm.sweep = Vector2(inside.size * GameMap.TILE_SIZE) * cfg.alarm_sweep
	map.add_child(alarm)
	for child in map.get_children():
		if child is CodeChest:
			map.add_child(RoomLight.make(cfg.code_chest, child.position))
			var middle := Vector2i((child.position / GameMap.TILE_SIZE).floor())
			for dy in CODE_CHEST_HAZARD.y:
				for dx in CODE_CHEST_HAZARD.x:
					var cell := middle - CODE_CHEST_HAZARD / 2 + Vector2i(dx, dy)
					if map.is_open(cell):
						map.set_floor_tile(cell, RoomStyles.HAZARD)


## Hazard stripes on each door and the tiles just inside it.
static func _mark_doors(map: GameMap, rect: Rect2i) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			var door := Vector2i(x, y)
			if map.symbol_at(door) != FloorGenerator.DOOR:
				continue
			var inward := Vector2i.RIGHT if x == rect.position.x else Vector2i.LEFT if x == rect.end.x - 1 \
					else Vector2i.DOWN if y == rect.position.y else Vector2i.UP
			for i in DOOR_HAZARD_DEPTH:
				if map.is_open(door + inward * i):
					map.set_floor_tile(door + inward * i, RoomStyles.HAZARD)


## Details (oil, debris, papers, cables...) and grates on random plain floor tiles.
static func _dress_floor(map: GameMap, inside: Rect2i, room_type: StringName, rng: RandomNumberGenerator) -> void:
	var details: Array = RoomStyles.LOOKS[room_type]["details"]
	var plain: Array[Vector2i] = []
	for y in range(inside.position.y, inside.end.y):
		for x in range(inside.position.x, inside.end.x):
			if map.symbol_at(Vector2i(x, y)) == GameMap.FLOOR:
				plain.append(Vector2i(x, y))
	plain.shuffle()
	var area := inside.get_area()
	for i in mini(maxi(1, area / RoomStyles.TILES_PER_GRATE), plain.size()):
		map.set_floor_tile(plain.pop_back(), RoomStyles.GRATE)
	for i in mini(area / RoomStyles.TILES_PER_DETAIL, plain.size()):
		var jitter := Vector2(rng.randi_range(-DETAIL_JITTER, DETAIL_JITTER), rng.randi_range(-DETAIL_JITTER, DETAIL_JITTER))
		var detail := map.add_prop(details[rng.randi_range(0, details.size() - 1)], map.cell_center(plain.pop_back()) + jitter)
		detail.z_index = DETAIL_Z


## The free tile in `free` closest to column `x`.
static func _nearest(free: Array[int], x: int) -> int:
	var best := free[0]
	for column in free:
		if absi(column - x) < absi(best - x):
			best = column
	return best


## The width of one frame of `prop`'s picture, in pixels.
static func _width(prop: StringName) -> int:
	return RoomStyles.texture(prop).get_width() / RoomStyles.PROPS[prop][0]
