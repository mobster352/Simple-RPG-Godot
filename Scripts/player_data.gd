extends Node

var level:int
var maxHP:int
var currentHP:int
var currentExp:int
var stamina:float
var playerId:int
var weapon:Vector2
var sprite: AnimatedSprite2D

enum PlayerTypes {
	WARRIOR,
	LANCER,
	ARCHER
}

func initPlayer(playerId:int):
	self.playerId = playerId
	if playerId == PlayerTypes.WARRIOR:
		sprite = preload("res://Characters/Player/warrior_sprite.tscn").instantiate()
		weapon = Vector2(7,13)
	elif playerId == PlayerTypes.LANCER:
		sprite = preload("res://Characters/Player/lancer_sprite.tscn").instantiate()
		weapon = Vector2(5,10)
	elif playerId == PlayerTypes.ARCHER:
		sprite = preload("res://Characters/Player/archer_sprite.tscn").instantiate()
		weapon = Vector2(10,15)
	else:
		sprite = preload("res://Characters/Player/warrior_sprite.tscn").instantiate()
		weapon = Vector2(7,13)
	level = 1
	maxHP = 10
	currentHP = maxHP
	currentExp = 0
	stamina = 100
