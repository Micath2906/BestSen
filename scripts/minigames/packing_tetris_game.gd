extends Control

# PACKING TETRIS GAME (XẾP VALI HÀNH TRANG 4 TÚI RIÊNG BIỆT)
# Cơ chế Inventory Grid Tetris: Mỗi vật phẩm có khối ô (1x1, 1x2, 2x2, 1x3, L-shape, Z-shape)
# Người chơi kéo thả vào lưới, có thể xoay 90 độ, xếp vừa khít chiếc vali!

signal minigame_completed(result: Dictionary)

const CELL_SIZE = 40 # px per grid cell

var current_bag_index: int = 0
var bags_data = [
	{
		"id": "clothes",
		"name": "Quần Áo & Đồ Vải",
		"icon": "👕",
		"grid_cols": 6,
		"grid_rows": 5,
		"color": Color("#D97706"),
		"bg_color": Color("#FFF8F0"),
		"border_color": Color("#B45309"),
		"items": [
			{"id": "hoodie", "name": "Áo Hoodie Dày", "shape": [[1, 1], [1, 1]], "tex": "res://assets/sprites/minigames/tetris/tetris_hoodie_2x2.png", "color": Color("#E07A5F")},
			{"id": "jeans", "name": "Quần Jean Cuộn", "shape": [[1], [1], [1]], "tex": "res://assets/sprites/minigames/tetris/tetris_jeans_1x3.png", "color": Color("#3D5A80")},
			{"id": "tshirt", "name": "Áo Thun Gấp", "shape": [[1, 1]], "tex": "res://assets/sprites/minigames/tetris/tetris_tshirt_2x1.png", "color": Color("#81B29A")},
			{"id": "towel", "name": "Khăn Bông Tắm", "shape": [[1], [1]], "tex": "res://assets/sprites/minigames/tetris/tetris_towel_1x2.png", "color": Color("#F2CC8F")},
			{"id": "socks", "name": "Tất & Phụ Kiện", "shape": [[1]], "tex": "res://assets/sprites/minigames/tetris/tetris_socks_1x1.png", "color": Color("#DDA15E")},
			{"id": "coat_l", "name": "Áo Khoác Phao", "shape": [[1, 0], [1, 1]], "tex": "res://assets/sprites/minigames/tetris/tetris_coat_L3.png", "color": Color("#9C6644")}
		]
	},
	{
		"id": "docs",
		"name": "Bìa Hồ Sơ Chống Nước",
		"icon": "📁",
		"grid_cols": 5,
		"grid_rows": 5,
		"color": Color("#2563EB"),
		"bg_color": Color("#F0F7FF"),
		"border_color": Color("#1D4ED8"),
		"items": [
			{"id": "doc_a4", "name": "Bìa Hồ Sơ A4", "shape": [[1, 1], [1, 1], [1, 1]], "tex": "res://assets/sprites/minigames/tetris/tetris_doc_a4_2x3.png", "color": Color("#FAF0CA")},
			{"id": "diploma", "name": "Bằng Tốt Nghiệp", "shape": [[1, 1], [1, 1]], "tex": "res://assets/sprites/minigames/tetris/tetris_diploma_2x2.png", "color": Color("#C1121F")},
			{"id": "id_card", "name": "Ví Thẻ CCCD/BHYT", "shape": [[1]], "tex": "res://assets/sprites/minigames/tetris/tetris_id_card_1x1.png", "color": Color("#F4D35E")},
			{"id": "notebook", "name": "Sổ Đoàn Viên", "shape": [[1], [1]], "tex": "res://assets/sprites/minigames/tetris/tetris_notebook_1x2.png", "color": Color("#588157")},
			{"id": "pen", "name": "Bút Ký Nhập Học", "shape": [[1]], "tex": "res://assets/sprites/minigames/tetris/tetris_pen_1x1.png", "color": Color("#3A86FF")}
		]
	},
	{
		"id": "meds",
		"name": "Hộp Thuốc Cấp Cứu",
		"icon": "💊",
		"grid_cols": 4,
		"grid_rows": 5,
		"color": Color("#059669"),
		"bg_color": Color("#ECFDF5"),
		"border_color": Color("#047857"),
		"items": [
			{"id": "para500", "name": "Paracetamol 500mg", "shape": [[1, 1]], "tex": "res://assets/sprites/minigames/tetris/tetris_para500_2x1.png", "color": Color("#E63946")},
			{"id": "spray", "name": "Chai Cồn Xịt", "shape": [[1], [1]], "tex": "res://assets/sprites/minigames/tetris/tetris_spray_1x2.png", "color": Color("#457B9D")},
			{"id": "oresol", "name": "Gói Bù Nước Oresol", "shape": [[1]], "tex": "res://assets/sprites/minigames/tetris/tetris_oresol_1x1.png", "color": Color("#FB8500")},
			{"id": "urgo", "name": "Hộp Urgo Băng Keo", "shape": [[1]], "tex": "res://assets/sprites/minigames/tetris/tetris_urgo_1x1.png", "color": Color("#FFB4A2")},
			{"id": "thermo", "name": "Nhiệt Kế Điện Tử", "shape": [[1], [1]], "tex": "res://assets/sprites/minigames/tetris/tetris_thermo_1x2.png", "color": Color("#E0FBFC")},
			{"id": "gauze", "name": "Cuộn Băng Gạc Y Tế", "shape": [[1, 0], [1, 1]], "tex": "res://assets/sprites/minigames/tetris/tetris_gauze_L3.png", "color": Color("#FFFFFF")}
		]
	},
	{
		"id": "tech",
		"name": "Balo Chống Sốc Công Nghệ",
		"icon": "💻",
		"grid_cols": 6,
		"grid_rows": 5,
		"color": Color("#7C3AED"),
		"bg_color": Color("#F5F3FF"),
		"border_color": Color("#6D28D9"),
		"items": [
			{"id": "laptop", "name": "Laptop Sinh Viên", "shape": [[1, 1, 1], [1, 1, 1]], "tex": "res://assets/sprites/minigames/tetris/tetris_laptop_3x2.png", "color": Color("#4A4E69")},
			{"id": "powerstrip", "name": "Ổ Cắm Chia Điện", "shape": [[1], [1], [1]], "tex": "res://assets/sprites/minigames/tetris/tetris_powerstrip_1x3.png", "color": Color("#FFFFFF")},
			{"id": "headphone", "name": "Tai Nghe Học Tập", "shape": [[1], [1]], "tex": "res://assets/sprites/minigames/tetris/tetris_headphone_1x2.png", "color": Color("#E76F51")},
			{"id": "mouse", "name": "Chuột Máy Tính", "shape": [[1]], "tex": "res://assets/sprites/minigames/tetris/tetris_mouse_1x1.png", "color": Color("#6D6875")},
			{"id": "charger", "name": "Củ & Dây Sạc Nhanh", "shape": [[1, 0], [1, 1]], "tex": "res://assets/sprites/minigames/tetris/tetris_charger_L3.png", "color": Color("#FFB703")}
		]
	}
]

