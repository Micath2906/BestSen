extends Control

# BUDGET JARS GAME (QUẢN LÝ 3 HŨ NGÂN SÁCH 2.000.000 VNĐ & NÉ BẪY TÀI CHÍNH)
# Toàn màn hình, giao diện Cozy Pixel 3 hũ thủy tinh
# Có thanh trượt HSlider (min 0 - max 2tr) VÀ ô LineEdit nhập số trực tiếp cho từng hũ
# Giai đoạn 1: Phân bổ ngân sách -> Giai đoạn 2: 30 ngày sinh tồn đối mặt 5 bẫy tài chính

signal minigame_completed(result: Dictionary)

const TOTAL_INCOME = 2000000

var jar_essential: int = 1000000
var jar_growth: int = 600000
var jar_emergency: int = 400000

var is_budget_locked: bool = false
var current_event_idx: int = 0
var safe_failures: int = 0

var life_events = [
	{
		"week": "TUẦN 1",
		"title": "🛒 Đi Chợ & Nấu Cơm Tuần Đầu",
		"desc": "Mua gạo, trứng, cá mòi, rau xanh và gia vị cho cả tuần đầu tiên tại phòng trọ.",
		"cost": 250000,
		"target_jar": "essential",
		"choices": [
			{"text": "Chi 250.000đ từ HŨ THIẾT YẾU", "correct": true, "jar": "essential", "note": "Chính xác! Ăn uống cơ bản là nhu cầu thiết yếu hàng đầu."},
			{"text": "Chi từ HŨ PHÁT TRIỂN", "correct": false, "jar": "growth", "note": "Sai hũ! Hũ phát triển chỉ dành cho việc học tập và nâng cao bản thân."}
		]
	},
	{
		"week": "TUẦN 2",
		"title": "🛵 Xe Máy Bị Cán Đinh Thủng Săm",
		"desc": "Đang đi học thì xe bị thủng săm giữa đường, thợ sửa xe báo giá vá săm và thay van 70.000đ.",
		"cost": 70000,
		"target_jar": "emergency",
		"choices": [
			{"text": "Chi 70.000đ từ HŨ KHẨN CẤP", "correct": true, "jar": "emergency", "note": "Chuẩn xác! Sự cố xe cộ bất ngờ được chi trả từ quỹ dự phòng khẩn cấp."},
			{"text": "Nhịn ăn 2 bữa để bù tiền", "correct": false, "jar": "essential", "note": "Không nên nhịn ăn làm hại dạ dày! Quỹ khẩn cấp sinh ra là để dùng cho lúc này."}
		]
	},
	{
		"week": "TUẦN 2",
		"title": "🚨 Cảnh Báo: Bẫy Vay Tiêu Dùng / Mua Trước Trả Sau",
		"desc": "Quảng cáo online: 'Vay 10 triệu mua iPhone trả góp 0%, tháng đầu chỉ trả 200k!'.",
		"cost": 0,
		"target_jar": "trap",
		"choices": [
			{"text": "BỎ QUA & BÁO CÁO SPAM (Từ chối bẫy nợ)", "correct": true, "jar": "none", "note": "Quá thông minh! Bẫy 0% thực chất ẩn chứa phí hồ sơ và lãi phạt chậm trả lên tới 40-50%!"},
			{"text": "Vay thử mua dùng trước sướng sau", "correct": false, "jar": "emergency", "penalty": 200000, "note": "Dính bẫy nợ! Bạn bị trừ 200.000đ phí ẩn và lãi phạt tín dụng đen!"}
		]
	},
	{
		"week": "TUẦN 3",
		"title": "📚 Mua Sách Giáo Trình & Khóa Học",
		"desc": "Mua bộ sách giáo trình chuyên ngành và tài liệu học ngoại ngữ kỳ 1 hết 180.000đ.",
		"cost": 180000,
		"target_jar": "growth",
		"choices": [
			{"text": "Chi 180.000đ từ HŨ PHÁT TRIỂN", "correct": true, "jar": "growth", "note": "Rất chuẩn! Đầu tư vào tri thức và kỹ năng là mục đích của hũ 30% phát triển."},
			{"text": "Rút từ HŨ KHẨN CẤP", "correct": false, "jar": "emergency", "note": "Mua sách có kế hoạch từ trước, không phải sự cố khẩn cấp."}
		]
	},
	{
		"week": "TUẦN 4",
		"title": "🍲 Cuối Tháng: Bạn Bè Rủ Đi Ăn Lẩu 400k",
		"desc": "Hội bạn rủ đi ăn lẩu sang chảnh 400.000đ/người. Ví tiền cuối tháng còn hạn chế.",
		"cost": 80000,
		"target_jar": "essential",
		"choices": [
			{"text": "Rủ bạn mua đồ về trọ tự nấu lẩu (80.000đ/người)", "correct": true, "jar": "essential", "note": "Tuyệt vời! Vừa gắn kết bạn bè vừa giữ gìn kỷ luật tài chính không bị cháy túi!"},
			{"text": "Cố đi ăn lẩu 400k rồi vay nợ bạn bè", "correct": false, "jar": "essential", "penalty": 400000, "note": "Hũ thiết yếu bị âm tiền! Bạn phải ăn mì tôm cả tuần sau!"}
		]
	}
]

