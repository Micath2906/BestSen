extends Control

# HospitalChoiceGame.gd - Game 2: Lựa Chọn Bệnh Viện Đúng Bệnh
# Gameplay dựa trên tình huống bạn cùng phòng (Roommate Cat):
# Trả lời câu hỏi 2 giai đoạn: Giai đoạn 1: Xác định Chuyên Khoa -> Giai đoạn 2: Chọn Bệnh Viện chuyên sâu
# Luật chơi nghiêm ngặt: Đáp án sai -> Quay lại từ đầu (Reset về Ca 1)

signal minigame_completed(sim_steps)
signal back_requested

# UI Nodes
@onready var btn_back: Button = $Header/BtnBack
@onready var btn_guide: Button = $Header/BtnGuide
@onready var title_lbl: Label = $Header/TitleLabel
@onready var case_progress_lbl: Label = $CaseBanner/HBox/CaseProgressLabel
@onready var vital_badge_lbl: Label = $CaseBanner/HBox/VitalBadgeLabel
@onready var illustration_rect: TextureRect = $ContentScroll/VBox/IllustrationFrame/IllustrationRect
@onready var situation_lbl: Label = $ContentScroll/VBox/SituationCard/VBox/SituationLabel
@onready var stage_indicator_lbl: Label = $ContentScroll/VBox/QuestionCard/VBox/StageIndicatorLabel
@onready var question_lbl: Label = $ContentScroll/VBox/QuestionCard/VBox/QuestionLabel
@onready var options_container: VBoxContainer = $ContentScroll/VBox/QuestionCard/VBox/OptionsContainer
@onready var cat_speech_lbl: Label = $MascotSection/HBox/SpeechBubble/CatSpeechLabel

# Modals
@onready var guide_modal: Control = $GuideModal
@onready var guide_content_lbl: Label = $GuideModal/ModalPanel/VBox/Scroll/GuideContent
@onready var btn_close_guide: Button = $GuideModal/ModalPanel/VBox/BtnCloseGuide

@onready var fail_modal: Control = $FailModal
@onready var fail_title_lbl: Label = $FailModal/ModalPanel/VBox/FailTitleLabel
@onready var fail_reason_lbl: Label = $FailModal/ModalPanel/VBox/FailReasonLabel
@onready var btn_restart_game: Button = $FailModal/ModalPanel/VBox/BtnRestartGame

@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue_lbl: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

var minigame_data: Dictionary = {}
var cases_list: Array = []
var current_case_idx: int = 0
var current_stage: int = 1 # 1: Chuyên Khoa, 2: Bệnh Viện
var total_mistakes: int = 0

func _ready() -> void:
	_setup_button_events()
	if guide_modal: guide_modal.visible = false
	if fail_modal: fail_modal.visible = false
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
	if btn_restart_game:
		btn_restart_game.pressed.connect(_on_restart_from_beginning_pressed)
	if btn_claim_reward:
		btn_claim_reward.pressed.connect(_on_claim_reward_pressed)

func load_minigame(data: Dictionary) -> void:
	minigame_data = data
	cases_list = minigame_data.get("cases", [])
	title_lbl.text = minigame_data.get("title", "Lựa chọn bệnh viện đúng bệnh")
	current_case_idx = 0
	current_stage = 1
	total_mistakes = 0
	_render_current_case()

