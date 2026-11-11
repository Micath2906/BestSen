extends Control

# SkillTree.gd - Bản đồ Kỹ Năng Sống Sinh Viên phong cách Candy Crush / Duolingo
# Hành trình uốn lượn S-Curve với nút Level 3D, Chú Mèo Chibi đứng trên màn đang học,
# 4 Trạm Kỹ Năng, Hòm Rương Cứu Trợ Milestones, và Modal Xem Trước Màn Chơi (Level Preview)

signal open_lesson(lesson_id)
signal back_to_room
signal open_museum_requested
signal open_category_requested(category_id)

const AchievementModalScene = preload("res://scenes/AchievementModal.tscn")
var achievement_modal: Control = null
var btn_view_category: Button = null

@onready var btn_back: Button = get_node_or_null("BtnBack") if has_node("BtnBack") else get_node_or_null("HeaderContainer/BtnBack")
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var roadmap_content: Control = $ScrollContainer/RoadmapContent
@onready var path_canvas: Control = $ScrollContainer/RoadmapContent/PathCanvas

# Nút Filter / Nhảy Trạm
@onready var tab_branch1: Button = $FilterBar/BtnBranch1
@onready var tab_branch2: Button = $FilterBar/BtnBranch2
@onready var tab_branch3: Button = $FilterBar/BtnBranch3
@onready var tab_branch4: Button = $FilterBar/BtnBranch4

# Banner Cấp Độ Mèo (Cat Mastery)
@onready var mastery_title: Label = $MasteryBanner/HBox/VBox/MasteryTitle
@onready var mastery_bar: ProgressBar = $MasteryBanner/HBox/VBox/ExpHBox/MasteryProgressBar
@onready var mastery_exp_lbl: Label = $MasteryBanner/HBox/VBox/ExpHBox/MasteryExpLabel
@onready var btn_level_reqs: Button = $MasteryBanner/HBox.get_node_or_null("BtnBox/BtnLevelReqs") if $MasteryBanner/HBox.has_node("BtnBox/BtnLevelReqs") else $MasteryBanner/HBox.get_node_or_null("BtnLevelReqs")
@onready var btn_achievements: Button = $MasteryBanner/HBox.get_node_or_null("BtnBox/BtnAchievements") if $MasteryBanner/HBox.has_node("BtnBox/BtnAchievements") else $MasteryBanner/HBox.get_node_or_null("BtnAchievements")
@onready var btn_preview_puzzle: Button = $LevelPreviewModal/ModalPanel/VBox/RewardBox/HBox.get_node_or_null("BtnPreviewPuzzle")

# Modal Điều Kiện Lên Cấp
@onready var level_info_modal: Control = $LevelInfoModal
@onready var level_list_container: VBoxContainer = $LevelInfoModal/ModalPanel/VBox/Scroll/LevelList
@onready var btn_close_modal: Button = $LevelInfoModal/ModalPanel/VBox/BtnCloseModal

# Modal Xem Trước Màn Chơi (Level Preview Popup - Candy Crush / Duolingo)
@onready var level_preview_modal: Control = $LevelPreviewModal
@onready var preview_title_lbl: Label = $LevelPreviewModal/ModalPanel/VBox/TitleLabel
@onready var preview_branch_lbl: Label = $LevelPreviewModal/ModalPanel/VBox/BranchLabel
@onready var preview_stars_lbl: Label = $LevelPreviewModal/ModalPanel/VBox/StarsLabel
@onready var preview_context_lbl: Label = $LevelPreviewModal/ModalPanel/VBox/ContextBox.get_node_or_null("HBox/ContextLabel") if $LevelPreviewModal/ModalPanel/VBox/ContextBox.has_node("HBox/ContextLabel") else $LevelPreviewModal/ModalPanel/VBox/ContextBox/ContextLabel
@onready var preview_image: TextureRect = $LevelPreviewModal/ModalPanel/VBox/ContextBox.get_node_or_null("HBox/PreviewImage")
@onready var preview_reward_fish: Label = $LevelPreviewModal/ModalPanel/VBox/RewardBox/HBox/FishLabel
@onready var preview_reward_loot: Label = $LevelPreviewModal/ModalPanel/VBox/RewardBox/HBox/LootLabel
@onready var preview_status_lbl: Label = $LevelPreviewModal/ModalPanel/VBox/StatusLabel
@onready var btn_start_lesson: Button = $LevelPreviewModal/ModalPanel/VBox/BtnStartLesson
@onready var btn_close_preview: Button = $LevelPreviewModal/ModalPanel/VBox/BtnClosePreview

