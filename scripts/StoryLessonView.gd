extends Control

# StoryLessonView.gd
# GAMEPLAY: Interactive Storytelling / Điền ô trống kể chuyện (Fill-in-the-Blank Adventure)
# Cơ chế Kéo Thả Chuẩn Native Godot 4 (_get_drag_data, _can_drop_data, _drop_data)
# Kết hợp thẻ bài tiếng mèo ('meo meo') và hình ảnh trực quan sinh động chuẩn CatUI

signal back_requested
signal story_completed(story_id)
signal open_matching_mode_requested
signal open_handbook_requested

# =========================================================================
# LỚP NATIVE DRAG & DROP CHO THẺ TIẾNG MÈO VÀ Ô TRỐNG ĐIỀN CHUYỆN
# =========================================================================
class StoryCardPanel extends PanelContainer:
	var card_data: Dictionary = {}
	var story_view: Control = null
	var is_filled: bool = false
	var is_selected_for_tap: bool = false
	
	func _get_drag_data(_at_position: Vector2) -> Variant:
		if is_filled or story_view == null:
			return null
		SoundManager.play_click()
		var preview = story_view._create_drag_preview(card_data)
		set_drag_preview(preview)
		return card_data
		
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if is_filled and story_view != null:
				story_view._on_filled_card_clicked(card_data)
			elif not is_filled and story_view != null:
				story_view._on_card_tap_selected(card_data)

class StoryBlankSlotPanel extends PanelContainer:
	var blank_id: String = ""
	var blank_info: Dictionary = {}
	var story_view: Control = null
	var is_filled: bool = false
	
	func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
		if is_filled or story_view == null:
			return false
		return data is Dictionary and data.has("id")
		
	func _drop_data(_at_position: Vector2, data: Variant) -> void:
		if story_view != null:
			story_view._attempt_fill_blank(data, blank_id)
			
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if story_view != null:
				story_view._on_blank_slot_clicked(blank_id)

# =========================================================================
# KHAI BÁO NODES & BIẾN
# =========================================================================
@onready var title_label: Label = $Header/TitleLabel
@onready var subtitle_label: Label = $Header/SubtitleLabel
@onready var btn_back: Button = $Header/BtnBack
@onready var btn_guide: Button = $Header/BtnGuide
@onready var btn_matching_mode: Button = $Header.get_node_or_null("BtnMatchingMode")
@onready var progress_dots_container: HBoxContainer = $Header/ProgressDotsContainer

@onready var illustration_rect: TextureRect = $IllustrationSection/IllustrationTexture
@onready var step_badge_label: Label = $IllustrationSection/StepBadge/Label
@onready var cat_bubble: Label = $CatSection/CatBubbleLabel

@onready var story_flow_container: HFlowContainer = $StorySection/StoryPanel/ScrollContainer/StoryFlowContainer
@onready var cards_pool_container: VBoxContainer = $CardsSection/ScrollContainer/CardsPoolContainer
@onready var cards_title: Label = $CardsSection/CardsTitle

@onready var guide_modal: Control = $GuideModal
@onready var guide_content_label: Label = $GuideModal/ModalPanel/ModalVBox/ScrollContainer/GuideContent
@onready var btn_close_guide: Button = $GuideModal/ModalPanel/ModalVBox/BtnCloseGuide

@onready var victory_modal: Control = $VictoryModal
@onready var victory_title: Label = $VictoryModal/Panel/VBox/TitleLabel
@onready var victory_badge: Label = $VictoryModal/Panel/VBox/BadgeLabel
@onready var victory_rewards: Label = $VictoryModal/Panel/VBox/RewardsLabel
@onready var victory_summary: Label = $VictoryModal/Panel/VBox/SummaryLabel
@onready var btn_victory_close: Button = $VictoryModal/Panel/VBox/BtnVictoryClose

# DỮ LIỆU CÂU CHUYỆN
var story_data: Dictionary = {}
var current_step_idx: int = 0
var filled_blanks: Dictionary = {} # blank_id -> card_data
var selected_card_for_tap: Dictionary = {} # Cho chế độ Tap-to-Fill (chạm thẻ rồi chạm ô)
var blank_nodes_cache: Dictionary = {} # blank_id -> PanelContainer

