extends Control

# CommunicationConflictGame.gd - Kỹ năng 3: Giao tiếp và giải quyết mâu thuẫn
# Phase 1 (Game 1): "Nếu là bạn, bạn sẽ nói gì?" (3 Tình huống mâu thuẫn xóm trọ, bài tập nhóm, bạn bè)
# Phase 2 (Game 2): "Giao tiếp xanh hay đỏ?" (Phân loại câu nói vào 2 nhóm: 🟢 Xanh tích cực vs 🔴 Đỏ độc hại)

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
@onready var situation_card: PanelContainer = $ContentScroll/VBox/Phase1Container/SituationCard
@onready var sit_num_lbl: Label = $ContentScroll/VBox/Phase1Container/SituationCard/VBox/SitNumLabel
@onready var sit_title_lbl: Label = $ContentScroll/VBox/Phase1Container/SituationCard/VBox/SitTitleLabel
@onready var sit_desc_lbl: Label = $ContentScroll/VBox/Phase1Container/SituationCard/VBox/SitDescLabel
@onready var sit_options_vbox: VBoxContainer = $ContentScroll/VBox/Phase1Container/SituationCard/VBox/SitOptionsVBox
@onready var sit_feedback_lbl: Label = $ContentScroll/VBox/Phase1Container/SituationCard/VBox/SitFeedbackLabel
@onready var btn_next_situation: Button = $ContentScroll/VBox/Phase1Container/SituationCard/VBox/BtnNextSituation
@onready var btn_go_phase2: Button = $ContentScroll/VBox/Phase1Container/BtnGoPhase2

@onready var phase2_container: VBoxContainer = $ContentScroll/VBox/Phase2Container
@onready var baskets_hbox: HBoxContainer = $ContentScroll/VBox/Phase2Container/BasketsHBox
@onready var basket_green_vbox: VBoxContainer = $ContentScroll/VBox/Phase2Container/BasketsHBox/BasketGreen/InnerVBox/VBox
@onready var basket_red_vbox: VBoxContainer = $ContentScroll/VBox/Phase2Container/BasketsHBox/BasketRed/InnerVBox/VBox
@onready var btn_basket_green: Button = $ContentScroll/VBox/Phase2Container/BasketsHBox/BasketGreen/InnerVBox/BtnAddGreen
@onready var btn_basket_red: Button = $ContentScroll/VBox/Phase2Container/BasketsHBox/BasketRed/InnerVBox/BtnAddRed
@onready var cards_pool: HFlowContainer = $ContentScroll/VBox/Phase2Container/CardsPool
@onready var btn_finish_game: Button = $ContentScroll/VBox/Phase2Container/BtnFinishGame

@onready var cat_speech_lbl: Label = $MascotSection/HBox/SpeechBubble/CatSpeechLabel

# Modals
@onready var guide_modal: Control = $GuideModal
@onready var guide_content_lbl: Label = $GuideModal/ModalPanel/VBox/Scroll/GuideContent
@onready var btn_close_guide: Button = $GuideModal/ModalPanel/VBox/BtnCloseGuide

@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue_lbl: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

