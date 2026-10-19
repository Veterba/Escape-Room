## The in-game HUD: hearts top-left; gun, ammo and smoke bombs top-right.
class_name Hud
extends CanvasLayer

const HEART_TEXTURE := preload("res://art/game/item_heart.png")

var _gun: Gun

@onready var _hearts: HBoxContainer = $Root/Hearts
@onready var _gun_icon: TextureRect = $Root/Loadout/Row/GunIcon
@onready var _ammo_label: Label = $Root/Loadout/Row/AmmoLabel
@onready var _smoke_label: Label = $Root/Loadout/Row/SmokeLabel


## Connects the HUD to the player it shows.
func bind(player: Player) -> void:
	_gun = player.gun
	_gun.changed.connect(_refresh_gun)
	_refresh_gun()
	_show_hearts(player.hearts)
	_smoke_label.text = str(player.smoke_bombs)


func _show_hearts(count: int) -> void:
	for child in _hearts.get_children():
		child.queue_free()
	for i in count:
		var heart := TextureRect.new()
		heart.texture = HEART_TEXTURE
		_hearts.add_child(heart)


func _refresh_gun() -> void:
	_gun_icon.texture = _gun.stats.texture
	if _gun.is_reloading:
		_ammo_label.text = Strings.RELOADING
		return
	var reserve := Strings.INFINITE_AMMO if _gun.stats.infinite_reserve else str(_gun.reserve)
	_ammo_label.text = Strings.AMMO_FORMAT % [_gun.in_magazine, reserve]
