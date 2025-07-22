extends Node2D

@onready var interactionLabel = $Control/InteractionLabel
@onready var npcSprite:AnimatedSprite2D = $AnimatedSprite2D
@onready var questSprite:Sprite2D = $QuestSprite

@export var configFileResource:String
# 0 - dialogue before quest
# 1 - dialogue after quest started
# 2 - dialogue after quest completed
@export var sections:PackedStringArray 
@export var questId:int
@export var questType:Global.QuestType
@export var isQuestTarget:bool

## See [enum QuestDialog]
## [br][br]
## 0 - [code]BEFORE_QUEST[/code] ; 
## 1 - [code]DURING_QUEST[/code] ; 
## 2 - [code]AFTER_QUEST[/code]
enum QuestDialog {
	BEFORE_QUEST,
	DURING_QUEST,
	AFTER_QUEST
}

var inRange:bool = false
var playerSprite:AnimatedSprite2D
var player:CharacterBody2D
var questStartedSpriteTexture:Texture2D
var questInProgressSpriteTexture:Texture2D
var questReadyToTurnInTexture:Texture2D

class DialogueMap:
	var character:String
	var sprite:AnimatedSprite2D
	var line:String
	
var dialogueMapArrayList:Array
var dialogueMapIndex:int

var isQuestComplete:bool = false

func _ready() -> void:
	Global.increment_dialogue.connect(_on_increment_dialogue)
	var node = preload("res://Characters/Player/player.tscn").instantiate()
	playerSprite = node.get_node("Sprite") as AnimatedSprite2D
	
	var config = ConfigFile.new()
	var err = config.load(configFileResource)
	if err != OK:
		print("File did not load")
		return
		
	for section in sections:
		var sectionKeys = config.get_section_keys(section)
		var dialogueMapArray:Array
		var dialogueMap = DialogueMap.new()
		for key in sectionKeys:
			var value = config.get_value(section, key)
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
		dialogueMapArrayList.append(dialogueMapArray)
	dialogueMapIndex = 0
	questStartedSpriteTexture = load("res://Resources/Raven_Fantasy_Icons/fb43.png")
	questInProgressSpriteTexture = load("res://Resources/Raven_Fantasy_Icons/fb13.png")
	questReadyToTurnInTexture = load("res://Resources/Raven_Fantasy_Icons/fb41.png")
	if questType != Global.QuestType.NONE:
		questSprite.texture = questStartedSpriteTexture
		questSprite.show()
	Global.quest_ready_to_turn_in.connect(_on_quest_ready_to_turn_in)

func _process(_delta: float) -> void:
	npcSprite.play("Idle")
	if inRange && Input.is_action_just_pressed("Use"):
		if questId == 0:
			playDialogue(QuestDialog.BEFORE_QUEST)
		elif isQuestTarget:
			var isFinishedPlaying = playDialogue(QuestDialog.BEFORE_QUEST)
			var isOnQuest = false
			if player:
				if player.has_method("isOnQuest"):
					isOnQuest = player.call("isOnQuest", questId)
			if isOnQuest && isFinishedPlaying:
				if player.has_method("markQuestReadyToTurnIn"):
					player.call("markQuestReadyToTurnIn", questId)
					Global.quest_ready_to_turn_in.emit(questId)
		else:
			if isQuestComplete:
				playDialogue(QuestDialog.AFTER_QUEST)
			else:
				var isOnQuest = false
				if player:
					if player.has_method("isOnQuest"):
						isOnQuest = player.call("isOnQuest", questId)
				if isOnQuest:
					var isFinishedPlaying = playDialogue(QuestDialog.DURING_QUEST)
					if isFinishedPlaying:
						if player:
							if player.has_method("tryToCompleteQuest"):
								isQuestComplete = player.call("tryToCompleteQuest", questId)
								if isQuestComplete:
									playDialogue(QuestDialog.AFTER_QUEST)
									questSprite.hide()
				else:
					var isFinishedPlaying = playDialogue(QuestDialog.BEFORE_QUEST)
					if isFinishedPlaying:
						Global.add_quest.emit(questId)
						if questType != Global.QuestType.NONE:
							if questSprite.texture != questInProgressSpriteTexture:
								questSprite.texture = questInProgressSpriteTexture

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		player = _body as CharacterBody2D
		interactionLabel.show()
		inRange = true
		dialogueMapIndex = 0


func _on_area_2d_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		interactionLabel.hide()
		inRange = false
		Global.show_dialogue.emit("",null,null)
		dialogueMapIndex = 0
	
func _on_increment_dialogue(incrementBy:int):
	dialogueMapIndex += incrementBy
	
## Returns [code]true[/code] when the dialog has finished playing, [code]false[/code] otherwise.
## [br][br]
## [param arrayListIndex] decides which dialogue array to play.
func playDialogue(arrayListIndex:int):
	if dialogueMapIndex >= dialogueMapArrayList.get(arrayListIndex).size():
		Global.show_dialogue.emit("",null,null)
		dialogueMapIndex = 0
		return true # true when done
	else:
		var dMap = dialogueMapArrayList.get(arrayListIndex).get(dialogueMapIndex)
		if dMap.character == "player":
			Global.show_dialogue.emit(dialogueMapArrayList.get(arrayListIndex).get(dialogueMapIndex).line, playerSprite.sprite_frames, null)
		elif dMap.character == "npc":
			Global.show_dialogue.emit(dialogueMapArrayList.get(arrayListIndex).get(dialogueMapIndex).line, null, npcSprite.sprite_frames)
		else:
			print("no character")
		return false #false when not done

func _on_quest_ready_to_turn_in(questId:int):
	if self.questId == questId:
		questSprite.texture = questReadyToTurnInTexture