func _ready() -> void:
	_setup_ui_styles()
	_connect_signals()
	
	# Mặc định nạp câu chuyện chuyến xe buýt số 01 nếu chưa nạp
	if story_data.is_empty():
		var default_story = GameManager.get_story_data("story_commute_bus_01")
		if not default_story.is_empty():
			load_story(default_story)
		else:
			var f = FileAccess.open("res://assets/data/story_lessons.json", FileAccess.READ)
			if f:
				var parsed = JSON.parse_string(f.get_as_text())
				if parsed is Dictionary and parsed.has("stories") and parsed["stories"].size() > 0:
					load_story(parsed["stories"][0])

func _connect_signals() -> void:
	btn_back.pressed.connect(func():
		SoundManager.play_click()
		emit_signal("back_requested")
	)
	btn_guide.pressed.connect(_open_guide_modal)
	btn_close_guide.pressed.connect(_close_guide_modal)
	if btn_matching_mode:
		btn_matching_mode.pressed.connect(func():
			SoundManager.play_click()
			emit_signal("open_matching_mode_requested")
		)
	btn_victory_close.pressed.connect(func():
		SoundManager.play_click()
		victory_modal.visible = false
		emit_signal("back_requested")
	)

func _setup_ui_styles() -> void:
	guide_modal.visible = false
	victory_modal.visible = false
	
	# Nút Thoát
	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color(0.96, 0.93, 0.89, 1.0)
	back_style.border_color = Color(0.82, 0.74, 0.66, 1.0)
	back_style.set_border_width_all(2)
	back_style.border_width_bottom = 3
	back_style.set_corner_radius_all(12)
	back_style.content_margin_left = 12
	back_style.content_margin_right = 12
	btn_back.add_theme_stylebox_override("normal", back_style)
	btn_back.add_theme_stylebox_override("hover", back_style)
	btn_back.add_theme_stylebox_override("pressed", back_style)
	btn_back.add_theme_color_override("font_color", Color(0.38, 0.26, 0.16, 1.0))
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.text = " Thoát"

	# Nút Cẩm Nang Cứu Sen
	var guide_style = StyleBoxFlat.new()
	guide_style.bg_color = Color(1.0, 0.95, 0.90, 1.0)
	guide_style.border_color = Color(0.92, 0.55, 0.25, 1.0)
	guide_style.set_border_width_all(2)
	guide_style.border_width_bottom = 3
	guide_style.set_corner_radius_all(14)
	guide_style.content_margin_left = 12
	guide_style.content_margin_right = 12
	btn_guide.add_theme_stylebox_override("normal", guide_style)
	btn_guide.add_theme_stylebox_override("hover", guide_style)
	btn_guide.add_theme_stylebox_override("pressed", guide_style)
	btn_guide.add_theme_color_override("font_color", Color(0.75, 0.32, 0.10, 1.0))
	
	# Nút Chuyển sang Khung Tranh
	if btn_matching_mode:
		var m_style = StyleBoxFlat.new()
		m_style.bg_color = Color(1.0, 0.94, 0.88, 1.0)
		m_style.border_color = Color(0.95, 0.55, 0.20, 1.0)
		m_style.set_border_width_all(2)
		m_style.border_width_bottom = 3
		m_style.set_corner_radius_all(14)
		m_style.content_margin_left = 10
		m_style.content_margin_right = 10
		btn_matching_mode.add_theme_stylebox_override("normal", m_style)
		btn_matching_mode.add_theme_stylebox_override("hover", m_style)
		btn_matching_mode.add_theme_stylebox_override("pressed", m_style)
		btn_matching_mode.add_theme_color_override("font_color", Color(0.85, 0.38, 0.08, 1.0))
		btn_matching_mode.text = "🎯 Khung Tranh"

	# Khung ảnh minh họa
	var illus_sec = get_node_or_null("IllustrationSection")
	if illus_sec:
		var is_style = StyleBoxFlat.new()
		is_style.bg_color = Color(0.92, 0.96, 1.0, 1.0)
		is_style.border_color = Color(0.65, 0.80, 0.95, 1.0)
		is_style.set_border_width_all(2)
		is_style.border_width_bottom = 3
		is_style.set_corner_radius_all(16)
		is_style.content_margin_left = 6
		is_style.content_margin_right = 6
		is_style.content_margin_top = 6
		is_style.content_margin_bottom = 6
		illus_sec.add_theme_stylebox_override("panel", is_style)

	var step_badge = get_node_or_null("IllustrationSection/StepBadge")
	if step_badge:
		var badge_style = StyleBoxFlat.new()
		badge_style.bg_color = Color(0.18, 0.22, 0.28, 0.8)
		badge_style.set_corner_radius_all(8)
		badge_style.content_margin_left = 8
		badge_style.content_margin_right = 8
		badge_style.content_margin_top = 4
		badge_style.content_margin_bottom = 4
		step_badge.add_theme_stylebox_override("panel", badge_style)

	# Khung bóng thoại CatSection
	var cat_sec = get_node_or_null("CatSection")
	if cat_sec:
		var cb_style = StyleBoxFlat.new()
		cb_style.bg_color = Color(1.0, 0.985, 0.94, 1.0)
		cb_style.border_color = Color(0.88, 0.75, 0.60, 1.0)
		cb_style.set_border_width_all(2)
		cb_style.border_width_bottom = 3
		cb_style.set_corner_radius_all(14)
		cb_style.content_margin_left = 16
		cb_style.content_margin_right = 16
		cb_style.content_margin_top = 8
		cb_style.content_margin_bottom = 8
		cat_sec.add_theme_stylebox_override("panel", cb_style)
		cat_bubble.add_theme_color_override("font_color", Color(0.32, 0.20, 0.10, 1.0))

	# Khung truyện StorySection
	var story_panel = get_node_or_null("StorySection/StoryPanel")
	if story_panel:
		var sp_style = StyleBoxFlat.new()
		sp_style.bg_color = Color(1.0, 0.99, 0.97, 1.0)
		sp_style.border_color = Color(0.90, 0.82, 0.72, 1.0)
		sp_style.set_border_width_all(2)
		sp_style.border_width_bottom = 3
		sp_style.set_corner_radius_all(16)
		sp_style.content_margin_left = 12
		sp_style.content_margin_right = 12
		sp_style.content_margin_top = 8
		sp_style.content_margin_bottom = 8
		story_panel.add_theme_stylebox_override("panel", sp_style)

