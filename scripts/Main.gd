extends Control

# Main.gd - Điều phối toàn bộ ứng dụng trên mọi thiết bị
# Tích hợp CatProfileHUD ở trên, BottomPawMenu tinh gọn ở dưới, và AvatarPickerModal

@onready var cat_profile_hud: Control = $CatProfileHUD
@onready var btn_handbook_quick: Button = $BtnHandbookQuick
@onready var bottom_paw_menu: Control = $BottomPawMenu
@onready var avatar_picker_modal: Control = $AvatarPickerModal
@onready var status_alert_modal: Control = $StatusAlertModal
@onready var pause_modal: Control = $PauseModal
@onready var views_container: Control = $ViewsContainer

@onready var toast_panel: PanelContainer = $ToastPanel
@onready var toast_label: Label = $ToastPanel/ToastLabel
@onready var toast_timer: Timer = $ToastTimer

var room_view_scene = preload("res://scenes/IsometricRoomView.tscn")
var skill_tree_scene = preload("res://scenes/SkillTree.tscn")
var lesson_view_scene = preload("res://scenes/LessonView.tscn")
var story_lesson_view_scene = preload("res://scenes/StoryLessonView.tscn")
var sim_view_scene = preload("res://scenes/SimulationView.tscn")
var handbook_view_scene = preload("res://scenes/HandbookView.tscn")
var museum_view_scene = preload("res://scenes/MuseumView.tscn")
var shop_view_scene = preload("res://scenes/ShopView.tscn")
var house_dress_view_scene = preload("res://scenes/HouseAndDressView.tscn")
var decor_studio_scene = preload("res://scenes/RoomDecorStudioView.tscn")

var category_scenes = {
	1: preload("res://scenes/categories/CategoryMobility.tscn"),
	2: preload("res://scenes/categories/CategoryHousingLegal.tscn"),
	3: preload("res://scenes/categories/CategoryHealthMedical.tscn"),
	4: preload("res://scenes/categories/CategoryFinanceCareer.tscn"),
}

var current_view_node: Control = null
var current_tab_name: String = "room"
var previous_tab_before_handbook: String = "room"
var current_lesson_id_active: int = 1
var back_press_count: int = 0
var back_press_timer: float = 0.0

func _ready() -> void:
	_apply_safe_area()
	get_viewport().size_changed.connect(_apply_safe_area)
	
	# Kết nối sự kiện toàn cục
	GameManager.show_toast.connect(_show_toast_message)
	GameManager.show_status_alert.connect(_on_show_status_alert)
	toast_timer.timeout.connect(func(): toast_panel.visible = false)
	toast_panel.visible = false
	
	# Kết nối HUD trên cùng (Click vào avatar để mở bảng chọn avatar, click Shop để mở Tiệm)
	cat_profile_hud.open_avatar_picker_requested.connect(_on_open_avatar_picker)
	cat_profile_hud.pause_requested.connect(func():
		if bottom_paw_menu:
			bottom_paw_menu.close_drawer()
		pause_modal.open()
	)
	if cat_profile_hud.has_signal("open_shop_requested"):
		cat_profile_hud.open_shop_requested.connect(func(): switch_to_shop("costumes"))
	
	# Kết nối nút Cẩm Nang nhanh ở góc trên bên trái dưới thanh thông tin
	btn_handbook_quick.pressed.connect(_on_handbook_quick_pressed)
	
	# Kết nối Menu tinh gọn dưới cùng
	bottom_paw_menu.go_home_requested.connect(switch_to_room)
	if bottom_paw_menu.has_signal("open_decor_studio_requested"):
		bottom_paw_menu.open_decor_studio_requested.connect(switch_to_decor_studio)
	bottom_paw_menu.open_skill_tree_requested.connect(switch_to_map)
	bottom_paw_menu.open_shop_requested.connect(switch_to_shop)
	bottom_paw_menu.open_handbook_requested.connect(switch_to_handbook)
	bottom_paw_menu.open_museum_requested.connect(switch_to_museum)
	if bottom_paw_menu.has_signal("start_lesson_requested"):
		bottom_paw_menu.start_lesson_requested.connect(start_lesson)
	bottom_paw_menu.action_food_selected.connect(_on_food_selected)
	bottom_paw_menu.action_play_selected.connect(_on_play_selected)
	bottom_paw_menu.action_drawer_opened.connect(func(_type):
		if current_tab_name != "room":
			switch_to_room()
		if current_view_node and current_view_node.has_node("YSortEntities/IsoCat"):
			var cat = current_view_node.get_node("YSortEntities/IsoCat")
			if cat.has_method("hide_dialogue"):
				cat.hide_dialogue()
	)
	
	switch_to_room()

