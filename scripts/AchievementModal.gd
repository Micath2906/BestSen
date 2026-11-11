extends Control

# AchievementModal.gd - Bảng Ghim Thành Tựu Phòng Trọ & Tranh Ghép Puzzle Nhận Bằng Khen
# Thiết kế phong cách Cozy Cork Board & Polaroid Photo Pins từ ToffeeCraft UI Pack
# Tích hợp trực tiếp trong màn Học Kỹ Năng (SkillTree & LessonView)
# Giúp người chơi theo dõi 16 mảnh ảnh Polaroid và rước 4 Bằng Khen Cuộn Giấy Hoàng Gia

signal closed
signal open_full_museum_requested

@onready var dim_overlay: ColorRect = $DimOverlay
@onready var panel: PanelContainer = $CenterContainer/Panel
@onready var btn_close: Button = $CenterContainer/Panel/VBox/Header/BtnClose
@onready var btn_footer_close: Button = $CenterContainer/Panel/VBox/Footer/BtnCloseFooter
@onready var btn_go_museum: Button = $CenterContainer/Panel/VBox/Footer/BtnGoMuseum

@onready var lbl_pieces_count: Label = $CenterContainer/Panel/VBox/StatsBar/PiecesBadge/Label
@onready var lbl_certs_count: Label = $CenterContainer/Panel/VBox/StatsBar/CertsBadge/Label
@onready var puzzle_list_container: VBoxContainer = $CenterContainer/Panel/VBox/Scroll/PuzzleContainer

# Popup Bằng Chứng Nhận Hoàng Gia (Parchment Scroll)
@onready var cert_popup: Control = $CertPopup
@onready var cert_dim: ColorRect = $CertPopup/DimOverlay
@onready var cert_title_lbl: Label = $CertPopup/Panel/VBox/CertTitle
@onready var cert_rank_lbl: Label = $CertPopup/Panel/VBox/CertRank
@onready var cert_recipient_lbl: Label = $CertPopup/Panel/VBox/RecipientLabel
@onready var cert_quote_lbl: Label = $CertPopup/Panel/VBox/QuoteBox/QuoteLabel
@onready var cert_reward_lbl: Label = $CertPopup/Panel/VBox/RewardBox/VBox/RewardLabel
@onready var btn_close_cert_popup: Button = $CertPopup/Panel/VBox/BtnCloseCert

# Popup Soi Mảnh Ghép Polaroid
@onready var piece_popup: Control = $PiecePopup
@onready var piece_dim: ColorRect = $PiecePopup/DimOverlay
@onready var piece_icon_lbl: Label = $PiecePopup/Panel/VBox/IconBox/IconLabel
@onready var piece_title_lbl: Label = $PiecePopup/Panel/VBox/TitleLabel
@onready var piece_desc_lbl: Label = $PiecePopup/Panel/VBox/DescBox/DescLabel
@onready var piece_status_lbl: Label = $PiecePopup/Panel/VBox/StatusLabel
@onready var btn_close_piece_popup: Button = $PiecePopup/Panel/VBox/BtnClosePiece

# Preload các tài nguyên Pixel Art Bảng Ghim Bần & Polaroid
const CORK_BOARD_STYLE = preload("res://assets/UI/CatUIPaid/slices/cozy_achievements/cork_board_stylebox.tres")
const SCROLL_STYLE = preload("res://assets/UI/CatUIPaid/slices/cozy_achievements/parchment_scroll_stylebox.tres")
const POLAROID_CARD_STYLE = preload("res://assets/UI/CatUIPaid/slices/cozy_achievements/polaroid_card_stylebox.tres")
const LOCKED_QMARK_TEX = preload("res://assets/UI/CatUIPaid/slices/cozy_achievements/polaroid_locked_wood_qmark.tres")
const PIN_TACK_TEX = preload("res://assets/UI/CatUIPaid/slices/cozy_achievements/pin_tack_red.tres")
const RIBBON_TEX = preload("res://assets/UI/CatUIPaid/slices/cozy_achievements/ribbon_red_gold.tres")
const WAX_SEAL_TEX = preload("res://assets/UI/CatUIPaid/slices/cozy_achievements/wax_seal_royal_gold.tres")

