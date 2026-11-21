extends Control

# SOI PHÒNG TRỌ THỰC TẾ: TÌM ĐIỂM KHÁC BIỆT & SOI BẪY PHÁP LÝ
# Có 3 Màn Chơi Thực Tế với Hình Ảnh Pixel So Sánh Đầy Đủ:
# Màn 1: Căn Phòng Trọ (Ảnh Quảng Cáo vs Ảnh Thực Tế Có 5 Lỗi Kỹ Thuật)
# Màn 2: Cụm Công Tơ Điện & Đồng Hồ Nước (Đấu Trộm / Quay Lén)
# Màn 3: Tờ Hợp Đồng Thuê Nhà (Điều Khoản Bẫy)

signal minigame_completed(result: Dictionary)

var current_stage_idx: int = 0
var stages = [
	{
		"id": "room",
		"title": "Màn 1: Căn Phòng Trọ Thực Tế",
		"ad_img": "res://assets/sprites/minigames/spot_diff/room_ad_clean.png",
		"real_img": "res://assets/sprites/minigames/spot_diff/room_real_traps.png",
		"desc": "So sánh ảnh quảng cáo đẹp đẽ của chủ trọ và phòng thực tế để tìm 5 bẫy hạ tầng:",
		"errors": [
			{
				"id": "leak_tap",
				"name": "Vòi Nước Bồn Rửa Bị Rỉ",
				"desc": "Van nước bị gãy nứt rò rỉ nước liên tục làm đội tiền nước và ẩm mốc bồn rửa.",
				"rect": Rect2(45, 90, 35, 35)
			},
			{
				"id": "ceiling_stain",
				"name": "Mảng Ố Dột Nứt Trần Nhà",
				"desc": "Mưa sẽ ngấm dột vào phòng làm hỏng đồ đạc. Cần yêu cầu chủ trọ xử lý chống thấm trước khi ký hợp đồng.",
				"rect": Rect2(125, 10, 85, 35)
			},
			{
				"id": "door_lock",
				"name": "Ổ Khóa Cửa Chính Bung Ốc",
				"desc": "Ổ khóa lỏng lẻo trộm cắp dễ cạy phá. An ninh phòng trọ là ưu tiên số 1 của sinh viên!",
				"rect": Rect2(275, 95, 30, 30)
			},
			{
				"id": "grill_escape",
				"name": "Chuồng Cọp Bít Sắt Đặc (Không Lối Thoát PCCC)",
				"desc": "Cực kỳ nguy hiểm khi có hỏa hoạn! Chuồng cọp bắt buộc phải có cửa thoát hiểm mở khóa được từ bên trong.",
				"rect": Rect2(350, 40, 50, 55)
			},
			{
				"id": "plug_wire",
				"name": "Ổ Cắm Tường Hở Dây Đồng",
				"desc": "Dây điện trần hở nguy cơ điện giật và chập cháy. Phải bắt buộc chủ trọ thay nắp bảo vệ.",
				"rect": Rect2(170, 110, 30, 35)
			}
		]
	},
	{
		"id": "meter",
		"title": "Màn 2: Soi Công Tơ Điện & Đồng Hồ Nước",
		"ad_img": "res://assets/sprites/minigames/spot_diff/meter_normal.png",
		"real_img": "res://assets/sprites/minigames/spot_diff/meter_tampered.png",
		"desc": "Kiểm tra hiện tượng câu trộm điện nước khi đã gạt cầu dao phòng sang OFF:",
		"errors": [
			{
				"id": "spinning_disk",
				"name": "Đĩa Công Tơ Quay Lén",
				"desc": "Phòng đã tắt hết điện mà công tơ vẫn quay ro ro chứng tỏ bị đấu trộm điện hành lang hoặc máy bơm chung!",
				"rect": Rect2(80, 60, 80, 40)
			},
			{
				"id": "water_needle",
				"name": "Kim Đồng Hồ Nước Tự Nhảy",
				"desc": "Đường ống ngầm trong tường bị vỡ rỉ nước khiến đồng hồ chạy ngày đêm mà bạn không hề hay biết.",
				"rect": Rect2(320, 65, 60, 40)
			},
			{
				"id": "broken_seal",
				"name": "Tem Niêm Chì Bị Rách Gãy",
				"desc": "Đồng hồ không có niêm chì chuẩn của công ty điện lực / nước sạch rất dễ bị chỉnh số ăn gian.",
				"rect": Rect2(250, 95, 30, 30)
			}
		]
	},
	{
		"id": "contract",
		"title": "Màn 3: Bút Dạ Quang Soi Hợp Đồng",
		"ad_img": "res://assets/sprites/minigames/spot_diff/contract_fair.png",
		"real_img": "res://assets/sprites/minigames/spot_diff/contract_traps.png",
		"desc": "Dùng mắt tinh soi các điều khoản bẫy câu chữ sinh viên thường mắc phải:",
		"errors": [
			{
				"id": "trap_electric_price",
				"name": "Giá Điện 5.000đ/Số (Vượt Mức Pháp Luật)",
				"desc": "Nhà nước quy định sinh viên thuê trọ được hưởng giá điện định mức bậc thang (~2.200 - 2.500đ/số), thu 5k là sai luật!",
				"rect": Rect2(80, 70, 270, 25)
			},
			{
				"id": "trap_intrusion",
				"name": "Chủ Trọ Tự Ý Vào Phòng Bất Kỳ Lúc Nào",
				"desc": "Xâm phạm quyền riêng tư và nơi ở bất khả xâm phạm. Chủ trọ chỉ được vào khi có sự đồng ý của người thuê.",
				"rect": Rect2(80, 115, 270, 25)
			},
			{
				"id": "trap_deposit",
				"name": "Tịch Thu Cọc 100% Trong Mọi Trường Hợp",
				"desc": "Điều khoản đơn phương bất công. Nếu chuyển đi báo trước 30 ngày hoặc nhà xuống cấp nghiêm trọng phải được hoàn cọc.",
				"rect": Rect2(80, 140, 270, 25)
			}
		]
	}
]

