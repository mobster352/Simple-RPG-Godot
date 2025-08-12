extends Node2D

@export var respawnTime = 30
@export var player:CharacterBody2D

func _ready() -> void:
	Global.enemy_died.connect(_on_enemy_died)
	
func _on_enemy_died(startPosition:Vector2, enemyType:int):
	var timer = Timer.new()
	timer.wait_time = respawnTime
	timer.connect("timeout", _on_enemy_timer_timeout.bind(timer, startPosition, enemyType))
	add_child(timer)
	timer.start()

func _on_enemy_timer_timeout(timer:Timer, startPosition:Vector2, enemyType:int):
	var enemy = preload("res://Characters/enemy.tscn").instantiate()
	if enemyType == Global.EnemyTypes.RedWarrior:
		enemy.name = "RedWarrior"
		enemy.enemyScenePath = "res://Characters/Enemy/red_warrior.tscn"
		enemy.maxHp = 30
		enemy.speed = 120
	elif enemyType == Global.EnemyTypes.Skull:
		enemy.name = "Skullman"
		enemy.enemyScenePath = "res://Characters/Enemy/skull.tscn"
		enemy.maxHp = 50
		enemy.speed = 120
	elif enemyType == Global.EnemyTypes.Snake:
		enemy.name = "Snake"
		enemy.enemyScenePath = "res://Characters/Enemy/snake.tscn"
		enemy.maxHp = 15
		enemy.speed = 180
		enemy.attackDamage = 1
		enemy.attackSpeed = 1.5
	enemy.global_position = startPosition
	enemy.player = player
	add_child(enemy)
	timer.queue_free()
