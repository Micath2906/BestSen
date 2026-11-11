extends Control

# MuseumView.gd - Bảo Tàng Sinh Tồn & Hệ Thống Ghép Tranh Puzzle Nhận Chứng Nhận
# 16 Chiến Lợi Phẩm Sinh Tồn chia thành 4 Bộ Puzzle Tranh Ghép
# Ghép đủ 4 mảnh của mỗi chuyên đề để mở khóa Chứng Nhận Danh Dự & Quà Đặc Biệt (+Tiền Thưởng 💵)

signal back_to_room

@onready var btn_back: Button = $Header/HBox/BtnBack
@onready var total_loot_label: Label = $Header/HBox/InfoVBox/TotalLootLabel
@onready var loot_progress_bar: ProgressBar = $Header/HBox/InfoVBox/LootProgressBar
@onready var cert_count_label: Label = $Header/HBox/BadgePill/BadgeCountLabel

@onready var loot_grid: GridContainer = $ScrollContainer/VBox/LootCabinet/LootGrid
@onready var puzzle_container: VBoxContainer = $ScrollContainer/VBox/PuzzleContainer

@onready var btn_gift_card: Button = $ScrollContainer/VBox/SocialBox/CardGiftCard/VBox/BtnGiftCard
@onready var btn_pate_rescue: Button = $ScrollContainer/VBox/SocialBox/CardPateRescue/VBox/BtnPateRescue

# Modal Xem Chi Tiết Chiến Lợi Phẩm
@onready var inspect_modal: Control = $InspectModal
@onready var dim_overlay: ColorRect = $InspectModal/DimOverlay
@onready var modal_icon: Label = $InspectModal/ModalPanel/VBox/IconBox/IconLabel
@onready var modal_title: Label = $InspectModal/ModalPanel/VBox/TitleLabel
@onready var modal_category: Label = $InspectModal/ModalPanel/VBox/CategoryLabel
@onready var modal_desc: Label = $InspectModal/ModalPanel/VBox/DescBox/DescLabel
@onready var modal_empathy: Label = $InspectModal/ModalPanel/VBox/EmpathyLabel
@onready var btn_close_inspect: Button = $InspectModal/ModalPanel/VBox/BtnCloseModal

# Modal Bằng Chứng Nhận Hoàng Gia (Royal Certificate Modal)
@onready var cert_modal: Control = $CertificateModal
@onready var cert_dim_overlay: ColorRect = $CertificateModal/DimOverlay
@onready var cert_modal_title: Label = $CertificateModal/CertPanel/VBox/CertTitle
@onready var cert_modal_rank: Label = $CertificateModal/CertPanel/VBox/CertRank
@onready var cert_modal_recipient: Label = $CertificateModal/CertPanel/VBox/RecipientLabel
@onready var cert_modal_quote: Label = $CertificateModal/CertPanel/VBox/QuoteBox/QuoteLabel
@onready var cert_modal_reward: Label = $CertificateModal/CertPanel/VBox/RewardBox/VBox/RewardLabel
@onready var btn_close_cert: Button = $CertificateModal/CertPanel/VBox/BtnCloseCert