# =========================================================================
# NẠP DỮ LIỆU CÂU CHUYỆN
# =========================================================================
func load_story(data: Dictionary) -> void:
	story_data = data
	current_step_idx = 0
	title_label.text = story_data.get("title", "Chuyến Xe Buýt Đầu Tiên Của Mèo")
	_render_step_progress_dots()
	_load_current_step()

func _render_step_progress_dots() -> void:
	for child in progress_dots_container.get_children():
		progress_dots_container.remove_child(child)
		child.queue_free()
		
	var steps = story_data.get("steps", [])
	for i in range(steps.size()):
		var dot = Panel.new()
		dot.custom_minimum_size = Vector2(18, 18)
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(9)
		if i == current_step_idx:
			style.bg_color = Color(0.95, 0.55, 0.20, 1.0)
			style.border_color = Color(0.98, 0.85, 0.65, 1.0)
			style.set_border_width_all(2)
		elif i < current_step_idx:
			style.bg_color = Color(0.35, 0.78, 0.50, 1.0)
		else:
			style.bg_color = Color(0.85, 0.80, 0.75, 1.0)
		dot.add_theme_stylebox_override("panel", style)
		progress_dots_container.add_child(dot)

func _load_current_step() -> void:
	var steps = story_data.get("steps", [])
	if current_step_idx >= steps.size():
		_on_story_completed()
		return
		
	var step = steps[current_step_idx]
	subtitle_label.text = step.get("step_title", "Bước %d" % (current_step_idx + 1))
	step_badge_label.text = "Chặng %d/%d" % [current_step_idx + 1, steps.size()]
	
	# 1. Nạp ảnh minh họa tình huống
	var illus_path = step.get("illustration", "")
	if illus_path != "" and ResourceLoader.exists(illus_path):
		illustration_rect.texture = load(illus_path)
	elif illus_path != "" and FileAccess.file_exists(illus_path):
		var img = Image.new()
		if img.load(illus_path) == OK:
			illustration_rect.texture = ImageTexture.create_from_image(img)
	else:
		illustration_rect.texture = null
		
	# Hiệu ứng nảy nhẹ ảnh minh họa
	illustration_rect.pivot_offset = illustration_rect.size / 2.0
	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	illustration_rect.scale = Vector2(0.92, 0.92)
	tw.tween_property(illustration_rect, "scale", Vector2.ONE, 0.3)
	
	# 2. Cập nhật bóng thoại Boss Mèo
	cat_bubble.text = "Meo meo! Đọc câu chuyện bên dưới và kéo thẻ hành động đúng thả vào ô trống nhé Sen! 🐾"
	
	# 3. Xóa trạng thái ô trống của bước trước
	filled_blanks.clear()
	selected_card_for_tap.clear()
	blank_nodes_cache.clear()
	
	# 4. Render Đoạn văn kể chuyện & Các Ô Trống
	_render_story_text_with_blanks(step)
	
	# 5. Render Khay Thẻ Bài
	_render_cards_pool(step)
	_render_step_progress_dots()

