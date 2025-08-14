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
var player:CharacterBody2D
var questStartedSpriteTexture:Texture2D
var questInProgressSpriteTexture:Texture2D
var questReadyToTurnInTexture:Texture2D

class DialogueMap:
	var character:String
	var sprite:AnimatedSprite2D
	var line:String
	
var dialogueMapArrayList:Array

func _ready() -> void:
	Global.add_quest.connect(_on_add_quest)
	dialogueMapArrayList = GlobalDialogue.init_dialogue(dialogueMapArrayList, configFileResource, sections, npcSprite)
	questStartedSpriteTexture = load("res://Resources/Raven_Fantasy_Icons/fb43.png")
	questInProgressSpriteTexture = load("res://Resources/Raven_Fantasy_Icons/fb13.png")
	questReadyToTurnInTexture = load("res://Resources/Raven_Fantasy_Icons/fb41.png")
	if questType != Global.QuestType.NONE and not PlayerData.isQuestCompleted(questId):
		questSprite.texture = questStartedSpriteTexture
		questSprite.show()
	Global.quest_ready_to_turn_in.connect(_on_quest_ready_to_turn_in)

func _process(_delta: float) -> void:
	npcSprite.play("Idle")
	if inRange && Input.is_action_just_pressed("Use"):
		if questId == 0:
			GlobalDialogue.playDialogue(dialogueMapArrayList, QuestDialog.BEFORE_QUEST)
		elif isQuestTarget:
			var isFinishedPlaying = GlobalDialogue.playDialogue(dialogueMapArrayList, QuestDialog.BEFORE_QUEST)
			var isOnQuest = false
			if player:
				if player.has_method("isOnQuest"):
					isOnQuest = player.call("isOnQuest", questId)
			if isOnQuest && isFinishedPlaying:
				if player.has_method("markQuestReadyToTurnIn"):
					player.call("markQuestReadyToTurnIn", questId)
		else:
			if PlayerData.isQuestCompleted(questId):
				GlobalDialogue.playDialogue(dialogueMapArrayList, QuestDialog.AFTER_QUEST)
			else:
				var isOnQuest = false
				if player:
					if player.has_method("isOnQuest"):
						isOnQuest = player.call("isOnQuest", questId)
				if isOnQuest:
					var isFinishedPlaying = GlobalDialogue.playDialogue(dialogueMapArrayList, QuestDialog.DURING_QUEST)
					if isFinishedPlaying:
						if player:
							if player.has_method("tryToCompleteQuest"):
								var isQuestComplete = player.call("tryToCompleteQuest", questId)
								if isQuestComplete:
									GlobalDialogue.playDialogue(dialogueMapArrayList, QuestDialog.AFTER_QUEST)
									questSprite.hide()
				else:
					var isFinishedPlaying = GlobalDialogue.playDialogue(dialogueMapArrayList, QuestDialog.BEFORE_QUEST)
					if isFinishedPlaying:
						Global.add_quest.emit(questId)

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		player = _body as CharacterBody2D
		interactionLabel.show()
		inRange = true
		GlobalDialogue.reset_dialogue()


func _on_area_2d_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		interactionLabel.hide()
		inRange = false
		Global.show_dialogue.emit("",null,null)
		GlobalDialogue.reset_dialogue()

func _on_quest_ready_to_turn_in(questId:int):
	if self.questId == questId:
		if isQuestTarget:
			questSprite.hide()
		else:
			questSprite.texture = questReadyToTurnInTexture

func _on_add_quest(questId:int):
	if self.questId == questId && isQuestTarget:
		questSprite.texture = questInProgressSpriteTexture
		questSprite.show()
	elif self.questId == questId && questType != Global.QuestType.NONE:
		questSprite.texture = null
