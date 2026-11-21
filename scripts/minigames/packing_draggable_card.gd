extends PanelContainer

const PixelPlaceholderFactory = preload("res://scripts/utils/PixelPlaceholderFactory.gd")

## packing_draggable_card.gd
## Card representing an item in the suitcase packing tray.
## Supports both drag-and-drop and direct tap/click inspection.

var item_data: Dictionary = {}
var minigame_ref = null

func setup_card(data: Dictionary, minigame) -> void:
	item_data = data
	minigame_ref = minigame
	mouse_filter = Control.MOUSE_FILTER_PASS

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if minigame_ref and minigame_ref.has_method("_show_item_inspection"):
			minigame_ref._show_item_inspection(item_data)

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not minigame_ref or not minigame_ref.can_accept_input():
		return null
		
	# Create drag preview
	var preview := Control.new()
	var preview_tex := TextureRect.new()
	preview_tex.custom_minimum_size = Vector2(48, 48)
	preview_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	preview_tex.texture = PixelPlaceholderFactory.get_or_create(
		item_data["asset_id"],
		Vector2i(48, 48),
		item_data["cat_enum"],
		item_data["name"]
	)
	preview_tex.position = -Vector2(24, 24)
	preview_tex.modulate = Color(1, 1, 1, 0.85)
	preview.add_child(preview_tex)
	set_drag_preview(preview)

	return {
		"type": "packing_item",
		"item_data": item_data
	}