# Grid state: 2D array of strings (item id or "")
var grid_cells: Array = []
var placed_items: Dictionary = {} # item_id -> {pos: Vector2i, shape: Array}
var selected_item_data: Dictionary = {}
var selected_item_rotated_shape: Array = []

# UI references
var grid_container: Control
var tray_container: HBoxContainer
var tabs_container: HBoxContainer
var lbl_bag_title: Label
var lbl_status: Label
var btn_rotate: Button
var btn_clear_bag: Button
var btn_finish_bag: Button

func _ready() -> void:
	_build_ui()
	_load_bag(0)

func _build_ui() -> void:
	# Background
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#FFFDF9") # Warm parchment
	add_child(bg)

	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.set("theme_override_constants/separation", 8)
	add_child(main_vbox)

	# 1. Header Bar
	var header = PanelContainer.new()
	header.custom_minimum_size = Vector2(0, 50)
	var header_sb = StyleBoxFlat.new()
	header_sb.bg_color = Color("#8D5B36")
	header_sb.content_margin_left = 12
	header_sb.content_margin_right = 12
	header_sb.content_margin_top = 6
	header_sb.content_margin_bottom = 6
	header.add_theme_stylebox_override("panel", header_sb)
	main_vbox.add_child(header)

	var header_hbox = HBoxContainer.new()
	header.add_child(header_hbox)

	var btn_back = Button.new()
	btn_back.name = "BtnBack"
	btn_back.text = "⬅ QUAY LẠI"
	btn_back.custom_minimum_size = Vector2(85, 34)
	btn_back.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_back.pressed.connect(_on_back_pressed)
	header_hbox.add_child(btn_back)

	var title_lbl = Label.new()
	title_lbl.text = "🧳 XẾP VALI HÀNH TRANG (TETRIS PACKING)"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", Color.WHITE)
	header_hbox.add_child(title_lbl)

	# 2. Bag Switcher Tabs (4 Bags)
	tabs_container = HBoxContainer.new()
	tabs_container.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs_container.set("theme_override_constants/separation", 6)
	main_vbox.add_child(tabs_container)

	for i in range(bags_data.size()):
		var b_data = bags_data[i]
		var tab_btn = Button.new()
		tab_btn.text = b_data.icon + " " + b_data.name
		tab_btn.custom_minimum_size = Vector2(120, 36)
		tab_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tab_btn.add_theme_font_size_override("font_size", 10)
		var b_idx = i
		tab_btn.pressed.connect(func(): _load_bag(b_idx))
		tabs_container.add_child(tab_btn)

	# 3. Bag Title & Instructions Banner
	var banner = PanelContainer.new()
	var banner_sb = StyleBoxFlat.new()
	banner_sb.bg_color = Color("#FFF8F0")
	banner_sb.border_color = Color("#8D5B36")
	banner_sb.set_border_width_all(2)
	banner_sb.set_corner_radius_all(8)
	banner_sb.content_margin_left = 12
	banner_sb.content_margin_right = 12
	banner_sb.content_margin_top = 6
	banner_sb.content_margin_bottom = 6
	banner.add_theme_stylebox_override("panel", banner_sb)
	main_vbox.add_child(banner)

	var banner_hbox = HBoxContainer.new()
	banner.add_child(banner_hbox)

	lbl_bag_title = Label.new()
	lbl_bag_title.text = "Quần Áo & Đồ Vải"
	lbl_bag_title.add_theme_font_size_override("font_size", 12)
	lbl_bag_title.add_theme_color_override("font_color", Color("#4A2E1B"))
	lbl_bag_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	banner_hbox.add_child(lbl_bag_title)

	lbl_status = Label.new()
	lbl_status.text = "Đã xếp: 0 / 6 món"
	lbl_status.add_theme_font_size_override("font_size", 11)
	lbl_status.add_theme_color_override("font_color", Color("#B45309"))
	banner_hbox.add_child(lbl_status)

	# 4. Bag Center Viewport & Grid Area
	var grid_scroll = ScrollContainer.new()
	grid_scroll.custom_minimum_size = Vector2(0, 320)
	grid_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(grid_scroll)

	var center_box = CenterContainer.new()
	center_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid_scroll.add_child(center_box)

	var bag_leather_frame = PanelContainer.new()
	bag_leather_frame.name = "BagLeatherFrame"
	center_box.add_child(bag_leather_frame)

	grid_container = Control.new()
	grid_container.name = "GridContainer"
	bag_leather_frame.add_child(grid_container)

	# 5. Controls toolbar: Rotate & Clear
	var tools_hbox = HBoxContainer.new()
	tools_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	tools_hbox.set("theme_override_constants/separation", 10)
	main_vbox.add_child(tools_hbox)

	btn_rotate = Button.new()
	btn_rotate.text = "🔄 XOAY VẬT PHẨM (90°)"
	btn_rotate.custom_minimum_size = Vector2(160, 34)
	btn_rotate.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_rotate.pressed.connect(_on_rotate_pressed)
	tools_hbox.add_child(btn_rotate)

	btn_clear_bag = Button.new()
	btn_clear_bag.text = "🗑 LẤY HẾT ĐỒ RA"
	btn_clear_bag.custom_minimum_size = Vector2(140, 34)
	btn_clear_bag.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_clear_bag.pressed.connect(_on_clear_bag_pressed)
	tools_hbox.add_child(btn_clear_bag)

	btn_finish_bag = Button.new()
	btn_finish_bag.text = "✨ KHÓA KÉO TÚI NÀY"
	btn_finish_bag.custom_minimum_size = Vector2(150, 34)
	btn_finish_bag.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_finish_bag.pressed.connect(_on_finish_bag_pressed)
	tools_hbox.add_child(btn_finish_bag)

	# 6. Bottom Item Tray (Khay đồ vật Tetris)
	var tray_panel = PanelContainer.new()
	tray_panel.custom_minimum_size = Vector2(0, 160)
	var tray_sb = StyleBoxFlat.new()
	tray_sb.bg_color = Color("#FFFDF9")
	tray_sb.border_color = Color("#8D5B36")
	tray_sb.set_border_width_all(2)
	tray_sb.border_width_top = 4
	tray_sb.content_margin_left = 10
	tray_sb.content_margin_right = 10
	tray_sb.content_margin_top = 8
	tray_sb.content_margin_bottom = 8
	tray_panel.add_theme_stylebox_override("panel", tray_sb)
	main_vbox.add_child(tray_panel)

	var tray_scroll = ScrollContainer.new()
	tray_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tray_panel.add_child(tray_scroll)

	tray_container = HBoxContainer.new()
	tray_container.set("theme_override_constants/separation", 10)
	tray_scroll.add_child(tray_container)