# Dữ liệu 16 Chiến Lợi Phẩm tương ứng 16 Bài Học (Trích xuất từ Hugging Face Angais/pixel-art-atlas-1.4m)
const LOOT_PIECES = [
	{"id": 1, "icon": "🎟️", "name": "Cuống Vé Buýt 08", "desc": "Kỷ niệm lần đầu đi xe buýt liên quận không bị lạc giữa thủ đô!", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_01_ticket.tres"},
	{"id": 2, "icon": "🪪", "name": "Thẻ Buýt Sinh Viên", "desc": "Thẻ tháng dán ảnh Mèo đeo kính ngố, đi xe bạt mạng khắp thành phố.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_02_bus_card.tres"},
	{"id": 3, "icon": "🧭", "name": "La Bàn Đeo Cổ", "desc": "Giúp Boss không bao giờ mất phương hướng giữa ngã tư bùng binh.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_03_compass.tres"},
	{"id": 4, "icon": "🔩", "name": "Ốc Xả Nhớt Đồng", "desc": "Biểu tượng tay lái tháo vát, tự bảo dưỡng xe định kỳ không lo bị vẽ bệnh.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_04_screw.tres"},
	{"id": 5, "icon": "🖊️", "name": "Bút Bi Ký Trọ", "desc": "Cây bút soi kỹ điều khoản hợp đồng thuê trọ, tiền cọc bảo toàn 100%.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_05_pen.tres"},
	{"id": 6, "icon": "🔑", "name": "Móc Khóa Dạ Quang", "desc": "Phát sáng trong đêm, mở khóa lối thoát hiểm ban công trong 3 giây.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_06_key.tres"},
	{"id": 7, "icon": "📜", "name": "Xác Nhận CT07", "desc": "Thông báo tạm trú CT07 chuẩn chỉ, bảo chứng cư trú công dân gương mẫu.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_07_scroll.tres"},
	{"id": 8, "icon": "📋", "name": "Nội Quy Hài Hước", "desc": "Cam kết huynh đệ cùng phòng trọ, sống chan hòa văn minh không xích mích.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_08_clipboard.tres"},
	{"id": 9, "icon": "🌡️", "name": "Nhiệt Kế Đầu Mềm", "desc": "Bảo bối cứu mạng khi sốt đêm một mình, đo chuẩn xác từng 0.1 độ C.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_09_thermometer.tres"},
	{"id": 10, "icon": "💊", "name": "Vỉ C Khám BHYT", "desc": "Đi khám đúng tuyến BHYT thành công, hưởng 100% quyền lợi thuốc men.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_10_pill.tres"},
	{"id": 11, "icon": "🩹", "name": "Hộp Y Tế Thiếc", "desc": "Hộp cứu thương mini phòng trọ chứa đầy đủ bông băng, hạ sốt, oresol.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_11_first_aid.tres"},
	{"id": 12, "icon": "🍶", "name": "Bình Giữ Nhiệt 24h", "desc": "Cung cấp nước ấm mùa thi, bảo vệ dạ dày khỏi cơn đau cồn cào.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_12_thermos.tres"},
	{"id": 13, "icon": "🏺", "name": "3 Hũ Thủy Tinh", "desc": "Bí kíp chia ngân sách 50-30-20, không bao giờ rỗng túi cuối tháng.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_13_jars.tres"},
	{"id": 14, "icon": "🔍", "name": "Kính Lúp Soi Lỗi", "desc": "Vũ khí trí tuệ soi thấu mọi bẫy việc làm lừa đảo, đa cấp ảo trên mạng.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_14_magnifier.tres"},
	{"id": 15, "icon": "☕", "name": "Thẻ Barista Xịn", "desc": "Huy hiệu làm thêm chân chính đầu đời, kiếm tiền mua cá khô đàng hoàng.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_15_coffee.tres"},
	{"id": 16, "icon": "✂️", "name": "Kéo Cắt Thẻ Nợ", "desc": "Biểu tượng tự do tài chính, nói không với ví trả sau và thấu chi bẫy nợ.", "sprite": "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_16_scissors.tres"}
]

# 4 Bộ Puzzle Tranh Ghép Kỹ Năng Sống
const PUZZLE_SETS = [
	{
		"id": "cert_street",
		"title": "BẢN ĐỒ THỔ ĐỊA ĐƯỜNG PHỐ",
		"icon": "🗺️",
		"cert_title": "CHỨNG NHẬN THỔ ĐỊA THÀNH PHỐ",
		"cert_rank": "🌟 HẠNG THỦ KHOA ĐƯỜNG PHỐ 🌟",
		"desc": "Ghép đủ 4 mảnh bản đồ giao thông để trở thành Thổ Địa bất khả chiến bại giữa phố xá!",
		"lessons": [1, 2, 3, 4],
		"reward_money": 50,
		"reward_item": "Mũ Phượt Thủ Sinh Viên 🧢",
		"reward_mood": 25,
		"quote": "Sen và Boss đã nắm lòng từng tuyến buýt, ngã tư và cung đường. Tự tin đi học, đi làm thêm không bao giờ sợ lạc!"
	},
	{
		"id": "cert_room",
		"title": "BẢN THIẾT KẾ PHÒNG TRỌ AN TOÀN",
		"icon": "🏠",
		"cert_title": "CHỨNG NHẬN CHUYÊN GIA THUÊ TRỌ",
		"cert_rank": "🔑 HẠNG BẬC THẦY CƯ TRÚ 🔑",
		"desc": "Ghép đủ 4 mảnh pháp lý và an toàn để làm chủ không gian sống độc lập!",
		"lessons": [5, 6, 7, 8],
		"reward_money": 50,
		"reward_item": "Tranh Treo Tường Kỷ Niệm 🖼️ + 5 Pate 🥫",
		"reward_mood": 25,
		"quote": "Hợp đồng minh bạch, tạm trú CT07 chuẩn chỉ, lối thoát hiểm PCCC thuộc làu. Một tổ ấm an toàn tuyệt đối!"
	},
	{
		"id": "cert_health",
		"title": "BÍ KÍP BẢO VỆ THÂN THỂ Y TẾ",
		"icon": "🩺",
		"cert_title": "CHỨNG NHẬN CHIẾN TƯỚNG TỰ CHĂM SÓC",
		"cert_rank": "💊 HẠNG BÁC SĨ SINH VIÊN 💊",
		"desc": "Ghép đủ 4 mảnh sơ cấp cứu và quyền lợi BHYT để bảo vệ sức khỏe khi sống xa nhà!",
		"lessons": [9, 10, 11, 12],
		"reward_money": 50,
		"reward_item": "Hộp Y Tế Hoàng Gia 🩹 + Bình Giữ Nhiệt 🍶",
		"reward_mood": 25,
		"quote": "Ốm đau biết tự đo nhiệt độ, khám đúng tuyến BHYT không mất tiền oan, bình nước ấm luôn sẵn sàng bên bàn học!"
	},
	{
		"id": "cert_finance",
		"title": "BẢN HỢP ÂM TỰ DO TÀI CHÍNH",
		"icon": "💰",
		"cert_title": "CHỨNG NHẬN ĐẠI GIA TỰ LẬP",
		"cert_rank": "👑 HẠNG TỰ DO TÀI CHÍNH ĐỈNH CAO 👑",
		"desc": "Ghép đủ 4 mảnh tài chính sinh viên để nói KHÔNG với bẫy nợ ví trả sau và đa cấp lừa đảo!",
		"lessons": [13, 14, 15, 16],
		"reward_money": 100,
		"reward_item": "Cúp Vàng Đại Gia 🏆 + Vest Tuxedo Vàng 👔",
		"reward_mood": 35,
		"quote": "Thu chi rạch ròi, tự kiếm tiền chân chính bằng công việc part-time và tuyệt đối không bao giờ làm nô lệ cho nợ nần!"
	}
]

func _ready() -> void:
	visible = false
	cert_popup.visible = false
	piece_popup.visible = false
	
	btn_close.pressed.connect(close)
	btn_footer_close.pressed.connect(close)
	btn_go_museum.pressed.connect(func():
		SoundManager.play_click()
		close()
		emit_signal("open_full_museum_requested")
	)
	
	btn_close_cert_popup.pressed.connect(func():
		SoundManager.play_click()
		cert_popup.visible = false
	)
	btn_close_piece_popup.pressed.connect(func():
		SoundManager.play_click()
		piece_popup.visible = false
	)
	
	dim_overlay.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			close()
	)
	cert_dim.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			cert_popup.visible = false
	)
	piece_dim.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			piece_popup.visible = false
	)

