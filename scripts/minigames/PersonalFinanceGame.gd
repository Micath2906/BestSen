extends Control

# PersonalFinanceGame.gd - Kỹ năng 1: Quản lý tài chính cá nhân
# Phase 1 (Game 1): Nối đáp án "Chi tiêu thông minh" (5 khoản chi Cột A với 5 nhóm Cột B)
# Phase 2 (Game 2): Tình huống lựa chọn "Sống sót với 5 triệu đồng" & Xử lý chi phí phát sinh

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
@onready var budget_panel: PanelContainer = $ContentScroll/VBox/Phase2Container/BudgetPanel
@onready var budget_amount_lbl: Label = $ContentScroll/VBox/Phase2Container/BudgetPanel/VBox/BudgetAmountLabel
@onready var budget_desc_lbl: Label = $ContentScroll/VBox/Phase2Container/BudgetPanel/VBox/BudgetDescLabel
@onready var scenario_card: PanelContainer = $ContentScroll/VBox/Phase2Container/ScenarioCard
@onready var scenario_num_lbl: Label = $ContentScroll/VBox/Phase2Container/ScenarioCard/VBox/ScenarioNumLabel
@onready var scenario_title_lbl: Label = $ContentScroll/VBox/Phase2Container/ScenarioCard/VBox/ScenarioTitleLabel
@onready var scenario_desc_lbl: Label = $ContentScroll/VBox/Phase2Container/ScenarioCard/VBox/ScenarioDescLabel
@onready var options_vbox: VBoxContainer = $ContentScroll/VBox/Phase2Container/ScenarioCard/VBox/OptionsVBox
@onready var feedback_lbl: Label = $ContentScroll/VBox/Phase2Container/ScenarioCard/VBox/FeedbackLabel
@onready var btn_next_scenario: Button = $ContentScroll/VBox/Phase2Container/ScenarioCard/VBox/BtnNextScenario
@onready var btn_finish_game: Button = $ContentScroll/VBox/Phase2Container/BtnFinishGame

@onready var cat_speech_lbl: Label = $MascotSection/HBox/SpeechBubble/CatSpeechLabel

# Modals
@onready var guide_modal: Control = $GuideModal
@onready var guide_content_lbl: Label = $GuideModal/ModalPanel/VBox/Scroll/GuideContent
@onready var btn_close_guide: Button = $GuideModal/ModalPanel/VBox/BtnCloseGuide

@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue_lbl: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

# Dữ liệu Phase 1: 5 Cặp Nối Khoản Chi -> Nhóm Chi Phí
const MATCHING_PAIRS = [
	{
		"id": "pf_rent",
		"col_a_text": "Tiền thuê trọ (1.500.000đ)",
		"col_b_text": "Chi phí thiết yếu (Chỗ ở an toàn)",
		"hint": "Thuê trọ là nhu cầu thiết yếu bắt buộc để có nơi sinh hoạt và học tập ổn định!"
	},
	{
		"id": "pf_food",
		"col_a_text": "Tiền ăn uống hàng ngày",
		"col_b_text": "Chi phí thiết yếu (Dinh dưỡng duy trì sự sống)",
		"hint": "Ăn uống đủ chất là chi phí thiết yếu sống còn, không nên nhịn ăn để tiết kiệm!"
	},
	{
		"id": "pf_clothes",
		"col_a_text": "Tiền mua quần áo mới / Trà sữa",
		"col_b_text": "Chi phí không thiết yếu (Mong muốn cá nhân)",
		"hint": "Quần áo mới và trà sữa là mong muốn, có thể cắt giảm linh hoạt khi ngân sách eo hẹp!"
	},
	{
		"id": "pf_saving",
		"col_a_text": "Tiền tiết kiệm / Quỹ khẩn cấp",
		"col_b_text": "Khoản tích lũy (Dự phòng rủi ro tương lai)",
		"hint": "Nên trích ngay 10-15% đầu tháng vào quỹ dự phòng trước khi bắt đầu chi tiêu!"
	},
	{
		"id": "pf_utility",
		"col_a_text": "Tiền điện nước, internet trọ",
		"col_b_text": "Chi phí sinh hoạt (Hóa đơn cố định hàng tháng)",
		"hint": "Hóa đơn điện nước là chi phí sinh hoạt hàng tháng cần thanh toán đúng hạn tránh bị cắt!"
	}
]

