extends Control

# SelfDiagnosisGame.gd - Game 3: Xác Định Đúng Bệnh Của Bản Thân Trước Khi Uống Thuốc
# Gameplay 2 lượt nghiêm ngặt:
# Lượt 1: Chọn vật phẩm chẩn đoán trong hộp cứu thương -> Xem Bảng Thống Kê Thông Tin đo đạc
# Lượt 2: Chọn đúng vật phẩm thuốc cần dùng
# Luật chơi: Sai bất kỳ lượt nào = GAME OVER ngay lập tức!

signal minigame_completed(sim_steps)
signal back_requested

# UI Nodes
@onready var btn_back: Button = $Header/BtnBack
@onready var btn_guide: Button = $Header/BtnGuide
@onready var title_lbl: Label = $Header/TitleLabel

@onready var case_progress_lbl: Label = $CaseBanner/HBox/CaseProgressLabel
@onready var case_vital_lbl: Label = $CaseBanner/HBox/CaseVitalLabel

@onready var illustration_rect: TextureRect = $ContentScroll/VBox/IllustrationFrame/IllustrationRect
@onready var situation_lbl: Label = $ContentScroll/VBox/SituationCard/VBox/SituationLabel

# Lượt 1: Dụng cụ chẩn đoán
@onready var turn_1_card: PanelContainer = $ContentScroll/VBox/Turn1Card
@onready var turn_1_prompt_lbl: Label = $ContentScroll/VBox/Turn1Card/VBox/Turn1PromptLabel
@onready var turn_1_items_container: VBoxContainer = $ContentScroll/VBox/Turn1Card/VBox/Turn1ItemsContainer

# Bảng thống kê thông tin (Medical Stat Sheet)
@onready var stat_sheet_card: PanelContainer = $ContentScroll/VBox/StatSheetCard
@onready var stat_sheet_title_lbl: Label = $ContentScroll/VBox/StatSheetCard/VBox/SheetTitleLabel
@onready var stat_sheet_tool_lbl: Label = $ContentScroll/VBox/StatSheetCard/VBox/StatsGrid/ToolValue
@onready var stat_sheet_value_lbl: Label = $ContentScroll/VBox/StatSheetCard/VBox/StatsGrid/MeasuredValue
@onready var stat_sheet_vitals_lbl: Label = $ContentScroll/VBox/StatSheetCard/VBox/StatsGrid/VitalsValue
@onready var stat_sheet_notes_lbl: Label = $ContentScroll/VBox/StatSheetCard/VBox/StatsGrid/NotesValue
@onready var stat_sheet_conclusion_lbl: Label = $ContentScroll/VBox/StatSheetCard/VBox/ConclusionBox/ConclusionLabel
@onready var stat_sheet_goal_lbl: Label = $ContentScroll/VBox/StatSheetCard/VBox/GoalBox/GoalLabel
@onready var btn_proceed_to_turn_2: Button = $ContentScroll/VBox/StatSheetCard/VBox/BtnProceedToTurn2

# Lượt 2: Chọn thuốc đặc trị
@onready var turn_2_card: PanelContainer = $ContentScroll/VBox/Turn2Card
@onready var turn_2_prompt_lbl: Label = $ContentScroll/VBox/Turn2Card/VBox/Turn2PromptLabel
@onready var turn_2_items_container: VBoxContainer = $ContentScroll/VBox/Turn2Card/VBox/Turn2ItemsContainer

@onready var cat_speech_lbl: Label = $MascotSection/HBox/SpeechBubble/CatSpeechLabel

# Modals
@onready var guide_modal: Control = $GuideModal
@onready var guide_content_lbl: Label = $GuideModal/ModalPanel/VBox/Scroll/GuideContent
@onready var btn_close_guide: Button = $GuideModal/ModalPanel/VBox/BtnCloseGuide

