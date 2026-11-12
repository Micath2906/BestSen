extends Control

# IsometricRoomView.gd - Điều khiển Căn Phòng Trọ Sinh Viên Khép Kín Chuẩn True 2.5D Isometric
# Tương tác đệm ngủ, khay ăn nước, cây cào móng, hộp carton và thả đồ chơi trên lưới Dimetric 8x8

const IsometricGrid = preload("res://scripts/IsometricGrid.gd")

signal open_skill_tree_requested
signal open_lesson_requested(lesson_id)
signal open_dressing_room_requested
signal open_room_decor_requested
signal open_handbook_requested

@onready var room_background: TextureRect = $RoomBackground
@onready var room_canvas: Node2D = $RoomCanvas
@onready var y_sort_entities: Node2D = $YSortEntities

@onready var room_title_label: Label = $RoomTitleBanner/HBox/TitleLabel
@onready var btn_edit_room_name: Button = $RoomTitleBanner/HBox/BtnEditRoomName
@onready var btn_change_bg: Button = $RoomTitleBanner/HBox.get_node_or_null("BtnChangeBg")
@onready var btn_main_menu: Button = $RoomTitleBanner/HBox.get_node_or_null("BtnMainMenu")

@onready var btn_handbook_quick: Button = get_node_or_null("UnifiedActionRow/BtnHandbookQuick")
@onready var btn_dressing_quick: Button = get_node_or_null("UnifiedActionRow/BtnDressingQuick")
@onready var btn_decor_quick: Button = get_node_or_null("UnifiedActionRow/BtnDecorQuick")

@onready var room_name_modal: Control = get_node_or_null("RoomNameModal")
@onready var line_edit_room_name: LineEdit = get_node_or_null("RoomNameModal/CenterContainer/Panel/VBox/LineEdit")
@onready var btn_chip_avatar: Button = get_node_or_null("RoomNameModal/CenterContainer/Panel/VBox/ChipsRow1/BtnChipAvatar")
@onready var btn_chip_cozy: Button = get_node_or_null("RoomNameModal/CenterContainer/Panel/VBox/ChipsRow1/BtnChipCozy")
@onready var btn_chip_dorm: Button = get_node_or_null("RoomNameModal/CenterContainer/Panel/VBox/ChipsRow2/BtnChipDorm")
@onready var btn_chip_palace: Button = get_node_or_null("RoomNameModal/CenterContainer/Panel/VBox/ChipsRow2/BtnChipPalace")
@onready var btn_save_room_name: Button = get_node_or_null("RoomNameModal/CenterContainer/Panel/VBox/BtnRow/BtnSave")
@onready var btn_cancel_room_name: Button = get_node_or_null("RoomNameModal/CenterContainer/Panel/VBox/BtnRow/BtnCancel")
@onready var modal_overlay: Panel = get_node_or_null("RoomNameModal/Overlay")

@onready var btn_monthly_expenses: Button = get_node_or_null("BtnMonthlyExpenses")
@onready var monthly_expenses_modal: Control = get_node_or_null("MonthlyExpensesModal")
@onready var btn_pay_expenses: Button = get_node_or_null("MonthlyExpensesModal/CenterContainer/Panel/VBox/BtnRow/BtnPayExpenses")
@onready var btn_close_expenses: Button = get_node_or_null("MonthlyExpensesModal/CenterContainer/Panel/VBox/BtnRow/BtnCloseExpenses")
@onready var expenses_status_label: Label = get_node_or_null("MonthlyExpensesModal/CenterContainer/Panel/VBox/StatusLabel")
@onready var expenses_overlay: Panel = get_node_or_null("MonthlyExpensesModal/Overlay")

@onready var cushion_bed: Node2D = $YSortEntities/CushionBed
@onready var food_bowl: Node2D = $YSortEntities/FoodBowl
@onready var water_bowl: Node2D = $YSortEntities/WaterBowl
@onready var litter_box: Node2D = $YSortEntities/LitterBox
@onready var iso_cat: Node2D = $YSortEntities/IsoCat
@onready var companion_cat: Node2D = $YSortEntities.get_node_or_null("CompanionCat")

@onready var toy_item: Node2D = $YSortEntities/ToyItem
@onready var toy_sprite: Sprite2D = $YSortEntities/ToyItem.get_node_or_null("ToySprite")
@onready var toy_label: Label = $YSortEntities/ToyItem/ToyLabel

@onready var floor_touch_area: Control = $FloorTouchArea
@onready var roam_timer: Timer = $RoamTimer

const LONG_PRESS_DECOR_SEC: float = 1.0
const FOOD_BAG_TEX: Texture2D = preload("res://assets/UI/CatUIPaid/slices/icon_cat_food_bag.png")

var origin: Vector2 = Vector2(270.0, 690.0)
var food_bowl_drop_zone: Control = null
var food_bag_widget: TextureRect = null
var food_bag_qty_lbl: Label = null
var is_dragging_food_bag: bool = false
var food_bag_base_pos: Vector2 = Vector2(338.0, 790.0)

var _floor_press_active: bool = false
var _floor_press_elapsed: float = 0.0
var _floor_press_pos: Vector2 = Vector2.ZERO
var _floor_press_handled_long: bool = false

var is_decor_mode: bool = false
var selected_decor_furn_key: String = ""
var decor_mode_bar: Control = null
var comfort_status_lbl: Label = null

