extends Control

# PublicAdminGame.gd - Kỹ năng 5: Nhận biết thủ tục Hành chính công cơ bản (Lesson 7)
# Phase 1 (Game 1): Nối loại giấy tờ cá nhân với cơ quan giải quyết / Cổng DVC đúng thẩm quyền
# Phase 2 (Game 2): Sắp xếp thứ tự 4 bước nộp hồ sơ dịch vụ công trực tuyến qua VNeID

signal minigame_completed(sim_steps)
signal back_requested

@onready var btn_back: Button = $Header/BtnBack
@onready var btn_guide: Button = $Header/BtnGuide
@onready var title_lbl: Label = $Header/TitleLabel

@onready var phase_banner: PanelContainer = $PhaseBanner
@onready var phase_badge_lbl: Label = $PhaseBanner/HBox/PhaseBadgeLabel
@onready var phase_status_lbl: Label = $PhaseBanner/HBox/PhaseStatusLabel

@onready var content_scroll: ScrollContainer = $ContentScroll
@onready var phase1_container: VBoxContainer = $ContentScroll/VBox/Phase1Container
@onready var col_a_vbox: VBoxContainer = $ContentScroll/VBox/Phase1Container/ColumnsHBox/ColAVBox
@onready var col_b_vbox: VBoxContainer = $ContentScroll/VBox/Phase1Container/ColumnsHBox/ColBVBox
@onready var btn_go_phase2: Button = $ContentScroll/VBox/Phase1Container/BtnGoPhase2

@onready var phase2_container: VBoxContainer = $ContentScroll/VBox/Phase2Container
@onready var steps_vbox: VBoxContainer = $ContentScroll/VBox/Phase2Container/StepsVBox
@onready var cards_pool: Container = $ContentScroll/VBox/Phase2Container/CardsPool
@onready var btn_finish_game: Button = $ContentScroll/VBox/Phase2Container/BtnFinishGame

@onready var cat_speech_lbl: Label = $MascotSection/HBox/SpeechBubble/CatSpeechLabel

# Modals
@onready var guide_modal: Control = $GuideModal
@onready var guide_content_lbl: Label = $GuideModal/ModalPanel/VBox/Scroll/GuideContent
@onready var btn_close_guide: Button = $GuideModal/ModalPanel/VBox/BtnCloseGuide

@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue_lbl: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

# Dữ liệu Phase 1: Nối loại giấy tờ với cơ quan / cổng DVC
const MATCHING_PAIRS = [
	{
		"id": "pair_residence",
		"col_a_text": "Đăng ký tạm trú, thông báo lưu trú của sinh viên",
		"col_b_text": "Công an cấp xã/phường hoặc Cổng Dịch vụ công Quản lý Cư trú / VNeID",
		"law_ref": "Luật Cư trú 2020: Đăng ký tạm trú thuộc thẩm quyền Công an cấp xã/phường hoặc khai báo online qua ứng dụng VNeID!"
	},
	{
		"id": "pair_passport",
		"col_a_text": "Cấp hộ chiếu phổ thông lần đầu cho công dân",
		"col_b_text": "Phòng Quản lý Xuất nhập cảnh Công an cấp tỉnh hoặc Cổng DVC Bộ Công an",
		"law_ref": "Luật Xuất cảnh, nhập cảnh: Hộ chiếu cấp lần đầu do Phòng QLXNC Công an tỉnh hoặc Cổng DVC Bộ Công an thụ lý!"
	},
	{
		"id": "pair_marriage_status",
		"col_a_text": "Cấp Giấy xác nhận tình trạng hôn nhân (cho sinh viên)",
		"col_b_text": "Ủy ban nhân dân (UBND) cấp xã/phường nơi đăng ký thường trú",
		"law_ref": "Luật Hộ tịch: UBND cấp xã nơi thường trú có thẩm quyền cấp Giấy xác nhận tình trạng hôn nhân!"
	}
]

