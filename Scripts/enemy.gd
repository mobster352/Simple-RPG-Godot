extends CharacterBody2D

@export var enemyScenePath:String
var enemyNode:Node2D
var sprite:AnimatedSprite2D
@onready var hitbox:CollisionShape2D = $Hitbox
var attackHitbox:CollisionShape2D
var enemyType:int

@onready var attackTimer:Timer = $AttackTimer
@onready var healthBar:ProgressBar = $Control/HealthBar
@onready var flyingTextNode = $FlyingTextNode
@onready var navAgent:NavigationAgent2D = $NavigationAgent2D
@onready var questSprite:Sprite2D = $QuestSprite
@onready var isAttackedTimer:Timer = $IsAttackedTimer

enum states {
	IDLE,
	CHASE,
	ATTACK,
	RESET
}

@export var maxHp:int = 30
var hp:int
@export var speed:int = 120
@export var chaseDistance:int = 25
@export var attackDamage:int = 4
@export var attackSpeed:float = 3.0
@export var loot:PackedScene

var startGlobalPosition:Vector2
var startPosition:Vector2
var canAttack:bool
var atPlayer:bool
var canMove:bool
var inAttackRange:bool
var inRange:bool
var lootNode:Node
var state = states.IDLE

@export var player:CharacterBody2D

const MOVEMENT_OFFSET:int = 50
const PLAYER_X_ALIGNMENT:float = 0.5
const RESET_DISTANCE:float = 1000
const EXP_RECEIVED:int = 15

var questIds:PackedInt32Array
var questTargetTexture:Texture2D

var isAwareOfPlayer:bool = false

func _ready() -> void:
	enemyNode = load(enemyScenePath).instantiate()
	sprite = enemyNode.get_node("Sprite")
	sprite.connect("animation_finished", _on_sprite_animation_finished)
	sprite.connect("frame_changed", _on_sprite_frame_changed)
	
	var attackArea = enemyNode.get_node("AttackArea") as Area2D
	attackHitbox = attackArea.get_node("AttackHitbox")
	attackArea.connect("body_entered", _on_attack_area_body_entered)
	attackArea.connect("body_exited", _on_attack_area_body_exited)
	
	var sightArea = enemyNode.get_node("SightArea") as Area2D
	sightArea.connect("body_entered", _on_sight_area_body_entered)
	sightArea.connect("body_exited", _on_sight_area_body_exited)
	
	add_child(enemyNode)
	questIds = enemyNode.get_meta("questIds", [0])
	
	if enemyNode.name == "RedWarrior":
		enemyType = Global.EnemyTypes.RedWarrior
	elif enemyNode.name == "Skull":
		enemyType = Global.EnemyTypes.Skull
	elif enemyNode.name == "Snake":
		enemyType = Global.EnemyTypes.Snake
	
	startGlobalPosition = global_position
	startPosition = position
	hp = maxHp
	healthBar.max_value = maxHp
	canAttack = true
	canMove = false
	inAttackRange = false
	lootNode = loot.instantiate()
	questTargetTexture = load("res://Resources/Raven_Fantasy_Icons/fb12.png")
	Global.add_quest.connect(_on_add_quest)
	Global.quest_ready_to_turn_in.connect(_on_quest_ready_to_turn_in)
	
func _process(_delta: float) -> void:
	playAnimation()
	healthBar.value = hp
	if hp < maxHp:
		healthBar.show()
	for questId in questIds:
		checkQuestTarget(questId)
	
func _physics_process(delta: float) -> void:
	move(delta)

func playAnimation():
	if state == states.IDLE:
		sprite.play("Idle")
	elif state == states.CHASE:
		sprite.play("Walk")
	elif state == states.ATTACK:
		sprite.play("Attack")
	elif state == states.RESET:
		sprite.play("Walk")
	else:
		sprite.play("Idle")
	