# Dữ liệu Phase 1: 3 Tình huống giao tiếp
const SITUATIONS = [
	{
		"id": "sit_roommate_borrow",
		"title": "Bạn cùng phòng mượn đồ không xin phép",
		"desc": "Bạn cùng phòng thường xuyên lấy mỹ phẩm, áo khoác, đồ ăn của bạn dùng mà không hề hỏi trước, đôi khi làm bẩn hoặc để quên ở ngoài.",
		"options": [
			{
				"text": "A. Gặp riêng bạn, nhẹ nhàng góp ý: 'Đồ dùng cá nhân tụi mình nên phân biệt rõ. Khi nào cần mượn gì, cậu cứ nhắn hỏi tớ một tiếng trước nhé!'",
				"is_correct": true,
				"feedback": "Chính xác! Thiết lập ranh giới rõ ràng trong không gian sống chung bằng thái độ bình tĩnh, lịch sự giúp giải quyết triệt để vấn đề mà không làm sứt mẻ tình cảm!"
			},
			{
				"text": "B. Đăng status bóng gió mỉa mai lên Facebook và chụp ảnh đồ đạc bóc phốt ẩn danh",
				"is_correct": false,
				"feedback": "Sai lầm! Mỉa mai trên mạng xã hội chỉ làm leo thang căng thẳng và tạo bầu không khí ngột ngạt khó sống cùng nhau!"
			},
			{
				"text": "C. Giấu hết đồ đạc vào vali khóa lại rồi chiến tranh lạnh, không thèm nói chuyện cả tháng",
				"is_correct": false,
				"feedback": "Tiêu cực! Chiến tranh lạnh không giúp đối phương hiểu được cảm xúc của bạn mà chỉ làm tăng áp lực tâm lý cho cả hai!"
			}
		]
	},
	{
		"id": "sit_team_deadline",
		"title": "Thành viên nhóm trễ hạn nộp bài tập lớn",
		"desc": "Bài tập nhóm cần ghép để nộp thầy trước 17h, nhưng một thành viên trễ deadline 2 ngày mà không báo lý do, có nguy cơ khiến cả nhóm bị trừ điểm.",
		"options": [
			{
				"text": "A. Nhắn tin hỏi thăm: 'Tiến độ nhóm đang bị chậm do thiếu phần của cậu. Cậu có gặp khó khăn gì không? Tụi mình cần chốt bài trước 17h hôm nay để nộp, cậu cố gắng hoàn thành nhé!'",
				"is_correct": true,
				"feedback": "Rất chuẩn mực! Hỏi thăm khó khăn trước để thấu hiểu, sau đó chốt hạn dứt khoát là kỹ năng làm việc nhóm vô cùng chuyên nghiệp!"
			},
			{
				"text": "B. Nhắn chửi bới trong nhóm chat chung và yêu cầu giảng viên gạch tên bạn ngay lập tức",
				"is_correct": false,
				"feedback": "Kém văn minh! Nổi nóng và công kích cá nhân làm vỡ vụn tinh thần đồng đội và thiếu kỹ năng giải quyết mâu thuẫn!"
			},
			{
				"text": "C. Im lặng tự làm thay phần việc của bạn rồi ấm ức một mình",
				"is_correct": false,
				"feedback": "Không nên! Bao che dung túng sự vô trách nhiệm vừa khiến bạn kiệt sức, vừa tước đi cơ hội học hỏi của thành viên đó!"
			}
		]
	},
	{
		"id": "sit_toxic_jokes",
		"title": "Bạn bè mang ngoại hình/quê quán ra trêu chọc quá trớn",
		"desc": "Trong bữa ăn đông người, một vài bạn liên tục lấy giọng nói địa phương hoặc ngoại hình của bạn ra làm trò đùa cợt cười cợt.",
		"options": [
			{
				"text": "A. Giữ nét mặt nghiêm túc, nói bình tĩnh: 'Trò đùa này làm mình cảm thấy không thoải mái và thiếu được tôn trọng. Mình mong các bạn dừng lại ở đây!'",
				"is_correct": true,
				"feedback": "Tuyệt vời! Dũng cảm lên tiếng bảo vệ danh dự và thiết lập ranh giới cảm xúc là biểu hiện của người có lòng tự trọng cao và bản lĩnh vững vàng!"
			},
			{
				"text": "B. Nổi trận lôi đình, chửi bới ầm ĩ và đập vỡ cốc chén trên bàn ăn",
				"is_correct": false,
				"feedback": "Mất kiểm soát! Bạo lực ngôn từ hoặc hành động làm hỏng hình ảnh của chính bạn trước tập thể!"
			},
			{
				"text": "C. Cười gượng hùa theo trò đùa dù trong lòng cảm thấy tổn thương sâu sắc",
				"is_correct": false,
				"feedback": "Tổn thương! Nhẫn nhịn vô lý chỉ khiến đối phương nghĩ bạn thích trò đùa đó và sẽ tiếp tục lấn tới!"
			}
		]
	}
]

