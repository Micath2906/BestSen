extends Control

# TrafficSafetyGame.gd - Kỹ năng 4: An toàn giao thông & Xử lý vi phạm hành chính (Lesson 4)
# Phase 1 (Game 1): Nối lỗi vi phạm giao thông với mức xử phạt / biện pháp ngăn chặn
# Phase 2 (Game 2): Sắp xếp thứ tự 4 bước xử lý khi xảy ra va chạm giao thông nhẹ

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

# Dữ liệu Phase 1: Nối lỗi vi phạm với mức xử phạt
const MATCHING_PAIRS = [
	{
		"id": "pair_alcohol",
		"col_a_text": "Điều khiển xe mô tô, xe gắn máy có nồng độ cồn vượt quá 0.4 mg/l khí thở",
		"col_b_text": "Phạt 6 - 8 triệu đồng, tước GPLX 22 - 24 tháng, tạm giữ xe",
		"law_ref": "Điểm e Khoản 8 Điều 6 Nghị định 100/2019/NĐ-CP: Nồng độ cồn kịch khung bị phạt tới 8 triệu, tước bằng lái đến 24 tháng và tạm giữ xe!"
	},
	{
		"id": "pair_helmet",
		"col_a_text": "Không đội 'mũ bảo hiểm cho người đi mô tô, xe máy' hoặc cài quai đúng quy cách",
		"col_b_text": "Phạt tiền từ 400.000 - 600.000 đồng",
		"law_ref": "Khoản 4 Điều 6 NĐ 100/2019 (sửa đổi bởi NĐ 123/2021): Không đội mũ bảo hiểm hoặc không cài quai phạt 400.000 - 600.000 đồng!"
	},
	{
		"id": "pair_license",
		"col_a_text": "Điều khiển xe mô tô hai bánh dung tích xi lanh dưới 175cc không có Giấy phép lái xe",
		"col_b_text": "Phạt tiền từ 1.000.000 - 2.000.000 đồng, tạm giữ xe đến 7 ngày",
		"law_ref": "Khoản 5 Điều 21 NĐ 100/2019 (sửa đổi): Lái xe máy không bằng lái phạt từ 1 - 2 triệu đồng và tạm giữ phương tiện đến 7 ngày!"
	}
]

# Dữ liệu Phase 2: 4 Bước xử lý va chạm giao thông nhẹ
const COLLISION_STEPS = [
	{
		"step": 1,
		"title": "Dừng xe ngay, giữ nguyên hiện trường & bật đèn cảnh báo",
		"icon": "🛑",
		"desc": "Tấp nhẹ vào hướng an toàn nếu nguy hiểm hoặc bật đèn khẩn cấp để các phương tiện khác quan sát tránh va chạm tiếp",
		"error_hint": "Vừa va chạm mà vội vã phóng xe bỏ chạy hoặc kéo xê dịch xe là vi phạm quy định xử lý tai nạn giao thông!"
	},
	{
		"step": 2,
		"title": "Kiểm tra tình trạng sức khỏe của các bên liên quan",
		"icon": "🩺",
		"desc": "Tính mạng con người là trên hết, ân cần thăm hỏi người va chạm xem có bị thương tích, trầy xước cần sơ cứu không",
		"error_hint": "Chưa hỏi han sức khỏe người ta xem có sao không mà đã nhảy bổ vào đôi co tiền bạc là sai đạo đức và quy tắc ứng xử!"
	},
	{
		"step": 3,
		"title": "Chụp ảnh, quay video hiện trường toàn cảnh và cận cảnh",
		"icon": "📸",
		"desc": "Ghi lại rõ ràng biển số 2 xe, vệt phanh trên đường, vết trầy xước của 2 xe để làm căn cứ xác định lỗi khách quan",
		"error_hint": "Không chụp ảnh bằng chứng hiện trường thì lát nữa giải quyết sẽ không có căn cứ pháp lý để phân định đúng sai!"
	},
	{
		"step": 4,
		"title": "Thương lượng bồi thường văn minh hoặc gọi CSGT 113",
		"icon": "🤝",
		"desc": "Bình tĩnh thỏa thuận chi phí sửa xe hợp lý; nếu đối phương say xỉn, hung hăng thì giữ khoảng cách an toàn và gọi ngay 113",
		"error_hint": "Đã có đủ ảnh hiện trường thì phải thỏa thuận văn minh hoặc nhờ công an phân xử, tuyệt đối không xô xát ẩu đả!"
	}
]