var level_node_scene = preload("res://scenes/LevelNode.tscn")
var current_filter: int = 0
var selected_lesson_id: int = 1
var active_lesson_id: int = 1
var node_positions: Dictionary = {}
var chapter_y_positions: Dictionary = {1: 20, 2: 580, 3: 1140, 4: 1700}

# Danh sách tọa độ uốn lượn S-Curve cho 16 màn chơi (Duolingo / Candy Crush Path)
const LEVEL_COORDS = {
	# TRẠM 1: BẾN XE & ĐƯỜNG PHỐ (Uốn sang phải)
	1: Vector2(194, 95),
	2: Vector2(309, 205),
	3: Vector2(344, 315),
	4: Vector2(264, 425),
	# TRẠM 2: BÌNH YÊN XÓM TRỌ (Uốn sang trái)
	5: Vector2(194, 655),
	6: Vector2(144, 765),
	7: Vector2(124, 875),
	8: Vector2(224, 985),
	# TRẠM 3: THÂN THỂ KIM CƯƠNG (Uốn sang phải)
	9: Vector2(194, 1215),
	10: Vector2(309, 1325),
	11: Vector2(344, 1435),
	12: Vector2(264, 1545),
	# TRẠM 4: TÚI TIỀN THÔNG THÁI (Uốn sang trái)
	13: Vector2(194, 1775),
	14: Vector2(144, 1885),
	15: Vector2(124, 1995),
	16: Vector2(224, 2105),
}

const CHEST_COORDS = {
	1: Vector2(194, 510),
	2: Vector2(194, 1070),
	3: Vector2(194, 1630),
	4: Vector2(194, 2195), # Trophy Tốt Nghiệp
}

