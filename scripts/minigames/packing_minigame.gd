extends "res://scripts/minigames/MinigameBase.gd"

const PixelPlaceholderFactory = preload("res://scripts/utils/PixelPlaceholderFactory.gd")

## packing_minigame.gd
## Standalone Unpacking-style Luggage Packing Minigame
## Features: 4 compartments, item tray, category filtering, drag & drop,
## polaroid inspection popup, safe failure for prohibited items, victory modal,
## and full standalone execution capability.

const FONT_PATH = "res://assets/font/SVN-Retron 2000.ttf"

# Target capacity & weights
const MAX_WEIGHT_KG: float = 10.0
const REQUIRED_ITEM_COUNT: int = 11

# Compartments definition
const COMPARTMENTS = {
	"clothes": {
		"title": "Quần Áo & Đồ Vải",
		"icon": "👔",
		"category": PixelPlaceholderFactory.Category.CLOTHES,
		"bg_color": Color("#E8EEF1"),
		"border_color": Color("#78909C"),
		"max_slots": 4
	},
	"docs": {
		"title": "Túi Hồ Sơ Chống Nước",
		"icon": "📄",
		"category": PixelPlaceholderFactory.Category.DOCS,
		"bg_color": Color("#FFF8E1"),
		"border_color": Color("#FFB74D"),
		"max_slots": 3
	},
	"medicine": {
		"title": "Hộp Thuốc Cấp Cứu",
		"icon": "💊",
		"category": PixelPlaceholderFactory.Category.MEDICINE,
		"bg_color": Color("#FFEBEE"),
		"border_color": Color("#E57373"),
		"max_slots": 4
	},
	"tech": {
		"title": "Túi Chống Sốc Công Nghệ",
		"icon": "🔌",
		"category": PixelPlaceholderFactory.Category.TECH,
		"bg_color": Color("#E0F7FA"),
		"border_color": Color("#4DD0E1"),
		"max_slots": 4
	}
}

