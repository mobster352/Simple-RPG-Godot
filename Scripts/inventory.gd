extends Control

@onready var inventoryGrid:GridContainer = $GridContainer

func updateInventorySlot(slotIndex:int, isVisible:bool):
	var textureRect = inventoryGrid.get_child(slotIndex).get_child(0) as TextureRect
	if isVisible:
		textureRect.show()
	else:
		textureRect.hide()

func _on_inventory_slot_1_mouse_entered() -> void:
	updateInventorySlot(0, true)


func _on_inventory_slot_1_mouse_exited() -> void:
	updateInventorySlot(0, false)


func _on_inventory_slot_2_mouse_entered() -> void:
	updateInventorySlot(1, true)


func _on_inventory_slot_2_mouse_exited() -> void:
	updateInventorySlot(1, false)


func _on_inventory_slot_3_mouse_entered() -> void:
	updateInventorySlot(2, true)


func _on_inventory_slot_3_mouse_exited() -> void:
	updateInventorySlot(2, false)


func _on_inventory_slot_4_mouse_entered() -> void:
	updateInventorySlot(3, true)


func _on_inventory_slot_4_mouse_exited() -> void:
	updateInventorySlot(3, false)


func _on_inventory_slot_5_mouse_entered() -> void:
	updateInventorySlot(4, true)


func _on_inventory_slot_5_mouse_exited() -> void:
	updateInventorySlot(4, false)


func _on_inventory_slot_6_mouse_entered() -> void:
	updateInventorySlot(5, true)


func _on_inventory_slot_6_mouse_exited() -> void:
	updateInventorySlot(5, false)


func _on_inventory_slot_7_mouse_entered() -> void:
	updateInventorySlot(6, true)


func _on_inventory_slot_7_mouse_exited() -> void:
	updateInventorySlot(6, false)


func _on_inventory_slot_8_mouse_entered() -> void:
	updateInventorySlot(7, true)


func _on_inventory_slot_8_mouse_exited() -> void:
	updateInventorySlot(7, false)


func _on_inventory_slot_9_mouse_entered() -> void:
	updateInventorySlot(8, true)


func _on_inventory_slot_9_mouse_exited() -> void:
	updateInventorySlot(8, false)