# UI references
var lbl_total_budget: Label
var lbl_wallet_unallocated: Label

# Jar 1 (Essential)
var edit_essential: LineEdit
var slider_essential: HSlider
var lbl_percent_essential: Label

# Jar 2 (Growth)
var edit_growth: LineEdit
var slider_growth: HSlider
var lbl_percent_growth: Label

# Jar 3 (Emergency)
var edit_emergency: LineEdit
var slider_emergency: HSlider
var lbl_percent_emergency: Label

var btn_lock_budget: Button
var btn_quick_503020: Button
var btn_quick_reset: Button

# Phase 2: Simulation card
var event_card: PanelContainer
var lbl_event_week: Label
var lbl_event_title: Label
var lbl_event_desc: Label
var choices_vbox: VBoxContainer
var result_modal: PanelContainer
var lbl_result_title: Label
var lbl_result_desc: Label
var btn_next_event: Button

func _ready() -> void:
	_build_ui()
	_update_all_displays()
	lbl_event_week.text = "🎯 GIAI ĐOẠN 1: PHÂN BỔ"
	lbl_event_title.text = "Kéo Thanh Trượt Hoặc Nhập Số"
	lbl_event_desc.text = "Kéo thanh cuộn (0 -> 2.000.000đ) hoặc gõ số tiền vào từng hũ. Bạn có thể bấm [Gợi ý tỷ lệ vàng 50-30-20] để điền nhanh, sau đó bấm [Xác nhận phân bổ] để bắt đầu thử thách 30 ngày sinh tồn."

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#FFFDF9")
	add_child(bg)

	var outer_scroll = ScrollContainer.new()
	outer_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(outer_scroll)

	var main_vbox = VBoxContainer.new()
	main_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_vbox.set("theme_override_constants/separation", 8)
	outer_scroll.add_child(main_vbox)

	# 1. Header
	var header = PanelContainer.new()
	header.custom_minimum_size = Vector2(0, 48)
	var h_sb = StyleBoxFlat.new()
	h_sb.bg_color = Color("#7C3AED")
	h_sb.content_margin_left = 12
	h_sb.content_margin_right = 12
	header.add_theme_stylebox_override("panel", h_sb)
	main_vbox.add_child(header)

	var header_hbox = HBoxContainer.new()
	header.add_child(header_hbox)

	var btn_back = Button.new()
	btn_back.name = "BtnBack"
	btn_back.text = "⬅ QUAY LẠI"
	btn_back.custom_minimum_size = Vector2(85, 32)
	btn_back.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var back_sb = StyleBoxFlat.new()
	back_sb.bg_color = Color("#5B21B6")
	back_sb.border_color = Color("#C4B5FD")
	back_sb.set_border_width_all(1)
	back_sb.set_corner_radius_all(4)
	btn_back.add_theme_stylebox_override("normal", back_sb)
	btn_back.add_theme_color_override("font_color", Color.WHITE)
	btn_back.pressed.connect(_on_back_pressed)
	header_hbox.add_child(btn_back)

	var title_lbl = Label.new()
	title_lbl.text = "💰 3 HŨ NGÂN SÁCH 2.000.000 VNĐ (THÁNG TỰ LẬP)"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", Color.WHITE)
	header_hbox.add_child(title_lbl)

	# 2. Total Budget Banner & Unallocated Wallet
	var tot_panel = PanelContainer.new()
	var tot_sb = StyleBoxFlat.new()
	tot_sb.bg_color = Color("#F5F3FF")
	tot_sb.border_color = Color("#7C3AED")
	tot_sb.set_border_width_all(2)
	tot_sb.set_corner_radius_all(8)
	tot_sb.content_margin_left = 14
	tot_sb.content_margin_right = 14
	tot_sb.content_margin_top = 8
	tot_sb.content_margin_bottom = 8
	tot_panel.add_theme_stylebox_override("panel", tot_sb)
	main_vbox.add_child(tot_panel)

	var tot_vbox = VBoxContainer.new()
	tot_vbox.set("theme_override_constants/separation", 4)
	tot_panel.add_child(tot_vbox)

	var row1 = HBoxContainer.new()
	tot_vbox.add_child(row1)

	var lbl_l1 = Label.new()
	lbl_l1.text = "💵 Tổng ngân sách tháng:"
	lbl_l1.add_theme_font_size_override("font_size", 11)
	lbl_l1.add_theme_color_override("font_color", Color("#4C1D95"))
	row1.add_child(lbl_l1)

	lbl_total_budget = Label.new()
	lbl_total_budget.text = "2.000.000 đ"
	lbl_total_budget.add_theme_font_size_override("font_size", 13)
	lbl_total_budget.add_theme_color_override("font_color", Color("#15803D"))
	lbl_total_budget.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_total_budget.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row1.add_child(lbl_total_budget)

	var row2 = HBoxContainer.new()
	tot_vbox.add_child(row2)

	lbl_wallet_unallocated = Label.new()
	lbl_wallet_unallocated.text = "Ví chưa phân bổ: 0 đ"
	lbl_wallet_unallocated.add_theme_font_size_override("font_size", 10)
	lbl_wallet_unallocated.add_theme_color_override("font_color", Color("#059669"))
	lbl_wallet_unallocated.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row2.add_child(lbl_wallet_unallocated)

	# 3. Quick Action Buttons (Preset 50/30/20 & Reset)
	var quick_hbox = HBoxContainer.new()
	quick_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	quick_hbox.set("theme_override_constants/separation", 8)
	main_vbox.add_child(quick_hbox)

	btn_quick_503020 = Button.new()
	btn_quick_503020.text = "⚡ GỢI Ý TỶ LỆ VÀNG 50 - 30 - 20"
	btn_quick_503020.custom_minimum_size = Vector2(230, 30)
	btn_quick_503020.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_quick_503020.add_theme_font_size_override("font_size", 10)
	var b50_sb = StyleBoxFlat.new()
	b50_sb.bg_color = Color("#FEF3C7")
	b50_sb.border_color = Color("#D97706")
	b50_sb.set_border_width_all(2)
	b50_sb.set_corner_radius_all(6)
	btn_quick_503020.add_theme_stylebox_override("normal", b50_sb)
	btn_quick_503020.add_theme_color_override("font_color", Color("#92400E"))
	btn_quick_503020.pressed.connect(_on_quick_503020_pressed)
	quick_hbox.add_child(btn_quick_503020)

	btn_quick_reset = Button.new()
	btn_quick_reset.text = "🔄 ĐẶT VỀ 0Đ ĐỂ KÉO LẠI"
	btn_quick_reset.custom_minimum_size = Vector2(170, 30)
	btn_quick_reset.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_quick_reset.add_theme_font_size_override("font_size", 10)
	var br_sb = StyleBoxFlat.new()
	br_sb.bg_color = Color("#F3F4F6")
	br_sb.border_color = Color("#9CA3AF")
	br_sb.set_border_width_all(2)
	br_sb.set_corner_radius_all(6)
	btn_quick_reset.add_theme_stylebox_override("normal", br_sb)
	btn_quick_reset.add_theme_color_override("font_color", Color("#374151"))
	btn_quick_reset.pressed.connect(_on_quick_reset_pressed)
	quick_hbox.add_child(btn_quick_reset)

	# 4. 3 Glass Jars Row (With Scroll/Sliders & LineEdit Inputs)
	var jars_center = CenterContainer.new()
	main_vbox.add_child(jars_center)

	var jars_hbox = HBoxContainer.new()
	jars_hbox.set("theme_override_constants/separation", 8)
	jars_center.add_child(jars_hbox)

	# Jar 1: Essential
	var j1 = _build_interactive_jar_card(
		"res://assets/sprites/minigames/budget/jar_essential.png",
		"HŨ THIẾT YẾU",
		Color("#2A9D8F"),
		"essential",
		jar_essential
	)
	edit_essential = j1.edit
	slider_essential = j1.slider
	lbl_percent_essential = j1.percent_lbl
	jars_hbox.add_child(j1.panel)

	# Jar 2: Growth
	var j2 = _build_interactive_jar_card(
		"res://assets/sprites/minigames/budget/jar_growth.png",
		"HŨ PHÁT TRIỂN",
		Color("#3A86FF"),
		"growth",
		jar_growth
	)
	edit_growth = j2.edit
	slider_growth = j2.slider
	lbl_percent_growth = j2.percent_lbl
	jars_hbox.add_child(j2.panel)

	# Jar 3: Emergency
	var j3 = _build_interactive_jar_card(
		"res://assets/sprites/minigames/budget/jar_emergency.png",
		"HŨ KHẨN CẤP",
		Color("#E76F51"),
		"emergency",
		jar_emergency
	)
	edit_emergency = j3.edit
	slider_emergency = j3.slider
	lbl_percent_emergency = j3.percent_lbl
	jars_hbox.add_child(j3.panel)

	# 5. Lock Budget & Start Simulation Button
	var lock_center = CenterContainer.new()
	main_vbox.add_child(lock_center)

	btn_lock_budget = Button.new()
	btn_lock_budget.text = "🔒 XÁC NHẬN PHÂN BỔ & BẮT ĐẦU 30 NGÀY SINH TỒN ▶"
	btn_lock_budget.custom_minimum_size = Vector2(460, 38)
	btn_lock_budget.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_lock_budget.add_theme_font_size_override("font_size", 11)
	var lock_sb = StyleBoxFlat.new()
	lock_sb.bg_color = Color("#10B981")
	lock_sb.border_color = Color("#059669")
	lock_sb.set_border_width_all(2)
	lock_sb.border_width_bottom = 4
	lock_sb.set_corner_radius_all(8)
	btn_lock_budget.add_theme_stylebox_override("normal", lock_sb)
	btn_lock_budget.add_theme_color_override("font_color", Color.WHITE)
	btn_lock_budget.pressed.connect(_on_lock_budget_pressed)
	lock_center.add_child(btn_lock_budget)

	# 6. Life Event Simulator Card (Phase 2)
	event_card = PanelContainer.new()
	event_card.custom_minimum_size = Vector2(460, 0)
	var ev_sb = StyleBoxFlat.new()
	ev_sb.bg_color = Color("#FFFDF9")
	ev_sb.border_color = Color("#8D5B36")
	ev_sb.set_border_width_all(3)
	ev_sb.border_width_bottom = 6
	ev_sb.set_corner_radius_all(12)
	ev_sb.content_margin_left = 16
	ev_sb.content_margin_right = 16
	ev_sb.content_margin_top = 12
	ev_sb.content_margin_bottom = 12
	ev_sb.shadow_size = 10
	ev_sb.shadow_color = Color(0, 0, 0, 0.15)
	event_card.add_theme_stylebox_override("panel", ev_sb)
	
	var ev_center = CenterContainer.new()
	ev_center.add_child(event_card)
	main_vbox.add_child(ev_center)

	var ev_vbox = VBoxContainer.new()
	ev_vbox.set("theme_override_constants/separation", 8)
	event_card.add_child(ev_vbox)

	var ev_top_hbox = HBoxContainer.new()
	ev_vbox.add_child(ev_top_hbox)

	lbl_event_week = Label.new()
	lbl_event_week.text = "📅 TUẦN 1 / 4"
	lbl_event_week.add_theme_font_size_override("font_size", 10)
	lbl_event_week.add_theme_color_override("font_color", Color("#B45309"))
	ev_top_hbox.add_child(lbl_event_week)

	lbl_event_title = Label.new()
	lbl_event_title.text = "Tình huống đời thực"
	lbl_event_title.add_theme_font_size_override("font_size", 12)
	lbl_event_title.add_theme_color_override("font_color", Color("#4A2E1B"))
	lbl_event_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_event_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ev_top_hbox.add_child(lbl_event_title)

	lbl_event_desc = Label.new()
	lbl_event_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_event_desc.add_theme_font_size_override("font_size", 11)
	lbl_event_desc.add_theme_color_override("font_color", Color("#2E1C0C"))
	ev_vbox.add_child(lbl_event_desc)

	choices_vbox = VBoxContainer.new()
	choices_vbox.set("theme_override_constants/separation", 8)
	ev_vbox.add_child(choices_vbox)

	# 7. Result Feedback Modal
	result_modal = PanelContainer.new()
	result_modal.visible = false
	result_modal.custom_minimum_size = Vector2(460, 0)
	var res_sb = StyleBoxFlat.new()
	res_sb.bg_color = Color("#FFFBEB")
	res_sb.border_color = Color("#D97706")
	res_sb.set_border_width_all(3)
	res_sb.set_corner_radius_all(10)
	res_sb.content_margin_left = 14
	res_sb.content_margin_right = 14
	res_sb.content_margin_top = 10
	res_sb.content_margin_bottom = 10
	result_modal.add_theme_stylebox_override("panel", res_sb)
	
	var res_center = CenterContainer.new()
	res_center.add_child(result_modal)
	main_vbox.add_child(res_center)

	var res_vbox = VBoxContainer.new()
	res_vbox.set("theme_override_constants/separation", 6)
	result_modal.add_child(res_vbox)

	lbl_result_title = Label.new()
	lbl_result_title.add_theme_font_size_override("font_size", 12)
	res_vbox.add_child(lbl_result_title)

	lbl_result_desc = Label.new()
	lbl_result_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_result_desc.add_theme_font_size_override("font_size", 10)
	res_vbox.add_child(lbl_result_desc)

	btn_next_event = Button.new()
	btn_next_event.text = "TIẾP TỤC BƯỚC TIẾP THEO ▶"
	btn_next_event.custom_minimum_size = Vector2(0, 32)
	btn_next_event.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_next_event.pressed.connect(_on_next_pressed)
	res_vbox.add_child(btn_next_event)

