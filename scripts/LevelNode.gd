extends Control

# LevelNode.gd - Nút Level 3D phong cách Duolingo / Candy Crush
# Hỗ trợ 3 trạng thái: Đã hoàn thành (3 sao vàng), Đang học (Pulsing glow + Chú Mèo ngồi), Bị khóa (Đá xám + Ổ khóa)

signal node_clicked(lesson_id)

@export var lesson_id: int = 1

var status: String = "locked" # "completed", "active", "locked"
var lesson_data: Dictionary = {}
var has_cat_avatar: bool = false
var avatar_id: int = 0

var btn_node: Button
var shadow_rect: Control
var node_content: VBoxContainer
var num_label: Label
var status_icon: TextureRect
var stars_container: HBoxContainer
var name_badge: PanelContainer
var name_label: Label
var pulse_tween: Tween

const NODE_SIZE = Vector2(74, 74)

# Bảng màu chủ đạo cho 4 nhánh kỹ năng
const BRANCH_COLORS = {
	1: {"main": Color(0.25, 0.65, 0.95), "bevel": Color(0.12, 0.45, 0.75), "glow": Color(0.2, 0.7, 1.0, 0.4)}, # Đi Lại (Sky Blue)
	2: {"main": Color(0.95, 0.45, 0.35), "bevel": Color(0.75, 0.25, 0.15), "glow": Color(1.0, 0.4, 0.3, 0.4)}, # Nơi Ở (Terracotta)
	3: {"main": Color(0.18, 0.75, 0.55), "bevel": Color(0.10, 0.55, 0.38), "glow": Color(0.2, 0.8, 0.6, 0.4)}, # Y Tế (Mint)
	4: {"main": Color(0.95, 0.65, 0.15), "bevel": Color(0.75, 0.45, 0.08), "glow": Color(1.0, 0.7, 0.1, 0.4)}, # Tài Chính (Gold)
}

func _ready() -> void:
	custom_minimum_size = Vector2(120, 110)
	size = custom_minimum_size
	pivot_offset = size / 2.0
	_build_ui()
	_update_visuals()

func setup(p_lesson_id: int, p_data: Dictionary, p_status: String, p_has_cat: bool, p_avatar_id: int = 0) -> void:
	lesson_id = p_lesson_id
	lesson_data = p_data
	status = p_status
	has_cat_avatar = p_has_cat
	avatar_id = p_avatar_id
	_update_visuals()

func _build_ui() -> void:
	# 1. Bóng đổ dưới nền
	shadow_rect = Control.new()
	shadow_rect.custom_minimum_size = Vector2(68, 22)
	shadow_rect.position = Vector2((size.x - 68) / 2.0, size.y - 36)
	shadow_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shadow_rect)
	
	# 2. Nút bấm chính hình tròn 3D
	btn_node = Button.new()
	btn_node.custom_minimum_size = NODE_SIZE
	btn_node.size = NODE_SIZE
	btn_node.position = Vector2((size.x - NODE_SIZE.x) / 2.0, 14)
	btn_node.pivot_offset = NODE_SIZE / 2.0
	btn_node.focus_mode = Control.FOCUS_NONE
	btn_node.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_node.pressed.connect(_on_button_pressed)
	add_child(btn_node)
	
	# Khung chứa nội dung bên trong nút bấm (Số bài + Icon trạng thái UI)
	node_content = VBoxContainer.new()
	node_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	node_content.alignment = BoxContainer.ALIGNMENT_CENTER
	node_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node_content.add_theme_constant_override("separation", 1)
	btn_node.add_child(node_content)
	
	num_label = Label.new()
	num_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	num_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	num_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node_content.add_child(num_label)
	
	status_icon = TextureRect.new()
	status_icon.custom_minimum_size = Vector2(18, 18)
	status_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	status_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	status_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	status_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	status_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node_content.add_child(status_icon)
	
	# 3. Cụm 3 Ngôi Sao (hiển thị khi hoàn thành)
	stars_container = HBoxContainer.new()
	stars_container.custom_minimum_size = Vector2(60, 20)
	stars_container.position = Vector2((size.x - 60) / 2.0, 0)
	stars_container.alignment = BoxContainer.ALIGNMENT_CENTER
	stars_container.add_theme_constant_override("separation", 2)
	stars_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stars_container)
	
	for i in range(3):
		var star_lbl = Label.new()
		star_lbl.text = "⭐"
		star_lbl.add_theme_font_size_override("font_size", 12)
		stars_container.add_child(star_lbl)
		
	# 4. Nhãn tên kỹ năng bên dưới nút
	name_badge = PanelContainer.new()
	name_badge.position = Vector2((size.x - 110) / 2.0, size.y - 20)
	name_badge.custom_minimum_size = Vector2(110, 22)
	name_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var badge_style = StyleBoxFlat.new()
	badge_style.bg_color = Color(0.98, 0.96, 0.92, 0.95)
	badge_style.border_color = Color(0.80, 0.72, 0.62, 1.0)
	badge_style.set_border_width_all(1)
	badge_style.set_corner_radius_all(10)
	badge_style.content_margin_left = 6
	badge_style.content_margin_right = 6
	badge_style.content_margin_top = 2
	badge_style.content_margin_bottom = 2
	name_badge.add_theme_stylebox_override("panel", badge_style)
	
	name_label = Label.new()
	name_label.text = "Bài %d" % lesson_id
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.add_theme_color_override("font_color", Color(0.35, 0.25, 0.18, 1.0))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_badge.add_child(name_label)
	add_child(name_badge)