func _load_bag(index: int) -> void:
	current_bag_index = index
	var bag = bags_data[index]
	
	# Update Title & Tabs style
	lbl_bag_title.text = bag.icon + " " + bag.name + " (" + str(bag.grid_cols) + "x" + str(bag.grid_rows) + " ô lưới)"
	for i in range(tabs_container.get_child_count()):
		var btn = tabs_container.get_child(i) as Button
		if i == index:
			btn.modulate = Color(1.2, 1.2, 1.0)
		else:
			btn.modulate = Color(0.85, 0.85, 0.85)

	# Initialize Grid
	var cols = bag.grid_cols
	var rows = bag.grid_rows
	grid_cells.clear()
	placed_items.clear()
	selected_item_data.clear()

	for r in range(rows):
		var row_arr = []
		for c in range(cols):
			row_arr.append("")
		grid_cells.append(row_arr)

	# Resize GridContainer
	var total_w = cols * CELL_SIZE
	var total_h = rows * CELL_SIZE
	grid_container.custom_minimum_size = Vector2(total_w, total_h)
	
	# Style leather bag frame
	var bag_frame = grid_container.get_parent() as PanelContainer
	var sb = StyleBoxFlat.new()
	sb.bg_color = bag.bg_color
	sb.border_color = bag.border_color
	sb.set_border_width_all(4)
	sb.border_width_bottom = 6
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 12
	sb.content_margin_top = 12
	sb.content_margin_right = 12
	sb.content_margin_bottom = 12
	sb.shadow_size = 8
	sb.shadow_color = Color(0, 0, 0, 0.15)
	bag_frame.add_theme_stylebox_override("panel", sb)

	_render_grid()
	_populate_tray()
	_update_status()

