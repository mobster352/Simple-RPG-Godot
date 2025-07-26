extends Control

@export var player:Node2D

@onready var potionsValue = $GridContainer/Slot1/Value

func _ready() -> void:
	potionsValue.text = str(0)
	Global.heal.connect(_on_heal)
	
func _on_heal(hp:int):
	if player.has_method("getPotionCount"):
		potionsValue.text = str(player.call("getPotionCount"))
		
func _process(delta: float) -> void:
	if player.has_method("getPotionCount"):
		potionsValue.text = str(player.call("getPotionCount"))