# =========================================================================
# RENDER ĐOẠN VĂN KỂ CHUYỆN VÀ CÁC Ô TRỐNG (NATIVE DROP TARGETS)
# =========================================================================
func _render_story_text_with_blanks(step: Dictionary) -> void:
	for child in story_flow_container.get_children():
		story_flow_container.remove_child(child)
		child.queue_free()
		
	var text_template = step.get("text_template", "")
	var blanks = step.get("blanks", [])
	
	var regex = RegEx.new()
	regex.compile("\\{blank_\\d+\\}")
	var matches = regex.search_all(text_template)
	
	var last_end = 0
	for m in matches:
		var start = m.get_start()
		var end = m.get_end()
		var blank_tag = m.get_string()
		var blank_id = blank_tag.replace("{", "").replace("}", "")
		
		# Thêm đoạn text phía trước ô trống
		if start > last_end:
			var prefix = text_template.substr(last_end, start - last_end)
			_add_story_text_fragment(prefix)
			
		# Thêm Widget Ô Trống Native Drop
		var blank_info = {}
		for b in blanks:
			if b.get("blank_id") == blank_id:
				blank_info = b
				break
		_add_blank_slot_widget(blank_id, blank_info)
		last_end = end
		
	# Thêm phần text còn lại sau ô trống cuối cùng
	if last_end < text_template.length():
		var suffix = text_template.substr(last_end)
		_add_story_text_fragment(suffix)

func _add_story_text_fragment(text: String) -> void:
	var words = text.split(" ", false)
	for w in words:
		var label = Label.new()
		label.text = w
		label.add_theme_color_override("font_color", Color(0.24, 0.16, 0.10, 1.0))
		label.add_theme_font_size_override("font_size", 13)
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		story_flow_container.add_child(label)

