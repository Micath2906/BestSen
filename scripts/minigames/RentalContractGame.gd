extends Control

# RentalContractGame.gd - Kỹ năng 1: Hiểu biết pháp luật cơ bản về Hợp đồng thuê nhà (Lesson 5)
# Phase 1 (Game 1): Nối tình huống vi phạm pháp lý với giải pháp đúng / Soi điểm khác biệt
# Phase 2 (Game 2): Kéo thả sắp xếp thứ tự 4 bước quy trình ký hợp đồng thuê nhà an toàn

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

# Dữ liệu Phase 1: 3 Cặp Nối Tình Huống <-> Giải Pháp
const MATCHING_PAIRS = [
	{
		"id": "pair_1",
		"col_a_text": "Chủ nhà yêu cầu tăng tiền nhà bất ngờ giữa thời hạn hợp đồng",
		"col_b_text": "Vi phạm điều khoản về giá thuê đã cam kết",
		"hint": "Giá thuê nhà đã ký kết cố định thì chủ nhà không được tự ý tăng giá giữa chừng!"
	},
	{
		"id": "pair_2",
		"col_a_text": "Bên cho thuê không đăng ký tạm trú cho người thuê",
		"col_b_text": "Vi phạm quy định quản lý cư trú của pháp luật",
		"hint": "Chủ trọ có nghĩa vụ phối hợp hoặc đăng ký tạm trú cho người thuê theo Luật Cư trú!"
	},
	{
		"id": "pair_3",
		"col_a_text": "Chủ nhà không trả lại tiền cọc khi kết thúc hợp đồng đúng hạn",
		"col_b_text": "Bên thuê có quyền khiếu nại hoặc khởi kiện đòi lại tài sản",
		"hint": "Hết hạn hợp đồng và phòng ốc nguyên vẹn thì bên thuê có quyền đòi lại 100% tiền cọc!"
	}
]

# Dữ liệu Phase 2: 4 Bước quy trình ký HĐ thuê nhà an toàn
const SAFE_CONTRACT_STEPS = [
	{
		"step": 1,
		"title": "Xác minh giấy tờ chủ sở hữu nhà",
		"icon": "🔍",
		"desc": "Kiểm tra CCCD chủ nhà và sổ đỏ/hợp đồng ủy quyền để tránh thuê nhầm phòng lừa đảo",
		"error_hint": "Chưa xác minh ai là chủ nhà thật sự mà đã vội đưa tiền cọc là dính bẫy lừa đảo mất trắng!"
	},
	{
		"step": 2,
		"title": "Đọc và thỏa thuận các điều khoản về tiền cọc, điện nước",
		"icon": "📑",
		"desc": "Thống nhất đơn giá điện nước cố định, điều kiện hoàn cọc và thời hạn báo trước",
		"error_hint": "Chưa thỏa thuận rõ giá điện nước và điều kiện trả cọc mà đã ký là dễ bị ép giá trên trời!"
	},
	{
		"step": 3,
		"title": "Ký hợp đồng và lập biên bản giao nhận phòng",
		"icon": "✍️",
		"desc": "Chụp ảnh hiện trạng tường nứt, vòi nước rỉ kèm phụ lục và hai bên cùng ký tên giữ bản gốc",
		"error_hint": "Ký hợp đồng mà quên chụp ảnh lập biên bản bàn giao thì lúc dọn đi sẽ bị trừ cọc oan ức!"
	},
	{
		"step": 4,
		"title": "Thực hiện đăng ký tạm trú",
		"icon": "🪪",
		"desc": "Mang hợp đồng thuê nhà khai báo tạm trú qua VNeID hoặc Công an phường để bảo đảm quyền công dân",
		"error_hint": "Thuê trọ mà không đăng ký tạm trú là vi phạm Luật Cư trú và không được công an bảo vệ!"
	}
]

var current_phase: int = 1
var selected_col_a_id: String = ""
var matched_pairs: Dictionary = {} # pair_id -> true

