extends Node2D

@export var respawnTime = 30

func _ready() -> void:
	Global.enemy_died.connect(_on_enemy_died)
	
func _on_enemy_died(startPosition:Vector2):
	var timer = Timer.new()
	timer.wait_time = respawnTime
	timer.connect("timeout", _on_enemy_timer_timeout.bind(timer, startPosition))
	add_child(timer)
	timer.start()

func _on_enemy_timer_timeout(timer:Timer, startPosition:Vector2):
	var enemy = preload("res://Characters/enemy.tscn").instantiate()
	enemy.global_position = startPosition
	add_child(enemy)
	timer.queue_free()
