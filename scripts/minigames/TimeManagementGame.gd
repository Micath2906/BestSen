extends Control

# TimeManagementGame.gd - Kỹ năng 2: Quản lý thời gian và công việc
# Phase 1 (Game 1): Sắp xếp thứ tự "Một ngày của sinh viên tự lập" (7 hoạt động vào thời gian biểu khoa học)
# Phase 2 (Game 2): Xử lý tình huống "Deadline đang đến!" theo Ma trận Eisenhower

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
@onready var timeline_vbox: VBoxContainer = $ContentScroll/VBox/Phase1Container/TimelineVBox
@onready var cards_pool: HFlowContainer = $ContentScroll/VBox/Phase1Container/CardsPool
@onready var btn_go_phase2: Button = $ContentScroll/VBox/Phase1Container/BtnGoPhase2

@onready var phase2_container: VBoxContainer = $ContentScroll/VBox/Phase2Container
@onready var eisenhower_card: PanelContainer = $ContentScroll/VBox/Phase2Container/EisenhowerCard
@onready var deadline_desc_lbl: Label = $ContentScroll/VBox/Phase2Container/EisenhowerCard/VBox/DeadlineDescLabel
@onready var q_num_lbl: Label = $ContentScroll/VBox/Phase2Container/EisenhowerCard/VBox/QNumLabel
@onready var q_title_lbl: Label = $ContentScroll/VBox/Phase2Container/EisenhowerCard/VBox/QTitleLabel
@onready var q_desc_lbl: Label = $ContentScroll/VBox/Phase2Container/EisenhowerCard/VBox/QDescLabel
@onready var q_options_vbox: VBoxContainer = $ContentScroll/VBox/Phase2Container/EisenhowerCard/VBox/QOptionsVBox
@onready var q_feedback_lbl: Label = $ContentScroll/VBox/Phase2Container/EisenhowerCard/VBox/QFeedbackLabel
@onready var btn_next_q: Button = $ContentScroll/VBox/Phase2Container/EisenhowerCard/VBox/BtnNextQ
@onready var btn_finish_game: Button = $ContentScroll/VBox/Phase2Container/BtnFinishGame

@onready var cat_speech_lbl: Label = $MascotSection/HBox/SpeechBubble/CatSpeechLabel

# Modals
@onready var guide_modal: Control = $GuideModal
@onready var guide_content_lbl: Label = $GuideModal/ModalPanel/VBox/Scroll/GuideContent
@onready var btn_close_guide: Button = $GuideModal/ModalPanel/VBox/BtnCloseGuide

@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue_lbl: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

# Dữ liệu Phase 1: 7 Mốc thời gian sinh viên
const SCHEDULE_ACTIVITIES = [
	{
		"step": 1,
		"time": "06:30",
		"icon": "🌅",
		"title": "Thức dậy & Vệ sinh cá nhân",
		"desc": "Thức dậy đúng giờ, gấp chăn màn và uống 1 ly nước ấm để đánh thức cơ thể"
	},
	{
		"step": 2,
		"time": "07:00",
		"icon": "🥪",
		"title": "Ăn sáng nạp năng lượng",
		"desc": "Ăn sáng đủ chất dinh dưỡng, tuyệt đối không bỏ bữa sáng gây hại dạ dày"
	},
	{
		"step": 3,
		"time": "07:30 - 11:30",
		"icon": "📚",
		"title": "Học tập tại giảng đường",
		"desc": "Nghe giảng tập trung, ghi chép nội dung trọng tâm và trao đổi cùng bạn bè"
	},
	{
		"step": 4,
		"time": "12:00 - 13:30",
		"icon": "🍱",
		"title": "Ăn trưa & Nghỉ trưa ngắn",
		"desc": "Ăn trưa thanh đạm và chợp mắt 20-30 phút để tái tạo năng lượng cho buổi chiều"
	},
	{
		"step": 5,
		"time": "14:00 - 17:30",
		"icon": "💼",
		"title": "Đi làm thêm part-time",
		"desc": "Trải nghiệm công việc thực tế, trau dồi kỹ năng mềm và tạo thêm thu nhập"
	},
	{
		"step": 6,
		"time": "18:00 - 19:30",
		"icon": "🏃",
		"title": "Tập thể dục & Ăn tối",
		"desc": "Chạy bộ hoặc tập thể thao 30 phút, tắm rửa và ăn bữa tối nhẹ nhàng"
	},
	{
		"step": 7,
		"time": "20:00 - 23:00",
		"icon": "🌙",
		"title": "Làm bài tập & Nghỉ ngơi",
		"desc": "Ôn bài, hoàn thành deadline và đi ngủ trước 23h30 để duy trì nhịp sinh học"
	}
]

