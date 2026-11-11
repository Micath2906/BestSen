extends Control

# DialogueMiniGame.gd - Gameplay "Mèo Đóng Vai / Đối Đáp Tình Huống" (Dialogue Choice / Role-play)
# Người chơi đóng vai Boss Mèo chọn câu đối đáp lịch sự, bản lĩnh để bảo vệ quyền lợi

signal minigame_completed(sim_steps)
signal back_requested

@onready var title_lbl: Label = $Header/HeaderTitle
@onready var btn_back: Button = $Header/BtnBack

@onready var npc_icon_lbl: Label = $ScenarioCard/VBox/NpcRow/NpcIcon
@onready var npc_name_lbl: Label = $ScenarioCard/VBox/NpcRow/NpcName
@onready var situation_lbl: Label = $ScenarioCard/VBox/SituationLabel

@onready var cat_speech: Label = $CatSection/HBox/CatSpeech
@onready var cat_anchor: Control = $CatSection/HBox/CatAnchor
@onready var options_container: VBoxContainer = $OptionsCard/VBox/Scroll/OptionsContainer

@onready var result_modal: PanelContainer = $ResultModal
@onready var result_title: Label = $ResultModal/VBox/Title
@onready var result_body: Label = $ResultModal/VBox/Body
@onready var btn_close_result: Button = $ResultModal/VBox/BtnClose

var data: Dictionary = {}
var cat_anim: AnimatedSprite2D = null

func _ready() -> void:
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(func(): emit_signal("back_requested"))
	btn_close_result.pressed.connect(_on_close_result_pressed)
	result_modal.visible = false
	_setup_cat_mascot()

func _setup_cat_mascot() -> void:
	if cat_anim == null and cat_anchor:
		cat_anim = AnimatedSprite2D.new()
		cat_anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		cat_anim.position = Vector2(30, 30)
		cat_anim.scale = Vector2(2.2, 2.2)
		cat_anchor.add_child(cat_anim)
		cat_anim.sprite_frames = CatAnimationFactory.get_sprite_frames(GameManager.selected_avatar_id)
		cat_anim.play("idle2")

func load_minigame(game_data: Dictionary) -> void:
	data = game_data
	
	title_lbl.text = "💬 " + data.get("title", "MÈO ĐỐI ĐÁP TÌNH HUỐNG")
	npc_icon_lbl.text = data.get("npc_icon", "👤")
	npc_name_lbl.text = data.get("npc_name", "Đối tác giao tiếp")
	situation_lbl.text = data.get("situation", "Tình huống giao tiếp thực tế...")
	cat_speech.text = data.get("cat_prompt", "Chọn câu đối đáp khôn ngoan nhất nhé Sen!")
	
	_render_options()

func _render_options() -> void:
	for child in options_container.get_children():
		options_container.remove_child(child)
		child.queue_free()
		
	var options = data.get("options", [])
	for opt in options:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 68)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		btn.text = " 🐾 [%s]\n    \"%s\"" % [opt.get("meow", "Tiếng Mèo"), opt.get("text", "")]
		btn.add_theme_font_size_override("font_size", 10)
		
		var b_style = StyleBoxFlat.new()
		b_style.set_corner_radius_all(12)
		b_style.content_margin_left = 12
		b_style.content_margin_right = 12
		b_style.content_margin_top = 8
		b_style.content_margin_bottom = 8
		b_style.bg_color = Color(1, 1, 1, 0.96)
		b_style.border_color = Color(0.85, 0.78, 0.68, 1)
		b_style.set_border_width_all(1)
		b_style.border_width_bottom = 3
		
		btn.add_theme_stylebox_override("normal", b_style)
		btn.add_theme_stylebox_override("hover", b_style)
		btn.add_theme_color_override("font_color", Color(0.28, 0.2, 0.12))
		
		btn.pressed.connect(func(): _on_option_selected(opt))
		options_container.add_child(btn)

func _on_option_selected(option: Dictionary) -> void:
	var is_correct = option.get("is_correct", false)
	var feedback_text = option.get("feedback", "")
	
	if is_correct:
		SoundManager.play_success()
		if cat_anim:
			cat_anim.play("jump")
		result_title.text = "🎉 ĐỐI ĐÁP XUẤT SẮC 10 ĐIỂM!"
		result_title.add_theme_color_override("font_color", Color(0.15, 0.65, 0.28))
		result_body.text = feedback_text
		btn_close_result.text = "Tiếp tục bài học ➔"
		result_modal.set_meta("is_correct", true)
	else:
		SoundManager.play_fail()
		result_title.text = "⚠️ BẪY GIAO TIẾP / RỦI RO!"
		result_title.add_theme_color_override("font_color", Color(0.85, 0.25, 0.15))
		result_body.text = feedback_text + "\n\n💡 Mẹo cho Sen: Thử chọn cách ứng xử văn minh và bảo vệ quyền lợi hợp pháp nhé!"
		btn_close_result.text = "Chọn lại câu khác 🔄"
		result_modal.set_meta("is_correct", false)
		
	result_modal.visible = true

func _on_close_result_pressed() -> void:
	SoundManager.play_click()
	var was_correct = result_modal.get_meta("is_correct", false)
	result_modal.visible = false
	
	if was_correct:
		var sim_steps = data.get("sim_steps", [])
		minigame_completed.emit(sim_steps)