func move(delta: float):
	if global_position.distance_to(startGlobalPosition) > RESET_DISTANCE && !isAwareOfPlayer:
		state = states.RESET
		
	if state == states.RESET:
		navAgent.target_position = startGlobalPosition
		var direction = global_position.direction_to(navAgent.get_next_path_position())
		navAgent.velocity = direction * speed * delta
		if direction.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		canMove = true
	
	elif state == states.CHASE:
		var offset = Vector2(MOVEMENT_OFFSET,0)
		var direction = player.position.direction_to(position)
		if direction.x < 0:
			offset = -offset
		var distance = position.distance_to(player.position + offset)
		
		navAgent.target_position = player.global_position + offset
		navAgent.velocity = global_position.direction_to(navAgent.get_next_path_position()) * speed * delta
		
		if navAgent.velocity.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false	
		if distance < chaseDistance && (direction.x > PLAYER_X_ALIGNMENT || direction.x < -PLAYER_X_ALIGNMENT):
			state = states.IDLE
			if direction.x > 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			if canAttack:
				attack()
			canMove = false
		else:
			canMove = true
			
	elif state == states.IDLE:
		if player && inRange:
			var offset = Vector2(MOVEMENT_OFFSET,0)
			var direction = player.position.direction_to(position)
			if direction.x < 0:
				offset = -offset
			var distance = position.distance_to(player.position + offset)
		
			if distance > chaseDistance:
				state = states.CHASE
			else:
				if direction.x > 0:
					sprite.flip_h = true
				else:
					sprite.flip_h = false
				if canAttack:
					attack()
	if (isAwareOfPlayer && !inRange) || (isAwareOfPlayer && state == states.RESET):
		state = states.CHASE
	
func attack():
	state = states.ATTACK
	canAttack = false
	attackTimer.start(attackSpeed)
	if sprite.flip_h:
		if attackHitbox.position.x > 0:
			attackHitbox.position.x = -attackHitbox.position.x
	else:
		attackHitbox.position.x = abs(attackHitbox.position.x)
	attackHitbox.disabled = false
			
func damage(dmg:int):
	awareOfPlayer()
	hp -= dmg
	Global.makeFlyingTextLabel(global_position, str(dmg), Color.RED, Global.LABEL_SIZE_BIG)
	if hp <= 0:
		#var randomSpawn = randi() % 4 + 1 # 25% chance to spawn
		var textPos = Vector2(global_position.x + 50, global_position.y)
		Global.makeFlyingTextLabel(textPos, str(EXP_RECEIVED," XP"), Color.MEDIUM_PURPLE, Global.LABEL_SIZE_MEDIUM)
		var randomSpawn = randi_range(1,4)
		if randomSpawn > 2:
			lootNode.position = position
			var parent = get_node("../")
			parent.call_deferred("add_child", lootNode)
		if player:
			if player.has_method("calculateExp"):
				player.call("calculateExp", EXP_RECEIVED)
			if player.has_method("isOnQuest"):
				for questId in questIds:
					var isOnQuest = player.call("isOnQuest", questId)
					if isOnQuest:
						if player.has_method("incrementQuestNum"):
							player.call("incrementQuestNum", questId)
		Global.enemy_died.emit(startPosition, enemyType)
		queue_free()

func _on_sight_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		state = states.CHASE
		inRange = true

func _on_sight_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		state = states.RESET
		inRange = false

func _on_sprite_animation_finished() -> void:
	if sprite.animation == "Attack":
		attackHitbox.disabled = true
		state = states.IDLE
		
func _on_sprite_frame_changed() -> void:
	if sprite.animation == "Attack":
		if checkEnemyAttackFrame():
			if player && inAttackRange:
				if player.has_method("damage"):
					player.call("damage", attackDamage, global_position)

func checkEnemyAttackFrame() -> bool:
	if enemyType == Global.EnemyTypes.RedWarrior and sprite.get_frame() == 2 or \
		enemyType == Global.EnemyTypes.Skull and sprite.get_frame() == 3 or \
		enemyType == Global.EnemyTypes.Snake and sprite.get_frame() == 3:
			return true
	else:
		return false

func _on_attack_timer_timeout() -> void:
	canAttack = true

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if canMove:
		velocity = velocity.move_toward(safe_velocity, .25)
		move_and_collide(velocity)

func _on_navigation_agent_2d_navigation_finished() -> void:
	if state == states.RESET:
		state = states.IDLE
		canMove = false


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		inAttackRange = true


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		inAttackRange = false
		
func _on_add_quest(questId:int):
	questIds.has(questId)
	if questIds.has(questId):
		checkQuestTarget(questId)
					
func checkQuestTarget(questId:int):
	if player:
		if player.has_method("isQuestReadyToComplete"):
			if player.call("isQuestReadyToComplete", questId):
				questSprite.texture = null
				questSprite.hide()
			elif player.has_method("isOnQuest"):
				if player.call("isOnQuest", questId):
					questSprite.texture = questTargetTexture
					questSprite.show()
				
func _on_quest_ready_to_turn_in(questId:int):
	if player:
		if questIds.has(questId):
			if player.call("isOnQuest", questId):
				questSprite.hide()

func awareOfPlayer():
	isAwareOfPlayer = true
	isAttackedTimer.one_shot = true
	isAttackedTimer.start(10)

func _on_is_attacked_timer_timeout() -> void:
	isAwareOfPlayer = false
