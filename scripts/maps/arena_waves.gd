## Sends the Enemy Arena's waves once the player walks into the arena room. Wave 1 starts at
## once; the next starts every 30 s, or as soon as fewer than 3 enemies are alive. Never more
## than 12 are alive: a wave that would go over skips the rest. Enemies appear on floor near
## the arena's walls, away from the player.
class_name ArenaWaves
extends Node

## The wave that started last (0 before the first).
var wave := 0
## Off until the player enters the arena (set by the room).
var active := false
var room: Room
var _next_wave_in := 0.0


func _physics_process(delta: float) -> void:
	if not active:
		return
	_next_wave_in -= delta
	if _next_wave_in <= 0.0 or alive_count() < Config.balance.arena_min_alive:
		start_next_wave()


## Enemies alive, counting the ones still appearing.
func alive_count() -> int:
	return get_tree().get_node_count_in_group(&"enemies") + get_tree().get_node_count_in_group(&"enemy_spawns")


func start_next_wave() -> void:
	var cfg := Config.balance
	wave += 1
	_next_wave_in = cfg.arena_wave_interval
	var enemies := Room.enemies_for(cfg.arena_waves[mini(wave, cfg.arena_waves.size()) - 1])
	enemies.shuffle()  # So the enemies skipped at the limit are not always the same kind.
	var room_left := cfg.arena_max_alive - alive_count()
	var cells := _spawn_cells()
	cells.shuffle()
	for i in mini(mini(room_left, enemies.size()), cells.size()):
		var marker: EnemySpawn = Room.ENEMY_SPAWN.instantiate()
		marker.scene = enemies[i]
		marker.leash = room.inside_area()
		marker.position = room.map.cell_center(cells[i])
		room.add_child(marker)
	Events.wave_started.emit(wave)


## Free floor near the arena's walls, far enough from the player.
func _spawn_cells() -> Array[Vector2i]:
	var cfg := Config.balance
	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	var inside := room.rect.grow(-1)
	var cells: Array[Vector2i] = []
	for cell in room.map.free_floor_cells:
		if not inside.has_point(cell):
			continue
		var from_wall := mini(mini(cell.x - inside.position.x, cell.y - inside.position.y),
				mini(inside.end.x - 1 - cell.x, inside.end.y - 1 - cell.y))
		if from_wall >= cfg.arena_spawn_edge_tiles:
			continue
		if player and player.global_position.distance_to(room.map.cell_center(cell)) < cfg.arena_spawn_min_distance:
			continue
		cells.append(cell)
	return cells
