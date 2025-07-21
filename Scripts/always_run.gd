extends Node2D

@onready var ui:CanvasLayer = $CanvasLayer

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		if get_tree().paused:
			ui.hide()
			get_tree().paused = false
		else:
			ui.show()
			get_tree().paused = true