# Dữ liệu Phase 2: Ma trận Eisenhower & Xử lý Deadline
const DEADLINE_QUESTIONS = [
	{
		"id": "q_eisenhower_priority",
		"title": "Phân loại theo Ma trận Eisenhower",
		"desc": "Bài tập lớn chiếm 40% điểm học phần phải nộp lúc 8h sáng mai thuộc góc phần tư nào trong Ma trận Eisenhower?",
		"options": [
			{
				"text": "A. Nhóm 1: Quan trọng & Khẩn cấp (LÀM NGAY LẬP TỨC!)",
				"is_correct": true,
				"feedback": "Chính xác! Bài tập lớn ảnh hưởng trực tiếp đến kết quả học tập và hạn nộp sát nút là việc khẩn cấp bắt buộc phải ưu tiên số 1!"
			},
			{
				"text": "B. Nhóm 2: Quan trọng nhưng không khẩn cấp (Lên kế hoạch làm sau)",
				"is_correct": false,
				"feedback": "Sai rồi! Sáng mai nộp bài rồi mà để lên kế hoạch làm sau thì sẽ bị 0 điểm!"
			},
			{
				"text": "C. Nhóm 4: Không quan trọng & Không khẩn cấp (Xóa bỏ hoặc ủy quyền)",
				"is_correct": false,
				"feedback": "Quá sai lầm! Điểm số đại học là của bạn, không thể xóa bỏ hay giao cho ai khác!"
			}
		]
	},
	{
		"id": "q_handle_part_time",
		"title": "Xử lý ca làm thêm part-time tối nay (18h - 22h)",
		"desc": "Tối nay bạn có ca làm thêm đã xếp lịch từ trước. Đứng trước deadline khẩn cấp sáng mai, bạn nên giải quyết thế nào vừa văn minh vừa giữ uy tín?",
		"options": [
			{
				"text": "A. Nhắn tin cho quản lý sớm, chân thành giải thích lý do và chủ động nhờ đồng nghiệp đổi ca trực hộ",
				"is_correct": true,
				"feedback": "Rất chuyên nghiệp! Báo trước có lý do chính đáng và tìm người thay thế giúp quán không bị thiếu người và bạn giữ trọn chữ tín!"
			},
			{
				"text": "B. Tắt nguồn điện thoại trốn làm không báo trước để ở phòng làm bài",
				"is_correct": false,
				"feedback": "Vô trách nhiệm! Trốn làm không báo trước sẽ bị trừ lương, mất việc và hỏng uy tín cá nhân!"
			},
			{
				"text": "C. Vừa đi làm vừa lén giấu tài liệu dưới quầy để làm bài thi",
				"is_correct": false,
				"feedback": "Tắc trách! Phục vụ khách hàng sai sót và bài tập làm vội vàng cũng không đạt chất lượng!"
			}
		]
	},
	{
		"id": "q_handle_party_invite",
		"title": "Ứng xử trước lời rủ tiệc sinh nhật bạn thân lúc 19h",
		"desc": "Bạn thân từ thời cấp ba rủ đi ăn mừng sinh nhật lúc 19h tối nay. Quyết định đúng đắn của bạn là gì?",
		"options": [
			{
				"text": "A. Nhắn tin chúc mừng bạn nhiệt thành, gửi món quà nhỏ hoặc thiệp điện tử, hẹn dịp cuối tuần gặp bù",
				"is_correct": true,
				"feedback": "Tuyệt vời! Bạn thân thật sự sẽ luôn thấu hiểu và ủng hộ việc học của bạn. Lời từ chối chân thành giúp giữ trọn tình bạn mà không hỏng việc lớn!"
			},
			{
				"text": "B. Nhận lời đi quẩy sinh nhật tới 2h sáng rồi về thức trắng đêm nộp bài vội",
				"is_correct": false,
				"feedback": "Nguy hiểm! Thức trắng đêm trong trạng thái mệt mỏi sẽ nộp bài cẩu thả và sáng hôm sau kiệt sức!"
			},
			{
				"text": "C. Xem tin nhắn rồi im lặng không trả lời coi như không biết",
				"is_correct": false,
				"feedback": "Bất lịch sự! Im lặng làm bạn bè thất vọng và rạn nứt mối quan hệ bạn bè!"
			}
		]
	}
]

