extends Resource
class_name InventoryItem

@export var item_name: String
@export var item_id: int
@export_multiline var description: String
@export var texture: AtlasTexture
@export var stackable: bool = false
@export var max_stack: int = 64