func _ready() -> void:
	room_canvas.origin = origin
	iso_cat.origin = origin
	
	# Định vị 4 đồ nội thất thiết yếu trên mặt sàn phòng trọ 2D Classic (Y ~ 760-820, X ~ 85-440)
	# 1 Giường ngủ, 1 Chén đồ ăn, 1 Chén nước, và 1 Chỗ đi vệ sinh (Litter box)
	cushion_bed.position = Vector2(85.0, 765.0)
	food_bowl.position = Vector2(195.0, 815.0)
	water_bowl.position = Vector2(260.0, 815.0)
	litter_box.position = Vector2(430.0, 790.0)
	
	# Cập nhật grid_coord để mèo đi đến chuẩn xác
	cushion_bed.grid_coord = IsometricGrid.screen_to_grid(cushion_bed.position, origin)
	food_bowl.grid_coord = IsometricGrid.screen_to_grid(food_bowl.position, origin)
	water_bowl.grid_coord = IsometricGrid.screen_to_grid(water_bowl.position, origin)
	litter_box.grid_coord = IsometricGrid.screen_to_grid(litter_box.position, origin)
	_apply_saved_furniture_positions()
	
	# Cập nhật background Classic từ PetMobileGameAsset
	_update_room_background()
	GameManager.classic_bg_changed.connect(func(_bg_id): _update_room_background())
	
	# Thiết lập mèo bạn đồng hành (Mochi & Pochi cùng ở trong phòng)
	_setup_companion_cat()
	GameManager.avatar_changed.connect(func(_id): _setup_companion_cat())
	
	if btn_change_bg:
		btn_change_bg.pressed.connect(func():
			SoundManager.play_click()
			var next_id = (GameManager.selected_classic_bg_id % 20) + 1
			GameManager.set_classic_bg(next_id)
			_spawn_floating_text(Vector2(270, 240), "Phòng Classic #%d/20" % next_id, Color(0.95, 0.65, 0.2))
		)
	
	# Kết nối sự kiện tương tác đồ nội thất
	cushion_bed.item_clicked.connect(_on_cushion_clicked)
	food_bowl.item_clicked.connect(_on_food_bowl_clicked)
	water_bowl.item_clicked.connect(_on_water_bowl_clicked)
	litter_box.item_clicked.connect(_on_litter_box_clicked)
	
	# Cập nhật tên phòng hiển thị & lắng nghe đổi tên
	_update_room_title(GameManager.get_room_name())
	if GameManager.has_signal("room_name_changed"):
		GameManager.room_name_changed.connect(_update_room_title)
		
	# Nạp các đồ nội thất do người chơi tự bài trí từ Decor Studio
	_sync_placed_decorations()
	if GameManager.has_signal("placed_decor_changed"):
		GameManager.placed_decor_changed.connect(_sync_placed_decorations)
	
	if btn_edit_room_name:
		btn_edit_room_name.pressed.connect(_open_rename_modal)
		
	if btn_main_menu:
		btn_main_menu.pressed.connect(func():
			SoundManager.play_click()
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
		)
		
	# Cho phép click trực tiếp vào tiêu đề banner để đổi tên phòng tiện lợi
	if room_title_label:
		room_title_label.mouse_filter = Control.MOUSE_FILTER_PASS
		room_title_label.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_open_rename_modal()
		)
	
	# Kết nối bộ 3 nút thao tác nhanh đã gom về 1 chỗ ở giữa
	if btn_handbook_quick:
		btn_handbook_quick.pressed.connect(func():
			SoundManager.play_click()
			emit_signal("open_handbook_requested")
		)
	if btn_dressing_quick:
		btn_dressing_quick.pressed.connect(func():
			SoundManager.play_click()
			emit_signal("open_dressing_room_requested")
		)
	if btn_decor_quick:
		btn_decor_quick.pressed.connect(func():
			SoundManager.play_click()
			emit_signal("open_room_decor_requested")
		)
		
	# Cấu hình Modal đổi tên phòng
	_setup_rename_modal()
	
	# Cấu hình Sổ Chi Phí KTX Hàng Tháng
	_setup_monthly_expenses_ui()
	
	# Kết nối tương tác chạm thân mèo
	var cat_touch: Control = iso_cat.get_node_or_null("Visual/CatTouchZone")
	if cat_touch:
		cat_touch.gui_input.connect(_on_cat_gui_input)
		
	# Kết nối chạm sàn nhà thả đồ chơi
	floor_touch_area.gui_input.connect(_on_floor_gui_input)
	
	# Kết nối bộ định thời đi dạo ngẫu nhiên (Roaming AI)
	roam_timer.timeout.connect(_on_roam_timer_timeout)
	roam_timer.start(randf_range(4.0, 7.0))
	
	if iso_cat.has_signal("reached_destination"):
		iso_cat.reached_destination.connect(_on_cat_reached_destination)
		
	if toy_sprite:
		toy_sprite.texture = GameManager.load_texture("res://assets/sprites/room_items/toy_yarn_ball.png")
		
	toy_item.visible = false
	_setup_food_bag_interaction()
	_setup_decor_mode_ui()
	_update_comfort_badge()
	GameManager.room_state_updated.connect(_update_comfort_badge)
	GameManager.stats_changed.connect(_refresh_food_bag_widget)
	if GameManager.is_offline_auto_sleeping and iso_cat.has_method("set_cozy_sleep_mode"):
		iso_cat.set_cozy_sleep_mode(true)

func _update_room_title(room_name: String) -> void:
	if room_title_label:
		room_title_label.text = room_name

func _update_room_background() -> void:
	if room_background:
		var path = GameManager.get_classic_bg_path()
		if ResourceLoader.exists(path) or FileAccess.file_exists(path):
			room_background.texture = load(path)

func _setup_companion_cat() -> void:
	if not companion_cat:
		return
	companion_cat.origin = origin
	var cur_breed = GameManager.selected_avatar_id
	var comp_breed = 9 if cur_breed == 8 else 8
	companion_cat._setup_sprite_frames(comp_breed)
	companion_cat.position = Vector2(85.0, 775.0)
	companion_cat.grid_pos = IsometricGrid.screen_to_grid(companion_cat.position, origin)
	companion_cat.set_state(companion_cat.State.SLEEP)
	if companion_cat.dialogue_label:
		var c_name = "Pochi" if comp_breed == 9 else "Mochi"
		companion_cat.dialogue_label.text = "%s bạn thân đang lim dim ngủ Zzz 🐾" % c_name
		# Ẩn bong bóng thoại bạn thân sau 4 giây để phòng thoáng đãng
		get_tree().create_timer(4.0).timeout.connect(func():
			if is_instance_valid(companion_cat) and companion_cat.bubble and companion_cat.current_state == companion_cat.State.SLEEP:
				var tw = create_tween()
				tw.tween_property(companion_cat.bubble, "modulate:a", 0.0, 0.4)
				tw.tween_callback(func():
					if is_instance_valid(companion_cat) and companion_cat.bubble:
						companion_cat.bubble.visible = false
				)
		)
	var comp_touch = companion_cat.get_node_or_null("Visual/CatTouchZone")
	if comp_touch and not comp_touch.gui_input.is_connected(_on_comp_touch):
		comp_touch.gui_input.connect(_on_comp_touch)

func _on_comp_touch(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		SoundManager.play_meow(1.2)
		if companion_cat:
			if companion_cat.bubble:
				companion_cat.bubble.visible = true
				companion_cat.bubble.modulate.a = 1.0
			companion_cat.set_state(companion_cat.State.IDLE)
			var cur_breed = GameManager.selected_avatar_id
			var comp_breed = 9 if cur_breed == 8 else 8
			var c_name = "Pochi" if comp_breed == 9 else "Mochi"
			companion_cat.dialogue_label.text = "%s meo chào Sen! Hai đứa mình cùng trông phòng nhé! ✨" % c_name
			# Tự động lim dim ngủ lại sau 4s
			get_tree().create_timer(4.0).timeout.connect(func():
				if is_instance_valid(companion_cat):
					companion_cat.set_state(companion_cat.State.SLEEP)
					companion_cat.dialogue_label.text = "%s lim dim ngủ Zzz 💤" % c_name
					get_tree().create_timer(3.0).timeout.connect(func():
						if is_instance_valid(companion_cat) and companion_cat.bubble:
							companion_cat.bubble.visible = false
					)
			)

func _setup_rename_modal() -> void:
	if not room_name_modal:
		return
	room_name_modal.visible = false
	if modal_overlay:
		modal_overlay.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_close_rename_modal()
		)
	if btn_save_room_name:
		btn_save_room_name.pressed.connect(_save_room_name)
	if btn_cancel_room_name:
		btn_cancel_room_name.pressed.connect(_close_rename_modal)
	if line_edit_room_name:
		line_edit_room_name.text_submitted.connect(func(_t): _save_room_name())
		
	if btn_chip_avatar:
		btn_chip_avatar.pressed.connect(func():
			line_edit_room_name.text = "Phòng của %s" % GameManager.get_cat_name()
			SoundManager.play_click()
		)
	if btn_chip_cozy:
		btn_chip_cozy.pressed.connect(func():
			line_edit_room_name.text = "Tổ Ấm Sen & Boss"
			SoundManager.play_click()
		)
	if btn_chip_dorm:
		btn_chip_dorm.pressed.connect(func():
			line_edit_room_name.text = "Ký Túc Xá P.102"
			SoundManager.play_click()
		)
	if btn_chip_palace:
		btn_chip_palace.pressed.connect(func():
			line_edit_room_name.text = "Lâu Đài Boss Cào Cào"
			SoundManager.play_click()
		)

