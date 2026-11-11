extends Control

# BaseCategoryView.gd - Base class điều khiển giao diện Danh Mục Kỹ Năng Sống
# Cung cấp khung chuẩn: TopBar điều hướng (icon_arrow_left), Switcher 4 Danh mục,
# Danh sách Thẻ Bài Minigame, và Container tích hợp chạy minigame toàn màn hình.

signal back_requested()
signal switch_category_requested(target_category_id: int)
signal minigame_completed(sim_steps: Array)

@export var category_id: int = 1
@export var category_name: String = "DANH MỤC KỸ NĂNG"
@export var category_title: String = "Tiêu Đề Danh Mục"
@export var category_subtitle: String = "Mô tả ngắn gọn về danh mục kỹ năng sống"
@export var category_icon: String = "🐾"
@export var theme_color: Color = Color(0.20, 0.60, 0.95)
@export var theme_bevel: Color = Color(0.12, 0.45, 0.75)
@export var bg_color: Color = Color(0.97, 0.95, 0.92)

# Danh sách định nghĩa các Minigame trong danh mục
var minigames_list: Array = []

# Node tham chiếu UI
@onready var bg_rect: ColorRect = $BgRect
@onready var top_bar: HBoxContainer = $TopBar
@onready var btn_back: Button = $TopBar/BtnBack
@onready var cat_badge_label: Label = $TopBar/TitleBox/CatBadgeLabel
@onready var cat_title_label: Label = $TopBar/TitleBox/CatTitleLabel

@onready var category_switcher: HBoxContainer = $CategorySwitcher
@onready var header_card: PanelContainer = $HeaderCard
@onready var header_desc_label: Label = $HeaderCard/VBox/DescLabel
@onready var header_progress_label: Label = $HeaderCard/VBox/ProgressHBox/ProgressLabel
@onready var header_progress_bar: ProgressBar = $HeaderCard/VBox/ProgressHBox/ProgressBar
@onready var header_stars_label: Label = $HeaderCard/VBox/ProgressHBox/StarsLabel

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var cards_container: VBoxContainer = $ScrollContainer/CardsContainer
@onready var minigame_holder: Control = $MinigameHolder

var active_minigame_instance: Node = null

const ARROW_LEFT_TEXTURE = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
const ARROW_RIGHT_TEXTURE = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_right.png")
const CHECK_ICON_TEXTURE = preload("res://assets/UI/CatUIPaid/slices/icon_check.png")

func _ready() -> void:
	custom_minimum_size = Vector2(540, 960)
	_setup_base_ui()
	_populate_cards()
	_update_category_progress()

func _setup_base_ui() -> void:
	if bg_rect:
		bg_rect.color = bg_color
		
	if btn_back:
		btn_back.text = " Thoát"
		btn_back.icon = ARROW_LEFT_TEXTURE
		btn_back.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn_back.pressed.connect(_on_btn_back_pressed)
		
		var back_style = StyleBoxFlat.new()
		back_style.bg_color = Color(0.98, 0.96, 0.93, 1.0)
		back_style.border_color = Color(0.82, 0.74, 0.66, 1.0)
		back_style.set_border_width_all(2)
		back_style.border_width_bottom = 3
		back_style.set_corner_radius_all(10)
		back_style.content_margin_left = 10
		back_style.content_margin_right = 10
		back_style.content_margin_top = 4
		back_style.content_margin_bottom = 4
		btn_back.add_theme_stylebox_override("normal", back_style)
		btn_back.add_theme_stylebox_override("hover", back_style)
		btn_back.add_theme_stylebox_override("pressed", back_style)
		btn_back.add_theme_color_override("font_color", Color(0.35, 0.24, 0.16))
		
	if cat_badge_label:
		cat_badge_label.text = "%s DANH MỤC %d" % [category_icon, category_id]
		cat_badge_label.add_theme_color_override("font_color", theme_bevel)
		
	if cat_title_label:
		cat_title_label.text = category_title
		
	if header_desc_label:
		header_desc_label.text = category_subtitle
		
	_setup_switcher_tabs()