func _process(delta: float) -> void:
	if back_press_timer > 0.0:
		back_press_timer -= delta
		if back_press_timer <= 0.0:
			back_press_count = 0

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_handle_back_press()

func _handle_back_press() -> void:
	if status_alert_modal and status_alert_modal.visible:
		status_alert_modal.close()
		return
	if avatar_picker_modal.visible:
		avatar_picker_modal.close()
		return
	if bottom_paw_menu.sub_drawer.visible:
		bottom_paw_menu.close_drawer()
		return
	if current_tab_name == "lesson" or current_tab_name == "sim":
		switch_to_map()
	elif current_tab_name != "room":
		switch_to_room()
	else:
		back_press_count += 1
		if back_press_count == 1:
			back_press_timer = 2.0
			_show_toast_message("Nhấn Back một lần nữa để thoát game.")
		elif back_press_count >= 2:
			get_tree().quit()

func _apply_safe_area() -> void:
	if OS.has_feature("mobile"):
		var safe_area = DisplayServer.get_display_safe_area()
		var screen_size = DisplayServer.screen_get_size()
		if screen_size.y > 0:
			# 1. Tránh tai thỏ / Dynamic Island trên đỉnh màn hình
			if safe_area.position.y > 0:
				var top_offset = float(safe_area.position.y) / float(screen_size.y) * 960.0
				cat_profile_hud.offset_top = top_offset
				views_container.offset_top = top_offset
				btn_handbook_quick.offset_top = 126.0 + top_offset
				btn_handbook_quick.offset_bottom = 162.0 + top_offset
			
			# 2. Tránh thanh cử chỉ vuốt Home Indicator ở cạnh dưới
			var bottom_inset = screen_size.y - (safe_area.position.y + safe_area.size.y)
			if bottom_inset > 0:
				var bottom_offset = float(bottom_inset) / float(screen_size.y) * 960.0
				bottom_paw_menu.offset_bottom = -bottom_offset

func _clear_current_view() -> void:
	if current_view_node and is_instance_valid(current_view_node):
		current_view_node.queue_free()
		current_view_node = null

func _on_handbook_quick_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(btn_handbook_quick, "scale", Vector2(0.92, 0.92), 0.08)
	tween.tween_property(btn_handbook_quick, "scale", Vector2(1.0, 1.0), 0.08)
	SoundManager.play_click()
	switch_to_handbook()

func switch_to_room() -> void:
	current_tab_name = "room"
	cat_profile_hud.visible = true
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = true
	bottom_paw_menu.set_view_mode("room")
	bottom_paw_menu.set_active_tab("room")
	_clear_current_view()
	current_view_node = room_view_scene.instantiate()
	views_container.add_child(current_view_node)
	current_view_node.open_skill_tree_requested.connect(switch_to_map)
	current_view_node.open_lesson_requested.connect(start_lesson)
	if current_view_node.has_signal("open_handbook_requested"):
		current_view_node.open_handbook_requested.connect(switch_to_handbook)
	if current_view_node.has_signal("open_dressing_room_requested"):
		current_view_node.open_dressing_room_requested.connect(func(): switch_to_house_dress("dress"))
	if current_view_node.has_signal("open_room_decor_requested"):
		current_view_node.open_room_decor_requested.connect(switch_to_decor_studio)

func switch_to_decor_studio() -> void:
	current_tab_name = "decor_studio"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	current_view_node = decor_studio_scene.instantiate()
	views_container.add_child(current_view_node)
	current_view_node.back_to_room_requested.connect(switch_to_room)