var found_errors: Array = []

# UI references
var tabs_hbox: HBoxContainer
var lbl_title: Label
var lbl_desc: Label
var lbl_counter: Label
var tex_ad: TextureRect
var tex_real: TextureRect
var real_click_area: Control
var markers_overlay: Control
var popup_dialog: PanelContainer
var lbl_popup_name: Label
var lbl_popup_desc: Label

func _ready() -> void:
	_build_ui()
	_load_stage(0)

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#FFFDF9")
	add_child(bg)

	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.set("theme_override_constants/separation", 6)
	add_child(main_vbox)

	# 1. Header
	var header = PanelContainer.new()
	header.custom_minimum_size = Vector2(0, 48)
	var h_sb = StyleBoxFlat.new()
	h_sb.bg_color = Color("#2563EB")
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
	btn_back.pressed.connect(_on_back_pressed)
	header_hbox.add_child(btn_back)

	var title_lbl = Label.new()
	title_lbl.text = "🔍 THÁM TỬ SOI PHÒNG TRỌ & BẪY PHÁP LÝ"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", Color.WHITE)
	header_hbox.add_child(title_lbl)

	# 2. Stage Tabs
	tabs_hbox = HBoxContainer.new()
	tabs_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs_hbox.set("theme_override_constants/separation", 6)
	main_vbox.add_child(tabs_hbox)

	for i in range(stages.size()):
		var st = stages[i]
		var tab_btn = Button.new()
		tab_btn.text = st.title
		tab_btn.custom_minimum_size = Vector2(150, 32)
		tab_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tab_btn.add_theme_font_size_override("font_size", 9)
		var s_idx = i
		tab_btn.pressed.connect(func(): _load_stage(s_idx))
		tabs_hbox.add_child(tab_btn)

	# 3. Instruction & Counter Banner
	var banner = PanelContainer.new()
	var b_sb = StyleBoxFlat.new()
	b_sb.bg_color = Color("#EFF6FF")
	b_sb.border_color = Color("#2563EB")
	b_sb.set_border_width_all(2)
	b_sb.set_corner_radius_all(8)
	b_sb.content_margin_left = 10
	b_sb.content_margin_right = 10
	b_sb.content_margin_top = 4
	b_sb.content_margin_bottom = 4
	banner.add_theme_stylebox_override("panel", b_sb)
	main_vbox.add_child(banner)

	var b_vbox = VBoxContainer.new()
	banner.add_child(b_vbox)

	var b_top_hbox = HBoxContainer.new()
	b_vbox.add_child(b_top_hbox)

	lbl_title = Label.new()
	lbl_title.add_theme_font_size_override("font_size", 11)
	lbl_title.add_theme_color_override("font_color", Color("#1E3A8A"))
	lbl_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b_top_hbox.add_child(lbl_title)

	lbl_counter = Label.new()
	lbl_counter.add_theme_font_size_override("font_size", 11)
	lbl_counter.add_theme_color_override("font_color", Color("#DC2626"))
	b_top_hbox.add_child(lbl_counter)

	lbl_desc = Label.new()
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_desc.add_theme_font_size_override("font_size", 9)
	lbl_desc.add_theme_color_override("font_color", Color("#4B5563"))
	b_vbox.add_child(lbl_desc)

	# 4. Scrollable Images Container
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)

	var center_img_box = CenterContainer.new()
	center_img_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center_img_box)

	var imgs_vbox = VBoxContainer.new()
	imgs_vbox.set("theme_override_constants/separation", 8)
	center_img_box.add_child(imgs_vbox)

	# Section 1: Standard Ad Image
	var lbl_ad_tag = Label.new()
	lbl_ad_tag.text = "🌟 ẢNH MẪU QUẢNG CÁO CỦA CHỦ TRỌ (TIÊU CHUẨN)"
	lbl_ad_tag.add_theme_font_size_override("font_size", 10)
	lbl_ad_tag.add_theme_color_override("font_color", Color("#15803D"))
	imgs_vbox.add_child(lbl_ad_tag)

	var frame_ad = PanelContainer.new()
	var frame_sb = StyleBoxFlat.new()
	frame_sb.bg_color = Color.BLACK
	frame_sb.border_color = Color("#15803D")
	frame_sb.set_border_width_all(2)
	frame_sb.set_corner_radius_all(6)
	frame_ad.add_theme_stylebox_override("panel", frame_sb)
	imgs_vbox.add_child(frame_ad)

	tex_ad = TextureRect.new()
	tex_ad.custom_minimum_size = Vector2(460, 220)
	tex_ad.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_ad.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	frame_ad.add_child(tex_ad)

	# Section 2: Real Life Inspection Image (Clickable)
	var lbl_real_tag = Label.new()
	lbl_real_tag.text = "🔍 PHÒNG TRỌ THỰC TẾ KHI TỚI XEM (CHẠM ĐỂ SOI LỖI)"
	lbl_real_tag.add_theme_font_size_override("font_size", 10)
	lbl_real_tag.add_theme_color_override("font_color", Color("#DC2626"))
	imgs_vbox.add_child(lbl_real_tag)

	var frame_real = PanelContainer.new()
	var frame_real_sb = StyleBoxFlat.new()
	frame_real_sb.bg_color = Color.BLACK
	frame_real_sb.border_color = Color("#DC2626")
	frame_real_sb.set_border_width_all(2)
	frame_real_sb.set_corner_radius_all(6)
	frame_real.add_theme_stylebox_override("panel", frame_real_sb)
	imgs_vbox.add_child(frame_real)

	var real_wrapper = Control.new()
	real_wrapper.custom_minimum_size = Vector2(460, 220)
	frame_real.add_child(real_wrapper)

	tex_real = TextureRect.new()
	tex_real.custom_minimum_size = Vector2(460, 220)
	tex_real.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_real.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	real_wrapper.add_child(tex_real)

	markers_overlay = Control.new()
	markers_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	real_wrapper.add_child(markers_overlay)

	real_click_area = Control.new()
	real_click_area.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	real_click_area.mouse_default_cursor_shape = Control.CURSOR_CROSS
	real_click_area.gui_input.connect(_on_real_image_clicked)
	real_wrapper.add_child(real_click_area)

	# 5. Modal Popup for Discovered Error
	popup_dialog = PanelContainer.new()
	popup_dialog.visible = false
	popup_dialog.custom_minimum_size = Vector2(460, 110)
	var p_sb = StyleBoxFlat.new()
	p_sb.bg_color = Color("#FFFBEB")
	p_sb.border_color = Color("#D97706")
	p_sb.set_border_width_all(3)
	p_sb.set_corner_radius_all(10)
	p_sb.content_margin_left = 12
	p_sb.content_margin_right = 12
	p_sb.content_margin_top = 8
	p_sb.content_margin_bottom = 8
	p_sb.shadow_size = 10
	p_sb.shadow_color = Color(0, 0, 0, 0.25)
	popup_dialog.add_theme_stylebox_override("panel", p_sb)
	main_vbox.add_child(popup_dialog)

	var p_vbox = VBoxContainer.new()
	p_vbox.set("theme_override_constants/separation", 4)
	popup_dialog.add_child(p_vbox)

	var p_header_hbox = HBoxContainer.new()
	p_vbox.add_child(p_header_hbox)

	lbl_popup_name = Label.new()
	lbl_popup_name.text = "🎯 ĐÃ PHÁT HIỆN: LỖI"
	lbl_popup_name.add_theme_font_size_override("font_size", 12)
	lbl_popup_name.add_theme_color_override("font_color", Color("#B45309"))
	lbl_popup_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	p_header_hbox.add_child(lbl_popup_name)

	var btn_close_popup = Button.new()
	btn_close_popup.text = "ĐÃ HIỂU ✖"
	btn_close_popup.custom_minimum_size = Vector2(75, 24)
	btn_close_popup.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_close_popup.pressed.connect(func(): popup_dialog.visible = false)
	p_header_hbox.add_child(btn_close_popup)

	lbl_popup_desc = Label.new()
	lbl_popup_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_popup_desc.add_theme_font_size_override("font_size", 10)
	lbl_popup_desc.add_theme_color_override("font_color", Color("#451A03"))
	p_vbox.add_child(lbl_popup_desc)