func _setup_switcher_tabs() -> void:
	if not category_switcher:
		return
		
	for child in category_switcher.get_children():
		child.queue_free()
		
	var cat_defs = [
		{"id": 1, "name": "🚌 Đi Lại", "color": Color(0.20, 0.60, 0.95)},
		{"id": 2, "name": "🏠 Nơi Ở", "color": Color(0.95, 0.45, 0.35)},
		{"id": 3, "name": "🩺 Y Tế", "color": Color(0.18, 0.75, 0.55)},
		{"id": 4, "name": "💰 Tài Chính", "color": Color(0.95, 0.65, 0.15)}
	]
	
	for def in cat_defs:
		var btn = Button.new()
		btn.text = def["name"]
		btn.custom_minimum_size = Vector2(116, 36)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.add_theme_font_size_override("font_size", 12)
		
		var is_current = (def["id"] == category_id)
		var btn_style = StyleBoxFlat.new()
		if is_current:
			btn_style.bg_color = def["color"]
			btn_style.border_color = def["color"].darkened(0.25)
			btn_style.set_border_width_all(2)
			btn_style.border_width_bottom = 3
			btn_style.set_corner_radius_all(12)
			btn.add_theme_color_override("font_color", Color(1, 1, 1))
		else:
			btn_style.bg_color = Color(1, 1, 1, 0.85)
			btn_style.border_color = Color(0.85, 0.80, 0.75, 1)
			btn_style.set_border_width_all(1)
			btn_style.border_width_bottom = 2
			btn_style.set_corner_radius_all(12)
			btn.add_theme_color_override("font_color", Color(0.45, 0.35, 0.28))
			
		btn_style.content_margin_left = 6
		btn_style.content_margin_right = 6
		btn_style.content_margin_top = 4
		btn_style.content_margin_bottom = 4
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_stylebox_override("hover", btn_style)
		btn.add_theme_stylebox_override("pressed", btn_style)
		
		var target_id = def["id"]
		btn.pressed.connect(func():
			if target_id != category_id:
				SoundManager.play_click()
				emit_signal("switch_category_requested", target_id)
		)
		category_switcher.add_child(btn)

func _populate_cards() -> void:
	if not cards_container:
		return
		
	for child in cards_container.get_children():
		child.queue_free()
		
	for i in range(minigames_list.size()):
		var mg_info = minigames_list[i]
		var card = _create_minigame_card(i + 1, mg_info)
		cards_container.add_child(card)

