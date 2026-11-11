extends Control

# RoomDecorStudioView.gd - Màn hình Thiết Kế & Trang Trí Phòng Trọ Isometric
# Chuẩn phong cách Decorator Game: Vòng tròn công cụ Gizmo (❌, 🔄, ✔), kéo thả đồ tự do,
# Zoom slider, thanh tài nguyên, và khay cuộn ngang phân loại nội thất.

signal back_to_room_requested

const ITEM_CARD_SIZE = Vector2(96, 128)
const GIZMO_RADIUS = 68.0

# Nodes
@onready var room_container: Control = $RoomViewportArea/RoomContainer
@onready var room_bg_rect: TextureRect = $RoomViewportArea/RoomContainer/RoomBg
@onready var furniture_layer: Node2D = $RoomViewportArea/RoomContainer/FurnitureLayer
@onready var gizmo_overlay: Node2D = $RoomViewportArea/RoomContainer/GizmoOverlay
@onready var floor_touch_catcher: Control = $RoomViewportArea/RoomContainer/FloorTouchCatcher

# Top Bar Nodes
@onready var btn_back: Button = $TopBar/HBox/BtnBack
@onready var lbl_mood_val: Label = $TopBar/HBox/ResourceRow/MoodBox/HBox/LblMood
@onready var lbl_gold_val: Label = $TopBar/HBox/ResourceRow/GoldBox/HBox/LblGold
@onready var lbl_fish_val: Label = $TopBar/HBox/ResourceRow/FishBox/HBox/LblFish
@onready var btn_save: Button = $TopBar/HBox/BtnSave
@onready var btn_clear: Button = $TopBar/HBox/BtnClear
@onready var btn_preset: Button = $TopBar/HBox.get_node_or_null("BtnPreset")

# Zoom Slider Nodes
@onready var zoom_slider: VSlider = $LeftPanel/ZoomSlider
@onready var lbl_zoom_val: Label = $LeftPanel/LblZoomVal

# Top Decor Drawer Nodes (Phần đồ trang trí chuyển lên trên cùng)
@onready var decor_drawer: PanelContainer = get_node_or_null("DecorDrawer") if has_node("DecorDrawer") else get_node_or_null("BottomDrawer")
@onready var tab_all: Button = decor_drawer.get_node("VBox/TabsContainer/HBox/BtnTabAll")
@onready var tab_furniture: Button = decor_drawer.get_node("VBox/TabsContainer/HBox/BtnTabFurniture")
@onready var tab_decor: Button = decor_drawer.get_node("VBox/TabsContainer/HBox/BtnTabDecor")
@onready var tab_cat: Button = decor_drawer.get_node("VBox/TabsContainer/HBox/BtnTabCat")
@onready var tab_wallpaper: Button = decor_drawer.get_node("VBox/TabsContainer/HBox/BtnTabWallpaper")
@onready var items_scroll: ScrollContainer = decor_drawer.get_node("VBox/ItemsScroll")
@onready var items_hbox: HBoxContainer = decor_drawer.get_node("VBox/ItemsScroll/ItemsHBox")

# State
var current_category: String = "all"
var selected_item_node: Node2D = null
var is_dragging_item: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var current_zoom: float = 1.0

# Gizmo Controls
var gizmo_btn_cancel: Button = null
var gizmo_btn_rotate: Button = null
var gizmo_btn_confirm: Button = null

