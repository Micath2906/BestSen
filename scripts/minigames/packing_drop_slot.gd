extends PanelContainer

## packing_drop_slot.gd
## Drop target container for luggage compartments.

var comp_key: String = ""
var minigame_ref = null
var default_border_color: Color

func setup_slot(key: String, minigame) -> void:
	comp_key = key
	minigame_ref = minigame
	mouse_filter = Control.MOUSE_FILTER_PASS
	var sb = get_theme_stylebox("panel")
	if sb is StyleBoxFlat:
		default_border_color = sb.border_color

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_DICTIONARY and data.get("type", "") == "packing_item":
		return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if typeof(data) == TYPE_DICTIONARY and data.get("type", "") == "packing_item":
		var item_data: Dictionary = data.get("item_data", {})
		if minigame_ref and minigame_ref.has_method("handle_item_drop"):
			minigame_ref.handle_item_drop(item_data, comp_key)