const ALL_16_LOOTS = [
	{
		"id": 1,
		"icon": "🎟️",
		"name": "Cuống Vé Buýt 08",
		"full_name": "Cuống vé xe buýt số 08",
		"desc": "Cuống vé xe buýt có bấm lỗ may mắn - Kỷ niệm lần đầu đi xe buýt không bị lạc giữa thủ đô!",
		"category": "Đi Lại An Toàn"
	},
	{
		"id": 2,
		"icon": "🪪",
		"name": "Thẻ Buýt Sinh Viên",
		"full_name": "Thẻ xe buýt sinh viên ép nhựa",
		"desc": "Thẻ tháng có dán ảnh Mèo đeo kính ngố, đi bạt mạng khắp thành phố chỉ 100k/tháng.",
		"category": "Đi Lại An Toàn"
	},
	{
		"id": 3,
		"icon": "🧭",
		"name": "La Bàn Đeo Cổ",
		"full_name": "La bàn đồ chơi đeo cổ",
		"desc": "Chiếc la bàn nhỏ xíu giúp Boss không bao giờ quay cuồng mất phương hướng giữa bùng binh ngã bảy.",
		"category": "Đi Lại An Toàn"
	},
	{
		"id": 4,
		"icon": "🔩",
		"name": "Ốc Xả Nhớt Đồng",
		"full_name": "Ốc xả nhớt bằng đồng",
		"desc": "Biểu tượng của tay lái tháo vát, tự biết bảo dưỡng xe định kỳ không bao giờ bị thợ vẽ vời.",
		"category": "Đi Lại An Toàn"
	},
	{
		"id": 5,
		"icon": "🖊️",
		"name": "Bút Bi Ký Trọ",
		"full_name": "Bút bi xanh ký hợp đồng trọ",
		"desc": "Cây bút thần kỳ mang lại bình yên suốt 4 năm đại học, soi kỹ điều khoản, cọc về nguyên vẹn 100%.",
		"category": "Thuê Trọ Sinh Viên"
	},
	{
		"id": 6,
		"icon": "🔑",
		"name": "Móc Khóa Dạ Quang",
		"full_name": "Móc chìa khóa dạ quang thoát hiểm",
		"desc": "Phát sáng rực rỡ trong bóng đêm, mở then chốt cửa thoát hiểm ban công chỉ trong 3 giây.",
		"category": "Thuê Trọ Sinh Viên"
	},
	{
		"id": 7,
		"icon": "📜",
		"name": "Xác Nhận CT07",
		"full_name": "Thông báo xác nhận tạm trú CT07",
		"desc": "Tờ giấy bảo chứng cư trú hợp pháp chuẩn công dân gương mẫu, tha hồ thi bằng lái và làm giấy tờ.",
		"category": "Thuê Trọ Sinh Viên"
	},
	{
		"id": 8,
		"icon": "📋",
		"name": "Nội Quy Hài Hước",
		"full_name": "Bảng nội quy phòng vẽ tay hài hước",
		"desc": "Bản cam kết tình huynh đệ không đụng vào đồ của bạn cùng phòng trừ khi được mời ăn chung.",
		"category": "Thuê Trọ Sinh Viên"
	},
	{
		"id": 9,
		"icon": "🌡️",
		"name": "Nhiệt Kế Đầu Mềm",
		"full_name": "Nhiệt kế điện tử đầu mềm",
		"desc": "Bảo bối cứu mạng trong đêm sốt rét một mình ở phòng trọ, đo thân nhiệt chính xác từng 0.1 độ C.",
		"category": "Y Tế & Sức Khỏe"
	},
	{
		"id": 10,
		"icon": "💊",
		"name": "Vỉ C Khám BHYT",
		"full_name": "Vỉ kẹo ngậm C bệnh viện",
		"desc": "Chiến lợi phẩm sau khi khám đúng tuyến BHYT thành công, được hưởng quyền lợi tối đa không mất một xu oan.",
		"category": "Y Tế & Sức Khỏe"
	},
	{
		"id": 11,
		"icon": "🩹",
		"name": "Hộp Y Tế Thiếc",
		"full_name": "Hộp cứu thương mini bằng thiếc",
		"desc": "Bảo bối phòng thân chứa đầy đủ bông băng, thuốc hạ sốt, oresol sinh tồn thiết yếu cho xóm trọ.",
		"category": "Y Tế & Sức Khỏe"
	},
	{
		"id": 12,
		"icon": "🍶",
		"name": "Bình Giữ Nhiệt 24h",
		"full_name": "Bình giữ nhiệt giữ nước ấm 24h",
		"desc": "Người bạn đồng hành bảo vệ dạ dày khỏi những cơn đau cồn cào và cung cấp nước ấm mùa ôn thi.",
		"category": "Y Tế & Sức Khỏe"
	},
	{
		"id": 13,
		"icon": "🏺",
		"name": "3 Hũ Thủy Tinh",
		"full_name": "3 Hũ thủy tinh chia ngân sách",
		"desc": "Bí kíp tài chính chia 6 chiếc lọ sinh viên, đảm bảo không bao giờ rơi vào cảnh rỗng túi cuối tháng.",
		"category": "Tài Chính Sinh Viên"
	},
	{
		"id": 14,
		"icon": "🔍",
		"name": "Kính Lúp Soi Sàn",
		"full_name": "Kính lúp soi sàn ảo Ponzi",
		"desc": "Vũ khí trí tuệ soi thấu mọi lời đường mật lừa đảo làm giàu nhanh, đa cấp ảo trên mạng xã hội.",
		"category": "Tài Chính Sinh Viên"
	},
	{
		"id": 15,
		"icon": "☕",
		"name": "Thẻ Barista Xịn",
		"full_name": "Thẻ nhân viên pha chế xịn sò",
		"desc": "Huy hiệu làm thêm chân chính đầu đời, tự lập kiếm tiền mua cá khô đàng hoàng bằng sức mình.",
		"category": "Tài Chính Sinh Viên"
	},
	{
		"id": 16,
		"icon": "✂️",
		"name": "Kéo Cắt Thẻ Nợ",
		"full_name": "Chiếc kéo vàng cắt thẻ nợ",
		"desc": "Biểu tượng của sự tự do tài chính tuyệt đối, không làm nô lệ cho thấu chi, thẻ tín dụng và nợ nần.",
		"category": "Tài Chính Sinh Viên"
	}
]