# Danh mục vật phẩm decor toàn diện
var catalog_items: Array = [
	# 🛋️ NỘI THẤT (FURNITURE)
	{"id": "d_cushion_bed", "name": "Đệm Nhung Terracotta", "cat": "furniture", "icon": "🛏️", "sprite": "res://assets/sprites/room_items/cushion_bed.png", "stars": 4, "is_new": true},
	{"id": "d_cushion_bed_blue", "name": "Đệm Tròn Xanh Dương", "cat": "furniture", "icon": "🛏️", "sprite": "res://assets/sprites/room_items/cushion_bed_blue.png", "stars": 4, "is_new": false},
	{"id": "d_cushion_bed_green", "name": "Đệm Nỉ Xanh Rêu", "cat": "furniture", "icon": "🛏️", "sprite": "res://assets/sprites/room_items/cushion_bed_green.png", "stars": 4, "is_new": false},
	{"id": "d_cat_bed_pink", "name": "Nệm Công Chúa Hồng", "cat": "furniture", "icon": "👑", "sprite": "res://assets/sprites/room_items/cat_bed_pink_iso.png", "stars": 5, "is_new": true},
	{"id": "d_bed_box", "name": "Hộp Carton KTX", "cat": "furniture", "icon": "📦", "sprite": "res://assets/sprites/room_items/cat_box_new.png", "stars": 3, "is_new": false},
	{"id": "d_single_home", "name": "Nhà Gỗ Mèo Mini", "cat": "furniture", "icon": "🏠", "sprite": "res://assets/sprites/room_items/single_cat_home.png", "stars": 4, "is_new": false},
	{"id": "d_bookshelf", "name": "Kệ Sách Sinh Viên", "cat": "furniture", "icon": "📚", "sprite": "res://assets/sprites/room_items/bookshelf.png", "stars": 4, "is_new": false},
	{"id": "d_scratch_post", "name": "Trụ Cào Sisal Tự Nhiên", "cat": "furniture", "icon": "🪵", "sprite": "res://assets/sprites/room_items/scratch_post.png", "stars": 4, "is_new": false},
	{"id": "d_cat_ladder", "name": "Thang Leo Vận Động", "cat": "furniture", "icon": "🪜", "sprite": "res://assets/sprites/room_items/cat_gym_ladder.png", "stars": 5, "is_new": true},
	
	# 🖼️ TRANG TRÍ (DECOR)
	{"id": "d_potted_monstera", "name": "Cây Trầu Bà Monstera", "cat": "decor", "icon": "🪴", "sprite": "res://assets/sprites/room_items/potted_monstera.png", "stars": 4, "is_new": true},
	{"id": "d_bonsai_pot", "name": "Chậu Cây Bonsai Để Sàn", "cat": "decor", "icon": "🌳", "sprite": "res://assets/sprites/room_items/bonsai_pot.png", "stars": 5, "is_new": false},
	{"id": "d_potted_ficus_blue", "name": "Chậu Ficus Men Xanh", "cat": "decor", "icon": "🌿", "sprite": "res://assets/sprites/room_items/potted_ficus_blue.png", "stars": 4, "is_new": false},
	{"id": "d_potted_plant", "name": "Chậu Thường Xuân", "cat": "decor", "icon": "🌱", "sprite": "res://assets/sprites/room_items/potted_plant.png", "stars": 3, "is_new": false},
	{"id": "d_rug_boho", "name": "Thảm Len Boho Dệt Tay", "cat": "decor", "icon": "🧶", "sprite": "res://assets/sprites/room_items/rug_boho.png", "stars": 4, "is_new": false},
	{"id": "d_wall_art", "name": "Tranh Trừu Tượng Canvas", "cat": "decor", "icon": "🖼️", "sprite": "res://assets/sprites/room_items/wall_art.png", "stars": 4, "is_new": false},
	{"id": "d_wall_cactus", "name": "Tranh Xương Rồng Kiên Cường", "cat": "decor", "icon": "🌵", "sprite": "res://assets/sprites/room_items/wall_cactus_poster.png", "stars": 3, "is_new": false},
	{"id": "d_window_curtains", "name": "Cửa Sổ Rèm Vải Pastel", "cat": "decor", "icon": "🪟", "sprite": "res://assets/sprites/room_items/window_curtains.png", "stars": 5, "is_new": true},
	
	# 🥣 ĐỒ CHO MÈO (CAT ITEMS)
	{"id": "d_food_bowl_clean", "name": "Chén Ăn Sứ Màu Pastel", "cat": "cat_items", "icon": "🥣", "sprite": "res://assets/sprites/room_items/food_bowl_clean.png", "stars": 4, "is_new": false},
	{"id": "d_water_bowl_clean", "name": "Chén Nước Mát Lành", "cat": "cat_items", "icon": "💧", "sprite": "res://assets/sprites/room_items/water_bowl_clean.png", "stars": 4, "is_new": false},
	{"id": "d_dual_bowl", "name": "Khay Ăn Đôi Tự Động", "cat": "cat_items", "icon": "🍽️", "sprite": "res://assets/sprites/room_items/dual_bowl_pair.png", "stars": 5, "is_new": true},
	{"id": "d_water_fountain", "name": "Đài Phun Nước Tuần Hoàn", "cat": "cat_items", "icon": "⛲", "sprite": "res://assets/sprites/room_items/water_fountain.png", "stars": 5, "is_new": true},
	{"id": "d_litter_box", "name": "Chậu Cát Vệ Sinh Khử Mùi", "cat": "cat_items", "icon": "🐾", "sprite": "res://assets/sprites/room_items/litter_box.png", "stars": 5, "is_new": true},
	{"id": "d_cat_food_bag", "name": "Túi Hạt Dinh Dưỡng", "cat": "cat_items", "icon": "🛍️", "sprite": "res://assets/sprites/room_items/cat_food_bag.png", "stars": 3, "is_new": false},
	{"id": "d_toy_yarn_ball", "name": "Cuộn Len Tinh Nghịch", "cat": "cat_items", "icon": "🧶", "sprite": "res://assets/sprites/room_items/toy_yarn_ball.png", "stars": 3, "is_new": false}
]

