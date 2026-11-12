
extends CanvasLayer

@onready var hp_margin_container: MarginContainer = $Control/HPMarginContainer
@onready var hp_bar: TextureProgressBar = $Control/HPMarginContainer/NinePatchRect/HPBar
@onready var coin_label: Label = $Control/CoinLabel

@onready var game_over: Control = $Control/GameOver

@onready var main_menu_button: Button = $Control/GameOver/HBoxContainer/MainMenuButton
@onready var replay_button: Button = $Control/GameOver/HBoxContainer/ReplayButton


func _ready() -> void:
	game_over.visible = false

	hp_bar.min_value = 0
	hp_bar.max_value = 100

	if not Messages.player_health_changed.is_connected(update_health_bar):
		Messages.player_health_changed.connect(update_health_bar)

	replay_button.pressed.connect(_on_replay_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	coin_label.visible = true
	coin_label.text = "Coins: 0"

	await get_tree().process_frame
	_connect_player()


func _connect_player() -> void:
	var player: Node = null

	while player == null:
		player = get_tree().get_first_node_in_group("Player")

		if player == null:
			await get_tree().process_frame

	update_health_bar(player.hp, player.max_hp)

	if not player.coin_count_changed.is_connected(update_coin_counter):
		player.coin_count_changed.connect(update_coin_counter)

	update_coin_counter(player.coins)


func update_health_bar(hp: float, max_hp: float) -> void:
	if max_hp <= 0:
		hp_bar.value = 0
		return

	hp_bar.value = (hp / max_hp) * 100


func update_coin_counter(total: int) -> void:
	coin_label.text = "Coins: " + str(total)
	coin_label.visible = true


func reset_hud() -> void:
	$Control.visible = true

	game_over.visible = false
	game_over.modulate = Color.WHITE

	main_menu_button.visible = true
	replay_button.visible = true

	coin_label.text = "Coins: 0"
	coin_label.visible = true


func show_game_over() -> void:
	$Control.visible = true

	main_menu_button.visible = false
	replay_button.visible = false

	game_over.modulate.a = 0
	game_over.visible = true

	var tween := create_tween()

	tween.tween_property(
		game_over,
		"modulate",
		Color.WHITE,
		3.0
	)

	await tween.finished

	replay_button.visible = true
	main_menu_button.visible = true
	replay_button.grab_focus()
func _on_replay_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func hide_hud() -> void:
	$Control.visible = false


func show_hud() -> void:
	$Control.visible = true
	game_over.visible = false


func show_trophy_hud() -> void:
	show_hud()