# 4 BỘ PUZZLE TRANH GHÉP VÀ CHỨNG NHẬN
const PUZZLE_SETS = [
	{
		"id": "cert_street",
		"title": "BẢN ĐỒ THỔ ĐỊA ĐƯỜNG PHỐ",
		"icon": "🗺️",
		"cert_title": "CHỨNG NHẬN THỔ ĐỊA THÀNH PHỐ",
		"cert_rank": "🌟 HẠNG THỦ KHOA ĐƯỜNG PHỐ 🌟",
		"desc": "Ghép đủ 4 mảnh bản đồ giao thông để trở thành Thổ Địa bất khả chiến bại giữa thủ đô!",
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
		"desc": "Ghép đủ 4 mảnh bảo bối pháp lý và an toàn để làm chủ không gian sống độc lập!",
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
	btn_back.pressed.connect(func():
		SoundManager.play_click()
		emit_signal("back_to_room")
	)
	
	btn_gift_card.pressed.connect(_on_gift_card_pressed)
	btn_pate_rescue.pressed.connect(_on_pate_rescue_pressed)
	
	btn_close_inspect.pressed.connect(_close_inspect_modal)
	dim_overlay.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_close_inspect_modal()
	)
	
	btn_close_cert.pressed.connect(_close_cert_modal)
	cert_dim_overlay.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_close_cert_modal()
	)
	
	inspect_modal.visible = false
	cert_modal.visible = false
	refresh_museum()

func refresh_museum() -> void:
	for child in loot_grid.get_children():
		loot_grid.remove_child(child)
		child.queue_free()
		
	for child in puzzle_container.get_children():
		puzzle_container.remove_child(child)
		child.queue_free()
		
	# 1. Cập nhật tiến độ thu thập trên Header
	var unlocked_count = _get_unlocked_loot_count()
	total_loot_label.text = "Đã thu thập: %d/16 Chiến Lợi Phẩm Sinh Tồn" % unlocked_count
	loot_progress_bar.value = unlocked_count
	
	var claimed_certs = GameManager.claimed_certificates.size()
	cert_count_label.text = "📜 %d/4 Chứng Nhận" % claimed_certs
	
	# 2. Render Tủ Kính 16 Bục Trưng Bày Chiến Lợi Phẩm
	for item in ALL_16_LOOTS:
		var is_unlocked = _is_loot_unlocked(item["id"])
		var slot_card = _create_trophy_slot(item, is_unlocked)
		loot_grid.add_child(slot_card)
		
	# 3. Render 4 Bộ Ghép Tranh Puzzle & Chứng Nhận Danh Dự
	for pset in PUZZLE_SETS:
		var p_card = _create_puzzle_card(pset)
		puzzle_container.add_child(p_card)

func _get_unlocked_loot_count() -> int:
	var count = 0
	for item in ALL_16_LOOTS:
		if _is_loot_unlocked(item["id"]):
			count += 1
	return count

func _is_loot_unlocked(lesson_id: int) -> bool:
	if lesson_id in GameManager.completed_lessons:
		return true
	for l in GameManager.loot_collection:
		if l.get("id", -1) == lesson_id:
			return true
		if l.get("name", "") == ALL_16_LOOTS[lesson_id - 1]["full_name"]:
			return true
	return false

