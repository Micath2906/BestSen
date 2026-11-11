extends Node2D

# IsometricFurniture.gd - Các vật dụng nội thất phòng trọ Pixel-Art chuẩn phối cảnh 2D Classic / Isometric
# Chỉ gồm 4 món thiết yếu: Giường đệm ngủ, Chén đồ ăn, Chén nước uống, và Chậu cát vệ sinh (có thể trang trí tương tác)
# Tự động đổ bóng mềm mại và hiệu ứng tương tác nảy (Juicy Squash & Stretch)

enum FurnitureType {
	CUSHION_BED,
	FOOD_BOWL,
	WATER_BOWL,
	LITTER_BOX,
	# Backward-compatibility alias
	FOOD_WATER_TRAY = 1,
	SCRATCH_POST = 4,
	CARDBOARD_BOX = 5,
	DECOR_SLOT = 6
}

@export var furniture_type: FurnitureType = FurnitureType.CUSHION_BED
@export var grid_coord: Vector2 = Vector2.ZERO

signal item_clicked(type)

var sprite_node: Sprite2D
var shadow_pts: PackedVector2Array
var is_hovered: bool = false

const TEXTURE_PATHS = {
	FurnitureType.CUSHION_BED: "res://assets/sprites/room_items/cat_bed_pink_classic.png",
	FurnitureType.FOOD_BOWL: "res://assets/sprites/room_items/mobile/bowl_mobile_blue_food.png",
	FurnitureType.WATER_BOWL: "res://assets/sprites/room_items/mobile/bowl_mobile_green_water.png",
	FurnitureType.LITTER_BOX: "res://assets/sprites/room_items/litter_box.png",
}

func _ready() -> void:
	z_as_relative = true
	_setup_sprite_node()
	_setup_shadow()
	GameManager.decor_changed.connect(func(_slot, _id): refresh_furniture())
	refresh_furniture()

func refresh_furniture() -> void:
	if not sprite_node:
		return
	visible = true
	var tex: Texture2D = null
	match furniture_type:
		FurnitureType.CUSHION_BED:
			var bed_id = GameManager.equipped_decor.get("beds", "")
			if bed_id != "" and bed_id != "d_bed_box":
				var path = GameManager.get_furniture_sprite_path(bed_id)
				if path != "":
					tex = _load_texture(path)
			if tex == null:
				tex = _load_texture("res://assets/sprites/room_items/cat_bed_pink_classic.png")
			sprite_node.scale = Vector2(1.2, 1.2)
			sprite_node.position = Vector2(0, -22)
			
		FurnitureType.FOOD_BOWL:
			var bowl_id = GameManager.equipped_decor.get("bowls", "")
			if bowl_id != "":
				var path = GameManager.get_furniture_sprite_path(bowl_id)
				if path != "":
					tex = _load_texture(path)
			if tex == null:
				tex = _load_texture("res://assets/sprites/room_items/mobile/bowl_mobile_blue_food.png")
			sprite_node.scale = Vector2(1.15, 1.15)
			sprite_node.position = Vector2(0, -14)
			
		FurnitureType.WATER_BOWL:
			tex = _load_texture("res://assets/sprites/room_items/mobile/bowl_mobile_green_water.png")
			if tex == null:
				tex = _load_texture("res://assets/sprites/room_items/bowl_water.png")
			sprite_node.scale = Vector2(1.15, 1.15)
			sprite_node.position = Vector2(0, -14)
			
		FurnitureType.LITTER_BOX:
			tex = _load_texture("res://assets/sprites/room_items/litter_box.png")
			sprite_node.scale = Vector2(1.15, 1.15)
			sprite_node.position = Vector2(0, -18)
			
		_:
			tex = _load_texture(TEXTURE_PATHS.get(furniture_type, ""))
			
	if tex:
		sprite_node.texture = tex
		queue_redraw()

