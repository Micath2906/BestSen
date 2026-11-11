extends Control

# MotorbikeMaintenanceGame.gd - Kỹ năng 5: Bảo dưỡng và xử lý sự cố xe máy cơ bản
# Phase 1 (Game 1): Nối đáp án "Kiểm tra phương tiện cá nhân" (5 dấu hiệu hư hỏng với 5 biện pháp xử lý)
# Phase 2 (Game 2): "Tìm lỗi sai / Thợ sửa xe tập sự" (Chẩn đoán 4 tình huống xe máy gặp vấn đề)

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
@onready var mechanic_card: PanelContainer = $ContentScroll/VBox/Phase2Container/MechanicCard
@onready var case_num_lbl: Label = $ContentScroll/VBox/Phase2Container/MechanicCard/VBox/CaseNumLabel
@onready var case_title_lbl: Label = $ContentScroll/VBox/Phase2Container/MechanicCard/VBox/CaseTitleLabel
@onready var case_desc_lbl: Label = $ContentScroll/VBox/Phase2Container/MechanicCard/VBox/CaseDescLabel
@onready var case_options_vbox: VBoxContainer = $ContentScroll/VBox/Phase2Container/MechanicCard/VBox/CaseOptionsVBox
@onready var case_feedback_lbl: Label = $ContentScroll/VBox/Phase2Container/MechanicCard/VBox/CaseFeedbackLabel
@onready var btn_next_case: Button = $ContentScroll/VBox/Phase2Container/MechanicCard/VBox/BtnNextCase
@onready var btn_finish_game: Button = $ContentScroll/VBox/Phase2Container/BtnFinishGame

@onready var cat_speech_lbl: Label = $MascotSection/HBox/SpeechBubble/CatSpeechLabel

# Modals
@onready var guide_modal: Control = $GuideModal
@onready var guide_content_lbl: Label = $GuideModal/ModalPanel/VBox/Scroll/GuideContent
@onready var btn_close_guide: Button = $GuideModal/ModalPanel/VBox/BtnCloseGuide

@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue_lbl: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

# Dữ liệu Phase 1: 5 Cặp Nối Dấu hiệu -> Xử lý
const MATCHING_PAIRS = [
	{
		"id": "mb_tire",
		"col_a_text": "Lốp xe non hơi, bánh lái chao đảo khi ôm cua",
		"col_b_text": "Bơm lốp đúng áp suất quy định (khoảng 2.0 - 2.2 kg/cm²)",
		"hint": "Bơm lốp đúng áp suất giúp xe chạy êm, tiết kiệm xăng và tránh mòn méo vành!"
	},
	{
		"id": "mb_brake",
		"col_a_text": "Phanh kêu bất thường, phát tiếng két két chói tai",
		"col_b_text": "Kiểm tra và thay mới má phanh (bố thắng) ngay",
		"hint": "Tiếng két két là do má phanh mòn hết trơ phần kim loại cọ vào đĩa phanh, rất nguy hiểm!"
	},
	{
		"id": "mb_light",
		"col_a_text": "Đèn xe không sáng khi đã bật công tắc pha/cốt",
		"col_b_text": "Kiểm tra bóng đèn sợi đốt/LED hoặc cầu chì, dây điện",
		"hint": "Đèn xe hỏng khi đi đêm rất dễ bị CSGT xử phạt và tiềm ẩn nguy cơ tai nạn nghiêm trọng!"
	},
	{
		"id": "mb_engine",
		"col_a_text": "Động cơ có tiếng gõ lạ lạch cạch khi tăng ga",
		"col_b_text": "Đưa xe đi kiểm tra động cơ, supap hoặc xích cam",
		"hint": "Tiếng gõ kim loại trong lốc máy là dấu hiệu supap hoặc xích cam chùng, cần kiểm tra sớm!"
	},
	{
		"id": "mb_oil",
		"col_a_text": "Dầu nhớt đến hạn thay (Đã chạy hơn 2.000 km)",
		"col_b_text": "Thay dầu nhớt động cơ định kỳ để bảo vệ lốc máy",
		"hint": "Thay nhớt máy định kỳ 1.500-2.000km giúp làm mát và bôi trơn piston bền bỉ!"
	}
]