# Master items catalogue
const DEFAULT_ITEMS_DATA: Array[Dictionary] = [
	{
		"id": "folded_shirt",
		"name": "Áo Thun Gấp Gọn",
		"category": "clothes",
		"cat_enum": PixelPlaceholderFactory.Category.CLOTHES,
		"asset_id": "pack_clothes_folded_shirt",
		"weight_kg": 0.4,
		"prohibited": false,
		"advice": "Gấp áo thun vuông vức hoặc cuộn tròn giúp tiết kiệm 40% diện tích vali và hạn chế nhăn."
	},
	{
		"id": "rolled_jeans",
		"name": "Quần Jean Cuộn Tròn",
		"category": "clothes",
		"cat_enum": PixelPlaceholderFactory.Category.CLOTHES,
		"asset_id": "pack_clothes_rolled_pants",
		"weight_kg": 0.8,
		"prohibited": false,
		"advice": "Cuộn chặt ống quần jeans để chèn vào các góc đáy vali, tạo khung chịu lực chống sốc."
	},
	{
		"id": "towel",
		"name": "Khăn Tắm Bông Cuộn",
		"category": "clothes",
		"cat_enum": PixelPlaceholderFactory.Category.CLOTHES,
		"asset_id": "pack_clothes_towel",
		"weight_kg": 0.3,
		"prohibited": false,
		"advice": "Khăn bông cotton hút ẩm tốt, nên bọc quanh đồ đạc dễ vỡ khi di chuyển đường dài."
	},
	{
		"id": "dossier",
		"name": "Hồ Sơ Nhập Học Chống Nước",
		"category": "docs",
		"cat_enum": PixelPlaceholderFactory.Category.DOCS,
		"asset_id": "pack_doc_dossier",
		"weight_kg": 0.5,
		"prohibited": false,
		"advice": "Giấy báo nhập học và học bạ bản gốc bắt buộc phải bỏ túi zip chống nước, không gửi thùng xe buýt."
	},
	{
		"id": "id_wallet",
		"name": "Ví Thẻ CCCD & BHYT",
		"category": "docs",
		"cat_enum": PixelPlaceholderFactory.Category.DOCS,
		"asset_id": "pack_doc_id_wallet",
		"weight_kg": 0.1,
		"prohibited": false,
		"advice": "CCCD gắn chip và thẻ BHYT luôn mang theo bên người để giải quyết thủ tục tạm trú và cấp cứu."
	},
	{
		"id": "mother_box",
		"name": "Hộp Thuốc Của Mẹ",
		"category": "medicine",
		"cat_enum": PixelPlaceholderFactory.Category.MEDICINE,
		"asset_id": "pack_med_mother_box",
		"weight_kg": 0.6,
		"prohibited": false,
		"advice": "Hộp thuốc gia đình gồm băng gạc, cồn đỏ, dầu gió, bông y tế — cứu tinh cho các vết thương bất ngờ."
	},
	{
		"id": "paracetamol",
		"name": "Vỉ Paracetamol 500mg",
		"category": "medicine",
		"cat_enum": PixelPlaceholderFactory.Category.MEDICINE,
		"asset_id": "pack_med_paracetamol",
		"weight_kg": 0.1,
		"prohibited": false,
		"advice": "Hạ sốt và giảm đau khẩn cấp. Uống đúng liều 10-15mg/kg cân nặng, cách nhau tối thiểu 4-6 tiếng."
	},
	{
		"id": "oresol",
		"name": "Gói Bột Oresol Bù Nước",
		"category": "medicine",
		"cat_enum": PixelPlaceholderFactory.Category.MEDICINE,
		"asset_id": "pack_med_oresol_pack",
		"weight_kg": 0.1,
		"prohibited": false,
		"advice": "Bù nước điện giải khi sốt cao hoặc tiêu chảy. Pha đúng dung tích nước trên bao bì (200ml/gói)."
	},
	{
		"id": "laptop",
		"name": "Laptop & Túi Chống Sốc",
		"category": "tech",
		"cat_enum": PixelPlaceholderFactory.Category.TECH,
		"asset_id": "pack_tech_laptop_sleeve",
		"weight_kg": 1.8,
		"prohibited": false,
		"advice": "Công cụ học tập quan trọng nhất. Đặt ở trung tâm ngăn công nghệ có đệm mút bảo vệ."
	},
	{
		"id": "power_strip",
		"name": "Ổ Cắm Điện Nối Dài 3 Chấu",
		"category": "tech",
		"cat_enum": PixelPlaceholderFactory.Category.TECH,
		"asset_id": "pack_tech_power_strip",
		"weight_kg": 0.5,
		"prohibited": false,
		"advice": "Phòng trọ thường chỉ có 1-2 ổ cắm. Ổ cắm có công tắc an toàn giúp bảo vệ laptop khỏi sét lan truyền."
	},
	{
		"id": "charger",
		"name": "Củ Sạc Đa Năng & Cáp",
		"category": "tech",
		"cat_enum": PixelPlaceholderFactory.Category.TECH,
		"asset_id": "pack_tech_charger_cable",
		"weight_kg": 0.2,
		"prohibited": false,
		"advice": "Củ sạc chuẩn Type-C sạc chung cho cả điện thoại và máy tính, giảm bớt dây cáp lộn xộn."
	},
	{
		"id": "teddy",
		"name": "Gấu Bông Khổng Lồ 1.5m",
		"category": "prohibited",
		"cat_enum": PixelPlaceholderFactory.Category.PROHIBITED,
		"asset_id": "pack_bad_giant_teddy",
		"weight_kg": 4.5,
		"prohibited": true,
		"advice": "VẬT CẨM: Quá cồng kềnh! Chiếm 80% diện tích vali và không có chỗ để trong phòng trọ chật hẹp."
	},
	{
		"id": "hotpot",
		"name": "Nồi Lẩu Điện Siêu To",
		"category": "prohibited",
		"cat_enum": PixelPlaceholderFactory.Category.PROHIBITED,
		"asset_id": "pack_bad_hotpot_cooker",
		"weight_kg": 3.8,
		"prohibited": true,
		"advice": "VẬT CẤM: Công suất 2000W vi phạm nghiêm trọng nội quy KTX/nhà trọ, dễ gây cháy nổ và nhảy aptomat."
	}
]

# State variables
var packed_items: Dictionary = {
	"clothes": [],
	"docs": [],
	"medicine": [],
	"tech": []
}
var current_filter: String = "all"
var total_weight: float = 0.0
var current_inspecting_item: Dictionary = {}
var btn_inspect_pack: Button = null