# Dữ liệu Phase 2: 4 Bước nộp hồ sơ DVC trực tuyến
const PUBLIC_ADMIN_STEPS = [
	{
		"step": 1,
		"title": "Đăng nhập tài khoản Định danh điện tử (VNeID Mức 2)",
		"icon": "🪪",
		"desc": "Truy cập dichvucong.gov.vn hoặc mở VNeID để xác thực danh tính công dân tự động qua cơ sở dữ liệu dân cư",
		"error_hint": "Chưa đăng nhập tài khoản định danh điện tử thì hệ thống không thể xác minh danh tính công dân nộp hồ sơ!"
	},
	{
		"step": 2,
		"title": "Tìm chọn đúng thủ tục & điền tờ khai trực tuyến",
		"icon": "🔍",
		"desc": "Tìm kiếm thủ tục (ví dụ: Đăng ký tạm trú), điền thông tin địa chỉ nơi ở mới và người cùng cư trú",
		"error_hint": "Chưa chọn đúng thủ tục và điền tờ khai thì hệ thống không có dữ liệu để chuyển sang khâu tải giấy tờ đính kèm!"
	},
	{
		"step": 3,
		"title": "Đính kèm tệp ảnh / scan tài liệu chứng minh hợp lệ",
		"icon": "📎",
		"desc": "Tải lên ảnh chụp hợp đồng thuê nhà, CCCD của chủ hộ cho thuê và giấy đồng ý cho đăng ký chỗ ở hợp pháp",
		"error_hint": "Không tải lên tài liệu chứng minh chỗ ở hợp pháp thì hồ sơ sẽ bị từ chối tiếp nhận vì thiếu căn cứ!"
	},
	{
		"step": 4,
		"title": "Gửi hồ sơ trực tuyến & lưu lại Mã số hồ sơ để tra cứu",
		"icon": "📑",
		"desc": "Bấm nộp hồ sơ, nhận giấy biên nhận điện tử có mã số để theo dõi quá trình thụ lý và nhận kết quả tại nhà",
		"error_hint": "Cần bấm nộp và lưu mã hồ sơ thì mới hoàn tất quá trình gửi đến cán bộ một cửa giải quyết!"
	}
]

var current_phase: int = 1
var selected_col_a_id: String = ""
var matched_pairs: Dictionary = {}

var solved_steps: Dictionary = {}
var selected_step_card: Dictionary = {}

func _ready() -> void:
	_setup_button_events()
	if guide_modal: guide_modal.visible = false
	if victory_modal: victory_modal.visible = false

func _setup_button_events() -> void:
	if btn_back:
		btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
		btn_back.pressed.connect(func():
			SoundManager.play_click()
			emit_signal("back_requested")
		)
	if btn_guide:
		btn_guide.pressed.connect(_on_guide_pressed)
	if btn_close_guide:
		btn_close_guide.pressed.connect(func():
			SoundManager.play_click()
			guide_modal.visible = false
		)
	if btn_go_phase2:
		btn_go_phase2.pressed.connect(_switch_to_phase2)
	if btn_finish_game:
		btn_finish_game.pressed.connect(_on_finish_game_pressed)
	if btn_claim_reward:
		btn_claim_reward.pressed.connect(_on_claim_reward_pressed)

var shuffled_pairs_a: Array = []
var shuffled_pairs_b: Array = []
var shuffled_phase2_pool: Array = []

func load_minigame(data: Dictionary) -> void:
	title_lbl.text = "Thủ Tục Hành Chính Công & VNeID"
	current_phase = 1
	matched_pairs.clear()
	selected_col_a_id = ""
	solved_steps.clear()
	selected_step_card = {}
	
	# Xáo trộn câu hỏi và đáp án
	shuffled_pairs_a = MATCHING_PAIRS.duplicate()
	shuffled_pairs_a.shuffle()
	shuffled_pairs_b = MATCHING_PAIRS.duplicate()
	shuffled_pairs_b.shuffle()
	shuffled_phase2_pool = PUBLIC_ADMIN_STEPS.duplicate()
	shuffled_phase2_pool.shuffle()
	
	_render_phase1()

