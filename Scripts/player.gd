extends CharacterBody2D

var level = 1
var maxHP = 10
var currentHP = maxHP
var currentExp = 0
var stamina = 100
var weapon = Vector2(7,13)

@export var speed = 100

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var attackHitbox = $Area2D/AttackHitbox
@onready var hitbox = $Hitbox
@onready var healthBar = $CanvasLayer/HealthBar
@onready var deathControl = $CanvasLayer/DeathControl
@onready var expBar = $CanvasLayer/ExpBar
@onready var flyingTextNode = $FlyingTextNode
@onready var staminaBar = $Control/StaminaBar
@onready var levelLabel = $CanvasLayer/LevelLabel
@onready var levelUpLabel = $Control/StaminaBar/LevelUpLabel
@onready var healthLabel = $CanvasLayer/HealthBar/HealthLabel

var isAttacking = false
var startPosition:Vector2
var canMove:bool = true

var textArray:Array = ["test test test"]
var currentTextIndex:int = 0

class ExpLevel:
	var level:int
	var expNextLevel:int
	var attackDamage:int

var expArray:Array
var currentExpLevel:ExpLevel

func _ready() -> void:
	startPosition = global_position
	var config = ConfigFile.new()
	var err = config.load("res://Files/exp_levels.cfg")
	if err != OK:
		print("File did not load")
		return
	for level in config.get_sections():
		var xp = ExpLevel.new()
		xp.level = config.get_value(level, "level")
		xp.expNextLevel = config.get_value(level, "exp")
		expArray.append(xp)
	currentExpLevel = expArray.get(0)
	expBar.max_value = currentExpLevel.expNextLevel
	expBar.value = 0
	Global.show_dialogue.connect(_on_show_dialogue)

func _process(delta: float) -> void:
	playAnimations()
	if stamina < 100:
		staminaBar.show()
		stamina += 1 * 10 * delta
	else:
		staminaBar.hide()
	healthLabel.text = str(currentHP)
	healthBar.value = currentHP
	staminaBar.value = stamina
	levelLabel.text = str("Lv ", level)
	
	#if Input.is_action_just_pressed("Use"):
		#canMove = false
		#if currentTextIndex >= textArray.size():
			#Global.show_dialogue.emit("",null,null)
			#currentTextIndex = 0
			#canMove = true
		#else:
			#Global.show_dialogue.emit(textArray.get(currentTextIndex), sprite.sprite_frames, null)
			#currentTextIndex += 1
	
func _physics_process(_delta: float) -> void:
	if visible && canMove:
		movePlayer()

func movePlayer():
	if isAttacking:
		return
	velocity = Vector2.ZERO
	if Input.is_action_pressed("MoveRight"):
		velocity.x += speed
		sprite.flip_h = false
		if attackHitbox.position.x < 0:
			attackHitbox.position.x *= -1
	if Input.is_action_pressed("MoveLeft"):
		velocity.x -= speed
		sprite.flip_h = true
		if attackHitbox.position.x > 0:
			attackHitbox.position.x *= -1
	if Input.is_action_pressed("MoveUp"):
		velocity.y -= speed
	if Input.is_action_pressed("MoveDown"):
		velocity.y += speed
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
	if level < 3:
		level += 1
		refreshCurrentExpFromPlayerLevel()
		var hp = healthBar.getHpFromPlayerLevel(level)
		maxHP = hp.maxValue
		currentHP = maxHP
		print("Level Up: ", level)
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
	print("Gained ", expToGain, " XP")
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
	global_position = startPosition
	currentHP = maxHP
	show()
	hitbox.disabled = false
	deathControl.hide()
	get_tree().reload_current_scene()
	
func _on_show_dialogue(text:String, left:SpriteFrames, right:SpriteFrames):
	if text == "":
		canMove = true
	else:
		canMove = false
