extends Node2D

@onready var animatedSprite = $AnimatedSprite2D

func _ready() -> void:
	animatedSprite.play("default")