func _build_interactive_jar_card(icon_path: String, title: String, col: Color, jar_key: String, initial_val: int) -> Dictionary:
	var pc = PanelContainer.new()
	pc.custom_minimum_size = Vector2(150, 240)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color("#FFFDF9")
	sb.border_color = col
	sb.set_border_width_all(2)
	sb.border_width_bottom = 4
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 6
	sb.content_margin_right = 6
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	pc.add_theme_stylebox_override("panel", sb)

	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.set("theme_override_constants/separation", 4)
	pc.add_child(vbox)

	var tex = TextureRect.new()
	tex.texture = GameManager.load_texture(icon_path)
	tex.custom_minimum_size = Vector2(50, 65)
	tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(tex)

	var t_lbl = Label.new()
	t_lbl.text = title
	t_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t_lbl.add_theme_font_size_override("font_size", 9)
	t_lbl.add_theme_color_override("font_color", col)
	vbox.add_child(t_lbl)

	# Percentage & Ratio label
	var pct_lbl = Label.new()
	pct_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pct_lbl.add_theme_font_size_override("font_size", 9)
	pct_lbl.add_theme_color_override("font_color", Color("#1F2937"))
	vbox.add_child(pct_lbl)

	# Direct Number Input (LineEdit)
	var edit = LineEdit.new()
	edit.text = str(initial_val)
	edit.placeholder_text = "Nhập số..."
	edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	edit.custom_minimum_size = Vector2(0, 26)
	edit.add_theme_font_size_override("font_size", 10)
	
	var edit_sb = StyleBoxFlat.new()
	edit_sb.bg_color = Color("#FFFFFF")
	edit_sb.border_color = col
	edit_sb.set_border_width_all(1)
	edit_sb.set_corner_radius_all(4)
	edit_sb.content_margin_left = 4
	edit_sb.content_margin_right = 4
	edit.add_theme_stylebox_override("normal", edit_sb)
	edit.add_theme_stylebox_override("focus", edit_sb)
	edit.add_theme_color_override("font_color", Color("#2E1C0C"))
	edit.text_changed.connect(func(txt): _on_input_text_changed(jar_key, txt))
	vbox.add_child(edit)

	# Scroll / Slider (min 0, max 2.000.000đ, step 10.000đ)
	var slider = HSlider.new()
	slider.min_value = 0
	slider.max_value = TOTAL_INCOME
	slider.step = 10000
	slider.value = initial_val
	slider.custom_minimum_size = Vector2(130, 16)
	slider.value_changed.connect(func(val): _on_slider_value_changed(jar_key, val))
	vbox.add_child(slider)

	return {"panel": pc, "edit": edit, "slider": slider, "percent_lbl": pct_lbl}

