extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("heal"):
			Global.item_pickup.emit(get_meta("itemId"))
			#body.call("heal", 10)
			queue_free()