# =========================================================================
# PHASE 1: NỐI LOẠI GIẤY TỜ VỚI CƠ QUAN THẨM QUYỀN
# =========================================================================
func _render_phase1() -> void:
	current_phase = 1
	phase1_container.visible = true
	phase2_container.visible = false
	phase_badge_lbl.text = "GAME 1 / 2"
	phase_status_lbl.text = "🔗 Nối thủ tục giấy tờ với cơ quan thẩm quyền"
	cat_speech_lbl.text = "Meo meo! Chạm một thủ tục ở Cột A, sau đó chạm cơ quan/cổng DVC đúng ở Cột B nhé Sen! 🐾"
	btn_go_phase2.disabled = true
	_render_matching_columns()

func _render_matching_columns() -> void:
	for child in col_a_vbox.get_children(): child.queue_free()
	for child in col_b_vbox.get_children(): child.queue_free()
	
	if shuffled_pairs_a.is_empty():
		shuffled_pairs_a = MATCHING_PAIRS.duplicate()
		shuffled_pairs_a.shuffle()
	if shuffled_pairs_b.is_empty():
		shuffled_pairs_b = MATCHING_PAIRS.duplicate()
		shuffled_pairs_b.shuffle()
	
	# Cột A (Đã xáo trộn)
	for p in shuffled_pairs_a:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 72)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.text = "🏛️ %s" % p["col_a_text"]
		btn.add_theme_font_size_override("font_size", 11)
		
		var is_matched = matched_pairs.has(p["id"])
		var is_selected = (selected_col_a_id == p["id"])
		
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(10)
		style.set_border_width_all(2)
		style.content_margin_left = 10
		style.content_margin_right = 10
		
		if is_matched:
			style.bg_color = Color(0.20, 0.72, 0.38, 1.0)
			style.border_color = Color(0.12, 0.50, 0.22, 1.0)
			btn.add_theme_stylebox_override("disabled", style)
			btn.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 1))
			btn.disabled = true
			btn.text = "✔ %s" % p["col_a_text"]
		elif is_selected:
			style.bg_color = Color(0.9, 0.95, 1.0, 1.0)
			style.border_color = Color(0.15, 0.55, 0.95, 1.0)
			btn.add_theme_stylebox_override("normal", style)
			btn.add_theme_color_override("font_color", Color(0.08, 0.35, 0.75, 1.0))
		else:
			style.bg_color = Color(1.0, 0.99, 0.97, 1.0)
			style.border_color = Color(0.88, 0.78, 0.66, 1.0)
			btn.add_theme_stylebox_override("normal", style)
			btn.add_theme_color_override("font_color", Color(0.25, 0.2, 0.15, 1.0))
			
		btn.pressed.connect(func(): _on_col_a_pressed(p["id"]))
		col_a_vbox.add_child(btn)
		
	# Cột B (Đã xáo trộn)
	for p in shuffled_pairs_b:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 72)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.text = "🏢 %s" % p["col_b_text"]
		btn.add_theme_font_size_override("font_size", 11)
		
		var is_matched = matched_pairs.has(p["id"])
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(10)
		style.set_border_width_all(2)
		style.content_margin_left = 10
		style.content_margin_right = 10
		
		if is_matched:
			style.bg_color = Color(0.20, 0.72, 0.38, 1.0)
			style.border_color = Color(0.12, 0.50, 0.22, 1.0)
			btn.add_theme_stylebox_override("disabled", style)
			btn.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 1))
			btn.disabled = true
			btn.text = "✔ %s" % p["col_b_text"]
		else:
			style.bg_color = Color(1.0, 0.99, 0.97, 1.0)
			style.border_color = Color(0.88, 0.78, 0.66, 1.0)
			btn.add_theme_stylebox_override("normal", style)
			btn.add_theme_color_override("font_color", Color(0.25, 0.2, 0.15, 1.0))
			
		btn.pressed.connect(func(): _on_col_b_pressed(p["id"]))
		col_b_vbox.add_child(btn)

func _on_col_a_pressed(pair_id: String) -> void:
	SoundManager.play_card_pop()
	selected_col_a_id = pair_id
	_render_matching_columns()
	cat_speech_lbl.text = "Đã chọn thủ tục. Giờ hãy chọn cơ quan / cổng DVC đúng ở Cột B nhé!"