# Real-time allocation callbacks
func _on_slider_value_changed(jar_key: String, new_val: float) -> void:
	if is_budget_locked:
		return
	var int_val = int(new_val)
	_set_jar_value(jar_key, int_val, true)

func _on_input_text_changed(jar_key: String, new_text: String) -> void:
	if is_budget_locked:
		return
	var digits = ""
	for c in new_text:
		if c >= "0" and c <= "9":
			digits += c
	var int_val = int(digits) if digits != "" else 0
	_set_jar_value(jar_key, int_val, false)

func _set_jar_value(jar_key: String, val: int, update_edit: bool) -> void:
	val = clampi(val, 0, TOTAL_INCOME)
	match jar_key:
		"essential":
			jar_essential = val
			if update_edit and edit_essential.text != str(val):
				edit_essential.text = str(val)
			if slider_essential.value != val:
				slider_essential.value = val
		"growth":
			jar_growth = val
			if update_edit and edit_growth.text != str(val):
				edit_growth.text = str(val)
			if slider_growth.value != val:
				slider_growth.value = val
		"emergency":
			jar_emergency = val
			if update_edit and edit_emergency.text != str(val):
				edit_emergency.text = str(val)
			if slider_emergency.value != val:
				slider_emergency.value = val

	_update_all_displays()