# --- TẠO THẺ BỤC CÚP CHIẾN LỢI PHẨM TRONG TỦ KÍNH ---
func _create_trophy_slot(item: Dictionary, is_unlocked: bool) -> PanelContainer:
	var slot = PanelContainer.new()
	slot.custom_minimum_size = Vector2(0, 86)
	slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(10)
	style.set_border_width_all(1)
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	
	if is_unlocked:
		style.bg_color = Color(1.0, 0.985, 0.92, 1.0)
		style.border_color = Color(0.90, 0.72, 0.35, 1.0)
		style.border_width_bottom = 3
		style.shadow_color = Color(0.9, 0.7, 0.3, 0.15)
		style.shadow_size = 4
	else:
		style.bg_color = Color(0.92, 0.89, 0.85, 0.7)
		style.border_color = Color(0.82, 0.78, 0.73, 1.0)
		style.border_width_bottom = 2
		
	slot.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	
	var icon_lbl = Label.new()
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var name_lbl = Label.new()
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 9)
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_lbl.clip_text = true
	
	if is_unlocked:
		icon_lbl.text = item["icon"]
		icon_lbl.add_theme_font_size_override("font_size", 22)
		name_lbl.text = item["name"]
		name_lbl.add_theme_color_override("font_color", Color(0.35, 0.22, 0.12))
	else:
		icon_lbl.text = "🔒"
		icon_lbl.add_theme_font_size_override("font_size", 18)
		icon_lbl.add_theme_color_override("font_color", Color(0.55, 0.50, 0.45))
		name_lbl.text = "Bài %d" % item["id"]
		name_lbl.add_theme_color_override("font_color", Color(0.55, 0.48, 0.42))
		
	vbox.add_child(icon_lbl)
	vbox.add_child(name_lbl)
	slot.add_child(vbox)
	
	slot.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			if is_unlocked:
				_inspect_loot(item)
			else:
				SoundManager.play_fail()
				var lesson_title = GameManager.lessons_data.get(item["id"], {}).get("title", "")
				GameManager.emit_signal("show_toast", "🔒 Hoàn thành [Bài %d: %s] để rinh cúp này về bảo tàng!" % [item["id"], lesson_title])
	)
	return slot