func open() -> void:
	SoundManager.play_click()
	visible = true
	cert_popup.visible = false
	piece_popup.visible = false
	refresh_achievements()
	
	# Hiệu ứng nảy mở modal Bảng Ghim Bần
	panel.scale = Vector2(0.85, 0.85)
	panel.modulate.a = 0.0
	var tw = create_tween().set_parallel(true)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "modulate:a", 1.0, 0.18)

func close() -> void:
	SoundManager.play_click()
	var tw = create_tween().set_parallel(true)
	tw.tween_property(panel, "scale", Vector2(0.9, 0.9), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(panel, "modulate:a", 0.0, 0.15)
	await tw.finished
	visible = false
	emit_signal("closed")

func refresh_achievements() -> void:
	# Cập nhật thống kê
	var unlocked_count = 0
	for item in LOOT_PIECES:
		if _is_piece_unlocked(item["id"]):
			unlocked_count += 1
	lbl_pieces_count.text = "🧩 Mảnh Ghép: %d/16" % unlocked_count
	
	var claimed_count = 0
	for pset in PUZZLE_SETS:
		if GameManager.is_certificate_claimed(pset["id"]):
			claimed_count += 1
	lbl_certs_count.text = "📜 Bằng Khen: %d/4" % claimed_count
	
	# Dọn dẹp danh sách cũ
	for child in puzzle_list_container.get_children():
		child.queue_free()
		
	# 1. KHU VỰC GHÉP PUZZLE: KHUNG LƯỚI 4X4 HIỂN THỊ 16 Ô GHIM ẢNH POLAROID PIXEL
	var polaroid_board = _build_polaroid_4x4_board()
	puzzle_list_container.add_child(polaroid_board)
	
	# Đường kẻ phân cách gỗ mộc
	var sep = HSeparator.new()
	sep.custom_minimum_size = Vector2(0, 12)
	puzzle_list_container.add_child(sep)
	
	# Tiêu đề danh sách Bằng Khen Hoàng Gia
	var cert_header_lbl = Label.new()
	cert_header_lbl.text = "📜 4 BỘ BẰNG KHEN CUỘN GIẤY HOÀNG GIA"
	cert_header_lbl.add_theme_font_size_override("font_size", 12)
	cert_header_lbl.add_theme_color_override("font_color", Color(0.40, 0.25, 0.12))
	puzzle_list_container.add_child(cert_header_lbl)
	
	# 2. Render 4 Bộ Ghép Tranh Puzzle & Nhận Bằng Khen
	for pset in PUZZLE_SETS:
		var card = _build_puzzle_set_card(pset)
		puzzle_list_container.add_child(card)

func _is_piece_unlocked(lesson_id: int) -> bool:
	if lesson_id in GameManager.completed_lessons:
		return true
	for l in GameManager.loot_collection:
		if l.get("id", -1) == lesson_id:
			return true
	return false

# =========================================================================
# KHU VỰC GHÉP 16 MẢNH ẢNH POLAROID PIXEL (LƯỚI 4x4)
# =========================================================================
func _build_polaroid_4x4_board() -> PanelContainer:
	var board_card = PanelContainer.new()
	board_card.custom_minimum_size = Vector2(0, 480)
	board_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var b_style = StyleBoxFlat.new()
	b_style.bg_color = Color(0.92, 0.82, 0.68, 0.65) # Nền gỗ bần nhạt hơn bên trong
	b_style.border_color = Color(0.60, 0.42, 0.25, 1.0)
	b_style.set_border_width_all(2)
	b_style.border_width_bottom = 3
	b_style.set_corner_radius_all(12)
	b_style.content_margin_left = 10
	b_style.content_margin_right = 10
	b_style.content_margin_top = 10
	b_style.content_margin_bottom = 10
	board_card.add_theme_stylebox_override("panel", b_style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	board_card.add_child(vbox)
	
	# Header của Bảng Polaroid 4x4
	var title_hbox = HBoxContainer.new()
	title_hbox.add_theme_constant_override("separation", 6)
	
	var icon_pin = TextureRect.new()
	icon_pin.texture = PIN_TACK_TEX
	icon_pin.custom_minimum_size = Vector2(18, 18)
	icon_pin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	title_hbox.add_child(icon_pin)
	
	var title_lbl = Label.new()
	title_lbl.text = "KHUNG LƯỚI 4x4: 16 MẢNH GHÉP POLAROID"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", Color(0.35, 0.22, 0.12))
	title_hbox.add_child(title_lbl)
	
	var sub_lbl = Label.new()
	sub_lbl.text = "Chạm để soi chi tiết"
	sub_lbl.add_theme_font_size_override("font_size", 10)
	sub_lbl.add_theme_color_override("font_color", Color(0.55, 0.42, 0.30))
	title_hbox.add_child(sub_lbl)
	vbox.add_child(title_hbox)
	
	# Lưới 4x4 chứa 16 ô ảnh Polaroid
	var grid = GridContainer.new()
	grid.columns = 4
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	
	for item in LOOT_PIECES:
		var is_unlocked = _is_piece_unlocked(item["id"])
		var polaroid_card = _build_single_polaroid_card(item, is_unlocked)
		grid.add_child(polaroid_card)
		
	vbox.add_child(grid)
	return board_card

func _build_single_polaroid_card(item: Dictionary, is_unlocked: bool) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(98, 102)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.add_theme_stylebox_override("panel", POLAROID_CARD_STYLE)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(vbox)
	
	# Đinh ghim nhỏ ở đỉnh ảnh polaroid
	var pin_center = CenterContainer.new()
	pin_center.custom_minimum_size = Vector2(0, 10)
	var pin_icon = TextureRect.new()
	pin_icon.texture = PIN_TACK_TEX
	pin_icon.custom_minimum_size = Vector2(12, 12)
	pin_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pin_center.add_child(pin_icon)
	vbox.add_child(pin_center)
	
	# Khu vực hiển thị ảnh (Photo Box)
	var photo_box = PanelContainer.new()
	photo_box.custom_minimum_size = Vector2(80, 52)
	photo_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	var pb_style = StyleBoxFlat.new()
	pb_style.set_corner_radius_all(4)
	
	if is_unlocked:
		# MẢNH ĐÃ MỞ: Hình vẽ pixel rực rỡ trích xuất từ Dataset Angais/pixel-art-atlas-1.4m
		pb_style.bg_color = Color(1.0, 0.98, 0.90, 1.0)
		pb_style.border_color = Color(1.0, 0.82, 0.35, 1.0) # Viền vàng rực
		pb_style.set_border_width_all(1)
		pb_style.shadow_color = Color(1.0, 0.85, 0.25, 0.45) # Hào quang lấp lánh
		pb_style.shadow_size = 4
		photo_box.add_theme_stylebox_override("panel", pb_style)
		
		var sprite_path = item.get("sprite", "")
		if sprite_path != "" and ResourceLoader.exists(sprite_path):
			var sprite_rect = TextureRect.new()
			sprite_rect.texture = load(sprite_path)
			sprite_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite_rect.custom_minimum_size = Vector2(36, 36)
			sprite_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			sprite_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			sprite_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			photo_box.add_child(sprite_rect)
		else:
			var icon_lbl = Label.new()
			icon_lbl.text = item["icon"]
			icon_lbl.add_theme_font_size_override("font_size", 24)
			icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			photo_box.add_child(icon_lbl)
		
		# Hiệu ứng hào quang đập nhẹ (subtle sparkle pulse)
		var tw = create_tween().set_loops()
		tw.tween_property(photo_box, "modulate", Color(1.08, 1.06, 0.95), 1.2).set_trans(Tween.TRANS_SINE)
		tw.tween_property(photo_box, "modulate", Color(1.0, 1.0, 1.0), 1.2).set_trans(Tween.TRANS_SINE)
	else:
		# MẢNH CHƯA MỞ: Bóng mờ xám kèm dấu hỏi chấm pixel gỗ
		pb_style.bg_color = Color(0.28, 0.25, 0.22, 0.9)
		pb_style.border_color = Color(0.45, 0.38, 0.32, 1.0)
		pb_style.set_border_width_all(1)
		photo_box.add_theme_stylebox_override("panel", pb_style)
		
		var q_tex = TextureRect.new()
		q_tex.texture = LOCKED_QMARK_TEX
		q_tex.custom_minimum_size = Vector2(28, 28)
		q_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		q_tex.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		q_tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		photo_box.add_child(q_tex)
		
	vbox.add_child(photo_box)
	
	# Caption nhãn chữ ở cạnh đáy Polaroid
	var name_lbl = Label.new()
	name_lbl.add_theme_font_size_override("font_size", 9)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_lbl.clip_text = true
	
	if is_unlocked:
		name_lbl.text = item["name"]
		name_lbl.add_theme_color_override("font_color", Color(0.32, 0.22, 0.15))
	else:
		name_lbl.text = "Bài %02d: ❓" % item["id"]
		name_lbl.add_theme_color_override("font_color", Color(0.60, 0.52, 0.45))
		
	vbox.add_child(name_lbl)
	
	# Chạm để xem chi tiết
	card.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_show_piece_popup(item, is_unlocked)
	)
	
	return card

# =========================================================================
# THẺ 4 BỘ BẰNG KHEN HOÀNG GIA
# =========================================================================
func _build_puzzle_set_card(pset: Dictionary) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 160)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(1.0, 0.985, 0.95, 1.0)
	card_style.border_color = Color(0.85, 0.65, 0.38, 1.0)
	card_style.set_border_width_all(2)
	card_style.border_width_bottom = 3
	card_style.set_corner_radius_all(14)
	card_style.content_margin_left = 12
	card_style.content_margin_right = 12
	card_style.content_margin_top = 10
	card_style.content_margin_bottom = 10
	card_style.shadow_color = Color(0, 0, 0, 0.06)
	card_style.shadow_size = 4
	card.add_theme_stylebox_override("panel", card_style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)
	
	# 1. Hàng Tiêu Đề Bộ & Tiến Độ
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 6)
	
	var icon_lbl = Label.new()
	icon_lbl.text = pset["icon"]
	icon_lbl.add_theme_font_size_override("font_size", 16)
	header_hbox.add_child(icon_lbl)
	
	var title_lbl = Label.new()
	title_lbl.text = pset["title"]
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", Color(0.3, 0.2, 0.12, 1.0))
	header_hbox.add_child(title_lbl)
	
	# Đếm số mảnh đã ghép
	var set_unlocked_count = 0
	for lid in pset["lessons"]:
		if _is_piece_unlocked(lid):
			set_unlocked_count += 1
	var is_set_complete = (set_unlocked_count == pset["lessons"].size())
	var is_claimed = GameManager.is_certificate_claimed(pset["id"])
	
	var badge_lbl = Label.new()
	badge_lbl.text = "%d/4 Mảnh Polaroid" % set_unlocked_count
	badge_lbl.add_theme_font_size_override("font_size", 11)
	if is_set_complete:
		badge_lbl.add_theme_color_override("font_color", Color(0.18, 0.65, 0.25))
	else:
		badge_lbl.add_theme_color_override("font_color", Color(0.85, 0.45, 0.1))
	header_hbox.add_child(badge_lbl)
	vbox.add_child(header_hbox)
	
	# Mô tả bộ tranh ghép
	var desc_lbl = Label.new()
	desc_lbl.text = pset["desc"]
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 10)
	desc_lbl.add_theme_color_override("font_color", Color(0.55, 0.45, 0.35, 1.0))
	vbox.add_child(desc_lbl)
	
	# 2. Hàng 4 ô mảnh ghép Polaroid thu nhỏ đại diện cho 4 bài
	var mini_pieces_hbox = HBoxContainer.new()
	mini_pieces_hbox.add_theme_constant_override("separation", 6)
	mini_pieces_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	for lid in pset["lessons"]:
		var p_item = LOOT_PIECES[lid - 1]
		var piece_unlocked = _is_piece_unlocked(lid)
		var piece_widget = _build_piece_widget(p_item, piece_unlocked)
		mini_pieces_hbox.add_child(piece_widget)
	vbox.add_child(mini_pieces_hbox)
	
	# 3. Nút Hành Động / Nhận Bằng Khen Cuộn Giấy
	var btn_action = Button.new()
	btn_action.custom_minimum_size = Vector2(0, 36)
	btn_action.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_action.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_action.add_theme_font_size_override("font_size", 11)
	
	var act_style = StyleBoxFlat.new()
	act_style.set_corner_radius_all(10)
	act_style.set_border_width_all(2)
	act_style.border_width_bottom = 3
	
	if is_claimed:
		act_style.bg_color = Color(1.0, 0.96, 0.90, 1.0)
		act_style.border_color = Color(0.85, 0.65, 0.35, 1.0)
		btn_action.add_theme_stylebox_override("normal", act_style)
		btn_action.add_theme_stylebox_override("hover", act_style)
		btn_action.add_theme_stylebox_override("pressed", act_style)
		btn_action.add_theme_color_override("font_color", Color(0.35, 0.22, 0.12))
		btn_action.text = "📜 XEM BẰNG KHEN CUỘN GIẤY (ĐÃ ĐẠT)"
		btn_action.pressed.connect(func():
			_show_cert_popup(pset)
		)
	elif is_set_complete:
		act_style.bg_color = Color(0.18, 0.65, 0.32, 1.0)
		act_style.border_color = Color(0.12, 0.45, 0.22, 1.0)
		btn_action.add_theme_stylebox_override("normal", act_style)
		btn_action.add_theme_stylebox_override("hover", act_style)
		btn_action.add_theme_stylebox_override("pressed", act_style)
		btn_action.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		btn_action.text = "🌟 NHẬN BẰNG KHEN CUỘN GIẤY & QUÀ (+%sđ) ➔" % GameManager.format_currency(pset["reward_money"])
		btn_action.pressed.connect(func():
			_claim_certificate(pset)
		)
	else:
		act_style.bg_color = Color(0.90, 0.88, 0.85, 1.0)
		act_style.border_color = Color(0.78, 0.74, 0.70, 1.0)
		btn_action.add_theme_stylebox_override("normal", act_style)
		btn_action.add_theme_stylebox_override("disabled", act_style)
		btn_action.add_theme_color_override("font_color", Color(0.55, 0.50, 0.45))
		btn_action.text = "🔒 Cần đủ 4 mảnh để nhận Bằng Khen & Quà Đặc Biệt"
		btn_action.disabled = true
	vbox.add_child(btn_action)
	
	return card