var current_phase: int = 1
var selected_activity_card: Dictionary = {}
var solved_activities: Dictionary = {} # step (1..7) -> data

var current_q_idx: int = 0
var completed_q_count: int = 0

func _ready() -> void:
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(_on_back_pressed)
	btn_guide.pressed.connect(_on_guide_pressed)
	btn_close_guide.pressed.connect(func(): guide_modal.visible = false)
	btn_go_phase2.pressed.connect(_switch_to_phase2)
	btn_next_q.pressed.connect(_on_next_q_pressed)
	btn_finish_game.pressed.connect(_on_finish_game_pressed)
	btn_claim_reward.pressed.connect(_on_claim_reward_pressed)
	
	_setup_guide_content()
	_init_phase1()

func load_minigame(_data: Dictionary = {}) -> void:
	_init_phase1()

func _setup_guide_content() -> void:
	var guide_text = """CẨM NANG: QUẢN LÝ THỜI GIAN & MA TRẬN EISENHOWER

1. Ma trận Eisenhower (4 Góc phần tư):
- Góc 1: QUAN TRỌNG & KHẨN CẤP (Bài tập nộp ngày mai, sự cố sức khỏe) -> Làm ngay lập tức!
- Góc 2: QUAN TRỌNG NHƯNG KHÔNG KHẨN CẤP (Học ngoại ngữ, tập thể dục, đọc sách) -> Lên kế hoạch chi tiết!
- Góc 3: KHÔNG QUAN TRỌNG NHƯNG KHẨN CẤP (Cuộc gọi bất ngờ, tin nhắn vu vơ) -> Tìm cách ủy quyền / giải quyết nhanh!
- Góc 4: KHÔNG QUAN TRỌNG & KHÔNG KHẨN CẤP (Lướt mạng xã hội vô bổ, chơi game thâu đêm) -> Cắt giảm hoặc xóa bỏ!

2. Kỹ thuật Quả Cà Chua (Pomodoro):
- 25 phút tập trung cao độ, 5 phút nghỉ ngơi thư giãn mắt.
- Sau 4 chu kỳ thì nghỉ dài 15-20 phút.

3. Kỷ luật sinh hoạt:
- Giữ khung giờ ngủ và thức dậy cố định giúp não bộ luôn minh mẫn và tràn đầy năng lượng!"""
	guide_content_lbl.text = guide_text

