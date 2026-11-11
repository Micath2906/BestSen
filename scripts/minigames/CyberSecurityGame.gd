extends Control

# CyberSecurityGame.gd - Kỹ năng 3: Luật An ninh mạng & Bảo vệ dữ liệu cá nhân (Lesson 14)
# Phase 1 (Game 1): Nối hành vi vi phạm với hình thức xử lý theo quy định pháp luật
# Phase 2 (Game 2): Trắc nghiệm Đúng / Sai nhanh nhận diện rủi ro không gian mạng

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
@onready var quiz_progress_lbl: Label = $ContentScroll/VBox/Phase2Container/QuizProgressLabel
@onready var question_panel: PanelContainer = $ContentScroll/VBox/Phase2Container/QuestionPanel
@onready var question_lbl: Label = $ContentScroll/VBox/Phase2Container/QuestionPanel/VBox/QuestionLabel
@onready var explanation_lbl: Label = $ContentScroll/VBox/Phase2Container/QuestionPanel/VBox/ExplanationLabel
@onready var btn_answer_true: Button = $ContentScroll/VBox/Phase2Container/AnswerButtonsHBox/BtnTrue
@onready var btn_answer_false: Button = $ContentScroll/VBox/Phase2Container/AnswerButtonsHBox/BtnFalse
@onready var btn_next_question: Button = $ContentScroll/VBox/Phase2Container/BtnNextQuestion
@onready var btn_finish_game: Button = $ContentScroll/VBox/Phase2Container/BtnFinishGame

@onready var cat_speech_lbl: Label = $MascotSection/HBox/SpeechBubble/CatSpeechLabel

# Modals
@onready var guide_modal: Control = $GuideModal
@onready var guide_content_lbl: Label = $GuideModal/ModalPanel/VBox/Scroll/GuideContent
@onready var btn_close_guide: Button = $GuideModal/ModalPanel/VBox/BtnCloseGuide

@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue_lbl: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

# Dữ liệu Phase 1: Nối hành vi vi phạm với hình thức xử lý
const MATCHING_PAIRS = [
	{
		"id": "pair_doxxing",
		"col_a_text": "Tự ý đăng tải thông tin cá nhân của người khác lên mạng để 'bóc phốt'",
		"col_b_text": "Xử phạt vi phạm hành chính từ 10 - 20 triệu đồng (Nghị định 15/2020)",
		"law_ref": "Điểm g Khoản 3 Điều 102 Nghị định 15/2020/NĐ-CP: Chia sẻ bí mật đời tư người khác trái phép bị phạt từ 10 - 20 triệu đồng!"
	},
	{
		"id": "pair_phishing",
		"col_a_text": "Lập website giả mạo ngân hàng để lừa đảo chiếm đoạt tài sản",
		"col_b_text": "Truy cứu trách nhiệm hình sự về tội lừa đảo công nghệ cao",
		"law_ref": "Điều 290 Bộ luật Hình sự: Sử dụng mạng máy tính chiếm đoạt tài sản bị phạt tù lên đến 20 năm tù giam!"
	},
	{
		"id": "pair_fake_news",
		"col_a_text": "Chia sẻ bài viết có nội dung xuyên tạc, tin giả về dịch bệnh",
		"col_b_text": "Buộc gỡ bỏ thông tin sai sự thật và xử phạt vi phạm hành chính",
		"law_ref": "Điều 101 Nghị định 15/2020/NĐ-CP: Cung cấp, chia sẻ tin giả, sai sự thật bị phạt 10 - 20 triệu đồng và buộc khắc phục hậu quả!"
	}
]

