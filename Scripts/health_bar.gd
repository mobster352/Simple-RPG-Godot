extends ProgressBar

@onready var player = $"../.."

class Hp:
	var level:int
	var size:int
	var maxValue:int

var hpArray:Array
var currentHp:Hp

func _ready() -> void:
	var hp = Hp.new()
	hp.level = 1
	hp.size = 50
	hp.maxValue = 10
	hpArray.append(hp)
	hp = Hp.new()
	hp.level = 2
	hp.size = 75
	hp.maxValue = 20
	hpArray.append(hp)
	hp = Hp.new()
	hp.level = 3
	hp.size = 100
	hp.maxValue = 40
	hpArray.append(hp)
	currentHp = hpArray.get(0)
	
	max_value = currentHp.maxValue
	size.x = currentHp.size

func _process(_delta: float) -> void:
	if currentHp.level != player.level:
		var hp = getHpFromPlayerLevel(player.level)
		size.x = hp.size
		max_value = hp.maxValue
		currentHp = hp

func getHpFromPlayerLevel(playerLevel:int):
	for hp in hpArray:
		if hp.level == playerLevel:
			return hp
