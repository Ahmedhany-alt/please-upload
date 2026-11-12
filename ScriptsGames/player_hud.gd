
extends CanvasLayer

@onready var hp_margin_container: MarginContainer = %HPMarginContainer
@onready var hp_bar: TextureProgressBar = %HPBar
@onready var coin_label: Label = %CoinLabel

@onready var game_over: Control = $Control/GameOver
@onready var main_menu_button: Button = $Control/GameOver/HBoxContainer/MainMenuButton
@onready var replay_button: Button = $Control/GameOver/HBoxContainer/ReplayButton


func _ready() -> void:
	Messsages.player_health_changed.connect(update_health_bar)

	game_over.visible = false
	replay_button.pressed.connect(_on_replay_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	hp_bar.min_value = 0
	hp_bar.max_value = 100

	var player: Player = get_tree().get_first_node_in_group("Player")

	if player:
		update_health_bar(player.hp, player.max_hp)
		player.coin_count_changed.connect(update_coin_counter)
		update_coin_counter(player.coins)

func update_health_bar(hp: float, max_hp: float) -> void:
	if max_hp <= 0:
		hp_bar.value = 0
		return

	hp_bar.value = (hp / max_hp) * 100


func update_coin_counter(total: int) -> void:
	coin_label.text = "Coins: " + str(total)


func show_game_over() -> void:
	main_menu_button.visible = false
	replay_button.visible = false
	game_over.modulate.a = 0
	game_over.visible = true

	var tween: Tween = create_tween()
	tween.tween_property(game_over, "modulate", Color.WHITE, 3.0)
	await tween.finished

	replay_button.visible = true
	main_menu_button.visible = true
	replay_button.grab_focus()


func clear_game_over() -> void:
	main_menu_button.visible = false
	replay_button.visible = false
	game_over.visible = false

	var player: Player = get_tree().get_first_node_in_group("Player")
	if player:
		player.queue_free()


func _on_replay_pressed() -> void:
	
	clear_game_over()


func _on_main_menu_pressed() -> void:
	
	clear_game_over()
