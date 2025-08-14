extends Node

var level:int
var maxHP:int
var currentHP:int
var currentExp:int
var stamina:float
var playerId:int
var weapon:Vector2
var spritePath: String
var potionsCount:int
var inventory:Array
var activeQuests:Array
var completedQuests:Array

enum PlayerTypes {
	NONE,
	WARRIOR,
	LANCER,
	ARCHER
}

func initPlayer(playerId:int):
	self.playerId = playerId
	if playerId == PlayerTypes.WARRIOR:
		spritePath = "res://Characters/Player/warrior_sprite.tscn"
		weapon = Vector2(7,13)
	elif playerId == PlayerTypes.LANCER:
		spritePath = "res://Characters/Player/lancer_sprite.tscn"
		weapon = Vector2(5,10)
	elif playerId == PlayerTypes.ARCHER:
		spritePath = "res://Characters/Player/archer_sprite.tscn"
		weapon = Vector2(10,15)
	else:
		spritePath = "res://Characters/Player/warrior_sprite.tscn"
		weapon = Vector2(7,13)
	level = 1
	maxHP = 10
	currentHP = maxHP
	currentExp = 0
	stamina = 100
	potionsCount = 0
	inventory = [
				null, null, null,
				null, null, null,
				null, null, null
				]
	activeQuests = []
	completedQuests = []

func isQuestCompleted(questId:int):
	for quest in completedQuests:
		if quest.questId == questId:
			return true
	return false