# Dữ liệu Phase 2: Trắc nghiệm Đúng / Sai
const QUIZ_QUESTIONS = [
	{
		"question": "1. Chụp ảnh Căn cước công dân (CCCD) rõ 2 mặt rồi đăng lên Facebook khoe vừa làm xong giấy tờ mới.",
		"correct_answer": false,
		"explanation": "SAI! Tuyệt đối không khoe CCCD lên mạng! Kẻ xấu sẽ lấy số định danh, ngày cấp và mã QR để đăng ký sim rác, vay tiền app đen hoặc mở tài khoản ngân hàng ảo!"
	},
	{
		"question": "2. Bật xác thực 2 yếu tố (2FA) và tuyệt đối KHÔNG bao giờ chia sẻ mã OTP cho bất kỳ ai, kể cả người tự xưng là cán bộ công an.",
		"correct_answer": true,
		"explanation": "ĐÚNG! Mã OTP là lớp giáp bảo mật cuối cùng. Ngân hàng và cơ quan công an chính thống không bao giờ yêu cầu người dân cung cấp mã OTP!"
	},
	{
		"question": "3. Sử dụng tài khoản mạng xã hội ẩn danh (nick clone không avatar) để vu khống người khác thì cơ quan chức năng không thể điều tra ra.",
		"correct_answer": false,
		"explanation": "SAI! Lực lượng An ninh mạng có đầy đủ biện pháp kỹ thuật số truy vết địa chỉ IP, địa chỉ MAC thiết bị và nhật ký nhà mạng viễn thông để xác định danh tính và xử lý nghiêm!"
	},
	{
		"question": "4. Kiểm tra kỹ tên miền website (phải có tiền tố https:// và đúng tên miền chính thức của ngân hàng) trước khi nhập mật khẩu.",
		"correct_answer": true,
		"explanation": "ĐÚNG! Kẻ lừa đảo thường tạo tên miền mạo danh như nganhang-online.top, vietcom-bank.xyz. Hãy luôn soi kỹ từng ký tự tên miền trước khi đăng nhập!"
	}
]

var current_phase: int = 1
var selected_col_a_id: String = ""
var matched_pairs: Dictionary = {}

var current_question_idx: int = 0
var answered_current_question: bool = false
var correct_answers_count: int = 0

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
	if btn_answer_true:
		btn_answer_true.pressed.connect(func(): _on_answer_selected(true))
	if btn_answer_false:
		btn_answer_false.pressed.connect(func(): _on_answer_selected(false))
	if btn_next_question:
		btn_next_question.pressed.connect(_on_next_question_pressed)

var shuffled_pairs_a: Array = []
var shuffled_pairs_b: Array = []
var shuffled_quiz: Array = []

func load_minigame(data: Dictionary) -> void:
	title_lbl.text = "An Ninh Mạng & Dữ Liệu Cá Nhân"
	current_phase = 1
	matched_pairs.clear()
	selected_col_a_id = ""
	current_question_idx = 0
	answered_current_question = false
	correct_answers_count = 0
	
	# Xáo trộn câu hỏi và đáp án
	shuffled_pairs_a = MATCHING_PAIRS.duplicate()
	shuffled_pairs_a.shuffle()
	shuffled_pairs_b = MATCHING_PAIRS.duplicate()
	shuffled_pairs_b.shuffle()
	shuffled_quiz = QUIZ_QUESTIONS.duplicate()
	shuffled_quiz.shuffle()
	
	_render_phase1()

# =========================================================================
# PHASE 1: NỐI HÀNH VI VI PHẠM VỚI HÌNH THỨC XỬ LÝ
# =========================================================================
func _render_phase1() -> void:
	current_phase = 1
	phase1_container.visible = true
	phase2_container.visible = false
	phase_badge_lbl.text = "GAME 1 / 2"
	phase_status_lbl.text = "🔗 Nối hành vi vi phạm với hình thức xử lý"
	cat_speech_lbl.text = "Meo meo! Chạm một hành vi ở Cột A, sau đó chạm hình thức xử lý tương ứng ở Cột B nhé Sen! 🐾"
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
		btn.text = "⚠️ %s" % p["col_a_text"]
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
		btn.text = "⚖️ %s" % p["col_b_text"]
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
	cat_speech_lbl.text = "Đã chọn hành vi. Giờ hãy chọn chế tài xử lý tương ứng ở Cột B nhé!"