func _open_rename_modal() -> void:
	if not room_name_modal:
		return
	SoundManager.play_click()
	if line_edit_room_name:
		line_edit_room_name.text = GameManager.get_room_name()
		line_edit_room_name.grab_focus()
		line_edit_room_name.select_all()
	if btn_chip_avatar:
		btn_chip_avatar.text = "Phòng của %s" % GameManager.get_cat_name()
	room_name_modal.visible = true

func _close_rename_modal() -> void:
	if not room_name_modal:
		return
	SoundManager.play_click()
	room_name_modal.visible = false

func _save_room_name() -> void:
	if not line_edit_room_name:
		return
	var new_name = line_edit_room_name.text.strip_edges()
	if new_name == "":
		new_name = "Phòng của %s" % GameManager.get_cat_name()
	GameManager.set_room_name(new_name)
	SoundManager.play_success()
	room_name_modal.visible = false
	_spawn_floating_text(Vector2(270, 160), "Đã đổi: " + new_name, Color(0.2, 0.75, 0.35))

# --- HỆ THỐNG CHI PHÍ KTX HÀNG THÁNG ---
func _setup_monthly_expenses_ui() -> void:
	if not btn_monthly_expenses:
		return
	btn_monthly_expenses.pressed.connect(_open_monthly_expenses_modal)
	if btn_close_expenses:
		btn_close_expenses.pressed.connect(_close_monthly_expenses_modal)
	if btn_pay_expenses:
		btn_pay_expenses.pressed.connect(_on_pay_expenses_pressed)
	if expenses_overlay:
		expenses_overlay.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				_close_monthly_expenses_modal()
		)
	GameManager.stats_changed.connect(_update_monthly_expenses_display)
	if GameManager.has_signal("monthly_rent_paid"):
		GameManager.monthly_rent_paid.connect(_update_monthly_expenses_display)
	_update_monthly_expenses_display()

func _update_monthly_expenses_display() -> void:
	var st = GameManager.get_monthly_budget_status()
	if not btn_monthly_expenses:
		return
	if st.is_paid:
		btn_monthly_expenses.text = " KTX Tháng: Đã đóng đủ 85.000đ • Sống khỏe an tâm"
		if btn_pay_expenses:
			btn_pay_expenses.text = "Đã Thanh Toán"
			btn_pay_expenses.disabled = true
		if expenses_status_label:
			expenses_status_label.text = "Đã đóng đủ toàn bộ chi phí KTX tháng này!"
	else:
		btn_monthly_expenses.text = " Chi Phí KTX: 85.000đ • Hạn còn %d ngày" % st.days_left
		if btn_pay_expenses:
			btn_pay_expenses.text = "Đóng Tiền KTX (%s)" % GameManager.format_currency(st.total)
			btn_pay_expenses.disabled = not st.can_afford
		if expenses_status_label:
			if st.can_afford:
				expenses_status_label.text = "Còn %d ngày • Ví đủ tiền đóng KTX ngay!" % st.days_left
			else:
				var missing = st.total - GameManager.fish
				expenses_status_label.text = "Còn %d ngày • Thiếu %s để đủ tiền KTX!" % [st.days_left, GameManager.format_currency(missing)]

func _open_monthly_expenses_modal() -> void:
	SoundManager.play_click()
	_update_monthly_expenses_display()
	if monthly_expenses_modal:
		monthly_expenses_modal.visible = true

func _close_monthly_expenses_modal() -> void:
	SoundManager.play_click()
	if monthly_expenses_modal:
		monthly_expenses_modal.visible = false

func _on_pay_expenses_pressed() -> void:
	SoundManager.play_click()
	var success = GameManager.pay_monthly_expenses()
	if success:
		_close_monthly_expenses_modal()
		_spawn_floating_text(Vector2(270, 200), "Đã đóng tiền KTX 85.000đ!", Color(0.2, 0.8, 0.4))
	_update_monthly_expenses_display()

# --- TƯƠNG TÁC CHẠM NỘI THẤT ISOMETRIC ---
func _on_cushion_clicked(_type) -> void:
	if is_decor_mode:
		_select_furniture_for_decor("cushion_bed")
		return
	# Mèo đi đến đệm và nằm ngủ, hồi phục và sang ngày mới
	iso_cat.walk_to_grid(cushion_bed.grid_coord + Vector2(0.25, 0.1), iso_cat.State.SLEEP)
	_spawn_floating_text(cushion_bed.position + Vector2(0, -35), "🛋️ Ngủ ngon! Ngày mới đã sang ✨", Color(0.9, 0.6, 0.4))
	GameManager.update_stats(0, 0, +5, +15)
	GameManager.advance_day()

func _on_food_bowl_clicked(_type) -> void:
	if is_decor_mode:
		_select_furniture_for_decor("food_bowl")
		return
	# Mèo đi đến chén đồ ăn
	feed_cat("kibble")

func _on_water_bowl_clicked(_type) -> void:
	if is_decor_mode:
		_select_furniture_for_decor("water_bowl")
		return
	# Mèo đi đến chén nước uống
	feed_cat("water")

func _on_litter_box_clicked(_type) -> void:
	if is_decor_mode:
		_select_furniture_for_decor("litter_box")
		return
	# Dọn cát vệ sinh sạch sẽ, nảy chậu cát và tăng chỉ số
	SoundManager.play_purr()
	litter_box.play_click_reaction()
	GameManager.update_stats(0, 0, +10, +15)
	_spawn_floating_text(litter_box.position + Vector2(0, -35), "✨ Dọn cát sạch bong: +15 Mood | +10 Vệ Sinh!", Color(0.25, 0.75, 0.85))

# --- TƯƠNG TÁC KÉO THẢ & CHẠM TRỰC TIẾP LÊN MÈO ---
var is_dragging_cat: bool = false
var _cat_drag_lifted: bool = false
var cat_drag_mouse_offset: Vector2 = Vector2.ZERO
var cat_press_time: float = 0.0
var cat_press_pos: Vector2 = Vector2.ZERO

func _on_cat_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging_cat = true
			_cat_drag_lifted = false
			cat_press_time = Time.get_ticks_msec() / 1000.0
			cat_press_pos = event.global_position
			cat_drag_mouse_offset = iso_cat.position - event.global_position
			roam_timer.stop()
		else:
			if is_dragging_cat:
				is_dragging_cat = false
				var duration = (Time.get_ticks_msec() / 1000.0) - cat_press_time
				var dist = event.global_position.distance_to(cat_press_pos)
				if not _cat_drag_lifted or (duration < 0.25 and dist < 14.0):
					# Nhấp chạm / xoa đầu vuốt ve (Petting/Vuốt ve)
					if _cat_drag_lifted:
						iso_cat.end_drag()
					var touch_y = event.position.y - 24.0
					iso_cat.handle_touch(touch_y)
					_spawn_heart_burst(iso_cat.position)
					var stat_msg = "💖 Purr~"
					if touch_y < -15.0: stat_msg = "💖 +2 Dũng | ✨ +5 Mood"
					elif touch_y < 10.0: stat_msg = "😹 +8 Mood"
					else: stat_msg = "✨ Boing!"
					_spawn_floating_text(iso_cat.position + Vector2(0, -60), stat_msg, Color(1.0, 0.45, 0.75))
					roam_timer.start(randf_range(6.0, 9.0))
				else:
					_on_cat_dropped_at(iso_cat.position)