func _ready() -> void:
	_setup_ui_styles()
	_setup_top_bar()
	_setup_zoom_slider()
	_setup_category_tabs()
	_setup_gizmo()
	
	# Cập nhật hình nền phòng hiện tại
	_update_room_background()
	GameManager.classic_bg_changed.connect(func(_id): _update_room_background())
	
	# Nạp các đồ nội thất đã lưu
	_load_existing_decorations()
	
	# Render danh mục thẻ đồ dưới đáy
	_render_catalog_drawer()
	
	# Kết nối sự kiện chạm sàn di chuyển đồ đang chọn
	floor_touch_catcher.gui_input.connect(_on_floor_gui_input)

func _setup_ui_styles() -> void:
	room_container.pivot_offset = Vector2(270, 480)

func _setup_top_bar() -> void:
	btn_back.pressed.connect(func():
		SoundManager.play_click()
		emit_signal("back_to_room_requested")
	)
	
	btn_save.pressed.connect(_on_save_pressed)
	btn_clear.pressed.connect(_on_clear_pressed)
	if btn_preset:
		btn_preset.pressed.connect(_on_preset_pressed)
	
	# Cập nhật tài nguyên
	_update_resource_displays()
	GameManager.stats_changed.connect(_update_resource_displays)

func _update_resource_displays() -> void:
	lbl_mood_val.text = "%d/100" % GameManager.mood
	lbl_gold_val.text = GameManager.format_currency(GameManager.fish)
	lbl_fish_val.text = "%d" % int(GameManager.courage * 10)

func _setup_zoom_slider() -> void:
	zoom_slider.min_value = 80.0
	zoom_slider.max_value = 140.0
	zoom_slider.value = 100.0
	lbl_zoom_val.text = "100%"
	
	zoom_slider.value_changed.connect(func(val):
		current_zoom = val / 100.0
		lbl_zoom_val.text = "%d%%" % int(val)
		room_container.scale = Vector2(current_zoom, current_zoom)
	)

func _setup_category_tabs() -> void:
	tab_all.pressed.connect(func(): _switch_category("all"))
	tab_furniture.pressed.connect(func(): _switch_category("furniture"))
	tab_decor.pressed.connect(func(): _switch_category("decor"))
	tab_cat.pressed.connect(func(): _switch_category("cat_items"))
	tab_wallpaper.pressed.connect(func(): _switch_category("wallpaper"))
	_switch_category("all")

func _switch_category(cat: String) -> void:
	current_category = cat
	var all_tabs = {
		"all": tab_all,
		"furniture": tab_furniture,
		"decor": tab_decor,
		"cat_items": tab_cat,
		"wallpaper": tab_wallpaper
	}
	
	for k in all_tabs.keys():
		var btn: Button = all_tabs[k]
		if btn == null: continue
		if k == cat:
			btn.modulate = Color(1.0, 1.0, 1.0)
		else:
			btn.modulate = Color(0.72, 0.72, 0.72)
			
	_render_catalog_drawer()

func _update_room_background() -> void:
	var bg_id = GameManager.selected_classic_bg_id
	var path = "res://assets/furnitures/PetMobileGameAsset/PetMobileGameAsset/Backgrounds/Classic/%d.png" % bg_id
	room_bg_rect.texture = GameManager.load_texture(path)

# ==============================================================================
# HỆ THỐNG GIZMO VÒNG TRÒN ĐIỀU KHIỂN (SELECTION RING GIZMO)
# ==============================================================================
func _setup_gizmo() -> void:
	gizmo_overlay.visible = false
	gizmo_overlay.z_index = 100
	
	# 1. Nút Cancel ❌ (Bên trái vòng tròn)
	gizmo_btn_cancel = _create_gizmo_circle_button("✖", Color(0.9, 0.3, 0.3), Vector2(-GIZMO_RADIUS * 0.95, GIZMO_RADIUS * 0.3))
	gizmo_btn_cancel.pressed.connect(_on_gizmo_cancel_pressed)
	gizmo_overlay.add_child(gizmo_btn_cancel)
	
	# 2. Nút Rotate / Flip 🔄 (Đỉnh trên cùng)
	gizmo_btn_rotate = _create_gizmo_circle_button("🔄", Color(0.45, 0.45, 0.5), Vector2(0, -GIZMO_RADIUS))
	gizmo_btn_rotate.pressed.connect(_on_gizmo_rotate_pressed)
	gizmo_overlay.add_child(gizmo_btn_rotate)
	
	# 3. Nút Confirm ✔ (Bên phải vòng tròn)
	gizmo_btn_confirm = _create_gizmo_circle_button("✔", Color(0.25, 0.75, 0.4), Vector2(GIZMO_RADIUS * 0.95, GIZMO_RADIUS * 0.3))
	gizmo_btn_confirm.pressed.connect(_on_gizmo_confirm_pressed)
	gizmo_overlay.add_child(gizmo_btn_confirm)