@onready var game_over_modal: Control = $GameOverModal
@onready var game_over_reason_lbl: Label = $GameOverModal/ModalPanel/VBox/GameOverReasonLabel
@onready var btn_retry_from_beginning: Button = $GameOverModal/ModalPanel/VBox/BtnRetryGame

@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue_lbl: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

var minigame_data: Dictionary = {}
var cases_list: Array = []
var current_case_idx: int = 0
var current_turn: int = 1 # 1: Chẩn đoán, 2: Xem bảng thống kê, 3: Chọn thuốc
var total_mistakes: int = 0

func _ready() -> void:
	_setup_events()
	if guide_modal: guide_modal.visible = false
	if game_over_modal: game_over_modal.visible = false
	if victory_modal: victory_modal.visible = false

func _setup_events() -> void:
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
	if btn_retry_from_beginning:
		btn_retry_from_beginning.pressed.connect(_on_retry_pressed)
	if btn_claim_reward:
		btn_claim_reward.pressed.connect(_on_claim_reward_pressed)
	if btn_proceed_to_turn_2:
		btn_proceed_to_turn_2.pressed.connect(_on_proceed_to_turn_2_pressed)

func load_minigame(data: Dictionary) -> void:
	minigame_data = data
	cases_list = minigame_data.get("cases", [])
	title_lbl.text = minigame_data.get("title", "Xác định đúng bệnh trước khi uống thuốc")
	current_case_idx = 0
	current_turn = 1
	total_mistakes = 0
	_render_current_case()

func _render_current_case() -> void:
	if $ContentScroll:
		$ContentScroll.scroll_vertical = 0
	if current_case_idx >= cases_list.size():
		_show_victory()
		return
		
	var c_data = cases_list[current_case_idx]
	case_progress_lbl.text = "🩺 CA BỆNH: %d / %d" % [current_case_idx + 1, cases_list.size()]
	case_vital_lbl.text = c_data.get("case_title", "Kiểm tra sức khỏe")
	
	# Load ảnh minh họa
	var img_paths = [
		"res://assets/sprites/skills/lesson_03_step_1.png",
		"res://assets/sprites/skills/lesson_03_step_2.png",
		"res://assets/sprites/skills/lesson_03_step_3.png"
	]
	var pick_img = img_paths[current_case_idx % img_paths.size()]
	var tex = _load_texture_safe(pick_img)
	if tex:
		illustration_rect.texture = tex
		
	situation_lbl.text = c_data.get("situation_desc", "")
	
	if current_turn == 1:
		turn_1_card.visible = true
		stat_sheet_card.visible = false
		turn_2_card.visible = false
		turn_1_prompt_lbl.text = c_data.get("turn_1_prompt", "LƯỢT 1: Chọn vật phẩm chẩn đoán:")
		cat_speech_lbl.text = "Meo meo! Đang khó chịu lắm nhưng tuyệt đối không được đoán mò! Chọn đúng dụng cụ kiểm tra nhé Sen! 🐾"
		_render_turn_1_items(c_data.get("turn_1_items", []))
	elif current_turn == 2:
		turn_1_card.visible = false
		stat_sheet_card.visible = true
		turn_2_card.visible = false
		_render_stat_sheet(c_data.get("diagnosis_stat_sheet", {}))
		cat_speech_lbl.text = "Chính xác! Đã đo được chỉ số cụ thể! Đọc kỹ Bảng Thống Kê rồi bấm Tiếp Tục chọn thuốc nhé! 📋"
	elif current_turn == 3:
		turn_1_card.visible = false
		stat_sheet_card.visible = false
		turn_2_card.visible = true
		turn_2_prompt_lbl.text = c_data.get("turn_2_prompt", "LƯỢT 2: Chọn lọ thuốc đặc trị:")
		cat_speech_lbl.text = "Căn cứ vào kết luận chẩn đoán ở Bảng Thống Kê, hãy chọn đúng lọ thuốc đặc trị cần dùng nào! 💊"
		_render_turn_2_items(c_data.get("turn_2_items", []))