func _render_grid() -> void:
	for child in grid_container.get_children():
		child.queue_free()

	var bag = bags_data[current_bag_index]
	var cols = bag.grid_cols
	var rows = bag.grid_rows

	# 1. Background Grid Cells
	for r in range(rows):
		for c in range(cols):
			var cell_rect = TextureRect.new()
			cell_rect.texture = GameManager.load_texture("res://assets/sprites/minigames/tetris/grid_cell.png")
			cell_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			cell_rect.size = Vector2(CELL_SIZE, CELL_SIZE)
			cell_rect.position = Vector2(c * CELL_SIZE, r * CELL_SIZE)
			cell_rect.modulate = Color(1, 1, 1, 0.7)
			grid_container.add_child(cell_rect)

			# Click to place or remove
			var hit_btn = Button.new()
			hit_btn.flat = true
			hit_btn.size = Vector2(CELL_SIZE, CELL_SIZE)
			hit_btn.position = cell_rect.position
			var cell_r = r
			var cell_c = c
			hit_btn.pressed.connect(func(): _on_cell_clicked(cell_c, cell_r))
			grid_container.add_child(hit_btn)

	# 2. Render Placed Items
	for item_id in placed_items:
		var item_info = placed_items[item_id]
		var item_meta = _find_item_meta(item_id)
		if item_meta.is_empty():
			continue

		var pos = item_info.pos
		var shape = item_info.shape
		var item_node = Control.new()
		item_node.name = "Placed_" + item_id
		item_node.position = Vector2(pos.x * CELL_SIZE, pos.y * CELL_SIZE)

		for r in range(shape.size()):
			for c in range(shape[r].size()):
				if shape[r][c] == 1:
					var block_panel = Panel.new()
					block_panel.size = Vector2(CELL_SIZE - 2, CELL_SIZE - 2)
					block_panel.position = Vector2(c * CELL_SIZE + 1, r * CELL_SIZE + 1)
					var blk_sb = StyleBoxFlat.new()
					blk_sb.bg_color = item_meta.color
					blk_sb.border_color = item_meta.color.darkened(0.3)
					blk_sb.set_border_width_all(2)
					blk_sb.set_corner_radius_all(4)
					block_panel.add_theme_stylebox_override("panel", blk_sb)
					item_node.add_child(block_panel)

		# Label on top left
		var lbl = Label.new()
		lbl.text = item_meta.name
		lbl.position = Vector2(4, 2)
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		item_node.add_child(lbl)

		# Click placed item to remove back to tray
		var remove_btn = Button.new()
		remove_btn.flat = true
		remove_btn.size = Vector2(shape[0].size() * CELL_SIZE, shape.size() * CELL_SIZE)
		remove_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		remove_btn.pressed.connect(func(): _remove_placed_item(item_id))
		item_node.add_child(remove_btn)

		grid_container.add_child(item_node)