var current_phase: int = 1
var selected_col_a_id: String = ""
var matched_pairs: Dictionary = {}

var solved_steps: Dictionary = {}
var selected_step_card: Dictionary = {}

var shuffled_pairs_a: Array = []
var shuffled_pairs_b: Array = []
var shuffled_phase2_pool: Array = []

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

func load_minigame(data: Dictionary) -> void:
	title_lbl.text = "An Toàn Giao Thông & Xử Lý Vi Phạm"
	current_phase = 1
	matched_pairs.clear()
	selected_col_a_id = ""
	solved_steps.clear()
	selected_step_card = {}
	_render_phase1()

# =========================================================================
# PHASE 1: NỐI LỖI VI PHẠM VỚI MỨC XỬ PHẠT
# =========================================================================
func _render_phase1() -> void:
	current_phase = 1
	phase1_container.visible = true
	phase2_container.visible = false
	phase_badge_lbl.text = "GAME 1 / 2"
	phase_status_lbl.text = "🔗 Nối lỗi vi phạm giao thông với mức xử phạt"
	cat_speech_lbl.text = "Meo meo! Chạm một lỗi vi phạm ở Cột A, sau đó chạm mức xử phạt đúng ở Cột B nhé Sen! 🐾"
	btn_go_phase2.disabled = true
	
	# Random ngẫu nhiên thứ tự các câu hỏi và đáp án
	if shuffled_pairs_a.is_empty():
		shuffled_pairs_a = MATCHING_PAIRS.duplicate()
		shuffled_pairs_a.shuffle()
		shuffled_pairs_b = MATCHING_PAIRS.duplicate()
		shuffled_pairs_b.shuffle()
		
	_render_matching_columns()

func _render_matching_columns() -> void:
	for child in col_a_vbox.get_children(): child.queue_free()
	for child in col_b_vbox.get_children(): child.queue_free()
	
	# Cột A (Random)
	for p in shuffled_pairs_a:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 72)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.text = "🛵 %s" % p["col_a_text"]
		btn.add_theme_font_size_override("font_size", 11)
		
		var is_matched = matched_pairs.has(p["id"])
		var is_selected = (selected_col_a_id == p["id"])
		
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(10)
		style.set_border_width_all(2)
		style.content_margin_left = 10
		style.content_margin_right = 10
		style.content_margin_top = 6
		style.content_margin_bottom = 6
		
		if is_matched:
			# ĐÚNG CHUYỂN SANG XANH RỰC RỠ VÀ RÕ RÀNG
			style.bg_color = Color(0.20, 0.72, 0.38, 1.0)
			style.border_color = Color(0.12, 0.50, 0.22, 1.0)
			btn.disabled = true
			btn.text = "✔ %s" % p["col_a_text"]
			btn.add_theme_stylebox_override("disabled", style)
			btn.add_theme_stylebox_override("normal", style)
			btn.add_theme_color_override("font_disabled_color", Color(1.0, 1.0, 1.0, 1.0))
			btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
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
		
	# Cột B (Random ngẫu nhiên)
	for p in shuffled_pairs_b:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 72)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.text = "⚖️ %s" % p["col_b_text"]
		btn.add_theme_font_size_override("font_size", 11)
		
		var is_matched = matched_pairs.has(p["id"])
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(10)
		style.set_border_width_all(2)
		style.content_margin_left = 10
		style.content_margin_right = 10
		style.content_margin_top = 6
		style.content_margin_bottom = 6
		
		if is_matched:
			# ĐÚNG CHUYỂN SANG XANH RỰC RỠ VÀ RÕ RÀNG
			style.bg_color = Color(0.20, 0.72, 0.38, 1.0)
			style.border_color = Color(0.12, 0.50, 0.22, 1.0)
			btn.disabled = true
			btn.text = "✔ %s" % p["col_b_text"]
			btn.add_theme_stylebox_override("disabled", style)
			btn.add_theme_stylebox_override("normal", style)
			btn.add_theme_color_override("font_disabled_color", Color(1.0, 1.0, 1.0, 1.0))
			btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
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
	cat_speech_lbl.text = "Đã chọn lỗi vi phạm. Giờ hãy chọn mức xử phạt đúng ở Cột B nhé!"

func _on_col_b_pressed(pair_id: String) -> void:
	if selected_col_a_id == "":
		cat_speech_lbl.text = "Sen hãy chạm chọn 1 lỗi vi phạm ở Cột A trước nhé!"
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
			cat_speech_lbl.text = "🎉 XUẤT SẮC! Đã nắm rõ các mức xử phạt giao thông! Bấm Tiếp Tục sang Game 2 nào! ✨"
	else:
		SoundManager.play_card_pop()
		cat_speech_lbl.text = "Chưa đúng mức xử phạt rồi Sen ơi! Xem lại quy định tại Nghị định 100/2019 nhé!"