func _on_col_b_pressed(pair_id: String) -> void:
	if selected_col_a_id == "":
		cat_speech_lbl.text = "Sen hãy chạm chọn 1 thủ tục ở Cột A trước nhé!"
		return
		
	if selected_col_a_id == pair_id:
		SoundManager.play_success()
		matched_pairs[pair_id] = true
		selected_col_a_id = ""
		_render_matching_columns()
		
		for p in MATCHING_PAIRS:
			if p["id"] == pair_id:
				cat_speech_lbl.text = "Chính xác! %s" % p["law_ref"]
				break
				
		if matched_pairs.size() == MATCHING_PAIRS.size():
			btn_go_phase2.disabled = false
			cat_speech_lbl.text = "🎉 XUẤT SẮC! Đã nắm rõ thẩm quyền giải quyết hành chính công! Bấm Tiếp Tục sang Game 2 nào! ✨"
	else:
		SoundManager.play_card_pop()
		cat_speech_lbl.text = "Chưa đúng cơ quan giải quyết rồi Sen ơi! Xem lại thẩm quyền Công an, UBND hay Xuất nhập cảnh nhé!"

func _switch_to_phase2() -> void:
	SoundManager.play_click()
	current_phase = 2
	phase1_container.visible = false
	phase2_container.visible = true
	phase_badge_lbl.text = "GAME 2 / 2"
	phase_status_lbl.text = "📲 Sắp xếp 4 bước nộp hồ sơ trực tuyến qua VNeID"
	cat_speech_lbl.text = "Game 2: Hãy xếp 4 bước nộp hồ sơ Dịch vụ công theo đúng thứ tự 1 ➔ 2 ➔ 3 ➔ 4 nhé! 🐾"
	btn_finish_game.disabled = true
	if content_scroll: content_scroll.scroll_vertical = 0
	_render_phase2_steps()
	_render_phase2_cards_pool()

# =========================================================================
# PHASE 2: SẮP XẾP 4 BƯỚC NỘP HỒ SƠ DVC TRỰC TUYẾN
# =========================================================================
func _render_phase2_steps() -> void:
	for child in steps_vbox.get_children(): child.queue_free()
	
	for s_info in PUBLIC_ADMIN_STEPS:
		var s_idx = s_info["step"]
		var is_solved = solved_steps.has(s_idx)
		
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 72)
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(12)
		style.set_border_width_all(2)
		style.border_width_bottom = 3
		style.content_margin_left = 12
		style.content_margin_right = 12
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		
		if is_solved:
			style.bg_color = Color(0.93, 0.98, 0.94, 1.0)
			style.border_color = Color(0.25, 0.72, 0.42, 1.0)
		else:
			style.bg_color = Color(1.0, 0.99, 0.97, 1.0)
			style.border_color = Color(0.88, 0.78, 0.66, 1.0)
		card.add_theme_stylebox_override("panel", style)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		
		var badge = PanelContainer.new()
		badge.custom_minimum_size = Vector2(48, 48)
		var b_style = StyleBoxFlat.new()
		b_style.set_corner_radius_all(8)
		b_style.bg_color = Color(0.2, 0.55, 0.85, 1.0) if not is_solved else Color(0.2, 0.7, 0.35, 1.0)
		badge.add_theme_stylebox_override("panel", b_style)
		var b_lbl = Label.new()
		b_lbl.text = "BƯỚC\n%d" % s_idx
		b_lbl.add_theme_font_size_override("font_size", 10)
		b_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		b_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge.add_child(b_lbl)
		hbox.add_child(badge)
		
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		if is_solved:
			var title_l = Label.new()
			title_l.text = "✔ %s %s" % [s_info["icon"], s_info["title"]]
			title_l.add_theme_font_size_override("font_size", 12)
			title_l.add_theme_color_override("font_color", Color(0.15, 0.55, 0.25, 1.0))
			vbox.add_child(title_l)
			
			var desc_l = Label.new()
			desc_l.text = s_info["desc"]
			desc_l.add_theme_font_size_override("font_size", 10)
			desc_l.add_theme_color_override("font_color", Color(0.4, 0.35, 0.3, 1.0))
			desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			vbox.add_child(desc_l)
		else:
			var slot_btn = Button.new()
			slot_btn.custom_minimum_size = Vector2(0, 36)
			slot_btn.add_theme_font_size_override("font_size", 11)
			var slot_sb = StyleBoxFlat.new()
			slot_sb.set_corner_radius_all(8)
			slot_sb.set_border_width_all(1)
			slot_sb.border_color = Color(0.85, 0.75, 0.65, 1.0)
			slot_sb.bg_color = Color(0.97, 0.95, 0.92, 1.0)
			slot_sb.content_margin_left = 10
			slot_sb.content_margin_right = 10
			slot_btn.add_theme_stylebox_override("normal", slot_sb)
			slot_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			slot_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			slot_btn.custom_minimum_size = Vector2(0, 46)
			if selected_step_card.is_empty():
				slot_btn.text = "❓ [Ô Trống Bước %d: Chạm thẻ thao tác bên dưới để đặt]" % s_idx
				slot_btn.add_theme_color_override("font_color", Color(0.55, 0.45, 0.35, 1.0))
			else:
				slot_btn.text = "👉 Chạm vào đây để đặt vào Bước %d" % s_idx
				slot_btn.add_theme_color_override("font_color", Color(0.1, 0.45, 0.85, 1.0))
			slot_btn.pressed.connect(func(): _on_phase2_slot_pressed(s_idx))
			vbox.add_child(slot_btn)
			
		hbox.add_child(vbox)
		card.add_child(hbox)
		steps_vbox.add_child(card)