# Dữ liệu Phase 2: Phân loại 6 câu nói (🟢 Xanh vs 🔴 Đỏ)
const SPEECH_CARDS = [
	{
		"id": "speech_1",
		"text": "Tớ hiểu góc nhìn của cậu, nhưng chúng mình cùng tìm giải pháp tối ưu nhé!",
		"is_green": true,
		"explain": "Giao tiếp xanh: Lắng nghe, đồng cảm và hướng đến giải pháp xây dựng!"
	},
	{
		"id": "speech_2",
		"text": "Cảm ơn cậu đã góp ý chân thành, tớ sẽ lưu ý rút kinh nghiệm ngay!",
		"is_green": true,
		"explain": "Giao tiếp xanh: Tinh thần cầu thị, cởi mở tiếp thu và hoàn thiện bản thân!"
	},
	{
		"id": "speech_3",
		"text": "Hôm nay trông cậu hơi mệt mỏi, có điều gì cần tớ phụ giúp một tay không?",
		"is_green": true,
		"explain": "Giao tiếp xanh: Sự quan tâm tinh tế và sẻ chia ấm áp giữa bạn bè!"
	},
	{
		"id": "speech_4",
		"text": "Có mỗi việc cỏn con thế này mà cũng làm không xong, vô dụng thật!",
		"is_green": false,
		"explain": "Giao tiếp đỏ: Miệt thị và công kích cá nhân, phá hủy lòng tự trọng của người khác!"
	},
	{
		"id": "speech_5",
		"text": "Tùy, thích làm gì thì làm, từ giờ việc ai nấy lo đừng có mở miệng nhờ vả!",
		"is_green": false,
		"explain": "Giao tiếp đỏ: Thái độ bất cần, trốn tránh giao tiếp và phát động chiến tranh lạnh độc hại!"
	},
	{
		"id": "speech_6",
		"text": "Tại cậu hết đấy! Do cậu mà cả nhóm mới bị điểm thấp thảm hại thế này!",
		"is_green": false,
		"explain": "Giao tiếp đỏ: Đổ lỗi hoàn toàn cho người khác và phủi bỏ trách nhiệm chung!"
	}
]

var current_phase: int = 1
var current_sit_idx: int = 0
var completed_sit_count: int = 0

var selected_speech_card: Dictionary = {}
var categorized_cards: Dictionary = {} # card_id -> "green" or "red"

func _ready() -> void:
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(_on_back_pressed)
	btn_guide.pressed.connect(_on_guide_pressed)
	btn_close_guide.pressed.connect(func(): guide_modal.visible = false)
	btn_next_situation.pressed.connect(_on_next_situation_pressed)
	btn_go_phase2.pressed.connect(_switch_to_phase2)
	btn_basket_green.pressed.connect(_on_basket_chosen.bind("green"))
	btn_basket_red.pressed.connect(_on_basket_chosen.bind("red"))
	btn_finish_game.pressed.connect(_on_finish_game_pressed)
	btn_claim_reward.pressed.connect(_on_claim_reward_pressed)
	
	_setup_guide_content()
	_init_phase1()

func load_minigame(_data: Dictionary = {}) -> void:
	_init_phase1()

func _setup_guide_content() -> void:
	var guide_text = """CẨM NANG: NGHỆ THUẬT GIAO TIẾP & GIẢI QUYẾT MÂU THUẪN

1. Mô hình phản hồi 'Bát Phở Thơm' (Sandwich Feedback):
- Khen ngợi/Ghi nhận điểm tốt trước -> Góp ý chân thành, cụ thể vào vấn đề -> Động viên, tin tưởng và hướng đến tương lai.

2. Sử dụng thông điệp 'Tôi' (I-Message) thay vì 'Bạn' (You-Message):
- Thay vì nói: 'Cậu bừa bãi quá thể!' (Công kích cá nhân).
- Hãy nói: 'Tớ cảm thấy hơi khó chịu khi phòng bị bừa bộn, tụi mình cùng nhau dọn dẹp nhé!' (Bày tỏ cảm xúc & Mời hợp tác).

3. Thiết lập ranh giới lành mạnh (Boundaries):
- Tôn trọng tài sản và sự riêng tư của người khác.
- Dũng cảm lên tiếng từ chối và ngăn chặn các hành vi trêu đùa quá trớn."""
	guide_content_lbl.text = guide_text

func _init_phase1() -> void:
	current_phase = 1
	current_sit_idx = 0
	completed_sit_count = 0
	
	phase1_container.visible = true
	phase2_container.visible = false
	btn_go_phase2.disabled = true
	btn_go_phase2.visible = false
	
	phase_badge_lbl.text = "GAME 1 / 2"
	phase_status_lbl.text = "💬 Nếu là bạn, bạn sẽ nói gì? (0/3)"
	cat_speech_lbl.text = "Meo! Cuộc sống tự lập sẽ gặp nhiều va chạm. Hãy chọn cách ứng xử khéo léo, văn minh nhưng dứt khoát nhé!"
	
	_render_current_situation()

