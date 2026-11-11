extends Control

# HandbookView.gd - Cẩm Nang Cứu Sen Bỏ Túi Mở 24/7 (Emergency Pocket Handbook)
# Thiết kế phong cách Sổ Tay Sinh Viên / Journal Note thủ công, ấm cúng, trực quan

signal back_to_room

@onready var btn_back: Button = get_node_or_null("BtnBack")
@onready var search_box: LineEdit = $SearchBar/SearchEdit
@onready var lessons_container: VBoxContainer = $ScrollContainer/LessonsContainer
@onready var detail_modal: Control = $DetailModal
@onready var detail_title: Label = $DetailModal/Panel/VBox/DetailTitle
@onready var detail_scroll: ScrollContainer = $DetailModal/Panel/VBox/Scroll
@onready var detail_text: Label = $DetailModal/Panel/VBox/Scroll/DetailText
@onready var btn_close_detail: Button = $DetailModal/Panel/VBox/BtnCloseDetail

var current_keyword: String = ""

# Danh mục phân loại & màu sắc nhận diện
const CATEGORY_COLORS = {
	"tai_chinh": {"bg": Color(1.0, 0.95, 0.88), "border": Color(1.0, 0.70, 0.35), "text": Color(0.85, 0.40, 0.05), "icon": "💰"},
	"nha_tro": {"bg": Color(1.0, 0.92, 0.90), "border": Color(1.0, 0.65, 0.55), "text": Color(0.80, 0.30, 0.15), "icon": "🏠"},
	"suc_khoe": {"bg": Color(0.88, 0.96, 0.94), "border": Color(0.55, 0.85, 0.78), "text": Color(0.10, 0.55, 0.42), "icon": "🩺"},
	"an_toan": {"bg": Color(1.0, 0.92, 0.93), "border": Color(1.0, 0.65, 0.70), "text": Color(0.82, 0.20, 0.28), "icon": "🛡️"},
	"di_lai": {"bg": Color(0.90, 0.94, 1.0), "border": Color(0.60, 0.75, 1.0), "text": Color(0.15, 0.40, 0.85), "icon": "🚌"},
	"default": {"bg": Color(0.94, 0.92, 0.98), "border": Color(0.75, 0.68, 0.92), "text": Color(0.40, 0.25, 0.75), "icon": "⚡"}
}

func _ready() -> void:
	if btn_back:
		var back_style = StyleBoxFlat.new()
		back_style.bg_color = Color(0.96, 0.93, 0.89, 1.0)
		back_style.border_color = Color(0.82, 0.74, 0.66, 1.0)
		back_style.set_border_width_all(2)
		back_style.border_width_bottom = 3
		back_style.set_corner_radius_all(12)
		back_style.content_margin_left = 10
		back_style.content_margin_right = 10
		back_style.content_margin_top = 4
		back_style.content_margin_bottom = 4
		btn_back.add_theme_stylebox_override("normal", back_style)
		btn_back.add_theme_stylebox_override("hover", back_style)
		btn_back.add_theme_stylebox_override("pressed", back_style)
		btn_back.add_theme_color_override("font_color", Color(0.38, 0.26, 0.16, 1.0))
		btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
		btn_back.text = " Thoát"
		btn_back.pressed.connect(func():
			SoundManager.play_click()
			emit_signal("back_to_room")
		)

	search_box.text_changed.connect(_on_search_changed)
	btn_close_detail.pressed.connect(func(): 
		SoundManager.play_click()
		detail_modal.visible = false
	)
	detail_modal.visible = false
	_style_search_bar()
	render_handbook()

func _style_search_bar() -> void:
	var s_style = StyleBoxFlat.new()
	s_style.bg_color = Color(1.0, 0.98, 0.95, 1.0)
	s_style.border_color = Color(0.85, 0.72, 0.58, 1.0)
	s_style.set_border_width_all(2)
	s_style.set_corner_radius_all(10)
	s_style.content_margin_left = 14
	s_style.content_margin_right = 14
	s_style.content_margin_top = 8
	s_style.content_margin_bottom = 8
	search_box.add_theme_stylebox_override("normal", s_style)
	search_box.add_theme_stylebox_override("focus", s_style)
	search_box.add_theme_color_override("font_color", Color(0.25, 0.18, 0.12))
	search_box.add_theme_color_override("font_placeholder_color", Color(0.60, 0.52, 0.45))

func _on_search_changed(new_text: String) -> void:
	current_keyword = new_text.to_lower().strip_edges()
	render_handbook()

