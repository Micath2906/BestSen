extends Control

# AuditMiniGame.gd - Gameplay "Soi Lỗi Bằng Kính Lúp Của Mèo" (Spot the Red Flags / Audit Mode)
# Người chơi dùng móng vuốt cào rách các điều khoản gian lận trong hợp đồng / PCCC / tin đa cấp

signal minigame_completed(sim_steps)
signal back_requested

@onready var title_lbl: Label = $PaperContainer/VBox/DocHeader/DocTitle
@onready var progress_lbl: Label = $PaperContainer/VBox/StatusRow/ProgressLabel
@onready var prompt_lbl: Label = $CatBar/HBox/CatSpeech
@onready var clauses_container: VBoxContainer = $PaperContainer/VBox/Scroll/ClausesContainer
@onready var btn_back: Button = $Header/BtnBack
@onready var feedback_panel: PanelContainer = $FeedbackModal
@onready var feedback_title: Label = $FeedbackModal/VBox/Title
@onready var feedback_body: Label = $FeedbackModal/VBox/Body
@onready var btn_close_feedback: Button = $FeedbackModal/VBox/BtnClose

var data: Dictionary = {}
var found_flags: int = 0
var total_required: int = 3
var scratched_ids: Array = []
var cat_anim: AnimatedSprite2D = null

func _ready() -> void:
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(func(): emit_signal("back_requested"))
	btn_close_feedback.pressed.connect(func():
		SoundManager.play_click()
		feedback_panel.visible = false
	)
	feedback_panel.visible = false
	_setup_cat_mascot()

func _setup_cat_mascot() -> void:
	var anchor = $CatBar/HBox/CatAnchor
	if cat_anim == null and anchor:
		cat_anim = AnimatedSprite2D.new()
		cat_anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		cat_anim.position = Vector2(24, 24)
		cat_anim.scale = Vector2(1.8, 1.8)
		anchor.add_child(cat_anim)
		cat_anim.sprite_frames = CatAnimationFactory.get_sprite_frames(GameManager.selected_avatar_id)
		cat_anim.play("idle2")

func load_minigame(game_data: Dictionary) -> void:
	data = game_data
	found_flags = 0
	scratched_ids.clear()
	total_required = data.get("required_flags", 3)
	
	title_lbl.text = "🔍 " + data.get("document_title", "VĂN BẢN KIỂM TRA")
	prompt_lbl.text = data.get("cat_prompt", "Sen ơi, soi kỹ tìm điểm bất thường nhé!")
	_update_progress_display()
	
	_render_clauses()

func _update_progress_display() -> void:
	progress_lbl.text = "🐾 ĐÃ CÀO RÁCH BẪY: %d/%d" % [found_flags, total_required]
	if found_flags >= total_required:
		progress_lbl.text = "🎉 ĐÃ VẠCH TRẦN %d/%d BẪY GIAN LẬN! THẮNG LỢI! 🛡️" % [found_flags, total_required]

func _render_clauses() -> void:
	for child in clauses_container.get_children():
		clauses_container.remove_child(child)
		child.queue_free()
		
	var clauses = data.get("clauses", [])
	for c in clauses:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 56)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text = " " + c.get("text", "")
		btn.add_theme_font_size_override("font_size", 11)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var is_scratched = c["id"] in scratched_ids
		_style_clause_btn(btn, is_scratched)
		
		btn.pressed.connect(func(): _on_clause_clicked(c, btn))
		clauses_container.add_child(btn)

func _style_clause_btn(btn: Button, is_scratched: bool) -> void:
	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(10)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	
	if is_scratched:
		style.bg_color = Color(1.0, 0.90, 0.90, 0.95)
		style.border_color = Color(0.90, 0.25, 0.25, 1.0)
		style.set_border_width_all(2)
		btn.add_theme_color_override("font_color", Color(0.75, 0.15, 0.15))
	else:
		style.bg_color = Color(1.0, 1.0, 1.0, 0.95)
		style.border_color = Color(0.88, 0.82, 0.75, 1.0)
		style.set_border_width_all(1)
		style.border_width_bottom = 2
		btn.add_theme_color_override("font_color", Color(0.28, 0.22, 0.18))
		
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)

func _on_clause_clicked(clause: Dictionary, btn: Button) -> void:
	var c_id = clause.get("id", "")
	if c_id in scratched_ids:
		_show_feedback("🐾 ĐÃ CÀO RÁCH BẪY NÀY RỒI!", clause.get("explanation", ""), true)
		return
		
	if clause.get("is_red_flag", false):
		# Cào trúng điểm đỏ!
		scratched_ids.append(c_id)
		found_flags += 1
		SoundManager.play_success()
		if cat_anim:
			cat_anim.play("jump")
			
		btn.text = "❌ [ĐÃ CÀO RÁCH] " + clause.get("text", "")
		_style_clause_btn(btn, true)
		_update_progress_display()
		
		# Hiệu ứng rung nhẹ
		var tw = create_tween()
		btn.pivot_offset = btn.size * 0.5
		tw.tween_property(btn, "rotation", 0.04, 0.05)
		tw.tween_property(btn, "rotation", -0.04, 0.05)
		tw.tween_property(btn, "rotation", 0.0, 0.05)
		
		prompt_lbl.text = "Cào rách rồi! " + clause.get("flag_name", "Bẫy lừa đảo") + "!"
		_show_feedback("🐾 VẠCH TRẦN: " + clause.get("flag_name", "BẪY GIAN LẬN!"), clause.get("explanation", ""), true)
		
		if found_flags >= total_required:
			_on_victory()
	else:
		# Nhấn nhầm dòng an toàn
		SoundManager.play_click()
		prompt_lbl.text = "Meo? " + clause.get("safe_hint", "Dòng này hợp pháp mà Sen!")
		_show_feedback("ℹ️ ĐIỀU KHOẢN HỢP PHÁP", clause.get("safe_hint", "Dòng này bình thường, không có bẫy gian lận đâu Sen!"), false)

func _show_feedback(title_text: String, body_text: String, is_warning: bool) -> void:
	feedback_title.text = title_text
	feedback_body.text = body_text
	if is_warning:
		feedback_title.add_theme_color_override("font_color", Color(0.85, 0.25, 0.15))
	else:
		feedback_title.add_theme_color_override("font_color", Color(0.2, 0.55, 0.75))
	feedback_panel.visible = true

func _on_victory() -> void:
	SoundManager.play_success()
	prompt_lbl.text = "Méo ngoao! Đã vạch trần mọi cạm bẫy! Sen xuất sắc quá! 🎉"
	await get_tree().create_timer(1.2).timeout
	var sim_steps = data.get("sim_steps", [])
	emit_signal("minigame_completed", sim_steps)
