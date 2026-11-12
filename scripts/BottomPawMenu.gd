extends Control

# BottomPawMenu.gd - Menu thanh công cụ bục gỗ mộc mạc ToffeeCraft chuẩn GDD
# Gồm DockPanel bục kệ gỗ, 5 nút TextureButton với icon pixel 24x24 & paw print footprint,
# SubDrawer ngăn kéo gỗ retro với các ItemSlot 32x32 hiển thị số lượng pixel,
# và hiệu ứng trượt Tween cubic mượt mà kết hợp âm thanh gõ gỗ lách cách (wooden pop).

signal go_home_requested
signal open_skill_tree_requested
signal open_handbook_requested
signal open_museum_requested
signal open_shop_requested(initial_category)
signal start_lesson_requested(lesson_id)
signal open_decor_studio_requested
signal action_food_selected(food_type)
signal action_play_selected(play_type)
signal action_drawer_opened(drawer_type)
signal action_drawer_closed

@onready var btn_home: BaseButton = $DockPanel/HBox/BtnHome
@onready var btn_food: BaseButton = $DockPanel/HBox/BtnFood
@onready var icon_food_rect: TextureRect = $DockPanel/HBox/BtnFood/VBox.get_node_or_null("Icon")
@onready var btn_play: BaseButton = $DockPanel/HBox/BtnPlay
@onready var icon_play_rect: TextureRect = $DockPanel/HBox/BtnPlay/VBox.get_node_or_null("Icon")
@onready var btn_learn: BaseButton = $DockPanel/HBox/BtnLearn
@onready var btn_handbook: BaseButton = $DockPanel/HBox/BtnHandbook
@onready var dock_panel: Control = $DockPanel
@onready var hbox: HBoxContainer = $DockPanel/HBox
@onready var sliding_paw_indicator: TextureRect = $DockPanel.get_node_or_null("SlidingPawIndicator")

@onready var sub_drawer: Control = $SubDrawer
@onready var drawer_title: Label = $SubDrawer/VBox/Header/TitleLabel
@onready var drawer_content: GridContainer = $SubDrawer/VBox/ContentGrid
@onready var btn_close_drawer: BaseButton = $SubDrawer/VBox/Header/BtnCloseDrawer

const FONT_PIXEL = preload("res://assets/font/SVN-Retron 2000.ttf")
const TEX_BTN_NORM = preload("res://assets/UI/CatUIPaid/slices/toffee_bottom_menu/btn_dock_normal.tres")
const TEX_BTN_PRESS = preload("res://assets/UI/CatUIPaid/slices/toffee_bottom_menu/btn_dock_pressed.tres")
const TEX_ITEM_SLOT = preload("res://assets/UI/CatUIPaid/slices/toffee_bottom_menu/item_slot_32x32_9patch.tres")

var current_drawer_type: String = ""
var current_active_tab: String = "room"
var drawer_tween: Tween
var _paw_slide_tween: Tween
var _icon_base_y: Dictionary = {}

const DOCK_HEIGHT_DP: float = 64.0
const DRAWER_OPEN_Y: float = -224.0
const DRAWER_CLOSED_Y: float = -20.0

func _ready() -> void:
	if icon_food_rect:
		var food_tex = GameManager.load_texture("res://assets/UI/CatUIPaid/slices/toffee_bottom_menu/icon_nav_food_24x24.tres")
		if food_tex:
			icon_food_rect.texture = food_tex

	if icon_play_rect:
		var toy_tex = GameManager.load_texture("res://assets/UI/CatUIPaid/slices/toffee_bottom_menu/icon_nav_play_24x24.tres")
		if toy_tex:
			icon_play_rect.texture = toy_tex
			
	sub_drawer.visible = false
	sub_drawer.position.y = DRAWER_CLOSED_Y
	btn_close_drawer.pressed.connect(close_drawer)
	
	btn_home.pressed.connect(func():
		_animate_button(btn_home)
		close_drawer()
		emit_signal("open_decor_studio_requested")
	)
	
	btn_food.pressed.connect(func():
		_animate_button(btn_food)
		_toggle_drawer("food")
	)
	
	btn_play.pressed.connect(func():
		_animate_button(btn_play)
		_toggle_drawer("play")
	)
	
	btn_learn.pressed.connect(func():
		_animate_button(btn_learn)
		close_drawer()
		emit_signal("open_skill_tree_requested")
	)
	
	btn_handbook.pressed.connect(func():
		_animate_button(btn_handbook)
		close_drawer()
		emit_signal("open_handbook_requested")
	)
	
	resized.connect(func(): call_deferred("_sync_sliding_paw_pos", false))
	set_active_tab("room")
	call_deferred("_sync_sliding_paw_pos", false)