# Dữ liệu Phase 2: Sống sót với 5 triệu đồng (3 Tình huống phát sinh)
const SCENARIOS = [
	{
		"id": "scen_broken_bike",
		"title": "Sự Cố Dọc Đường: Thủng Xăm & Hỏng Bugi",
		"desc": "Giữa tuần đang đi học thì xe máy bị cán đinh và chết máy. Bác thợ sửa xe báo giá vá xăm và thay bugi mới hết 150.000đ. Ngân sách tuần này của bạn vừa khít tiền cơm.",
		"options": [
			{
				"text": "A. Trích 150.000đ từ Quỹ dự phòng khẩn cấp đã tiết kiệm đầu tháng",
				"is_correct": true,
				"feedback": "Chính xác! Quỹ dự phòng khẩn cấp sinh ra chính là để giải quyết các sự cố bất ngờ như thế này mà không làm xáo trộn tiền ăn học!"
			},
			{
				"text": "B. Quyết định nhịn ăn 3 ngày để bù lại số tiền sửa xe",
				"is_correct": false,
				"feedback": "Sai lầm! Nhịn ăn gây kiệt sức, đau dạ dày và tiền thuốc men sau đó sẽ tốn gấp nhiều lần tiền sửa xe!"
			},
			{
				"text": "C. Nhấn vào app vay tiền online hoặc tín dụng đen trên mạng để vay nóng",
				"is_correct": false,
				"feedback": "Rất nguy hiểm! Bẫy tín dụng đen với lãi suất cắt cổ sẽ cuốn sinh viên vào vòng xoáy nợ nần không lối thoát!"
			}
		]
	},
	{
		"id": "scen_class_fund",
		"title": "Phát Sinh Học Tập: Giáo Trình & Quỹ Lớp",
		"desc": "Đầu tháng giáo viên thông báo mua bộ giáo trình thực hành bắt buộc và lớp thu quỹ photo tài liệu tổng cộng 200.000đ ngoài dự kiến.",
		"options": [
			{
				"text": "A. Chủ động cắt giảm ngân sách ăn vặt, trà sữa và giải trí tuần này để bù vào",
				"is_correct": true,
				"feedback": "Rất thông minh! Khoản chi học tập là cần thiết, sinh viên khéo léo co kéo bằng cách giảm các chi phí 'mong muốn' không thiết yếu!"
			},
			{
				"text": "B. Trốn đóng quỹ lớp và mượn sách chép trộm tài liệu của bạn",
				"is_correct": false,
				"feedback": "Ý thức kém! Thiếu trung thực và gây mất đoàn kết với bạn bè trong lớp!"
			},
			{
				"text": "C. Gọi điện xin phụ huynh gấp đôi số tiền với lý do đóng học phí bổ sung",
				"is_correct": false,
				"feedback": "Không nên! Học cách tự chủ và phân bổ ngân sách 5 triệu thay vì phụ thuộc và nói dối gia đình!"
			}
		]
	},
	{
		"id": "scen_buffet_party",
		"title": "Cám Dỗ Bạn Bè: Kèo Lẩu Nướng Cuối Tháng",
		"desc": "Vào ngày 25 của tháng, quỹ giải trí của bạn đã hết nhẵn. Nhóm bạn thân rủ đi ăn buffet lẩu nướng mừng sinh nhật một bạn với chi phí 350.000đ/người.",
		"options": [
			{
				"text": "A. Từ chối khéo: 'Tháng này tớ hết quỹ rồi, chúc mừng sinh nhật cậu nhé! Tụi mình hẹn nhau trà đá trò chuyện bù sau nha!'",
				"is_correct": true,
				"feedback": "Tuyệt vời! Dũng cảm nói lời từ chối lịch sự và giữ vững kỷ luật tài chính là kỹ năng quan trọng nhất của người tự lập!"
			},
			{
				"text": "B. Mượn tiền bạn cùng phòng để đi ăn cho bằng bạn bằng bè rồi tháng sau tính tiếp",
				"is_correct": false,
				"feedback": "Sai lầm! Vay mượn tiêu dùng chỉ để phục vụ sĩ diện sẽ khiến bạn liên tục rơi vào cảnh 'đầu tháng trả nợ, cuối tháng đói meo'!"
			},
			{
				"text": "C. Kích hoạt thẻ ví trả sau / thẻ tín dụng để quẹt nợ tiêu trước trả sau",
				"is_correct": false,
				"feedback": "Nguy cơ cao! Quẹt ví trả sau khi chưa có thu nhập ổn định là bước đầu tiên rơi vào bẫy nợ tiêu dùng!"
			}
		]
	}
]

