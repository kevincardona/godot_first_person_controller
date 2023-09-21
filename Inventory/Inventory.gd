extends Node
class_name Inventory

@export var inventory_data: InventoryData = null
@export var inventory_columns: int = 6
@export var slot_count: int = 36
@onready var item_grid: GridContainer = $InventoryContainer/MarginContainer/ItemGrid
@onready var inventory_container: Control = $InventoryContainer

const SLOT = preload("res://inventory/slot.tscn")

var is_open: bool = false

func _ready():
	var test_inv = load("res://Inventory/test_inventory_data.tres")

func toggle_open():
	is_open = !is_open
	inventory_container.visible = is_open

func open():
	is_open = true
	inventory_container.visible = is_open
	Global._open_game_menu()

func close():
	is_open = false
	inventory_container.visible = false
	Global._close_game_menu()

func generate_item_grid_slots() -> void:
	for i in range(slot_count):
		var slot = SLOT.instantiate()
		item_grid.add_child(slot) 
	reload_item_grid_data()

func reload_item_grid_data() -> void:
	for i in range(slot_count):
		item_grid.get_child(i).set_slot_data(inventory_data.slots[i])


## Used for development ##
func generate_test_inventory():
	pass