func _render_turn_1_items(items: Array) -> void:
	for child in turn_1_items_container.get_children():
		child.queue_free()
		
	var shuffled = items.duplicate()
	shuffled.shuffle()
	
	for it in shuffled:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 64)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = Color(1.0, 0.99, 0.97, 1.0)
		style_normal.border_color = Color(0.85, 0.75, 0.65, 1.0)
		style_normal.set_border_width_all(2)
		style_normal.border_width_bottom = 3
		style_normal.set_corner_radius_all(12)
		style_normal.content_margin_left = 12
		style_normal.content_margin_right = 12
		style_normal.content_margin_top = 6
		style_normal.content_margin_bottom = 6
		btn.add_theme_stylebox_override("normal", style_normal)
		
		var style_hover = style_normal.duplicate()
		style_hover.bg_color = Color(0.95, 0.98, 1.0, 1.0)
		style_hover.border_color = Color(0.2, 0.6, 0.9, 1.0)
		btn.add_theme_stylebox_override("hover", style_hover)
		
		var style_pressed = style_normal.duplicate()
		style_pressed.bg_color = Color(0.9, 0.94, 0.98, 1.0)
		btn.add_theme_stylebox_override("pressed", style_pressed)
		
		btn.text = "%s  %s\n    %s" % [it.get("icon", "🔹"), it.get("name", ""), it.get("desc", "")]
		btn.add_theme_color_override("font_color", Color(0.22, 0.18, 0.14, 1.0))
		btn.add_theme_font_size_override("font_size", 12)
		
		btn.pressed.connect(func(): _on_turn_1_item_selected(it, btn))
		turn_1_items_container.add_child(btn)

func _on_turn_1_item_selected(it: Dictionary, btn: Button = null) -> void:
	var is_correct = it.get("is_correct", false)
	if is_correct:
		SoundManager.play_success()
		if btn:
			var win_style = StyleBoxFlat.new()
			win_style.bg_color = Color(0.20, 0.72, 0.38, 1.0)
			win_style.border_color = Color(0.12, 0.50, 0.22, 1.0)
			win_style.set_corner_radius_all(12)
			win_style.set_border_width_all(2)
			win_style.content_margin_left = 12
			win_style.content_margin_right = 12
			win_style.content_margin_top = 6
			win_style.content_margin_bottom = 6
			btn.add_theme_stylebox_override("normal", win_style)
			btn.add_theme_stylebox_override("disabled", win_style)
			btn.add_theme_color_override("font_color", Color(1, 1, 1))
			btn.add_theme_color_override("font_disabled_color", Color(1, 1, 1))
			btn.disabled = true
			
			var tw = create_tween()
			tw.tween_interval(0.35)
			tw.tween_callback(func():
				current_turn = 2 # Chuyển sang xem Bảng Thống Kê
				_render_current_case()
			)
		else:
			current_turn = 2
			_render_current_case()
	else:
		total_mistakes += 1
		SoundManager.play_card_pop()
		_show_game_over(it.get("fail_msg", "Chẩn đoán mò mẫm bằng sai dụng cụ y tế!"))

func _render_stat_sheet(sheet: Dictionary) -> void:
	stat_sheet_title_lbl.text = sheet.get("title", "📋 BẢNG THỐNG KÊ CHỈ SỐ Y TẾ")
	stat_sheet_tool_lbl.text = sheet.get("tool_used", "")
	stat_sheet_value_lbl.text = sheet.get("measured_value", "")
	stat_sheet_vitals_lbl.text = sheet.get("vital_signs", "")
	stat_sheet_notes_lbl.text = sheet.get("clinical_notes", "")
	stat_sheet_conclusion_lbl.text = sheet.get("conclusion", "")
	stat_sheet_goal_lbl.text = sheet.get("treatment_goal", "")

func _on_proceed_to_turn_2_pressed() -> void:
	SoundManager.play_click()
	current_turn = 3 # Chuyển sang Lượt 2 chọn thuốc
	_render_current_case()