func _on_show_status_alert(alert_type: String) -> void:
	if bottom_paw_menu:
		bottom_paw_menu.close_drawer()
	if status_alert_modal:
		status_alert_modal.open(alert_type)

func switch_to_house_dress(initial_mode: String = "dress") -> void:
	current_tab_name = "house_dress"
	cat_profile_hud.visible = true
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = true
	_clear_current_view()
	current_view_node = house_dress_view_scene.instantiate()
	views_container.add_child(current_view_node)
	current_view_node.back_to_room_requested.connect(switch_to_room)
	current_view_node.open_shop_requested.connect(switch_to_shop)
	if current_view_node.has_method("switch_mode"):
		current_view_node.switch_mode(initial_mode)

func switch_to_map() -> void:
	current_tab_name = "map"
	cat_profile_hud.visible = true
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = true
	bottom_paw_menu.set_view_mode("skill_tree")
	_clear_current_view()
	current_view_node = skill_tree_scene.instantiate()
	views_container.add_child(current_view_node)
	current_view_node.open_lesson.connect(start_lesson)
	current_view_node.back_to_room.connect(switch_to_room)
	if current_view_node.has_signal("open_house_dress_requested"):
		current_view_node.open_house_dress_requested.connect(switch_to_house_dress)
	if current_view_node.has_signal("open_museum_requested"):
		current_view_node.open_museum_requested.connect(switch_to_museum)
	if current_view_node.has_signal("open_category_requested"):
		current_view_node.open_category_requested.connect(switch_to_category)

func switch_to_category(cat_id: int) -> void:
	if not category_scenes.has(cat_id):
		return
	current_tab_name = "category_%d" % cat_id
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	
	var cat_scene = category_scenes[cat_id]
	current_view_node = cat_scene.instantiate()
	views_container.add_child(current_view_node)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.switch_category_requested.connect(switch_to_category)
	current_view_node.minigame_completed.connect(func(sim_steps):
		pass
	)

func start_lesson(lesson_id: int) -> void:
	# Kiểm tra thể lực & tâm lý của Boss trước khi ra ngoài học kỹ năng
	var check = GameManager.can_start_lesson()
	if not check["ok"]:
		_show_toast_message(check["reason"])
		SoundManager.play_fail()
		return
		
	current_lesson_id_active = lesson_id
	if lesson_id == 1:
		_open_preparation_game(lesson_id)
		return
	if lesson_id == 2:
		_open_hospital_choice_game(lesson_id)
		return
	if lesson_id == 3:
		_open_self_diagnosis_game(lesson_id)
		return
	if lesson_id == 4:
		_open_traffic_safety_game(lesson_id)
		return
	if lesson_id == 5:
		_open_rental_contract_game(lesson_id)
		return
	if lesson_id == 7:
		_open_public_admin_game(lesson_id)
		return
	if lesson_id == 10:
		_open_bhyt_process_game(lesson_id)
		return
	if lesson_id == 14:
		_open_cyber_security_game(lesson_id)
		return
	if lesson_id == 15:
		_open_labor_rights_game(lesson_id)
		return
		
	var story = GameManager.get_story_by_lesson_id(lesson_id)
	if not story.is_empty():
		_open_story_lesson(story, lesson_id)
	else:
		_open_matching_lesson(lesson_id)

func _open_preparation_game(lesson_id: int) -> void:
	current_tab_name = "lesson_prep"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	var prep_scene = load("res://scenes/minigames/PreparationValiGame.tscn")
	current_view_node = prep_scene.instantiate()
	views_container.add_child(current_view_node)
	var mg_data = GameManager.get_minigame_data(lesson_id)
	current_view_node.load_minigame(mg_data)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.minigame_completed.connect(func(sim_steps):
		start_simulation(lesson_id, sim_steps, true)
	)

func _open_hospital_choice_game(lesson_id: int) -> void:
	current_tab_name = "lesson_hospital"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	var hosp_scene = load("res://scenes/minigames/HospitalChoiceGame.tscn")
	current_view_node = hosp_scene.instantiate()
	views_container.add_child(current_view_node)
	var mg_data = GameManager.get_minigame_data(lesson_id)
	current_view_node.load_minigame(mg_data)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.minigame_completed.connect(func(sim_steps):
		start_simulation(lesson_id, sim_steps, true)
	)

