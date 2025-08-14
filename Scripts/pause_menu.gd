extends CanvasLayer

func _on_resume_button_pressed() -> void:
	hide()
	get_tree().paused = false

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Maps/MainMenu.tscn")

func _on_test_map_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Maps/TestMap.tscn")

func _on_start_map_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Maps/StartMap.tscn")