func _update_all_displays() -> void:
	var total_allocated = jar_essential + jar_growth + jar_emergency
	var unallocated = TOTAL_INCOME - total_allocated

	# Update Jar Percentages
	var p_ess = (float(jar_essential) / TOTAL_INCOME) * 100.0
	var p_gro = (float(jar_growth) / TOTAL_INCOME) * 100.0
	var p_eme = (float(jar_emergency) / TOTAL_INCOME) * 100.0

	lbl_percent_essential.text = "%d%% (%s đ)" % [int(p_ess), _format_vnd(jar_essential)]
	lbl_percent_growth.text = "%d%% (%s đ)" % [int(p_gro), _format_vnd(jar_growth)]
	lbl_percent_emergency.text = "%d%% (%s đ)" % [int(p_eme), _format_vnd(jar_emergency)]

	# Update Unallocated Status
	if unallocated == 0:
		lbl_wallet_unallocated.text = "✅ Đã phân bổ vừa khớp 100% ngân sách (0 đ dư)!"
		lbl_wallet_unallocated.add_theme_color_override("font_color", Color("#15803D"))
		btn_lock_budget.disabled = false
		btn_lock_budget.text = "🔒 XÁC NHẬN PHÂN BỔ & BẮT ĐẦU 30 NGÀY SINH TỒN ▶"
	elif unallocated > 0:
		lbl_wallet_unallocated.text = "ℹ️ Ví còn %s đ chưa phân bổ vào hũ nào!" % _format_vnd(unallocated)
		lbl_wallet_unallocated.add_theme_color_override("font_color", Color("#D97706"))
		btn_lock_budget.disabled = false
		btn_lock_budget.text = "🔒 VẪN CÒN TIỀN DƯ - BẮT ĐẦU VỚI SỐ DƯ HIỆN TẠI ▶"
	else:
		lbl_wallet_unallocated.text = "⚠️ Vượt quá ngân sách: -%s đ! Hãy kéo giảm bớt." % _format_vnd(abs(unallocated))
		lbl_wallet_unallocated.add_theme_color_override("font_color", Color("#DC2626"))
		btn_lock_budget.disabled = true
		btn_lock_budget.text = "❌ KHÔNG THỂ BẮT ĐẦU: NGÂN SÁCH ĐANG BỊ ÂM!"

