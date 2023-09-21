extends PanelContainer

@onready var texture_rect: TextureRect = $MarginContainer/TextureRect
@onready var quantity_label: Label = $QuantityLabel

func set_slot_data(slot_data: SlotData) -> void:
	var item = slot_data.item
	texture_rect.texture = item.texture
	tooltip_text = "%s\n$s" % [item.name, item.description]
	
	if slot_data.quantity > 1:
		quantity_label.text = "x%s" % slot_data.quantity
	else:
		quantity_label.text = ""