func _on_col_b_pressed(pair_id: String) -> void:
	if selected_col_a_id == "":
		cat_speech_lbl.text = "Sen hãy chạm chọn 1 hành vi ở Cột A trước nhé!"
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
			cat_speech_lbl.text = "🎉 XUẤT SẮC! Đã hiểu rõ khung chế tài xử phạt An ninh mạng! Bấm Tiếp Tục sang Game 2 nào! ✨"
	else:
		SoundManager.play_card_pop()
		cat_speech_lbl.text = "Chưa đúng chế tài pháp lý rồi Sen ơi! Xem lại mức xử phạt hành chính hay trách nhiệm hình sự nhé!"

func _switch_to_phase2() -> void:
	SoundManager.play_click()
	current_phase = 2
	phase1_container.visible = false
	phase2_container.visible = true
	phase_badge_lbl.text = "GAME 2 / 2"
	phase_status_lbl.text = "🛡️ Trắc nghiệm Đúng / Sai nhận diện an ninh mạng"
	cat_speech_lbl.text = "Game 2: Trả lời 4 câu Đúng / Sai để kiểm tra kỹ năng phòng chống lừa đảo số nhé! 🐾"
	current_question_idx = 0
	correct_answers_count = 0
	answered_current_question = false
	btn_finish_game.visible = false
	btn_next_question.visible = false
	if content_scroll: content_scroll.scroll_vertical = 0
	_render_current_quiz()

# =========================================================================
# PHASE 2: TRẮC NGHIỆM ĐÚNG / SAI
# =========================================================================
func _render_current_quiz() -> void:
	answered_current_question = false
	btn_answer_true.disabled = false
	btn_answer_false.disabled = false
	btn_next_question.visible = false
	
	if shuffled_quiz.is_empty():
		shuffled_quiz = QUIZ_QUESTIONS.duplicate()
		shuffled_quiz.shuffle()
		
	var q_data = shuffled_quiz[current_question_idx]
	quiz_progress_lbl.text = "CÂU HỎI %d / %d" % [current_question_idx + 1, shuffled_quiz.size()]
	question_lbl.text = q_data["question"]
	explanation_lbl.text = ""

func _on_answer_selected(user_answer: bool) -> void:
	if answered_current_question: return
	answered_current_question = true
	btn_answer_true.disabled = true
	btn_answer_false.disabled = true
	
	if shuffled_quiz.is_empty():
		shuffled_quiz = QUIZ_QUESTIONS.duplicate()
		shuffled_quiz.shuffle()
	var q_data = shuffled_quiz[current_question_idx]
	var is_correct = (user_answer == q_data["correct_answer"])
	
	# Đổi màu xanh cho đáp án đúng
	var green_sb = StyleBoxFlat.new()
	green_sb.bg_color = Color(0.20, 0.72, 0.38, 1.0)
	green_sb.border_color = Color(0.12, 0.50, 0.22, 1.0)
	green_sb.set_corner_radius_all(10)
	
	if q_data["correct_answer"] == true:
		btn_answer_true.add_theme_stylebox_override("disabled", green_sb)
		btn_answer_true.add_theme_color_override("font_disabled_color", Color(1, 1, 1))
	else:
		btn_answer_false.add_theme_stylebox_override("disabled", green_sb)
		btn_answer_false.add_theme_color_override("font_disabled_color", Color(1, 1, 1))
	
	if is_correct:
		SoundManager.play_success()
		correct_answers_count += 1
		explanation_lbl.text = "✔ CHÍNH XÁC!\n%s" % q_data["explanation"]
		explanation_lbl.add_theme_color_override("font_color", Color(0.15, 0.55, 0.25, 1.0))
		cat_speech_lbl.text = "Xuất sắc! Bạn đã nhận diện chuẩn xác tình huống an toàn số này!"
	else:
		SoundManager.play_fail()
		explanation_lbl.text = "✖ CHƯA ĐÚNG!\n%s" % q_data["explanation"]
		explanation_lbl.add_theme_color_override("font_color", Color(0.85, 0.25, 0.2, 1.0))
		cat_speech_lbl.text = "Cảnh báo nguy hiểm! Đọc kỹ bài học để không bị dính bẫy lừa đảo nhé Sen!"
		
	if current_question_idx < shuffled_quiz.size() - 1:
		btn_next_question.visible = true
	else:
		btn_finish_game.visible = true