func _get_category_info(lesson: Dictionary) -> Dictionary:
	var branch_num = lesson.get("branch", 0)
	if branch_num == 1:
		return CATEGORY_COLORS["di_lai"]
	elif branch_num == 2:
		return CATEGORY_COLORS["nha_tro"]
	elif branch_num == 3:
		return CATEGORY_COLORS["suc_khoe"]
	elif branch_num == 4:
		return CATEGORY_COLORS["tai_chinh"]
		
	var branch_id = lesson.get("branch_id", "")
	if CATEGORY_COLORS.has(branch_id):
		return CATEGORY_COLORS[branch_id]
	var b_name = lesson.get("branch_name", "").to_lower()
	if "tài chính" in b_name or "tiền" in b_name:
		return CATEGORY_COLORS["tai_chinh"]
	elif "trọ" in b_name or "nhà" in b_name or "nơi ở" in b_name or "pháp lý" in b_name:
		return CATEGORY_COLORS["nha_tro"]
	elif "sức khỏe" in b_name or "y tế" in b_name:
		return CATEGORY_COLORS["suc_khoe"]
	elif "an toàn" in b_name or "lừa" in b_name:
		return CATEGORY_COLORS["an_toan"]
	elif "xe" in b_name or "đi" in b_name:
		return CATEGORY_COLORS["di_lai"]
	return CATEGORY_COLORS["default"]

func render_handbook() -> void:
	for child in lessons_container.get_children():
		child.queue_free()
		
	var rendered_count = 0
	
	for id in range(1, 17):
		var lesson = GameManager.lessons_data[id]
		var title_lower = lesson["title"].to_lower()
		var context_lower = lesson["context"].to_lower()
		var branch_lower = lesson["branch_name"].to_lower()
		
		if current_keyword != "" and not (current_keyword in title_lower or current_keyword in context_lower or current_keyword in branch_lower):
			continue
			
		rendered_count += 1
		var cat_info = _get_category_info(lesson)
		
		# Thẻ bài học phong cách Sổ Tay Giấy Note
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 74)
		
		var c_style = StyleBoxFlat.new()
		c_style.bg_color = Color(0.99, 0.98, 0.95, 1.0) # Màu giấy kem ấm
		c_style.border_color = Color(0.86, 0.76, 0.66, 1.0)
		c_style.set_border_width_all(1)
		c_style.border_width_bottom = 3 # Hiệu ứng nổi 3D
		c_style.set_corner_radius_all(12)
		c_style.content_margin_left = 12
		c_style.content_margin_right = 12
		c_style.content_margin_top = 8
		c_style.content_margin_bottom = 8
		c_style.shadow_color = Color(0.2, 0.15, 0.1, 0.06)
		c_style.shadow_size = 4
		c_style.shadow_offset = Vector2(0, 2)
		card.add_theme_stylebox_override("panel", c_style)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 12)
		
		# Icon tròn nổi bật
		var icon_badge = PanelContainer.new()
		icon_badge.custom_minimum_size = Vector2(48, 48)
		icon_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var ib_style = StyleBoxFlat.new()
		ib_style.bg_color = cat_info["bg"]
		ib_style.border_color = cat_info["border"]
		ib_style.set_border_width_all(1)
		ib_style.set_corner_radius_all(10)
		icon_badge.add_theme_stylebox_override("panel", ib_style)
		
		var step1_asset = "res://assets/sprites/skills/lesson_%02d_step_1.png" % id
		if ResourceLoader.exists(step1_asset):
			var tr = TextureRect.new()
			tr.texture = load(step1_asset)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tr.custom_minimum_size = Vector2(32, 32)
			tr.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			tr.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			icon_badge.add_child(tr)
		else:
			var icon_lbl = Label.new()
			icon_lbl.text = cat_info["icon"]
			icon_lbl.add_theme_font_size_override("font_size", 22)
			icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			icon_badge.add_child(icon_lbl)
		
		# Khối thông tin giữa
		var v_text = VBoxContainer.new()
		v_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v_text.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		v_text.add_theme_constant_override("separation", 3)
		
		# Hàng tiêu đề + Tag số bài
		var top_h = HBoxContainer.new()
		top_h.add_theme_constant_override("separation", 6)
		
		var num_tag = Label.new()
		num_tag.text = "#%02d" % id
		num_tag.add_theme_font_size_override("font_size", 10)
		num_tag.add_theme_color_override("font_color", cat_info["text"])
		
		var title_lbl = Label.new()
		title_lbl.text = lesson["title"]
		title_lbl.add_theme_font_size_override("font_size", 13)
		title_lbl.add_theme_color_override("font_color", Color(0.22, 0.16, 0.10))
		
		top_h.add_child(num_tag)
		top_h.add_child(title_lbl)
		
		# Nhãn nhánh & gợi ý ngắn
		var branch_lbl = Label.new()
		branch_lbl.text = "%s • %s" % [lesson["branch_name"], lesson.get("cheat_sheet", "Quy trình chuẩn 3 bước")]
		branch_lbl.add_theme_font_size_override("font_size", 10)
		branch_lbl.add_theme_color_override("font_color", Color(0.55, 0.48, 0.40))
		branch_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		
		v_text.add_child(top_h)
		v_text.add_child(branch_lbl)
		
		# Nút "Đọc Sổ Tay" phong cách tem dán Washi Tape
		var read_btn = Button.new()
		read_btn.custom_minimum_size = Vector2(86, 36)
		read_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		read_btn.text = "📖 Đọc Ngay"
		read_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var b_style = StyleBoxFlat.new()
		b_style.bg_color = Color(1.0, 0.90, 0.65, 1.0) # Vàng mật ong ấm
		b_style.border_color = Color(0.85, 0.62, 0.22, 1.0)
		b_style.set_border_width_all(1)
		b_style.border_width_bottom = 2
		b_style.set_corner_radius_all(18)
		b_style.content_margin_left = 8
		b_style.content_margin_right = 8
		read_btn.add_theme_stylebox_override("normal", b_style)
		read_btn.add_theme_color_override("font_color", Color(0.35, 0.22, 0.08))
		read_btn.add_theme_font_size_override("font_size", 11)
		
		var cur_id = id
		read_btn.pressed.connect(func(): _open_detail(cur_id))
		
		hbox.add_child(icon_badge)
		hbox.add_child(v_text)
		hbox.add_child(read_btn)
		card.add_child(hbox)
		lessons_container.add_child(card)
		
	if rendered_count == 0:
		var empty_lbl = Label.new()
		empty_lbl.text = "😿 Không tìm thấy bài học phù hợp với từ khóa '%s'!" % current_keyword
		empty_lbl.add_theme_font_size_override("font_size", 13)
		empty_lbl.add_theme_color_override("font_color", Color(0.55, 0.45, 0.35))
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lessons_container.add_child(empty_lbl)

