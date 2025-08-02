extends Control

@onready var inventoryGrid:GridContainer = $GridContainer

@onready var player = get_node(".")

class Item:
	var id:int
	var name:String
	var texture:Texture2D
	var value:int
	
var allItems:Array
var inventory:Array
	
func _ready() -> void:
	var config = ConfigFile.new()
	var err = config.load("res://Files/item_database.cfg")
	if err != OK:
		print("File did not load")
		return
	for section in config.get_sections():
		var sectionKeys = config.get_section_keys(section)
		var item = Item.new()
		for key in sectionKeys:
			var value = config.get_value(section, key)
			if key == "id":
				item.id = value
			elif key == "name":
				item.name = value
			elif key == "texture":
				item.texture = load(value)
			elif key == "value":
				item.value = value
		allItems.append(item)
	inventory = [
				null, null, null,
				null, null, null,
				null, null, null
				]
	Global.connect("item_pickup", _on_item_pickup)
	
func findItem(itemId:int):
	for item in allItems:
		if item.id == itemId:
			return item
	
func _on_item_pickup(itemId:int):
	var item = findItem(itemId)
	if item:
		if itemId == 0:
			Global.add_potion.emit()
		else:
			var slotIndex = addItemToInventorySlot(item)
			if slotIndex != -1:
				inventory.set(slotIndex, item)
				#print("Item picked up: ", item.name)
				var slotTexture = inventoryGrid.get_child(slotIndex).get_child(1) as TextureRect
				if slotTexture:
					slotTexture.texture = item.texture
		
func addItemToInventorySlot(item:Item):
	var index:int = 0
	for slot in inventory:
		if !slot:
			slot = item
			return index
		index += 1
	return -1
	
func findItemInInventorySlot(slotIndex:int):
	var slot = inventory.get(slotIndex)
	if slot:
		return slot
		
func findItemInInventory(itemId:int):
	for index in range(inventory.size()):
		var slot = inventory.get(index)
		if slot:
			if slot.id == itemId:
				return slot

func updateInventorySlot(slotIndex:int, isVisible:bool):
	var textureRect = inventoryGrid.get_child(slotIndex).get_child(0) as TextureRect
	if isVisible:
		textureRect.show()
	else:
		textureRect.hide()

func _on_inventory_slot_mouse_entered(slotIndex:int) -> void:
	updateInventorySlot(slotIndex, true)
	Global.toggle_player_attack.emit(false)


func _on_inventory_slot_mouse_exited(slotIndex:int) -> void:
	updateInventorySlot(slotIndex, false)
	Global.toggle_player_attack.emit(true)


func removeTexture(slotIndex:int):
	var slotTexture = inventoryGrid.get_child(slotIndex).get_child(1) as TextureRect
	if slotTexture:
		slotTexture.texture = null

func _on_inventory_slot_gui_input(event: InputEvent, slotIndex:int) -> void:
	if event.is_pressed():
		var item:Item = findItemInInventorySlot(slotIndex)
		if item:
			if item.id == 0:
				Global.heal.emit(item.value)
				inventory.set(slotIndex, null)
				removeTexture(slotIndex)