# UI Node references
@onready var lbl_title: Label = $HeaderBar/HBox/LblTitle
@onready var btn_back: Button = $HeaderBar/HBox/BtnBack
@onready var btn_info: Button = $HeaderBar/HBox/BtnInfo
@onready var lbl_cat_bubble: Label = $MainLayout/SpeechSection/CatBubble/LblSpeech
@onready var lbl_weight: Label = $MainLayout/StatusSection/VBox/HBoxStats/LblWeight
@onready var lbl_count: Label = $MainLayout/StatusSection/VBox/HBoxStats/LblCount
@onready var bar_progress: ProgressBar = $MainLayout/StatusSection/VBox/ProgressBar
@onready var grid_suitcases: GridContainer = $MainLayout/SuitcaseSection/SuitcaseCard/CompartmentsGrid
@onready var tabs_container: HBoxContainer = $MainLayout/TraySection/FilterTabs
@onready var tray_container: HBoxContainer = $MainLayout/TraySection/ScrollTray/TrayItemsHBox
@onready var modal_inspect: PanelContainer = $InspectModal
@onready var modal_victory: PanelContainer = $VictoryModal
@onready var banner_alert: PanelContainer = $SafeFailureBanner

func _on_load_minigame(game_data: Dictionary) -> void:
	if not game_data.is_empty():
		data = game_data
		if is_inside_tree() and tray_container:
			_populate_tray()

func _ready() -> void:
	super._ready()
	_setup_theme_and_ui()
	_populate_compartments()
	_populate_tabs()
	
	# Standalone fallback: Load default mock data if not supplied by parent
	if data.is_empty():
		data = {
			"lesson_id": 1,
			"title": "Xếp Vali Hành Trang Tân Sinh Viên",
			"items": DEFAULT_ITEMS_DATA
		}
	
	_populate_tray()
	_update_stats_display()
	begin_minigame_loop("🎒 Hãy xếp 11 món đồ thiết yếu vào đúng ngăn vali!")

func _setup_theme_and_ui() -> void:
	btn_back.pressed.connect(_on_back_pressed)
	btn_info.pressed.connect(_on_info_pressed)
	modal_inspect.visible = false
	modal_victory.visible = false
	banner_alert.visible = false
	
	var btn_inspect_close = modal_inspect.get_node_or_null("VBox/BtnCloseInspect")
	if btn_inspect_close:
		btn_inspect_close.pressed.connect(func(): modal_inspect.visible = false)
		
		# Nút xếp nhanh vào vali ngay trong modal soi chi tiết
		btn_inspect_pack = Button.new()
		btn_inspect_pack.name = "BtnPackDirect"
		btn_inspect_pack.text = "📥 XẾP VÀO VALI"
		btn_inspect_pack.custom_minimum_size = Vector2(140, 36)
		btn_inspect_pack.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var btn_pack_sb = StyleBoxFlat.new()
		btn_pack_sb.bg_color = Color("#2E7D32")
		btn_pack_sb.border_color = Color("#1B5E20")
		btn_pack_sb.set_border_width_all(2)
		btn_pack_sb.border_width_bottom = 4
		btn_pack_sb.set_corner_radius_all(10)
		btn_inspect_pack.add_theme_stylebox_override("normal", btn_pack_sb)
		btn_inspect_pack.add_theme_stylebox_override("hover", btn_pack_sb)
		btn_inspect_pack.add_theme_stylebox_override("pressed", btn_pack_sb)
		btn_inspect_pack.add_theme_color_override("font_color", Color.WHITE)
		btn_inspect_pack.add_theme_font_size_override("font_size", 12)
		
		var vbox_parent = btn_inspect_close.get_parent()
		var hbox_btn = HBoxContainer.new()
		hbox_btn.name = "HBoxInspectButtons"
		hbox_btn.alignment = BoxContainer.ALIGNMENT_CENTER
		hbox_btn.set("theme_override_constants/separation", 10)
		
		vbox_parent.remove_child(btn_inspect_close)
		vbox_parent.add_child(hbox_btn)
		hbox_btn.add_child(btn_inspect_pack)
		hbox_btn.add_child(btn_inspect_close)
		
		btn_inspect_pack.pressed.connect(func():
			if not current_inspecting_item.is_empty():
				var cat = current_inspecting_item.get("category", "")
				if handle_item_drop(current_inspecting_item, cat):
					modal_inspect.visible = false
					_populate_tray()
		)
		var JuicyButton = preload("res://scripts/ui/JuicyButton.gd")
		JuicyButton.attach_juice(btn_inspect_pack, true)
		
	var btn_replay = modal_victory.get_node_or_null("VBox/HBoxVictory/BtnReplay")
	if btn_replay:
		btn_replay.pressed.connect(_on_replay_pressed)
	var btn_menu = modal_victory.get_node_or_null("VBox/HBoxVictory/BtnMenu")
	if btn_menu:
		btn_menu.pressed.connect(_on_menu_pressed)