func _populate_tray() -> void:
	for child in tray_container.get_children():
		child.queue_free()

	var bag = bags_data[current_bag_index]
	for it in bag.items:
		var item_id = it.get("id", "")
		if placed_items.has(item_id):
			continue # already in grid

		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(100, 130)
		var card_sb = StyleBoxFlat.new()
		card_sb.bg_color = Color("#FFFDF9")
		card_sb.border_color = it.get("color", Color("#8D5B36"))
		card_sb.set_border_width_all(2)
		card_sb.border_width_bottom = 4
		card_sb.set_corner_radius_all(8)
		card_sb.content_margin_left = 6
		card_sb.content_margin_right = 6
		card_sb.content_margin_top = 6
		card_sb.content_margin_bottom = 6
		card.add_theme_stylebox_override("panel", card_sb)

		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.set("theme_override_constants/separation", 4)
		card.add_child(vbox)

		# Texture preview
		var icon = TextureRect.new()
		icon.texture = GameManager.load_texture(it.get("tex", ""))
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(60, 50)
		vbox.add_child(icon)

		# Name
		var name_lbl = Label.new()
		name_lbl.text = it.get("name", "")
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		name_lbl.add_theme_font_size_override("font_size", 9)
		name_lbl.add_theme_color_override("font_color", Color("#4A2E1B"))
		vbox.add_child(name_lbl)

		# Shape dims
		var dims_lbl = Label.new()
		var shape_arr = it.get("shape", [[1]])
		var shape_h = shape_arr.size()
		var shape_w = shape_arr[0].size()
		dims_lbl.text = str(shape_w) + "x" + str(shape_h) + " ô"
		dims_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dims_lbl.add_theme_font_size_override("font_size", 8)
		dims_lbl.add_theme_color_override("font_color", Color("#8D5B36"))
		vbox.add_child(dims_lbl)

		# Select button
		var btn_select = Button.new()
		btn_select.text = "CHỌN XẾP"
		btn_select.custom_minimum_size = Vector2(0, 26)
		btn_select.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var it_data = it
		btn_select.pressed.connect(func(): _select_item_to_place(it_data))
		vbox.add_child(btn_select)

		tray_container.add_child(card)

func _select_item_to_place(it: Dictionary) -> void:
	SoundManager.play_click()
	selected_item_data = it
	selected_item_rotated_shape = it.get("shape", [[1]]).duplicate(true)
	lbl_status.text = "Đang chọn: " + it.get("name", "") + " -> Chạm ô trên lưới để đặt!"