## Mở Trang Nhật Ký Cứu Nguy 30 Giây
func _open_detail(lesson_id: int) -> void:
	SoundManager.play_click()
	var lesson = GameManager.lessons_data[lesson_id]
	var cat_info = _get_category_info(lesson)
	
	detail_title.text = "%s BÀI %d: %s" % [cat_info["icon"], lesson_id, lesson["title"].to_upper()]
	
	# Xây dựng nội dung chi tiết dạng các thẻ ghi chú trực quan (Visual Cards)
	var content_vbox = detail_scroll.get_node_or_null("ContentVBox")
	if not content_vbox:
		content_vbox = VBoxContainer.new()
		content_vbox.name = "ContentVBox"
		content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content_vbox.add_theme_constant_override("separation", 12)
		detail_scroll.add_child(content_vbox)
		
	# Xóa nội dung cũ
	for c in content_vbox.get_children():
		c.queue_free()
		
	# 1. HỘP GHI CHÚ GIẤY NOTE: BỐI CẢNH NGOÀI ĐỜI
	var ctx_box = PanelContainer.new()
	var ctx_style = StyleBoxFlat.new()
	ctx_style.bg_color = Color(1.0, 0.98, 0.88, 1.0) # Vàng giấy note
	ctx_style.border_color = Color(0.92, 0.82, 0.50, 1.0)
	ctx_style.set_border_width_all(1)
	ctx_style.border_width_left = 4 # Nẹp note
	ctx_style.set_corner_radius_all(8)
	ctx_style.content_margin_left = 12
	ctx_style.content_margin_right = 12
	ctx_style.content_margin_top = 10
	ctx_style.content_margin_bottom = 10
	ctx_box.add_theme_stylebox_override("panel", ctx_style)
	
	var ctx_v = VBoxContainer.new()
	ctx_v.add_theme_constant_override("separation", 4)
	var ctx_head = Label.new()
	ctx_head.text = "📌 BỐI CẢNH THỰC TẾ SINH VIÊN"
	ctx_head.add_theme_font_size_override("font_size", 12)
	ctx_head.add_theme_color_override("font_color", Color(0.65, 0.35, 0.05))
	
	var ctx_body = Label.new()
	ctx_body.text = lesson["context"]
	ctx_body.add_theme_font_size_override("font_size", 12)
	ctx_body.add_theme_color_override("font_color", Color(0.25, 0.20, 0.15))
	ctx_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	ctx_v.add_child(ctx_head)
	ctx_v.add_child(ctx_body)
	ctx_box.add_child(ctx_v)
	content_vbox.add_child(ctx_box)
	
	# 2. KHỐI QUY TRÌNH 3 BƯỚC CHUẨN ĐỜI THỰC
	var guide_box = VBoxContainer.new()
	guide_box.add_theme_constant_override("separation", 6)
	
	var guide_head = Label.new()
	guide_head.text = "🐾 QUY TRÌNH 3 BƯỚC CHUẨN ĐỜI THỰC (ĐỌC 30 GIÂY)"
	guide_head.add_theme_font_size_override("font_size", 12)
	guide_head.add_theme_color_override("font_color", Color(0.18, 0.38, 0.28))
	guide_box.add_child(guide_head)
	
	var step_idx = 1
	var step_colors = [Color(1.0, 0.60, 0.25), Color(0.25, 0.70, 0.60), Color(0.55, 0.45, 0.85)]
	for line in lesson["guide"]:
		var step_card = PanelContainer.new()
		var sc_style = StyleBoxFlat.new()
		sc_style.bg_color = Color(0.98, 0.97, 0.95, 1.0)
		sc_style.border_color = Color(0.88, 0.82, 0.76, 1.0)
		sc_style.set_border_width_all(1)
		sc_style.set_corner_radius_all(8)
		sc_style.content_margin_left = 10
		sc_style.content_margin_right = 10
		sc_style.content_margin_top = 8
		sc_style.content_margin_bottom = 8
		step_card.add_theme_stylebox_override("panel", sc_style)
		
		var s_hbox = HBoxContainer.new()
		s_hbox.add_theme_constant_override("separation", 10)
		
		var badge = Label.new()
		badge.text = "BƯỚC %d" % step_idx
		badge.add_theme_font_size_override("font_size", 10)
		badge.add_theme_color_override("font_color", step_colors[(step_idx - 1) % 3])
		
		var s_text = Label.new()
		s_text.text = line
		s_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		s_text.add_theme_font_size_override("font_size", 12)
		s_text.add_theme_color_override("font_color", Color(0.22, 0.18, 0.14))
		s_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		s_hbox.add_child(badge)
		s_hbox.add_child(s_text)
		step_card.add_child(s_hbox)
		guide_box.add_child(step_card)
		step_idx += 1
		
	content_vbox.add_child(guide_box)
	
	# 3. HỘP HIGHLIGHT BẢO BỐI TÓM TẮT (CHEAT SHEET)
	var cheat_box = PanelContainer.new()
	var cb_style = StyleBoxFlat.new()
	cb_style.bg_color = Color(0.92, 0.98, 0.94, 1.0) # Xanh mint mát lành
	cb_style.border_color = Color(0.60, 0.85, 0.70, 1.0)
	cb_style.set_border_width_all(1)
	cb_style.set_corner_radius_all(8)
	cb_style.content_margin_left = 12
	cb_style.content_margin_right = 12
	cb_style.content_margin_top = 8
	cb_style.content_margin_bottom = 8
	cheat_box.add_theme_stylebox_override("panel", cb_style)
	
	var cb_v = VBoxContainer.new()
	cb_v.add_theme_constant_override("separation", 3)
	var cb_h = Label.new()
	cb_h.text = "💡 BẢO BỐI NHỚ NHANH:"
	cb_h.add_theme_font_size_override("font_size", 11)
	cb_h.add_theme_color_override("font_color", Color(0.12, 0.55, 0.35))
	var cb_t = Label.new()
	cb_t.text = lesson["cheat_sheet"]
	cb_t.add_theme_font_size_override("font_size", 12)
	cb_t.add_theme_color_override("font_color", Color(0.15, 0.40, 0.25))
	cb_t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	cb_v.add_child(cb_h)
	cb_v.add_child(cb_t)
	cheat_box.add_child(cb_v)
	content_vbox.add_child(cheat_box)
	
	# 4. CHIẾN LỢI PHẨM
	var loot_lbl = Label.new()
	loot_lbl.text = "🎁 Chiến lợi phẩm bảo tàng: %s" % lesson["loot_name"]
	loot_lbl.add_theme_font_size_override("font_size", 11)
	loot_lbl.add_theme_color_override("font_color", Color(0.55, 0.45, 0.30))
	content_vbox.add_child(loot_lbl)
	
	# Đồng bộ label cũ để backward-compatibility với test
	if detail_text:
		detail_text.visible = false
		detail_text.text = lesson["title"] + " - " + lesson["context"]
		
	detail_modal.visible = true