var solved_contract_steps: Dictionary = {} # step (1..4) -> step_data
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
	title_lbl.text = "Pháp Luật Hợp Đồng Thuê Nhà"
	current_phase = 1
	matched_pairs.clear()
	selected_col_a_id = ""
	solved_contract_steps.clear()
	selected_step_card = {}
	
	# Xáo trộn câu hỏi và đáp án
	shuffled_pairs_a = MATCHING_PAIRS.duplicate()
	shuffled_pairs_a.shuffle()
	shuffled_pairs_b = MATCHING_PAIRS.duplicate()
	shuffled_pairs_b.shuffle()
	shuffled_phase2_pool = SAFE_CONTRACT_STEPS.duplicate()
	shuffled_phase2_pool.shuffle()
	
	_render_phase1()

# =========================================================================
# PHASE 1: NỐI TÌNH HUỐNG <-> GIẢI PHÁP PHÁP LÝ
# =========================================================================
func _render_phase1() -> void:
	current_phase = 1
	phase1_container.visible = true
	phase2_container.visible = false
	phase_badge_lbl.text = "GAME 1 / 2"
	phase_status_lbl.text = "🔗 Nối tình huống pháp lý với giải pháp đúng"
	cat_speech_lbl.text = "Meo meo! Chạm một tình huống ở Cột A, sau đó chạm giải pháp đúng ở Cột B để nối cặp nhé Sen! 🐾"
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
		btn.custom_minimum_size = Vector2(0, 68)
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
		btn.custom_minimum_size = Vector2(0, 68)
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
	cat_speech_lbl.text = "Đã chọn tình huống. Giờ hãy chọn giải pháp pháp lý đúng ở Cột B nhé!"

func _on_col_b_pressed(pair_id: String) -> void:
	if selected_col_a_id == "":
		cat_speech_lbl.text = "Sen hãy chạm chọn 1 tình huống ở Cột A trước nhé!"
		return
		
	if selected_col_a_id == pair_id:
		SoundManager.play_success()
		matched_pairs[pair_id] = true
		selected_col_a_id = ""
		_render_matching_columns()
		cat_speech_lbl.text = "Chính xác! Nối cặp pháp lý thành công! Tiếp tục nối các tình huống còn lại nào!"
		
		if matched_pairs.size() == MATCHING_PAIRS.size():
			btn_go_phase2.disabled = false
			cat_speech_lbl.text = "🎉 XUẤT SẮC! Đã hiểu rõ toàn bộ giải pháp pháp lý! Bấm Tiếp Tục sang Game 2 nào! ✨"
	else:
		SoundManager.play_card_pop()
		cat_speech_lbl.text = "Chưa đúng giải pháp pháp lý rồi Sen ơi! Thử lại cặp khác xem sao nhé!"

func _switch_to_phase2() -> void:
	SoundManager.play_click()
	current_phase = 2
	phase1_container.visible = false
	phase2_container.visible = true
	phase_badge_lbl.text = "GAME 2 / 2"
	phase_status_lbl.text = "📋 Sắp xếp quy trình ký kết hợp đồng thuê nhà an toàn"
	cat_speech_lbl.text = "Game 2: Hãy xếp 4 bước quy trình ký hợp đồng thuê trọ an toàn theo đúng thứ tự 1 ➔ 2 ➔ 3 ➔ 4 nhé! 🐾"
	btn_finish_game.disabled = true
	if content_scroll: content_scroll.scroll_vertical = 0
	_render_phase2_steps()
	_render_phase2_cards_pool()