func _build_piece_widget(item: Dictionary, is_unlocked: bool) -> PanelContainer:
	var piece = PanelContainer.new()
	piece.custom_minimum_size = Vector2(0, 42)
	piece.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	piece.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(8)
	style.set_border_width_all(1)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	
	if is_unlocked:
		style.bg_color = Color(1.0, 0.97, 0.90, 1.0)
		style.border_color = Color(0.92, 0.72, 0.35, 1.0)
		style.border_width_bottom = 2
	else:
		style.bg_color = Color(0.88, 0.85, 0.80, 0.6)
		style.border_color = Color(0.78, 0.74, 0.70, 1.0)
	piece.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	piece.add_child(hbox)
	
	var spr_path = item.get("sprite", "")
	if is_unlocked and spr_path != "" and ResourceLoader.exists(spr_path):
		var spr_rect = TextureRect.new()
		spr_rect.texture = load(spr_path)
		spr_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr_rect.custom_minimum_size = Vector2(18, 18)
		spr_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(spr_rect)
	else:
		var icon = Label.new()
		icon.text = item["icon"] if is_unlocked else "🔒"
		icon.add_theme_font_size_override("font_size", 14)
		hbox.add_child(icon)
	
	var name_lbl = Label.new()
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 10)
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_lbl.clip_text = true
	if is_unlocked:
		name_lbl.text = item["name"]
		name_lbl.add_theme_color_override("font_color", Color(0.3, 0.2, 0.12))
	else:
		name_lbl.text = "Bài %d: ❓" % item["id"]
		name_lbl.add_theme_color_override("font_color", Color(0.55, 0.50, 0.45))
	hbox.add_child(name_lbl)
	
	if is_unlocked:
		var check = Label.new()
		check.text = "✔"
		check.add_theme_font_size_override("font_size", 10)
		check.add_theme_color_override("font_color", Color(0.2, 0.65, 0.25))
		hbox.add_child(check)
		
	piece.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_show_piece_popup(item, is_unlocked)
	)
	
	return piece