func _input(event: InputEvent) -> void:
	if is_dragging_cat:
		if event is InputEventMouseMotion:
			var move_dist: float = event.global_position.distance_to(cat_press_pos)
			if not _cat_drag_lifted:
				if move_dist < 14.0:
					if iso_cat.has_method("pet_rub"):
						iso_cat.pet_rub(event.position.y - iso_cat.position.y)
					return
				_cat_drag_lifted = true
				iso_cat.start_drag()
			var target_pos = event.global_position + cat_drag_mouse_offset
			# Giới hạn trong sàn phòng trọ 2D Classic
			target_pos.x = clampf(target_pos.x, 70.0, 470.0)
			target_pos.y = clampf(target_pos.y, 715.0, 850.0)
			iso_cat.position = target_pos
			iso_cat.grid_pos = IsometricGrid.screen_to_grid(target_pos, origin)
			
			# Phản hồi bong bóng thoại khi kéo gần đồ đạc
			if target_pos.distance_to(cushion_bed.position) < 55.0:
				iso_cat.dialogue_label.text = "Thả vào đệm để ngủ ngon Zzz 💤"
			elif target_pos.distance_to(food_bowl.position) < 45.0:
				iso_cat.dialogue_label.text = "Thả vào chén ăn để xơi hạt 🍗"
			elif target_pos.distance_to(water_bowl.position) < 45.0:
				iso_cat.dialogue_label.text = "Thả vào chén nước để giải khát 💧"
			elif target_pos.distance_to(litter_box.position) < 55.0:
				iso_cat.dialogue_label.text = "Thả vào chậu cát để đi vệ sinh 🐾"
			else:
				iso_cat.dialogue_label.text = "Đang được Sen bế đi dạo phòng! 🐾"
				
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			is_dragging_cat = false
			if _cat_drag_lifted:
				_on_cat_dropped_at(iso_cat.position)
			else:
				iso_cat.pet_rub(-12.0)

func _on_cat_dropped_at(drop_pos: Vector2) -> void:
	iso_cat.end_drag()
	
	# Kiểm tra khoảng cách tới 4 món đồ nội thất (Tương tác hợp logic mèo)
	if drop_pos.distance_to(cushion_bed.position) < 55.0:
		iso_cat.position = cushion_bed.position + Vector2(25, 10)
		iso_cat.grid_pos = IsometricGrid.screen_to_grid(iso_cat.position, origin)
		iso_cat.set_state(iso_cat.State.SLEEP)
		SoundManager.play_purr()
		GameManager.update_stats(0, 0, +5, +15)
		_spawn_floating_text(cushion_bed.position + Vector2(0, -40), "💤 Ngủ đệm êm: +15 Mood!", Color(0.3, 0.7, 0.9))
	elif drop_pos.distance_to(food_bowl.position) < 45.0:
		iso_cat.position = food_bowl.position + Vector2(-24, 4)
		iso_cat.grid_pos = IsometricGrid.screen_to_grid(iso_cat.position, origin)
		iso_cat.anim_sprite.flip_h = false
		iso_cat.set_state(iso_cat.State.EAT)
		SoundManager.play_chomp()
		GameManager.update_stats(0, +20, 0, +10)
		_spawn_floating_text(food_bowl.position + Vector2(0, -40), "🍗 Ăn hạt: +20 No | +10 Mood!", Color(0.2, 0.8, 0.35))
	elif drop_pos.distance_to(water_bowl.position) < 45.0:
		iso_cat.position = water_bowl.position + Vector2(-24, 4)
		iso_cat.grid_pos = IsometricGrid.screen_to_grid(iso_cat.position, origin)
		iso_cat.anim_sprite.flip_h = false
		iso_cat.set_state(iso_cat.State.DRINK)
		SoundManager.play_purr()
		GameManager.update_stats(0, 0, +5, +15)
		_spawn_floating_text(water_bowl.position + Vector2(0, -40), "💧 Uống nước mát: +15 Mood!", Color(0.2, 0.65, 0.9))
	elif drop_pos.distance_to(litter_box.position) < 55.0:
		iso_cat.position = litter_box.position + Vector2(0, 2)
		iso_cat.grid_pos = IsometricGrid.screen_to_grid(iso_cat.position, origin)
		iso_cat.set_state(iso_cat.State.IDLE)
		SoundManager.play_purr()
		litter_box.play_click_reaction()
		GameManager.update_stats(0, 0, +10, +15)
		iso_cat.dialogue_label.text = "Đi vệ sinh xong nhẹ cả người Sen ơi! Cát sạch thơm tho quá! ✨"
	else:
		# Kiểm tra nếu thả trúng bất kỳ đồ decor nào do người chơi tự đặt
		var decor_matched = false
		var layer = y_sort_entities.get_node_or_null("PlacedDecorLayer")
		if layer:
			for decor_spr in layer.get_children():
				if decor_spr is Sprite2D and drop_pos.distance_to(decor_spr.position) < 55.0:
					decor_matched = true
					var did = decor_spr.get_meta("item_id") if decor_spr.has_meta("item_id") else ""
					_on_custom_decor_interacted(did, decor_spr.position)
					break
		if not decor_matched:
			iso_cat.grid_pos = IsometricGrid.screen_to_grid(drop_pos, origin)
			iso_cat.set_state(iso_cat.State.IDLE)
			SoundManager.play_meow(1.3)
			iso_cat.dialogue_label.text = "Hạ cánh rồi! Sen đặt Boss ở đây ấm ghê! 🐾"
		
	roam_timer.start(randf_range(6.0, 9.0))

# --- TƯƠNG TÁC CHẠM MẶT SÀN 2D CLASSIC (THẢ ĐỒ CHƠI & LONG-PRESS 1s DECOR MODE) ---
func _process(delta: float) -> void:
	if _floor_press_active and not _floor_press_handled_long and not is_decor_mode:
		_floor_press_elapsed += delta
		if _floor_press_elapsed >= LONG_PRESS_DECOR_SEC:
			_floor_press_handled_long = true
			_floor_press_active = false
			enter_decor_mode(_floor_press_pos)

func _on_floor_gui_input(event: InputEvent) -> void:
	if is_dragging_cat or is_dragging_food_bag:
		return
	if event is InputEventMouseMotion and is_decor_mode:
		var g = IsometricGrid.screen_to_grid(event.position, origin)
		var cell := Vector2i(floori(g.x), floori(g.y))
		var valid: bool = is_grid_cell_valid(cell, selected_decor_furn_key)
		room_canvas.set_grid_highlight(cell, valid)
		return
	if event is InputEventMouseMotion and _floor_press_active:
		if event.position.distance_to(_floor_press_pos) > 16.0:
			_floor_press_active = false
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos = event.position
		if event.pressed:
			_floor_press_active = true
			_floor_press_elapsed = 0.0
			_floor_press_pos = click_pos
			_floor_press_handled_long = false
		else:
			var was_long: bool = _floor_press_handled_long
			_floor_press_active = false
			if was_long:
				return
			if is_decor_mode:
				_handle_decor_floor_click(click_pos)
			elif (click_pos.y >= 710.0 and click_pos.y <= 880.0 and click_pos.x >= 40.0 and click_pos.x <= 500.0) or IsometricGrid.is_point_inside_floor(click_pos, origin, 0.4):
				var target_grid = IsometricGrid.screen_to_grid(click_pos, origin)
				_drop_toy_and_chase(target_grid)