func _ready() -> void:
	if btn_back:
		var back_style = StyleBoxFlat.new()
		back_style.bg_color = Color(0.96, 0.93, 0.89, 1.0)
		back_style.border_color = Color(0.82, 0.74, 0.66, 1.0)
		back_style.set_border_width_all(2)
		back_style.border_width_bottom = 3
		back_style.set_corner_radius_all(12)
		back_style.content_margin_left = 10
		back_style.content_margin_right = 10
		back_style.content_margin_top = 4
		back_style.content_margin_bottom = 4
		btn_back.add_theme_stylebox_override("normal", back_style)
		btn_back.add_theme_stylebox_override("hover", back_style)
		btn_back.add_theme_stylebox_override("pressed", back_style)
		btn_back.add_theme_color_override("font_color", Color(0.38, 0.26, 0.16, 1.0))
		btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
		btn_back.text = " Thoát"
		btn_back.pressed.connect(func():
			SoundManager.play_click()
			emit_signal("back_to_room")
		)

	# Kết nối bộ nút nhảy trạm
	tab_branch1.pressed.connect(func(): filter_branch(1))
	tab_branch2.pressed.connect(func(): filter_branch(2))
	tab_branch3.pressed.connect(func(): filter_branch(3))
	tab_branch4.pressed.connect(func(): filter_branch(4))
	
	# Khởi tạo Modal Thành Tựu & Puzzle Ghép Tranh
	achievement_modal = AchievementModalScene.instantiate()
	add_child(achievement_modal)
	achievement_modal.open_full_museum_requested.connect(func():
		emit_signal("open_museum_requested")
	)
	
	if btn_achievements:
		var achv_style = StyleBoxFlat.new()
		achv_style.bg_color = Color(1.0, 0.85, 0.35, 1.0)
		achv_style.border_color = Color(0.75, 0.45, 0.1, 1.0)
		achv_style.set_border_width_all(2)
		achv_style.border_width_bottom = 3
		achv_style.set_corner_radius_all(8)
		achv_style.content_margin_left = 6
		achv_style.content_margin_right = 6
		achv_style.content_margin_top = 2
		achv_style.content_margin_bottom = 2
		btn_achievements.add_theme_stylebox_override("normal", achv_style)
		btn_achievements.add_theme_stylebox_override("hover", achv_style)
		btn_achievements.add_theme_stylebox_override("pressed", achv_style)
		btn_achievements.add_theme_color_override("font_color", Color(0.35, 0.2, 0.05))
		btn_achievements.pressed.connect(func():
			SoundManager.play_click()
			if achievement_modal:
				achievement_modal.open()
		)
		
	if btn_preview_puzzle:
		var pz_style = StyleBoxFlat.new()
		pz_style.bg_color = Color(1.0, 0.94, 0.82, 1.0)
		pz_style.border_color = Color(0.85, 0.65, 0.3, 1.0)
		pz_style.set_border_width_all(1)
		pz_style.set_corner_radius_all(6)
		btn_preview_puzzle.add_theme_stylebox_override("normal", pz_style)
		btn_preview_puzzle.add_theme_color_override("font_color", Color(0.4, 0.25, 0.1))
		btn_preview_puzzle.pressed.connect(func():
			SoundManager.play_click()
			if achievement_modal:
				achievement_modal.open()
		)

	# Kết nối Modal Điều Kiện Lên Cấp
	btn_level_reqs.pressed.connect(_on_level_reqs_pressed)
	btn_close_modal.pressed.connect(func(): 
		SoundManager.play_click()
		level_info_modal.visible = false
	)
	level_info_modal.visible = false
	
	# Kết nối Modal Level Preview
	var close_style = StyleBoxFlat.new()
	close_style.bg_color = Color(0.93, 0.90, 0.86, 1.0)
	close_style.border_color = Color(0.78, 0.72, 0.65, 1.0)
	close_style.set_border_width_all(1)
	close_style.set_corner_radius_all(12)
	btn_close_preview.add_theme_stylebox_override("normal", close_style)
	btn_close_preview.add_theme_stylebox_override("hover", close_style)
	btn_close_preview.add_theme_stylebox_override("pressed", close_style)
	btn_close_preview.add_theme_color_override("font_color", Color(0.35, 0.28, 0.20, 1.0))
	btn_close_preview.pressed.connect(func():
		SoundManager.play_click()
		level_preview_modal.visible = false
	)
	btn_start_lesson.pressed.connect(_on_start_lesson_pressed)
	
	# Tạo nút Mở Danh Mục Riêng trong Level Preview Modal
	var preview_vbox = $LevelPreviewModal/ModalPanel/VBox
	btn_view_category = Button.new()
	btn_view_category.name = "BtnViewCategory"
	btn_view_category.custom_minimum_size = Vector2(0, 38)
	btn_view_category.text = "📂 VÀO DANH MỤC KỸ NĂNG RIÊNG"
	btn_view_category.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_view_category.add_theme_font_size_override("font_size", 12)
	
	var cat_btn_style = StyleBoxFlat.new()
	cat_btn_style.bg_color = Color(0.96, 0.94, 0.90, 1.0)
	cat_btn_style.border_color = Color(0.80, 0.72, 0.62, 1.0)
	cat_btn_style.set_border_width_all(2)
	cat_btn_style.border_width_bottom = 3
	cat_btn_style.set_corner_radius_all(12)
	cat_btn_style.content_margin_top = 4
	cat_btn_style.content_margin_bottom = 4
	btn_view_category.add_theme_stylebox_override("normal", cat_btn_style)
	btn_view_category.add_theme_stylebox_override("hover", cat_btn_style)
	btn_view_category.add_theme_stylebox_override("pressed", cat_btn_style)
	btn_view_category.add_theme_color_override("font_color", Color(0.35, 0.25, 0.15))
	
	var start_idx = btn_start_lesson.get_index()
	preview_vbox.add_child(btn_view_category)
	preview_vbox.move_child(btn_view_category, start_idx + 1)
	
	btn_view_category.pressed.connect(func():
		var lesson = GameManager.lessons_data.get(selected_lesson_id, {})
		var b_id = lesson.get("branch", 1)
		level_preview_modal.visible = false
		SoundManager.play_click()
		emit_signal("open_category_requested", b_id)
	)
	
	level_preview_modal.visible = false
	
	# Làm cho các Banner Trạm có thể bấm để mở Scene Danh Mục tương ứng
	for b in range(1, 5):
		var banner = roadmap_content.get_node_or_null("BannerBranch%d" % b)
		if banner:
			banner.mouse_filter = Control.MOUSE_FILTER_STOP
			banner.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var branch_id = b
			banner.gui_input.connect(func(event):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					SoundManager.play_click()
					emit_signal("open_category_requested", branch_id)
			)
	
	# Đăng ký sự kiện vẽ đường mòn
	path_canvas.draw.connect(_on_path_canvas_draw)
	
	GameManager.lesson_completed.connect(func(_id): refresh_list())
	_populate_level_modal()
	_style_filter_buttons()
	refresh_list()
	
	# Tự động cuộn đến màn chơi hiện tại sau khi nạp xong
	await get_tree().process_frame
	_scroll_to_active_level()