# =========================================================================
# PHASE 2: SẮP XẾP QUY TRÌNH KÝ HỢP ĐỒNG 4 BƯỚC
# =========================================================================
func _render_phase2_steps() -> void:
	for child in steps_vbox.get_children(): child.queue_free()
	
	for s_info in SAFE_CONTRACT_STEPS:
		var s_idx = s_info["step"]
		var is_solved = solved_contract_steps.has(s_idx)
		
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
				slot_btn.text = "❓ [Ô Trống Bước %d: Chạm thẻ hành động bên dưới để đặt]" % s_idx
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
		shuffled_phase2_pool = SAFE_CONTRACT_STEPS.duplicate()
		shuffled_phase2_pool.shuffle()
		
	for s_info in shuffled_phase2_pool:
		var s_idx = s_info["step"]
		if solved_contract_steps.has(s_idx): continue
		
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
		cat_speech_lbl.text = "Sen hãy chọn một thẻ hành động ở khay bên dưới trước nhé!"
		return
		
	if selected_step_card["step"] == target_step_idx:
		SoundManager.play_success()
		solved_contract_steps[target_step_idx] = selected_step_card
		selected_step_card = {}
		_render_phase2_steps()
		_render_phase2_cards_pool()
		
		if solved_contract_steps.size() == 4:
			btn_finish_game.disabled = false
			cat_speech_lbl.text = "🎉 XUẤT SẮC! Hoàn thành quy trình 4 bước ký hợp đồng thuê nhà an toàn! Bấm Hoàn Thành để nhận thưởng nhé!"
		else:
			cat_speech_lbl.text = "Chính xác! Bước %d đã hoàn tất! Tiếp tục đặt các bước còn lại nào!" % target_step_idx
	else:
		SoundManager.play_card_pop()
		var step_data = SAFE_CONTRACT_STEPS[target_step_idx - 1]
		cat_speech_lbl.text = "CHƯA ĐÚNG! %s" % step_data.get("error_hint", "Thao tác này chưa đúng thứ tự!")

func _on_finish_game_pressed() -> void:
	SoundManager.play_success()
	var speech = "🎉 CHÚC MỪNG BẬC THẦY HỢP ĐỒNG THUÊ TRỌ!\n\n"
	speech += "Mèo con đã hoàn thành xuất sắc cả 2 Game pháp lý thuê trọ:\n\n"
	speech += "✔ Game 1: Nắm chắc 3 giải pháp bảo vệ quyền lợi khi chủ nhà tăng giá, giữ cọc hoặc không đăng ký tạm trú.\n"
	speech += "✔ Game 2: Thuộc lòng 4 bước ký kết hợp đồng an toàn:\n"
	speech += "  1. Xác minh giấy tờ chủ sở hữu nhà.\n"
	speech += "  2. Đọc & thỏa thuận rõ ràng tiền cọc, điện nước.\n"
	speech += "  3. Ký hợp đồng & lập biên bản bàn giao phòng.\n"
	speech += "  4. Thực hiện đăng ký tạm trú hợp pháp.\n\n"
	speech += "Không sợ bị lừa cọc, an cư lạc nghiệp tự tin học tập!\n\n"
	speech += "🎖️ Nhận danh hiệu 'Thám Tử Soi Hợp Đồng' & Thưởng +35 Cá Khô!"
	victory_dialogue_lbl.text = speech
	victory_modal.visible = true

func _on_claim_reward_pressed() -> void:
	SoundManager.play_click()
	victory_modal.visible = false
	GameManager.complete_lesson(5)
	var sim_steps = [
		{"icon": "🔍", "text": "Xác minh giấy tờ chủ sở hữu nhà"},
		{"icon": "📑", "text": "Đọc thỏa thuận cọc, điện nước"},
		{"icon": "✍️", "text": "Ký hợp đồng & lập biên bản bàn giao"},
		{"icon": "🪪", "text": "Đăng ký tạm trú đúng luật"}
	]
	emit_signal("minigame_completed", sim_steps)

func _on_guide_pressed() -> void:
	SoundManager.play_click()
	var guide_str = "📌 CẨM NANG PHÁP LUẬT THUÊ NHÀ:\n\n"
	guide_str += "1. NGUYÊN TẮC BẤT DI BẤT DỊCH:\n"
	guide_str += "  • Luôn yêu cầu xem CCCD và giấy chứng nhận quyền sở hữu nhà của bên cho thuê.\n"
	guide_str += "  • Không đặt cọc khi chưa có hợp đồng hoặc giấy biên nhận tiền cọc có chữ ký.\n\n"
	guide_str += "2. ĐIỀU KHOẢN CẦN SOI KỸ:\n"
	guide_str += "  • Đơn giá điện (kWh) và nước (khối): Phải ghi số cụ thể, không ghi mập mờ.\n"
	guide_str += "  • Điều kiện hoàn trả tiền cọc: Quy định rõ thời gian báo trước (thường 30 ngày).\n\n"
	guide_str += "3. BIÊN BẢN BÀN GIAO:\n"
	guide_str += "  • Chụp ảnh vết nứt, thiết bị cũ đính kèm vào phụ lục hợp đồng."
	guide_content_lbl.text = guide_str
	guide_modal.visible = true
