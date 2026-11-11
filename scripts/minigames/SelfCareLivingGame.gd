extends Control

# SelfCareLivingGame.gd - Kỹ năng 4: Tự chăm sóc bản thân và quản lý sinh hoạt
# Phase 1 (Game 1): Sắp xếp trình tự "Đảm đang không khó" (4 bước giặt giũ quần áo an toàn)
# Phase 2 (Game 2): Trắc nghiệm tình huống "Hôm nay ăn gì?" (Thực đơn cân bằng, Bảo quản tủ lạnh, Nhận diện thực phẩm hỏng)

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
@onready var steps_vbox: VBoxContainer = $ContentScroll/VBox/Phase1Container/StepsVBox
@onready var cards_pool: HFlowContainer = $ContentScroll/VBox/Phase1Container/CardsPool
@onready var btn_go_phase2: Button = $ContentScroll/VBox/Phase1Container/BtnGoPhase2

@onready var phase2_container: VBoxContainer = $ContentScroll/VBox/Phase2Container
@onready var food_quiz_card: PanelContainer = $ContentScroll/VBox/Phase2Container/FoodQuizCard
@onready var q_num_lbl: Label = $ContentScroll/VBox/Phase2Container/FoodQuizCard/VBox/QNumLabel
@onready var q_title_lbl: Label = $ContentScroll/VBox/Phase2Container/FoodQuizCard/VBox/QTitleLabel
@onready var q_desc_lbl: Label = $ContentScroll/VBox/Phase2Container/FoodQuizCard/VBox/QDescLabel
@onready var q_options_vbox: VBoxContainer = $ContentScroll/VBox/Phase2Container/FoodQuizCard/VBox/QOptionsVBox
@onready var q_feedback_lbl: Label = $ContentScroll/VBox/Phase2Container/FoodQuizCard/VBox/QFeedbackLabel
@onready var btn_next_q: Button = $ContentScroll/VBox/Phase2Container/FoodQuizCard/VBox/BtnNextQ
@onready var btn_finish_game: Button = $ContentScroll/VBox/Phase2Container/BtnFinishGame

@onready var cat_speech_lbl: Label = $MascotSection/HBox/SpeechBubble/CatSpeechLabel

# Modals
@onready var guide_modal: Control = $GuideModal
@onready var guide_content_lbl: Label = $GuideModal/ModalPanel/VBox/Scroll/GuideContent
@onready var btn_close_guide: Button = $GuideModal/ModalPanel/VBox/BtnCloseGuide

@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue_lbl: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

# Dữ liệu Phase 1: 4 Bước giặt giũ khoa học
const LAUNDRY_STEPS = [
	{
		"step": 1,
		"icon": "🧺",
		"title": "Phân loại đồ màu và đồ trắng riêng biệt",
		"desc": "Tránh hiện tượng phai màu từ áo quần màu đậm sang đồ trắng làm loang lổ, hỏng quần áo",
		"hint": "Phân loại quần áo trước khi giặt là nguyên tắc số 1 để giữ trang phục luôn sạch đẹp!"
	},
	{
		"step": 2,
		"icon": "🔍",
		"title": "Kiểm tra kỹ túi quần áo và xem mác giặt",
		"desc": "Lấy sạch chìa khóa, tiền lẻ, giấy ăn ra ngoài; xem nhiệt độ giặt trên nhãn để tránh co rút vải",
		"hint": "Quên giấy ăn trong túi quần sẽ làm vụn giấy bám trắng xóa khắp lồng giặt đấy Sen!"
	},
	{
		"step": 3,
		"icon": "🧴",
		"title": "Cho lượng nước giặt vừa đủ & chọn chế độ giặt",
		"desc": "Không đổ quá nhiều xà phòng gây bám cặn cặn bẩn; chọn chế độ giặt thường hoặc giặt nhẹ",
		"hint": "Dùng lượng xà phòng vừa phải giúp bảo vệ sợi vải và tránh dị ứng da ngứa ngáy!"
	},
	{
		"step": 4,
		"icon": "☀️",
		"title": "Lộn trái trang phục và phơi nơi thoáng gió có nắng",
		"desc": "Lộn trái giúp giữ màu vải không bị bạc dưới nắng gắt, tia UV giúp diệt sạch vi khuẩn và nấm mốc",
		"hint": "Phơi nơi khô ráo thoáng gió giúp quần áo thơm tho, không bị mùi ẩm mốc khó chịu!"
	}
]

