extends CharacterBody2D

var level = 1
var maxHP = 10
var currentHP = maxHP

@export var speed = 100
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var attackHitbox = $Area2D/AttackHitbox
@onready var hitbox = $Hitbox
@onready var healthBar = $CanvasLayer/HealthBar
@onready var deathControl = $CanvasLayer/DeathControl

var isAttacking = false
var startPosition:Vector2

func _ready() -> void:
	startPosition = global_position

func _process(_delta: float) -> void:
	playAnimations()
	healthBar.value = currentHP
	
func _physics_process(delta: float) -> void:
	if visible:
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
	if Input.is_action_just_pressed("Attack"):
		isAttacking = true 
		attackHitbox.disabled = false
		sprite.play("Attack")
		
func damage(dmg:int):
	currentHP -= dmg
	print("HP: ", currentHP)
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
		
func levelUp():
	if level < 3:
		level += 1
		var hp = healthBar.getHpFromPlayerLevel(level)
		maxHP = hp.maxValue
		currentHP = maxHP
		print("Level Up: ", level)

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "Attack":
		isAttacking = false
		attackHitbox.disabled = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("damage"):
			body.call("damage", 1)

func _on_respawn_button_pressed() -> void:
	global_position = startPosition
	currentHP = maxHP
	show()
	hitbox.disabled = false
	deathControl.hide()
	get_tree().reload_current_scene()