func _init_phase1() -> void:
	current_phase = 1
	selected_activity_card = {}
	solved_activities = {}
	
	phase1_container.visible = true
	phase2_container.visible = false
	btn_go_phase2.disabled = true
	
	phase_badge_lbl.text = "GAME 1 / 2"
	phase_status_lbl.text = "📅 Sắp xếp 7 hoạt động sinh hoạt khoa học (0/7)"
	cat_speech_lbl.text = "Meo! Hãy bấm chọn thẻ hoạt động bên dưới rồi xếp vào đúng khung giờ sinh hoạt một ngày của sinh viên nhé!"
	
	_render_timeline_slots()
	_render_activity_cards()

func _render_timeline_slots() -> void:
	for child in timeline_vbox.get_children():
		child.queue_free()
		
	for act in SCHEDULE_ACTIVITIES:
		var slot_panel = PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(0, 48)
		slot_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_apply_slot_empty_style(slot_panel)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)
		slot_panel.add_child(hbox)
		
		var time_lbl = Label.new()
		time_lbl.text = act["time"]
		time_lbl.custom_minimum_size = Vector2(90, 0)
		time_lbl.add_theme_font_size_override("font_size", 11)
		time_lbl.add_theme_color_override("font_color", Color(0.85, 0.45, 0.1))
		hbox.add_child(time_lbl)
		
		var content_lbl = Label.new()
		content_lbl.name = "ContentLabel"
		content_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content_lbl.add_theme_font_size_override("font_size", 11)
		content_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		if solved_activities.has(act["step"]):
			var data = solved_activities[act["step"]]
			content_lbl.text = "%s %s" % [data["icon"], data["title"]]
			content_lbl.add_theme_color_override("font_color", Color(0.15, 0.55, 0.25))
			_apply_slot_filled_style(slot_panel)
		else:
			content_lbl.text = "Trống (Bấm để gán hoạt động)"
			content_lbl.add_theme_color_override("font_color", Color(0.65, 0.6, 0.55))
			
		hbox.add_child(content_lbl)
		
		# Slot click handler
		var step_num = act["step"]
		slot_panel.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
				_on_slot_pressed(step_num)
		)
		
		timeline_vbox.add_child(slot_panel)

func _render_activity_cards() -> void:
	for child in cards_pool.get_children():
		child.queue_free()
		
	# Lọc các thẻ chưa giải
	var remaining_cards = []
	for act in SCHEDULE_ACTIVITIES:
		if not solved_activities.has(act["step"]):
			remaining_cards.append(act)
			
	remaining_cards.shuffle()
	
	for card in remaining_cards:
		var btn = Button.new()
		btn.text = "%s %s" % [card["icon"], card["title"]]
		btn.custom_minimum_size = Vector2(160, 36)
		btn.add_theme_font_size_override("font_size", 10)
		btn.add_theme_color_override("font_color", Color(0.25, 0.2, 0.15))
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		if selected_activity_card.get("step", -1) == card["step"]:
			_apply_card_selected_style(btn)
		else:
			_apply_card_normal_style(btn)
			
		btn.pressed.connect(_on_card_selected.bind(card))
		cards_pool.add_child(btn)

func _on_card_selected(card: Dictionary) -> void:
	selected_activity_card = card.duplicate()
	SoundManager.play_click()
	cat_speech_lbl.text = "Bạn vừa chọn '%s %s'. Hãy bấm vào khung giờ phù hợp ở bảng thời gian biểu bên trên!" % [card["icon"], card["title"]]
	_render_activity_cards()