var current_phase: int = 1
var selected_col_a_id: String = ""
var matched_pairs: Dictionary = {}

var current_scenario_idx: int = 0
var completed_scenarios: int = 0

func _ready() -> void:
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(_on_back_pressed)
	btn_guide.pressed.connect(_on_guide_pressed)
	btn_close_guide.pressed.connect(func(): guide_modal.visible = false)
	btn_go_phase2.pressed.connect(_switch_to_phase2)
	btn_next_scenario.pressed.connect(_on_next_scenario_pressed)
	btn_finish_game.pressed.connect(_on_finish_game_pressed)
	btn_claim_reward.pressed.connect(_on_claim_reward_pressed)
	
	_setup_guide_content()
	_init_phase1()

func load_minigame(_data: Dictionary = {}) -> void:
	# Khởi tạo dữ liệu minigame
	_init_phase1()

func _setup_guide_content() -> void:
	var guide_text = """CẨM NANG: QUẢN LÝ TÀI CHÍNH CÁ NHÂN CHO SINH VIÊN

1. Quy tắc 50/30/20 & Phân loại chi tiêu:
- 50% Nhu cầu thiết yếu: Tiền phòng trọ, ăn uống dinh dưỡng, điện nước, xăng xe đi lại.
- 30% Mong muốn linh hoạt: Mua sắm quần áo, ăn vặt, giải trí, cà phê gặp gỡ bạn bè.
- 20% Tích lũy & Dự phòng: Quỹ khẩn cấp đề phòng ốm đau, xe hỏng, học hành phát sinh.

2. Kỷ luật 'Chi tiêu trước - Tiết kiệm sau' là sai lầm:
- Hãy 'Tiết kiệm trước - Chi tiêu phần còn lại'. Đầu tháng trích ngay 10-15% cất vào quỹ dự phòng.

3. Kỹ năng từ chối lịch sự:
- Biết giới hạn ngân sách bản thân và dũng cảm từ chối các cuộc hẹn ăn chơi đắt đỏ vượt quá khả năng tài chính."""
	guide_content_lbl.text = guide_text

func _init_phase1() -> void:
	current_phase = 1
	selected_col_a_id = ""
	matched_pairs = {}
	
	phase1_container.visible = true
	phase2_container.visible = false
	btn_go_phase2.disabled = true
	
	phase_badge_lbl.text = "GAME 1 / 2"
	phase_status_lbl.text = "🔗 Nối khoản chi Cột A với nhóm chi phí Cột B (0/5)"
	cat_speech_lbl.text = "Meo! Hãy giúp Mèo phân loại 5 khoản chi tiêu vào đúng nhóm để quản lý tiền thông minh nhé!"
	
	_render_matching_columns()

func _render_matching_columns() -> void:
	for child in col_a_vbox.get_children():
		child.queue_free()
	for child in col_b_vbox.get_children():
		child.queue_free()
		
	# Cột A giữ nguyên thứ tự
	for p in MATCHING_PAIRS:
		var btn = Button.new()
		btn.text = p["col_a_text"]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 52)
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", Color(0.25, 0.2, 0.15))
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.pressed.connect(_on_col_a_pressed.bind(p["id"]))
		_apply_button_normal_style(btn)
		col_a_vbox.add_child(btn)
		
	# Cột B đảo ngẫu nhiên
	var shuffled_b = MATCHING_PAIRS.duplicate()
	shuffled_b.shuffle()
	for p in shuffled_b:
		var btn = Button.new()
		btn.text = p["col_b_text"]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 52)
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", Color(0.2, 0.35, 0.6))
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.pressed.connect(_on_col_b_pressed.bind(p["id"]))
		_apply_button_normal_style(btn)
		col_b_vbox.add_child(btn)