func _style_filter_buttons() -> void:
	var tabs = [
		{"btn": tab_branch1, "color": Color(0.88, 0.94, 1.0), "border": Color(0.55, 0.75, 0.95), "text": Color(0.12, 0.45, 0.80)},
		{"btn": tab_branch2, "color": Color(1.0, 0.92, 0.90), "border": Color(0.95, 0.65, 0.55), "text": Color(0.80, 0.30, 0.15)},
		{"btn": tab_branch3, "color": Color(0.88, 0.96, 0.92), "border": Color(0.55, 0.85, 0.70), "text": Color(0.10, 0.55, 0.38)},
		{"btn": tab_branch4, "color": Color(1.0, 0.95, 0.88), "border": Color(0.95, 0.75, 0.35), "text": Color(0.85, 0.45, 0.08)},
	]
	for item in tabs:
		var b: Button = item["btn"]
		var style = StyleBoxFlat.new()
		style.bg_color = item["color"]
		style.border_color = item["border"]
		style.set_border_width_all(2)
		style.border_width_bottom = 3
		style.set_corner_radius_all(10)
		style.content_margin_left = 6
		style.content_margin_right = 6
		style.content_margin_top = 4
		style.content_margin_bottom = 4
		b.add_theme_stylebox_override("normal", style)
		b.add_theme_stylebox_override("hover", style)
		b.add_theme_stylebox_override("pressed", style)
		b.add_theme_color_override("font_color", item["text"])
		b.add_theme_color_override("font_hover_color", item["text"])

func _on_level_reqs_pressed() -> void:
	SoundManager.play_click()
	level_info_modal.visible = true

func _populate_level_modal() -> void:
	for child in level_list_container.get_children():
		child.queue_free()
		
	var configs = GameManager.MASTERY_CONFIG
	for cfg in configs:
		var panel = PanelContainer.new()
		var p_style = StyleBoxFlat.new()
		p_style.content_margin_left = 12
		p_style.content_margin_top = 8
		p_style.content_margin_right = 12
		p_style.content_margin_bottom = 8
		p_style.set_corner_radius_all(10)
		
		var is_cur = (cfg["level"] == GameManager.cat_mastery_level)
		if is_cur:
			p_style.bg_color = Color(1.0, 0.95, 0.88, 1.0)
			p_style.border_color = Color(0.95, 0.55, 0.15, 1.0)
			p_style.set_border_width_all(2)
		else:
			p_style.bg_color = Color(0.96, 0.95, 0.94, 1.0)
			p_style.border_color = Color(0.85, 0.80, 0.75, 0.8)
			p_style.set_border_width_all(1)
		panel.add_theme_stylebox_override("panel", p_style)
		
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 4)
		
		var title_lbl = Label.new()
		title_lbl.text = "⭐ CẤP %d: %s%s" % [cfg["level"], cfg["title"], " (HIỆN TẠI)" if is_cur else ""]
		title_lbl.add_theme_font_size_override("font_size", 13)
		title_lbl.add_theme_color_override("font_color", Color(0.85, 0.35, 0.1) if is_cur else Color(0.35, 0.30, 0.25))
		
		var req_lbl = Label.new()
		req_lbl.text = "🎯 Điều kiện: %s" % cfg["req_text"]
		req_lbl.add_theme_font_size_override("font_size", 11)
		req_lbl.add_theme_color_override("font_color", Color(0.45, 0.40, 0.35))
		
		var skill_lbl = Label.new()
		skill_lbl.text = "🔓 Quyền lợi: %s" % cfg["skills_unlocked"]
		skill_lbl.add_theme_font_size_override("font_size", 11)
		skill_lbl.add_theme_color_override("font_color", Color(0.18, 0.55, 0.32))
		
		vbox.add_child(title_lbl)
		vbox.add_child(req_lbl)
		vbox.add_child(skill_lbl)
		panel.add_child(vbox)
		level_list_container.add_child(panel)