func _on_quick_503020_pressed() -> void:
	SoundManager.play_click()
	_set_jar_value("essential", 1000000, true)
	_set_jar_value("growth", 600000, true)
	_set_jar_value("emergency", 400000, true)

func _on_quick_reset_pressed() -> void:
	SoundManager.play_click()
	_set_jar_value("essential", 0, true)
	_set_jar_value("growth", 0, true)
	_set_jar_value("emergency", 0, true)

func _on_lock_budget_pressed() -> void:
	SoundManager.play_success()
	is_budget_locked = true
	edit_essential.editable = false
	edit_growth.editable = false
	edit_emergency.editable = false
	slider_essential.editable = false
	slider_growth.editable = false
	slider_emergency.editable = false
	btn_quick_503020.disabled = true
	btn_quick_reset.disabled = true
	btn_lock_budget.visible = false

	# Show Life Events
	_show_event(0)

# Phase 2: Simulation Events
func _show_event(idx: int) -> void:
	current_event_idx = idx
	result_modal.visible = false

	if idx >= life_events.size():
		_show_final_victory()
		return

	var ev = life_events[idx]
	lbl_event_week.text = "📅 " + ev.week + " (" + str(idx + 1) + "/" + str(life_events.size()) + ")"
	lbl_event_title.text = ev.title
	lbl_event_desc.text = ev.desc

	for child in choices_vbox.get_children():
		child.queue_free()

	for ch in ev.choices:
		var btn = Button.new()
		btn.text = ch.text
		btn.custom_minimum_size = Vector2(0, 36)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.add_theme_font_size_override("font_size", 10)
		var choice_data = ch
		var event_data = ev
		btn.pressed.connect(func(): _on_choice_selected(choice_data, event_data))
		choices_vbox.add_child(btn)

