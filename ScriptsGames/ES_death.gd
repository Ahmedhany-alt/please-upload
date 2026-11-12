class_name ESDeath
extends Enemystate


func enter() -> void:
	blackboard.can_decide = false

	if enemy.damage_area:
		enemy.damage_area.set_deferred("monitoring", false)

	if enemy.hazard_area:
		enemy.hazard_area.set_deferred("monitoring", false)

	var anim: String = animation_name if animation_name else "Death"

	if enemy.animation and enemy.animation.has_animation(anim):
		enemy.animation.play(anim)
		await enemy.animation.animation_finished

	enemy.queue_free()


func re_enter() -> void:
	pass


func exit() -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