func _claim_certificate(pset: Dictionary) -> void:
	SoundManager.play_success()
	var res = GameManager.claim_certificate(pset["id"])
	if res.is_empty():
		return
	
	# Hiển thị toast thông báo quà đặc biệt
	GameManager.emit_signal("show_toast", "🎉 Chúc mừng! Bạn nhận được %s và %s!" % [
		GameManager.format_currency(pset["reward_money"]),
		pset["reward_item"]
	])
	
	refresh_achievements()
	_show_cert_popup(pset)

# =========================================================================
# POPUP BẰNG KHEN CUỘN GIẤY (PARCHMENT SCROLL POPUP)
# =========================================================================
func _show_cert_popup(pset: Dictionary) -> void:
	SoundManager.play_success()
	cert_title_lbl.text = pset["cert_title"]
	cert_rank_lbl.text = pset["cert_rank"]
	cert_recipient_lbl.text = "Kính tặng: Sen [%s] & Boss Mèo [%s]" % [
		GameManager.get_owner_name(),
		GameManager.get_cat_name()
	]
	cert_quote_lbl.text = "“%s”" % pset["quote"]
	cert_reward_lbl.text = "🎁 Quà Đặc Biệt: +%s & %s" % [
		GameManager.format_currency(pset["reward_money"]),
		pset["reward_item"]
	]
	
	cert_popup.visible = true
	
	# Hiệu ứng cuộn giấy mở ra từ giữa màn hình (Parchment Unroll Tween)
	var cert_panel = cert_popup.get_node("Panel")
	if cert_panel:
		cert_panel.pivot_offset = cert_panel.size / 2.0
		cert_panel.scale = Vector2(0.15, 0.15)
		cert_panel.modulate.a = 0.0
		var tw = create_tween().set_parallel(true)
		tw.tween_property(cert_panel, "scale", Vector2.ONE, 0.28).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(cert_panel, "modulate:a", 1.0, 0.22)