func _update_visuals() -> void:
	if not btn_node:
		return
		
	var branch = lesson_data.get("branch", 1)
	var colors = BRANCH_COLORS.get(branch, BRANCH_COLORS[1])
	var title = lesson_data.get("title", "Bài %d" % lesson_id)
	name_label.text = title
	
	# Xóa tween cũ nếu có
	if pulse_tween and pulse_tween.is_valid():
		pulse_tween.kill()
	btn_node.scale = Vector2(1.0, 1.0)
		
	match status:
		"completed":
			stars_container.visible = true
			name_badge.visible = true
			
			# Nút màu vàng kim 3D hoàn thành
			var style = _create_3d_style(Color(1.0, 0.78, 0.22), Color(0.82, 0.55, 0.05), Color(1.0, 0.88, 0.45, 0.5))
			btn_node.add_theme_stylebox_override("normal", style)
			btn_node.add_theme_stylebox_override("hover", style)
			btn_node.add_theme_stylebox_override("pressed", style)
			
			btn_node.text = ""
			num_label.text = "%d" % lesson_id
			num_label.add_theme_font_size_override("font_size", 16)
			num_label.add_theme_color_override("font_color", Color(0.40, 0.22, 0.02))
			
			status_icon.visible = true
			status_icon.texture = preload("res://assets/UI/CatUIPaid/slices/icon_check.png")
			status_icon.modulate = Color(0.40, 0.22, 0.02)
			
		"active":
			stars_container.visible = false
			name_badge.visible = true
			
			# Nút màu sáng rực rỡ (theo theme nhánh) kèm viền dày
			var style = _create_3d_style(colors["main"], colors["bevel"], colors["glow"], 6)
			btn_node.add_theme_stylebox_override("normal", style)
			btn_node.add_theme_stylebox_override("hover", style)
			btn_node.add_theme_stylebox_override("pressed", style)
			
			btn_node.text = ""
			num_label.text = "%d" % lesson_id
			num_label.add_theme_font_size_override("font_size", 16)
			num_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
			
			status_icon.visible = true
			status_icon.texture = preload("res://assets/UI/CatUIPaid/slices/btn_paw_sq_cream.png")
			status_icon.modulate = Color(1.0, 1.0, 1.0)
			
			# Hiệu ứng nhịp đập nhẹ nhàng cho nút đang học
			pulse_tween = create_tween().set_loops()
			pulse_tween.tween_property(btn_node, "scale", Vector2(1.06, 1.06), 0.5).set_trans(Tween.TRANS_SINE)
			pulse_tween.tween_property(btn_node, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_SINE)
			
		"locked":
			stars_container.visible = false
			name_badge.visible = true
			
			# Nút đá xám có ổ khóa
			var style = _create_3d_style(Color(0.75, 0.72, 0.68), Color(0.55, 0.52, 0.48), Color(0, 0, 0, 0.1), 4)
			btn_node.add_theme_stylebox_override("normal", style)
			btn_node.add_theme_stylebox_override("hover", style)
			btn_node.add_theme_stylebox_override("pressed", style)
			
			btn_node.text = ""
			num_label.text = "%02d\n🔒" % lesson_id
			num_label.add_theme_font_size_override("font_size", 13)
			num_label.add_theme_color_override("font_color", Color(0.45, 0.42, 0.38))
			status_icon.visible = false

func _create_3d_style(main_color: Color, bevel_color: Color, shadow_col: Color, bevel_height: int = 5) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = main_color
	s.border_color = bevel_color
	s.border_width_left = 2
	s.border_width_right = 2
	s.border_width_top = 2
	s.border_width_bottom = 2 + bevel_height
	s.set_corner_radius_all(37) # Nút tròn 74x74
	s.shadow_color = shadow_col
	s.shadow_size = 6
	s.shadow_offset = Vector2(0, 3)
	return s

func _on_button_pressed() -> void:
	# Hiệu ứng nhấn nút nảy 3D thật tay
	var tw = create_tween()
	tw.tween_property(btn_node, "scale", Vector2(0.88, 0.88), 0.06).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(btn_node, "scale", Vector2(1.0, 1.0), 0.08).set_trans(Tween.TRANS_BACK)
	
	if status == "locked":
		SoundManager.play_fail()
	else:
		SoundManager.play_card_pop()
		
	emit_signal("node_clicked", lesson_id)