func _render_current_case() -> void:
	if $ContentScroll:
		$ContentScroll.scroll_vertical = 0
	if current_case_idx >= cases_list.size():
		_show_victory()
		return
		
	var c_data = cases_list[current_case_idx]
	case_progress_lbl.text = "🏥 CA BỆNH: %d / %d" % [current_case_idx + 1, cases_list.size()]
	vital_badge_lbl.text = "⚠️ %s" % c_data.get("vital_status", "Cần cấp cứu khẩn cấp")
	
	# Load minh họa
	var img_path = c_data.get("patient_avatar", "res://assets/sprites/skills/lesson_02_step_1.png")
	var tex = _load_texture_safe(img_path)
	if tex:
		illustration_rect.texture = tex
		
	situation_lbl.text = "%s: \"%s\"" % [c_data.get("patient_name", "Bạn Cùng Phòng"), c_data.get("situation_desc", "")]
	
	if current_stage == 1:
		stage_indicator_lbl.text = "GIAI ĐOẠN 1: XÁC ĐỊNH CHUYÊN KHOA ĐIỀU TRỊ"
		stage_indicator_lbl.add_theme_color_override("font_color", Color(0.12, 0.45, 0.85, 1.0))
		question_lbl.text = c_data.get("phase_1_question", "Chọn chuyên khoa phù hợp:")
		cat_speech_lbl.text = "Meo meo! Bạn đau lắm rồi Sen ơi! Xem kỹ triệu chứng rồi chọn đúng Chuyên Khoa trước nhé! 🐾"
		_render_options(c_data.get("phase_1_options", []))
	else:
		stage_indicator_lbl.text = "GIAI ĐOẠN 2: CHỌN BỆNH VIỆN CHUYÊN SÂU TUYẾN ĐẦU"
		stage_indicator_lbl.add_theme_color_override("font_color", Color(0.85, 0.38, 0.08, 1.0))
		question_lbl.text = c_data.get("phase_2_question", "Chọn bệnh viện chuyên sâu đầu ngành:")
		cat_speech_lbl.text = "Giỏi lắm! Đã rõ chuyên khoa rồi, giờ đưa bạn vào Bệnh Viện nào để cấp cứu ngay nào Sen! 🏥"
		_render_options(c_data.get("phase_2_options", []))

func _render_options(options: Array) -> void:
	for child in options_container.get_children():
		child.queue_free()
		
	var shuffled = options.duplicate()
	shuffled.shuffle()
	
	for opt in shuffled:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 72)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		var style_normal = StyleBoxFlat.new()
		style_normal.bg_color = Color(1.0, 0.99, 0.97, 1.0)
		style_normal.border_color = Color(0.88, 0.78, 0.66, 1.0)
		style_normal.set_border_width_all(2)
		style_normal.border_width_bottom = 3
		style_normal.set_corner_radius_all(12)
		style_normal.content_margin_left = 14
		style_normal.content_margin_right = 14
		style_normal.content_margin_top = 8
		style_normal.content_margin_bottom = 8
		btn.add_theme_stylebox_override("normal", style_normal)
		
		var style_hover = style_normal.duplicate()
		style_hover.bg_color = Color(1.0, 0.97, 0.92, 1.0)
		style_hover.border_color = Color(0.95, 0.55, 0.12, 1.0)
		btn.add_theme_stylebox_override("hover", style_hover)
		
		var style_pressed = style_normal.duplicate()
		style_pressed.bg_color = Color(0.95, 0.90, 0.82, 1.0)
		btn.add_theme_stylebox_override("pressed", style_pressed)
		
		var opt_text = "%s  %s\n    %s" % [
			opt.get("icon", "🔹"),
			opt.get("title", ""),
			opt.get("desc", "")
		]
		btn.text = opt_text
		btn.add_theme_color_override("font_color", Color(0.22, 0.18, 0.14, 1.0))
		btn.add_theme_font_size_override("font_size", 12)
		
		btn.pressed.connect(func(): _on_option_selected(opt, btn))
		options_container.add_child(btn)

func _on_option_selected(opt: Dictionary, btn: Button = null) -> void:
	var is_correct = opt.get("is_correct", false)
	if is_correct:
		SoundManager.play_success()
		if btn:
			var win_style = StyleBoxFlat.new()
			win_style.bg_color = Color(0.20, 0.72, 0.38, 1.0)
			win_style.border_color = Color(0.12, 0.50, 0.22, 1.0)
			win_style.set_corner_radius_all(12)
			win_style.set_border_width_all(2)
			win_style.content_margin_left = 14
			win_style.content_margin_right = 14
			win_style.content_margin_top = 8
			win_style.content_margin_bottom = 8
			btn.add_theme_stylebox_override("normal", win_style)
			btn.add_theme_stylebox_override("disabled", win_style)
			btn.add_theme_color_override("font_color", Color(1, 1, 1))
			btn.add_theme_color_override("font_disabled_color", Color(1, 1, 1))
			btn.disabled = true
			
			var tw = create_tween()
			tw.tween_interval(0.35)
			tw.tween_callback(func():
				if current_stage == 1:
					current_stage = 2
					_render_current_case()
				else:
					current_stage = 1
					current_case_idx += 1
					_render_current_case()
			)
		else:
			if current_stage == 1:
				current_stage = 2
				_render_current_case()
			else:
				current_stage = 1
				current_case_idx += 1
				_render_current_case()
	else:
		total_mistakes += 1
		SoundManager.play_card_pop()
		_show_fail_modal(opt.get("fail_reason", "Chọn sai chuyên khoa hoặc cơ sở y tế!"))