func _setup_sprite_node() -> void:
	sprite_node = Sprite2D.new()
	sprite_node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite_node)
	
	var tex_path = TEXTURE_PATHS.get(furniture_type, "")
	var tex: Texture2D = _load_texture(tex_path)
	
	if tex:
		sprite_node.texture = tex
		match furniture_type:
			FurnitureType.CUSHION_BED:
				sprite_node.scale = Vector2(1.2, 1.2)
				sprite_node.position = Vector2(0, -22)
			FurnitureType.FOOD_BOWL:
				sprite_node.scale = Vector2(1.15, 1.15)
				sprite_node.position = Vector2(0, -14)
			FurnitureType.WATER_BOWL:
				sprite_node.scale = Vector2(1.15, 1.15)
				sprite_node.position = Vector2(0, -14)
			FurnitureType.LITTER_BOX:
				sprite_node.scale = Vector2(1.15, 1.15)
				sprite_node.position = Vector2(0, -18)
	else:
		queue_redraw()

func _load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var t = load(path)
		if t: return t
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(path)
		if img:
			return ImageTexture.create_from_image(img)
	return null

func _setup_shadow() -> void:
	match furniture_type:
		FurnitureType.CUSHION_BED:
			shadow_pts = _make_iso_ellipse(Vector2(0, 4), 34.0, 17.0)
		FurnitureType.FOOD_BOWL:
			shadow_pts = _make_iso_ellipse(Vector2(0, 3), 22.0, 11.0)
		FurnitureType.WATER_BOWL:
			shadow_pts = _make_iso_ellipse(Vector2(0, 3), 22.0, 11.0)
		FurnitureType.LITTER_BOX:
			shadow_pts = _make_iso_ellipse(Vector2(0, 4), 32.0, 16.0)
		_:
			shadow_pts = _make_iso_ellipse(Vector2(0, 3), 20.0, 10.0)

func _draw() -> void:
	# Luôn vẽ bóng đổ mềm mại dưới chân đồ nội thất
	if shadow_pts.size() > 0:
		draw_colored_polygon(shadow_pts, Color(0.15, 0.1, 0.08, 0.18))
		
	# Nếu không có sprite texture -> vẽ dự phòng procedural
	if not sprite_node or not sprite_node.texture:
		match furniture_type:
			FurnitureType.CUSHION_BED:
				draw_colored_polygon(_make_iso_ellipse(Vector2(0, 0), 30.0, 15.0), Color(0.85, 0.65, 0.50, 1.0))
			FurnitureType.FOOD_BOWL:
				draw_colored_polygon(_make_iso_ellipse(Vector2(0, 0), 20.0, 10.0), Color(0.40, 0.65, 0.85, 1.0))
			FurnitureType.WATER_BOWL:
				draw_colored_polygon(_make_iso_ellipse(Vector2(0, 0), 20.0, 10.0), Color(0.35, 0.75, 0.55, 1.0))
			FurnitureType.LITTER_BOX:
				draw_colored_polygon(_make_iso_ellipse(Vector2(0, 0), 28.0, 14.0), Color(0.85, 0.75, 0.60, 1.0))

func _make_iso_ellipse(center: Vector2, rx: float, ry: float, segments: int = 24) -> PackedVector2Array:
	var pts = PackedVector2Array()
	for i in range(segments):
		var theta = float(i) / float(segments) * TAU
		var x = center.x + cos(theta) * rx
		var y = center.y + sin(theta) * ry
		pts.append(Vector2(x, y))
	return pts

## Hiệu ứng tương tác nảy (Juicy Squash & Stretch) khi bấm vào đồ nội thất
func play_click_reaction() -> void:
	if not sprite_node:
		return
	var orig_scale = sprite_node.scale
	var tween = create_tween()
	tween.tween_property(sprite_node, "scale", orig_scale * Vector2(1.18, 0.85), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite_node, "scale", orig_scale * Vector2(0.92, 1.12), 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite_node, "scale", orig_scale, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = to_local(event.position)
		if local_pos.length_squared() < 1600.0: # Bán kính chạm ~40px
			play_click_reaction()
			emit_signal("item_clicked", furniture_type)