func _render_current_situation() -> void:
	if current_sit_idx >= SITUATIONS.size():
		return
		
	var sit = SITUATIONS[current_sit_idx]
	sit_num_lbl.text = "TÌNH HUỐNG %d / %d" % [current_sit_idx + 1, SITUATIONS.size()]
	sit_title_lbl.text = sit["title"]
	sit_desc_lbl.text = sit["desc"]
	
	sit_feedback_lbl.text = ""
	sit_feedback_lbl.visible = false
	btn_next_situation.visible = false
	
	for child in sit_options_vbox.get_children():
		child.queue_free()
		
	for opt in sit["options"]:
		var btn = Button.new()
		btn.text = opt["text"]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(0, 52)
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", Color(0.2, 0.25, 0.35))
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		_apply_card_normal_style(btn)
		btn.pressed.connect(_on_situation_option_chosen.bind(opt, btn))
		sit_options_vbox.add_child(btn)

func _on_situation_option_chosen(opt: Dictionary, chosen_btn: Button) -> void:
	for child in sit_options_vbox.get_children():
		var b = child as Button
		b.disabled = true
		
	sit_feedback_lbl.visible = true
	sit_feedback_lbl.text = opt["feedback"]
	
	if opt["is_correct"]:
		SoundManager.play_success()
		_apply_button_matched_style(chosen_btn)
		sit_feedback_lbl.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25))
		cat_speech_lbl.text = "Rất văn minh! " + opt["feedback"]
		completed_sit_count += 1
		phase_status_lbl.text = "💬 Nếu là bạn, bạn sẽ nói gì? (%d/3)" % completed_sit_count
		
		if current_sit_idx < SITUATIONS.size() - 1:
			btn_next_situation.visible = true
		else:
			btn_go_phase2.visible = true
			btn_go_phase2.disabled = false
			cat_speech_lbl.text = "🎉 Tuyệt vời! Bạn đã vượt qua cả 3 tình huống ứng xử khó khăn! Nhấn 'Sang Game 2' để phân loại giao tiếp Xanh vs Đỏ!"
	else:
		SoundManager.play_fail()
		_apply_button_wrong_style(chosen_btn)
		sit_feedback_lbl.add_theme_color_override("font_color", Color(0.85, 0.2, 0.2))
		cat_speech_lbl.text = "Cách ứng xử này dễ gây xung đột lớn! Hãy thử suy nghĩ lại cách nói nhé!"
		
		var retry_timer = get_tree().create_timer(1.8)
		retry_timer.timeout.connect(func():
			if is_instance_valid(self):
				for child in sit_options_vbox.get_children():
					var b = child as Button
					b.disabled = false
					_apply_card_normal_style(b)
				sit_feedback_lbl.visible = false
		)

func _on_next_situation_pressed() -> void:
	current_sit_idx += 1
	SoundManager.play_card_pop()
	_render_current_situation()

func _switch_to_phase2() -> void:
	current_phase = 2
	phase1_container.visible = false
	phase2_container.visible = true
	
	phase_badge_lbl.text = "GAME 2 / 2"
	phase_status_lbl.text = "🟢 Giao tiếp Xanh hay Đỏ? (0/6)"
	cat_speech_lbl.text = "Meo! Hãy bấm chọn từng câu nói ở khay bên dưới, sau đó xếp vào rổ 'Giao tiếp Xanh 🟢' hoặc 'Giao tiếp Đỏ 🔴' nhé!"
	SoundManager.play_card_pop()
	
	selected_speech_card = {}
	categorized_cards = {}
	btn_finish_game.visible = false
	
	_render_baskets()
	_render_speech_cards_pool()

func _render_baskets() -> void:
	for child in basket_green_vbox.get_children():
		child.queue_free()
	for child in basket_red_vbox.get_children():
		child.queue_free()
		
	for card_id in categorized_cards.keys():
		var card = _get_speech_card(card_id)
		var cat_type = categorized_cards[card_id]
		
		var lbl = Label.new()
		lbl.text = "• " + card["text"]
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.add_theme_font_size_override("font_size", 10)
		
		if cat_type == "green":
			lbl.add_theme_color_override("font_color", Color(0.15, 0.55, 0.25))
			basket_green_vbox.add_child(lbl)
		else:
			lbl.add_theme_color_override("font_color", Color(0.8, 0.25, 0.25))
			basket_red_vbox.add_child(lbl)

