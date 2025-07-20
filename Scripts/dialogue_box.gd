extends Node2D

@onready var canvasLayer = $CanvasLayer
@onready var dialogue:Label = $CanvasLayer/Background/Dialogue
@onready var leftSprite:AnimatedSprite2D = $CanvasLayer/MarginContainer/LeftSprite
@onready var rightSprite:AnimatedSprite2D = $CanvasLayer/MarginContainer/RightSprite

var tween

func _ready() -> void:
	Global.show_dialogue.connect(_on_show_dialogue)
	dialogue.visible_characters = 0
	dialogue.visible_ratio = 0

func _on_show_dialogue(text:String, left:SpriteFrames, right:SpriteFrames):
	leftSprite.sprite_frames = null
	rightSprite.sprite_frames = null
	if left:
		leftSprite.sprite_frames = left
		if leftSprite.sprite_frames.has_animation("Idle"):
			leftSprite.play("Idle")
	if right:
		rightSprite.sprite_frames = right
		if rightSprite.sprite_frames.has_animation("Idle"):
			rightSprite.play("Idle")
	if text == "":
		canvasLayer.hide()
	else:
		dialogue.text = text
		canvasLayer.show()
		if dialogue.visible_ratio > 0 && dialogue.visible_ratio < 1:
			dialogue.visible_characters = -1
			dialogue.visible_ratio = 1
			Global.increment_dialogue.emit(1)
			if tween:
				tween.kill()
		else:
			dialogue.visible_characters = 0
			dialogue.visible_ratio = 0
			if tween:
				tween.kill()
			tween = create_tween()
			var characters_per_second = 25.0
			var text_length = dialogue.text.length()
			var tween_duration = text_length / characters_per_second
			tween.tween_property(dialogue, "visible_ratio", 1.0, tween_duration)
			tween.finished.connect(_on_tween_finished)
			
func _on_tween_finished():
	Global.increment_dialogue.emit(1)
