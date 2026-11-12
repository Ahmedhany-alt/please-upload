class_name DecisionEngineBasic
extends DecisionEngine


func _ready() -> void:
	await super()


func decide() -> Enemystate:
	if blackboard.health <= 0:
		return get_state(ESDeath)

	if current_state is ESDeath:
		return null

	if blackboard.damage_source:
		return get_state(ESStun)

	if not blackboard.can_decide:
		return null

	if blackboard.edge_detected:
		enemy.change_dir(-blackboard.dir)

	return get_state(ESWalk)
func get_state(state_class: GDScript) -> Enemystate:
	for state in enemy.state_machine.states:
		if state.get_script() == state_class:
			return state

	return null