func _switch_to_phase2() -> void:
	SoundManager.play_click()
	current_phase = 2
	phase1_container.visible = false
	phase2_container.visible = true
	phase_badge_lbl.text = "GAME 2 / 2"
	phase_status_lbl.text = "📋 Sắp xếp 4 bước xử lý khi va chạm giao thông nhẹ"
	cat_speech_lbl.text = "Game 2: Hãy xếp 4 bước ứng phó khi xảy ra va chạm nhẹ theo đúng thứ tự 1 ➔ 2 ➔ 3 ➔ 4 nhé! 🐾"
	btn_finish_game.disabled = true
	if content_scroll: content_scroll.scroll_vertical = 0
	
	# Random thứ tự thẻ thao tác trong kho
	shuffled_phase2_pool = COLLISION_STEPS.duplicate()
	shuffled_phase2_pool.shuffle()
	
	_render_phase2_steps()
	_render_phase2_cards_pool()

# =========================================================================
# PHASE 2: SẮP XẾP 4 BƯỚC XỬ LÝ VA CHẠM GIAO THÔNG
# =========================================================================
func _render_phase2_steps() -> void:
	for child in steps_vbox.get_children(): child.queue_free()
	
	for s_info in COLLISION_STEPS:
		var s_idx = s_info["step"]
		var is_solved = solved_steps.has(s_idx)
		
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(0, 68)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(12)
		style.set_border_width_all(2)
		style.border_width_bottom = 3
		style.content_margin_left = 12
		style.content_margin_right = 12
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		
		if is_solved:
			# ĐÚNG CHUYỂN SANG XANH RỰC RỠ
			style.bg_color = Color(0.85, 0.98, 0.88, 1.0)
			style.border_color = Color(0.20, 0.72, 0.38, 1.0)
		else:
			style.bg_color = Color(1.0, 0.99, 0.97, 1.0)
			style.border_color = Color(0.88, 0.78, 0.66, 1.0)
		card.add_theme_stylebox_override("panel", style)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var badge = PanelContainer.new()
		badge.custom_minimum_size = Vector2(48, 48)
		var b_style = StyleBoxFlat.new()
		b_style.set_corner_radius_all(8)
		b_style.bg_color = Color(0.2, 0.55, 0.85, 1.0) if not is_solved else Color(0.20, 0.72, 0.38, 1.0)
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
			title_l.add_theme_color_override("font_color", Color(0.10, 0.50, 0.20, 1.0))
			title_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			vbox.add_child(title_l)
			
			var desc_l = Label.new()
			desc_l.text = s_info["desc"]
			desc_l.add_theme_font_size_override("font_size", 10)
			desc_l.add_theme_color_override("font_color", Color(0.35, 0.30, 0.25, 1.0))
			desc_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			vbox.add_child(desc_l)
		else:
			var slot_btn = Button.new()
			slot_btn.custom_minimum_size = Vector2(0, 36)
			slot_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			slot_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			slot_btn.add_theme_font_size_override("font_size", 11)
			var slot_sb = StyleBoxFlat.new()
			slot_sb.set_corner_radius_all(8)
			slot_sb.set_border_width_all(1)
			slot_sb.border_color = Color(0.85, 0.75, 0.65, 1.0)
			slot_sb.bg_color = Color(0.97, 0.95, 0.92, 1.0)
			slot_sb.content_margin_left = 10
			slot_sb.content_margin_right = 10
			slot_btn.add_theme_stylebox_override("normal", slot_sb)
			if selected_step_card.is_empty():
				slot_btn.text = "❓ [Ô Trống Bước %d: Chạm thẻ bên dưới để đặt]" % s_idx
				slot_btn.add_theme_color_override("font_color", Color(0.55, 0.45, 0.35, 1.0))
			else:
				# XÓA BỚT ĐÁP ÁN HIỆN SẴN TRÊN CÂU HỎI
				slot_btn.text = "👉 Chạm vào đây để đặt vào Bước %d" % s_idx
				slot_btn.add_theme_color_override("font_color", Color(0.1, 0.45, 0.85, 1.0))
			slot_btn.pressed.connect(func(): _on_phase2_slot_pressed(s_idx))
			vbox.add_child(slot_btn)
			
		hbox.add_child(vbox)
		card.add_child(hbox)
		steps_vbox.add_child(card)

