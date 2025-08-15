extends Area2D

@export var spawnPosition:Vector2
@export var map:String

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.spawnPosition = spawnPosition
		get_tree().change_scene_to_file.call_deferred(map)