func _drop_toy_and_chase(grid_target: Vector2) -> void:
	var screen_pos = IsometricGrid.grid_to_screen(grid_target, origin)
	toy_item.position = screen_pos
	toy_item.visible = true
	toy_item.modulate.a = 1.0
	toy_item.rotation_degrees = 0.0
	toy_item.scale = Vector2(0.5, 0.5)
	
	if toy_sprite:
		if toy_sprite.texture == null:
			toy_sprite.texture = GameManager.load_texture("res://assets/sprites/room_items/toy_yarn_ball.png")
		toy_sprite.visible = true
		if toy_label:
			toy_label.visible = false
	elif toy_label:
		var toys = ["🧶", "🔴", "🎾", "🐟"]
		toy_label.text = toys[randi() % toys.size()]
		toy_label.visible = true
	
	var tween = create_tween()
	tween.tween_property(toy_item, "position:y", screen_pos.y - 25.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(toy_item, "position:y", screen_pos.y, 0.12).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(toy_item, "scale", Vector2(1.2, 0.8), 0.12)
	tween.tween_property(toy_item, "scale", Vector2(1.0, 1.0), 0.08)
	
	SoundManager.play_meow(1.4)
	iso_cat.walk_to_grid(grid_target, iso_cat.State.CHASE_TOY)

func _on_cat_reached_destination(dest_state: int) -> void:
	if dest_state == iso_cat.State.CHASE_TOY:
		SoundManager.play_bounce()
		SoundManager.play_purr()
		GameManager.update_stats(0, 0, +10, +15)
		_spawn_floating_text(toy_item.position + Vector2(0, -35), "🧶 +15 Mood | +10 Dũng!", Color(0.95, 0.6, 0.2))
		
		# Boss mèo vồ lấy cuộn len với animation vờn bắt paw_toy
		if iso_cat.has_node("Visual/AnimSprite"):
			var spr = iso_cat.get_node("Visual/AnimSprite")
			if spr.sprite_frames.has_animation("paw_toy"):
				spr.play("paw_toy")
		if iso_cat.has_node("DialogueBubble/SpeechLabel"):
			iso_cat.get_node("DialogueBubble/SpeechLabel").text = "Vồ được cuộn len rồi! Lăn lăn vui quá Sen ơi! 🧶✨"
			
		var tw = create_tween()
		tw.tween_property(toy_item, "position:x", toy_item.position.x + 22.0, 0.2)
		tw.parallel().tween_property(toy_item, "rotation_degrees", 60.0, 0.2)
		tw.tween_interval(0.6)
		tw.tween_property(toy_item, "modulate:a", 0.0, 0.3)
		tw.finished.connect(func():
			toy_item.visible = false
			toy_item.modulate.a = 1.0
			toy_item.rotation_degrees = 0.0
			if iso_cat.current_state == iso_cat.State.CHASE_TOY:
				iso_cat.set_state(iso_cat.State.IDLE)
		)

# --- CHO ĂN & UỐNG NƯỚC QUA MENU / HOẠT ĐỘNG ---
func feed_cat(food_type: String) -> void:
	if food_type == "water":
		iso_cat.walk_to_grid(water_bowl.grid_coord + Vector2(-0.2, 0.0), iso_cat.State.DRINK)
		SoundManager.play_purr()
		water_bowl.play_click_reaction()
		GameManager.update_stats(0, 0, +5, +15)
		_spawn_floating_text(water_bowl.position + Vector2(0, -35), "💧 Uống nước mát: +15 Mood | +5 Dũng", Color(0.2, 0.65, 0.9))
		return
		
	var success = false
	if food_type == "kibble":
		success = GameManager.feed_kibble()
	elif food_type == "pate":
		success = GameManager.feed_pate()
	elif food_type == "dry_fish":
		success = GameManager.feed_dry_fish()
		
	if not success:
		return
		
	iso_cat.walk_to_grid(food_bowl.grid_coord + Vector2(-0.2, 0.0), iso_cat.State.EAT)
	SoundManager.play_chomp()
	if food_bowl.has_method("set_bowl_filled"):
		food_bowl.set_bowl_filled(true)
	else:
		food_bowl.play_click_reaction()
	get_tree().create_timer(2.2).timeout.connect(func():
		if is_instance_valid(food_bowl) and food_bowl.has_method("set_bowl_filled"):
			food_bowl.set_bowl_filled(false)
	)
	_refresh_food_bag_widget()
	
	var msg = "+15 🍗 | +5 ✨"
	if food_type == "pate":
		msg = "+35 🍗 | +25 💖 | +20 ✨"
	elif food_type == "dry_fish":
		msg = "+20 🍗 | +20 ✨ | +5 💖"
	_spawn_floating_text(food_bowl.position + Vector2(0, -35), msg, Color(0.2, 0.8, 0.35))

func play_activity(activity_type: String) -> void:
	match activity_type:
		"yarn_ball":
			# Thả cuộn len ra sàn phòng trọ cho Boss đuổi bắt
			var drop_grid = Vector2(randf_range(2.0, 3.8), randf_range(3.5, 4.8))
			_drop_toy_and_chase(drop_grid)
		"feather":
			if GameManager.play_feather():
				SoundManager.play_bounce()
				_spawn_floating_text(iso_cat.position + Vector2(0, -50), "🪶 +40 💖 Hưng Phấn!", Color(1.0, 0.5, 0.2))
				iso_cat._jump_reaction(35.0)
		"pet":
			iso_cat.handle_touch(-20.0)
		"bnpl":
			GameManager.use_bnpl()
			SoundManager.play_meow(0.85)
			_spawn_floating_text(iso_cat.position + Vector2(0, -50), "💳 +30 💖 (Nợ 35 Cá sau 5 ngày!)", Color(0.9, 0.2, 0.2))

# --- ROAMING AI: TỰ DO ĐI LẠI TRONG KHÔNG GIAN PHÒNG TRỌ ---
func _on_roam_timer_timeout() -> void:
	# Nếu mèo đang xỉu vì hạ đường huyết -> nằm yên
	if GameManager.hunger <= 0:
		iso_cat.set_state(iso_cat.State.FAINT)
		roam_timer.start(4.0)
		return

	if iso_cat.current_state == iso_cat.State.CHASE_TOY or iso_cat.current_state == iso_cat.State.EAT or iso_cat.current_state == iso_cat.State.DRINK:
		roam_timer.start(3.0)
		return
		
	var roll = randf()
	if roll < 0.45:
		# Đi dạo ngẫu nhiên đến một vị trí trong phòng
		var next_u = randf_range(1.5, 6.0)
		var next_v = randf_range(2.0, 5.5)
		iso_cat.walk_to_grid(Vector2(next_u, next_v), iso_cat.State.IDLE)
		iso_cat._show_random_thought()
	elif roll < 0.65:
		# Nằm nghỉ tại chỗ
		iso_cat.set_state(iso_cat.State.IDLE)
	elif roll < 0.85:
		# Ghé thăm đệm ngủ hoặc chậu cát đi vệ sinh
		if randf() < 0.5:
			iso_cat.walk_to_grid(cushion_bed.grid_coord + Vector2(0.2, 0.1), iso_cat.State.SLEEP)
		else:
			iso_cat.walk_to_grid(litter_box.grid_coord, iso_cat.State.IDLE)
			iso_cat.dialogue_label.text = "Bới cát sột soạt... Chậu cát sạch thơm tho ghê! 🐾"
	else:
		# Ghé uống nước hoặc chén ăn
		if randf() < 0.5:
			iso_cat.walk_to_grid(water_bowl.grid_coord + Vector2(-0.2, 0.0), iso_cat.State.DRINK)
		else:
			iso_cat.walk_to_grid(food_bowl.grid_coord + Vector2(-0.2, 0.0), iso_cat.State.EAT)
		
	roam_timer.start(randf_range(4.5, 8.5))

func _spawn_floating_text(pos: Vector2, text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 12)
	label.position = pos + Vector2(-40, 0)
	$FloatingContainer.add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 35.0, 0.85)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.85)
	tween.finished.connect(func(): label.queue_free())