# Dữ liệu Phase 2: 4 Tình huống Thợ sửa xe tập sự
const MECHANIC_CASES = [
	{
		"id": "case_tire_crack",
		"title": "Chẩn đoán tình trạng Lốp xe mòn nứt chân chim",
		"desc": "Quan sát lốp xe máy thấy rãnh gai đã mòn phẳng đến vạch chỉ thị TWI và xuất hiện vết nứt chân chim ở thành lốp. Tình trạng này có an toàn để lưu thông không?",
		"options": [
			{
				"text": "A. Rất nguy hiểm! Dễ nổ lốp khi đi tốc độ cao và trơn trượt ngã xe khi trời mưa, cần thay lốp mới ngay lập tức!",
				"is_correct": true,
				"feedback": "Chính xác! Lốp mòn mất hoàn toàn độ bám đường và vết nứt chân chim cảnh báo cao su đã lão hóa, nguy cơ nổ lốp bất cứ lúc nào!"
			},
			{
				"text": "B. Vẫn an toàn chạy thoải mái thêm 1-2 năm nữa cho đỡ tốn tiền",
				"is_correct": false,
				"feedback": "Cực kỳ liều lĩnh! Tiết kiệm vài trăm ngàn tiền lốp có thể phải trả giá bằng tính mạng khi nổ lốp trên đường quốc lộ!"
			},
			{
				"text": "C. Chỉ cần xả bớt hơi ra cho mềm lốp để tăng độ bám đường",
				"is_correct": false,
				"feedback": "Sai kỹ thuật! Lốp non hơi trên lốp nứt càng làm cao su gãy gập nhanh hơn và dễ cắn xăm hỏng vành!"
			}
		]
	},
	{
		"id": "case_fi_warning",
		"title": "Đèn báo lỗi động cơ (Fi) màu vàng sáng liên tục",
		"desc": "Sau khi bật khóa điện và nổ máy, đèn vàng biểu tượng động cơ (Fi) trên mặt đồng hồ không chịu tắt mà sáng liên tục hoặc nhấp nháy. Bạn cần làm gì?",
		"options": [
			{
				"text": "A. Đưa xe đến trung tâm bảo dưỡng uy tín để cắm máy chẩn đoán đọc mã lỗi cảm biến và hệ thống phun xăng",
				"is_correct": true,
				"feedback": "Rất chuẩn xác! Đèn Fi báo hiệu cảm biến oxy, cảm biến nhiệt độ hoặc kim phun đang gặp lỗi, cần máy đọc lỗi chuyên dụng để sửa chữa chuẩn xác!"
			},
			{
				"text": "B. Không sao cả, đó chỉ là đèn trang trí cho xe thêm bắt mắt",
				"is_correct": false,
				"feedback": "Sai lầm tai hại! Bỏ qua đèn Fi có thể khiến xe chết máy đột ngột giữa xa lộ hoặc ăn xăng gấp đôi bình thường!"
			},
			{
				"text": "C. Lấy băng dính đen dán đè lên đèn hoặc tháo bóng đèn ra cho đỡ ngứa mắt",
				"is_correct": false,
				"feedback": "Trốn tránh cảnh báo! Làm vậy không giải quyết được lỗi hỏng hóc thực sự bên trong động cơ!"
			}
		]
	},
	{
		"id": "case_oil_cycle",
		"title": "Chu kỳ thay dầu nhớt xe máy đúng tiêu chuẩn",
		"desc": "Theo khuyến cáo của kỹ sư cơ khí, chu kỳ thay dầu nhớt động cơ và dầu hộp số (dầu láp) cho xe máy như thế nào là đúng nhất?",
		"options": [
			{
				"text": "A. Thay nhớt máy sau mỗi 1.500 - 2.000 km; với xe tay ga cần thay thêm dầu láp (nhớt hộp số) sau 2-3 lần thay nhớt máy",
				"is_correct": true,
				"feedback": "Tuyệt hảo! Đây là công thức vàng giúp động cơ luôn êm ái, bốc máy và chống mài mòn bánh răng hộp số xe ga!"
			},
			{
				"text": "B. Cứ chạy thoải mái tới khi xe kêu gào hoặc cạn sạch nhớt mới cần đổ thêm",
				"is_correct": false,
				"feedback": "Phá xe! Cạn nhớt sẽ làm bó máy, lột dên và cháy piston xilanh, chi phí sửa chữa lên tới hàng triệu đồng!"
			},
			{
				"text": "C. Xe máy hiện đại đi 10.000 km mới cần thay nhớt một lần",
				"is_correct": false,
				"feedback": "Nhầm lẫn nguy hiểm! Dầu nhớt xe máy điều kiện vận hành tại Việt Nam sinh nhiệt rất lớn và biến chất thoái hóa sau 2.000 km!"
			}
		]
	},
	{
		"id": "case_brake_failure",
		"title": "Xử lý khẩn cấp khi phanh tay mất tác dụng khi đang chạy",
		"desc": "Khi đang lưu thông trên đường, bạn bóp phanh tay kịch cỡ chạm sát ghi-đông mà xe vẫn trôi băng băng không giảm tốc. Phản xạ an toàn nhất là gì?",
		"options": [
			{
				"text": "A. Nhả hết ga, dùng phanh chân/phanh còn lại nhấp nhả từ từ, về số thấp (với xe số) để phanh bằng động cơ và tấp vào lề an toàn",
				"is_correct": true,
				"feedback": "Rất bản lĩnh! Dùng phanh động cơ kết hợp phanh phụ còn lại giúp giảm tốc độ mượt mà mà không bị khóa bánh trượt ngã!"
			},
			{
				"text": "B. Nhảy ngay khỏi xe xuống đường để thoát hiểm",
				"is_correct": false,
				"feedback": "Cực kỳ nguy hiểm! Nhảy khỏi xe đang chạy sẽ gây va đập chấn thương sọ não và tai nạn liên hoàn cho người đi sau!"
			},
			{
				"text": "C. Vặn ga thật mạnh lao nhanh về phía trước xem xe có tự dừng lại không",
				"is_correct": false,
				"feedback": "Hành động liều lĩnh tự sát! Mất phanh mà tăng ga là chắc chắn đâm vào chướng ngại vật!"
			}
		]
	}
]