## Create visual 4 compartments with custom drop target logic
func _populate_compartments() -> void:
	for child in grid_suitcases.get_children():
		child.queue_free()

	for comp_key in COMPARTMENTS.keys():
		var comp_info: Dictionary = COMPARTMENTS[comp_key]
		var comp_panel := PanelContainer.new()
		comp_panel.name = "Comp_" + comp_key
		comp_panel.custom_minimum_size = Vector2(240, 150)
		comp_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		comp_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		# Styling
		var sb := StyleBoxFlat.new()
		sb.bg_color = comp_info["bg_color"]
		sb.border_color = comp_info["border_color"]
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(10)
		sb.content_margin_left = 8
		sb.content_margin_top = 8
		sb.content_margin_right = 8
		sb.content_margin_bottom = 8
		comp_panel.add_theme_stylebox_override("panel", sb)

		var vbox := VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		# Header with title & counter
		var hbox_h := HBoxContainer.new()
		var lbl_h := Label.new()
		lbl_h.text = "%s %s" % [comp_info["icon"], comp_info["title"]]
		lbl_h.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_h.add_theme_color_override("font_color", Color("#263238"))
		lbl_h.add_theme_font_size_override("font_size", 11)
		hbox_h.add_child(lbl_h)
		
		var lbl_badge := Label.new()
		lbl_badge.name = "BadgeCount"
		lbl_badge.text = "0/%d" % comp_info["max_slots"]
		lbl_badge.add_theme_color_override("font_color", Color("#546E7A"))
		lbl_badge.add_theme_font_size_override("font_size", 10)
		hbox_h.add_child(lbl_badge)
		vbox.add_child(hbox_h)
		
		# Items container inside compartment
		var flow_items := HFlowContainer.new()
		flow_items.name = "ItemsFlow"
		flow_items.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		flow_items.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vbox.add_child(flow_items)

		comp_panel.add_child(vbox)
		
		# Scripted drop target logic
		comp_panel.set_script(preload("res://scripts/minigames/packing_drop_slot.gd"))
		comp_panel.setup_slot(comp_key, self)
		grid_suitcases.add_child(comp_panel)

## Setup category filter tabs
func _populate_tabs() -> void:
	for child in tabs_container.get_children():
		child.queue_free()

	var tab_defs = [
		{"key": "all", "label": "Tất cả"},
		{"key": "clothes", "label": "👔 Quần áo"},
		{"key": "docs", "label": "📄 Hồ sơ"},
		{"key": "medicine", "label": "💊 Y tế"},
		{"key": "tech", "label": "🔌 Công nghệ"},
		{"key": "prohibited", "label": "⚠️ Đồ cấm"}
	]
	
	for tab in tab_defs:
		var btn := Button.new()
		btn.text = tab["label"]
		btn.flat = true
		btn.add_theme_font_size_override("font_size", 10)
		btn.pressed.connect(func(): _set_filter(tab["key"]))
		tabs_container.add_child(btn)

func _set_filter(filter_key: String) -> void:
	current_filter = filter_key
	_populate_tray()

## Populate available items in the tray
func _populate_tray() -> void:
	for child in tray_container.get_children():
		child.queue_free()

	var items_list: Array = data.get("items", DEFAULT_ITEMS_DATA)
	for item_data in items_list:
		var item_id: String = item_data["id"]
		var cat: String = item_data["category"]
		
		# Skip if already packed
		if _is_item_packed(item_id):
			continue
			
		# Apply category filter
		if current_filter != "all" and current_filter != cat:
			continue

		var item_card := _create_item_tray_card(item_data)
		tray_container.add_child(item_card)

