extends Node

signal show_dialogue
signal increment_dialogue
signal enemy_died
signal add_quest
signal quest_ready_to_turn_in
signal item_pickup
signal heal
signal add_potion
signal toggle_player_attack

const LABEL_SPEED = 5
const LABEL_SIZE_SMALL = 20
const LABEL_SIZE_MEDIUM = 25
const LABEL_SIZE_BIG = 30

enum QuestType {
	NONE,
	KILL,
	TALK
}

var flyingTextNode:Node

func _ready() -> void:
	flyingTextNode = Node.new()
	flyingTextNode.name = "FlyingTextNode"
	add_child(flyingTextNode)

func _process(delta: float) -> void:
	for label in flyingTextNode.get_children():
		label = label as Label
		label.global_position -= Vector2(0, 10) * LABEL_SPEED * delta

func makeFlyingTextLabel(global_position:Vector2, text:String, color:Color, labelSize:int):
	var label = Label.new()
	label.text = text
	label.label_settings = LabelSettings.new()
	label.label_settings.font_color = color
	label.label_settings.font_size = labelSize
	label.label_settings.outline_color = Color.BLACK
	label.label_settings.outline_size = 5
	label.z_index = 10
	label.global_position = global_position
	flyingTextNode.add_child(label)
	var timer = Timer.new()
	timer.wait_time = 1
	timer.one_shot = true
	timer.connect("timeout", _on_timer_timeout.bind(label))
	label.add_child(timer)
	timer.start()
	
func _on_timer_timeout(label:Label):
	label.queue_free()