func _on_next_question_pressed() -> void:
	SoundManager.play_click()
	current_question_idx += 1
	_render_current_quiz()

func _on_finish_game_pressed() -> void:
	SoundManager.play_success()
	var speech = "🎉 CHÚC MỪNG CHIẾN BINH AN TOÀN SỐ!\n\n"
	speech += "Mèo con đã hoàn thành xuất sắc cả 2 Game An ninh mạng:\n\n"
	speech += "✔ Game 1: Nắm chắc khung hình phạt và chế tài:\n"
	speech += "  • Lập web giả mạo ngân hàng: Truy cứu trách nhiệm hình sự.\n"
	speech += "  • Bóc phốt đời tư, lan truyền tin giả: Phạt 10 - 20 triệu đồng.\n\n"
	speech += "✔ Game 2: Thuộc lòng 4 quy tắc vàng bảo vệ bản thân:\n"
	speech += "  • Tuyệt đối không đăng ảnh CCCD lên mạng xã hội.\n"
	speech += "  • Không chia sẻ mã OTP với bất kỳ ai.\n"
	speech += "  • Nhận thức rõ nick ẩn danh vẫn bị an ninh mạng truy vết.\n"
	speech += "  • Soi kỹ tên miền website trước khi đăng nhập tài khoản.\n\n"
	speech += "🎖️ Nhận danh hiệu 'Lá Chắn An Ninh Mạng' & Thưởng +35 Cá Khô!"
	victory_dialogue_lbl.text = speech
	victory_modal.visible = true

func _on_claim_reward_pressed() -> void:
	SoundManager.play_click()
	victory_modal.visible = false
	GameManager.complete_lesson(14)
	var sim_steps = [
		{"icon": "🛡️", "text": "Bảo vệ thông tin CCCD & dữ liệu số"},
		{"icon": "🔑", "text": "Bật xác thực 2FA & giữ bí mật OTP"},
		{"icon": "🌐", "text": "Soi kỹ tên miền web ngân hàng chính thức"},
		{"icon": "⚖️", "text": "Tuân thủ nghiêm Luật An ninh mạng"}
	]
	emit_signal("minigame_completed", sim_steps)

func _on_guide_pressed() -> void:
	SoundManager.play_click()
	var guide_str = "📌 CẨM NANG AN NINH MẠNG & DỮ LIỆU CÁ NHÂN:\n\n"
	guide_str += "1. BẢO VỆ DỮ LIỆU CÁ NHÂN (Nghị định 13/2023):\n"
	guide_str += "  • Không chụp đăng CCCD, thẻ sinh viên, vé máy bay lên mạng xã hội.\n"
	guide_str += "  • Không tự ý đăng ảnh, số điện thoại người khác để bóc phốt.\n\n"
	guide_str += "2. NGUYÊN TẮC BẢO MẬT TÀI KHOẢN NGÂN HÀNG:\n"
	guide_str += "  • Mã OTP chỉ để bạn tự nhập, không cung cấp cho bất kỳ ai qua điện thoại.\n"
	guide_str += "  • Không click vào link lạ nhận tiền trúng thưởng hay cập nhật sinh trắc học giả.\n\n"
	guide_str += "3. TRÁCH NHIỆM PHÁP LÝ PHÁT NGÔN:\n"
	guide_str += "  • Dù dùng nick clone thì cơ quan an ninh vẫn truy vết được địa chỉ IP.\n"
	guide_str += "  • Lan truyền tin giả, vu khống bị phạt 10 - 20 triệu đồng hoặc phạt tù."
	guide_content_lbl.text = guide_str
	guide_modal.visible = true