var current_phase: int = 1
var selected_col_a_id: String = ""
var matched_pairs: Dictionary = {}

var current_case_idx: int = 0
var completed_case_count: int = 0

func _ready() -> void:
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(_on_back_pressed)
	btn_guide.pressed.connect(_on_guide_pressed)
	btn_close_guide.pressed.connect(func(): guide_modal.visible = false)
	btn_go_phase2.pressed.connect(_switch_to_phase2)
	btn_next_case.pressed.connect(_on_next_case_pressed)
	btn_finish_game.pressed.connect(_on_finish_game_pressed)
	btn_claim_reward.pressed.connect(_on_claim_reward_pressed)
	
	_setup_guide_content()
	_init_phase1()

func load_minigame(_data: Dictionary = {}) -> void:
	_init_phase1()

func _setup_guide_content() -> void:
	var guide_text = """CẨM NANG: BẢO DƯỠNG & SỰ CỐ XE MÁY CHO SINH VIÊN

1. Quy tắc kiểm tra trước khi khởi hành (B-L-O-P):
- B (Brakes - Phanh): Bóp thử phanh trước & phanh sau xem có ăn không, có phát ra tiếng kim loại két két không.
- L (Lights - Đèn còi): Kiểm tra đèn pha cốt, đèn xi-nhan và còi xe.
- O (Oil - Dầu nhớt): Nhớ số km đã đi, thay dầu máy sau mỗi 1.500-2.000km (thay nhớt láp sau 3 lần thay nhớt máy đối với xe ga).
- P (Pressure - Áp suất lốp): Kiểm tra độ căng lốp (2.0 - 2.2 kg/cm²), nhìn rãnh lốp và phát hiện vết nứt chân chim.

2. Cảnh báo an toàn:
- Đèn Fi sáng liên tục: Cần đưa xe đến tiệm kiểm tra hệ thống phun xăng ngay.
- Phanh mất tác dụng: Nhả ga, về số thấp phanh bằng động cơ kết hợp phanh phụ còn lại."""
	guide_content_lbl.text = guide_text