func filter_branch(branch_id: int) -> void:
	SoundManager.play_click()
	current_filter = branch_id
	if branch_id == 0:
		_scroll_to_active_level()
	elif chapter_y_positions.has(branch_id):
		var target_y = chapter_y_positions[branch_id]
		var tw = create_tween()
		tw.tween_property(scroll_container, "scroll_vertical", target_y, 0.35).set_trans(Tween.TRANS_SINE)

func refresh_list() -> void:
	if btn_achievements:
		var cert_count = GameManager.claimed_certificates.size()
		btn_achievements.text = "🏆 THÀNH TỰU\n[%d/4 BỘ]" % cert_count
	
	# Cập nhật Banner Cấp Độ Mèo
	var cur_lvl = GameManager.cat_mastery_level
	var lvl_info = GameManager.get_mastery_info()
	mastery_title.text = "🌟 CẤP %d: %s" % [cur_lvl, lvl_info["title"].to_upper()]
	
	var min_exp = lvl_info["min_exp"]
	var max_exp = lvl_info["max_exp"]
	var cur_exp = GameManager.cat_mastery_exp
	
	if cur_lvl >= 5:
		mastery_bar.max_value = 100
		mastery_bar.value = 100
		mastery_exp_lbl.text = "Cực Đại (MAX)"
	else:
		var span = max_exp - min_exp
		var progress = clampi(cur_exp - min_exp, 0, span)
		mastery_bar.max_value = span
		mastery_bar.value = progress
		var pct = int((float(progress) / float(span)) * 100.0) if span > 0 else 100
		mastery_exp_lbl.text = "%d/%d EXP (%d%%)" % [cur_exp, max_exp, pct]

	# Xác định màn chơi hiện tại Boss cần học (Active Lesson)
	active_lesson_id = 1
	for id in range(1, 17):
		if not (id in GameManager.completed_lessons):
			var unl = GameManager.check_skill_unlock_status(id)
			if unl["is_unlocked"] or (id in GameManager.unlocked_lessons):
				active_lesson_id = id
				break

	# Xóa các LevelNode cũ trong RoadmapContent (giữ lại PathCanvas, Gateway và Chests)
	for child in roadmap_content.get_children():
		if child is Control and child.name.begins_with("LevelNode_"):
			child.queue_free()

	# Sinh 16 LevelNode trên bản đồ S-Curve
	for id in range(1, 17):
		var lesson = GameManager.lessons_data.get(id, {})
		var unlock_st = GameManager.check_skill_unlock_status(id)
		var is_done = id in GameManager.completed_lessons
		var is_unlocked = unlock_st["is_unlocked"] or (id in GameManager.unlocked_lessons)
		
		var st = "locked"
		if is_done:
			st = "completed"
		elif is_unlocked:
			st = "active"
			
		var is_boss_here = (id == active_lesson_id)
		
		var node = level_node_scene.instantiate()
		node.name = "LevelNode_%d" % id
		var pos = LEVEL_COORDS.get(id, Vector2(194, id * 110))
		node.position = pos
		roadmap_content.add_child(node)
		node.setup(id, lesson, st, is_boss_here, GameManager.selected_avatar_id)
		node.node_clicked.connect(_on_level_node_clicked)

	# Cập nhật trạng thái các Rương Cứu Trợ Milestones
	_update_milestone_chests()
	
	# Yêu cầu vẽ lại đường mòn uốn lượn
	path_canvas.queue_redraw()

func _update_milestone_chests() -> void:
	for branch in range(1, 5):
		var chest_node = roadmap_content.get_node_or_null("ChestBranch_%d" % branch)
		if chest_node:
			var all_done = true
			for l_id in range((branch - 1) * 4 + 1, branch * 4 + 1):
				if not (l_id in GameManager.completed_lessons):
					all_done = false
					break
			if all_done:
				chest_node.modulate = Color(1.0, 1.0, 1.0, 1.0)
				chest_node.text = "🎁 MỞ RƯƠNG TRẠM %d (HOÀN THÀNH!) ⭐" % branch if branch < 4 else "🏆 CÚP SEN TOÀN NĂNG ⭐"
			else:
				chest_node.modulate = Color(0.75, 0.75, 0.75, 0.85)
				chest_node.text = "🔒 Hòm Cứu Trợ Trạm %d" % branch if branch < 4 else "🔒 Cúp Thủ Khoa Tự Lập"