func _add_blank_slot_widget(blank_id: String, blank_info: Dictionary) -> void:
	var is_filled = filled_blanks.has(blank_id)
	
	var slot_panel = StoryBlankSlotPanel.new()
	slot_panel.blank_id = blank_id
	slot_panel.blank_info = blank_info
	slot_panel.story_view = self
	slot_panel.is_filled = is_filled
	slot_panel.custom_minimum_size = Vector2(146, 30)
	slot_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slot_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	slot_panel.set_meta("blank_id", blank_id)
	slot_panel.set_meta("blank_info", blank_info)
	
	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(10)
	style.set_border_width_all(2)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	
	var content_box = HBoxContainer.new()
	content_box.alignment = BoxContainer.ALIGNMENT_CENTER
	content_box.add_theme_constant_override("separation", 5)
	
	if is_filled:
		var card = filled_blanks[blank_id]
		style.bg_color = Color(0.88, 0.98, 0.92, 1.0)
		style.border_color = Color(0.25, 0.75, 0.45, 1.0)
		
		var icon_lbl = Label.new()
		icon_lbl.text = card.get("icon", "🐾")
		icon_lbl.add_theme_font_size_override("font_size", 16)
		content_box.add_child(icon_lbl)
		
		var title_lbl = Label.new()
		title_lbl.text = card.get("label", "")
		title_lbl.add_theme_color_override("font_color", Color(0.12, 0.50, 0.25, 1.0))
		title_lbl.add_theme_font_size_override("font_size", 12)
		content_box.add_child(title_lbl)
		
		var check_lbl = Label.new()
		check_lbl.text = "✔"
		check_lbl.add_theme_color_override("font_color", Color(0.20, 0.70, 0.35, 1.0))
		check_lbl.add_theme_font_size_override("font_size", 13)
		content_box.add_child(check_lbl)
	else:
		style.bg_color = Color(1.0, 0.96, 0.90, 0.95)
		style.border_color = Color(0.92, 0.55, 0.25, 1.0)
		
		var dot_icon = Label.new()
		dot_icon.text = "📥"
		dot_icon.add_theme_font_size_override("font_size", 13)
		content_box.add_child(dot_icon)
		
		var hint_lbl = Label.new()
		var p_text = blank_info.get("placeholder", " [ Kéo thẻ vào đây ] ")
		if p_text.length() > 30:
			p_text = p_text.substr(0, 28) + "..."
		hint_lbl.text = p_text
		hint_lbl.add_theme_color_override("font_color", Color(0.70, 0.40, 0.15, 1.0))
		hint_lbl.add_theme_font_size_override("font_size", 11)
		content_box.add_child(hint_lbl)
		
	slot_panel.add_theme_stylebox_override("panel", style)
	slot_panel.add_child(content_box)
	
	story_flow_container.add_child(slot_panel)
	blank_nodes_cache[blank_id] = slot_panel

# =========================================================================
# RENDER KHAY THẺ BÀI LỰA CHỌN (NATIVE DRAGGABLE CARDS POOL - DẠNG CỘT DỌC)
# =========================================================================
func _render_cards_pool(step: Dictionary) -> void:
	for child in cards_pool_container.get_children():
		cards_pool_container.remove_child(child)
		child.queue_free()
		
	var cards = step.get("cards", []).duplicate()
	cards_title.text = "🐾 KHAY THẺ HÀNH ĐỘNG (Kéo thả hoặc chạm thẻ để điền ô trống):"
	
	for card in cards:
		var is_already_filled = false
		for fb_id in filled_blanks:
			if filled_blanks[fb_id].get("id") == card.get("id"):
				is_already_filled = true
				break
				
		var card_btn = _create_card_button(card, is_already_filled)
		cards_pool_container.add_child(card_btn)

