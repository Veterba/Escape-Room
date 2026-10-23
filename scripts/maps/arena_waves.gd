## Sends the Enemy Arena's waves. Wave 1 starts at once; the next starts every 30 s, or as soon
## as fewer than 3 enemies are alive. Never more than 12 are alive: a wave that would go over
## skips the rest. Enemies appear on floor near the edges of the map, away from the player.
## Must be a child of the arena's GameMap.
class_name ArenaWaves
extends Node

const ENEMY_SPAWN := preload("res://scenes/fx/enemy_spawn.tscn")
const GRUNT := preload("res://scenes/enemies/grunt_kin.tscn")
const FUSE := preload("res://scenes/enemies/fuse_kin.tscn")
const ROCKET := preload("res://scenes/enemies/rocket_kin.tscn")
const WING := preload("res://scenes/enemies/wing_kin.tscn")

## The wave that started last (0 before the first).
var wave := 0
var _next_wave_in := 0.0

@onready var _map: GameMap = get_parent()


func _physics_process(delta: float) -> void:
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
	var enemies := _enemies_for(cfg.arena_waves[mini(wave, cfg.arena_waves.size()) - 1])
	enemies.shuffle()  # So the enemies skipped at the limit are not always the same kind.
	var room := cfg.arena_max_alive - alive_count()
	var cells := _spawn_cells()
	cells.shuffle()
	for i in mini(mini(room, enemies.size()), cells.size()):
		var spawn: EnemySpawn = ENEMY_SPAWN.instantiate()
		spawn.scene = enemies[i]
		spawn.position = _map.cell_center(cells[i])
		_map.add_child(spawn)
	Events.wave_started.emit(wave)


func _enemies_for(mix: ArenaWave) -> Array[PackedScene]:
	var enemies: Array[PackedScene] = []
	for kind: Array in [[GRUNT, mix.grunts], [FUSE, mix.fuses], [ROCKET, mix.rockets], [WING, mix.wings]]:
		for i in kind[1]:
			enemies.append(kind[0])
	return enemies


## Free floor near the map's edges, far enough from the player.
func _spawn_cells() -> Array[Vector2i]:
	var cfg := Config.balance
	var size := _map.bounds.size / GameMap.TILE_SIZE
	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	var cells: Array[Vector2i] = []
	for cell in _map.free_floor_cells:
		var edge_distance := mini(mini(cell.x, cell.y), mini(size.x - 1 - cell.x, size.y - 1 - cell.y))
		if edge_distance > cfg.arena_spawn_edge_tiles:
			continue
		if player and player.global_position.distance_to(_map.cell_center(cell)) < cfg.arena_spawn_min_distance:
			continue
		cells.append(cell)
	return cells