func _on_path_canvas_draw() -> void:
	# 1. Vẽ đường mòn uốn lượn hình chữ S kết nối 16 màn chơi và rương thưởng
	var points = []
	for id in range(1, 17):
		var node_pos = LEVEL_COORDS.get(id, Vector2.ZERO) + Vector2(60, 50)
		points.append(node_pos)
		
	# Vẽ các viên đá lát đường (Stepping Cobblestones) kết nối từng cặp màn chơi
	for i in range(points.size() - 1):
		var p1: Vector2 = points[i]
		var p2: Vector2 = points[i + 1]
		
		var l1 = i + 1
		var l2 = i + 2
		var is_p1_done = l1 in GameManager.completed_lessons
		var is_p2_unlocked = (l2 in GameManager.completed_lessons) or (l2 == active_lesson_id)
		
		var road_color = Color(0.95, 0.75, 0.25, 0.85) if (is_p1_done and is_p2_unlocked) else Color(0.80, 0.76, 0.70, 0.55)
		var shadow_col = Color(0.2, 0.15, 0.1, 0.12)
		
		# Vẽ 4 viên đá lát bước chân giữa 2 node
		var steps = 4
		for s in range(1, steps):
			var t = float(s) / float(steps)
			var interp_pos = p1.lerp(p2, t)
			# Uốn cong nhẹ tạo độ mềm mại cho cung đường
			var curve_offset = sin(t * PI) * 12.0 * (1.0 if p2.x > p1.x else -1.0)
			interp_pos.x += curve_offset
			
			# Bóng đổ viên đá
			path_canvas.draw_circle(interp_pos + Vector2(0, 3), 7.0, shadow_col)
			# Mặt viên đá
			path_canvas.draw_circle(interp_pos, 6.5, road_color)
			# Điểm nhấn viên đá
			path_canvas.draw_circle(interp_pos + Vector2(-1, -1), 2.0, Color(1, 1, 1, 0.4))

func _on_level_node_clicked(lesson_id: int) -> void:
	selected_lesson_id = lesson_id
	var lesson = GameManager.lessons_data.get(lesson_id, {})
	var unlock_st = GameManager.check_skill_unlock_status(lesson_id)
	var is_done = lesson_id in GameManager.completed_lessons
	var is_unlocked = unlock_st["is_unlocked"] or (lesson_id in GameManager.unlocked_lessons)
	
	# Điền thông tin vào Modal Level Preview
	var branch_names = {
		1: "🎒 TRẠM 1: HÀNH TRANG & ĐƯỜNG PHỐ",
		2: "🏠 TRẠM 2: BÌNH YÊN XÓM TRỌ",
		3: "🩺 TRẠM 3: THÂN THỂ KIM CƯƠNG",
		4: "💰 TRẠM 4: TÚI TIỀN THÔNG THÁI",
	}
	var b_id = lesson.get("branch", 1)
	preview_branch_lbl.text = branch_names.get(b_id, "KỸ NĂNG SỐNG")
	preview_title_lbl.text = "Bài %d: %s" % [lesson_id, lesson.get("title", "")]
	preview_context_lbl.text = lesson.get("context", "")
	if preview_image:
		var img_path = "res://assets/sprites/skills/lesson_%02d_step_1.png" % lesson_id
		if ResourceLoader.exists(img_path):
			preview_image.texture = load(img_path)
			preview_image.visible = true
		else:
			preview_image.visible = false
	preview_reward_fish.text = "💵 +%s" % GameManager.format_currency(lesson.get("reward_fish", 15))
	preview_reward_loot.text = "🎁 %s" % lesson.get("loot_name", "Chiến Lợi Phẩm")
	
	if is_done:
		preview_stars_lbl.text = "⭐⭐⭐ ĐÃ THÀNH THẠO! ⭐⭐⭐"
		preview_stars_lbl.add_theme_color_override("font_color", Color(0.95, 0.70, 0.10))
		preview_status_lbl.text = "🏆 Mèo đã nắm vững kỹ năng này. Bạn có thể ôn lại để nhận thêm tiền thưởng!"
		preview_status_lbl.add_theme_color_override("font_color", Color(0.25, 0.65, 0.35))
		btn_start_lesson.disabled = false
		btn_start_lesson.text = "🔄 ÔN TẬP KỸ NĂNG (+%s 💵)" % GameManager.format_currency(5)
		_style_start_button(true, Color(0.25, 0.70, 0.40))
	elif is_unlocked:
		preview_stars_lbl.text = "⭐ BÀI HỌC MỚI ĐANG MỞ ⭐"
		preview_stars_lbl.add_theme_color_override("font_color", Color(0.95, 0.50, 0.10))
		preview_status_lbl.text = "🐾 Boss đang hào hứng! Hãy dạy Boss qua chuỗi hành động kéo thả."
		preview_status_lbl.add_theme_color_override("font_color", Color(0.35, 0.30, 0.25))
		btn_start_lesson.disabled = false
		btn_start_lesson.text = "🚀 BẮT ĐẦU DẠY MÈO NGAY!"
		_style_start_button(true, Color(0.95, 0.55, 0.10))
	else:
		preview_stars_lbl.text = "🔒 CHƯA MỞ KHÓA"
		preview_stars_lbl.add_theme_color_override("font_color", Color(0.65, 0.60, 0.55))
		preview_status_lbl.text = "🔒 " + unlock_st.get("reason", "Cần hoàn thành bài học trước!")
		preview_status_lbl.add_theme_color_override("font_color", Color(0.85, 0.35, 0.15))
		btn_start_lesson.disabled = true
		btn_start_lesson.text = "🔒 CẦN MỞ KHÓA TRƯỚC"
		_style_start_button(false, Color(0.75, 0.72, 0.68))
		
	level_preview_modal.visible = true
	
	# Hiệu ứng nảy mở modal
	var panel = $LevelPreviewModal/ModalPanel
	panel.scale = Vector2(0.9, 0.9)
	var tw = create_tween()
	tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK)

