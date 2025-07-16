extends Node2D

@onready var collision = $StaticBody2D/CollisionShape2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("heal"):
			body.call("heal", 50)
			queue_free()
