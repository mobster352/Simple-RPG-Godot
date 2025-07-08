extends AnimatedSprite2D

@onready var player:CharacterBody2D
	
func _ready() -> void:
	var playerGroupNodes = get_tree().get_nodes_in_group("player")
	var playerNode = playerGroupNodes.get(0)
	player = playerNode as CharacterBody2D

func _process(delta: float) -> void:
	play("tree")
	#print(position.y-offset.y)
	#if player.position.y > position.y - offset.y:
		#z_index = 0
	#else:
		#z_index = 1