func _show_fail_modal(reason: String) -> void:
	fail_title_lbl.text = "🚨 BÁO ĐỘNG: CẤP CỨU SAI CƠ SỞ!"
	fail_reason_lbl.text = "%s\n\n⚠️ Theo quy tắc cấp cứu khẩn cấp: Bạn sẽ phải quay lại từ Ca 1 để chuẩn hóa lại quy trình chẩn đoán y tế!" % reason
	fail_modal.visible = true

func _on_restart_from_beginning_pressed() -> void:
	SoundManager.play_click()
	fail_modal.visible = false
	current_case_idx = 0
	current_stage = 1
	_render_current_case()

func _show_victory() -> void:
	var speech = "🎉 XUẤT SẮC! CẤP CỨU THÀNH CÔNG CẢ 3 CA BỆNH!\n\n"
	speech += "Mèo Mướp, Mèo Vàng và Mèo Mun đều được cấp cứu kịp thời trong thời gian vàng y tế nhờ Sen xác định đúng Chuyên Khoa và Bệnh Viện chuyên sâu tuyến đầu!\n\n"
	speech += "✔ Ca 1: Gãy chân -> Chuyên khoa Chấn thương chỉnh hình -> Bệnh viện Chấn Thương Chỉnh Hình TP.\n"
	speech += "✔ Ca 2: Sốt xuất huyết 39.5°C -> Chuyên khoa Bệnh Nhiệt Đới -> Bệnh viện Bệnh Nhiệt Đới TP.\n"
	speech += "✔ Ca 3: Bỏng hóa chất mắt -> Chuyên khoa Mắt cấp cứu -> Bệnh viện Mắt TP.\n\n"
	speech += "🎖️ Bạn đã nhận danh hiệu 'Thổ Địa Cứu Cấp Bệnh Viện' và mở khóa 'Sổ Tay Danh Bạ Cấp Cứu 115'!"
	victory_dialogue_lbl.text = speech
	victory_modal.visible = true
	SoundManager.play_success()

func _on_claim_reward_pressed() -> void:
	SoundManager.play_click()
	victory_modal.visible = false
	GameManager.complete_lesson(2)
	var sim_steps = minigame_data.get("sim_steps", [
		{"icon": "🤕", "text": "Khám triệu chứng bạn cùng phòng"},
		{"icon": "🩺", "text": "Xác định chuyên khoa điều trị"},
		{"icon": "🏥", "text": "Chọn đúng bệnh viện chuyên sâu"},
		{"icon": "🚑", "text": "Cấp cứu kịp thời đúng nơi"}
	])
	emit_signal("minigame_completed", sim_steps)

func _on_guide_pressed() -> void:
	SoundManager.play_click()
	var handbook_str = "📌 SỔ TAY CHUYÊN KHOA & BỆNH VIỆN TUYẾN ĐẦU (115):\n\n"
	handbook_str += "1. Xương khớp & Tai nạn té ngã:\n"
	handbook_str += "  • Chuyên khoa: Chấn thương chỉnh hình & X-quang.\n"
	handbook_str += "  • Bệnh viện: Bệnh Viện Chấn Thương Chỉnh Hình.\n\n"
	handbook_str += "2. Sốt cao li bì, ban xuất huyết, sốt virus:\n"
	handbook_str += "  • Chuyên khoa: Truyền nhiễm & Bệnh Nhiệt Đới.\n"
	handbook_str += "  • Bệnh viện: Bệnh Viện Bệnh Nhiệt Đới.\n\n"
	handbook_str += "3. Bỏng hóa chất, dị vật, đau mắt cấp:\n"
	handbook_str += "  • Chuyên khoa: Nhãn khoa (Mắt) cấp cứu 24/7.\n"
	handbook_str += "  • Bệnh viện: Bệnh Viện Mắt TP.\n\n"
	handbook_str += "💡 QUY TẮC VÀNG: Cấp cứu đúng cơ sở ngay từ đầu giúp cứu sống tính mạng và tránh chuyển viện lòng vòng mất thời gian vàng!"
	guide_content_lbl.text = handbook_str
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
