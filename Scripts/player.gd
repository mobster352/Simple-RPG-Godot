extends CharacterBody2D

@export var speed = 100;
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D;

var isAttacking = false;

func _process(delta: float) -> void:
	movePlayer()	
	playAnimations()
	#print(get_global_mouse_position())

func movePlayer():
	velocity = Vector2.ZERO
	if Input.is_action_pressed("MoveRight"):
		velocity.x += speed;
		sprite.flip_h = false;
	if Input.is_action_pressed("MoveLeft"):
		velocity.x -= speed;
		sprite.flip_h = true;
	if Input.is_action_pressed("MoveUp"):
		velocity.y -= speed;
	if Input.is_action_pressed("MoveDown"):
		velocity.y += speed;
	move_and_slide()
	
func playAnimations():
	if velocity == Vector2.ZERO:
		sprite.play("Idle");
	else:
		sprite.play("Walk");
	if Input.is_action_just_pressed("Attack"):
		isAttacking = true;
		sprite.play("Attack")