func _create_item_tray_card(item_data: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(80, 100)
	
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#FFFDF7")
	sb.border_color = Color("#D7CCC8")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 4
	sb.content_margin_top = 4
	sb.content_margin_right = 4
	sb.content_margin_bottom = 4
	card.add_theme_stylebox_override("panel", sb)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Icon generated via PixelPlaceholderFactory
	var tex_rect := TextureRect.new()
	tex_rect.custom_minimum_size = Vector2(40, 40)
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var tex = PixelPlaceholderFactory.get_or_create(
		item_data["asset_id"],
		Vector2i(40, 40),
		item_data["cat_enum"],
		item_data["name"]
	)
	tex_rect.texture = tex
	vbox.add_child(tex_rect)
	
	# Item Name
	var lbl := Label.new()
	lbl.text = item_data["name"]
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.add_theme_color_override("font_color", Color("#3E2723"))
	vbox.add_child(lbl)
	
	# Weight badge
	var lbl_w := Label.new()
	lbl_w.text = "%.1f kg" % item_data["weight_kg"]
	lbl_w.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_w.add_theme_font_size_override("font_size", 8)
	lbl_w.add_theme_color_override("font_color", Color("#8D6E63"))
	vbox.add_child(lbl_w)
	
	card.add_child(vbox)
	
	# Enable DraggableItem script on card
	card.set_script(preload("res://scripts/minigames/packing_draggable_card.gd"))
	card.setup_card(item_data, self)
	return card

func _is_item_packed(item_id: String) -> bool:
	for comp_key in packed_items.keys():
		for it in packed_items[comp_key]:
			if it["id"] == item_id:
				return true
	return false

## Drag & Drop handler called by drop slots
func handle_item_drop(item_data: Dictionary, target_comp: String) -> bool:
	if not can_accept_input():
		return false
		
	# 1. Prohibited item detection (Safe Failure)
	if item_data.get("prohibited", false):
		_trigger_prohibited_failure(item_data)
		return false
		
	# 2. Check if item fits this compartment category
	if item_data["category"] != target_comp:
		_trigger_wrong_slot_feedback(item_data, target_comp)
		return false
		
	# 3. Check compartment capacity
	var max_slots: int = COMPARTMENTS[target_comp]["max_slots"]
	if packed_items[target_comp].size() >= max_slots:
		_show_feedback_speech("Ngăn này đã đầy rồi! Hãy sắp xếp lại nhé.")
		return false

	# 4. Check weight limit
	if total_weight + item_data["weight_kg"] > MAX_WEIGHT_KG:
		_show_feedback_speech("Vali vượt quá 10kg! Bị từ chối xách tay lên xe!")
		run_safe_feedback(0.8)
		return false

	# Pack item successfully
	packed_items[target_comp].append(item_data)
	total_weight += item_data["weight_kg"]
	_update_compartment_ui(target_comp)
	_update_stats_display()
	_populate_tray()
	
	_show_feedback_speech("✓ Đã xếp %s vào vali gọn gàng!" % item_data["name"])
	
	# Check completion condition
	var total_packed: int = _get_total_packed_count()
	if total_packed >= REQUIRED_ITEM_COUNT:
		_trigger_victory()

	return true

func _trigger_prohibited_failure(item_data: Dictionary) -> void:
	safe_failure_count += 1
	var reason: String = str(item_data.get("advice", "Món đồ cồng kềnh, không phù hợp!"))
	banner_alert.visible = true
	var lbl_alert = banner_alert.get_node_or_null("VBox/LblAlertReason")
	if lbl_alert:
		lbl_alert.text = "⚠️ BẪY THỬ SAI: %s\n%s" % [item_data["name"], reason]
	
	_show_feedback_speech("Ái chà! Món này bị cấm hoặc quá tải rồi Sen ơi!")
	run_safe_feedback(1.2)
	
	var tween := create_tween()
	tween.tween_interval(2.8)
	tween.tween_callback(func(): banner_alert.visible = false)

func _trigger_wrong_slot_feedback(item_data: Dictionary, target_comp: String) -> void:
	var expected_comp: String = item_data["category"]
	var expected_title: String = COMPARTMENTS.get(expected_comp, {}).get("title", expected_comp)
	_show_feedback_speech("Sai ngăn rồi! %s phải xếp vào ngăn [%s] nhé." % [item_data["name"], expected_title])
	run_safe_feedback(0.6)

func _update_compartment_ui(comp_key: String) -> void:
	var comp_panel = grid_suitcases.get_node_or_null("Comp_" + comp_key)
	if not comp_panel:
		return
		
	var badge = comp_panel.find_child("BadgeCount", true, false)
	var flow = comp_panel.find_child("ItemsFlow", true, false)
	
	var items: Array = packed_items[comp_key]
	var max_slots: int = COMPARTMENTS[comp_key]["max_slots"]
	if badge:
		badge.text = "%d/%d" % [items.size(), max_slots]
		
	if flow:
		for ch in flow.get_children():
			ch.queue_free()
		for it in items:
			var chip := _create_packed_chip(it, comp_key)
			flow.add_child(chip)

func _create_packed_chip(item_data: Dictionary, comp_key: String) -> Control:
	var chip := Button.new()
	chip.text = "✓ " + item_data["name"]
	chip.flat = false
	chip.add_theme_font_size_override("font_size", 9)
	chip.tooltip_text = "Chạm để gỡ ra hoặc xem chi tiết"
	chip.pressed.connect(func(): _show_item_inspection(item_data))
	return chip

func _get_total_packed_count() -> int:
	var count: int = 0
	for comp_key in packed_items.keys():
		count += packed_items[comp_key].size()
	return count

func _update_stats_display() -> void:
	var count: int = _get_total_packed_count()
	lbl_weight.text = "Trọng lượng: %.1f / %.1f kg" % [total_weight, MAX_WEIGHT_KG]
	lbl_count.text = "Hành trang: %d / %d món" % [count, REQUIRED_ITEM_COUNT]
	bar_progress.max_value = REQUIRED_ITEM_COUNT
	bar_progress.value = count

func _show_feedback_speech(text: String) -> void:
	if lbl_cat_bubble:
		lbl_cat_bubble.text = text

## Single-tap Polaroid Inspection Modal
func _show_item_inspection(item_data: Dictionary) -> void:
	current_inspecting_item = item_data
	modal_inspect.visible = true
	var lbl_name = modal_inspect.find_child("LblInspectName", true, false)
	var lbl_advice = modal_inspect.find_child("LblInspectAdvice", true, false)
	var tex_inspect = modal_inspect.find_child("TexInspectIcon", true, false)
	
	if lbl_name:
		lbl_name.text = item_data["name"]
	if lbl_advice:
		lbl_advice.text = "💡 LỜI DẶN ĐỜI THỰC:\n" + item_data["advice"]
	if tex_inspect:
		tex_inspect.texture = PixelPlaceholderFactory.get_or_create(
			item_data["asset_id"],
			Vector2i(64, 64),
			item_data["cat_enum"],
			item_data["name"]
		)
	if btn_inspect_pack:
		btn_inspect_pack.visible = not _is_item_packed(item_data["id"])

## Victory & Completion sequence
func _trigger_victory() -> void:
	modal_victory.visible = true
	var lbl_stats = modal_victory.find_child("LblVictoryStats", true, false)
	if lbl_stats:
		lbl_stats.text = "Tổng cân nặng: %.1f kg (Chuẩn xách tay)\nThử sai đã học: %d lần\nBạn đã sẵn sàng khởi hành tự lập!" % [total_weight, safe_failure_count]
	complete_minigame(0.1, {
		"total_packed": _get_total_packed_count(),
		"total_weight": total_weight,
		"safe_failures": safe_failure_count
	})

func _on_replay_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	if get_tree() and get_parent() == get_tree().root:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_back_pressed() -> void:
	if not back_requested.get_connections().is_empty():
		emit_signal("back_requested")
	elif get_tree() and get_parent() == get_tree().root:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_info_pressed() -> void:
	_show_feedback_speech("Kéo thả các món đồ dưới khay vào đúng 4 ngăn vali. Tránh đồ cấm và quá tải!")
