extends Control

@onready var player_inventory: PanelContainer = $PlayerInventory

func _ready():
	var test_inv = load("res://Inventory/test_inventory.tres")
	set_player_inventory_data(test_inv)

func set_player_inventory_data(inventory_data: InventoryData):
	$PlayerInventory.populate_item_grid(inventory_data.slots)
	