func _load_stage(idx: int) -> void:
	current_stage_idx = idx
	var st = stages[idx]
	found_errors.clear()
	popup_dialog.visible = false

	# Tabs highlight
	for i in range(tabs_hbox.get_child_count()):
		var b = tabs_hbox.get_child(i) as Button
		if i == idx:
			b.modulate = Color(1.2, 1.2, 1.0)
		else:
			b.modulate = Color(0.8, 0.8, 0.8)

	lbl_title.text = st.title
	lbl_desc.text = st.desc
	tex_ad.texture = GameManager.load_texture(st.ad_img)
	tex_real.texture = GameManager.load_texture(st.real_img)

	# Clear previous markers
	for child in markers_overlay.get_children():
		child.queue_free()

	_update_counter()

func _on_real_image_clicked(ev: InputEvent) -> void:
	if not (ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT):
		return

	var click_pos = ev.position
	var st = stages[current_stage_idx]
	var hit_error: Dictionary = {}

	for err in st.errors:
		var rect: Rect2 = err.rect
		if rect.has_point(click_pos):
			hit_error = err
			break

	if not hit_error.is_empty():
		var err_id = hit_error.id
		if found_errors.has(err_id):
			lbl_popup_name.text = "ℹ️ ĐÃ PHÁT HIỆN TRƯỚC ĐÓ: " + hit_error.name
			lbl_popup_desc.text = hit_error.desc
			popup_dialog.visible = true
			return

		# Newly discovered!
		found_errors.append(err_id)
		SoundManager.play_success()

		# Add animated red circle marker on spot
		_add_spot_marker(hit_error.rect)

		# Show educational popup
		lbl_popup_name.text = "🎯 PHÁT HIỆN: " + hit_error.name
		lbl_popup_desc.text = hit_error.desc
		popup_dialog.visible = true

		_update_counter()

		# Check win
		if found_errors.size() == st.errors.size():
			SoundManager.play_success()
			lbl_popup_name.text = "🏆 XUẤT SẮC! BẠN ĐÃ TÌM ĐỦ MỌI ĐIỂM BẪY CỦA " + st.title.to_upper() + "!"
			if current_stage_idx < stages.size() - 1:
				lbl_popup_desc.text = "Bấm tab tiếp theo để soi tiếp màn tiếp theo nhé Sen!"
			else:
				lbl_popup_desc.text = "Bạn đã hoàn thành khóa huấn luyện Thám Tử Soi Trọ Của Mèo!"
				emit_signal("minigame_completed", {"status": "victory", "stages_completed": 3})
	else:
		SoundManager.play_click()
		# Tap outside error
		lbl_popup_name.text = "🔍 Vùng này an toàn!"
		lbl_popup_desc.text = "Hãy quan sát thật kỹ các điểm nghi vấn: trần nhà, vòi nước, then cửa, công tơ, v.v."
		popup_dialog.visible = true

func _add_spot_marker(r: Rect2) -> void:
	var circle = Panel.new()
	circle.size = Vector2(r.size.x + 8, r.size.y + 8)
	circle.position = Vector2(r.position.x - 4, r.position.y - 4)
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(1, 0, 0, 0.25)
	sb.border_color = Color("#DC2626")
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(int(min(r.size.x, r.size.y) / 2))
	circle.add_theme_stylebox_override("panel", sb)
	markers_overlay.add_child(circle)

func _update_counter() -> void:
	var st = stages[current_stage_idx]
	var total = st.errors.size()
	var found = found_errors.size()
	lbl_counter.text = "Đã tìm thấy: " + str(found) + " / " + str(total) + " lỗi bẫy"

func _on_back_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