func _spawn_heart_burst(pos: Vector2) -> void:
	var heart_colors = [Color(1.0, 0.4, 0.6), Color(1.0, 0.6, 0.75), Color(1.0, 0.85, 0.2)]
	for i in range(4):
		var lbl = Label.new()
		lbl.text = "💖" if i % 2 == 0 else "✨"
		lbl.add_theme_color_override("font_color", heart_colors[i % heart_colors.size()])
		lbl.add_theme_font_size_override("font_size", 14 if i % 2 == 0 else 11)
		var offset = Vector2(randf_range(-25, 25), randf_range(-15, 10))
		lbl.position = pos + Vector2(-10, -40) + offset
		$FloatingContainer.add_child(lbl)
		
		var tw = create_tween()
		var target_y = lbl.position.y - randf_range(40, 65)
		var target_x = lbl.position.x + randf_range(-18, 18)
		tw.tween_property(lbl, "position", Vector2(target_x, target_y), 0.75 + i * 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.75 + i * 0.08)
		tw.finished.connect(func(): lbl.queue_free())

# --- ĐỒNG BỘ NỘI THẤT DO NGƯỜI CHƠI TỰ BÀI TRÍ TỪ DECOR STUDIO ---
func _sync_placed_decorations() -> void:
	var layer = y_sort_entities.get_node_or_null("PlacedDecorLayer")
	if layer == null:
		layer = Node2D.new()
		layer.name = "PlacedDecorLayer"
		layer.y_sort_enabled = true
		y_sort_entities.add_child(layer)
		
	for child in layer.get_children():
		child.queue_free()
		
	var placed = GameManager.get_placed_decor()
	if placed.size() == 0:
		return

	var bed_synced = false
	var food_synced = false
	var water_synced = false
	var litter_synced = false

	for it in placed:
		var item_id = it.get("id", "")
		var px = float(it.get("pos_x", 270.0))
		var py = float(it.get("pos_y", 620.0))
		var flipped = bool(it.get("flipped", false))

		# 1. Đồng bộ Giường Nệm (Cushion Bed / Pink Bed / Box / Home)
		if not bed_synced and ("bed" in item_id or "cushion" in item_id or "home" in item_id or "box" in item_id):
			bed_synced = true
			cushion_bed.position = Vector2(px, py)
			cushion_bed.grid_coord = IsometricGrid.screen_to_grid(cushion_bed.position, origin)
			cushion_bed.scale = Vector2(-1.0 if flipped else 1.0, 1.0)
			var b_path = GameManager.get_furniture_sprite_path(item_id)
			if b_path != "" and cushion_bed.get("sprite_node") != null:
				var tex = GameManager.load_texture(b_path)
				if tex:
					cushion_bed.sprite_node.texture = tex
			continue

		# 2. Đồng bộ Chén Ăn (Food Bowl / Dual Bowl / Bag)
		if not food_synced and ("food_bowl" in item_id or "dual_bowl" in item_id):
			food_synced = true
			food_bowl.position = Vector2(px, py)
			food_bowl.grid_coord = IsometricGrid.screen_to_grid(food_bowl.position, origin)
			food_bowl.scale = Vector2(-1.0 if flipped else 1.0, 1.0)
			var f_path = GameManager.get_furniture_sprite_path(item_id)
			if f_path != "" and food_bowl.get("sprite_node") != null:
				var tex = GameManager.load_texture(f_path)
				if tex:
					food_bowl.sprite_node.texture = tex
			continue

		# 3. Đồng bộ Chén Nước / Đài Phun Nước (Water Bowl / Fountain)
		if not water_synced and ("water_bowl" in item_id or "water_fountain" in item_id):
			water_synced = true
			water_bowl.position = Vector2(px, py)
			water_bowl.grid_coord = IsometricGrid.screen_to_grid(water_bowl.position, origin)
			water_bowl.scale = Vector2(-1.0 if flipped else 1.0, 1.0)
			var w_path = GameManager.get_furniture_sprite_path(item_id)
			if w_path != "" and water_bowl.get("sprite_node") != null:
				var tex = GameManager.load_texture(w_path)
				if tex:
					water_bowl.sprite_node.texture = tex
			continue

		# 4. Đồng bộ Chậu Cát Vệ Sinh (Litter Box)
		if not litter_synced and "litter_box" in item_id:
			litter_synced = true
			litter_box.position = Vector2(px, py)
			litter_box.grid_coord = IsometricGrid.screen_to_grid(litter_box.position, origin)
			litter_box.scale = Vector2(-1.0 if flipped else 1.0, 1.0)
			continue

		# 5. Tất cả đồ trang trí khác (Kệ sách, Trụ cào, Thang leo, Cây xanh, Thảm, Tranh, Rèm...)
		var spr = Sprite2D.new()
		var path = GameManager.get_furniture_sprite_path(item_id)
		if path != "":
			spr.texture = GameManager.load_texture(path)
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		spr.position = Vector2(px, py - (spr.texture.get_height() * 0.4 if spr.texture else 0))
		spr.scale = Vector2(-1.0 if flipped else 1.0, 1.0)
		spr.set_meta("item_id", item_id)
		
		# Vùng tương tác chạm cho từng món đồ tự bài trí
		var touch = Control.new()
		touch.custom_minimum_size = Vector2(56, 56)
		touch.position = Vector2(-28, -50)
		touch.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var item_id_copy = item_id
		var pos_copy = spr.position
		touch.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				_on_custom_decor_interacted(item_id_copy, pos_copy)
		)
		spr.add_child(touch)
		layer.add_child(spr)

