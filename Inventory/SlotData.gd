extends Resource
class_name SlotData

const MAX_STACK_SIZE: int = 64

@export var item: InventoryItem
@export_range(1, MAX_STACK_SIZE) var quantity: int = 1: set = set_quantity

func set_quantity(value: int) -> void:
	quantity = value
	if quantity > 1 and not item.stackable:
		quantity = 1
		push_warning("%s is not stackable. Setting quantity to 1", item.name)