func _create_gizmo_circle_button(text_symbol: String, bg_color: Color, offset: Vector2) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(34, 34)
	btn.position = offset - Vector2(17, 17)
	btn.text = text_symbol
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.add_theme_font_size_override("font_size", 14)
	btn.add_theme_color_override("font_color", Color.WHITE)
	
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.set_corner_radius_all(17)
	style.border_color = Color(1.0, 1.0, 1.0, 0.9)
	style.set_border_width_all(2)
	style.shadow_color = Color(0, 0, 0, 0.25)
	style.shadow_size = 4
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	return btn

func _select_item(item_node: Node2D) -> void:
	selected_item_node = item_node
	if selected_item_node == null:
		gizmo_overlay.visible = false
		return
		
	gizmo_overlay.visible = true
	gizmo_overlay.position = selected_item_node.position
	gizmo_overlay.queue_redraw()
	SoundManager.play_click()

func _process(_delta: float) -> void:
	if is_dragging_item and selected_item_node:
		var mouse_pos = room_container.get_local_mouse_position()
		# Giới hạn trong vùng sàn và tường phòng
		var clamped_x = clampf(mouse_pos.x + drag_offset.x, 70.0, 470.0)
		var clamped_y = clampf(mouse_pos.y + drag_offset.y, 450.0, 820.0)
		selected_item_node.position = Vector2(clamped_x, clamped_y)
		gizmo_overlay.position = selected_item_node.position
		gizmo_overlay.queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed and is_dragging_item:
				is_dragging_item = false

func _on_floor_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if selected_item_node:
			var mouse_pos = room_container.get_local_mouse_position()
			if mouse_pos.y >= 420.0 and mouse_pos.y <= 830.0:
				selected_item_node.position = mouse_pos
				gizmo_overlay.position = mouse_pos
				gizmo_overlay.queue_redraw()

func _on_gizmo_confirm_pressed() -> void:
	if selected_item_node:
		SoundManager.play_click()
		var tween = create_tween()
		tween.tween_property(selected_item_node, "scale", selected_item_node.scale * 1.1, 0.06)
		tween.tween_property(selected_item_node, "scale", selected_item_node.scale, 0.06)
	selected_item_node = null
	gizmo_overlay.visible = false
	_render_catalog_drawer()

func _on_gizmo_rotate_pressed() -> void:
	if selected_item_node:
		SoundManager.play_click()
		selected_item_node.scale.x *= -1.0
		var tween = create_tween()
		tween.tween_property(selected_item_node, "scale:y", 1.15, 0.07)
		tween.tween_property(selected_item_node, "scale:y", 1.0, 0.07)

func _on_gizmo_cancel_pressed() -> void:
	if selected_item_node:
		SoundManager.play_pop()
		selected_item_node.queue_free()
		selected_item_node = null
		gizmo_overlay.visible = false
		_render_catalog_drawer()

# ==============================================================================
# QUẢN LÝ CÁC MÓN ĐỒ TRONG PHÒNG (FURNITURE INSTANCES)
# ==============================================================================
func _load_existing_decorations() -> void:
	for child in furniture_layer.get_children():
		child.queue_free()
		
	var placed = GameManager.get_placed_decor()
	if placed.size() == 0:
		# Tạo 4 món đồ cơ bản ban đầu nếu chưa trang trí
		_add_decor_instance("d_cushion_bed", Vector2(100.0, 760.0), false)
		_add_decor_instance("d_food_bowl_clean", Vector2(210.0, 810.0), false)
		_add_decor_instance("d_water_bowl_clean", Vector2(280.0, 810.0), false)
		_add_decor_instance("d_litter_box", Vector2(430.0, 790.0), false)
	else:
		for d in placed:
			var item_id = d.get("id", "")
			var px = float(d.get("pos_x", 270.0))
			var py = float(d.get("pos_y", 620.0))
			var flipped = bool(d.get("flipped", false))
			_add_decor_instance(item_id, Vector2(px, py), flipped)

