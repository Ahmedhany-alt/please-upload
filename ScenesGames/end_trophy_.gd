
extends Area2D

@export_range(1, 3) var level_number: int = 1

var collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if collected:
		return

	if body is Player:
		collected = true

		Progressmanager.complete_level(level_number)

		PlayerHud.show_game_over()

		print("ECHO: Level ", level_number, " trophy collected.")
		print("ECHO: Progress saved.")

		queue_free()