func _create_minigame_card(index: int, mg_info: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(500, 110)
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(1.0, 0.99, 0.97, 1.0)
	card_style.border_color = Color(0.88, 0.82, 0.75, 1.0)
	card_style.set_border_width_all(2)
	card_style.border_width_bottom = 4
	card_style.set_corner_radius_all(14)
	card_style.content_margin_left = 12
	card_style.content_margin_right = 12
	card_style.content_margin_top = 10
	card_style.content_margin_bottom = 10
	card_style.shadow_color = Color(0, 0, 0, 0.05)
	card_style.shadow_size = 4
	card_style.shadow_offset = Vector2(0, 2)
	panel.add_theme_stylebox_override("panel", card_style)
	
	var main_hbox = HBoxContainer.new()
	main_hbox.add_theme_constant_override("separation", 10)
	main_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(main_hbox)
	
	# 1. Cột Icon & Số thứ tự
	var left_box = VBoxContainer.new()
	left_box.custom_minimum_size = Vector2(62, 80)
	left_box.alignment = BoxContainer.ALIGNMENT_CENTER
	left_box.add_theme_constant_override("separation", 2)
	main_hbox.add_child(left_box)
	
	var icon_badge = PanelContainer.new()
	icon_badge.custom_minimum_size = Vector2(46, 46)
	var badge_style = StyleBoxFlat.new()
	badge_style.bg_color = theme_color.lightened(0.85)
	badge_style.border_color = theme_color
	badge_style.set_border_width_all(2)
	badge_style.set_corner_radius_all(12)
	icon_badge.add_theme_stylebox_override("panel", badge_style)
	
	var icon_lbl = Label.new()
	icon_lbl.text = mg_info.get("icon", category_icon)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 22)
	icon_badge.add_child(icon_lbl)
	left_box.add_child(icon_badge)
	
	var num_lbl = Label.new()
	num_lbl.text = "Bài %d" % index
	num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num_lbl.add_theme_font_size_override("font_size", 10)
	num_lbl.add_theme_color_override("font_color", Color(0.55, 0.45, 0.38))
	left_box.add_child(num_lbl)
	
	# 2. Cột thông tin chi tiết
	var center_box = VBoxContainer.new()
	center_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_box.alignment = BoxContainer.ALIGNMENT_CENTER
	center_box.add_theme_constant_override("separation", 3)
	main_hbox.add_child(center_box)
	
	var title_hbox = HBoxContainer.new()
	title_hbox.add_theme_constant_override("separation", 6)
	center_box.add_child(title_hbox)
	
	var title_lbl = Label.new()
	title_lbl.text = mg_info.get("title", "Kỹ Năng")
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", Color(0.25, 0.18, 0.12))
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_hbox.add_child(title_lbl)
	
	var badge_type = PanelContainer.new()
	var tag_style = StyleBoxFlat.new()
	tag_style.bg_color = theme_color
	tag_style.set_corner_radius_all(6)
	tag_style.content_margin_left = 6
	tag_style.content_margin_right = 6
	tag_style.content_margin_top = 1
	tag_style.content_margin_bottom = 1
	badge_type.add_theme_stylebox_override("panel", tag_style)
	
	var tag_lbl = Label.new()
	tag_lbl.text = mg_info.get("type_badge", "Thực Hành")
	tag_lbl.add_theme_font_size_override("font_size", 9)
	tag_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	badge_type.add_child(tag_lbl)
	title_hbox.add_child(badge_type)
	
	var desc_lbl = Label.new()
	desc_lbl.text = mg_info.get("desc", "")
	desc_lbl.add_theme_font_size_override("font_size", 11)
	desc_lbl.add_theme_color_override("font_color", Color(0.48, 0.40, 0.35))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.max_lines_visible = 2
	center_box.add_child(desc_lbl)
	
	# 3. Cột Nút Bấm Chơi & Trạng Thái
	var right_box = VBoxContainer.new()
	right_box.custom_minimum_size = Vector2(105, 80)
	right_box.alignment = BoxContainer.ALIGNMENT_CENTER
	right_box.add_theme_constant_override("separation", 4)
	main_hbox.add_child(right_box)
	
	var lesson_id = mg_info.get("lesson_id", index)
	var is_completed = (lesson_id in GameManager.completed_lessons)
	
	var stars_lbl = Label.new()
	stars_lbl.text = "⭐⭐⭐ ĐÃ XONG" if is_completed else "⭐ CHƯA HỌC"
	stars_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stars_lbl.add_theme_font_size_override("font_size", 10)
	stars_lbl.add_theme_color_override("font_color", Color(0.95, 0.65, 0.10) if is_completed else Color(0.65, 0.60, 0.55))
	right_box.add_child(stars_lbl)
	
	var btn_play = Button.new()
	btn_play.custom_minimum_size = Vector2(98, 36)
	btn_play.text = " Ôn Tập" if is_completed else " Chơi Ngay"
	btn_play.icon = ARROW_RIGHT_TEXTURE
	btn_play.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_play.add_theme_font_size_override("font_size", 11)
	
	var play_style = StyleBoxFlat.new()
	var btn_col = Color(0.25, 0.70, 0.40) if is_completed else theme_color
	play_style.bg_color = btn_col
	play_style.border_color = btn_col.darkened(0.25)
	play_style.set_border_width_all(1)
	play_style.border_width_bottom = 3
	play_style.set_corner_radius_all(10)
	play_style.content_margin_left = 6
	play_style.content_margin_right = 6
	play_style.content_margin_top = 4
	play_style.content_margin_bottom = 4
	btn_play.add_theme_stylebox_override("normal", play_style)
	btn_play.add_theme_stylebox_override("hover", play_style)
	btn_play.add_theme_stylebox_override("pressed", play_style)
	btn_play.add_theme_color_override("font_color", Color(1, 1, 1))
	
	btn_play.pressed.connect(func():
		_launch_minigame(mg_info)
	)
	right_box.add_child(btn_play)
	
	return panel

