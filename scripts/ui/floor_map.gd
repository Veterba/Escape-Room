## Tab shows a map of the floor: the rooms the player has walked into, the rooms joined to them
## (as outlines), the corridors between them, and where the player is. The labyrinth has no map:
## finding the way is the point of it.
class_name FloorMap
extends CanvasLayer

## Space around the map, in screen pixels.
const MARGIN := 24.0
const BACK_COLOR := Color(0.043, 0.031, 0.063, 0.9)
const SEEN_COLOR := Color("#4A4258")
const KNOWN_COLOR := Color("#2C2636")
const CORRIDOR_COLOR := Color("#4A4258")
const PLAYER_COLOR := Color("#F0B43C")
const OBJECTIVE_COLOR := Color("#E0403A")
const CHEST_COLOR := Color("#3FC1B0")
const TEXT_COLOR := Color("#F3E7D3")
const OUTLINE_WIDTH := 1.0
const CORRIDOR_WIDTH := 3.0
const PLAYER_RADIUS := 3.0
## A chest room's mark is a square this many screen pixels wide.
const MARK_SIZE := 4.0
const FONT_SIZE := 16

var _round: Round

@onready var _view: Control = $View


func _ready() -> void:
	visible = false
	_view.draw.connect(_draw_map)


func bind(round_node: Round) -> void:
	_round = round_node


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"map"):
		visible = not visible


func _process(_delta: float) -> void:
	if visible:
		_view.queue_redraw()


func _draw_map() -> void:
	var screen := _view.get_rect()
	_view.draw_rect(screen, BACK_COLOR)
	var dungeon := _round.map as DungeonFloor
	if dungeon == null:
		var font := ThemeDB.fallback_font
		var width := font.get_string_size(Strings.NO_MAP, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
		_view.draw_string(font, screen.get_center() - Vector2(width / 2.0, 0.0), Strings.NO_MAP,
				HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, TEXT_COLOR)
		return
	# Floor pixels to screen pixels: as big as fits, in the middle of the screen.
	var floor_size := Vector2(dungeon.bounds.size)
	var zoom := minf((screen.size.x - 2.0 * MARGIN) / floor_size.x, (screen.size.y - 2.0 * MARGIN) / floor_size.y)
	var origin := screen.get_center() - floor_size * zoom / 2.0
	var to_screen := func(point: Vector2) -> Vector2: return origin + point * zoom

	for room in dungeon.rooms:
		if room.parent_room and (room.entered or room.parent_room.entered):
			_view.draw_line(to_screen.call(_middle(room)), to_screen.call(_middle(room.parent_room)), CORRIDOR_COLOR, CORRIDOR_WIDTH)
	for room in dungeon.rooms:
		if not _is_known(room):
			continue
		var area := Rect2(to_screen.call(Vector2(room.rect.position * GameMap.TILE_SIZE)), Vector2(room.rect.size * GameMap.TILE_SIZE) * zoom)
		_view.draw_rect(area, SEEN_COLOR if room.entered else KNOWN_COLOR)
		if room.kind == FloorGenerator.Kind.OBJECTIVE:
			_view.draw_rect(area, OBJECTIVE_COLOR, false, OUTLINE_WIDTH)
		elif room.kind == FloorGenerator.Kind.CHEST:
			_view.draw_rect(Rect2(area.get_center() - Vector2.ONE * MARK_SIZE / 2.0, Vector2.ONE * MARK_SIZE), CHEST_COLOR)
	_view.draw_circle(to_screen.call(_round.player.global_position), PLAYER_RADIUS, PLAYER_COLOR)


## A room is on the map once the player was in it or in a room joined to it.
func _is_known(room: Room) -> bool:
	if room.entered or (room.parent_room and room.parent_room.entered):
		return true
	var dungeon := _round.map as DungeonFloor
	return dungeon.rooms.any(func(other: Room) -> bool: return other.parent_room == room and other.entered)


func _middle(room: Room) -> Vector2:
	return Vector2(room.rect.get_center() * GameMap.TILE_SIZE)
