extends Node2D

@onready var interactionLabel = $Control/InteractionLabel
@onready var npcSprite:AnimatedSprite2D = $AnimatedSprite2D

@export var configFileResource:String

var inRange:bool = false
var playerSprite:AnimatedSprite2D

class DialogueMap:
	var character:String
	var sprite:AnimatedSprite2D
	var line:String
	
var dialogueMapArray:Array
var dialogueMapIndex:int

func _ready() -> void:
	Global.increment_dialogue.connect(_on_increment_dialogue)
	var node = preload("res://Characters/Player/player.tscn").instantiate()
	playerSprite = node.get_node("Sprite") as AnimatedSprite2D
	
	var config = ConfigFile.new()
	var err = config.load(configFileResource)
	if err != OK:
		print("File did not load")
		return
	var sectionKeys = config.get_section_keys("dialogue")
	var dialogueMap = DialogueMap.new()
	for key in sectionKeys:
		var value = config.get_value("dialogue", key)
		if value == "player":
			dialogueMap.character = value
			dialogueMap.sprite = playerSprite
		elif value == "npc":
			dialogueMap.character = value
			dialogueMap.sprite = npcSprite
		else:
			dialogueMap.line = value
			dialogueMapArray.append(dialogueMap)
			dialogueMap = DialogueMap.new()
	dialogueMapIndex = 0
	

func _process(_delta: float) -> void:
	npcSprite.play("Idle")
	if inRange && Input.is_action_just_pressed("Use"):
		if dialogueMapIndex >= dialogueMapArray.size():
			Global.show_dialogue.emit("",null,null)
			dialogueMapIndex = 0
		else:
			var dMap = dialogueMapArray.get(dialogueMapIndex)
			if dMap.character == "player":
				Global.show_dialogue.emit(dialogueMapArray.get(dialogueMapIndex).line, playerSprite.sprite_frames, null)
			elif dMap.character == "npc":
				Global.show_dialogue.emit(dialogueMapArray.get(dialogueMapIndex).line, null, npcSprite.sprite_frames)
			else:
				print("no character")

func _on_area_2d_body_entered(_body: Node2D) -> void:
	interactionLabel.show()
	inRange = true


func _on_area_2d_body_exited(_body: Node2D) -> void:
	interactionLabel.hide()
	inRange = false
	
func _on_increment_dialogue(incrementBy:int):
	dialogueMapIndex += incrementBy