func _open_self_diagnosis_game(lesson_id: int) -> void:
	current_tab_name = "lesson_self_diag"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	var diag_scene = load("res://scenes/minigames/SelfDiagnosisGame.tscn")
	current_view_node = diag_scene.instantiate()
	views_container.add_child(current_view_node)
	var mg_data = GameManager.get_minigame_data(lesson_id)
	current_view_node.load_minigame(mg_data)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.minigame_completed.connect(func(sim_steps):
		start_simulation(lesson_id, sim_steps, true)
	)

func _open_traffic_safety_game(lesson_id: int) -> void:
	current_tab_name = "lesson_traffic_safety"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	var scn = load("res://scenes/minigames/TrafficSafetyGame.tscn")
	current_view_node = scn.instantiate()
	views_container.add_child(current_view_node)
	var mg_data = GameManager.get_minigame_data(lesson_id)
	current_view_node.load_minigame(mg_data)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.minigame_completed.connect(func(sim_steps):
		start_simulation(lesson_id, sim_steps, true)
	)

func _open_rental_contract_game(lesson_id: int) -> void:
	current_tab_name = "lesson_rental_contract"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	var scn = load("res://scenes/minigames/RentalContractGame.tscn")
	current_view_node = scn.instantiate()
	views_container.add_child(current_view_node)
	var mg_data = GameManager.get_minigame_data(lesson_id)
	current_view_node.load_minigame(mg_data)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.minigame_completed.connect(func(sim_steps):
		start_simulation(lesson_id, sim_steps, true)
	)

func _open_public_admin_game(lesson_id: int) -> void:
	current_tab_name = "lesson_public_admin"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	var scn = load("res://scenes/minigames/PublicAdminGame.tscn")
	current_view_node = scn.instantiate()
	views_container.add_child(current_view_node)
	var mg_data = GameManager.get_minigame_data(lesson_id)
	current_view_node.load_minigame(mg_data)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.minigame_completed.connect(func(sim_steps):
		start_simulation(lesson_id, sim_steps, true)
	)

func _open_bhyt_process_game(lesson_id: int) -> void:
	current_tab_name = "lesson_bhyt_process"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	var scn = load("res://scenes/minigames/HospitalBHYTProcessGame.tscn")
	current_view_node = scn.instantiate()
	views_container.add_child(current_view_node)
	var mg_data = GameManager.get_minigame_data(lesson_id)
	current_view_node.load_minigame(mg_data)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.minigame_completed.connect(func(sim_steps):
		start_simulation(lesson_id, sim_steps, true)
	)

func _open_cyber_security_game(lesson_id: int) -> void:
	current_tab_name = "lesson_cyber_security"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	var scn = load("res://scenes/minigames/CyberSecurityGame.tscn")
	current_view_node = scn.instantiate()
	views_container.add_child(current_view_node)
	var mg_data = GameManager.get_minigame_data(lesson_id)
	current_view_node.load_minigame(mg_data)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.minigame_completed.connect(func(sim_steps):
		start_simulation(lesson_id, sim_steps, true)
	)

func _open_labor_rights_game(lesson_id: int) -> void:
	current_tab_name = "lesson_labor_rights"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	var scn = load("res://scenes/minigames/LaborRightsGame.tscn")
	current_view_node = scn.instantiate()
	views_container.add_child(current_view_node)
	var mg_data = GameManager.get_minigame_data(lesson_id)
	current_view_node.load_minigame(mg_data)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.minigame_completed.connect(func(sim_steps):
		start_simulation(lesson_id, sim_steps, true)
	)

func _open_personal_finance_game(lesson_id: int) -> void:
	current_tab_name = "lesson_personal_finance"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	var scn = load("res://scenes/minigames/PersonalFinanceGame.tscn")
	current_view_node = scn.instantiate()
	views_container.add_child(current_view_node)
	var mg_data = GameManager.get_minigame_data(lesson_id)
	current_view_node.load_minigame(mg_data)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.minigame_completed.connect(func(sim_steps):
		start_simulation(lesson_id, sim_steps, true)
	)