func _on_choice_selected(choice: Dictionary, ev: Dictionary) -> void:
	if choice.correct:
		SoundManager.play_success()
		lbl_result_title.text = "✅ QUYẾT ĐỊNH THÔNG THÁI!"
		lbl_result_title.add_theme_color_override("font_color", Color("#15803D"))
		# Deduct cost from right jar
		if choice.jar == "essential":
			jar_essential = max(0, jar_essential - ev.cost)
		elif choice.jar == "growth":
			jar_growth = max(0, jar_growth - ev.cost)
		elif choice.jar == "emergency":
			jar_emergency = max(0, jar_emergency - ev.cost)
	else:
		SoundManager.play_click()
		safe_failures += 1
		lbl_result_title.text = "⚠️ BẪY TÀI CHÍNH / SAI LẦM!"
		lbl_result_title.add_theme_color_override("font_color", Color("#DC2626"))
		var pen = choice.get("penalty", ev.cost)
		if choice.jar == "emergency":
			jar_emergency = max(0, jar_emergency - pen)
		else:
			jar_essential = max(0, jar_essential - pen)

	lbl_result_desc.text = choice.note
	result_modal.visible = true
	_update_all_displays()

func _on_next_pressed() -> void:
	_show_event(current_event_idx + 1)

func _show_final_victory() -> void:
	SoundManager.play_success()
	lbl_event_week.text = "🏆 TỔNG KẾT 30 NGÀY SINH TỒN"
	lbl_event_title.text = "QUẢN LÝ TÀI CHÍNH XUẤT SẮC"
	var total_remaining = jar_essential + jar_growth + jar_emergency
	lbl_event_desc.text = "Chúc mừng bạn đã xuất sắc vượt qua tháng đầu tiên tự lập!\n\nSố dư cuối tháng:\n- Hũ Thiết yếu: " + _format_vnd(jar_essential) + " đ\n- Hũ Phát triển: " + _format_vnd(jar_growth) + " đ\n- Hũ Khẩn cấp: " + _format_vnd(jar_emergency) + " đ\n\n👉 Tổng tiết kiệm dư: " + _format_vnd(total_remaining) + " VNĐ!\nBạn đã nhận danh hiệu: MÈO TÀI CHÍNH THÔNG THÁI!"

	for child in choices_vbox.get_children():
		child.queue_free()

	var btn_finish = Button.new()
	btn_finish.text = "🎉 HOÀN THÀNH VÀ TRỞ VỀ MENU"
	btn_finish.custom_minimum_size = Vector2(0, 38)
	btn_finish.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_finish.pressed.connect(_on_back_pressed)
	choices_vbox.add_child(btn_finish)

	emit_signal("minigame_completed", {"status": "victory", "remaining_funds": total_remaining, "safe_failures": safe_failures})

func _format_vnd(val: int) -> String:
	var s = str(val)
	var res = ""
	var cnt = 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		cnt += 1
		if cnt % 3 == 0 and i > 0:
			res = "." + res
	return res

func _on_back_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