func _on_slot_pressed(slot_step: int) -> void:
	if solved_activities.has(slot_step):
		cat_speech_lbl.text = "Khung giờ này đã được sắp xếp chính xác rồi!"
		return
		
	if selected_activity_card.is_empty():
		cat_speech_lbl.text = "Meo! Bạn hãy bấm chọn một thẻ hoạt động ở khay bên dưới trước nhé!"
		SoundManager.play_fail()
		return
		
	if selected_activity_card.get("step", -1) == slot_step:
		# Sắp xếp đúng mốc thời gian
		solved_activities[slot_step] = selected_activity_card.duplicate()
		selected_activity_card = {}
		SoundManager.play_success()
		
		var act = _get_activity(slot_step)
		cat_speech_lbl.text = "Chính xác! " + act.get("desc", "")
		
		_render_timeline_slots()
		_render_activity_cards()
		
		phase_status_lbl.text = "📅 Sắp xếp 7 hoạt động sinh hoạt khoa học (%d/7)" % solved_activities.size()
		
		if solved_activities.size() >= SCHEDULE_ACTIVITIES.size():
			btn_go_phase2.disabled = false
			cat_speech_lbl.text = "🎉 Tuyệt hảo! Thời gian biểu 1 ngày của sinh viên đã hoàn thành khoa học! Nhấn 'Sang Game 2' để xử lý tình huống khẩn cấp!"
	else:
		# Sai mốc thời gian
		SoundManager.play_fail()
		cat_speech_lbl.text = "Khung giờ này chưa tối ưu cho hoạt động '%s'. Thử suy nghĩ về nhịp sinh học hợp lý hơn nhé!" % selected_activity_card.get("title", "")

func _switch_to_phase2() -> void:
	current_phase = 2
	phase1_container.visible = false
	phase2_container.visible = true
	
	phase_badge_lbl.text = "GAME 2 / 2"
	phase_status_lbl.text = "⚡ Deadline đang đến! Ma trận Eisenhower (0/3)"
	cat_speech_lbl.text = "Báo động! Bài tập lớn 40% điểm nộp sáng mai, ca làm thêm tối nay và sinh nhật bạn thân cùng ập đến. Hãy áp dụng Ma trận Eisenhower để quyết định!"
	SoundManager.play_card_pop()
	
	current_q_idx = 0
	completed_q_count = 0
	btn_finish_game.visible = false
	_render_current_deadline_q()

func _render_current_deadline_q() -> void:
	if current_q_idx >= DEADLINE_QUESTIONS.size():
		return
		
	var q = DEADLINE_QUESTIONS[current_q_idx]
	q_num_lbl.text = "TÌNH HUỐNG %d / %d" % [current_q_idx + 1, DEADLINE_QUESTIONS.size()]
	q_title_lbl.text = q["title"]
	q_desc_lbl.text = q["desc"]
	
	q_feedback_lbl.text = ""
	q_feedback_lbl.visible = false
	btn_next_q.visible = false
	
	for child in q_options_vbox.get_children():
		child.queue_free()
		
	for opt in q["options"]:
		var btn = Button.new()
		btn.text = opt["text"]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 48)
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", Color(0.2, 0.25, 0.35))
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_apply_card_normal_style(btn)
		btn.pressed.connect(_on_deadline_option_chosen.bind(opt, btn))
		q_options_vbox.add_child(btn)

func _on_deadline_option_chosen(opt: Dictionary, chosen_btn: Button) -> void:
	for child in q_options_vbox.get_children():
		var b = child as Button
		b.disabled = true
		
	q_feedback_lbl.visible = true
	q_feedback_lbl.text = opt["feedback"]
	
	if opt["is_correct"]:
		SoundManager.play_success()
		_apply_button_matched_style(chosen_btn)
		q_feedback_lbl.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25))
		cat_speech_lbl.text = "Rất sáng suốt! " + opt["feedback"]
		completed_q_count += 1
		phase_status_lbl.text = "⚡ Xử lý quyết định thành công (%d/3)" % completed_q_count
		
		if current_q_idx < DEADLINE_QUESTIONS.size() - 1:
			btn_next_q.visible = true
		else:
			btn_finish_game.visible = true
			cat_speech_lbl.text = "🎉 XUẤT SẮC! Bạn đã làm chủ Ma trận Eisenhower, giải quyết bài toán ưu tiên hoàn hảo!"
	else:
		SoundManager.play_fail()
		_apply_button_wrong_style(chosen_btn)
		q_feedback_lbl.add_theme_color_override("font_color", Color(0.85, 0.2, 0.2))
		cat_speech_lbl.text = "Cách xử lý này gây hậu quả xấu! Hãy thử lại câu hỏi này nhé!"
		
		var retry_timer = get_tree().create_timer(1.8)
		retry_timer.timeout.connect(func():
			if is_instance_valid(self):
				for child in q_options_vbox.get_children():
					var b = child as Button
					b.disabled = false
					_apply_card_normal_style(b)
				q_feedback_lbl.visible = false
		)