func _on_rotate_pressed() -> void:
	SoundManager.play_click()
	if selected_item_data.is_empty():
		lbl_status.text = "Hãy chọn 1 vật phẩm ở khay trước để xoay!"
		return

	# Rotate matrix 90 degrees clockwise
	var old_shape = selected_item_rotated_shape
	var rows = old_shape.size()
	var cols = old_shape[0].size()
	var new_shape = []

	for c in range(cols):
		var new_row = []
		for r in range(rows - 1, -1, -1):
			new_row.append(old_shape[r][c])
		new_shape.append(new_row)

	selected_item_rotated_shape = new_shape
	lbl_status.text = "Đã xoay " + selected_item_data.get("name", "") + " (" + str(new_shape[0].size()) + "x" + str(new_shape.size()) + " ô)"

func _on_cell_clicked(col: int, row: int) -> void:
	if selected_item_data.is_empty():
		return

	var shape = selected_item_rotated_shape
	var shape_h = shape.size()
	var shape_w = shape[0].size()

	var bag = bags_data[current_bag_index]
	if col + shape_w > bag.grid_cols or row + shape_h > bag.grid_rows:
		lbl_status.text = "❌ Quá chật! Vật phẩm chạm mép ngoài vali."
		return

	# Check collision
	for r in range(shape_h):
		for c in range(shape_w):
			if shape[r][c] == 1:
				if grid_cells[row + r][col + c] != "":
					lbl_status.text = "❌ Bị vướng! Đã có vật phẩm khác chiếm chỗ này."
					return

	# Place item!
	var it_id = selected_item_data.get("id", "")
	for r in range(shape_h):
		for c in range(shape_w):
			if shape[r][c] == 1:
				grid_cells[row + r][col + c] = it_id

	placed_items[it_id] = {
		"pos": Vector2i(col, row),
		"shape": shape.duplicate(true)
	}

	selected_item_data.clear()
	selected_item_rotated_shape.clear()
	SoundManager.play_success()

	_render_grid()
	_populate_tray()
	_update_status()

func _remove_placed_item(item_id: String) -> void:
	SoundManager.play_click()
	if not placed_items.has(item_id):
		return

	var info = placed_items[item_id]
	var pos: Vector2i = info.get("pos", Vector2i.ZERO)
	var shape: Array = info.get("shape", [])

	for r in range(shape.size()):
		for c in range(shape[r].size()):
			if shape[r][c] == 1:
				grid_cells[pos.y + r][pos.x + c] = ""

	placed_items.erase(item_id)
	_render_grid()
	_populate_tray()
	_update_status()

func _on_clear_bag_pressed() -> void:
	SoundManager.play_click()
	var bag = bags_data[current_bag_index]
	for r in range(bag.grid_rows):
		for c in range(bag.grid_cols):
			grid_cells[r][c] = ""
	placed_items.clear()
	selected_item_data.clear()
	_render_grid()
	_populate_tray()
	_update_status()

func _on_finish_bag_pressed() -> void:
	SoundManager.play_success()
	var bag = bags_data[current_bag_index]
	var total_items = bag.items.size()
	var placed_count = placed_items.size()

	if placed_count == total_items:
		lbl_status.text = "🎉 HOÀN THÀNH XUẤT SẮC TÚI: " + bag.name + "! ĐÃ XẾP KÍN GỌN GÀNG!"
		# Auto suggest next bag
		if current_bag_index < bags_data.size() - 1:
			await get_tree().create_timer(1.2).timeout
			_load_bag(current_bag_index + 1)
		else:
			lbl_status.text = "🏆 BẠN ĐÃ XẾP XONG CẢ 4 TÚI TRONG VALI NHẬP HỌC!"
			emit_signal("minigame_completed", {"status": "victory", "bags_completed": 4})
	else:
		lbl_status.text = "⚠️ Bạn mới xếp được " + str(placed_count) + "/" + str(total_items) + " món. Cố gắng xếp nốt nhé!"

func _update_status() -> void:
	var bag = bags_data[current_bag_index]
	var total_items = bag.items.size()
	var placed_count = placed_items.size()
	lbl_status.text = "Đã xếp: " + str(placed_count) + " / " + str(total_items) + " món"

func _find_item_meta(id: String) -> Dictionary:
	var bag = bags_data[current_bag_index]
	for it in bag.items:
		if it.get("id", "") == id:
			return it
	return {}

func _on_back_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
