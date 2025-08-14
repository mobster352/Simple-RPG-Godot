extends Node2D

@onready var pauseMenu:CanvasLayer = $PauseMenu

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		if get_tree().paused:
			pauseMenu.hide()
			get_tree().paused = false
		else:
			pauseMenu.show()
			get_tree().paused = true