func _on_next_q_pressed() -> void:
	current_q_idx += 1
	SoundManager.play_card_pop()
	_render_current_deadline_q()

func _on_finish_game_pressed() -> void:
	SoundManager.play_level_up()
	victory_modal.visible = true
	victory_dialogue_lbl.text = """Boss Mèo trao huy hiệu 'Chiến Thần Quản Lý Thời Gian':

'Meo! Sen quả thực là cao thủ cân bằng cuộc sống! Sen không chỉ biết cách phân bổ 24 giờ một ngày thành thời gian biểu khoa học, mà khi biến cố bất ngờ xảy đến, Sen đã xuất sắc dùng Ma trận Eisenhower:

1. Ưu tiên số 1 cho việc sống còn (Bài tập lớn 40% điểm).
2. Xử lý trách nhiệm có tâm (Nhờ bạn đổi ca làm thêm đàng hoàng).
3. Ứng xử tinh tế với bạn bè (Từ chối lịch sự, giữ trọn tình bạn).

Tương lai tự lập của Sen sẽ vô cùng thảnh thơi và thành công rực rỡ!'"""

func _on_claim_reward_pressed() -> void:
	victory_modal.visible = false
	var sim_steps = [
		{"step": 1, "desc": "Sắp xếp 7 hoạt động sinh hoạt một ngày thành thời gian biểu khoa học"},
		{"step": 2, "desc": "Áp dụng Ma trận Eisenhower xác định việc Quan trọng & Khẩn cấp nộp sáng mai"},
		{"step": 3, "desc": "Chủ động xin đổi ca làm thêm part-time có trách nhiệm và giữ chữ tín"},
		{"step": 4, "desc": "Khéo léo từ chối lời mời sinh nhật để tập trung dứt điểm deadline lớn"}
	]
	emit_signal("minigame_completed", sim_steps)

func _on_back_pressed() -> void:
	SoundManager.play_click()
	emit_signal("back_requested")

func _on_guide_pressed() -> void:
	SoundManager.play_click()
	guide_modal.visible = true

func _get_activity(step: int) -> Dictionary:
	for act in SCHEDULE_ACTIVITIES:
		if act["step"] == step:
			return act
	return {}

# Style helpers
func _apply_slot_empty_style(panel: PanelContainer) -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0.9)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 2
	sb.border_color = Color(0.85, 0.8, 0.75)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	panel.add_theme_stylebox_override("panel", sb)

func _apply_slot_filled_style(panel: PanelContainer) -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.92, 0.98, 0.94)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 3
	sb.border_color = Color(0.25, 0.72, 0.42)
	sb.set_corner_radius_all(10)
	sb.content_margin_left = 12.0
	sb.content_margin_right = 12.0
	sb.content_margin_top = 6.0
	sb.content_margin_bottom = 6.0
	panel.add_theme_stylebox_override("panel", sb)

func _apply_card_normal_style(btn: Button) -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(1, 1, 1, 0.95)
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 2
	sb.border_color = Color(0.85, 0.8, 0.75)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 10.0
	sb.content_margin_right = 10.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 4.0
	btn.add_theme_stylebox_override("normal", sb)

func _apply_card_selected_style(btn: Button) -> void:
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.94, 0.8)
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 3
	sb.border_color = Color(0.95, 0.55, 0.1)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 10.0
	sb.content_margin_right = 10.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 4.0
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