func _render_phase2_cards_pool() -> void:
	for child in cards_pool.get_children(): child.queue_free()
	
	if shuffled_phase2_pool.is_empty():
		shuffled_phase2_pool = PUBLIC_ADMIN_STEPS.duplicate()
		shuffled_phase2_pool.shuffle()
		
	for s_info in shuffled_phase2_pool:
		var s_idx = s_info["step"]
		if solved_steps.has(s_idx): continue
		
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 46)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.text = "%s %s" % [s_info["icon"], s_info["title"]]
		btn.add_theme_font_size_override("font_size", 11)
		
		var is_selected = (not selected_step_card.is_empty() and selected_step_card["step"] == s_idx)
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(10)
		style.set_border_width_all(2)
		style.content_margin_left = 10
		style.content_margin_right = 10
		
		if is_selected:
			style.bg_color = Color(0.9, 0.95, 1.0, 1.0)
			style.border_color = Color(0.15, 0.55, 0.95, 1.0)
		else:
			style.bg_color = Color(1.0, 0.99, 0.97, 1.0)
			style.border_color = Color(0.88, 0.78, 0.66, 1.0)
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_color_override("font_color", Color(0.08, 0.35, 0.75, 1.0) if is_selected else Color(0.25, 0.2, 0.15, 1.0))
		
		btn.pressed.connect(func(): _on_phase2_card_tapped(s_info))
		cards_pool.add_child(btn)

func _on_phase2_card_tapped(s_info: Dictionary) -> void:
	SoundManager.play_card_pop()
	if not selected_step_card.is_empty() and selected_step_card["step"] == s_info["step"]:
		selected_step_card = {}
	else:
		selected_step_card = s_info.duplicate()
	_render_phase2_steps()
	_render_phase2_cards_pool()

