extends CharacterBody2D

class Player:
	pass
# Character Data (may make this a class)
var level:int = 1
var maxHP:int = 10
var currentHP:int = maxHP
var currentExp:int = 0
var stamina:float = 100
var playerId:int
var weapon:Vector2
var sprite: AnimatedSprite2D

@export var speed = 100
@export var staminaDrain = 25

var attackHitbox:CollisionShape2D
var hitbox:CollisionShape2D
@onready var healthBar = $CanvasLayer/UI/HealthBar
@onready var deathControl = $CanvasLayer/DeathControl
@onready var expBar = $CanvasLayer/UI/ExpBar
@onready var flyingTextNode = $FlyingTextNode
@onready var staminaBar = $Control/StaminaBar
@onready var levelLabel = $CanvasLayer/UI/ExpBar/LevelLabel
@onready var levelUpLabel = $Control/StaminaBar/LevelUpLabel
@onready var healthLabel = $CanvasLayer/UI/HealthBar/HealthLabel
@onready var questLogControl = $CanvasLayer/QuestLog
@onready var questsVBox = $CanvasLayer/QuestLog/MarginContainer/Quests
@onready var inventory = $CanvasLayer/Inventory
@onready var attackArc = $AttackArc
@onready var hotbarSlot3 = $CanvasLayer/UI/Hotbar/GridContainer/Slot3

var canAttack:bool = true
var isAttacking = false
var startGlobalPosition:Vector2
var canMove:bool = true
var canBlock:bool = false
var blockTimer:float = 0.0
var isBlocking = false
var knockback = Vector2.ZERO
var knockback_strength = 500.0
var p0
var p1
var p2

class ExpLevel:
	var level:int
	var expNextLevel:int

var expArray:Array
var currentExpLevel:ExpLevel

var showQuestLog = false
var potionsCount = 0

var mousePosForArrow:Vector2

func _ready() -> void:
	playerId = Global.playerId
	weapon = Global.playerWeapon
	sprite = Global.playerSprite
	
	add_child(sprite)
	hitbox = sprite.get_node("HitboxArea/Hitbox")
	sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)
	sprite.frame_changed.connect(_on_animated_sprite_2d_frame_changed)
	var area2D = sprite.get_node("Area2D") as Area2D
	if area2D:
		attackHitbox = sprite.get_node("Area2D/AttackHitbox")
		area2D.connect("body_entered", _on_area_2d_body_entered)
	startGlobalPosition = global_position
	var levelIndex = 1
	while levelIndex < 99:
		var xp = ExpLevel.new()
		xp.level = levelIndex
		xp.expNextLevel = floor(100 * pow(levelIndex, 1.5))
		expArray.append(xp)
		levelIndex += 1
	currentExpLevel = getExpLevel(level)
	expBar.max_value = currentExpLevel.expNextLevel
	expBar.value = 0
	
	if playerId == Global.PlayerTypes.ARCHER:
		var slot3Tex = hotbarSlot3.get_child(1) as TextureRect
		slot3Tex.texture = null
		var slot3Lab = hotbarSlot3.get_child(2) as Label
		slot3Lab.text = ""
	
	
	Global.show_dialogue.connect(_on_show_dialogue)
	Global.add_quest.connect(_on_add_quest)
	Global.heal.connect(_on_heal)
	Global.add_potion.connect(_on_add_potion)
	Global.toggle_player_attack.connect(_on_toggle_player_attack)

func _process(delta: float) -> void:
	if blockTimer > 0:
		blockTimer -= delta
	else:
		if playerId == Global.PlayerTypes.WARRIOR || playerId == Global.PlayerTypes.LANCER:
			canBlock = true
		playAnimations()
	if stamina < 100:
		staminaBar.show()
		if !isBlocking:
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
	if Input.is_action_just_pressed("Heal"):
		usePotion()
	#if playerId == Global.PlayerTypes.ARCHER && Input.is_action_pressed("Block"):
		#drawAttackArc()
		#if get_local_mouse_position().x < 0:
			#sprite.flip_h = true
		#else:
			#sprite.flip_h = false
	#if playerId == Global.PlayerTypes.ARCHER && Input.is_action_just_released("Block"):
		#attackArc.clear_points()
	if questLogControl.isQuestActive(3) && !questLogControl.isQuestReadyToComplete(3):
		hasItemForQuest(3)
	
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
	velocity = input_vector * speed + knockback
	if input_vector.x != 0:
		sprite.flip_h = input_vector.x < 0
		var should_be_positive = input_vector.x > 0
		if (should_be_positive and attackHitbox.position.x < 0) or (not should_be_positive and attackHitbox.position.x > 0):
			attackHitbox.position.x *= -1
	move_and_slide()
	knockback = knockback.lerp(Vector2.ZERO, 0.1)
	if knockback.distance_to(Vector2.ZERO) < 100.0:
		knockback = Vector2.ZERO
	
