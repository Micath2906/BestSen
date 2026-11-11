extends Control

# AvatarPickerModal.gd - Cho phép người chơi tự do đổi 8 Avatar Mèo Pixel & 6 Khung Tai Mèo chuẩn GDD

signal avatar_selected(new_id)
signal frame_selected(frame_id)

@onready var grid_container: GridContainer = $CenterContainer/Panel/VBox/Scroll/Grid
@onready var btn_tab_avatars: Button = $CenterContainer/Panel/VBox/TabHBox/BtnTabAvatars
@onready var btn_tab_frames: Button = $CenterContainer/Panel/VBox/TabHBox/BtnTabFrames
@onready var btn_close: Button = $CenterContainer/Panel/VBox/BtnClose
@onready var panel: PanelContainer = $CenterContainer/Panel

var current_tab: String = "avatars" # "avatars" hoặc "frames"
var item_buttons: Array = []

var style_card_normal: StyleBoxFlat
var style_card_hover: StyleBoxFlat
var style_card_active: StyleBoxFlat
var style_tab_active: StyleBoxFlat
var style_tab_inactive: StyleBoxFlat

func _ready() -> void:
	_init_styles()
	btn_close.pressed.connect(close)
	btn_tab_avatars.pressed.connect(func():
		SoundManager.play_click()
		_switch_tab("avatars")
	)
	btn_tab_frames.pressed.connect(func():
		SoundManager.play_click()
		_switch_tab("frames")
	)
	visible = false
	_switch_tab("avatars")

func _init_styles() -> void:
	style_card_normal = StyleBoxFlat.new()
	style_card_normal.bg_color = Color(1.0, 0.985, 0.965, 1.0)
	style_card_normal.border_color = Color(0.86, 0.78, 0.70, 1.0)
	style_card_normal.set_border_width_all(1)
	style_card_normal.border_width_bottom = 2
	style_card_normal.set_corner_radius_all(10)
	style_card_normal.content_margin_left = 8
	style_card_normal.content_margin_right = 8
	style_card_normal.content_margin_top = 6
	style_card_normal.content_margin_bottom = 6

	style_card_hover = StyleBoxFlat.new()
	style_card_hover.bg_color = Color(1.0, 0.95, 0.88, 1.0)
	style_card_hover.border_color = Color(0.90, 0.55, 0.18, 1.0)
	style_card_hover.set_border_width_all(2)
	style_card_hover.border_width_bottom = 3
	style_card_hover.set_corner_radius_all(10)
	style_card_hover.content_margin_left = 8
	style_card_hover.content_margin_right = 8
	style_card_hover.content_margin_top = 6
	style_card_hover.content_margin_bottom = 6

	style_card_active = StyleBoxFlat.new()
	style_card_active.bg_color = Color(1.0, 0.93, 0.82, 1.0)
	style_card_active.border_color = Color(0.88, 0.48, 0.12, 1.0)
	style_card_active.set_border_width_all(2)
	style_card_active.border_width_bottom = 3
	style_card_active.shadow_color = Color(0.88, 0.48, 0.12, 0.25)
	style_card_active.shadow_size = 4
	style_card_active.set_corner_radius_all(10)
	style_card_active.content_margin_left = 8
	style_card_active.content_margin_right = 8
	style_card_active.content_margin_top = 6
	style_card_active.content_margin_bottom = 6

	style_tab_active = StyleBoxFlat.new()
	style_tab_active.bg_color = Color(1.0, 0.96, 0.90, 1.0)
	style_tab_active.border_color = Color(0.88, 0.48, 0.12, 1.0)
	style_tab_active.set_border_width_all(2)
	style_tab_active.border_width_bottom = 3
	style_tab_active.set_corner_radius_all(12)
	style_tab_active.content_margin_left = 12
	style_tab_active.content_margin_right = 12
	style_tab_active.content_margin_top = 6
	style_tab_active.content_margin_bottom = 6

	style_tab_inactive = StyleBoxFlat.new()
	style_tab_inactive.bg_color = Color(0.94, 0.90, 0.85, 1.0)
	style_tab_inactive.border_color = Color(0.82, 0.75, 0.68, 1.0)
	style_tab_inactive.set_border_width_all(1)
	style_tab_inactive.border_width_bottom = 2
	style_tab_inactive.set_corner_radius_all(12)
	style_tab_inactive.content_margin_left = 12
	style_tab_inactive.content_margin_right = 12
	style_tab_inactive.content_margin_top = 6
	style_tab_inactive.content_margin_bottom = 6