func _render_phase2_cards_pool() -> void:
	for child in cards_pool.get_children(): child.queue_free()
	
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
			cat_speech_lbl.text = "🎉 XUẤT SẮC! Hoàn thành quy trình 4 bước xử lý va chạm giao thông văn minh! Bấm Hoàn Thành để nhận thưởng nhé!"
		else:
			cat_speech_lbl.text = "Chính xác! Bước %d đã hoàn tất! Tiếp tục đặt các bước còn lại nào!" % target_step_idx
	else:
		SoundManager.play_card_pop()
		var step_data = COLLISION_STEPS[target_step_idx - 1]
		cat_speech_lbl.text = "CHƯA ĐÚNG! %s" % step_data.get("error_hint", "Thao tác này chưa đúng thứ tự!")

func _on_finish_game_pressed() -> void:
	SoundManager.play_success()
	var speech = "🎉 CHÚC MỪNG TÀI XẾ VĂN MINH AN TOÀN!\n\n"
	speech += "Mèo con đã hoàn thành xuất sắc cả 2 Game An toàn Giao thông:\n\n"
	speech += "✔ Game 1: Nắm chắc mức phạt lỗi nguy hiểm:\n"
	speech += "  • Nồng độ cồn kịch khung: Phạt tới 8 triệu, tước bằng 24 tháng.\n"
	speech += "  • Không đội mũ bảo hiểm: Phạt 400.000 - 600.000đ.\n"
	speech += "  • Không bằng lái xe máy: Phạt 1 - 2 triệu đồng & tạm giữ xe.\n\n"
	speech += "✔ Game 2: Thuộc lòng 4 bước ứng phó va chạm chuẩn mực:\n"
	speech += "  1. Dừng xe, giữ hiện trường & bật đèn cảnh báo.\n"
	speech += "  2. Thăm hỏi sức khỏe các bên và sơ cứu nếu cần.\n"
	speech += "  3. Chụp ảnh, quay video hiện trường toàn cảnh và chi tiết.\n"
	speech += "  4. Thỏa thuận bồi thường văn minh hoặc gọi CSGT 113.\n\n"
	speech += "🎖️ Nhận danh hiệu 'Hiệp Sĩ Giao Thông' & Thưởng +35 Cá Khô!"
	victory_dialogue_lbl.text = speech
	victory_modal.visible = true

func _on_claim_reward_pressed() -> void:
	SoundManager.play_click()
	victory_modal.visible = false
	GameManager.complete_lesson(4)
	var sim_steps = [
		{"icon": "🛑", "text": "Dừng xe giữ hiện trường & bật đèn"},
		{"icon": "🩺", "text": "Hỏi thăm sức khỏe & sơ cứu"},
		{"icon": "📸", "text": "Chụp ảnh quay video bằng chứng"},
		{"icon": "🤝", "text": "Hòa giải văn minh hoặc gọi CSGT 113"}
	]
	emit_signal("minigame_completed", sim_steps)

func _on_guide_pressed() -> void:
	SoundManager.play_click()
	var guide_str = "📌 CẨM NANG AN TOÀN GIAO THÔNG CHO SINH VIÊN:\n\n"
	guide_str += "1. NGUYÊN TẮC 'ĐÃ UỐNG RƯỢU BIA - KHÔNG LÁI XE':\n"
	guide_str += "  • Mức phạt nồng độ cồn xe máy từ 2 triệu đến 8 triệu đồng.\n"
	guide_str += "  • Tước quyền sử dụng GPLX từ 10 đến 24 tháng.\n\n"
	guide_str += "2. GIẤY TỜ BẮT BUỘC PHẢI MANG KHI LÁI XE MÁY:\n"
	guide_str += "  • Giấy đăng ký xe (Cà vẹt xe).\n"
	guide_str += "  • Giấy phép lái xe (GPLX hạng A1).\n"
	guide_str += "  • Bảo hiểm trách nhiệm dân sự bắt buộc của chủ xe mô tô.\n"
	guide_str += "  • Căn cước công dân (hoặc tích hợp trên VNeID Mức 2).\n\n"
	guide_str += "3. KHI XẢY RA VA CHẠM:\n"
	guide_str += "  • Giữ bình tĩnh, không xô xát to tiếng.\n"
	guide_str += "  • Chụp ảnh làm chứng trước khi dịch chuyển xe."
	guide_content_lbl.text = guide_str
	guide_modal.visible = true
