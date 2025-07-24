extends CharacterBody2D

class Player:
	pass
# Character Data (may make this a class)
var level = 1
var maxHP = 10
var currentHP = maxHP
var currentExp = 0
var stamina = 100
var weapon = Vector2(7,13)

@export var speed = 100

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var attackHitbox = $Area2D/AttackHitbox
@onready var hitbox = $HitboxArea/Hitbox
@onready var healthBar = $CanvasLayer/HealthBar
@onready var deathControl = $CanvasLayer/DeathControl
@onready var expBar = $CanvasLayer/ExpBar
@onready var flyingTextNode = $FlyingTextNode
@onready var staminaBar = $Control/StaminaBar
@onready var levelLabel = $CanvasLayer/ExpBar/LevelLabel
@onready var levelUpLabel = $Control/StaminaBar/LevelUpLabel
@onready var healthLabel = $CanvasLayer/HealthBar/HealthLabel
@onready var questLogControl = $CanvasLayer/QuestLog
@onready var questsVBox = $CanvasLayer/QuestLog/MarginContainer/Quests
@onready var inventory = $CanvasLayer/Inventory

var isAttacking = false
var startGlobalPosition:Vector2
var canMove:bool = true

class ExpLevel:
	var level:int
	var expNextLevel:int

var expArray:Array
var currentExpLevel:ExpLevel

class QuestLog:
	var questId:int
	var questName:String
	var questType: int
	
var showQuestLog = false

func _ready() -> void:
	startGlobalPosition = global_position
	var levelIndex = 1
	while levelIndex < 99:
		var xp = ExpLevel.new()
		xp.level = levelIndex
		xp.expNextLevel = floor(100 * pow(levelIndex, 1.5))
		expArray.append(xp)
		levelIndex += 1
	currentExpLevel = expArray.get(0)
	expBar.max_value = currentExpLevel.expNextLevel
	expBar.value = 0
	Global.show_dialogue.connect(_on_show_dialogue)
	Global.add_quest.connect(_on_add_quest)
	Global.heal.connect(_on_heal)

func _process(delta: float) -> void:
	playAnimations()
	if stamina < 100:
		staminaBar.show()
		stamina += 1 * 10 * delta
	else:
		staminaBar.hide()
	healthLabel.text = str(currentHP, " / ", maxHP)
	healthBar.value = currentHP
	staminaBar.value = stamina
	levelLabel.text = str("Lv ", level)
	
	if Input.is_action_just_pressed("QuestLog"):
		if showQuestLog:
			questLogControl.hide()
			showQuestLog = false
		else:
			questLogControl.show()
			showQuestLog = true
	if Input.is_action_just_pressed("Inventory"):
		if inventory.visible:
			inventory.hide()
		else:
			inventory.show()
	
func _physics_process(_delta: float) -> void:
	if visible && canMove:
		movePlayer()

func movePlayer():
	if isAttacking:
		return	
	var input_vector = Vector2(
		Input.get_action_strength("MoveRight") - Input.get_action_strength("MoveLeft"),
		Input.get_action_strength("MoveDown") - Input.get_action_strength("MoveUp")
	).normalized()
	velocity = input_vector * speed
	if input_vector.x != 0:
		sprite.flip_h = input_vector.x < 0
		var should_be_positive = input_vector.x > 0
		if (should_be_positive and attackHitbox.position.x < 0) or (not should_be_positive and attackHitbox.position.x > 0):
			attackHitbox.position.x *= -1
	move_and_slide()
	
func playAnimations():
	if isAttacking:
		return
	if velocity == Vector2.ZERO:
		sprite.play("Idle")
	else:
		sprite.play("Walk")
	if Input.is_action_just_pressed("Attack") && stamina >= 25 && canMove:
		isAttacking = true
		attackHitbox.disabled = false
		sprite.play("Attack")
		stamina -= 25
		
func damage(dmg:int):
	currentHP -= dmg
	Global.makeFlyingTextLabel(global_position, str(dmg), Color.RED, Global.LABEL_SIZE_BIG)
	if currentHP <= 0:
		print("You Died")
		deathControl.show()
		hide()
		hitbox.disabled = true
		
func heal(hp:int):
	if currentHP + hp <= maxHP:
		currentHP += hp
	else:
		currentHP = maxHP
	Global.makeFlyingTextLabel(global_position, str("+", hp), Color.GREEN, Global.LABEL_SIZE_MEDIUM)
		
func refreshCurrentExpFromPlayerLevel():
	for xp in expArray:
		if xp.level == level:
			currentExpLevel = xp
			return
		
func levelUp():
	if level < 100:
		level += 1
		refreshCurrentExpFromPlayerLevel()
		var hp = healthBar.getHpFromPlayerLevel(level)
		maxHP = hp.maxValue
		currentHP = maxHP
		print("Level Up: ", level)
		#print("XP Next Level: ", currentExpLevel.expNextLevel)
		levelUpLabel.show()
		var timer = Timer.new()
		timer.wait_time = 2
		timer.connect("timeout", _on_level_up_timer_timeout.bind(timer))
		add_child(timer)
		timer.start()
		
func _on_level_up_timer_timeout(timer:Timer):
	levelUpLabel.hide()
	timer.queue_free()
		