func _open_time_management_game(lesson_id: int) -> void:
	current_tab_name = "lesson_time_management"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	var scn = load("res://scenes/minigames/TimeManagementGame.tscn")
	current_view_node = scn.instantiate()
	views_container.add_child(current_view_node)
	var mg_data = GameManager.get_minigame_data(lesson_id)
	current_view_node.load_minigame(mg_data)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.minigame_completed.connect(func(sim_steps):
		start_simulation(lesson_id, sim_steps, true)
	)

func _open_communication_conflict_game(lesson_id: int) -> void:
	current_tab_name = "lesson_communication_conflict"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	var scn = load("res://scenes/minigames/CommunicationConflictGame.tscn")
	current_view_node = scn.instantiate()
	views_container.add_child(current_view_node)
	var mg_data = GameManager.get_minigame_data(lesson_id)
	current_view_node.load_minigame(mg_data)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.minigame_completed.connect(func(sim_steps):
		start_simulation(lesson_id, sim_steps, true)
	)

func _open_self_care_living_game(lesson_id: int) -> void:
	current_tab_name = "lesson_self_care_living"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	var scn = load("res://scenes/minigames/SelfCareLivingGame.tscn")
	current_view_node = scn.instantiate()
	views_container.add_child(current_view_node)
	var mg_data = GameManager.get_minigame_data(lesson_id)
	current_view_node.load_minigame(mg_data)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.minigame_completed.connect(func(sim_steps):
		start_simulation(lesson_id, sim_steps, true)
	)

func _open_motorbike_maintenance_game(lesson_id: int) -> void:
	current_tab_name = "lesson_motorbike_maintenance"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	var scn = load("res://scenes/minigames/MotorbikeMaintenanceGame.tscn")
	current_view_node = scn.instantiate()
	views_container.add_child(current_view_node)
	var mg_data = GameManager.get_minigame_data(lesson_id)
	current_view_node.load_minigame(mg_data)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.minigame_completed.connect(func(sim_steps):
		start_simulation(lesson_id, sim_steps, true)
	)

func _open_story_lesson(story: Dictionary, lesson_id: int) -> void:
	current_tab_name = "lesson_story"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	current_view_node = story_lesson_view_scene.instantiate()
	views_container.add_child(current_view_node)
	current_view_node.load_story(story)
	current_view_node.back_requested.connect(switch_to_map)
	if current_view_node.has_signal("open_matching_mode_requested"):
		current_view_node.open_matching_mode_requested.connect(func():
			_open_matching_lesson(lesson_id)
		)
	if current_view_node.has_signal("open_handbook_requested"):
		current_view_node.open_handbook_requested.connect(func():
			switch_to_handbook_from_lesson()
		)

func _open_matching_lesson(lesson_id: int) -> void:
	current_tab_name = "lesson"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	current_view_node = lesson_view_scene.instantiate()
	views_container.add_child(current_view_node)
	current_view_node.load_lesson(lesson_id)
	current_view_node.back_requested.connect(switch_to_map)
	current_view_node.run_simulation_requested.connect(start_simulation)
	if current_view_node.has_signal("open_story_mode_requested"):
		current_view_node.open_story_mode_requested.connect(func():
			var story = GameManager.get_story_by_lesson_id(lesson_id)
			if not story.is_empty():
				_open_story_lesson(story, lesson_id)
		)
	if current_view_node.has_signal("open_handbook_requested"):
		current_view_node.open_handbook_requested.connect(func():
			switch_to_handbook_from_lesson()
		)

func switch_to_handbook_from_lesson() -> void:
	previous_tab_before_handbook = current_tab_name
	switch_to_handbook()

func start_simulation(lesson_id: int, sequence: Array, is_correct: bool) -> void:
	current_tab_name = "sim"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = false
	_clear_current_view()
	current_view_node = sim_view_scene.instantiate()
	views_container.add_child(current_view_node)
	current_view_node.start_simulation(lesson_id, sequence, is_correct)
	current_view_node.retry_lesson_requested.connect(start_lesson)
	current_view_node.continue_to_room_requested.connect(switch_to_room)