func _on_custom_decor_interacted(item_id: String, pos: Vector2) -> void:
	var target_grid = IsometricGrid.screen_to_grid(pos, origin)
	if "bookshelf" in item_id:
		SoundManager.play_confirm()
		iso_cat.walk_to_grid(target_grid, iso_cat.State.IDLE)
		_spawn_floating_text(pos + Vector2(0, -35), "📚 Kệ Sách: Khám phá Kỹ Năng Sống!", Color(0.2, 0.65, 0.95))
		GameManager.update_stats(0, 0, +5, +15)
		emit_signal("open_skill_tree_requested")
	elif "water_fountain" in item_id:
		SoundManager.play_purr()
		iso_cat.walk_to_grid(target_grid, iso_cat.State.DRINK)
		_spawn_floating_text(pos + Vector2(0, -35), "⛲ Đài nước tuần hoàn: +15 Mood | +10 Dũng!", Color(0.2, 0.75, 0.9))
		GameManager.update_stats(0, 0, +10, +15)
	elif "dual_bowl" in item_id or "cat_food_bag" in item_id:
		SoundManager.play_chomp()
		iso_cat.walk_to_grid(target_grid, iso_cat.State.EAT)
		_spawn_floating_text(pos + Vector2(0, -35), "🍽️ Đĩa hạt ngon lành: +20 No | +10 Mood!", Color(0.9, 0.55, 0.2))
		GameManager.update_stats(0, +20, 0, +10)
	elif "cat_ladder" in item_id or "scratch_post" in item_id:
		SoundManager.play_purr()
		iso_cat.walk_to_grid(target_grid, iso_cat.State.SCRATCH)
		_spawn_floating_text(pos + Vector2(0, -35), "🪜 Mài móng leo trèo: +15 Dũng | +15 Mood!", Color(0.95, 0.55, 0.2))
		GameManager.update_stats(0, 0, +15, +15)
	elif "toy_yarn_ball" in item_id:
		SoundManager.play_bounce()
		_drop_toy_and_chase(target_grid)
		_spawn_floating_text(pos + Vector2(0, -35), "🧶 Vờn cuộn len vui vẻ: +15 Mood!", Color(0.95, 0.45, 0.6))
		GameManager.update_stats(0, 0, +5, +15)
	elif "monstera" in item_id or "bonsai" in item_id or "ficus" in item_id or "plant" in item_id:
		SoundManager.play_click()
		iso_cat.walk_to_grid(target_grid, iso_cat.State.IDLE)
		_spawn_floating_text(pos + Vector2(0, -35), "🪴 Tưới cây xanh mát: +10 Mood | +5 Dũng!", Color(0.25, 0.8, 0.35))
		GameManager.update_stats(0, 0, +5, +10)
	elif "rug" in item_id:
		SoundManager.play_click()
		iso_cat.walk_to_grid(target_grid, iso_cat.State.SLEEP)
		_spawn_floating_text(pos + Vector2(0, -35), "🧶 Thảm len dệt êm ái: +10 Mood!", Color(0.9, 0.6, 0.3))
		GameManager.update_stats(0, 0, +5, +10)
	elif "curtains" in item_id or "art" in item_id or "cactus" in item_id:
		SoundManager.play_click()
		iso_cat.walk_to_grid(target_grid, iso_cat.State.IDLE)
		_spawn_floating_text(pos + Vector2(0, -35), "🖼️ Góc phòng ấm cúng: +10 Mood!", Color(0.9, 0.7, 0.2))
		GameManager.update_stats(0, 0, +5, +10)
	elif "bed" in item_id or "home" in item_id:
		SoundManager.play_purr()
		iso_cat.walk_to_grid(target_grid, iso_cat.State.SLEEP)
		_spawn_floating_text(pos + Vector2(0, -35), "💤 Nằm nghỉ ngơi thư thái: +15 Mood!", Color(0.3, 0.7, 0.9))
		GameManager.update_stats(0, 0, +5, +15)
	else:
		SoundManager.play_click()
		iso_cat.walk_to_grid(target_grid, iso_cat.State.IDLE)
		_spawn_floating_text(pos + Vector2(0, -35), "✨ Đồ decor xinh xắn: +5 Mood!", Color(0.9, 0.65, 0.2))
		GameManager.update_stats(0, 0, +2, +5)

# =========================================================================
# GP-ROOM-01: KÉO THẢ TÚI HẠT VÀO BÁT ĐỒ ĂN & CHẾ ĐỘ NGỦ ẤM ÁP
# =========================================================================
func _setup_food_bag_interaction() -> void:
	# Drop zone trên chén ăn (nhận kéo từ BottomPawMenu hoặc túi hạt trong phòng)
	food_bowl_drop_zone = Control.new()
	food_bowl_drop_zone.name = "FoodBowlDropZone"
	food_bowl_drop_zone.custom_minimum_size = Vector2(72, 56)
	food_bowl_drop_zone.size = Vector2(72, 56)
	food_bowl_drop_zone.position = food_bowl.position - Vector2(36, 34)
	food_bowl_drop_zone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	food_bowl_drop_zone.set_drag_forwarding(
		func(_pos: Vector2): return null,
		func(_pos: Vector2, data):
			return data is Dictionary and data.get("type", "") == "food_bag",
		func(_pos: Vector2, _data):
			pour_food_bag_into_bowl()
	)
	add_child(food_bowl_drop_zone)

	# Túi hạt kéo trực tiếp trong phòng cạnh khay ăn
	food_bag_widget = TextureRect.new()
	food_bag_widget.name = "RoomFoodBagWidget"
	food_bag_widget.texture = FOOD_BAG_TEX
	food_bag_widget.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	food_bag_widget.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	food_bag_widget.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	food_bag_widget.size = Vector2(36, 52)
	food_bag_widget.position = food_bag_base_pos
	food_bag_widget.mouse_filter = Control.MOUSE_FILTER_STOP
	food_bag_widget.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	food_bag_widget.tooltip_text = "Kéo túi hạt thả vào bát ăn để cho Boss ăn!"

	food_bag_qty_lbl = Label.new()
	food_bag_qty_lbl.position = Vector2(18, 34)
	food_bag_qty_lbl.add_theme_font_size_override("font_size", 10)
	food_bag_qty_lbl.add_theme_color_override("font_color", Color(1.0, 0.96, 0.85))
	food_bag_qty_lbl.add_theme_color_override("font_outline_color", Color("#3d251e"))
	food_bag_qty_lbl.add_theme_constant_override("outline_size", 2)
	food_bag_widget.add_child(food_bag_qty_lbl)

	var bag_offset := Vector2.ZERO
	food_bag_widget.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
			if ev.pressed:
				is_dragging_food_bag = true
				bag_offset = food_bag_widget.position - ev.global_position
				SoundManager.play_click()
			else:
				if is_dragging_food_bag:
					is_dragging_food_bag = false
					var center: Vector2 = food_bag_widget.position + (food_bag_widget.size * 0.5)
					if center.distance_to(food_bowl.position) <= 68.0:
						pour_food_bag_into_bowl()
					var tw = create_tween()
					tw.tween_property(food_bag_widget, "position", food_bag_base_pos, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		elif ev is InputEventMouseMotion and is_dragging_food_bag:
			food_bag_widget.position = ev.global_position + bag_offset
	)
	add_child(food_bag_widget)
	_refresh_food_bag_widget()

func _refresh_food_bag_widget() -> void:
	if not food_bag_widget or not food_bag_qty_lbl:
		return
	var qty: int = GameManager.food_inventory.get("kibble", 0)
	food_bag_qty_lbl.text = "x%d" % qty
	food_bag_widget.modulate.a = 1.0 if qty > 0 else 0.45
	if food_bowl_drop_zone and food_bowl:
		food_bowl_drop_zone.position = food_bowl.position - Vector2(36, 34)

func pour_food_bag_into_bowl() -> bool:
	if GameManager.hunger >= 100:
		GameManager.can_feed()
		return false
	if GameManager.food_inventory.get("kibble", 0) <= 0:
		GameManager.feed_kibble()
		_refresh_food_bag_widget()
		return false
	feed_cat("kibble")
	if iso_cat.has_method("set_cozy_sleep_mode") and iso_cat.cozy_sleep_mode:
		iso_cat.set_cozy_sleep_mode(false)
	_refresh_food_bag_widget()
	return true