func _create_card_button(card: Dictionary, is_already_filled: bool = false) -> Control:
	var is_selected_for_tap = (selected_card_for_tap.get("id", "") == card.get("id", ""))
	
	var card_panel = StoryCardPanel.new()
	card_panel.card_data = card
	card_panel.story_view = self
	card_panel.is_filled = is_already_filled
	card_panel.is_selected_for_tap = is_selected_for_tap
	card_panel.custom_minimum_size = Vector2(0, 54)
	card_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card_panel.mouse_default_cursor_shape = Control.CURSOR_ARROW if is_already_filled else Control.CURSOR_POINTING_HAND
	
	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(12)
	style.set_border_width_all(2)
	style.border_width_bottom = 3
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	
	if is_already_filled:
		style.bg_color = Color(0.92, 0.96, 0.93, 0.8)
		style.border_color = Color(0.60, 0.82, 0.68, 0.7)
	elif is_selected_for_tap:
		style.bg_color = Color(1.0, 0.95, 0.82, 1.0)
		style.border_color = Color(0.95, 0.50, 0.10, 1.0)
	else:
		style.bg_color = Color(1.0, 0.985, 0.95, 1.0)
		style.border_color = Color(0.88, 0.75, 0.62, 1.0)
		
	card_panel.add_theme_stylebox_override("panel", style)
	
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 10)
	
	# Icon badge
	var icon_lbl = Label.new()
	icon_lbl.text = card.get("icon", "🐾")
	icon_lbl.custom_minimum_size = Vector2(36, 36)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_size_override("font_size", 22)
	hbox.add_child(icon_lbl)
	
	# VBox thông tin thẻ (tiếng mèo + nhãn hành động)
	var vbox = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	
	var meow_lbl = Label.new()
	meow_lbl.text = card.get("cat_sound", "Meow!")
	if is_already_filled:
		meow_lbl.add_theme_color_override("font_color", Color(0.40, 0.65, 0.48, 1.0))
	else:
		meow_lbl.add_theme_color_override("font_color", Color(0.85, 0.40, 0.10, 1.0))
	meow_lbl.add_theme_font_size_override("font_size", 12)
	vbox.add_child(meow_lbl)
	
	var label_lbl = Label.new()
	label_lbl.text = card.get("label", "")
	if is_already_filled:
		label_lbl.add_theme_color_override("font_color", Color(0.35, 0.50, 0.40, 1.0))
	else:
		label_lbl.add_theme_color_override("font_color", Color(0.24, 0.16, 0.10, 1.0))
	label_lbl.add_theme_font_size_override("font_size", 13)
	vbox.add_child(label_lbl)
	
	hbox.add_child(vbox)
	
	# Grip / Tag trạng thái bên phải
	var tag_panel = PanelContainer.new()
	tag_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tag_style = StyleBoxFlat.new()
	tag_style.set_corner_radius_all(8)
	tag_style.content_margin_left = 8
	tag_style.content_margin_right = 8
	tag_style.content_margin_top = 4
	tag_style.content_margin_bottom = 4
	
	var tag_lbl = Label.new()
	tag_lbl.add_theme_font_size_override("font_size", 11)
	
	if is_already_filled:
		tag_style.bg_color = Color(0.20, 0.70, 0.35, 0.15)
		tag_style.border_color = Color(0.20, 0.70, 0.35, 0.45)
		tag_style.set_border_width_all(1)
		tag_lbl.text = "✔ Đã điền"
		tag_lbl.add_theme_color_override("font_color", Color(0.20, 0.60, 0.30, 1.0))
	elif is_selected_for_tap:
		tag_style.bg_color = Color(0.95, 0.45, 0.10, 0.20)
		tag_style.border_color = Color(0.95, 0.45, 0.10, 0.8)
		tag_style.set_border_width_all(1)
		tag_lbl.text = "🎯 Đã chọn"
		tag_lbl.add_theme_color_override("font_color", Color(0.90, 0.40, 0.05, 1.0))
	else:
		tag_style.bg_color = Color(0.50, 0.40, 0.30, 0.08)
		tag_style.border_color = Color(0.50, 0.40, 0.30, 0.20)
		tag_style.set_border_width_all(1)
		tag_lbl.text = "⠿ Kéo thả"
		tag_lbl.add_theme_color_override("font_color", Color(0.55, 0.45, 0.35, 0.9))
		
	tag_panel.add_theme_stylebox_override("panel", tag_style)
	tag_panel.add_child(tag_lbl)
	hbox.add_child(tag_panel)
	
	card_panel.add_child(hbox)
	return card_panel

# =========================================================================
# TẠO DRAG PREVIEW NATIVE GIAO DIỆN XINH XẮN THEO CHUỘT
# =========================================================================
func _create_drag_preview(card: Dictionary) -> Control:
	var preview = PanelContainer.new()
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.z_index = 100
	preview.custom_minimum_size = Vector2(240, 50)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.96, 0.88, 0.95)
	style.border_color = Color(0.95, 0.50, 0.10, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.shadow_color = Color(0.2, 0.1, 0.05, 0.25)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 3)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	preview.add_theme_stylebox_override("panel", style)
	
	var h = HBoxContainer.new()
	h.alignment = BoxContainer.ALIGNMENT_BEGIN
	h.add_theme_constant_override("separation", 8)
	
	var icon_l = Label.new()
	icon_l.text = card.get("icon", "🐾")
	icon_l.add_theme_font_size_override("font_size", 22)
	h.add_child(icon_l)
	
	var v = VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var meow_l = Label.new()
	meow_l.text = card.get("cat_sound", "Meow!")
	meow_l.add_theme_color_override("font_color", Color(0.85, 0.40, 0.10, 1.0))
	meow_l.add_theme_font_size_override("font_size", 11)
	v.add_child(meow_l)
	
	var lbl = Label.new()
	lbl.text = card.get("label", "")
	lbl.add_theme_color_override("font_color", Color(0.24, 0.16, 0.10, 1.0))
	lbl.add_theme_font_size_override("font_size", 12)
	v.add_child(lbl)
	
	h.add_child(v)
	preview.add_child(h)
	preview.position = -Vector2(120, 25)
	return preview