func playAnimations():
	if isAttacking:
		return
	if Input.is_action_just_pressed("Attack") && stamina >= staminaDrain && canMove && canAttack:
		isAttacking = true
		attackHitbox.disabled = false
		sprite.play("Attack")
		mousePosForArrow = get_local_mouse_position()
		stamina -= staminaDrain
		if global_position.x - get_global_mouse_position().x > 0:
			sprite.flip_h = true
			if attackHitbox.position.x > 0:
				attackHitbox.position.x *= -1
		else:
			sprite.flip_h = false
			if attackHitbox.position.x < 0:
				attackHitbox.position.x *= -1
	elif isBlocking && stamina < staminaDrain:
		isBlocking = false
		canMove = true
		canBlock = true
		sprite.play("Idle")
	elif Input.is_action_pressed("Block") && stamina >= staminaDrain && canBlock:
		isBlocking = true
		canMove = false
		sprite.play("Block")
		if global_position.x - get_global_mouse_position().x > 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
	elif Input.is_action_just_released("Block") && (playerId == Global.PlayerTypes.WARRIOR || playerId == Global.PlayerTypes.LANCER):
		isBlocking = false
		canMove = true
		canBlock = true
	elif velocity != Vector2.ZERO:
		sprite.play("Walk")
	else:
		sprite.play("Idle")
	
func damage(dmg:int, enemyPos:Vector2):
	if ((global_position.direction_to(enemyPos).x > 0 && global_position.direction_to(get_global_mouse_position()).x > 0) || (global_position.direction_to(enemyPos).x < 0 && global_position.direction_to(get_global_mouse_position()).x < 0)) && isBlocking && stamina >= staminaDrain:
		stamina -= staminaDrain
		return
	if isBlocking:
		isBlocking = false
		canMove = true
		canBlock = false
		blockTimer = 0.5
		sprite.play("Idle")
	
	var direction = enemyPos.direction_to(global_position)
	var force = direction * knockback_strength
	knockback = force
	
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
			
func _on_animated_sprite_2d_frame_changed():
	if sprite.animation == "Attack" && sprite.get_frame() == 5 && playerId == Global.PlayerTypes.ARCHER:
		var arrow = preload("res://Characters/Player/arrow.tscn").instantiate()
		get_parent().add_child(arrow)
		arrow.globalPosition = global_position
		arrow.setReady(sprite.flip_h, weapon, mousePosForArrow)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if playerId == Global.PlayerTypes.WARRIOR || playerId == Global.PlayerTypes.LANCER:
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
	velocity = Vector2.ZERO
		
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
	else:
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
		else:
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
		var quest = questLogControl.completeQuest(questId)
		if quest.questType == Global.QuestType.FIND_ITEM:
			inventory.removeItemInInventory(quest.itemId)
		calculateExp(quest.expReward)
		Global.makeFlyingTextLabel(global_position, str(quest.expReward," XP"), Color.MEDIUM_PURPLE, Global.LABEL_SIZE_MEDIUM)
		return true
	return false
	
func markQuestReadyToTurnIn(questId:int):
	var quest = questLogControl.findQuest(questId)
	quest.readyToBeTurnedIn = true
	drawQuest(questId, quest.readyToBeTurnedIn)
	Global.quest_ready_to_turn_in.emit(questId)

func _on_heal(hp:int):
	heal(hp)

func _on_add_potion():
	potionsCount += 1
	
func usePotion():
	if potionsCount > 0:
		Global.heal.emit(10)
		potionsCount -= 1
		
func getPotionCount():
	return potionsCount

func _on_toggle_player_attack(toggle:bool):
	canAttack = toggle
	
func hasItemForQuest(questId:int):
	var quest = questLogControl.findActiveQuest(questId)
	if quest:
		var item = inventory.findItemInInventory(quest.itemId)
		if item:
			markQuestReadyToTurnIn(questId)
	
#func drawAttackArc():
	#var min = Vector2(-300, -300)
	#var max = Vector2(300, 300)
	#var mousePos = get_local_mouse_position()
	#var arrow_global_position = to_local(global_position)
	#
	#p0 = arrow_global_position
	#p0 = p0.clamp(min, max)
	#
	#p1 = arrow_global_position + mousePos - Vector2(0,(arrow_global_position + mousePos).y / 2)
	#p1 = p1.clamp(min, max)
	#
	#p2 = arrow_global_position + mousePos
	#p2 = p2.clamp(min, max)
	#
	#attackArc.clear_points()
	#attackArc.add_point(p0)
	#attackArc.add_point(p1)
	#attackArc.add_point(p2)
	
func getExpLevel(level:int):
	for expLevel in expArray:
		if expLevel.level == level:
			return expLevel