# Dữ liệu Phase 2: 3 Thử thách Dinh dưỡng & An toàn thực phẩm
const FOOD_QUIZ_QUESTIONS = [
	{
		"id": "q_meal_nutrition",
		"title": "Thực đơn dinh dưỡng sinh viên ngân sách 35k",
		"desc": "Với ngân sách tự nấu 35.000đ cho một bữa ăn tại phòng trọ, thực đơn nào dưới đây cân bằng dinh dưỡng và tốt cho sức khỏe nhất?",
		"options": [
			{
				"text": "A. Cơm trắng + Đậu hũ sốt cà chua + Canh rau ngót nấu thịt băm + 1 quả trứng rán",
				"is_correct": true,
				"feedback": "Tuyệt hảo! Thực đơn cung cấp đầy đủ 4 nhóm dưỡng chất thiết yếu: tinh bột, đạm thực vật & động vật, vitamin và chất xơ từ rau xanh với chi phí vô cùng tiết kiệm!"
			},
			{
				"text": "B. 2 gói mì tôm ăn liền + xúc xích ăn liền + 1 lon nước ngọt có ga",
				"is_correct": false,
				"feedback": "Rất có hại! Bữa ăn này chứa quá nhiều natri, chất béo bão hòa và đường tinh luyện, thiếu hoàn toàn vitamin và chất xơ, gây nóng trong và đau dạ dày!"
			},
			{
				"text": "C. Chỉ ăn thịt kho tàu thật nhiều với cơm trắng, không cần ăn rau xanh hay canh",
				"is_correct": false,
				"feedback": "Mất cân bằng! Ăn quá nhiều đạm động vật mà thiếu chất xơ sẽ làm hệ tiêu hóa quá tải và táo bón khó chịu!"
			}
		]
	},
	{
		"id": "q_fridge_storage",
		"title": "Bảo quản thức ăn chín trong tủ lạnh phòng trọ",
		"desc": "Thức ăn nấu chín còn dư sau bữa tối nên được bảo quản an toàn trong tủ lạnh như thế nào để tránh ngộ độc thực phẩm?",
		"options": [
			{
				"text": "A. Chờ thức ăn nguội bớt, cho vào hộp kín nắp và cất vào ngăn mát (< 5°C), ăn lại trong vòng 24-48 giờ",
				"is_correct": true,
				"feedback": "Chính xác! Đậy kín hộp thức ăn giúp ngăn vi khuẩn chéo lây nhiễm, nhiệt độ dưới 5°C làm chậm sự phát triển của vi sinh vật và nên hâm nóng kỹ trước khi ăn!"
			},
			{
				"text": "B. Cứ để nguyên nồi trên bếp qua đêm, sáng mai đun sôi lại ăn tiếp",
				"is_correct": false,
				"feedback": "Cực kỳ nguy hiểm! Nhiệt độ phòng từ 20-37°C là môi trường lý tưởng cho vi khuẩn sinh sôi và tiết độc tố gây ngộ độc cấp tính!"
			},
			{
				"text": "C. Đặt cả nồi canh đang sôi sùng sục vào tủ lạnh ngay lập tức",
				"is_correct": false,
				"feedback": "Sai kỹ thuật! Cho đồ nóng vào tủ lạnh sẽ làm tăng nhiệt độ bên trong tủ, làm hỏng các thực phẩm xung quanh và quá tải lốc máy lạnh!"
			}
		]
	},
	{
		"id": "q_moldy_bread",
		"title": "Nhận diện thực phẩm mốc hỏng",
		"desc": "Một lát bánh mì sandwich trong túi bánh xuất hiện một đốm nấm mốc xanh nhỏ li ti ở góc rìa. Bạn nên xử lý thế nào?",
		"options": [
			{
				"text": "A. Vứt bỏ toàn bộ ổ bánh mì ngay lập tức",
				"is_correct": true,
				"feedback": "Rất chuẩn xác! Cấu trúc bánh mì mềm xốp, khi mắt thường nhìn thấy đốm mốc thì sợi nấm mốc và độc tố vi nấm (Mycotoxin) đã lan rộng khắp cả ổ bánh, tuyệt đối không được ăn!"
			},
			{
				"text": "B. Lấy dao cắt bỏ phần góc mốc xanh đi rồi ăn phần ruột bánh còn lại",
				"is_correct": false,
				"feedback": "Sai lầm nguy hiểm! Độc tố vi nấm Mycotoxin vô hình đã ngấm sâu vào toàn bộ chiếc bánh, cắt bỏ góc mốc vẫn gây hại gan thận!"
			},
			{
				"text": "C. Bỏ vào chảo nướng thật giòn để nhiệt độ diệt hết nấm mốc rồi ăn",
				"is_correct": false,
				"feedback": "Sai lầm! Nhiệt độ nướng thông thường không thể phá hủy được độc tố Mycotoxin do nấm mốc tiết ra!"
			}
		]
	}
]