func _switch_tab(tab: String) -> void:
	current_tab = tab
	if current_tab == "avatars":
		btn_tab_avatars.add_theme_stylebox_override("normal", style_tab_active)
		btn_tab_avatars.add_theme_stylebox_override("hover", style_tab_active)
		btn_tab_avatars.add_theme_stylebox_override("pressed", style_tab_active)
		btn_tab_avatars.add_theme_color_override("font_color", Color(0.85, 0.45, 0.10))
		btn_tab_frames.add_theme_stylebox_override("normal", style_tab_inactive)
		btn_tab_frames.add_theme_stylebox_override("hover", style_tab_inactive)
		btn_tab_frames.add_theme_stylebox_override("pressed", style_tab_inactive)
		btn_tab_frames.add_theme_color_override("font_color", Color(0.50, 0.40, 0.32))
		_build_avatar_grid()
	else:
		btn_tab_avatars.add_theme_stylebox_override("normal", style_tab_inactive)
		btn_tab_avatars.add_theme_stylebox_override("hover", style_tab_inactive)
		btn_tab_avatars.add_theme_stylebox_override("pressed", style_tab_inactive)
		btn_tab_avatars.add_theme_color_override("font_color", Color(0.50, 0.40, 0.32))
		btn_tab_frames.add_theme_stylebox_override("normal", style_tab_active)
		btn_tab_frames.add_theme_stylebox_override("hover", style_tab_active)
		btn_tab_frames.add_theme_stylebox_override("pressed", style_tab_active)
		btn_tab_frames.add_theme_color_override("font_color", Color(0.85, 0.45, 0.10))
		_build_frame_grid()

func _build_avatar_grid() -> void:
	for c in grid_container.get_children():
		c.queue_free()
	item_buttons.clear()
	
	for i in range(GameManager.avatar_list.size()):
		var av_data = GameManager.avatar_list[i]
		var av_card = Button.new()
		av_card.custom_minimum_size = Vector2(210, 72)
		av_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		av_card.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		# Styles
		av_card.add_theme_stylebox_override("normal", style_card_normal)
		av_card.add_theme_stylebox_override("hover", style_card_hover)
		av_card.add_theme_stylebox_override("pressed", style_card_active)
		
		# HBox inside button
		var hbox = HBoxContainer.new()
		hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		hbox.add_theme_constant_override("separation", 8)
		av_card.add_child(hbox)
		
		# Avatar image
		var tex_rect = TextureRect.new()
		tex_rect.custom_minimum_size = Vector2(48, 56)
		tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.texture = GameManager.load_texture("res://assets/sprites/avatars/framed_avatar_%d.png" % i)
		hbox.add_child(tex_rect)
		
		# Text vbox
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 2)
		hbox.add_child(vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = av_data["name"]
		name_lbl.add_theme_font_size_override("font_size", 12)
		name_lbl.add_theme_color_override("font_color", Color(0.24, 0.16, 0.10))
		vbox.add_child(name_lbl)
		
		var desc_lbl = Label.new()
		desc_lbl.text = av_data["desc"]
		desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_lbl.add_theme_font_size_override("font_size", 9)
		desc_lbl.add_theme_color_override("font_color", Color(0.48, 0.38, 0.30))
		vbox.add_child(desc_lbl)
		
		var status_lbl = Label.new()
		status_lbl.name = "StatusLabel"
		status_lbl.add_theme_font_size_override("font_size", 9)
		if i == GameManager.selected_avatar_id:
			status_lbl.text = "✓ Đang chọn"
			status_lbl.add_theme_color_override("font_color", Color(0.12, 0.65, 0.25))
		else:
			status_lbl.text = ""
		vbox.add_child(status_lbl)
		
		var av_id = i
		av_card.pressed.connect(func(): _on_avatar_chosen(av_id))
		grid_container.add_child(av_card)
		item_buttons.append(av_card)
		
	_highlight_current()

func _build_frame_grid() -> void:
	for c in grid_container.get_children():
		c.queue_free()
	item_buttons.clear()
	
	for frame in GameManager.available_avatar_frames:
		var frame_card = Button.new()
		frame_card.custom_minimum_size = Vector2(210, 72)
		frame_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		frame_card.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		# Styles
		frame_card.add_theme_stylebox_override("normal", style_card_normal)
		frame_card.add_theme_stylebox_override("hover", style_card_hover)
		frame_card.add_theme_stylebox_override("pressed", style_card_active)
		
		var hbox = HBoxContainer.new()
		hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		hbox.add_theme_constant_override("separation", 10)
		frame_card.add_child(hbox)
		
		# Composite preview: Frame + Current Cat Avatar inside
		var preview_box = Control.new()
		preview_box.custom_minimum_size = Vector2(50, 50)
		preview_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		var frame_tex = TextureRect.new()
		frame_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		frame_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
		frame_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		frame_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		frame_tex.texture = GameManager.load_texture(frame["path"])
		preview_box.add_child(frame_tex)
		
		var cat_tex = TextureRect.new()
		cat_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		cat_tex.custom_minimum_size = Vector2(34, 34)
		cat_tex.set_anchors_preset(Control.PRESET_CENTER)
		cat_tex.position = Vector2(8, 8)
		cat_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cat_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var current_cat_path = "res://assets/sprites/avatars/avatar_%d.png" % GameManager.selected_avatar_id
		cat_tex.texture = GameManager.load_texture(current_cat_path)
		preview_box.add_child(cat_tex)
		hbox.add_child(preview_box)
		
		# Text vbox
		var vbox = VBoxContainer.new()
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 2)
		hbox.add_child(vbox)
		
		var name_lbl = Label.new()
		name_lbl.text = frame["name"]
		name_lbl.add_theme_font_size_override("font_size", 12)
		name_lbl.add_theme_color_override("font_color", Color(0.24, 0.16, 0.10))
		vbox.add_child(name_lbl)
		
		var status_lbl = Label.new()
		status_lbl.name = "StatusLabel"
		if frame["id"] == GameManager.selected_avatar_frame:
			status_lbl.text = "✓ Đang áp dụng"
			status_lbl.add_theme_color_override("font_color", Color(0.12, 0.65, 0.25))
		else:
			status_lbl.text = "Chạm để áp dụng"
			status_lbl.add_theme_color_override("font_color", Color(0.50, 0.40, 0.32))
		status_lbl.add_theme_font_size_override("font_size", 9)
		vbox.add_child(status_lbl)
		
		var fid = frame["id"]
		frame_card.pressed.connect(func(): _on_frame_chosen(fid))
		grid_container.add_child(frame_card)
		item_buttons.append(frame_card)
		
	_highlight_current()