func _animate_button(btn: Control) -> void:
	var bg: NinePatchRect = btn.get_node_or_null("BtnBg")
	var icon_node: Control = btn.get_node_or_null("VBox/Icon")
	var tw = create_tween().set_parallel(true)
	if bg:
		bg.texture = TEX_BTN_PRESS
		bg.position.y = 2.0
		tw.tween_property(bg, "position:y", 0.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if icon_node:
		var bid = btn.get_instance_id()
		if not _icon_base_y.has(bid):
			_icon_base_y[bid] = icon_node.position.y
		var base_y: float = _icon_base_y[bid]
		icon_node.position.y = base_y
		var icon_tw = create_tween()
		icon_tw.tween_property(icon_node, "position:y", base_y - 4.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		icon_tw.tween_property(icon_node, "position:y", base_y, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	SoundManager.play_wooden_pop()

func _get_tab_button_map() -> Dictionary:
	return {
		"room": btn_home,
		"food": btn_food,
		"play": btn_play,
		"learn": btn_learn,
		"handbook": btn_handbook
	}

func _sync_sliding_paw_pos(animate: bool = true) -> void:
	if not sliding_paw_indicator or not dock_panel:
		return
	var btn: Control = _get_tab_button_map().get(current_active_tab)
	if btn == null or not btn.visible:
		sliding_paw_indicator.visible = false
		return
	sliding_paw_indicator.visible = true
	var target_x: float = (btn.global_position.x - dock_panel.global_position.x) + (btn.size.x - sliding_paw_indicator.size.x) * 0.5
	if not animate or not is_inside_tree():
		sliding_paw_indicator.position.x = target_x
		return
	if _paw_slide_tween and _paw_slide_tween.is_valid():
		_paw_slide_tween.kill()
	_paw_slide_tween = create_tween()
	_paw_slide_tween.tween_property(sliding_paw_indicator, "position:x", target_x, 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func set_active_tab(tab_name: String) -> void:
	if tab_name in ["room", "food", "play", "learn", "handbook"]:
		current_active_tab = tab_name
		
	var all_btns = _get_tab_button_map()
	
	for key in all_btns.keys():
		var btn = all_btns[key]
		if btn == null: continue
		var is_active = (key == tab_name)
		var paw: TextureRect = btn.get_node_or_null("PawIndicator")
		var bg: NinePatchRect = btn.get_node_or_null("BtnBg")
		
		if is_active:
			if bg:
				bg.texture = TEX_BTN_PRESS
				bg.self_modulate = Color(1.0, 0.96, 0.88, 1.0)
			if paw:
				paw.visible = (sliding_paw_indicator == null)
		else:
			if bg:
				bg.texture = TEX_BTN_NORM
				bg.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
			if paw:
				paw.visible = false
	call_deferred("_sync_sliding_paw_pos", true)

func set_view_mode(mode: String) -> void:
	close_drawer()
	if mode == "skill_tree":
		# Chế độ bản đồ: chỉ hiển thị nút Cẩm Nang ô vuông góc phải dưới
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn_home.visible = false
		btn_food.visible = false
		btn_play.visible = false
		btn_learn.visible = false
		btn_handbook.visible = true
		
		if dock_panel:
			dock_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			dock_panel.self_modulate.a = 0.0
		if hbox:
			hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
			hbox.alignment = BoxContainer.ALIGNMENT_END
			
		btn_handbook.mouse_filter = Control.MOUSE_FILTER_STOP
		btn_handbook.custom_minimum_size = Vector2(60, 56)
		btn_handbook.size_flags_horizontal = Control.SIZE_SHRINK_END
	elif mode == "handbook":
		# Chế độ cẩm nang: nút Học Kỹ Năng ở góc phải dưới
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn_home.visible = false
		btn_food.visible = false
		btn_play.visible = false
		btn_learn.visible = true
		btn_handbook.visible = false
		
		if dock_panel:
			dock_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
			dock_panel.self_modulate.a = 0.0
		if hbox:
			hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
			hbox.alignment = BoxContainer.ALIGNMENT_END
			
		btn_learn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn_learn.custom_minimum_size = Vector2(60, 56)
		btn_learn.size_flags_horizontal = Control.SIZE_SHRINK_END
	else: # "room"
		mouse_filter = Control.MOUSE_FILTER_PASS
		if dock_panel:
			dock_panel.mouse_filter = Control.MOUSE_FILTER_STOP
			dock_panel.self_modulate.a = 1.0
		if hbox:
			hbox.mouse_filter = Control.MOUSE_FILTER_PASS
			hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			
		btn_home.visible = true
		btn_food.visible = true
		btn_play.visible = true
		btn_learn.visible = true
		btn_handbook.visible = true
		btn_home.custom_minimum_size = Vector2(76, 56)
		btn_food.custom_minimum_size = Vector2(76, 56)
		btn_play.custom_minimum_size = Vector2(76, 56)
		btn_learn.custom_minimum_size = Vector2(76, 56)
		btn_handbook.custom_minimum_size = Vector2(76, 56)
		btn_home.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_food.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_play.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_learn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_handbook.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		set_active_tab("room")

func set_compact_handbook_only_mode(enable: bool) -> void:
	if enable:
		set_view_mode("skill_tree")
	else:
		set_view_mode("room")

# =========================================================================
# SUBDRAWER: TRƯỢT TWEEN CUBIC & ÂM THANH GÕ GỖ
# =========================================================================
func _toggle_drawer(drawer_type: String) -> void:
	if sub_drawer.visible and current_drawer_type == drawer_type:
		close_drawer()
		return
	
	SoundManager.play_wooden_pop()
	emit_signal("action_drawer_opened", drawer_type)
	current_drawer_type = drawer_type
	_build_drawer_content(drawer_type)
	set_active_tab(drawer_type)
	
	sub_drawer.visible = true
	
	if drawer_tween and drawer_tween.is_valid():
		drawer_tween.kill()
		
	sub_drawer.position.y = DRAWER_CLOSED_Y
	sub_drawer.modulate.a = 0.2
	
	drawer_tween = create_tween().set_parallel(true)
	drawer_tween.tween_property(sub_drawer, "position:y", DRAWER_OPEN_Y, 0.26).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	drawer_tween.tween_property(sub_drawer, "modulate:a", 1.0, 0.20).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func close_drawer() -> void:
	if not sub_drawer.visible:
		set_active_tab(current_active_tab)
		return
		
	SoundManager.play_wooden_pop()
	emit_signal("action_drawer_closed")
	
	if drawer_tween and drawer_tween.is_valid():
		drawer_tween.kill()
		
	drawer_tween = create_tween().set_parallel(true)
	drawer_tween.tween_property(sub_drawer, "position:y", DRAWER_CLOSED_Y, 0.20).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	drawer_tween.tween_property(sub_drawer, "modulate:a", 0.0, 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	drawer_tween.chain().tween_callback(func():
		sub_drawer.visible = false
		current_drawer_type = ""
		set_active_tab(current_active_tab)
	)

# =========================================================================
# XÂY DỰNG NỘI DUNG NGĂN KÉO VỚI ITEM SLOT 32x32 PIXEL
# =========================================================================
func _build_drawer_content(type: String) -> void:
	for c in drawer_content.get_children():
		c.queue_free()
		
	if type == "food":
		drawer_title.text = "🍲 GÓC ĂN UỐNG & CHĂM SÓC BOSS"
		
		var kibble_qty = GameManager.get_food_count("kibble")
		var pate_qty = GameManager.get_food_count("pate")
		var dry_fish_qty = GameManager.get_food_count("dry_fish")
		var has_any_food = false
		
		# 1. Hạt sinh viên
		if kibble_qty > 0:
			has_any_food = true
			var slot_kibble = _create_item_slot(
				"Túi Hạt",
				"x%d" % kibble_qty,
				"res://assets/UI/CatUIPaid/slices/icon_cat_food_bag.png",
				func():
					emit_signal("action_food_selected", "kibble")
					close_drawer()
			)
			var kibble_btn: Control = slot_kibble.find_child("SlotBtn", true, false)
			if kibble_btn:
				var bag_tex: Texture2D = GameManager.load_texture("res://assets/UI/CatUIPaid/slices/icon_cat_food_bag.png")
				kibble_btn.set_drag_forwarding(
					func(_at_pos: Vector2):
						if bag_tex:
							var prev := TextureRect.new()
							prev.texture = bag_tex
							prev.custom_minimum_size = Vector2(38, 48)
							prev.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
							prev.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
							prev.position = -prev.custom_minimum_size * 0.5
							kibble_btn.set_drag_preview(prev)
						close_drawer()
						return {"type": "food_bag", "food_type": "kibble"},
					func(_at_pos: Vector2, _data): return false,
					func(_at_pos: Vector2, _data): pass
				)
			drawer_content.add_child(slot_kibble)
		
		# 2. Pate thượng hạng
		if pate_qty > 0:
			has_any_food = true
			var slot_pate = _create_item_slot(
				"Pate Xịn",
				"x%d" % pate_qty,
				"res://assets/sprites/room_items/canned_pate.png",
				func():
					emit_signal("action_food_selected", "pate")
					close_drawer()
			)
			drawer_content.add_child(slot_pate)
		
		# 3. Nước sạch mát lành
		var slot_water = _create_item_slot(
			"Nước Mát",
			"∞",
			"res://assets/sprites/room_items/water_bowl_clean.png",
			func():
				emit_signal("action_food_selected", "water")
				close_drawer()
		)
		drawer_content.add_child(slot_water)
		
		# 4. Cá khô quê gửi
		if dry_fish_qty > 0:
			has_any_food = true
			var slot_dry_fish = _create_item_slot(
				"Cá Khô",
				"x%d" % dry_fish_qty,
				"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/CatToys/fish.png",
				func():
					emit_signal("action_food_selected", "dry_fish")
					close_drawer()
			)
			drawer_content.add_child(slot_dry_fish)
			
		# Nếu hết thức ăn khô/pate, thêm ô ghé tiệm
		if not has_any_food:
			var slot_shop = _create_item_slot(
				"Mua Thêm",
				"Tiệm",
				"res://assets/UI/CatUIPaid/slices/toffee_hud/btn_shop_normal.tres",
				func():
					close_drawer()
					emit_signal("open_shop_requested", "food")
			)
			drawer_content.add_child(slot_shop)
		
	elif type == "play":
		drawer_title.text = "🧶 GÓC ĐỒ CHƠI & GIẢI TRÍ BOSS"
		
		# 1. Cuộn Len Tinh Nghịch
		var slot_yarn = _create_item_slot(
			"Cuộn Len",
			"x1",
			"res://assets/UI/CatUIPaid/slices/toffee_bottom_menu/icon_nav_play_24x24.tres",
			func():
				emit_signal("action_play_selected", "yarn_ball")
				close_drawer()
		)
		drawer_content.add_child(slot_yarn)
		
		# 2. Vuốt Ve & Gãi Cằm
		var slot_pet = _create_item_slot(
			"Gãi Cằm",
			"∞",
			"res://assets/UI/CatUIPaid/slices/toffee_bottom_menu/paw_indicator_selected.tres",
			func():
				emit_signal("action_play_selected", "pet")
				close_drawer()
		)
		drawer_content.add_child(slot_pet)
		
		# 3. Hộp carton
		var slot_box = _create_item_slot(
			"Hộp Giấy",
			"x1",
			"res://assets/sprites/room_items/cardboard_box.png",
			func():
				emit_signal("action_play_selected", "box")
				close_drawer()
		)
		drawer_content.add_child(slot_box)
		
		# 4. Cần câu lông vũ
		if GameManager.inventory_decor.has("toy_feather") or GameManager.inventory_decor.has("d_toy_feather"):
			var slot_feather = _create_item_slot(
				"Cần Câu",
				"x1",
				"res://assets/sprites/room_items/feather_wand.png",
				func():
					emit_signal("action_play_selected", "feather")
					close_drawer()
			)
			drawer_content.add_child(slot_feather)

	elif type == "learn":
		drawer_title.text = "🎓 HỌC KỸ NĂNG TỰ LẬP"
		
		var next_lesson_id = 1
		for id in range(1, 17):
			if id in GameManager.unlocked_lessons and not (id in GameManager.completed_lessons):
				next_lesson_id = id
				break
				
		var slot_start = _create_item_slot(
			"Bài %d" % next_lesson_id,
			"Học",
			"res://assets/UI/CatUIPaid/slices/toffee_bottom_menu/icon_nav_learn_24x24.tres",
			func():
				close_drawer()
				emit_signal("start_lesson_requested", next_lesson_id)
		)
		drawer_content.add_child(slot_start)
		
		var slot_tree = _create_item_slot(
			"Bản Đồ",
			"16 Bài",
			"res://assets/UI/CatUIPaid/slices/toffee_bottom_menu/icon_nav_home_24x24.tres",
			func():
				close_drawer()
				emit_signal("open_skill_tree_requested")
		)
		drawer_content.add_child(slot_tree)
		
		var slot_achieve = _create_item_slot(
			"Thành Tựu",
			"Cúp ⭐",
			"res://assets/UI/CatUIPaid/slices/toffee_hud/level_ribbon_badge.tres",
			func():
				close_drawer()
				GameManager.emit_signal("open_achievements_requested")
		)
		drawer_content.add_child(slot_achieve)
		
		var slot_hb = _create_item_slot(
			"Sổ Tay",
			"Bí Kíp",
			"res://assets/UI/CatUIPaid/slices/toffee_bottom_menu/icon_nav_handbook_24x24.tres",
			func():
				close_drawer()
				emit_signal("open_handbook_requested")
		)
		drawer_content.add_child(slot_hb)

	elif type == "handbook":
		drawer_title.text = "📖 CẨM NANG CỨU SEN BỎ TÚI"
		
		var slot_bus = _create_item_slot(
			"Xe Buýt",
			"Bus 08",
			"res://assets/UI/CatUIPaid/slices/toffee_bottom_menu/icon_nav_home_24x24.tres",
			func():
				close_drawer()
				emit_signal("start_lesson_requested", 1)
		)
		drawer_content.add_child(slot_bus)
		
		var slot_rent = _create_item_slot(
			"Thuê Trọ",
			"PCCC",
			"res://assets/UI/CatUIPaid/slices/toffee_bottom_menu/icon_nav_learn_24x24.tres",
			func():
				close_drawer()
				emit_signal("start_lesson_requested", 5)
		)
		drawer_content.add_child(slot_rent)
		
		var slot_med = _create_item_slot(
			"BHYT",
			"Y Tế",
			"res://assets/UI/CatUIPaid/slices/toffee_bottom_menu/icon_nav_handbook_24x24.tres",
			func():
				close_drawer()
				emit_signal("start_lesson_requested", 10)
		)
		drawer_content.add_child(slot_med)
		
		var slot_all = _create_item_slot(
			"Toàn Bộ",
			"16 Bí Kíp",
			"res://assets/UI/CatUIPaid/slices/toffee_bottom_menu/icon_nav_handbook_24x24.tres",
			func():
				close_drawer()
				emit_signal("open_handbook_requested")
		)
		drawer_content.add_child(slot_all)

# =========================================================================
# TẠO Ô ITEM SLOT 32x32 CHUẨN RETRO VỚI NHÃN SỐ LƯỢNG GÓC DƯỚI PHẢI
# =========================================================================
func _create_item_slot(title: String, qty_text: String, icon_path_or_tex, on_click: Callable, accent_color: Color = Color("#3A2010")) -> Control:
	var slot_container = VBoxContainer.new()
	slot_container.custom_minimum_size = Vector2(110, 74)
	slot_container.alignment = BoxContainer.ALIGNMENT_CENTER
	slot_container.add_theme_constant_override("separation", 4)
	
	# 1. Khung ô 32x32 pixel slot
	var frame_box = Control.new()
	frame_box.custom_minimum_size = Vector2(42, 42)
	frame_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	frame_box.pivot_offset = Vector2(21, 21)
	
	var slot_bg = NinePatchRect.new()
	slot_bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	slot_bg.texture = TEX_ITEM_SLOT
	slot_bg.patch_margin_left = 6
	slot_bg.patch_margin_top = 6
	slot_bg.patch_margin_right = 6
	slot_bg.patch_margin_bottom = 6
	slot_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	slot_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame_box.add_child(slot_bg)
	
	var btn = TextureButton.new()
	btn.name = "SlotBtn"
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	frame_box.add_child(btn)
	
	var icon_rect = TextureRect.new()
	icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon_rect.custom_minimum_size = Vector2(24, 24)
	icon_rect.set_anchors_preset(Control.PRESET_CENTER)
	icon_rect.offset_left = -12.0
	icon_rect.offset_top = -12.0
	icon_rect.offset_right = 12.0
	icon_rect.offset_bottom = 12.0
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	var tex: Texture2D = null
	if icon_path_or_tex is Texture2D:
		tex = icon_path_or_tex
	elif icon_path_or_tex is String and icon_path_or_tex != "":
		tex = GameManager.load_texture(icon_path_or_tex)
	if tex:
		icon_rect.texture = tex
	frame_box.add_child(icon_rect)
	
	# 2. Nhãn số lượng pixel ở góc dưới phải mỗi ô
	if qty_text != "":
		var qty_lbl = Label.new()
		qty_lbl.text = qty_text
		qty_lbl.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		qty_lbl.add_theme_font_override("font", FONT_PIXEL)
		qty_lbl.add_theme_font_size_override("font_size", 9)
		qty_lbl.add_theme_color_override("font_color", Color(1.0, 0.95, 0.82, 1.0))
		qty_lbl.add_theme_color_override("font_outline_color", Color(0.18, 0.09, 0.04, 1.0))
		qty_lbl.add_theme_constant_override("outline_size", 2)
		qty_lbl.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		qty_lbl.offset_left = -26.0
		qty_lbl.offset_top = -14.0
		qty_lbl.offset_right = -3.0
		qty_lbl.offset_bottom = -2.0
		qty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		qty_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		frame_box.add_child(qty_lbl)
		
	slot_container.add_child(frame_box)
	
	# 3. Nhãn tên vật phẩm bên dưới ô
	var name_lbl = Label.new()
	name_lbl.text = title
	name_lbl.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_lbl.add_theme_font_override("font", FONT_PIXEL)
	name_lbl.add_theme_font_size_override("font_size", 10)
	name_lbl.add_theme_color_override("font_color", accent_color)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot_container.add_child(name_lbl)
	
	btn.pressed.connect(func():
		var tw = create_tween()
		tw.tween_property(frame_box, "scale", Vector2(0.88, 0.88), 0.05).set_trans(Tween.TRANS_QUAD)
		tw.tween_property(frame_box, "scale", Vector2(1.0, 1.0), 0.07).set_trans(Tween.TRANS_BACK)
		SoundManager.play_wooden_pop()
		on_click.call()
	)
	
	return slot_container

# Backwards compatibility helper
func _create_action_card(title: String, subtitle: String, accent_color: Color, on_click: Callable, icon_path: String = "") -> Control:
	return _create_item_slot(title, "x1", icon_path, on_click, accent_color)
