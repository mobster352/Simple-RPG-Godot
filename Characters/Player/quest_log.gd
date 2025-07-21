extends Control

class Quest:
	var questId:int
	var questName:String
	var questType:int
	var expReward:int
	var numRequired:int
	var numCompleted:int
	var readyToBeTurnedIn:bool
	var questComplete:bool
	
var allQuests:Array
var activeQuests:Array
var completedQuests:Array

func _ready() -> void:
	var config = ConfigFile.new()
	var err = config.load("res://Files/quest_database.cfg")
	if err != OK:
		print("Quest Database not loaded")
		return
	var quests = config.get_sections()
	for q in quests:
		var quest = Quest.new()
		var keys = config.get_section_keys(q)
		quest.questId = config.get_value(q, keys.get(keys.find("id")))
		quest.questName = config.get_value(q, keys.get(keys.find("name")))
		quest.questType = config.get_value(q, keys.get(keys.find("type")))
		quest.expReward = config.get_value(q, keys.get(keys.find("exp_reward")))
		if quest.questType == Global.QuestType.KILL:
			quest.numRequired = config.get_value(q, keys.get(keys.find("num_required")))
		quest.numCompleted = 0
		quest.readyToBeTurnedIn = false
		quest.questComplete = false
		allQuests.append(quest)

func findQuest(questId:int):
	for quest in allQuests:
		if quest.questId == questId:
			return quest
			
func findActiveQuest(questId:int):
	for quest in activeQuests:
		if quest.questId == questId:
			return quest
			
func isQuestActive(questId:int):
	for quest in activeQuests:
		if quest.questId == questId:
			return true
	return false

func isQuestCompleted(questId:int):
	for quest in completedQuests:
		if quest.questId == questId:
			return true
	return false
	
func isQuestReadyToComplete(questId:int):
	var quest = findActiveQuest(questId)
	if quest:
		if quest.readyToBeTurnedIn:
			return true
	return false
	
func removeFromActiveQuests(questId:int):
	var index = 0
	for quest in activeQuests:
		if quest.questId == questId:
			activeQuests.remove_at(index)
			return quest
		index += 1
	return null