# =========================================================================
# GP-ROOM-02: DECOR MODE (NHẤN GIỮ 1.0s), LƯỚI 2.5D XANH/CAM & LƯU room_save.json
# =========================================================================
func _setup_decor_mode_ui() -> void:
	decor_mode_bar = PanelContainer.new()
	decor_mode_bar.name = "DecorModeBar"
	decor_mode_bar.visible = false
	decor_mode_bar.position = Vector2(20, 170)
	decor_mode_bar.custom_minimum_size = Vector2(500, 44)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.98, 0.94, 0.86, 0.95)
	style.border_color = Color(0.45, 0.28, 0.16, 1.0)
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	decor_mode_bar.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	decor_mode_bar.add_child(hbox)

	var lbl := Label.new()
	lbl.name = "HintLabel"
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.text = "🎨 Decor 2.5D: Chọn đồ rồi chạm ô lưới (Xanh: Hợp lệ)"
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color("#3d251e"))
	hbox.add_child(lbl)

	var btn_done := Button.new()
	btn_done.name = "BtnDoneDecor"
	btn_done.text = "✓ Xong"
	btn_done.custom_minimum_size = Vector2(78, 32)
	btn_done.pressed.connect(exit_decor_mode)
	hbox.add_child(btn_done)

	add_child(decor_mode_bar)

	# Nhãn tiện ích cách nhiệt & quạt mini trong phòng
	comfort_status_lbl = Label.new()
	comfort_status_lbl.name = "ComfortStatusLabel"
	comfort_status_lbl.position = Vector2(18, 224)
	comfort_status_lbl.add_theme_font_size_override("font_size", 10)
	comfort_status_lbl.add_theme_color_override("font_color", Color(0.25, 0.45, 0.35))
	comfort_status_lbl.visible = false
	add_child(comfort_status_lbl)

func _update_comfort_badge() -> void:
	if not comfort_status_lbl:
		return
	var summary: Dictionary = GameManager.get_room_comfort_summary()
	var tags: Array[String] = []
	if summary.get("heat_insulation", false):
		tags.append("🪟 Cách nhiệt -5°C")
	if summary.get("mini_fan", false):
		tags.append("🌬️ Quạt Mini mát mẻ")
	if tags.size() > 0:
		comfort_status_lbl.text = " • ".join(tags)
		comfort_status_lbl.visible = true
	else:
		comfort_status_lbl.visible = false

func _get_furniture_map() -> Dictionary:
	return {
		"cushion_bed": cushion_bed,
		"food_bowl": food_bowl,
		"water_bowl": water_bowl,
		"litter_box": litter_box
	}

func _apply_saved_furniture_positions() -> void:
	var furn_map := _get_furniture_map()
	for k in GameManager.furniture_grid_positions.keys():
		if furn_map.has(k):
			var pos_dict = GameManager.furniture_grid_positions[k]
			if pos_dict is Dictionary and pos_dict.has("u") and pos_dict.has("v"):
				var cell := Vector2i(int(pos_dict["u"]), int(pos_dict["v"]))
				if cell.x >= 0 and cell.x < IsometricGrid.GRID_SIZE and cell.y >= 0 and cell.y < IsometricGrid.GRID_SIZE:
					var node: Node2D = furn_map[k]
					var g_vec := Vector2(float(cell.x) + 0.5, float(cell.y) + 0.5)
					node.position = IsometricGrid.grid_to_screen(g_vec, origin)
					node.grid_coord = g_vec

func enter_decor_mode(at_pos: Vector2 = Vector2.ZERO) -> void:
	if is_decor_mode:
		return
	is_decor_mode = true
	selected_decor_furn_key = "cushion_bed"
	roam_timer.stop()
	room_canvas.set_decor_grid_visible(true)
	if at_pos != Vector2.ZERO:
		var g := IsometricGrid.screen_to_grid(at_pos, origin)
		var cell := Vector2i(floori(g.x), floori(g.y))
		room_canvas.set_grid_highlight(cell, is_grid_cell_valid(cell, selected_decor_furn_key))
	if decor_mode_bar:
		decor_mode_bar.visible = true
	SoundManager.play_confirm()
	SoundManager.vibrate(15)
	_spawn_floating_text(Vector2(270, 260), "🎨 Bật Chế Độ Decor 2.5D!", Color(0.2, 0.72, 0.4))

func exit_decor_mode() -> void:
	if not is_decor_mode:
		return
	is_decor_mode = false
	selected_decor_furn_key = ""
	room_canvas.set_decor_grid_visible(false)
	if decor_mode_bar:
		decor_mode_bar.visible = false
	GameManager.save_room_state()
	roam_timer.start(randf_range(4.0, 7.0))
	SoundManager.play_click()

func _select_furniture_for_decor(furn_key: String) -> void:
	selected_decor_furn_key = furn_key
	SoundManager.play_click()
	if decor_mode_bar:
		var lbl := decor_mode_bar.find_child("HintLabel", true, false) as Label
		if lbl:
			lbl.text = "🎨 Đang chọn: %s • Chạm ô lưới Xanh để đặt" % furn_key

func is_grid_cell_valid(cell: Vector2i, ignore_key: String = "") -> bool:
	if cell.x < 0 or cell.x >= IsometricGrid.GRID_SIZE or cell.y < 0 or cell.y >= IsometricGrid.GRID_SIZE:
		return false
	var furn_map := _get_furniture_map()
	for k in furn_map.keys():
		if k == ignore_key:
			continue
		var node: Node2D = furn_map[k]
		if node:
			var occupied := Vector2i(floori(node.grid_coord.x), floori(node.grid_coord.y))
			if occupied == cell:
				return false
	return true

func move_furniture_to_cell(furn_key: String, cell: Vector2i) -> bool:
	if not is_grid_cell_valid(cell, furn_key):
		return false
	var furn_map := _get_furniture_map()
	if not furn_map.has(furn_key):
		return false
	var node: Node2D = furn_map[furn_key]
	var g_vec := Vector2(float(cell.x) + 0.5, float(cell.y) + 0.5)
	node.position = IsometricGrid.grid_to_screen(g_vec, origin)
	node.grid_coord = g_vec
	if furn_key == "food_bowl" and food_bowl_drop_zone:
		food_bowl_drop_zone.position = node.position - Vector2(36, 34)
	GameManager.set_furniture_grid_pos(furn_key, cell)
	node.play_click_reaction()
	SoundManager.play_wooden_pop()
	return true

func _handle_decor_floor_click(click_pos: Vector2) -> void:
	var g := IsometricGrid.screen_to_grid(click_pos, origin)
	var cell := Vector2i(floori(g.x), floori(g.y))
	if selected_decor_furn_key == "":
		selected_decor_furn_key = "cushion_bed"
	var valid: bool = is_grid_cell_valid(cell, selected_decor_furn_key)
	room_canvas.set_grid_highlight(cell, valid)
	if not valid:
		SoundManager.play_fail()
		_spawn_floating_text(click_pos, "⚠️ Ô cam: Vướng đồ / Ngoài sàn!", Color(0.95, 0.5, 0.15))
		return
	if move_furniture_to_cell(selected_decor_furn_key, cell):
		_spawn_floating_text(click_pos + Vector2(0, -24), "✓ Đã đặt gọn vào lưới (%d,%d)" % [cell.x, cell.y], Color(0.2, 0.8, 0.35))
