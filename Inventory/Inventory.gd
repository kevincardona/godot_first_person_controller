extends PanelContainer

const Slot = preload("res://inventory/slot.tscn")

@onready var item_grid: GridContainer = $MarginContainer/ItemGrid

func populate_item_grid(slot_datas: Array[SlotData]) -> void:
	for child in item_grid.get_children():
		child.queue_free()

	for slot_data in slot_datas:
		var slot = Slot.instantiate()
		item_grid.add_child(slot)
		
		if slot_data:
			slot.set_slot_data(slot_data)