func calculateExp(expToGain:int):
	#print("Gained ", expToGain, " XP")
	var newExp = currentExp + expToGain
	if newExp >= currentExpLevel.expNextLevel:
		levelUp()
		currentExp = newExp - currentExp
		expBar.max_value = currentExpLevel.expNextLevel
	else:
		currentExp = newExp
	expBar.value = currentExp

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "Attack":
		isAttacking = false
		attackHitbox.disabled = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("damage"):
			body.call("damage", randi_range(weapon.x, weapon.y))

func _on_respawn_button_pressed() -> void:
	global_position = startGlobalPosition
	currentHP = maxHP
	show()
	hitbox.disabled = false
	deathControl.hide()
	#get_tree().reload_current_scene()
	
func _on_show_dialogue(text:String, left:SpriteFrames, right:SpriteFrames):
	if text == "":
		canMove = true
	else:
		canMove = false
		
func _on_add_quest(questId:int):
	var quest = questLogControl.findQuest(questId)
	var questLabelName = RichTextLabel.new()
	questLabelName.bbcode_enabled = true
	questLabelName.set_meta("questId", quest.questId)
	questLabelName.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	questLabelName.set_anchors_preset(Control.PRESET_FULL_RECT)
	questLabelName.fit_content = true
	if quest.questType == Global.QuestType.KILL:
		questLabelName.text = str("[font_size=18][color=bisque][outline_size=5][outline_color=black]",quest.questName, "[/outline_color][/outline_size][/color][/font_size]", "\n")
		questLabelName.text += str("[outline_size=5]", quest.questDesc, " ", quest.numCompleted, "/", quest.numRequired, "[/outline_size]")
	elif quest.questType == Global.QuestType.TALK:
		questLabelName.text = str("[font_size=18][color=bisque][outline_size=5][outline_color=black]",quest.questName, "[/outline_color][/outline_size][/color][/font_size]", "\n")
		questLabelName.text += str("[outline_size=5]", quest.questDesc, "[/outline_size]")
	questsVBox.add_child(questLabelName)
	questLogControl.activeQuests.append(quest)

func isOnQuest(questId:int):
	if questLogControl.isQuestActive(questId):
		return true
	return false
	
func isQuestReadyToComplete(questId:int):
	if questLogControl.isQuestReadyToComplete(questId):
		return true
	return false
	
func incrementQuestNum(questId:int):
	var quest = questLogControl.findQuest(questId)
	if quest.numCompleted < quest.numRequired:
		quest.numCompleted += 1
	if quest.numCompleted >= quest.numRequired:
		markQuestReadyToTurnIn(questId)
	drawQuest(questId, quest.readyToBeTurnedIn)
		
func drawQuest(questId:int, readyToBeTurnedIn:bool):
	var quest = questLogControl.findQuest(questId)
	var questNode = getQuestNodeByQuestId(questId) as RichTextLabel
	if questNode != null:
		if quest.questType == Global.QuestType.KILL:
			if readyToBeTurnedIn:
				questNode.text = str("[font_size=18][color=green][outline_size=5][outline_color=black]",quest.questName, "[/outline_color][/outline_size][/color][/font_size]", "\n")
			else:
				questNode.text = str("[font_size=18][color=bisque][outline_size=5][outline_color=black]",quest.questName, "[/outline_color][/outline_size][/color][/font_size]", "\n")
			questNode.text += str("[outline_size=5]", quest.questDesc, " ", quest.numCompleted, "/", quest.numRequired, "[/outline_size]")
		elif quest.questType == Global.QuestType.TALK:
			if readyToBeTurnedIn:
				questNode.text = str("[font_size=18][color=green][outline_size=5][outline_color=black]",quest.questName, "[/outline_color][/outline_size][/color][/font_size]", "\n")
			else:
				questNode.text = str("[font_size=18][color=bisque][outline_size=5][outline_color=black]",quest.questName, "[/outline_color][/outline_size][/color][/font_size]", "\n")
			questNode.text += str("[outline_size=5]", quest.questDesc, "[/outline_size]")

func getQuestNodeByQuestId(questId:int):
	for node in questsVBox.get_children():
		if node.has_meta("questId"):
			if node.get_meta("questId") == questId:
				return node
	return null

func tryToCompleteQuest(questId:int):
	var readyToComplete = questLogControl.isQuestReadyToComplete(questId)
	if readyToComplete:
		var questNode = getQuestNodeByQuestId(questId)
		if questNode:
			questNode.queue_free()
		var removedQuest = questLogControl.removeFromActiveQuests(questId)
		questLogControl.completedQuests.append(removedQuest)
		calculateExp(removedQuest.expReward)
		Global.makeFlyingTextLabel(global_position, str(removedQuest.expReward," XP"), Color.MEDIUM_PURPLE, Global.LABEL_SIZE_MEDIUM)
		return true
	return false
	
func markQuestReadyToTurnIn(questId:int):
	var quest = questLogControl.findQuest(questId)
	quest.readyToBeTurnedIn = true
	drawQuest(questId, quest.readyToBeTurnedIn)
	Global.quest_ready_to_turn_in.emit(questId)

func _on_heal(hp:int):
	heal(hp)
