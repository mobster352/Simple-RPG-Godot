extends Node2D

@onready var initialVBox:VBoxContainer = $CanvasLayer/InitialVBox
@onready var selectionVBox:VBoxContainer = $CanvasLayer/SelectionVBox

func _on_new_game_button_pressed() -> void:
	initialVBox.hide()
	selectionVBox.show()

func _on_quit_game_button_pressed() -> void:
	get_tree().quit()
	
func _on_back_button_pressed() -> void:
	initialVBox.show()
	selectionVBox.hide()

func _on_warrior_button_pressed() -> void:
	PlayerData.initPlayer(PlayerData.PlayerTypes.WARRIOR)
	get_tree().change_scene_to_file("res://Maps/StartMap.tscn")

func _on_lancer_button_pressed() -> void:
	PlayerData.initPlayer(PlayerData.PlayerTypes.LANCER)
	get_tree().change_scene_to_file("res://Maps/StartMap.tscn")

func _on_archer_button_pressed() -> void:
	PlayerData.initPlayer(PlayerData.PlayerTypes.ARCHER)
	get_tree().change_scene_to_file("res://Maps/StartMap.tscn")