var current_phase: int = 1
var selected_step_card: Dictionary = {}
var solved_laundry_steps: Dictionary = {} # step (1..4) -> data

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
	var guide_text = """CẨM NANG: TỰ CHĂM SÓC BẢN THÂN & SINH HOẠT TỰ LẬP

1. Quy tắc giặt giũ quần áo:
- Luôn phân loại đồ màu và đồ trắng trước khi giặt.
- Kiểm tra túi áo quần: Không để quên tiền, giấy ăn, chìa khóa.
- Phơi lộn trái trang phục nơi thoáng gió có ánh nắng để khử khuẩn và bảo vệ màu vải.

2. Dinh dưỡng tự nấu phòng trọ:
- Suất ăn cân bằng cần đủ 4 nhóm chất: Tinh bột (Cơm/Bún) - Chất đạm (Thịt, cá, trứng, đậu hũ) - Chất béo lành mạnh - Vitamin & Khoáng chất (Rau xanh, củ quả).
- Hạn chế tối đa ăn mì tôm triền miên nhiều ngày.

3. An toàn thực phẩm:
- Bảo quản đồ ăn chín trong hộp kín ở ngăn mát tủ lạnh dưới 5°C.
- Tuyệt đối không ăn thực phẩm đã chớm mốc (bánh mì, hoa quả thối) vì độc tố vi nấm Mycotoxin không bị phân hủy bởi nhiệt độ!"""
	guide_content_lbl.text = guide_text

func _init_phase1() -> void:
	current_phase = 1
	selected_step_card = {}
	solved_laundry_steps = {}
	
	phase1_container.visible = true
	phase2_container.visible = false
	btn_go_phase2.disabled = true
	
	phase_badge_lbl.text = "GAME 1 / 2"
	phase_status_lbl.text = "🧺 Sắp xếp 4 bước giặt giũ khoa học (0/4)"
	cat_speech_lbl.text = "Meo! Hãy chọn thẻ bước giặt giũ ở khay dưới rồi xếp vào đúng thứ tự 1 đến 4 nhé!"
	
	_render_laundry_slots()
	_render_laundry_cards()

func _render_laundry_slots() -> void:
	for child in steps_vbox.get_children():
		child.queue_free()
		
	for st in LAUNDRY_STEPS:
		var slot_panel = PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(0, 52)
		slot_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_apply_slot_empty_style(slot_panel)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		slot_panel.add_child(hbox)
		
		var num_lbl = Label.new()
		num_lbl.text = "BƯỚC %d" % st["step"]
		num_lbl.custom_minimum_size = Vector2(70, 0)
		num_lbl.add_theme_font_size_override("font_size", 11)
		num_lbl.add_theme_color_override("font_color", Color(0.85, 0.45, 0.1))
		hbox.add_child(num_lbl)
		
		var content_lbl = Label.new()
		content_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		content_lbl.add_theme_font_size_override("font_size", 11)
		content_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		if solved_laundry_steps.has(st["step"]):
			var data = solved_laundry_steps[st["step"]]
			content_lbl.text = "%s %s" % [data["icon"], data["title"]]
			content_lbl.add_theme_color_override("font_color", Color(0.15, 0.55, 0.25))
			_apply_slot_filled_style(slot_panel)
		else:
			content_lbl.text = "Trống (Bấm để xếp bước này)"
			content_lbl.add_theme_color_override("font_color", Color(0.65, 0.6, 0.55))
			
		hbox.add_child(content_lbl)
		
		var step_num = st["step"]
		slot_panel.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
				_on_slot_pressed(step_num)
		)
		
		steps_vbox.add_child(slot_panel)