func _on_filled_card_clicked(card: Dictionary) -> void:
	for blank_id in filled_blanks:
		if filled_blanks[blank_id].get("id") == card.get("id"):
			_on_blank_slot_clicked(blank_id)
			return

# =========================================================================
# XỬ LÝ CHẠM 2 BƯỚC (TAP-TO-FILL)
# =========================================================================
func _on_card_tap_selected(card: Dictionary) -> void:
	SoundManager.play_click()
	if selected_card_for_tap.get("id", "") == card.get("id", ""):
		selected_card_for_tap.clear()
	else:
		selected_card_for_tap = card
		cat_bubble.text = "Sen đã chọn thẻ '%s' nè! Giờ hãy chạm vào Ô Trống muốn điền nhé! ✨" % card.get("label", "")
		
	var step = story_data.get("steps", [])[current_step_idx]
	_render_cards_pool(step)

func _on_blank_slot_clicked(blank_id: String) -> void:
	# Nếu ô trống đã được điền, bấm vào sẽ gỡ thẻ ra để đổi
	if filled_blanks.has(blank_id):
		SoundManager.play_click()
		var card = filled_blanks[blank_id]
		filled_blanks.erase(blank_id)
		cat_bubble.text = "Đã gỡ thẻ '%s' ra khỏi ô trống để Sen chọn lại nè! 🐾" % card.get("label", "")
		var step = story_data.get("steps", [])[current_step_idx]
		_render_story_text_with_blanks(step)
		_render_cards_pool(step)
		return
		
	# Nếu có thẻ đang được chọn ở khay, điền vào ô trống này
	if not selected_card_for_tap.is_empty():
		var card_to_fill = selected_card_for_tap.duplicate()
		selected_card_for_tap.clear()
		_attempt_fill_blank(card_to_fill, blank_id)

# =========================================================================
# KIỂM TRA ĐIỀN ĐÚNG / SAI & PHẢN HỒI SINH ĐỘNG (CORE LOGIC)
# =========================================================================
func _attempt_fill_blank(card: Dictionary, blank_id: String) -> void:
	var step = story_data.get("steps", [])[current_step_idx]
	var blanks = step.get("blanks", [])
	
	var target_blank_info = {}
	for b in blanks:
		if b.get("blank_id") == blank_id:
			target_blank_info = b
			break
			
	var correct_card_id = target_blank_info.get("correct_card_id", "")
	var is_correct = (card.get("id", "") == correct_card_id)
	
	if card.has("target_blank") and card["target_blank"] != blank_id:
		is_correct = false
		
	if is_correct:
		# --- TRƯỜNG HỢP 1: KÉO / ĐIỀN ĐÚNG ---
		filled_blanks[blank_id] = card
		SoundManager.play_meow(1.15)
		
		var slot_node = blank_nodes_cache.get(blank_id)
		if slot_node:
			_punch_scale_node(slot_node)
			
		cat_bubble.text = "Méo-tick! Tuyệt vời! Sen đã điền đúng '%s' rồi nè! ✨" % card.get("label", "")
		
		_render_story_text_with_blanks(step)
		_render_cards_pool(step)
		
		# Kiểm tra xem toàn bộ ô trống của bước đã điền đủ chưa
		var all_blanks_filled = true
		for b in blanks:
			if not filled_blanks.has(b.get("blank_id")):
				all_blanks_filled = false
				break
				
		if all_blanks_filled:
			_on_step_completed(step)
	else:
		# --- TRƯỜNG HỢP 2: KÉO / ĐIỀN SAI ---
		SoundManager.play_fail()
		
		var slot_node = blank_nodes_cache.get(blank_id)
		if slot_node:
			_shake_node(slot_node)
			
		var fail_msg = card.get("fail_hint", "")
		if fail_msg == "":
			fail_msg = "Ngoao.. Không đúng rồi Sen ơi! Đọc kỹ cẩm nang rồi chọn lại nha!"
		cat_bubble.text = fail_msg

