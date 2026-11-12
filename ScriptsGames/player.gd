
class_name Player
extends CharacterBody2D

const DEBUG_JUMP_INDICATOR = preload("uid://c3rmn6g1tfvy")

signal damage_taken
signal coin_count_changed(total: int)

var coins: int = 0
#region Onready Variables
@onready var sprite: PlayerSprite = $Sprite2D
@onready var attack_sprite_2d: Sprite2D = %AttackSprite2D
@onready var collision_stand: CollisionShape2D = $CollisionStand
@onready var collision_crouch: CollisionShape2D = $CollisionCrouch
@onready var da_stand: CollisionShape2D = %DAStand
@onready var da_crouch: CollisionShape2D = %DACrouch
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var one_way_platform_shape_cast: ShapeCast2D = $OneWayPlatformShapeCast
@onready var attack_area: AttackArea = %AttackArea
@onready var damage_area: DamageArea = %DamageArea
#endregion

#region Export Variables
@export var move_speed: float = 150
@export var max_fall_velocity: float = 600.0
#endregion

#region State Machine Variables
var states: Array[PlayerState]

var current_state: PlayerState:
	get:
		if states.is_empty():
			return null
		return states[0]

var previous_state: PlayerState:
	get:
		if states.size() < 2:
			return null
		return states[1]
#endregion

#region Health Variables
var hp: float = 3:
	set(value):
		hp = clampf(value, 0, max_hp)
		Messages.player_health_changed.emit(hp, max_hp)

var max_hp: float = 3:
	set(value):
		max_hp = value
		Messages.player_health_changed.emit(hp, max_hp)
#endregion

#region Abilities
var dash: bool = true
var dash_count: int = 0
var double_jump: bool = true
var jump_count: int = 0
var ground_slam: bool = true
var morph_roll: bool = true
#endregion

#region Standard Variables
var direction: Vector2 = Vector2.ZERO
var gravity: float = 980
var gravity_multiplier: float = 1.0
#endregion


func _ready() -> void:
	initialize_states()
	damage_area.damage_taken.connect(_on_damage_taken)
	hp = max_hp


func _unhandled_input(event: InputEvent) -> void:
	if current_state == null:
		return

	if event.is_action_released("jump"):
		velocity.y += 0.5

	change_state(current_state.handle_input(event))


func _process(delta: float) -> void:
	if current_state == null:
		return

	update_direction()
	change_state(current_state.process(delta))


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta * gravity_multiplier
	velocity.y = clampf(velocity.y, -1000.0, max_fall_velocity)
	move_and_slide()

	if current_state == null:
		return

	change_state(current_state.physics_process(delta))


func initialize_states() -> void:
	states.clear()

	for c in $States.get_children():
		if c is PlayerState:
			states.append(c)
			c.player = self

	if states.is_empty():
		push_error("No PlayerState found!")
		return

	var idle_state: PlayerState = null

	for state in states:
		if state is PlayerStateIdle:
			idle_state = state
			break

	if idle_state == null:
		push_error("Idle State not found!")
		return

	states.erase(idle_state)
	states.push_front(idle_state)

	current_state.enter()


func change_state(new_state: PlayerState) -> void:
	if new_state == null or states.is_empty():
		return

	if new_state == current_state:
		return

	current_state.exit()
	states.push_front(new_state)
	states.resize(mini(states.size(), 3))
	new_state.enter()


func update_direction() -> void:
	var prev_direction: Vector2 = direction
	var x_axis = Input.get_axis("left", "right")
	var y_axis = Input.get_axis("up", "down")
	direction = Vector2(x_axis, y_axis)

	if prev_direction.x != direction.x:
		attack_area.flip(direction.x)

		if direction.x < 0:
			sprite.flip_h = true
			attack_sprite_2d.flip_h = true
			attack_sprite_2d.position.x = -24
		elif direction.x > 0:
			sprite.flip_h = false
			attack_sprite_2d.flip_h = false
			attack_sprite_2d.position.x = 24


func add_debug_indicator(color: Color = Color.RED) -> void:
	var d: Node2D = DEBUG_JUMP_INDICATOR.instantiate()
	get_tree().root.add_child(d)
	d.global_position = global_position
	d.modulate = color
	await get_tree().create_timer(3.0).timeout
	d.queue_free()


func can_dash() -> bool:
	if not dash or dash_count > 0:
		return false
	return true


func can_morph() -> bool:
	if not morph_roll:
		return false
	return true


func _on_damage_taken(attack_area: AttackArea) -> void:
	if current_state == null:
		return

	if current_state == current_state.death:
		return

	if current_state == current_state.take_damage:
		return

	hp -= attack_area.damage
	damage_taken.emit()

	if hp <= 0:
		change_state(current_state.death)
	else:
		var take_damage_state: PlayerStateTakeDamage = current_state.take_damage

		if attack_area.global_position.x < global_position.x:
			take_damage_state.dir = 1.0
		else:
			take_damage_state.dir = -1.0

		change_state(take_damage_state)


func add_coins(amount: int) -> void:
	coins += amount
	coin_count_changed.emit(coins)