func _render_laundry_cards() -> void:
	for child in cards_pool.get_children():
		child.queue_free()
		
	var remaining_cards = []
	for st in LAUNDRY_STEPS:
		if not solved_laundry_steps.has(st["step"]):
			remaining_cards.append(st)
			
	remaining_cards.shuffle()
	
	for card in remaining_cards:
		var btn = Button.new()
		btn.text = "%s %s" % [card["icon"], card["title"]]
		btn.custom_minimum_size = Vector2(230, 42)
		btn.add_theme_font_size_override("font_size", 10)
		btn.add_theme_color_override("font_color", Color(0.25, 0.2, 0.15))
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		if selected_step_card.get("step", -1) == card["step"]:
			_apply_card_selected_style(btn)
		else:
			_apply_card_normal_style(btn)
			
		btn.pressed.connect(_on_step_card_selected.bind(card))
		cards_pool.add_child(btn)

func _on_step_card_selected(card: Dictionary) -> void:
	selected_step_card = card.duplicate()
	SoundManager.play_click()
	cat_speech_lbl.text = "Bạn vừa chọn '%s %s'. Hãy bấm vào ô Bước 1, 2, 3 hoặc 4 tương ứng bên trên!" % [card["icon"], card["title"]]
	_render_laundry_cards()

func _on_slot_pressed(slot_step: int) -> void:
	if solved_laundry_steps.has(slot_step):
		cat_speech_lbl.text = "Bước này đã được giải chính xác rồi!"
		return
		
	if selected_step_card.is_empty():
		cat_speech_lbl.text = "Meo! Bạn hãy bấm chọn một thẻ bước giặt ở khay bên dưới trước nhé!"
		SoundManager.play_fail()
		return
		
	if selected_step_card.get("step", -1) == slot_step:
		solved_laundry_steps[slot_step] = selected_step_card.duplicate()
		selected_step_card = {}
		SoundManager.play_success()
		
		var st = _get_laundry_step(slot_step)
		cat_speech_lbl.text = "Chính xác! " + st.get("hint", "")
		
		_render_laundry_slots()
		_render_laundry_cards()
		
		phase_status_lbl.text = "🧺 Sắp xếp 4 bước giặt giũ khoa học (%d/4)" % solved_laundry_steps.size()
		
		if solved_laundry_steps.size() >= LAUNDRY_STEPS.size():
			btn_go_phase2.disabled = false
			cat_speech_lbl.text = "🎉 Tuyệt hảo! Quy trình giặt giũ đã hoàn thành chuẩn xác! Nhấn 'Sang Game 2' để thử tài dinh dưỡng 'Hôm nay ăn gì?'!"
	else:
		SoundManager.play_fail()
		cat_speech_lbl.text = "Thứ tự này chưa chuẩn rồi Sen ơi! Xem lại quy trình giặt giũ an toàn nhé!"

func _switch_to_phase2() -> void:
	current_phase = 2
	phase1_container.visible = false
	phase2_container.visible = true
	
	phase_badge_lbl.text = "GAME 2 / 2"
	phase_status_lbl.text = "🍳 Trắc nghiệm 'Hôm nay ăn gì?' & An toàn thực phẩm (0/3)"
	cat_speech_lbl.text = "Meo! Ăn uống lành mạnh và bảo quản thực phẩm đúng cách là bí quyết khỏe mạnh của sinh viên. Cùng trả lời 3 câu hỏi nhé!"
	SoundManager.play_card_pop()
	
	current_q_idx = 0
	completed_q_count = 0
	btn_finish_game.visible = false
	_render_current_food_q()