func _init_phase1() -> void:
	current_phase = 1
	selected_col_a_id = ""
	matched_pairs = {}
	
	phase1_container.visible = true
	phase2_container.visible = false
	btn_go_phase2.disabled = true
	
	phase_badge_lbl.text = "GAME 1 / 2"
	phase_status_lbl.text = "🔧 Nối dấu hiệu hư hỏng với biện pháp xử lý (0/5)"
	cat_speech_lbl.text = "Meo! Xe máy là phương tiện đi học hàng ngày. Hãy giúp Mèo nối đúng dấu hiệu hư hỏng với cách bảo dưỡng nhé!"
	
	_render_matching_columns()

func _render_matching_columns() -> void:
	for child in col_a_vbox.get_children():
		child.queue_free()
	for child in col_b_vbox.get_children():
		child.queue_free()
		
	# Cột A
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
	cat_speech_lbl.text = "Bạn vừa chọn dấu hiệu '%s'. Hãy chọn biện pháp xử lý chuẩn ở Cột B!" % _get_pair(id).get("col_a_text", "")

func _on_col_b_pressed(id: String) -> void:
	if matched_pairs.has(id):
		return
	if selected_col_a_id == "":
		cat_speech_lbl.text = "Meo! Bạn hãy chọn một dấu hiệu ở Cột A trước nhé!"
		SoundManager.play_fail()
		return
		
	if selected_col_a_id == id:
		matched_pairs[id] = true
		SoundManager.play_success()
		cat_speech_lbl.text = "Chính xác! " + _get_pair(id).get("hint", "")
		_update_matching_styles()
		selected_col_a_id = ""
		
		phase_status_lbl.text = "🔧 Nối dấu hiệu hư hỏng với biện pháp xử lý (%d/5)" % matched_pairs.size()
		
		if matched_pairs.size() >= MATCHING_PAIRS.size():
			btn_go_phase2.disabled = false
			cat_speech_lbl.text = "🎉 Tuyệt hảo! Bạn đã nắm vững 5 khâu kiểm tra phương tiện cơ bản! Nhấn 'Sang Game 2' để làm thợ sửa xe tập sự nhé!"
	else:
		SoundManager.play_fail()
		cat_speech_lbl.text = "Biện pháp này chưa tương ứng với dấu hiệu hư hỏng trên rồi Sen ơi! Thử lại nhé!"

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
	phase_status_lbl.text = "🔍 Thợ sửa xe tập sự: Chẩn đoán sự cố (0/4)"
	cat_speech_lbl.text = "Meo! Trở thành thợ sửa xe tập sự, hãy chẩn đoán và đưa ra giải pháp an toàn cho 4 tình huống xe máy thực tế!"
	SoundManager.play_card_pop()
	
	current_case_idx = 0
	completed_case_count = 0
	btn_finish_game.visible = false
	_render_current_case()

func _render_current_case() -> void:
	if current_case_idx >= MECHANIC_CASES.size():
		return
		
	var c = MECHANIC_CASES[current_case_idx]
	case_num_lbl.text = "TÌNH HUỐNG %d / %d" % [current_case_idx + 1, MECHANIC_CASES.size()]
	case_title_lbl.text = c["title"]
	case_desc_lbl.text = c["desc"]
	
	case_feedback_lbl.text = ""
	case_feedback_lbl.visible = false
	btn_next_case.visible = false
	
	for child in case_options_vbox.get_children():
		child.queue_free()
		
	for opt in c["options"]:
		var btn = Button.new()
		btn.text = opt["text"]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 52)
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", Color(0.2, 0.25, 0.35))
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_apply_button_normal_style(btn)
		btn.pressed.connect(_on_case_option_chosen.bind(opt, btn))
		case_options_vbox.add_child(btn)

