class_name PlayerStateTakeDamage
extends PlayerState

@export var move_speed: float = 100
@export var invulnerable_duration: float = 0.5

var time: float = 0.0
var dir: float = 1.0

@onready var damage_area: DamageArea = %DamageArea


func enter() -> void:
	player.animation_player.play("take_damage")
	time = player.animation_player.current_animation_length
	damage_area.make_invulnerable(invulnerable_duration)
	VisualEffects.camera_shake()


func exit() -> void:
	pass


func handle_input(_event: InputEvent) -> PlayerState:
	return next_state


func process(delta: float) -> PlayerState:
	time -= delta

	if time <= 0:
		if player.hp <= 0:
			return death
		return idle

	return null


func physics_process(_delta: float) -> PlayerState:
	player.velocity.x = move_speed * dir
	return null