func _render_speech_cards_pool() -> void:
	for child in cards_pool.get_children():
		child.queue_free()
		
	var remaining_cards = []
	for card in SPEECH_CARDS:
		if not categorized_cards.has(card["id"]):
			remaining_cards.append(card)
			
	for card in remaining_cards:
		var btn = Button.new()
		btn.text = card["text"]
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.custom_minimum_size = Vector2(230, 44)
		btn.add_theme_font_size_override("font_size", 10)
		btn.add_theme_color_override("font_color", Color(0.25, 0.2, 0.15))
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		if selected_speech_card.get("id", "") == card["id"]:
			_apply_card_selected_style(btn)
		else:
			_apply_card_normal_style(btn)
			
		btn.pressed.connect(_on_speech_card_selected.bind(card))
		cards_pool.add_child(btn)

func _on_speech_card_selected(card: Dictionary) -> void:
	selected_speech_card = card.duplicate()
	SoundManager.play_click()
	cat_speech_lbl.text = "Bạn vừa chọn câu: '%s'. Hãy bấm nút ở rổ XANH 🟢 hoặc rổ ĐỎ 🔴 để xếp loại!" % card["text"]
	_render_speech_cards_pool()

func _on_basket_chosen(chosen_basket: String) -> void:
	if selected_speech_card.is_empty():
		cat_speech_lbl.text = "Meo! Hãy bấm chọn một câu nói ở khay bên dưới trước nhé!"
		SoundManager.play_fail()
		return
		
	var is_correct = false
	if chosen_basket == "green" and selected_speech_card.get("is_green", false):
		is_correct = true
	elif chosen_basket == "red" and not selected_speech_card.get("is_green", false):
		is_correct = true
		
	if is_correct:
		SoundManager.play_success()
		categorized_cards[selected_speech_card["id"]] = chosen_basket
		cat_speech_lbl.text = "Chính xác! " + selected_speech_card.get("explain", "")
		selected_speech_card = {}
		
		_render_baskets()
		_render_speech_cards_pool()
		
		phase_status_lbl.text = "🟢 Giao tiếp Xanh hay Đỏ? (%d/6)" % categorized_cards.size()
		
		if categorized_cards.size() >= SPEECH_CARDS.size():
			btn_finish_game.visible = true
			cat_speech_lbl.text = "🎉 HOÀN TOÀN CHÍNH XÁC! Bạn đã phân loại xuất sắc cả 6 câu nói! Nhấn Hoàn Thành để nhận huy hiệu nhé!"
	else:
		SoundManager.play_fail()
		cat_speech_lbl.text = "Chưa đúng rổ rồi Sen ơi! Hãy đọc kỹ ý nghĩa của câu nói này xem nó tích cực xây dựng hay mang tính độc hại nhé!"

func _on_finish_game_pressed() -> void:
	SoundManager.play_level_up()
	victory_modal.visible = true
	victory_dialogue_lbl.text = """Boss Mèo phong tặng danh hiệu 'Sứ Giả Hòa Bình Xóm Trọ':

'Meo! Giao tiếp là chiếc cầu nối kỳ diệu nhất trong đời sống tự lập. Sen đã chứng tỏ bản lĩnh giao tiếp xuất sắc:

- Biết lắng nghe và đồng cảm trước khi đưa ra nhận xét.
- Dũng cảm thiết lập ranh giới khi bị trêu đùa quá trớn.
- Nhận biết rõ ràng đâu là ngôn từ mang năng lượng tích cực (Xanh 🟢) và đâu là lời nói độc hại phá hoại mối quan hệ (Đỏ 🔴).

Chúc mừng Sen đã trở thành một người bạn cùng phòng lý tưởng và người đồng đội tuyệt vời!'"""

func _on_claim_reward_pressed() -> void:
	victory_modal.visible = false
	var sim_steps = [
		{"step": 1, "desc": "Góp ý bạn cùng phòng tế nhị và thiết lập ranh giới đồ dùng cá nhân"},
		{"step": 2, "desc": "Trao đổi tiến độ bài tập nhóm lịch sự, hỏi thăm khó khăn và chốt hạn rõ ràng"},
		{"step": 3, "desc": "Bình tĩnh bảo vệ bản thân trước những trò đùa quá trớn thiếu tôn trọng"},
		{"step": 4, "desc": "Phân loại chính xác 6 câu nói tích cực (Xanh 🟢) vs độc hại (Đỏ 🔴)"}
	]
	emit_signal("minigame_completed", sim_steps)

func _on_back_pressed() -> void:
	SoundManager.play_click()
	emit_signal("back_requested")

func _on_guide_pressed() -> void:
	SoundManager.play_click()
	guide_modal.visible = true

func _get_speech_card(id: String) -> Dictionary:
	for c in SPEECH_CARDS:
		if c["id"] == id:
			return c
	return {}

# Style helpers
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
