## Base for every enemy: waking up, hit points, hit flash and knockback, pathfinding towards a
## point, line of sight, shooting, and the death puff with a chance of a drop.
class_name Enemy
extends CharacterBody2D

const ENEMY_BULLET := preload("res://scenes/enemies/enemy_bullet.tscn")
## Enemies look and shoot from this height above their feet.
const EYE_OFFSET := Vector2(0, -10)
## Physics layer 1: walls. Only walls block line of sight.
const WALL_MASK := 1

var hp := 1
## Enemies idle until they see the player or the player comes close; then they stay awake.
var awake := false
var _knockback := Vector2.ZERO
var _dead := false

@onready var body: AnimatedSprite2D = $Body
@onready var juice: Juice = $Juice
@onready var _nav: NavigationAgent2D = $Nav


## The player to go after, or null while this enemy is idle or the player is dead.
## Wakes the enemy up the first time it sees the player or the player comes within range.
func target_player() -> Player:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player == null or player.state == Player.State.DEAD:
		return null
	if not awake:
		var close := global_position.distance_to(player.global_position) <= Config.balance.enemy_wake_distance
		awake = close or can_see(player.hurtbox_position())
	return player if awake else null


## Where bullets and blasts hit: the middle of the body.
func hitbox_position() -> Vector2:
	return $Hitbox/Shape.global_position


## Loses `amount` hit points with a white flash and a push along `direction`.
func take_damage(amount: int, direction: Vector2) -> void:
	if _dead:
		return
	hp -= amount
	juice.hit_flash()
	_knockback = direction.normalized() * Config.balance.enemy_knockback_speed
	if hp <= 0:
		die()


## Death puff, maybe a drop, and gone.
func die() -> void:
	_dead = true
	juice.spawn_death_puff()
	_drop_loot()
	Events.enemy_died.emit(self)
	Audio.play_sfx(&"enemy_die")
	queue_free()


## Velocity that walks towards `point` along the navigation path, around walls.
func path_velocity(point: Vector2, speed: float) -> Vector2:
	_nav.target_position = point
	if _nav.is_navigation_finished():
		return Vector2.ZERO
	return global_position.direction_to(_nav.get_next_path_position()) * speed


## Moves with `desired` velocity plus any knockback, and animates walking.
func move(desired: Vector2, delta: float) -> void:
	velocity = desired + _knockback
	_knockback = _knockback.move_toward(Vector2.ZERO, Config.balance.knockback_decay * delta)
	move_and_slide()
	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	if awake and player:
		body.flip_h = player.global_position.x < global_position.x
	body.play(&"walk" if desired != Vector2.ZERO else &"idle")
	juice.update_walk(delta, desired != Vector2.ZERO)


## True if no wall is between this enemy's eyes and `point`.
func can_see(point: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(global_position + EYE_OFFSET, point, WALL_MASK)
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


## Fires one bullet from the eyes. `bullet_scene` picks the look (the Wing Kin's are teal).
## Costs the player a heart while their hurtbox overlaps `contact` (the player's own
## invulnerability after a hit limits it to one heart per touch).
func hurt_touching_player(contact: Area2D) -> void:
	for area in contact.get_overlapping_areas():
		var player := area.owner as Player
		player.take_hit(player.global_position - global_position)


func shoot(direction: Vector2, speed: float, bullet_scene: PackedScene = ENEMY_BULLET) -> void:
	var bullet: EnemyBullet = bullet_scene.instantiate()
	bullet.global_position = global_position + EYE_OFFSET
	bullet.setup(direction, speed)
	get_tree().current_scene.add_child(bullet)
	Audio.play_sfx(&"enemy_shot")


func _drop_loot() -> void:
	var drop := Loot.roll_enemy_drop(RandomNumberGenerator.new())
	if drop:
		var pickup: Node2D = drop.instantiate()
		pickup.global_position = global_position
		get_tree().current_scene.add_child.call_deferred(pickup)
