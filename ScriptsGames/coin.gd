class_name Coin
extends Area2D

@export var Coin_amount: int = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.add_coins(Coin_amount)
		queue_free()