func _add_decor_instance(item_id: String, pos: Vector2, flipped: bool) -> Node2D:
	var node = Node2D.new()
	node.position = pos
	node.scale = Vector2(-1.0 if flipped else 1.0, 1.0)
	node.set_meta("item_id", item_id)
	
	# Sprite
	var spr = Sprite2D.new()
	var path = GameManager.get_furniture_sprite_path(item_id)
	if path == "":
		for cat_it in catalog_items:
			if cat_it["id"] == item_id:
				path = cat_it["sprite"]
				break
				
	if path != "":
		spr.texture = GameManager.load_texture(path)
	spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	spr.position = Vector2(0, -spr.texture.get_height() * 0.4 if spr.texture else 0)
	node.add_child(spr)
	
	# Touch area để chọn đồ
	var touch_area = Control.new()
	touch_area.custom_minimum_size = Vector2(70, 70)
	touch_area.position = Vector2(-35, -55)
	touch_area.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	touch_area.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
			if ev.pressed:
				_select_item(node)
				is_dragging_item = true
				drag_offset = node.position - room_container.get_local_mouse_position()
			else:
				is_dragging_item = false
	)
	node.add_child(touch_area)
	
	furniture_layer.add_child(node)
	return node

func _is_item_currently_placed(item_id: String) -> bool:
	for child in furniture_layer.get_children():
		if child.has_meta("item_id") and child.get_meta("item_id") == item_id:
			return true
	return false

func _find_placed_node(item_id: String) -> Node2D:
	for child in furniture_layer.get_children():
		if child.has_meta("item_id") and child.get_meta("item_id") == item_id:
			return child
	return null

# ==============================================================================
# RENDER KHAY DANH MỤC THẺ CUỘN NGANG Ở ĐÁY (DECOR DRAWER)
# ==============================================================================
func _render_catalog_drawer() -> void:
	for child in items_hbox.get_children():
		child.queue_free()
		
	if current_category == "wallpaper":
		_render_wallpaper_cards()
		return
		
	for item in catalog_items:
		if current_category != "all" and item["cat"] != current_category:
			continue
		var card = _create_catalog_item_card(item)
		items_hbox.add_child(card)

func _create_catalog_item_card(item: Dictionary) -> Control:
	var item_id = item["id"]
	var is_placed = _is_item_currently_placed(item_id)
	
	var card = Button.new()
	card.custom_minimum_size = ITEM_CARD_SIZE
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# Style thẻ trắng be viền cam nhẹ chuẩn CatUI
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.985, 0.96, 1.0)
	style.border_color = Color(0.92, 0.75, 0.60, 1.0) if not is_placed else Color(0.80, 0.76, 0.72, 0.8)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	
	var hover = style.duplicate()
	hover.border_color = Color(0.95, 0.50, 0.20, 1.0)
	hover.bg_color = Color(1.0, 0.95, 0.90, 1.0)
	
	card.add_theme_stylebox_override("normal", style)
	card.add_theme_stylebox_override("hover", hover)
	card.add_theme_stylebox_override("pressed", hover)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 3)
	card.add_child(vbox)
	
	# Badge số lượng 1/1 hoặc 0/1 góc trên
	var badge_hbox = HBoxContainer.new()
	badge_hbox.alignment = BoxContainer.ALIGNMENT_END
	vbox.add_child(badge_hbox)
	
	if item.get("is_new", false):
		var new_lbl = Label.new()
		new_lbl.text = "NEW"
		new_lbl.add_theme_font_size_override("font_size", 8)
		new_lbl.add_theme_color_override("font_color", Color(0.95, 0.25, 0.25))
		badge_hbox.add_child(new_lbl)
		
	var qty_lbl = Label.new()
	qty_lbl.text = "0/1" if is_placed else "1/1"
	qty_lbl.add_theme_font_size_override("font_size", 9)
	qty_lbl.add_theme_color_override("font_color", Color(0.6, 0.55, 0.5) if is_placed else Color(0.85, 0.35, 0.2))
	badge_hbox.add_child(qty_lbl)
	
	# Icon Sprite
	var icon_rect = TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(44, 44)
	icon_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon_rect.texture = GameManager.load_texture(item["sprite"])
	vbox.add_child(icon_rect)
	
	# Tên món đồ
	var name_lbl = Label.new()
	name_lbl.text = item["name"]
	name_lbl.add_theme_font_size_override("font_size", 9)
	name_lbl.add_theme_color_override("font_color", Color(0.3, 0.22, 0.16))
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	vbox.add_child(name_lbl)
	
	# Hàng 4 trái tim nhỏ
	var hearts_lbl = Label.new()
	hearts_lbl.text = "❤️❤️❤️❤️"
	hearts_lbl.add_theme_font_size_override("font_size", 8)
	hearts_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hearts_lbl)
	
	# Click vào thẻ:
	card.pressed.connect(func():
		SoundManager.play_click()
		if is_placed:
			# Tìm node và kích hoạt Gizmo
			var existing = _find_placed_node(item_id)
			if existing:
				_select_item(existing)
		else:
			# Tạo mới ngay giữa phòng và chọn
			var new_node = _add_decor_instance(item_id, Vector2(270.0, 620.0), false)
			_select_item(new_node)
			_render_catalog_drawer()
	)
	
	return card

