## The code chest in the Enemy Arena: a heavy vault in chains with a padlock. It stays chained
## until the unlock wave starts; then the chains break and fall and the padlock drops. Hold E for
## 2 s to open it (a hit cancels the hold): the lid opens, golden light shines out and the key
## (the secret code) rises, then drops in front of the chest.
class_name CodeChest
extends Interactable

enum State { CHAINED, UNCHAINING, READY, OPENING, OPEN }

const CHAINED_LOOK := preload("res://art/game/chests/code_chest_chained.png")
const UNCHAIN_STRIP := preload("res://art/game/chests/code_chest_unchain.png")
const UNCHAIN_FRAMES := 6
const OPEN_STRIP := preload("res://art/game/chests/code_chest_open.png")
const OPEN_FRAMES := 8
const CODE_PICKUP := preload("res://scenes/world/code_pickup.tscn")
## The chest picture is 34x34 and centred on the chest.
const LOOK_HALF := Vector2(17, 17)
## Pixels below the chest where the key lands.
const DROP_OFFSET := Vector2(0, 20)
## The rising key, as on the approved page: from KEY_RISE_FROM of the opening it rises
## KEY_RISE_SPEED pixels per whole opening, its top starting KEY_TOP pixels down the picture.
const KEY_RISE_FROM := 0.4
const KEY_RISE_SPEED := 18.0
const KEY_TOP := 8.0
## Seconds the risen key takes to drop to where it floats in front of the chest.
const DROP_TIME := 0.15

var state := State.CHAINED
## True until the chains have come off.
var locked: bool:
	get:
		return state == State.CHAINED or state == State.UNCHAINING
var _anim := 0.0

@onready var _look: Sprite2D = $Sprite
@onready var _rising_key: Sprite2D = $RisingKey


func _ready() -> void:
	hold_time = Config.balance.code_chest_open_time
	Events.wave_started.connect(_on_wave_started)
	_rising_key.visible = false
	_show(State.CHAINED)


func can_interact() -> bool:
	return state == State.READY


## Breaks the chains. Does nothing if they are already coming off.
func unlock() -> void:
	if state != State.CHAINED:
		return
	_anim = 0.0
	_show(State.UNCHAINING)
	Audio.play_sfx(&"chains_fall")


func interact(_player: Player) -> void:
	set_focus(false, 0.0)
	_anim = 0.0
	_show(State.OPENING)
	Audio.play_sfx(&"chest_open")


func _process(delta: float) -> void:
	var cfg := Config.balance
	if state == State.UNCHAINING:
		_anim = minf(_anim + delta / cfg.code_chest_unchain_time, 1.0)
		_look.frame = roundi(_anim * (UNCHAIN_FRAMES - 1))
		if _anim >= 1.0:
			_show(State.READY)
	elif state == State.OPENING:
		_anim = minf(_anim + delta / cfg.chest_open_time, 1.0)
		_look.frame = roundi(_anim * (OPEN_FRAMES - 1))
		var rise := roundf((_anim - KEY_RISE_FROM) * KEY_RISE_SPEED)
		_rising_key.visible = _anim > KEY_RISE_FROM
		_rising_key.position = Vector2(floorf(LOOK_HALF.x - _rising_key.texture.get_width() / 2.0), KEY_TOP - rise) - LOOK_HALF
		if _anim >= 1.0:
			_show(State.OPEN)
			var land := create_tween()
			var floating := DROP_OFFSET - Vector2(0.0, KeyPickup.HOVER) - _rising_key.texture.get_size() / 2.0
			land.tween_property(_rising_key, "position", floating, DROP_TIME)
			land.tween_callback(_drop_key)


func _drop_key() -> void:
	_rising_key.visible = false
	var code: Node2D = CODE_PICKUP.instantiate()
	code.position = position + DROP_OFFSET
	get_parent().add_child(code)


## The picture for each state: chained, the unchain strip, then the open strip (its first frame
## is the chest closed without chains).
func _show(new_state: State) -> void:
	state = new_state
	match state:
		State.CHAINED:
			_look.texture = CHAINED_LOOK
			_look.hframes = 1
		State.UNCHAINING, State.READY:
			_look.texture = UNCHAIN_STRIP
			_look.hframes = UNCHAIN_FRAMES
			_look.frame = UNCHAIN_FRAMES - 1 if state == State.READY else 0
		State.OPENING, State.OPEN:
			_look.texture = OPEN_STRIP
			_look.hframes = OPEN_FRAMES
			_look.frame = OPEN_FRAMES - 1 if state == State.OPEN else 0


func _on_wave_started(wave: int) -> void:
	if wave >= Config.balance.arena_chest_unlock_wave:
		unlock()