func _on_case_option_chosen(opt: Dictionary, chosen_btn: Button) -> void:
	for child in case_options_vbox.get_children():
		var b = child as Button
		b.disabled = true
		
	case_feedback_lbl.visible = true
	case_feedback_lbl.text = opt["feedback"]
	
	if opt["is_correct"]:
		SoundManager.play_success()
		_apply_button_matched_style(chosen_btn)
		case_feedback_lbl.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25))
		cat_speech_lbl.text = "Chẩn đoán chính xác! " + opt["feedback"]
		completed_case_count += 1
		phase_status_lbl.text = "🔍 Thợ sửa xe tập sự (%d/4)" % completed_case_count
		
		if current_case_idx < MECHANIC_CASES.size() - 1:
			btn_next_case.visible = true
		else:
			btn_finish_game.visible = true
			cat_speech_lbl.text = "🎉 XUẤT SẮC TOÀN DIỆN! Bạn đã hoàn thành 4 bài chẩn đoán xe máy xuất sắc như một người thợ chuyên nghiệp!"
	else:
		SoundManager.play_fail()
		_apply_button_wrong_style(chosen_btn)
		case_feedback_lbl.add_theme_color_override("font_color", Color(0.85, 0.2, 0.2))
		cat_speech_lbl.text = "Cách xử lý này rất nguy hiểm cho bản thân và xe! Hãy thử suy nghĩ lại nhé!"
		
		var retry_timer = get_tree().create_timer(1.8)
		retry_timer.timeout.connect(func():
			if is_instance_valid(self):
				for child in case_options_vbox.get_children():
					var b = child as Button
					b.disabled = false
					_apply_button_normal_style(b)
				case_feedback_lbl.visible = false
		)

func _on_next_case_pressed() -> void:
	current_case_idx += 1
	SoundManager.play_card_pop()
	_render_current_case()

func _on_finish_game_pressed() -> void:
	SoundManager.play_level_up()
	victory_modal.visible = true
	victory_dialogue_lbl.text = """Boss Mèo phong tặng danh hiệu 'Tay Lái Vàng An Toàn':

'Meo! Chiếc xe máy là đôi chân của người sinh viên trên mọi nẻo đường đến trường. Nhờ bài học này, Sen đã:

- Biết tự kiểm tra áp suất lốp, má phanh, dầu nhớt và hệ thống điện đèn.
- Nhận diện nguy cơ nổ lốp từ vết nứt chân chim và mòn rãnh chỉ thị.
- Hiểu ý nghĩa đèn cảnh báo Fi và chu kỳ thay dầu nhớt bảo vệ động cơ.
- Nắm vững phản xạ hãm phanh động cơ cứu mạng khi phanh tay gặp sự cố.

Chúc Sen luôn vững tay lái trên mọi hành trình tự lập!'"""

func _on_claim_reward_pressed() -> void:
	victory_modal.visible = false
	var sim_steps = [
		{"step": 1, "desc": "Nối đúng 5 dấu hiệu hư hỏng xe máy với biện pháp kiểm tra bảo dưỡng chuẩn"},
		{"step": 2, "desc": "Nhận diện độ mòn và vết nứt chân chim trên lốp xe để thay thế kịp thời"},
		{"step": 3, "desc": "Xử lý đèn báo lỗi Fi và tuân thủ chu kỳ thay dầu nhớt 1.500-2.000km"},
		{"step": 4, "desc": "Bình tĩnh nhả ga, về số dùng phanh động cơ khi phanh xe mất tác dụng"}
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
