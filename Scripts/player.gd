extends CharacterBody2D

@export var speed = 100
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var attackHitbox = $Area2D/AttackHitbox

var isAttacking = false

#@onready var enemyNodes:Array
#func _ready() -> void:
	#var enemyGroupNodes = get_tree().get_nodes_in_group("enemy")
	#for enemyNode in enemyGroupNodes:
		#enemyNodes.append(enemyNode)

func _process(_delta: float) -> void:
	movePlayer()
	playAnimations()

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

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "Attack":
		isAttacking = false
		attackHitbox.disabled = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("damage"):
			body.call("damage", 1)
