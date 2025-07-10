extends RigidBody2D

@onready var sprite:AnimatedSprite2D = $Sprite
@onready var hitbox:CollisionShape2D = $Hitbox
@onready var movementLine:Line2D = $MovementLine

enum states {
	IDLE,
	CHASE
}

var hp:int
var speed:int
var startPosition:Vector2
const CHASE_DISTANCE:int = 25
const MOVEMENT_OFFSET:int = 50
const PLAYER_X_ALIGNMENT = 0.5

var state = states.IDLE
var player:CharacterBody2D

#@onready var player:CharacterBody2D
func _ready() -> void:
	hp = 3
	speed = 120
	startPosition = position
	#var playerGroupNodes = get_tree().get_nodes_in_group("player")
	#var playerNode = playerGroupNodes.get(0)
	#player = playerNode as CharacterBody2D
	
func _process(_delta: float) -> void:
	move(_delta)
	playAnimation()

func playAnimation():
	if state == states.IDLE:
		sprite.play("Idle")
	elif state == states.CHASE:
		sprite.play("Walk")
	else:
		sprite.play("Idle")
	
func move(_delta: float):
	if state == states.CHASE:
		var offset = Vector2(MOVEMENT_OFFSET,0)
		var direction = player.position.direction_to(position)
		
		if direction.x < 0:
			offset = -offset
		
		var distance = position.distance_to(player.position + offset)
		var motion = position.direction_to(player.position + offset) * speed * _delta
		
		if motion.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
		
		if distance < CHASE_DISTANCE && (direction.x > PLAYER_X_ALIGNMENT || direction.x < -PLAYER_X_ALIGNMENT):
			state = states.IDLE
			if direction.x > 0:
				sprite.flip_h = true
			else:
				sprite.flip_h = false
			
		#movementLine.clear_points()
		#movementLine.add_point(movementLine.to_local(global_position))
		#movementLine.add_point(movementLine.to_local(player.global_position + offset))
			
		move_and_collide(motion)
	
func damage(dmg:int):
	hp -= dmg
	if hp <= 0:
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player sighted")
		state = states.CHASE
		player = body as CharacterBody2D


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("player lost")
		state = states.IDLE
