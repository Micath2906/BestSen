extends Control

# LaborRightsGame.gd - Kỹ năng 2: Quyền lao động và Hợp đồng lao động cho người trẻ (Lesson 15)
# Phase 1 (Game 1): Nối chế định pháp lý với con số / thời hạn theo Bộ luật Lao động
# Phase 2 (Game 2): Phân loại Kéo - Thả vào 2 nhóm "Đúng luật lao động" vs "Vi phạm luật lao động"

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
@onready var basket_legal_vbox: VBoxContainer = $ContentScroll/VBox/Phase2Container/BasketsHBox/BasketLegal/InnerVBox/VBox
@onready var basket_illegal_vbox: VBoxContainer = $ContentScroll/VBox/Phase2Container/BasketsHBox/BasketIllegal/InnerVBox/VBox
@onready var btn_basket_legal: Button = $ContentScroll/VBox/Phase2Container/BasketsHBox/BasketLegal/InnerVBox/BtnAddLegal
@onready var btn_basket_illegal: Button = $ContentScroll/VBox/Phase2Container/BasketsHBox/BasketIllegal/InnerVBox/BtnAddIllegal
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

# Dữ liệu Phase 1: Nối chế định pháp lý với con số / thời hạn
const MATCHING_PAIRS = [
	{
		"id": "pair_probation_duration",
		"col_a_text": "Thời gian thử việc tối đa cho công việc có trình độ cao đẳng trở lên",
		"col_b_text": "Không quá 60 ngày",
		"law_ref": "Điều 25 Bộ luật Lao động 2019: Vị trí yêu cầu trình độ chuyên môn kỹ thuật từ cao đẳng trở lên thử việc tối đa 60 ngày!"
	},
	{
		"id": "pair_probation_salary",
		"col_a_text": "Mức lương tối thiểu trong thời gian thử việc theo luật định",
		"col_b_text": "Ít nhất 85% mức lương chính thức",
		"law_ref": "Điều 26 Bộ luật Lao động 2019: Tiền lương thử việc do hai bên thỏa thuận nhưng bắt buộc phải bằng ít nhất 85% lương chính thức!"
	},
	{
		"id": "pair_notice_period",
		"col_a_text": "Thời hạn báo trước khi đơn phương chấm dứt hợp đồng lao động không xác định thời hạn",
		"col_b_text": "Ít nhất 45 ngày",
		"law_ref": "Điều 35 Bộ luật Lao động 2019: Người lao động ký HĐLĐ không xác định thời hạn có quyền nghỉ việc nhưng phải báo trước ít nhất 45 ngày!"
	}
]

# Dữ liệu Phase 2: Phân loại 4 tình huống thực tế
const CLASSIFY_SCENARIOS = [
	{
		"id": "scen_hold_id",
		"title": "Công ty giữ bản gốc CCCD và Bằng tốt nghiệp ĐH làm tin",
		"is_legal": false,
		"explanation": "VI PHẠM LUẬT! Điều 17 Bộ luật Lao động nghiêm cấm NSDLĐ giữ bản chính giấy tờ tùy thân, văn bằng chứng chỉ của người lao động!"
	},
	{
		"id": "scen_long_probation",
		"title": "Thử việc 3 tháng cho vị trí nhân viên bán hàng part-time",
		"is_legal": false,
		"explanation": "VI PHẠM LUẬT! Vị trí bán hàng thông thường chỉ được thử việc tối đa 30 ngày (hoặc tối đa 60 ngày nếu yêu cầu chuyên môn cao). Thử việc 3 tháng là bóc lột sức lao động!"
	},
	{
		"id": "scen_holiday_overtime",
		"title": "Tiền lương làm thêm giờ vào ngày nghỉ Lễ, Tết được trả ít nhất 300%",
		"is_legal": true,
		"explanation": "ĐÚNG LUẬT LAO ĐỘNG! Điều 98 BLLĐ 2019 quy định làm thêm giờ vào ngày nghỉ lễ, tết hưởng ít nhất bằng 300% (chưa kể tiền lương ngày lễ đối với NLĐ hưởng lương ngày)!"
	},
	{
		"id": "scen_social_insurance",
		"title": "Đóng BHXH, BHYT bắt buộc cho hợp đồng lao động từ đủ 1 tháng trở lên",
		"is_legal": true,
		"explanation": "ĐÚNG LUẬT LAO ĐỘNG! Theo Luật BHXH, hợp đồng lao động từ đủ 1 tháng trở lên thuộc đối tượng bắt buộc tham gia BHXH và BHYT!"
	}
]

var current_phase: int = 1
var selected_col_a_id: String = ""
var matched_pairs: Dictionary = {}

var selected_classify_card: Dictionary = {}
var categorized_items: Dictionary = {} # item_id -> "legal" or "illegal"

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
	if btn_basket_legal:
		btn_basket_legal.pressed.connect(func(): _on_basket_chosen("legal"))
	if btn_basket_illegal:
		btn_basket_illegal.pressed.connect(func(): _on_basket_chosen("illegal"))

