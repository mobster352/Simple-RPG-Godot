extends RigidBody2D

@onready var sprite:AnimatedSprite2D = $Sprite
@onready var hitbox:CollisionShape2D = $Hitbox

var hp:int = 3

#@onready var player:CharacterBody2D
#func _ready() -> void:
	#var playerGroupNodes = get_tree().get_nodes_in_group("player")
	#var playerNode = playerGroupNodes.get(0)
	#player = playerNode as CharacterBody2D
	
func _process(_delta: float) -> void:
	playAnimation()

func playAnimation():
	sprite.play("Idle")
	
func damage(dmg:int):
	hp -= dmg
	if hp <= 0:
		queue_free()