func _render_wallpaper_cards() -> void:
	for i in range(1, 21):
		var bg_card = Button.new()
		bg_card.custom_minimum_size = ITEM_CARD_SIZE
		bg_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var vbox = VBoxContainer.new()
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		bg_card.add_child(vbox)
		
		var preview_rect = TextureRect.new()
		preview_rect.custom_minimum_size = Vector2(50, 50)
		preview_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		preview_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		var bg_path = "res://assets/furnitures/PetMobileGameAsset/PetMobileGameAsset/Backgrounds/Classic/%d.png" % i
		if ResourceLoader.exists(bg_path):
			preview_rect.texture = load(bg_path)
		vbox.add_child(preview_rect)
		
		var lbl = Label.new()
		lbl.text = "Sàn & Tường %d" % i
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(lbl)
		
		var bg_id = i
		bg_card.pressed.connect(func():
			SoundManager.play_click()
			GameManager.set_classic_bg(bg_id)
			_update_room_background()
			GameManager.emit_signal("show_toast", "🎨 Đã đổi giấy dán tường & gạch sàn phòng!")
		)
		items_hbox.add_child(bg_card)

# ==============================================================================
# NÚT LƯU & DỌN DẸP PHÒNG
# ==============================================================================
func _on_save_pressed() -> void:
	SoundManager.play_success()
	var decor_list: Array = []
	for child in furniture_layer.get_children():
		if child.has_meta("item_id"):
			decor_list.append({
				"id": child.get_meta("item_id"),
				"pos_x": child.position.x,
				"pos_y": child.position.y,
				"flipped": (child.scale.x < 0)
			})
			
	GameManager.save_placed_decor(decor_list)
	GameManager.emit_signal("show_toast", "🏡 Đã lưu cách bài trí căn phòng của Boss thành công!")
	
	# Tắt Gizmo
	selected_item_node = null
	gizmo_overlay.visible = false

func _on_clear_pressed() -> void:
	SoundManager.play_pop()
	for child in furniture_layer.get_children():
		child.queue_free()
	selected_item_node = null
	gizmo_overlay.visible = false
	_render_catalog_drawer()
	GameManager.emit_signal("show_toast", "🔄 Đã thu hồi toàn bộ đồ nội thất về kho!")

# ==============================================================================
# HỆ THỐNG MẪU BÀI TRÍ PHÒNG GỢI Ý (COZY LIVING PRESETS)
# ==============================================================================
const ROOM_PRESETS = [
	{
		"name": "KTX Sinh Viên Ấm Cúng",
		"tag": "Gợi Ý Cho Bạn Mới Đến",
		"desc": "Không gian sinh viên tiện ích: kệ sách học tập, cây Monstera & đệm nhung êm ái.",
		"bg_id": 1,
		"icon": "🎓",
		"items": [
			{"id": "d_cushion_bed", "pos": Vector2(110.0, 750.0), "flipped": false},
			{"id": "d_bookshelf", "pos": Vector2(125.0, 580.0), "flipped": false},
			{"id": "d_rug_boho", "pos": Vector2(270.0, 710.0), "flipped": false},
			{"id": "d_potted_monstera", "pos": Vector2(420.0, 580.0), "flipped": false},
			{"id": "d_dual_bowl", "pos": Vector2(370.0, 780.0), "flipped": false},
			{"id": "d_litter_box", "pos": Vector2(440.0, 800.0), "flipped": false}
		]
	},
	{
		"name": "Thiên Đường Mèo Cào",
		"tag": "Năng Động & Thư Giãn",
		"desc": "Thiết kế thể thao: thang leo tường, trụ cào Sisal, nệm hồng & đài phun nước tuần hoàn.",
		"bg_id": 3,
		"icon": "🐾",
		"items": [
			{"id": "d_cat_bed_pink", "pos": Vector2(120.0, 760.0), "flipped": false},
			{"id": "d_cat_ladder", "pos": Vector2(110.0, 570.0), "flipped": false},
			{"id": "d_scratch_post", "pos": Vector2(230.0, 680.0), "flipped": false},
			{"id": "d_water_fountain", "pos": Vector2(350.0, 770.0), "flipped": false},
			{"id": "d_food_bowl_clean", "pos": Vector2(420.0, 790.0), "flipped": false},
			{"id": "d_toy_yarn_ball", "pos": Vector2(270.0, 780.0), "flipped": false}
		]
	},
	{
		"name": "Studio Tối Giản Chill",
		"tag": "Japandi Thư Thái",
		"desc": "Phong cách Zen tĩnh lặng: đệm xanh rêu, chậu cây Bonsai & tranh trừu tượng canvas.",
		"bg_id": 5,
		"icon": "🌿",
		"items": [
			{"id": "d_cushion_bed_green", "pos": Vector2(120.0, 740.0), "flipped": false},
			{"id": "d_bonsai_pot", "pos": Vector2(420.0, 600.0), "flipped": false},
			{"id": "d_wall_art", "pos": Vector2(270.0, 480.0), "flipped": false},
			{"id": "d_single_home", "pos": Vector2(380.0, 740.0), "flipped": false},
			{"id": "d_water_bowl_clean", "pos": Vector2(250.0, 790.0), "flipped": false},
			{"id": "d_food_bowl_clean", "pos": Vector2(190.0, 790.0), "flipped": false}
		]
	}
]