func _on_phase2_slot_pressed(target_step_idx: int) -> void:
	if selected_step_card.is_empty():
		cat_speech_lbl.text = "Sen hãy chọn một thẻ thao tác ở khay bên dưới trước nhé!"
		return
		
	if selected_step_card["step"] == target_step_idx:
		SoundManager.play_success()
		solved_steps[target_step_idx] = selected_step_card
		selected_step_card = {}
		_render_phase2_steps()
		_render_phase2_cards_pool()
		
		if solved_steps.size() == 4:
			btn_finish_game.disabled = false
			cat_speech_lbl.text = "🎉 XUẤT SẮC! Hoàn thành quy trình 4 bước nộp hồ sơ Dịch vụ công qua VNeID! Bấm Hoàn Thành để nhận thưởng nhé!"
		else:
			cat_speech_lbl.text = "Chính xác! Bước %d đã hoàn tất! Tiếp tục đặt các bước còn lại nào!" % target_step_idx
	else:
		SoundManager.play_card_pop()
		var step_data = PUBLIC_ADMIN_STEPS[target_step_idx - 1]
		cat_speech_lbl.text = "CHƯA ĐÚNG! %s" % step_data.get("error_hint", "Thao tác này chưa đúng thứ tự!")

func _on_finish_game_pressed() -> void:
	SoundManager.play_success()
	var speech = "🎉 CHÚC MỪNG CÔNG DÂN SỐ THÔNG THÁI!\n\n"
	speech += "Mèo con đã hoàn thành xuất sắc cả 2 Game Thủ tục Hành chính công:\n\n"
	speech += "✔ Game 1: Nắm vững cơ quan có thẩm quyền:\n"
	speech += "  • Tạm trú / lưu trú: Công an phường hoặc VNeID.\n"
	speech += "  • Cấp hộ chiếu: Phòng QLXNC Công an tỉnh hoặc DVC Bộ Công an.\n"
	speech += "  • Giấy xác nhận hôn nhân: UBND cấp xã nơi thường trú.\n\n"
	speech += "✔ Game 2: Thành thạo 4 bước nộp hồ sơ trực tuyến:\n"
	speech += "  1. Đăng nhập VNeID mức 2.\n"
	speech += "  2. Chọn đúng thủ tục và điền tờ khai trực tuyến.\n"
	speech += "  3. Tải lên ảnh chụp hợp đồng thuê nhà & giấy tờ hợp lệ.\n"
	speech += "  4. Nộp hồ sơ và lưu mã số tra cứu kết quả.\n\n"
	speech += "Tự chủ cuộc sống đại học, giải quyết thủ tục nhanh chóng không lo bị phạt!\n\n"
	speech += "🎖️ Nhận danh hiệu 'Công Dân Số 4.0' & Thưởng +35 Cá Khô!"
	victory_dialogue_lbl.text = speech
	victory_modal.visible = true

func _on_claim_reward_pressed() -> void:
	SoundManager.play_click()
	victory_modal.visible = false
	GameManager.complete_lesson(7)
	var sim_steps = [
		{"icon": "🪪", "text": "Đăng nhập VNeID Mức 2"},
		{"icon": "🔍", "text": "Chọn thủ tục & điền biểu mẫu"},
		{"icon": "📎", "text": "Đính kèm giấy tờ thuê nhà hợp lệ"},
		{"icon": "📑", "text": "Nộp hồ sơ & nhận kết quả online"}
	]
	emit_signal("minigame_completed", sim_steps)

func _on_guide_pressed() -> void:
	SoundManager.play_click()
	var guide_str = "📌 CẨM NANG THỦ TỤC HÀNH CHÍNH CÔNG CHO SINH VIÊN:\n\n"
	guide_str += "1. ĐĂNG KÝ TẠM TRÚ (BẮT BUỘC):\n"
	guide_str += "  • Trong thời hạn 30 ngày kể từ ngày chuyển đến chỗ ở mới, phải làm thủ tục đăng ký tạm trú.\n"
	guide_str += "  • Hồ sơ gồm: Tờ khai thay đổi thông tin cư trú + Giấy tờ chứng minh chỗ ở hợp pháp (Hợp đồng thuê nhà).\n\n"
	guide_str += "2. LỢI ÍCH CỦA TÀI KHOẢN VNEID MỨC ĐỘ 2:\n"
	guide_str += "  • Thay thế CCCD vật lý và tích hợp thẻ BHYT, GPLX.\n"
	guide_str += "  • Thực hiện các thủ tục hành chính công trực tuyến ngay tại nhà mà không cần đến trụ sở công an."
	guide_content_lbl.text = guide_str
	guide_modal.visible = true