func open() -> void:
	visible = true
	_switch_tab(current_tab)
	panel.scale = Vector2(0.85, 0.85)
	panel.pivot_offset = panel.size * 0.5
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func close() -> void:
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2(0.85, 0.85), 0.1)
	tween.finished.connect(func(): visible = false)

func _highlight_current() -> void:
	if current_tab == "avatars":
		for i in range(item_buttons.size()):
			var btn = item_buttons[i]
			var status_lbl = btn.get_node_or_null("HBox/VBox/StatusLabel")
			if i == GameManager.selected_avatar_id:
				btn.add_theme_stylebox_override("normal", style_card_active)
				btn.add_theme_stylebox_override("hover", style_card_active)
				btn.add_theme_stylebox_override("pressed", style_card_active)
				if status_lbl:
					status_lbl.text = "✓ Đang chọn"
					status_lbl.add_theme_color_override("font_color", Color(0.12, 0.65, 0.25))
			else:
				btn.add_theme_stylebox_override("normal", style_card_normal)
				btn.add_theme_stylebox_override("hover", style_card_hover)
				btn.add_theme_stylebox_override("pressed", style_card_active)
				if status_lbl:
					status_lbl.text = ""
	else:
		for i in range(GameManager.available_avatar_frames.size()):
			if i < item_buttons.size():
				var frame_info = GameManager.available_avatar_frames[i]
				var btn = item_buttons[i]
				var status_lbl = btn.get_node_or_null("HBox/VBox/StatusLabel")
				if frame_info["id"] == GameManager.selected_avatar_frame:
					btn.add_theme_stylebox_override("normal", style_card_active)
					btn.add_theme_stylebox_override("hover", style_card_active)
					btn.add_theme_stylebox_override("pressed", style_card_active)
					if status_lbl:
						status_lbl.text = "✓ Đang áp dụng"
						status_lbl.add_theme_color_override("font_color", Color(0.12, 0.65, 0.25))
				else:
					btn.add_theme_stylebox_override("normal", style_card_normal)
					btn.add_theme_stylebox_override("hover", style_card_hover)
					btn.add_theme_stylebox_override("pressed", style_card_active)
					if status_lbl:
						status_lbl.text = "Chạm để áp dụng"
						status_lbl.add_theme_color_override("font_color", Color(0.50, 0.40, 0.32))

func _on_avatar_chosen(av_id: int) -> void:
	GameManager.set_avatar(av_id)
	SoundManager.play_purr()
	GameManager.emit_signal("show_toast", "🐾 Đã đổi skin mèo: %s!" % GameManager.get_cat_name())
	emit_signal("avatar_selected", av_id)
	_highlight_current()

func _on_frame_chosen(frame_id: String) -> void:
	GameManager.set_avatar_frame(frame_id)
	SoundManager.play_click()
	GameManager.emit_signal("show_toast", "🖼️ Đã đổi khung avatar mới!")
	emit_signal("frame_selected", frame_id)
	_switch_tab("frames")