var shuffled_pairs_a: Array = []
var shuffled_pairs_b: Array = []
var shuffled_scenarios: Array = []

func load_minigame(data: Dictionary) -> void:
	title_lbl.text = "Quyền Lao Động & HĐLĐ Người Trẻ"
	current_phase = 1
	matched_pairs.clear()
	selected_col_a_id = ""
	selected_classify_card = {}
	categorized_items.clear()
	
	# Xáo trộn câu hỏi và đáp án
	shuffled_pairs_a = MATCHING_PAIRS.duplicate()
	shuffled_pairs_a.shuffle()
	shuffled_pairs_b = MATCHING_PAIRS.duplicate()
	shuffled_pairs_b.shuffle()
	shuffled_scenarios = CLASSIFY_SCENARIOS.duplicate()
	shuffled_scenarios.shuffle()
	
	_render_phase1()

# =========================================================================
# PHASE 1: NỐI CHẾ ĐỊNH PHÁP LÝ VỚI CON SỐ / THỜI HẠN
# =========================================================================
func _render_phase1() -> void:
	current_phase = 1
	phase1_container.visible = true
	phase2_container.visible = false
	phase_badge_lbl.text = "GAME 1 / 2"
	phase_status_lbl.text = "🔗 Nối chế định pháp lý với con số / thời hạn"
	cat_speech_lbl.text = "Meo meo! Chạm một chế định ở Cột A, sau đó chạm con số/thời hạn tương ứng ở Cột B nhé Sen! 🐾"
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
		btn.text = "📌 %s" % p["col_a_text"]
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
		btn.text = "⏳ %s" % p["col_b_text"]
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
	cat_speech_lbl.text = "Đã chọn chế định. Giờ hãy chọn con số / thời hạn tương ứng ở Cột B nhé!"

func _on_col_b_pressed(pair_id: String) -> void:
	if selected_col_a_id == "":
		cat_speech_lbl.text = "Sen hãy chạm chọn 1 chế định pháp lý ở Cột A trước nhé!"
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
			cat_speech_lbl.text = "🎉 XUẤT SẮC! Đã ghi nhớ trọn vẹn các mốc thời gian luật định! Bấm Tiếp Tục sang Game 2 nào! ✨"
	else:
		SoundManager.play_card_pop()
		cat_speech_lbl.text = "Chưa đúng con số luật định rồi Sen ơi! Xem lại quy định thử việc & thời hạn báo trước nhé!"

func _switch_to_phase2() -> void:
	SoundManager.play_click()
	current_phase = 2
	phase1_container.visible = false
	phase2_container.visible = true
	phase_badge_lbl.text = "GAME 2 / 2"
	phase_status_lbl.text = "⚖️ Phân loại tình huống: Đúng luật vs Vi phạm"
	cat_speech_lbl.text = "Game 2: Hãy phân loại 4 tình huống vào 2 nhóm 'Đúng Luật' hoặc 'Vi Phạm' nhé! 🐾"
	btn_finish_game.disabled = true
	if content_scroll: content_scroll.scroll_vertical = 0
	_render_phase2_baskets()
	_render_phase2_cards_pool()

# =========================================================================
# PHASE 2: PHÂN LOẠI ĐÚNG LUẬT VS VI PHẠM
# =========================================================================
func _render_phase2_baskets() -> void:
	for child in basket_legal_vbox.get_children(): child.queue_free()
	for child in basket_illegal_vbox.get_children(): child.queue_free()
	
	for scen in CLASSIFY_SCENARIOS:
		var s_id = scen["id"]
		if not categorized_items.has(s_id): continue
		
		var label = Label.new()
		label.text = "• %s" % scen["title"]
		label.add_theme_font_size_override("font_size", 10)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		if categorized_items[s_id] == "legal":
			label.add_theme_color_override("font_color", Color(0.12, 0.52, 0.22, 1.0))
			basket_legal_vbox.add_child(label)
		else:
			label.add_theme_color_override("font_color", Color(0.82, 0.2, 0.15, 1.0))
			basket_illegal_vbox.add_child(label)

func _render_phase2_cards_pool() -> void:
	for child in cards_pool.get_children(): child.queue_free()
	
	if shuffled_scenarios.is_empty():
		shuffled_scenarios = CLASSIFY_SCENARIOS.duplicate()
		shuffled_scenarios.shuffle()
		
	for scen in shuffled_scenarios:
		var s_id = scen["id"]
		if categorized_items.has(s_id): continue
		
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 52)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.text = "📄 %s" % scen["title"]
		btn.add_theme_font_size_override("font_size", 11)
		
		var is_selected = (not selected_classify_card.is_empty() and selected_classify_card["id"] == s_id)
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
		
		btn.pressed.connect(func(): _on_classify_card_tapped(scen))
		cards_pool.add_child(btn)