func _shake_node(node: Control) -> void:
	if not node: return
	var tw = create_tween()
	var orig_x = node.position.x
	tw.tween_property(node, "position:x", orig_x - 8, 0.05)
	tw.tween_property(node, "position:x", orig_x + 8, 0.05)
	tw.tween_property(node, "position:x", orig_x - 4, 0.05)
	tw.tween_property(node, "position:x", orig_x + 4, 0.05)
	tw.tween_property(node, "position:x", orig_x, 0.05)

func _punch_scale_node(node: Control) -> void:
	if not node: return
	node.pivot_offset = node.size / 2.0
	var tw = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	node.scale = Vector2(1.15, 1.15)
	tw.tween_property(node, "scale", Vector2.ONE, 0.25)

# =========================================================================
# HOÀN THÀNH BƯỚC & CHUYỂN TIẾP MẠCH TRUYỆN
# =========================================================================
func _on_step_completed(step: Dictionary) -> void:
	var success_msg = step.get("success_prompt", "Tuyệt vời! Chuyển sang bước tiếp theo!")
	cat_bubble.text = success_msg
	SoundManager.play_success()
	
	# Đợi 1.2 giây cho người chơi tận hưởng kết quả rồi tự động chuyển bước
	await get_tree().create_timer(1.2).timeout
	current_step_idx += 1
	_load_current_step()

func _on_story_completed() -> void:
	SoundManager.play_success()
	emit_signal("story_completed", story_data.get("story_id", ""))
	
	# Thưởng tài nguyên & danh hiệu vào GameManager
	var achv = story_data.get("achievement", "Thổ Địa Tuyến 08")
	var reward_fish = story_data.get("reward_fish", 25)
	var reward_exp = story_data.get("reward_exp", 40)
	
	GameManager.update_stats(reward_fish, 0, 0)
	GameManager.add_mastery_exp(reward_exp)
	if not achv in GameManager.badges:
		GameManager.badges.append(achv)
		
	var lesson_id = story_data.get("lesson_id", 1)
	GameManager.complete_lesson(lesson_id)
	
	# Hiển thị modal chiến thắng
	victory_title.text = "🎉 CHÚC MỪNG HOÀN THÀNH BÀI HỌC! 🎉"
	victory_badge.text = "🏆 Danh Hiệu Mới: %s" % achv
	victory_rewards.text = "🎁 Phần Thưởng: +%d Cá Khô 🐟  •  +%d EXP 🌟" % [reward_fish, reward_exp]
	victory_summary.text = story_data.get("context", "Mèo con đã hoàn thành bài học an toàn và đầy tự tin! Hãy lưu giữ bí kíp này nhé Sen!")
	victory_modal.visible = true

# =========================================================================
# MODAL CẨM NANG CỨU SEN
# =========================================================================
func _open_guide_modal() -> void:
	SoundManager.play_click()
	emit_signal("open_handbook_requested")
	var l_id = story_data.get("lesson_id", 1)
	var lesson = GameManager.lessons_data.get(l_id, {})
	var guide_lines = lesson.get("guide", [])
	var guide_text = "📖 CẨM NANG BỎ TÚI: %s\n\n" % story_data.get("title", "")
	if not guide_lines.is_empty():
		for line in guide_lines:
			guide_text += "  ✔ " + line + "\n"
	else:
		guide_text += story_data.get("handbook_tip", "") + "\n"
	guide_text += "\n💡 MẸO TỪ BOSS: Quan sát bức tranh minh họa bên trên rồi kéo thẻ hành động đúng thả vào ô trống nhé Sen!"
	
	guide_content_label.text = guide_text
	guide_modal.visible = true

func _close_guide_modal() -> void:
	SoundManager.play_click()
	guide_modal.visible = false
