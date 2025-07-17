extends ProgressBar

@onready var player = $"../.."

class Hp:
	var level:int
	var size:int
	var maxValue:int

var hpArray:Array
var currentHp:Hp

func _ready() -> void:
	var config = ConfigFile.new()
	var err = config.load("res://Files/health_levels.cfg")
	if err != OK:
		print("File did not load")
		return
	for level in config.get_sections():
		var hp = Hp.new()
		hp.level = config.get_value(level, "level")
		hp.size = config.get_value(level, "size")
		hp.maxValue = config.get_value(level, "max_hp")
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
