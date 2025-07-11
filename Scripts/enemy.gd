extends CharacterBody2D

@onready var sprite:AnimatedSprite2D = $Sprite
@onready var hitbox:CollisionShape2D = $Hitbox
@onready var movementLine:Line2D = $MovementLine
@onready var attackTimer:Timer = $AttackTimer

@onready var navAgent:NavigationAgent2D = $NavigationAgent2D

enum states {
	IDLE,
	CHASE,
	ATTACK,
	RESET
}

var hp:int
var speed:int

var startPosition:Vector2
var canAttack:bool
var atPlayer:bool
var canMove:bool

const CHASE_DISTANCE:int = 25
const MOVEMENT_OFFSET:int = 50
const PLAYER_X_ALIGNMENT:float = 0.5
const ATTACK_TIMER_SECS:float = 3.0
const RESET_DISTANCE:float = 1000
const ATTACK_DAMAGE:int = 50

var state = states.IDLE
var player:CharacterBody2D

func _ready() -> void:
	hp = 3
	speed = 120
	startPosition = global_position
	canAttack = true
	canMove = false
	
func _process(_delta: float) -> void:
	playAnimation()
	
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
	if global_position.distance_to(startPosition) > RESET_DISTANCE:
		state = states.RESET
		
	if state == states.RESET:
		navAgent.target_position = startPosition
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
		if distance < CHASE_DISTANCE && (direction.x > PLAYER_X_ALIGNMENT || direction.x < -PLAYER_X_ALIGNMENT):
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
		if player:
			var offset = Vector2(MOVEMENT_OFFSET,0)
			var direction = player.position.direction_to(position)
			if direction.x < 0:
				offset = -offset
			var distance = position.distance_to(player.position + offset)
		
			if distance > CHASE_DISTANCE:
				state = states.CHASE
			else:
				if direction.x > 0:
					sprite.flip_h = true
				else:
					sprite.flip_h = false
				if canAttack:
					attack()
	
func attack():
	state = states.ATTACK
	canAttack = false
	attackTimer.start(ATTACK_TIMER_SECS)
	if player:
		if player.has_method("damage"):
			player.call("damage", ATTACK_DAMAGE)
			
func damage(dmg:int):
	hp -= dmg
	if hp <= 0:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		state = states.CHASE
		player = body as CharacterBody2D

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = null
		state = states.RESET

func _on_sprite_animation_finished() -> void:
	if sprite.animation == "Attack":
		state = states.IDLE

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
