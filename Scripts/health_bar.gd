extends ProgressBar

class Hp:
	var level:int
	var size:int
	var maxValue:int

var hpArray:Array
var currentHp:Hp

func _ready() -> void:
	var levelIndex = 1
	while levelIndex < 99:
		var hp = Hp.new()
		hp.level = levelIndex
		hp.maxValue = floor(10 * pow(levelIndex, 0.5))
		hpArray.append(hp)
		levelIndex += 1
	currentHp = hpArray.get(0)
	max_value = currentHp.maxValue

func _process(_delta: float) -> void:
	if currentHp.level != PlayerData.level:
		var hp = getHpFromPlayerLevel(PlayerData.level)
		max_value = hp.maxValue
		currentHp = hp

func getHpFromPlayerLevel(playerLevel:int):
	for hp in hpArray:
		if hp.level == playerLevel:
			return hp
