
extends Node

var highest_unlocked_level: int = 1


func _ready() -> void:
	highest_unlocked_level = 1
	print("ECHO: New game session. Level 1 unlocked.")


func complete_level(level_number: int) -> void:
	if level_number < 1 or level_number > 3:
		return

	var next_level: int = mini(level_number + 1, 3)

	if next_level > highest_unlocked_level:
		highest_unlocked_level = next_level

	print("ECHO: Level ", level_number, " completed.")
	print("ECHO: Highest unlocked level: ", highest_unlocked_level)


func is_level_unlocked(level_number: int) -> bool:
	return level_number <= highest_unlocked_level