func _show_piece_popup(item: Dictionary, is_unlocked: bool) -> void:
	SoundManager.play_card_pop()
	piece_icon_lbl.text = item["icon"] if is_unlocked else "🔒"
	var icon_box = piece_icon_lbl.get_parent()
	if icon_box:
		var sprite_rect = icon_box.get_node_or_null("AtlasSprite")
		var spr_path = item.get("sprite", "")
		if is_unlocked and spr_path != "" and ResourceLoader.exists(spr_path):
			if not sprite_rect:
				sprite_rect = TextureRect.new()
				sprite_rect.name = "AtlasSprite"
				sprite_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				sprite_rect.custom_minimum_size = Vector2(48, 48)
				sprite_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon_box.add_child(sprite_rect)
			sprite_rect.texture = load(spr_path)
			sprite_rect.visible = true
			piece_icon_lbl.visible = false
		else:
			if sprite_rect:
				sprite_rect.visible = false
			piece_icon_lbl.visible = true
			
	piece_title_lbl.text = item["name"]
	piece_desc_lbl.text = item["desc"]
	if is_unlocked:
		piece_status_lbl.text = "✔ Mảnh ghép đã thu thập khi hoàn thành Bài %d!" % item["id"]
		piece_status_lbl.add_theme_color_override("font_color", Color(0.2, 0.65, 0.25))
	else:
		piece_status_lbl.text = "🔒 Mảnh ghép còn khóa. Hãy vượt qua Bài học số %d để thu thập!" % item["id"]
		piece_status_lbl.add_theme_color_override("font_color", Color(0.85, 0.35, 0.1))
	piece_popup.visible = true
