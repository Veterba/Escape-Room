## The code chest in the Enemy Arena. It is chained shut until wave 7 starts; then the chains
## fall off. Hold E for 2 s to open it (a hit cancels the hold) and it drops the secret code.
class_name CodeChest
extends Interactable

const CODE_PICKUP := preload("res://scenes/world/code_pickup.tscn")
const PUFF := preload("res://scenes/fx/death_puff.tscn")
## Opened chests are drawn darker.
const OPENED_TINT := Color(0.5, 0.5, 0.5)
## Pixels below the chest where the code lands.
const DROP_OFFSET := Vector2(0, 20)
## How far the chains drop, and in how many seconds, while they fade out.
const CHAINS_FALL := Vector2(0, 8)
const CHAINS_FALL_TIME := 0.4

var locked := true
var _opened := false

@onready var _chains: Sprite2D = $Chains


func _ready() -> void:
	hold_time = Config.balance.code_chest_open_time
	Events.wave_started.connect(_on_wave_started)


func can_interact() -> bool:
	return not locked and not _opened


## Drops the chains with a small puff. Does nothing if the chest is already unlocked.
func unlock() -> void:
	if not locked:
		return
	locked = false
	var fall := create_tween().set_parallel()
	fall.tween_property(_chains, "position", _chains.position + CHAINS_FALL, CHAINS_FALL_TIME)
	fall.tween_property(_chains, "modulate:a", 0.0, CHAINS_FALL_TIME)
	var puff: Node2D = PUFF.instantiate()
	puff.position = position
	get_parent().add_child(puff)
	Audio.play_sfx(&"chains_fall")


func interact(_player: Player) -> void:
	_opened = true
	modulate = OPENED_TINT
	set_focus(false, 0.0)
	var code: Node2D = CODE_PICKUP.instantiate()
	code.position = position + DROP_OFFSET
	get_parent().add_child(code)
	Audio.play_sfx(&"chest_open")


func _on_wave_started(wave: int) -> void:
	if wave >= Config.balance.arena_chest_unlock_wave:
		unlock()