var active_preset_modal: Control = null

func _on_preset_pressed() -> void:
	SoundManager.play_menu_open()
	_open_preset_modal()

func _open_preset_modal() -> void:
	if active_preset_modal and is_instance_valid(active_preset_modal):
		active_preset_modal.queue_free()
		active_preset_modal = null

	var overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	active_preset_modal = overlay
	add_child(overlay)

	# Nền làm mờ tối
	var dark_bg = ColorRect.new()
	dark_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	dark_bg.color = Color(0, 0, 0, 0.52)
	dark_bg.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_close_preset_modal()
	)
	overlay.add_child(dark_bg)

	# Panel modal chính giữa
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(460, 520)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.pivot_offset = Vector2(230, 260)

	var pstyle = StyleBoxFlat.new()
	pstyle.bg_color = Color(1.0, 0.985, 0.96, 1.0)
	pstyle.border_color = Color(0.85, 0.72, 0.60, 1.0)
	pstyle.set_border_width_all(2)
	pstyle.set_corner_radius_all(18)
	pstyle.shadow_color = Color(0, 0, 0, 0.3)
	pstyle.shadow_size = 14
	pstyle.shadow_offset = Vector2(0, 6)
	pstyle.content_margin_left = 18
	pstyle.content_margin_right = 18
	pstyle.content_margin_top = 16
	pstyle.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", pstyle)
	overlay.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# Header: Title + Close Button
	var head_hbox = HBoxContainer.new()
	vbox.add_child(head_hbox)

	var title_vbox = VBoxContainer.new()
	title_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_hbox.add_child(title_vbox)

	var title_lbl = Label.new()
	title_lbl.text = "✨ MẪU BÀI TRÍ PHÒNG KTX"
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color(0.24, 0.16, 0.10))
	title_vbox.add_child(title_lbl)

	var sub_lbl = Label.new()
	sub_lbl.text = "Chọn 1 phong cách không gian được thiết kế sẵn cho Boss"
	sub_lbl.add_theme_font_size_override("font_size", 10)
	sub_lbl.add_theme_color_override("font_color", Color(0.55, 0.45, 0.38))
	title_vbox.add_child(sub_lbl)

	var btn_close = Button.new()
	btn_close.custom_minimum_size = Vector2(30, 30)
	btn_close.text = "✖"
	btn_close.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var cstyle = StyleBoxFlat.new()
	cstyle.bg_color = Color(0.9, 0.35, 0.35)
	cstyle.set_corner_radius_all(15)
	btn_close.add_theme_stylebox_override("normal", cstyle)
	btn_close.add_theme_stylebox_override("hover", cstyle)
	btn_close.add_theme_stylebox_override("pressed", cstyle)
	btn_close.pressed.connect(_close_preset_modal)
	head_hbox.add_child(btn_close)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	# Danh sách 3 preset cards
	for i in range(ROOM_PRESETS.size()):
		var p_data = ROOM_PRESETS[i]
		var card = _create_preset_card(p_data, i)
		vbox.add_child(card)

	# Hiệu ứng phóng to modal nhẹ nhàng
	panel.scale = Vector2(0.92, 0.92)
	var tw = create_tween()
	tw.tween_property(panel, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _create_preset_card(p_data: Dictionary, idx: int) -> Control:
	var cpanel = PanelContainer.new()
	var cstyle = StyleBoxFlat.new()
	cstyle.bg_color = Color(1.0, 1.0, 1.0, 0.95)
	cstyle.border_color = Color(0.90, 0.82, 0.74, 1.0)
	cstyle.set_border_width_all(1)
	cstyle.border_width_bottom = 2
	cstyle.set_corner_radius_all(12)
	cstyle.content_margin_left = 12
	cstyle.content_margin_right = 12
	cstyle.content_margin_top = 10
	cstyle.content_margin_bottom = 10
	cpanel.add_theme_stylebox_override("panel", cstyle)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	cpanel.add_child(hbox)

	# Icon
	var icon_box = PanelContainer.new()
	icon_box.custom_minimum_size = Vector2(48, 48)
	var istyle = StyleBoxFlat.new()
	istyle.bg_color = Color(0.98, 0.92, 0.86)
	istyle.set_corner_radius_all(10)
	icon_box.add_theme_stylebox_override("panel", istyle)
	var ilbl = Label.new()
	ilbl.text = p_data.get("icon", "🏡")
	ilbl.add_theme_font_size_override("font_size", 22)
	ilbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ilbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_box.add_child(ilbl)
	hbox.add_child(icon_box)

	# Text info
	var info_vbox = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 2)
	hbox.add_child(info_vbox)

	var name_lbl = Label.new()
	name_lbl.text = p_data["name"]
	name_lbl.add_theme_font_size_override("font_size", 12)
	name_lbl.add_theme_color_override("font_color", Color(0.24, 0.16, 0.10))
	info_vbox.add_child(name_lbl)

	var tag_lbl = Label.new()
	tag_lbl.text = "🏷️ %s" % p_data.get("tag", "Tiêu Chuẩn")
	tag_lbl.add_theme_font_size_override("font_size", 9)
	tag_lbl.add_theme_color_override("font_color", Color(0.92, 0.45, 0.20))
	info_vbox.add_child(tag_lbl)

	var desc_lbl = Label.new()
	desc_lbl.text = p_data["desc"]
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 9)
	desc_lbl.add_theme_color_override("font_color", Color(0.52, 0.44, 0.38))
	info_vbox.add_child(desc_lbl)

	# Apply button
	var btn_apply = Button.new()
	btn_apply.text = "Áp Dụng ✨"
	btn_apply.custom_minimum_size = Vector2(86, 36)
	btn_apply.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn_apply.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var bstyle = StyleBoxFlat.new()
	bstyle.bg_color = Color(0.92, 0.45, 0.38, 1.0)
	bstyle.border_color = Color(0.78, 0.32, 0.26, 1.0)
	bstyle.set_border_width_all(1)
	bstyle.border_width_bottom = 2
	bstyle.set_corner_radius_all(10)
	bstyle.content_margin_left = 8
	bstyle.content_margin_right = 8
	btn_apply.add_theme_stylebox_override("normal", bstyle)
	btn_apply.add_theme_stylebox_override("hover", bstyle)
	btn_apply.add_theme_stylebox_override("pressed", bstyle)
	btn_apply.add_theme_font_size_override("font_size", 11)

	btn_apply.pressed.connect(func():
		_apply_preset(idx)
		_close_preset_modal()
	)
	hbox.add_child(btn_apply)

	return cpanel

