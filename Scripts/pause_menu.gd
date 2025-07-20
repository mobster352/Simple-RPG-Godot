extends CanvasLayer

func _on_resume_button_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Maps/MainMenu.tscn")
