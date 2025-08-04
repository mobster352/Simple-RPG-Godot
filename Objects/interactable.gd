extends Node2D

@export var configFileResource:String
@export var sections:PackedStringArray
@export var sprite:AnimatedSprite2D
@export var deleteAfterRead:bool

@onready var interactionLabel = $Control/InteractionLabel

var dialogueArray:Array
var inRange:bool

func _ready() -> void:
	dialogueArray = GlobalDialogue.init_dialogue(dialogueArray, configFileResource, sections, sprite)

func _process(delta: float) -> void:
	if inRange && Input.is_action_just_pressed("Use"):
		var isFinished = GlobalDialogue.playDialogue(dialogueArray, 0)
		if isFinished && deleteAfterRead:
			queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		#player = _body as CharacterBody2D - idk if I need this
		interactionLabel.show()
		inRange = true
		GlobalDialogue.reset_dialogue()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		interactionLabel.hide()
		inRange = false
		Global.show_dialogue.emit("",null,null)
		GlobalDialogue.reset_dialogue()