# --- TẠO CARD BỘ GHÉP TRANH PUZZLE (JIGSAW PUZZLE CARD) ---
func _create_puzzle_card(pset: Dictionary) -> PanelContainer:
	var card = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var c_style = StyleBoxFlat.new()
	c_style.bg_color = Color(1.0, 0.985, 0.96, 1.0)
	c_style.border_color = Color(0.85, 0.75, 0.65, 1.0)
	c_style.set_border_width_all(1)
	c_style.border_width_bottom = 3
	c_style.set_corner_radius_all(14)
	c_style.content_margin_left = 12
	c_style.content_margin_right = 12
	c_style.content_margin_top = 10
	c_style.content_margin_bottom = 10
	c_style.shadow_color = Color(0, 0, 0, 0.05)
	c_style.shadow_size = 4
	c_style.shadow_offset = Vector2(0, 2)
	card.add_theme_stylebox_override("panel", c_style)
	
	var root_vbox = VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 8)
	card.add_child(root_vbox)
	
	# 1. Hàng Tiêu Đề Bộ Puzzle & Tiến độ
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 8)
	
	var icon_lbl = Label.new()
	icon_lbl.text = pset["icon"]
	icon_lbl.add_theme_font_size_override("font_size", 20)
	header_hbox.add_child(icon_lbl)
	
	var title_vbox = VBoxContainer.new()
	title_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_vbox.add_theme_constant_override("separation", 2)
	
	var title_lbl = Label.new()
	title_lbl.text = pset["title"]
	title_lbl.add_theme_font_size_override("font_size", 12)
	title_lbl.add_theme_color_override("font_color", Color(0.3, 0.2, 0.12))
	title_vbox.add_child(title_lbl)
	
	var desc_lbl = Label.new()
	desc_lbl.text = pset["desc"]
	desc_lbl.add_theme_font_size_override("font_size", 9)
	desc_lbl.add_theme_color_override("font_color", Color(0.5, 0.42, 0.35))
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_vbox.add_child(desc_lbl)
	header_hbox.add_child(title_vbox)
	
	# Đếm số mảnh đã mở trong bộ 4 bài
	var unlocked_pieces = 0
	for lid in pset["lessons"]:
		if _is_loot_unlocked(lid):
			unlocked_pieces += 1
			
	var is_completed = (unlocked_pieces == 4)
	var is_claimed = GameManager.is_certificate_claimed(pset["id"])
	
	var prog_pill = PanelContainer.new()
	var pill_style = StyleBoxFlat.new()
	pill_style.set_corner_radius_all(10)
	pill_style.content_margin_left = 8
	pill_style.content_margin_right = 8
	pill_style.content_margin_top = 4
	pill_style.content_margin_bottom = 4
	if is_completed:
		pill_style.bg_color = Color(0.25, 0.72, 0.45, 0.15)
		pill_style.border_color = Color(0.25, 0.72, 0.45, 1.0)
	else:
		pill_style.bg_color = Color(0.95, 0.65, 0.15, 0.15)
		pill_style.border_color = Color(0.95, 0.65, 0.15, 1.0)
	pill_style.set_border_width_all(1)
	prog_pill.add_theme_stylebox_override("panel", pill_style)
	
	var prog_lbl = Label.new()
	prog_lbl.add_theme_font_size_override("font_size", 10)
	if is_completed:
		prog_lbl.text = "🧩 4/4 Mảnh ✨"
		prog_lbl.add_theme_color_override("font_color", Color(0.15, 0.62, 0.35))
	else:
		prog_lbl.text = "🧩 %d/4 Mảnh" % unlocked_pieces
		prog_lbl.add_theme_color_override("font_color", Color(0.85, 0.45, 0.1))
	prog_pill.add_child(prog_lbl)
	header_hbox.add_child(prog_pill)
	root_vbox.add_child(header_hbox)
	
	# 2. Khung Ghép Tranh Puzzle 2x2 (GridContainer 2 cột)
	var grid_panel = PanelContainer.new()
	var gp_style = StyleBoxFlat.new()
	gp_style.bg_color = Color(0.94, 0.90, 0.85, 0.9)
	gp_style.set_border_width_all(2)
	gp_style.border_color = Color(0.82, 0.74, 0.65, 1.0)
	gp_style.set_corner_radius_all(10)
	gp_style.content_margin_left = 6
	gp_style.content_margin_right = 6
	gp_style.content_margin_top = 6
	gp_style.content_margin_bottom = 6
	grid_panel.add_theme_stylebox_override("panel", gp_style)
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_panel.add_child(grid)
	
	# Tạo 4 mảnh ghép
	for idx in range(pset["lessons"].size()):
		var lid = pset["lessons"][idx]
		var piece_item = ALL_16_LOOTS[lid - 1]
		var piece_unlocked = _is_loot_unlocked(lid)
		var piece_widget = _create_puzzle_piece(piece_item, idx + 1, piece_unlocked)
		grid.add_child(piece_widget)
		
	root_vbox.add_child(grid_panel)
	
	# 3. Khu vực Nhận Chứng Nhận & Quà Tặng Đặc Biệt
	if is_completed:
		if not is_claimed:
			var btn_claim = Button.new()
			btn_claim.name = "BtnClaim"
			btn_claim.custom_minimum_size = Vector2(0, 38)
			btn_claim.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			btn_claim.text = "📜 NHẬN CHỨNG NHẬN & QUÀ ĐẶC BIỆT (+%s 💵) 🎁" % GameManager.format_currency(pset["reward_money"])
			
			var claim_style = StyleBoxFlat.new()
			claim_style.bg_color = Color(0.95, 0.52, 0.15, 1.0)
			claim_style.set_border_width_all(2)
			claim_style.border_color = Color(0.80, 0.38, 0.05, 1.0)
			claim_style.border_width_bottom = 3
			claim_style.set_corner_radius_all(10)
			claim_style.shadow_color = Color(0.95, 0.52, 0.15, 0.3)
			claim_style.shadow_size = 4
			btn_claim.add_theme_stylebox_override("normal", claim_style)
			btn_claim.add_theme_color_override("font_color", Color(1, 1, 1))
			btn_claim.add_theme_font_size_override("font_size", 11)
			
			btn_claim.pressed.connect(func():
				_on_claim_certificate_pressed(pset)
			)
			root_vbox.add_child(btn_claim)
		else:
			var claimed_hbox = HBoxContainer.new()
			claimed_hbox.name = "ClaimedHBox"
			claimed_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
			claimed_hbox.add_theme_constant_override("separation", 8)
			
			var badge_lbl = Label.new()
			badge_lbl.text = "🎖️ ĐÃ CẤP CHỨNG NHẬN: %s" % pset["cert_title"]
			badge_lbl.add_theme_color_override("font_color", Color(0.18, 0.65, 0.32))
			badge_lbl.add_theme_font_size_override("font_size", 11)
			claimed_hbox.add_child(badge_lbl)
			
			var btn_view_cert = Button.new()
			btn_view_cert.name = "BtnViewCert"
			btn_view_cert.custom_minimum_size = Vector2(110, 30)
			btn_view_cert.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			btn_view_cert.text = "📜 Xem Bằng Khen"
			
			var vc_style = StyleBoxFlat.new()
			vc_style.bg_color = Color(0.95, 0.92, 0.88, 1.0)
			vc_style.border_color = Color(0.78, 0.70, 0.62, 1.0)
			vc_style.set_border_width_all(1)
			vc_style.border_width_bottom = 2
			vc_style.set_corner_radius_all(8)
			btn_view_cert.add_theme_stylebox_override("normal", vc_style)
			btn_view_cert.add_theme_color_override("font_color", Color(0.35, 0.25, 0.15))
			btn_view_cert.add_theme_font_size_override("font_size", 10)
			
			btn_view_cert.pressed.connect(func():
				_show_certificate_modal(pset)
			)
			claimed_hbox.add_child(btn_view_cert)
			root_vbox.add_child(claimed_hbox)
	else:
		var hint_lbl = Label.new()
		hint_lbl.text = "🔒 Ghép đủ 4 mảnh để mở khóa Chứng Nhận Danh Dự & Thưởng %s 💵" % GameManager.format_currency(pset["reward_money"])
		hint_lbl.add_theme_color_override("font_color", Color(0.55, 0.48, 0.40))
		hint_lbl.add_theme_font_size_override("font_size", 9)
		hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		root_vbox.add_child(hint_lbl)
		
	return card