func _style_start_button(is_enabled: bool, color: Color) -> void:
	var b_style = StyleBoxFlat.new()
	b_style.bg_color = color
	b_style.border_color = color.darkened(0.25)
	b_style.set_border_width_all(2)
	b_style.border_width_bottom = 5
	b_style.set_corner_radius_all(16)
	b_style.shadow_color = Color(0, 0, 0, 0.15)
	b_style.shadow_size = 6
	b_style.shadow_offset = Vector2(0, 3)
	btn_start_lesson.add_theme_stylebox_override("normal", b_style)
	btn_start_lesson.add_theme_stylebox_override("hover", b_style)
	btn_start_lesson.add_theme_stylebox_override("pressed", b_style)
	btn_start_lesson.add_theme_stylebox_override("disabled", b_style)

func _on_start_lesson_pressed() -> void:
	# Tắt âm thanh khi ấn chơi ngay
	level_preview_modal.visible = false
	_start_lesson(selected_lesson_id)

func _start_lesson(lesson_id: int) -> void:
	var check = GameManager.can_start_lesson()
	if not check["ok"]:
		GameManager.emit_signal("show_toast", check["reason"])
		SoundManager.play_fail()
		return
	emit_signal("open_lesson", lesson_id)

func _scroll_to_active_level() -> void:
	if LEVEL_COORDS.has(active_lesson_id):
		var node_y = LEVEL_COORDS[active_lesson_id].y
		# Căn giữa màn hình (viewport height ~ 600 trong vùng cuộn)
		var target_scroll = clampi(int(node_y - 250), 0, 2400)
		var tw = create_tween()
		tw.tween_property(scroll_container, "scroll_vertical", target_scroll, 0.45).set_trans(Tween.TRANS_SINE)

func _on_chest_clicked(branch_id: int) -> void:
	var all_done = true
	for l_id in range((branch_id - 1) * 4 + 1, branch_id * 4 + 1):
		if not (l_id in GameManager.completed_lessons):
			all_done = false
			break
			
	if all_done:
		SoundManager.play_success()
		GameManager.fish += 20
		GameManager.emit_signal("show_toast", "🎉 Bạn đã mở Rương Cứu Trợ Trạm %d! Nhận thêm +%s tiền thưởng! 💵" % [branch_id, GameManager.format_currency(20)])
		GameManager.emit_signal("stats_changed")
	else:
		SoundManager.play_fail()
		GameManager.emit_signal("show_toast", "🔒 Hãy hoàn thành cả 4 bài của Trạm %d để mở rương này nhé!" % branch_id)