func switch_to_handbook() -> void:
	current_tab_name = "handbook"
	cat_profile_hud.visible = true
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = true
	bottom_paw_menu.set_view_mode("handbook")
	_clear_current_view()
	current_view_node = handbook_view_scene.instantiate()
	views_container.add_child(current_view_node)
	current_view_node.back_to_room.connect(func():
		if previous_tab_before_handbook == "lesson_story":
			var story = GameManager.get_story_by_lesson_id(current_lesson_id_active)
			if not story.is_empty():
				_open_story_lesson(story, current_lesson_id_active)
			else:
				switch_to_map()
			previous_tab_before_handbook = "room"
		elif previous_tab_before_handbook == "lesson":
			_open_matching_lesson(current_lesson_id_active)
			previous_tab_before_handbook = "room"
		else:
			switch_to_room()
	)
	if current_view_node.has_signal("open_house_dress_requested"):
		current_view_node.open_house_dress_requested.connect(switch_to_house_dress)
	if current_view_node.has_signal("open_museum_requested"):
		current_view_node.open_museum_requested.connect(switch_to_museum)

func switch_to_museum() -> void:
	current_tab_name = "museum"
	cat_profile_hud.visible = true
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = true
	bottom_paw_menu.set_active_tab("museum")
	_clear_current_view()
	current_view_node = museum_view_scene.instantiate()
	views_container.add_child(current_view_node)
	current_view_node.back_to_room.connect(switch_to_room)
	if current_view_node.has_signal("open_house_dress_requested"):
		current_view_node.open_house_dress_requested.connect(switch_to_house_dress)
	if current_view_node.has_signal("open_museum_requested"):
		current_view_node.open_museum_requested.connect(switch_to_museum)

func switch_to_shop(initial_category: String = "costumes") -> void:
	current_tab_name = "shop"
	cat_profile_hud.visible = false
	btn_handbook_quick.visible = false
	bottom_paw_menu.visible = true
	bottom_paw_menu.set_active_tab("shop")
	_clear_current_view()
	current_view_node = shop_view_scene.instantiate()
	views_container.add_child(current_view_node)
	current_view_node.back_to_room.connect(switch_to_room)
	if current_view_node.has_signal("open_house_dress_requested"):
		current_view_node.open_house_dress_requested.connect(switch_to_house_dress)
	if current_view_node.has_signal("open_museum_requested"):
		current_view_node.open_museum_requested.connect(switch_to_museum)
	if initial_category != "costumes" and current_view_node.has_method("_switch_main_category"):
		current_view_node._switch_main_category(initial_category)

func _on_open_avatar_picker() -> void:
	if bottom_paw_menu:
		bottom_paw_menu.close_drawer()
	avatar_picker_modal.open()

func _on_voice_mimic() -> void:
	SoundManager.play_talking_mimic()
	var phrases = [
		"Meo-o! Sen đẹp trai / xinh gái nhất trần đời! 💖",
		"Nhớ chi tiêu tiết kiệm, đừng quẹt ví bừa bãi nha Sen! 🐟",
		"Có Boss ở đây rồi, ra đường không sợ lạc xe buýt nữa! 🚌",
		"Học chăm chỉ rồi cuối tuần thưởng lon Pate xịn nha Sen! 🥫",
		"Purr-purr! Tự lập không khó khi có Boss bên cạnh! 🐾"
	]
	var p = phrases[randi() % phrases.size()]
	_show_toast_message("🎤 Boss Mèo nhại tiếng: \"" + p + "\"")

func _on_food_selected(food_type: String) -> void:
	if current_tab_name != "room":
		switch_to_room()
	if current_view_node and current_view_node.has_method("feed_cat"):
		current_view_node.feed_cat(food_type)

func _on_play_selected(play_type: String) -> void:
	if current_tab_name != "room":
		switch_to_room()
	if current_view_node and current_view_node.has_method("play_activity"):
		current_view_node.play_activity(play_type)

func _show_toast_message(msg: String) -> void:
	toast_label.text = msg
	toast_panel.visible = true
	toast_timer.start(3.5)