func _on_col_a_pressed(id: String) -> void:
	if matched_pairs.has(id):
		return
	selected_col_a_id = id
	SoundManager.play_click()
	
	# Highlight nút được chọn
	for i in range(MATCHING_PAIRS.size()):
		var p = MATCHING_PAIRS[i]
		if i < col_a_vbox.get_child_count():
			var btn = col_a_vbox.get_child(i) as Button
			if matched_pairs.has(p["id"]):
				_apply_button_matched_style(btn)
			elif p["id"] == id:
				_apply_button_selected_style(btn)
			else:
				_apply_button_normal_style(btn)
	cat_speech_lbl.text = "Bạn vừa chọn '%s'. Giờ hãy chọn nhóm chi phí phù hợp ở Cột B!" % _get_pair(id).get("col_a_text", "")

func _on_col_b_pressed(id: String) -> void:
	if matched_pairs.has(id):
		return
	if selected_col_a_id == "":
		cat_speech_lbl.text = "Meo! Bạn hãy chọn một khoản chi ở Cột A trước nhé!"
		SoundManager.play_fail()
		return
		
	if selected_col_a_id == id:
		# Nối chính xác
		matched_pairs[id] = true
		SoundManager.play_success()
		cat_speech_lbl.text = "Chính xác! " + _get_pair(id).get("hint", "")
		_update_matching_styles()
		selected_col_a_id = ""
		
		phase_status_lbl.text = "🔗 Nối khoản chi Cột A với nhóm chi phí Cột B (%d/5)" % matched_pairs.size()
		
		if matched_pairs.size() >= MATCHING_PAIRS.size():
			btn_go_phase2.disabled = false
			cat_speech_lbl.text = "🎉 Xuất sắc! Bạn đã phân loại đúng toàn bộ 5 khoản chi tiêu! Nhấn 'Sang Game 2' để thử thách sinh tồn với 5 triệu đồng!"
	else:
		# Nối sai
		SoundManager.play_fail()
		cat_speech_lbl.text = "Chưa chính xác rồi Sen ơi! Khoản chi này thuộc nhóm khác cơ, thử chọn lại nhé!"

func _update_matching_styles() -> void:
	for i in range(MATCHING_PAIRS.size()):
		var p = MATCHING_PAIRS[i]
		if i < col_a_vbox.get_child_count():
			var btn = col_a_vbox.get_child(i) as Button
			if matched_pairs.has(p["id"]):
				_apply_button_matched_style(btn)
			else:
				_apply_button_normal_style(btn)
				
	for child in col_b_vbox.get_children():
		var btn = child as Button
		for p in MATCHING_PAIRS:
			if btn.text == p["col_b_text"]:
				if matched_pairs.has(p["id"]):
					_apply_button_matched_style(btn)
				else:
					_apply_button_normal_style(btn)
				break

func _switch_to_phase2() -> void:
	current_phase = 2
	phase1_container.visible = false
	phase2_container.visible = true
	
	phase_badge_lbl.text = "GAME 2 / 2"
	phase_status_lbl.text = "💰 Thử thách sinh tồn với 5 triệu đồng & Xử lý tình huống (0/3)"
	cat_speech_lbl.text = "Meo! Bạn có 5.000.000đ sinh hoạt phí cho 1 tháng. Hãy đưa ra quyết định tài chính khôn ngoan trước các tình huống phát sinh!"
	SoundManager.play_card_pop()
	
	current_scenario_idx = 0
	completed_scenarios = 0
	btn_finish_game.visible = false
	_render_current_scenario()

func _render_current_scenario() -> void:
	if current_scenario_idx >= SCENARIOS.size():
		return
		
	var scen = SCENARIOS[current_scenario_idx]
	scenario_num_lbl.text = "TÌNH HUỐNG %d / %d" % [current_scenario_idx + 1, SCENARIOS.size()]
	scenario_title_lbl.text = scen["title"]
	scenario_desc_lbl.text = scen["desc"]
	
	feedback_lbl.text = ""
	feedback_lbl.visible = false
	btn_next_scenario.visible = false
	
	for child in options_vbox.get_children():
		child.queue_free()
		
	for opt in scen["options"]:
		var btn = Button.new()
		btn.text = opt["text"]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 48)
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", Color(0.2, 0.25, 0.35))
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_apply_button_normal_style(btn)
		btn.pressed.connect(_on_option_chosen.bind(opt, btn))
		options_vbox.add_child(btn)