func _close_preset_modal() -> void:
	if active_preset_modal and is_instance_valid(active_preset_modal):
		SoundManager.play_menu_close()
		active_preset_modal.queue_free()
		active_preset_modal = null

func _apply_preset(preset_idx: int) -> void:
	if preset_idx < 0 or preset_idx >= ROOM_PRESETS.size():
		return
	var preset = ROOM_PRESETS[preset_idx]

	# Xóa đồ hiện tại
	for child in furniture_layer.get_children():
		child.queue_free()
	selected_item_node = null
	gizmo_overlay.visible = false

	# Đổi hình nền theo preset
	GameManager.set_classic_bg(preset["bg_id"])
	_update_room_background()

	# Thêm từng món đồ với hoạt ảnh nảy drop-in
	for it in preset["items"]:
		var node = _add_decor_instance(it["id"], it["pos"], it["flipped"])
		node.scale = Vector2.ZERO
		var target_x = -1.0 if it["flipped"] else 1.0
		var tw = create_tween()
		tw.tween_property(node, "scale", Vector2(target_x * 1.15, 1.15), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(node, "scale", Vector2(target_x, 1.0), 0.1)

	SoundManager.play_confirm()
	_render_catalog_drawer()
	GameManager.emit_signal("show_toast", "✨ Đã trang hoàng theo mẫu [%s]!" % preset["name"])