# --- TẠO TỪNG MẢNH GHÉP PUZZLE (PUZZLE PIECE WIDGET) ---
func _create_puzzle_piece(item: Dictionary, piece_idx: int, is_unlocked: bool) -> PanelContainer:
	var piece = PanelContainer.new()
	piece.custom_minimum_size = Vector2(0, 56)
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
		style.bg_color = Color(1.0, 0.985, 0.94, 1.0)
		style.border_color = Color(0.92, 0.75, 0.35, 1.0)
		style.border_width_bottom = 2
	else:
		style.bg_color = Color(0.90, 0.86, 0.82, 0.8)
		style.border_color = Color(0.80, 0.75, 0.70, 1.0)
		
	piece.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var icon_lbl = Label.new()
	var text_vbox = VBoxContainer.new()
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	text_vbox.add_theme_constant_override("separation", 1)
	
	var name_lbl = Label.new()
	name_lbl.add_theme_font_size_override("font_size", 9)
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	
	var tag_lbl = Label.new()
	tag_lbl.add_theme_font_size_override("font_size", 8)
	
	if is_unlocked:
		icon_lbl.text = item["icon"]
		icon_lbl.add_theme_font_size_override("font_size", 20)
		name_lbl.text = item["name"]
		name_lbl.add_theme_color_override("font_color", Color(0.3, 0.2, 0.12))
		tag_lbl.text = "🧩 Mảnh %d • Đã Ghép" % piece_idx
		tag_lbl.add_theme_color_override("font_color", Color(0.2, 0.65, 0.3))
	else:
		icon_lbl.text = "🔒"
		icon_lbl.add_theme_font_size_override("font_size", 16)
		name_lbl.text = "Bài %d: Chưa mở" % item["id"]
		name_lbl.add_theme_color_override("font_color", Color(0.55, 0.48, 0.42))
		tag_lbl.text = "🧩 Mảnh %d • Cần mở" % piece_idx
		tag_lbl.add_theme_color_override("font_color", Color(0.65, 0.55, 0.45))
		
	text_vbox.add_child(name_lbl)
	text_vbox.add_child(tag_lbl)
	hbox.add_child(icon_lbl)
	hbox.add_child(text_vbox)
	piece.add_child(hbox)
	
	piece.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			if is_unlocked:
				_inspect_loot(item)
			else:
				SoundManager.play_fail()
				var lesson_title = GameManager.lessons_data.get(item["id"], {}).get("title", "")
				GameManager.emit_signal("show_toast", "🔒 Hãy hoàn thành [Bài %d: %s] để ghép mảnh này vào tranh!" % [item["id"], lesson_title])
	)
	return piece