func _on_option_chosen(opt: Dictionary, chosen_btn: Button) -> void:
	# Disable all options
	for child in options_vbox.get_children():
		var b = child as Button
		b.disabled = true
		
	feedback_lbl.visible = true
	feedback_lbl.text = opt["feedback"]
	
	if opt["is_correct"]:
		SoundManager.play_success()
		_apply_button_matched_style(chosen_btn)
		feedback_lbl.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25))
		cat_speech_lbl.text = "Tuyệt đỉnh! " + opt["feedback"]
		completed_scenarios += 1
		phase_status_lbl.text = "💰 Xử lý tình huống thành công (%d/3)" % completed_scenarios
		
		if current_scenario_idx < SCENARIOS.size() - 1:
			btn_next_scenario.visible = true
		else:
			btn_finish_game.visible = true
			cat_speech_lbl.text = "🎉 CHÚC MỪNG! Bạn đã xuất sắc vượt qua cả 3 tình huống tài chính và sống sót trọn vẹn với 5 triệu đồng!"
	else:
		SoundManager.play_fail()
		_apply_button_wrong_style(chosen_btn)
		feedback_lbl.add_theme_color_override("font_color", Color(0.85, 0.2, 0.2))
		cat_speech_lbl.text = "Cảnh báo! Quyết định này rất rủi ro. Hãy bấm thử lại tình huống này nhé!"
		
		# Cho phép thử lại
		var retry_timer = get_tree().create_timer(1.8)
		retry_timer.timeout.connect(func():
			if is_instance_valid(self):
				for child in options_vbox.get_children():
					var b = child as Button
					b.disabled = false
					_apply_button_normal_style(b)
				feedback_lbl.visible = false
		)

func _on_next_scenario_pressed() -> void:
	current_scenario_idx += 1
	SoundManager.play_card_pop()
	_render_current_scenario()

func _on_finish_game_pressed() -> void:
	SoundManager.play_level_up()
	victory_modal.visible = true
	victory_dialogue_lbl.text = """Boss Mèo tự hào khen ngợi Sen:

'Sen đã làm rất tốt! Từ việc phân biệt rõ nhu cầu thiết yếu với những ham muốn nhất thời, cho đến việc kiên định giữ quỹ dự phòng và từ chối các cuộc ăn chơi vượt ngân sách.

Với kỹ năng này, Sen hoàn toàn có thể tự tin làm chủ cuộc sống tự lập với bất kỳ mức ngân sách nào mà không lo rơi vào bẫy nợ nần!'"""

func _on_claim_reward_pressed() -> void:
	victory_modal.visible = false
	var sim_steps = [
		{"step": 1, "desc": "Nối đúng 5 khoản chi tiêu vào các nhóm ngân sách chuẩn khoa học"},
		{"step": 2, "desc": "Trích quỹ dự phòng khẩn cấp xử lý sự cố xe máy dọc đường"},
		{"step": 3, "desc": "Linh hoạt cắt giảm chi tiêu không thiết yếu để mua tài liệu học tập"},
		{"step": 4, "desc": "Dũng cảm từ chối kèo ăn chơi vượt ngân sách để giữ kỷ luật tài chính"}
	]
	emit_signal("minigame_completed", sim_steps)

func _on_back_pressed() -> void:
	SoundManager.play_click()
	emit_signal("back_requested")

func _on_guide_pressed() -> void:
	SoundManager.play_click()
	guide_modal.visible = true

func _get_pair(id: String) -> Dictionary:
	for p in MATCHING_PAIRS:
		if p["id"] == id:
			return p
	return {}

# Style helpers
func _apply_button_normal_style(btn: Button) -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0.95)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 2
	sb.border_color = Color(0.85, 0.8, 0.75)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 10.0
	sb.content_margin_right = 10.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	btn.add_theme_stylebox_override("normal", sb)

func _apply_button_selected_style(btn: Button) -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.95, 0.82)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 3
	sb.border_color = Color(0.95, 0.6, 0.1)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 10.0
	sb.content_margin_right = 10.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	btn.add_theme_stylebox_override("normal", sb)

func _apply_button_matched_style(btn: Button) -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.20, 0.72, 0.38, 1.0)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 3
	sb.border_color = Color(0.12, 0.50, 0.22, 1.0)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 10.0
	sb.content_margin_right = 10.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("disabled", sb)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_disabled_color", Color(1, 1, 1))

func _apply_button_wrong_style(btn: Button) -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.92, 0.92)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 3
	sb.border_color = Color(0.85, 0.3, 0.3)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 10.0
	sb.content_margin_right = 10.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	btn.add_theme_stylebox_override("normal", sb)