func _render_current_food_q() -> void:
	if current_q_idx >= FOOD_QUIZ_QUESTIONS.size():
		return
		
	var q = FOOD_QUIZ_QUESTIONS[current_q_idx]
	q_num_lbl.text = "CÂU HỎI %d / %d" % [current_q_idx + 1, FOOD_QUIZ_QUESTIONS.size()]
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
		btn.custom_minimum_size = Vector2(0, 52)
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", Color(0.2, 0.25, 0.35))
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_apply_card_normal_style(btn)
		btn.pressed.connect(_on_food_option_chosen.bind(opt, btn))
		q_options_vbox.add_child(btn)

func _on_food_option_chosen(opt: Dictionary, chosen_btn: Button) -> void:
	for child in q_options_vbox.get_children():
		var b = child as Button
		b.disabled = true
		
	q_feedback_lbl.visible = true
	q_feedback_lbl.text = opt["feedback"]
	
	if opt["is_correct"]:
		SoundManager.play_success()
		_apply_button_matched_style(chosen_btn)
		q_feedback_lbl.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25))
		cat_speech_lbl.text = "Rất am hiểu dinh dưỡng! " + opt["feedback"]
		completed_q_count += 1
		phase_status_lbl.text = "🍳 Trắc nghiệm 'Hôm nay ăn gì?' (%d/3)" % completed_q_count
		
		if current_q_idx < FOOD_QUIZ_QUESTIONS.size() - 1:
			btn_next_q.visible = true
		else:
			btn_finish_game.visible = true
			cat_speech_lbl.text = "🎉 CHÚC MỪNG! Bạn đã xuất sắc nắm vững kiến thức dinh dưỡng & an toàn thực phẩm!"
	else:
		SoundManager.play_fail()
		_apply_button_wrong_style(chosen_btn)
		q_feedback_lbl.add_theme_color_override("font_color", Color(0.85, 0.2, 0.2))
		cat_speech_lbl.text = "Lựa chọn này rất có hại cho sức khỏe! Hãy suy nghĩ và thử lại nhé!"
		
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
	_render_current_food_q()

func _on_finish_game_pressed() -> void:
	SoundManager.play_level_up()
	victory_modal.visible = true
	victory_dialogue_lbl.text = """Boss Mèo phong tặng danh hiệu 'Chuyên Gia Tự Chăm Sóc Bản Thân':

'Meo! Sống tự lập xa nhà, sức khỏe là tài sản quý giá nhất của Sen. Hôm nay Sen đã thể hiện kỹ năng sinh hoạt tuyệt vời:

- Giặt giũ chu đáo, biết phân loại đồ và phơi nắng diệt khuẩn.
- Lên thực đơn bữa cơm sinh viên 35k đủ 4 nhóm chất dinh dưỡng.
- Bảo quản tủ lạnh an toàn và kiên quyết vứt bỏ đồ mốc hỏng để bảo vệ dạ dày và gan thận.

Boss Mèo hoàn toàn yên tâm khi trao chiếc chìa khóa tự lập vào tay Sen!'"""

func _on_claim_reward_pressed() -> void:
	victory_modal.visible = false
	var sim_steps = [
		{"step": 1, "desc": "Sắp xếp 4 bước quy trình giặt giũ bảo vệ quần áo và diệt khuẩn"},
		{"step": 2, "desc": "Lựa chọn thực đơn 35k cân bằng 4 nhóm dinh dưỡng cho sinh viên"},
		{"step": 3, "desc": "Bảo quản thức ăn chín trong tủ lạnh trọ dưới 5°C đúng tiêu chuẩn"},
		{"step": 4, "desc": "Nhận diện và loại bỏ thực phẩm mốc hỏng tránh độc tố Mycotoxin"}
	]
	emit_signal("minigame_completed", sim_steps)

func _on_back_pressed() -> void:
	SoundManager.play_click()
	emit_signal("back_requested")

func _on_guide_pressed() -> void:
	SoundManager.play_click()
	guide_modal.visible = true

func _get_laundry_step(step: int) -> Dictionary:
	for st in LAUNDRY_STEPS:
		if st["step"] == step:
			return st
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