# --- NHẬN CHỨNG NHẬN & QUÀ ĐẶC BIỆT ---
func _on_claim_certificate_pressed(pset: Dictionary) -> void:
	SoundManager.play_success()
	var res = GameManager.claim_certificate(pset["id"])
	if not res.is_empty():
		GameManager.emit_signal("show_toast", "🎉 Chúc mừng! Nhận Bằng [%s] và +%s! 🐾" % [
			pset["cert_title"],
			GameManager.format_currency(pset["reward_money"])
		])
	_show_certificate_modal(pset)
	refresh_museum()

# --- HIỂN THỊ MODAL BẰNG CHỨNG NHẬN HOÀNG GIA ---
func _show_certificate_modal(pset: Dictionary) -> void:
	SoundManager.play_card_pop()
	cert_modal_title.text = pset["cert_title"]
	cert_modal_rank.text = pset["cert_rank"]
	
	var sen_name = GameManager.get_owner_name()
	var boss_name = GameManager.get_cat_name()
	cert_modal_recipient.text = "Trao tặng cho: Sen %s & Boss %s 🐾" % [sen_name, boss_name]
	cert_modal_quote.text = "« " + pset["quote"] + " »"
	cert_modal_reward.text = "💵 +%s Tiền Thưởng • %s" % [
		GameManager.format_currency(pset["reward_money"]),
		pset["reward_item"]
	]
	
	cert_modal.visible = true
	var panel = $CertificateModal/CertPanel
	panel.scale = Vector2(0.85, 0.85)
	var tw = create_tween()
	tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK)

func _close_cert_modal() -> void:
	SoundManager.play_click()
	cert_modal.visible = false

# --- POPUP CHI TIẾT KHI CHẠM VÀO VẬT PHẨM ---
func _inspect_loot(item: Dictionary) -> void:
	SoundManager.play_card_pop()
	modal_icon.text = item["icon"]
	modal_title.text = item["full_name"]
	modal_category.text = "Chiến Lợi Phẩm • Bài %d (%s)" % [item["id"], item["category"]]
	modal_desc.text = item["desc"]
	modal_empathy.text = "🏆 Mảnh ghép sinh tồn tự hào minh chứng cho bước trưởng thành tự lập của Boss và Sen!"
	inspect_modal.visible = true
	_animate_modal()

func _animate_modal() -> void:
	var panel = $InspectModal/ModalPanel
	panel.scale = Vector2(0.88, 0.88)
	var tw = create_tween()
	tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK)

func _close_inspect_modal() -> void:
	SoundManager.play_click()
	inspect_modal.visible = false

# --- TÍNH NĂNG BẠN BÈ ---
func _on_gift_card_pressed() -> void:
	SoundManager.play_success()
	GameManager.emit_signal("show_toast", "💌 Đã tạo Link Thẻ Cứu Nguy BHYT! Bạn bè có thể xem ngay trên web không cần cài app!")

func _on_pate_rescue_pressed() -> void:
	SoundManager.play_click()
	if GameManager.fish >= 5:
		GameManager.update_stats(-5, 0, +10)
		SoundManager.play_success()
		GameManager.emit_signal("show_toast", "🥫 Đã gửi 1 hộp Pate (-5.000đ) sang phòng trọ bạn bè! Nhận danh hiệu 'Tình Làng Nghĩa Xóm' (+10 Mood)!")
	else:
		SoundManager.play_fail()
		GameManager.emit_signal("show_toast", "❌ Bạn không đủ tiền! Cần 5.000đ để gửi hộp Pate tiếp tế.")