func _update_category_progress() -> void:
	if minigames_list.is_empty():
		return
		
	var completed_count = 0
	for mg in minigames_list:
		var l_id = mg.get("lesson_id", 0)
		if l_id in GameManager.completed_lessons:
			completed_count += 1
			
	var total = minigames_list.size()
	if header_progress_label:
		header_progress_label.text = "Tiến độ: %d / %d Kỹ năng" % [completed_count, total]
		
	if header_progress_bar:
		header_progress_bar.max_value = total
		header_progress_bar.value = completed_count
		
	if header_stars_label:
		header_stars_label.text = "⭐ %d / %d Sao" % [completed_count * 3, total * 3]

func _launch_minigame(mg_info: Dictionary) -> void:
	var scene_path = mg_info.get("scene_path", "")
	if not ResourceLoader.exists(scene_path):
		GameManager.emit_signal("show_toast", "⚠️ Chưa tìm thấy màn chơi: %s" % scene_path)
		return
		
	SoundManager.play_click()
	
	# Khởi tạo minigame vào minigame_holder
	var packed_scn = load(scene_path)
	if not packed_scn:
		return
		
	if active_minigame_instance:
		active_minigame_instance.queue_free()
		active_minigame_instance = null
		
	# Ẩn giao diện danh mục để minigame độc quyền toàn màn hình, không bị lem chữ nền
	if top_bar: top_bar.visible = false
	if category_switcher: category_switcher.visible = false
	if header_card: header_card.visible = false
	if scroll_container: scroll_container.visible = false
	
	active_minigame_instance = packed_scn.instantiate()
	minigame_holder.add_child(active_minigame_instance)
	minigame_holder.visible = true
	
	# Nạp dữ liệu vào minigame nếu hỗ trợ
	var data_key = mg_info.get("data_key", str(mg_info.get("lesson_id", 1)))
	var mg_data = GameManager.get_minigame_data(int(data_key) if data_key.is_valid_int() else 1)
	if mg_data.is_empty() and GameManager.minigames_data.has(str(data_key)):
		mg_data = GameManager.minigames_data[str(data_key)]
		
	if active_minigame_instance.has_method("load_minigame"):
		active_minigame_instance.load_minigame(mg_data)
	elif active_minigame_instance.has_method("setup"):
		active_minigame_instance.setup(mg_data)
		
	# Kết nối tín hiệu điều hướng
	if active_minigame_instance.has_signal("back_requested"):
		active_minigame_instance.back_requested.connect(_on_minigame_closed)
		
	if active_minigame_instance.has_signal("minigame_completed"):
		active_minigame_instance.minigame_completed.connect(func(sim_steps):
			_on_minigame_completed(mg_info, sim_steps)
		)

func _on_minigame_closed() -> void:
	if active_minigame_instance:
		active_minigame_instance.queue_free()
		active_minigame_instance = null
	minigame_holder.visible = false
	
	# Phục hồi hiển thị danh mục
	if top_bar: top_bar.visible = true
	if category_switcher: category_switcher.visible = true
	if header_card: header_card.visible = true
	if scroll_container: scroll_container.visible = true
	
	_populate_cards()
	_update_category_progress()

func _on_minigame_completed(mg_info: Dictionary, sim_steps: Array) -> void:
	var l_id = mg_info.get("lesson_id", 1)
	if not (l_id in GameManager.completed_lessons):
		GameManager.completed_lessons.append(l_id)
		GameManager.fish += 25
		GameManager.courage = mini(100, GameManager.courage + 15)
		GameManager.emit_signal("show_toast", "🎉 Hoàn thành kỹ năng! Thưởng +25 💵 Cá Khô & +15 Dũng Cảm! ⭐")
		GameManager.emit_signal("stats_changed")
		GameManager.save_game()
		
	emit_signal("minigame_completed", sim_steps)
	_on_minigame_closed()

func _on_btn_back_pressed() -> void:
	SoundManager.play_click()
	emit_signal("back_requested")
