extends Node

var dialogueIndex:int

class Dialogue:
	var character:String
	var animatedSprite:AnimatedSprite2D
	var line:String
	
func _ready() -> void:
	Global.increment_dialogue.connect(_on_increment_dialogue)
	
func init_dialogue(dialogueArrayList:Array, configFileResource:String, sections:PackedStringArray, animatedSprite:AnimatedSprite2D) -> Array:
	var config = ConfigFile.new()
	var err = config.load(configFileResource)
	if err != OK:
		print("File did not load")
		return []
		
	for section in sections:
		var sectionKeys = config.get_section_keys(section)
		var dialogueArray:Array
		var dialogue = Dialogue.new()
		for key in sectionKeys:
			var value = config.get_value(section, key)
			if value == "player":
				dialogue.character = value
				dialogue.animatedSprite = PlayerData.sprite
			elif value == "other":
				dialogue.character = value
				dialogue.animatedSprite = animatedSprite
			else:
				dialogue.line = value
				dialogueArray.append(dialogue)
				dialogue = Dialogue.new()
		dialogueArrayList.append(dialogueArray)
	dialogueIndex = 0
	return dialogueArrayList

## Returns [code]true[/code] when the dialog has finished playing, [code]false[/code] otherwise.
## [br][br]
## [param sectionIndex] decides which dialogue array to play. -uses enum
func playDialogue(dialogueArrayList:Array, sectionIndex:int):
	if dialogueIndex >= dialogueArrayList.get(sectionIndex).size():
		Global.show_dialogue.emit("",null,null)
		dialogueIndex = 0
		return true # true when done
	else:
		var dialogue = dialogueArrayList.get(sectionIndex).get(dialogueIndex)
		if dialogue.character == "player":
			Global.show_dialogue.emit(dialogue.line, dialogue.animatedSprite.sprite_frames, null)
		elif dialogue.character == "other":
			if dialogueArrayList.get(sectionIndex).get(dialogueIndex).animatedSprite:
				Global.show_dialogue.emit(dialogue.line, null, dialogue.animatedSprite.sprite_frames)
			else:
				Global.show_dialogue.emit(dialogue.line, null, null)
		else:
			print("no character")
		return false #false when not done

func _on_increment_dialogue(incrementBy:int):
	dialogueIndex += incrementBy
	
func reset_dialogue():
	dialogueIndex = 0