func _render_turn_2_items(items: Array) -> void:
	for child in turn_2_items_container.get_children():
		child.queue_free()
		
	var shuffled = items.duplicate()
	shuffled.shuffle()
	
	for it in shuffled:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 68)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = Color(1.0, 0.99, 0.97, 1.0)
		style_normal.border_color = Color(0.85, 0.75, 0.65, 1.0)
		style_normal.set_border_width_all(2)
		style_normal.border_width_bottom = 3
		style_normal.set_corner_radius_all(12)
		style_normal.content_margin_left = 12
		style_normal.content_margin_right = 12
		style_normal.content_margin_top = 6
		style_normal.content_margin_bottom = 6
		btn.add_theme_stylebox_override("normal", style_normal)
		
		var style_hover = style_normal.duplicate()
		style_hover.bg_color = Color(0.98, 0.95, 0.9, 1.0)
		style_hover.border_color = Color(0.95, 0.55, 0.12, 1.0)
		btn.add_theme_stylebox_override("hover", style_hover)
		
		var style_pressed = style_normal.duplicate()
		style_pressed.bg_color = Color(0.95, 0.9, 0.82, 1.0)
		btn.add_theme_stylebox_override("pressed", style_pressed)
		
		btn.text = "%s  %s\n    %s" % [it.get("icon", "💊"), it.get("name", ""), it.get("desc", "")]
		btn.add_theme_color_override("font_color", Color(0.22, 0.18, 0.14, 1.0))
		btn.add_theme_font_size_override("font_size", 12)
		
		btn.pressed.connect(func(): _on_turn_2_item_selected(it, btn))
		turn_2_items_container.add_child(btn)

func _on_turn_2_item_selected(it: Dictionary, btn: Button = null) -> void:
	var is_correct = it.get("is_correct", false)
	if is_correct:
		SoundManager.play_success()
		if btn:
			var win_style = StyleBoxFlat.new()
			win_style.bg_color = Color(0.20, 0.72, 0.38, 1.0)
			win_style.border_color = Color(0.12, 0.50, 0.22, 1.0)
			win_style.set_corner_radius_all(12)
			win_style.set_border_width_all(2)
			win_style.content_margin_left = 12
			win_style.content_margin_right = 12
			win_style.content_margin_top = 6
			win_style.content_margin_bottom = 6
			btn.add_theme_stylebox_override("normal", win_style)
			btn.add_theme_stylebox_override("disabled", win_style)
			btn.add_theme_color_override("font_color", Color(1, 1, 1))
			btn.add_theme_color_override("font_disabled_color", Color(1, 1, 1))
			btn.disabled = true
			
			var tw = create_tween()
			tw.tween_interval(0.35)
			tw.tween_callback(func():
				current_turn = 1
				current_case_idx += 1
				_render_current_case()
			)
		else:
			current_turn = 1
			current_case_idx += 1
			_render_current_case()
	else:
		total_mistakes += 1
		SoundManager.play_card_pop()
		_show_game_over(it.get("fail_msg", "Uống sai thuốc cực kỳ nguy hiểm đến tính mạng!"))

func _show_game_over(reason: String) -> void:
	game_over_reason_lbl.text = "🚨 NGUY HIỂM Y TẾ TỘT ĐỘ!\n\n%s\n\n☠️ HẬU QUẢ: Cơ thể trúng độc và kháng thuốc nặng nề! GAME OVER!\nBạn phải bắt đầu lại từ Ca 1 để học lại quy trình an toàn y tế!" % reason
	game_over_modal.visible = true

func _on_retry_pressed() -> void:
	SoundManager.play_click()
	game_over_modal.visible = false
	current_case_idx = 0
	current_turn = 1
	_render_current_case()