func _on_classify_card_tapped(scen: Dictionary) -> void:
	SoundManager.play_card_pop()
	if not selected_classify_card.is_empty() and selected_classify_card["id"] == scen["id"]:
		selected_classify_card = {}
		cat_speech_lbl.text = "Đã bỏ chọn tình huống. Chạm thẻ để chọn lại nhé!"
	else:
		selected_classify_card = scen.duplicate()
		cat_speech_lbl.text = "Đang chọn: '%s'. Hãy bấm nút ở nhóm [Đúng Luật] hoặc [Vi Phạm] để phân loại!" % scen["title"]
	_render_phase2_cards_pool()

func _on_basket_chosen(target_basket: String) -> void:
	if selected_classify_card.is_empty():
		cat_speech_lbl.text = "Sen hãy chọn một tình huống ở khay bên dưới trước nhé!"
		return
		
	var is_target_legal = (target_basket == "legal")
	if selected_classify_card["is_legal"] == is_target_legal:
		SoundManager.play_success()
		categorized_items[selected_classify_card["id"]] = target_basket
		cat_speech_lbl.text = "CHÍNH XÁC! %s" % selected_classify_card["explanation"]
		selected_classify_card = {}
		_render_phase2_baskets()
		_render_phase2_cards_pool()
		
		if categorized_items.size() == CLASSIFY_SCENARIOS.size():
			btn_finish_game.disabled = false
			cat_speech_lbl.text = "🎉 XUẤT SẮC! Bạn đã phân loại chính xác toàn bộ 4 tình huống pháp luật lao động! Bấm Hoàn Thành để nhận thưởng!"
	else:
		SoundManager.play_fail()
		cat_speech_lbl.text = "CHƯA ĐÚNG! %s" % selected_classify_card["explanation"]

func _on_finish_game_pressed() -> void:
	SoundManager.play_success()
	var speech = "🎉 CHÚC MỪNG CHIẾN BINH BẢO VỆ QUYỀN LAO ĐỘNG!\n\n"
	speech += "Mèo con đã hoàn thành xuất sắc cả 2 Game quyền lao động:\n\n"
	speech += "✔ Game 1: Nắm chắc 3 chế định cốt lõi:\n"
	speech += "  • Thử việc trình độ CĐ/ĐH: Không quá 60 ngày.\n"
	speech += "  • Lương thử việc: Ít nhất 85% lương chính thức.\n"
	speech += "  • Báo trước chấm dứt HĐ vô thời hạn: Ít nhất 45 ngày.\n\n"
	speech += "✔ Game 2: Nhận diện bẫy bóc lột & quyền lợi hợp pháp:\n"
	speech += "  • Nghiêm cấm giữ bản chính CCCD & bằng cấp.\n"
	speech += "  • Làm thêm giờ Lễ/Tết hưởng ít nhất 300%.\n"
	speech += "  • HĐLĐ từ 1 tháng bắt buộc tham gia BHXH, BHYT.\n\n"
	speech += "🎖️ Nhận danh hiệu 'Người Lao Động Thông Thái' & Thưởng +35 Cá Khô!"
	victory_dialogue_lbl.text = speech
	victory_modal.visible = true

func _on_claim_reward_pressed() -> void:
	SoundManager.play_click()
	victory_modal.visible = false
	GameManager.complete_lesson(15)
	var sim_steps = [
		{"icon": "⏳", "text": "Thử việc đúng thời hạn & 85% lương"},
		{"icon": "🪪", "text": "Không để NSDLĐ giữ bản gốc CCCD/Bằng"},
		{"icon": "📈", "text": "Hưởng đúng lương thêm giờ Lễ Tết 300%"},
		{"icon": "🛡️", "text": "Đóng BHXH, BHYT từ 1 tháng hợp đồng"}
	]
	emit_signal("minigame_completed", sim_steps)

func _on_guide_pressed() -> void:
	SoundManager.play_click()
	var guide_str = "📌 CẨM NANG PHÁP LUẬT LAO ĐỘNG CHO SINH VIÊN:\n\n"
	guide_str += "1. THỬ VIỆC AN TOÀN:\n"
	guide_str += "  • Không thử việc quá 60 ngày (CĐ/ĐH) hoặc 30 ngày (lao động phổ thông).\n"
	guide_str += "  • Lương thử việc tối thiểu 85% mức lương chính thức.\n\n"
	guide_str += "2. NHỮNG ĐIỀU CẤM ĐỐI VỚI CHỦ SỬ DỤNG LAO ĐỘNG:\n"
	guide_str += "  • Tuyệt đối KHÔNG giữ bản chính CCCD, hộ chiếu hoặc văn bằng gốc.\n"
	guide_str += "  • Không bắt nộp tiền đặt cọc giữ chỗ làm việc.\n\n"
	guide_str += "3. CHẾ ĐỘ THỜI GIAN LÀM THÊM:\n"
	guide_str += "  • Làm thêm ngày thường: ít nhất 150%.\n"
	guide_str += "  • Làm thêm ngày nghỉ hàng tuần: ít nhất 200%.\n"
	guide_str += "  • Làm thêm ngày nghỉ Lễ, Tết: ít nhất 300%."
	guide_content_lbl.text = guide_str
	guide_modal.visible = true
