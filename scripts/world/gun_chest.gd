## A gun chest: a weapon case. Hold E for half a second to open it and it gives a random gun (C 50 %,
## B 30 %, A 15 %, S 5 %), picked when the chest appears. Ready, its light strip glows teal and
## pulses gently; locked (the Enemy Arena's, until the wave that unlocks the code chest) it glows
## red with a padlock. Opening, the lid lifts, teal light spills out and the gun rises out of it,
## then drops in front of the chest, where E takes it.
class_name GunChest
extends Interactable

enum State { LOCKED, READY, OPENING, OPEN }

const LOCKED_LOOK := preload("res://art/game/chests/gun_chest_locked.png")
const READY_LOOK := preload("res://art/game/chests/gun_chest_ready.png")
const OPEN_STRIP := preload("res://art/game/chests/gun_chest_open.png")
const OPEN_FRAMES := 8
const GUN_PICKUP := preload("res://scenes/world/gun_pickup.tscn")
## The chest picture is 30x30 and centred on the chest.
const LOOK_HALF := Vector2(15, 15)
## Pixels below the chest where the gun lands.
const DROP_OFFSET := Vector2(0, 20)
## The light strip on the picture (left, top, width, height), its colours, and its pulse: the
## light swings between PULSE_LOW and full, PULSE_SPEED radians per second.
const STRIP := Rect2(2, 16, 26, 1)
const STRIP_LOCKED := Color("#ff5873")
const STRIP_READY := Color("#74f2e0")
const PULSE_LOW := 0.6
const PULSE_SPEED := 3.0
## The rising gun, as on the approved page: from GUN_RISE_FROM of the opening it rises
## GUN_RISE_SPEED pixels per whole opening, its top starting GUN_TOP pixels down the picture.
const GUN_RISE_FROM := 0.45
const GUN_RISE_SPEED := 16.0
const GUN_TOP := 8.0
## Seconds the risen gun takes to drop to the floor in front of the chest.
const DROP_TIME := 0.15

var state := State.READY
var _gun: GunStats
var _locked_until_wave := 0
var _opening := 0.0
var _time := 0.0

@onready var _look: Sprite2D = $Sprite
@onready var _strip: ColorRect = $Strip
@onready var _rising_gun: Sprite2D = $RisingGun


func _ready() -> void:
	hold_time = Config.balance.gun_chest_open_time
	_gun = Loot.roll_chest_gun(RandomNumberGenerator.new())
	_rising_gun.texture = _gun.held_texture
	_rising_gun.visible = false
	_strip.position = STRIP.position - LOOK_HALF
	_strip.size = STRIP.size
	_show(State.LOCKED if _locked_until_wave > 0 else State.READY)


## Keeps the chest locked until `wave` starts (the Enemy Arena's gun chests).
func lock_until_wave(wave: int) -> void:
	_locked_until_wave = wave
	Events.wave_started.connect(_on_wave_started)
	if is_inside_tree():
		_show(State.LOCKED)


func can_interact() -> bool:
	return state == State.READY


func interact(_player: Player) -> void:
	set_focus(false, 0.0)
	_opening = 0.0
	_show(State.OPENING)
	Audio.play_sfx(&"chest_open")


func _process(delta: float) -> void:
	_time += delta
	_strip.modulate.a = lerpf(PULSE_LOW, 1.0, 0.5 + 0.5 * sin(_time * PULSE_SPEED))
	if state != State.OPENING:
		return
	_opening = minf(_opening + delta / Config.balance.chest_open_time, 1.0)
	_look.frame = roundi(_opening * (OPEN_FRAMES - 1))
	var rise := roundf((_opening - GUN_RISE_FROM) * GUN_RISE_SPEED)
	_rising_gun.visible = _opening > GUN_RISE_FROM
	_rising_gun.position = Vector2(floorf(LOOK_HALF.x - _rising_gun.texture.get_width() / 2.0), GUN_TOP - rise) - LOOK_HALF
	if _opening >= 1.0:
		_show(State.OPEN)
		var land := create_tween()
		land.tween_property(_rising_gun, "position", DROP_OFFSET - _rising_gun.texture.get_size() / 2.0, DROP_TIME)
		land.tween_callback(_drop_gun)


func _drop_gun() -> void:
	_rising_gun.visible = false
	var pickup: GunPickup = GUN_PICKUP.instantiate()
	pickup.owned = OwnedGun.new(_gun)
	pickup.position = position + DROP_OFFSET
	get_parent().add_child(pickup)


func _show(new_state: State) -> void:
	state = new_state
	_look.texture = OPEN_STRIP if state >= State.OPENING else (LOCKED_LOOK if state == State.LOCKED else READY_LOOK)
	_look.hframes = OPEN_FRAMES if state >= State.OPENING else 1
	_look.frame = OPEN_FRAMES - 1 if state == State.OPEN else 0
	_strip.visible = state == State.LOCKED or state == State.READY
	_strip.color = STRIP_LOCKED if state == State.LOCKED else STRIP_READY


func _on_wave_started(wave: int) -> void:
	if state == State.LOCKED and wave >= _locked_until_wave:
		_show(State.READY)