func _show_victory() -> void:
	var speech = "🎉 XUẤT SẮC! BẠN ĐÃ TRỞ THÀNH DƯỢC SĨ BẢN LĨNH CỦA CHÍNH MÌNH!\n\n"
	speech += "Mèo con đã hoàn thành chuẩn xác cả 3 ca chẩn đoán & dùng thuốc sinh tồn:\n\n"
	speech += "✔ Ca 1: Đo nhiệt kế 38.9°C -> Bảng chẩn đoán Sốt cao cấp tính -> Uống đúng Paracetamol + Bù nước Oresol.\n"
	speech += "✔ Ca 2: Bảng theo dõi tiêu hóa -> Bảng chẩn đoán Nhiễm khuẩn ruột -> Uống Berberin thảo dược + Oresol.\n"
	speech += "✔ Ca 3: Thước đo sẩn phù mề đay -> Bảng chẩn đoán Dị ứng Histamin -> Uống Clorpheniramin chống dị ứng.\n\n"
	speech += "Tuyệt đối không đoán mò, không tự ý uống kháng sinh bừa bãi! Sức khỏe của Boss luôn được bảo vệ an toàn 100%!\n\n"
	speech += "🎖️ Bạn đã nhận danh hiệu 'Dược Sĩ Của Bản Thân' và mở khóa 'Nhiệt Kế Điện Tử Đầu Mềm'!"
	victory_dialogue_lbl.text = speech
	victory_modal.visible = true
	SoundManager.play_success()

func _on_claim_reward_pressed() -> void:
	SoundManager.play_click()
	victory_modal.visible = false
	GameManager.complete_lesson(3)
	var sim_steps = minigame_data.get("sim_steps", [
		{"icon": "🌡️", "text": "Dùng dụng cụ đo chỉ số cơ thể"},
		{"icon": "📋", "text": "Lập bảng thống kê triệu chứng"},
		{"icon": "💊", "text": "Chọn đúng thuốc đặc trị"},
		{"icon": "✨", "text": "Hồi phục sức khỏe an toàn"}
	])
	emit_signal("minigame_completed", sim_steps)

func _on_guide_pressed() -> void:
	SoundManager.play_click()
	var guide_str = "📌 QUY TẮC Y TẾ '4 ĐÚNG' CỦA SINH VIÊN TỰ LẬP:\n\n"
	guide_str += "1. ĐO ĐẠC TRƯỚC KHI KẾT LUẬN:\n"
	guide_str += "  • Dùng nhiệt kế điện tử đo trán hoặc kẹp nách để có số đo chính xác.\n"
	guide_str += "  • Thân nhiệt > 38.5°C mới dùng thuốc hạ sốt Paracetamol.\n\n"
	guide_str += "2. BẢNG THỐNG KÊ THÔNG TIN TRIỆU CHỨNG:\n"
	guide_str += "  • Ghi nhận nhiệt độ, nhịp tim, số lần đi ngoài, nốt phát ban.\n"
	guide_str += "  • Đối chiếu triệu chứng để rút ra kết luận y khoa sơ bộ.\n\n"
	guide_str += "3. CHỌN ĐÚNG THUỐC ĐẶC TRỊ:\n"
	guide_str += "  • Sốt, đau đầu: Paracetamol 500mg (cách nhau 4-6 tiếng).\n"
	guide_str += "  • Đau bụng tiêu chảy: Berberin thảo dược + Oresol.\n"
	guide_str += "  • Dị ứng, sổ mũi: Clorpheniramin 4mg.\n\n"
	guide_str += "4. LỜI CẢNH BÁO SỐNG CÒN:\n"
	guide_str += "  • Tuyệt đối KHÔNG tự ý mua kháng sinh khi chưa có đơn bác sĩ!\n"
	guide_str += "  • Sai một li đi một dặm, uống sai thuốc có thể dẫn đến sốc phản vệ hoặc tổn thương gan thận vĩnh viễn!"
	guide_content_lbl.text = guide_str
	guide_modal.visible = true

func _load_texture_safe(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D:
			return res
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(path)
		if img and not img.is_empty():
			return ImageTexture.create_from_image(img)
	return null
