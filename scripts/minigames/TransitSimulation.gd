extends Control

# TransitSimulation.gd - Module Giả Lập Hệ Thống & Xúc Giác: Trụ Cột Giao Thông & Văn Hóa Đô Thị
# Thiết kế 3 Cấp Độ (Basic -> Intermediate -> Advanced) theo triết lý Impeccable Educational Micro-Game
# Level 1: "Bắt Đúng Tuyến & Quẹt Thẻ NFC" (Observation & Timing Wave + 0.6s RFID Dwell)
# Level 2: "Giờ Cao Điểm Metro Line 1" (Physics Balance & Spatial Etiquette - Balo trước ngực)
# Level 3: "Cứu Hộ Đêm Mưa & Bẫy Sửa Xe" (Motorbike Breakdown Diagnostic & Cost-Risk Negotiation)

signal minigame_completed(sim_steps)
signal back_requested

const JuicyButtonScript = preload("res://scripts/ui/JuicyButton.gd")

# =========================================================================
# ENUMS & CONSTANTS
# =========================================================================
enum Level {
	LEVEL_1_BUS_NFC = 1,
	LEVEL_2_METRO_ETIQUETTE = 2,
	LEVEL_3_MOTORBIKE_DIAGNOSTIC = 3
}

const TARGET_BUS_ROUTES = [1, 53, 150] # Các tuyến xe đúng lộ trình ĐH KHTN -> Bến Thành
const ALL_BUS_ROUTES = [1, 8, 19, 33, 53, 150]

# =========================================================================
# NODE REFERENCES (Được khởi tạo linh hoạt hoặc qua UI tree)
# =========================================================================
@onready var header_box: HBoxContainer = $Header
@onready var btn_back: Button = $Header/BtnBack
@onready var btn_help: Button = $Header/BtnHelp
@onready var title_lbl: Label = $Header/TitleLabel
@onready var level_badge_lbl: Label = $Header/LevelBadgeLabel

@onready var cat_speech_lbl: Label = $MascotBox/SpeechBubble/CatSpeechLabel
@onready var mascot_avatar: TextureRect = $MascotBox/CatAvatar

# Level Containers
@onready var level1_container: Control = $Level1Container
@onready var level2_container: Control = $Level2Container
@onready var level3_container: Control = $Level3Container

# Modals
@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue_lbl: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

# =========================================================================
# STATE VARIABLES
# =========================================================================
var current_level: int = 1
var is_level_active: bool = false
var safe_failure_count: int = 0
var completed_levels: Dictionary = {} # level_idx -> true

# State Level 1: Bus & NFC
var bus_position_x: float = -120.0
var current_bus_route: int = 8
var is_bus_stopped: bool = false
var is_waving: bool = false
var wave_hold_time: float = 0.0
var nfc_dwell_time: float = 0.0
var is_nfc_card_held: bool = false
var nfc_success: bool = false

# State Level 2: Metro Physics & Etiquette
var is_backpack_in_front: bool = false
var current_inertia_x: float = 0.0
var balance_slider_value: float = 50.0 # 0..100, cân bằng ở 50
var balance_hold_timer: float = 0.0
var turns_cleared: int = 0
var max_turns_required: int = 3
var npc_collision_count: int = 0

# State Level 3: Motorbike Diagnostic
var is_headlight_checked: bool = false
var is_horn_checked: bool = false
var is_exhaust_inspected: bool = false
var is_tire_inspected: bool = false
var diagnostic_finished: bool = false
var negotiation_resolved: bool = false

var polaroid_ticket_panel: PanelContainer = null

# =========================================================================
# LIFECYCLE
# =========================================================================
func _ready() -> void:
	_setup_header_and_buttons()
	if victory_modal: victory_modal.visible = false
	if not is_level_active:
		load_level(1)

func _process(delta: float) -> void:
	if not is_level_active:
		return
		
	match current_level:
		Level.LEVEL_1_BUS_NFC:
			_process_level1_bus(delta)
		Level.LEVEL_2_METRO_ETIQUETTE:
			_process_level2_metro(delta)
		Level.LEVEL_3_MOTORBIKE_DIAGNOSTIC:
			_process_level3_diagnostic(delta)

# =========================================================================
# SETUP & NAVIGATION
# =========================================================================
func _setup_header_and_buttons() -> void:
	if btn_back:
		btn_back.pressed.connect(func():
			SoundManager.play_click()
			emit_signal("back_requested")
		)
		JuicyButtonScript.attach_juice(btn_back, true)
		
	if btn_help:
		btn_help.pressed.connect(_on_help_pressed)
		JuicyButtonScript.attach_juice(btn_help, true)
		
	if btn_claim_reward:
		btn_claim_reward.pressed.connect(_on_claim_reward_pressed)
		JuicyButtonScript.attach_juice(btn_claim_reward, true)

func load_minigame(data: Dictionary = {}) -> void:
	var req_lvl = data.get("level", 1)
	load_level(req_lvl)

func load_level(lvl_idx: int) -> void:
	current_level = clampi(lvl_idx, 1, 3)
	is_level_active = true
	safe_failure_count = 0
	
	if level1_container: level1_container.visible = (current_level == 1)
	if level2_container: level2_container.visible = (current_level == 2)
	if level3_container: level3_container.visible = (current_level == 3)
	
	match current_level:
		1:
			level_badge_lbl.text = "CẤP ĐỘ 1 / 3: BẮT ĐÚNG TUYẾN"
			title_lbl.text = "Giao Thông Đô Thị: Xe Buýt & NFC"
			cat_speech_lbl.text = "Meo! Xem bảng lộ trình ĐH KHTN ➔ Bến Thành trên điện thoại, vẫy đúng tuyến 01, 53, 150 và giữ thẻ NFC 0.6s nha Sen! 🐾"
			_init_level1_bus_nfc()
		2:
			level_badge_lbl.text = "CẤP ĐỘ 2 / 3: GIỜ CAO ĐIỂM METRO"
			title_lbl.text = "Metro Tuyến 1: Văn Hóa Balo & Giữ Thăng Bằng"
			cat_speech_lbl.text = "Khoang tàu đông đúc! Bấm nút Đeo Balo Trước Ngực để tránh va vào người khác và giữ vững thăng bằng khi tàu vào cua nhé! 🚇"
			_init_level2_metro()
		3:
			level_badge_lbl.text = "CẤP ĐỘ 3 / 3: CỨU HỘ ĐÊM MƯA"
			title_lbl.text = "Xe Máy Chết Máy & Né Bẫy Chặt Chém"
			cat_speech_lbl.text = "Trời mưa 8h tối xe chết máy! Hãy thử đề đèn/còi và soi lốp/pô để chẩn đoán chính xác, đừng để thợ vẽ bệnh thay IC oan nhé Sen! 🛵"
			_init_level3_motorbike()

# =========================================================================
# LEVEL 1: BẮT ĐÚNG TUYẾN XE BUÝT & QUẸT THẺ NFC 0.6S
# =========================================================================
var bus_speed: float = 160.0
var bus_rect: ColorRect = null
var bus_label: Label = null
var wave_progress_bar: ProgressBar = null
var nfc_ring_panel: Control = null
var nfc_card_btn: Button = null
var bus_nfc_panel: Control = null

func _init_level1_bus_nfc() -> void:
	bus_position_x = -140.0
	is_bus_stopped = false
	is_waving = false
	wave_hold_time = 0.0
	nfc_dwell_time = 0.0
	is_nfc_card_held = false
	nfc_success = false
	
	_spawn_next_bus()
	_build_level1_ui()

func _spawn_next_bus() -> void:
	bus_position_x = -140.0
	is_bus_stopped = false
	wave_hold_time = 0.0
	# Chọn ngẫu nhiên tuyến xe, 50% cơ hội rơi vào tuyến đúng để người chơi quan sát
	if randf() < 0.5:
		current_bus_route = TARGET_BUS_ROUTES[randi() % TARGET_BUS_ROUTES.size()]
	else:
		current_bus_route = ALL_BUS_ROUTES[randi() % ALL_BUS_ROUTES.size()]
		
	if bus_label:
		bus_label.text = "XE BUÝT SỐ %02d" % current_bus_route

func _build_level1_ui() -> void:
	if not level1_container: return
	for ch in level1_container.get_children():
		ch.queue_free()
		
	var v_box = VBoxContainer.new()
	v_box.name = "Level1VBox"
	v_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	v_box.add_theme_constant_override("separation", 10)
	
	# 1. Điện thoại mini BusMap (Góc trên)
	var phone_panel = PanelContainer.new()
	phone_panel.custom_minimum_size = Vector2(0, 75)
	var sb_phone = StyleBoxFlat.new()
	sb_phone.bg_color = Color(0.12, 0.20, 0.32, 0.95)
	sb_phone.border_color = Color(0.25, 0.65, 0.95, 1.0)
	sb_phone.set_border_width_all(2)
	sb_phone.set_corner_radius_all(10)
	phone_panel.add_theme_stylebox_override("panel", sb_phone)
	
	var phone_lbl = Label.new()
	phone_lbl.text = "📱 BUSMAP SÀI GÒN:\n📍 Lộ trình: ĐH Khoa Học Tự Nhiên ➔ Chợ Bến Thành\n🚌 Tuyến chấp nhận: 01, 53, 150 (Các xe khác đi sai hướng!)"
	phone_lbl.add_theme_font_size_override("font_size", 11)
	phone_lbl.add_theme_color_override("font_color", Color(0.9, 0.96, 1.0, 1.0))
	phone_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	phone_panel.add_child(phone_lbl)
	v_box.add_child(phone_panel)
	
	# 2. Khu vực lòng đường 2D giả lập
	var road_area = Panel.new()
	road_area.name = "RoadArea"
	road_area.custom_minimum_size = Vector2(0, 120)
	var sb_road = StyleBoxFlat.new()
	sb_road.bg_color = Color(0.25, 0.26, 0.28, 1.0)
	road_area.add_theme_stylebox_override("panel", sb_road)
	
	# Vạch trạm đón xe (Trigger Zone: x 360..480)
	var trigger_indicator = ColorRect.new()
	trigger_indicator.name = "TriggerZone"
	trigger_indicator.position = Vector2(360, 0)
	trigger_indicator.size = Vector2(130, 120)
	trigger_indicator.color = Color(0.2, 0.8, 0.4, 0.25)
	road_area.add_child(trigger_indicator)
	
	var trigger_lbl = Label.new()
	trigger_lbl.text = "TRẠM CHỜ\nVẪY XE TẠI ĐÂY"
	trigger_lbl.add_theme_font_size_override("font_size", 9)
	trigger_lbl.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5, 0.9))
	trigger_lbl.position = Vector2(370, 8)
	road_area.add_child(trigger_lbl)
	
	# Xe buýt 2D
	bus_rect = ColorRect.new()
	bus_rect.name = "BusVisual"
	bus_rect.size = Vector2(150, 65)
	bus_rect.position = Vector2(-150, 25)
	bus_rect.color = Color(0.85, 0.22, 0.22, 1.0) # Xe buýt đỏ Sài Gòn
	
	bus_label = Label.new()
	bus_label.name = "BusLedLabel"
	bus_label.text = "XE BUÝT SỐ %02d" % current_bus_route
	bus_label.add_theme_font_size_override("font_size", 10)
	bus_label.add_theme_color_override("font_color", Color(1, 1, 0.2, 1.0))
	bus_label.position = Vector2(12, 12)
	bus_rect.add_child(bus_label)
	road_area.add_child(bus_rect)
	v_box.add_child(road_area)
	
	# 3. Nút giữ Vẫy Xe (Timing Wave)
	var wave_hbox = HBoxContainer.new()
	wave_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	wave_hbox.add_theme_constant_override("separation", 12)
	
	var btn_wave = Button.new()
	btn_wave.name = "BtnWave"
	btn_wave.text = "🙋 GIỮ NÚT ĐỂ VẪY XE (0.4s)"
	btn_wave.custom_minimum_size = Vector2(220, 48)
	btn_wave.add_theme_font_size_override("font_size", 12)
	btn_wave.button_down.connect(func(): is_waving = true)
	btn_wave.button_up.connect(func(): is_waving = false; wave_hold_time = 0.0)
	JuicyButtonScript.attach_juice(btn_wave, true)
	wave_hbox.add_child(btn_wave)
	
	wave_progress_bar = ProgressBar.new()
	wave_progress_bar.custom_minimum_size = Vector2(120, 24)
	wave_progress_bar.max_value = 0.4
	wave_progress_bar.value = 0.0
	wave_progress_bar.show_percentage = false
	wave_hbox.add_child(wave_progress_bar)
	v_box.add_child(wave_hbox)
	
	# 4. Bảng quẹt thẻ NFC khi xe đã tấp lề
	bus_nfc_panel = PanelContainer.new()
	bus_nfc_panel.name = "NfcPanel"
	bus_nfc_panel.custom_minimum_size = Vector2(0, 150)
	bus_nfc_panel.visible = false
	var sb_nfc = StyleBoxFlat.new()
	sb_nfc.bg_color = Color(0.97, 0.95, 0.91, 1.0)
	sb_nfc.border_color = Color(0.65, 0.45, 0.30, 1.0)
	sb_nfc.set_border_width_all(2)
	sb_nfc.set_corner_radius_all(10)
	bus_nfc_panel.add_theme_stylebox_override("panel", sb_nfc)
	
	var nfc_vbox = VBoxContainer.new()
	nfc_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	nfc_vbox.add_theme_constant_override("separation", 8)
	
	var nfc_instruct = Label.new()
	nfc_instruct.text = "📶 ĐẦU ĐỌC THẺ XE BUÝT THÔNG MINH\nNhấn giữ thẻ xe buýt vào đầu đọc đúng 0.6 giây để thanh toán vé:"
	nfc_instruct.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nfc_instruct.add_theme_font_size_override("font_size", 11)
	nfc_instruct.add_theme_color_override("font_color", Color(0.25, 0.20, 0.15, 1.0))
	nfc_vbox.add_child(nfc_instruct)
	
	var card_hbox = HBoxContainer.new()
	card_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card_hbox.add_theme_constant_override("separation", 16)
	
	nfc_card_btn = Button.new()
	nfc_card_btn.name = "BtnNfcCard"
	nfc_card_btn.text = "💳 GIỮ THẺ XE BUÝT (0.6s)"
	var card_tex = load("res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_02_bus_card.tres")
	if card_tex: nfc_card_btn.icon = card_tex
	nfc_card_btn.custom_minimum_size = Vector2(190, 50)
	nfc_card_btn.add_theme_font_size_override("font_size", 11)
	nfc_card_btn.button_down.connect(_on_nfc_card_down)
	nfc_card_btn.button_up.connect(_on_nfc_card_up)
	JuicyButtonScript.attach_juice(nfc_card_btn, true)
	card_hbox.add_child(nfc_card_btn)
	
	var nfc_progress = ProgressBar.new()
	nfc_progress.name = "NfcProgressBar"
	nfc_progress.custom_minimum_size = Vector2(120, 24)
	nfc_progress.max_value = 0.6
	nfc_progress.value = 0.0
	card_hbox.add_child(nfc_progress)
	nfc_vbox.add_child(card_hbox)
	
	bus_nfc_panel.add_child(nfc_vbox)
	v_box.add_child(bus_nfc_panel)
	
	level1_container.add_child(v_box)

func _process_level1_bus(delta: float) -> void:
	if not is_bus_stopped:
		bus_position_x += bus_speed * delta
		if bus_rect:
			bus_rect.position.x = bus_position_x
			
		# Xe chạy lố khỏi màn hình -> spawn xe tiếp theo
		if bus_position_x > 580:
			_spawn_next_bus()
			
		# Xử lý giữ nút Vẫy Xe
		if is_waving:
			# Kiểm tra xe có nằm trong TriggerZone (360 .. 490) không
			if bus_position_x >= 350.0 and bus_position_x <= 490.0:
				wave_hold_time += delta
				if wave_progress_bar: wave_progress_bar.value = wave_hold_time
				if wave_hold_time >= 0.4:
					_handle_bus_wave_success()
			else:
				wave_hold_time = 0.0
				if wave_progress_bar: wave_progress_bar.value = 0.0
		else:
			wave_hold_time = 0.0
			if wave_progress_bar: wave_progress_bar.value = 0.0
	else:
		# Xe đã tấp lề, đếm thời gian chạm thẻ NFC
		if is_nfc_card_held and not nfc_success:
			nfc_dwell_time += delta
			var bar = bus_nfc_panel.get_node_or_null("Level1VBox/NfcPanel/VBox/HBox/NfcProgressBar") if bus_nfc_panel else null
			if not bar and bus_nfc_panel:
				bar = bus_nfc_panel.find_child("NfcProgressBar", true, false)
			if bar: bar.value = nfc_dwell_time
			
			if nfc_dwell_time >= 0.6:
				_handle_nfc_success()

func _handle_bus_wave_success() -> void:
	# Kiểm tra xem xe có đúng tuyến (01, 53, 150) hay không
	if TARGET_BUS_ROUTES.has(current_bus_route):
		is_bus_stopped = true
		SoundManager.play_success()
		cat_speech_lbl.text = "Chuẩn rồi! Xe buýt số %02d đã tấp vào lề đón Sen! Hãy quẹt thẻ NFC lên xe nào!" % current_bus_route
		if bus_nfc_panel: bus_nfc_panel.visible = true
	else:
		# Bẫy sai tuyến
		safe_failure_count += 1
		SoundManager.play_card_pop()
		cat_speech_lbl.text = "CẢNH BÁO! 💡 Xe buýt số %02d không đi Bến Thành! Tuyến này đi ra Suối Tiên/Bình Dương đó Sen ơi! Hãy đợi đúng tuyến 01, 53 hoặc 150 nhé! 🐾" % current_bus_route
		wave_hold_time = 0.0
		is_waving = false
		bus_position_x = 520.0 # Cho xe chạy qua luôn

func _on_nfc_card_down() -> void:
	is_nfc_card_held = true
	nfc_dwell_time = 0.0
	SoundManager.play_click()

func _on_nfc_card_up() -> void:
	if not is_nfc_card_held: return
	is_nfc_card_held = false
	if not nfc_success and nfc_dwell_time < 0.55:
		SoundManager.play_card_pop()
		cat_speech_lbl.text = "TÍT TÍT! 💡 Chưa kịp đọc chip thẻ Sen ơi! Hãy nhấn giữ thẻ trên 0.6 giây để hệ thống nhận diện nhé! 🐾"
		nfc_dwell_time = 0.0
		var bar = bus_nfc_panel.find_child("NfcProgressBar", true, false) if bus_nfc_panel else null
		if bar: bar.value = 0.0

func _handle_nfc_success() -> void:
	nfc_success = true
	SoundManager.play_success()
	completed_levels[1] = true
	cat_speech_lbl.text = "🎉 BÍP! Quẹt thẻ NFC thành công! Trừ 5.000đ vé sinh viên! Cửa mở đón Sen & Mochi lên xe an toàn! ✨"
	
	# Tự động mở chuyển sang Level 2 sau 1.5s
	get_tree().create_timer(1.2).timeout.connect(func():
		load_level(2)
	)

# =========================================================================
# LEVEL 2: GIỜ CAO ĐIỂM METRO LINE 1 (VĂN HÓA BALO & CÂN BẰNG QUÁN TÍNH)
# =========================================================================
var metro_balance_slider: HSlider = null
var backpack_btn: Button = null
var metro_status_lbl: Label = null
var current_turn_direction: float = 1.0 # 1.0: sang phải, -1.0: sang trái

func _init_level2_metro() -> void:
	is_backpack_in_front = false
	balance_slider_value = 50.0
	balance_hold_timer = 0.0
	turns_cleared = 0
	npc_collision_count = 0
	_build_level2_ui()

func _build_level2_ui() -> void:
	if not level2_container: return
	for ch in level2_container.get_children(): ch.queue_free()
	
	var v_box = VBoxContainer.new()
	v_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	v_box.add_theme_constant_override("separation", 10)
	
	# 1. Trạng thái khoang tàu
	var status_panel = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.96, 0.98, 1.0, 1.0)
	sb.border_color = Color(0.2, 0.6, 0.9, 1.0)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	status_panel.add_theme_stylebox_override("panel", sb)
	
	metro_status_lbl = Label.new()
	metro_status_lbl.text = "🚇 METRO SỐ 1 BẾN THÀNH - SUỐI TIÊN\nTàu đông giờ cao điểm! Đeo balo trước ngực và giữ thăng bằng qua 3 khúc cua:"
	metro_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	metro_status_lbl.add_theme_font_size_override("font_size", 11)
	metro_status_lbl.add_theme_color_override("font_color", Color(0.1, 0.3, 0.5, 1.0))
	status_panel.add_child(metro_status_lbl)
	v_box.add_child(status_panel)
	
	# 2. Nút Toggle Đeo Balo Trước Ngực
	var bag_hbox = HBoxContainer.new()
	bag_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	backpack_btn = Button.new()
	backpack_btn.name = "BtnToggleBackpack"
	backpack_btn.text = "🎒 TƯ THẾ HIỆN TẠI: ĐEO SAU LƯNG (RỘNG 80px - DỄ VA CHẠM)"
	backpack_btn.custom_minimum_size = Vector2(340, 46)
	backpack_btn.add_theme_font_size_override("font_size", 11)
	backpack_btn.pressed.connect(_on_toggle_backpack_pressed)
	JuicyButtonScript.attach_juice(backpack_btn, true)
	bag_hbox.add_child(backpack_btn)
	v_box.add_child(bag_hbox)
	
	# 3. Khu vực giữ thăng bằng quán tính với thanh trượt gỗ
	var balance_panel = PanelContainer.new()
	balance_panel.custom_minimum_size = Vector2(0, 110)
	var sb_bal = StyleBoxFlat.new()
	sb_bal.bg_color = Color(0.98, 0.96, 0.92, 1.0)
	sb_bal.border_color = Color(0.75, 0.55, 0.35, 1.0)
	sb_bal.set_border_width_all(2)
	sb_bal.set_corner_radius_all(10)
	balance_panel.add_theme_stylebox_override("panel", sb_bal)
	
	var bal_vbox = VBoxContainer.new()
	bal_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	bal_vbox.add_theme_constant_override("separation", 8)
	
	var bal_title = Label.new()
	bal_title.text = "⚖️ THANH THĂNG BẰNG QUÁN TÍNH TÀU ĐIỆN (VÙNG AN TOÀN: 40 - 60):"
	bal_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bal_title.add_theme_font_size_override("font_size", 10)
	bal_title.add_theme_color_override("font_color", Color(0.4, 0.25, 0.15, 1.0))
	bal_vbox.add_child(bal_title)
	
	metro_balance_slider = HSlider.new()
	metro_balance_slider.name = "MetroBalanceSlider"
	metro_balance_slider.min_value = 0.0
	metro_balance_slider.max_value = 100.0
	metro_balance_slider.value = 50.0
	metro_balance_slider.custom_minimum_size = Vector2(320, 36)
	
	# Gắn track & grabber gỗ nếu có
	var track_tex = load("res://assets/UI/CatUIPaid/slices/slider_track_brown.png")
	var knob_tex = load("res://assets/UI/CatUIPaid/slices/slider_knob_wood.png")
	if knob_tex:
		metro_balance_slider.add_theme_icon_override("grabber", knob_tex)
		metro_balance_slider.add_theme_icon_override("grabber_highlight", knob_tex)
		
	metro_balance_slider.value_changed.connect(func(val): balance_slider_value = val)
	bal_vbox.add_child(metro_balance_slider)
	
	var turn_lbl = Label.new()
	turn_lbl.name = "TurnCounterLabel"
	turn_lbl.text = "Đã vượt qua: 0 / 3 khúc cua quán tính"
	turn_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_lbl.add_theme_font_size_override("font_size", 10)
	turn_lbl.add_theme_color_override("font_color", Color(0.2, 0.55, 0.3, 1.0))
	bal_vbox.add_child(turn_lbl)
	
	balance_panel.add_child(bal_vbox)
	v_box.add_child(balance_panel)
	
	level2_container.add_child(v_box)

func _on_toggle_backpack_pressed() -> void:
	is_backpack_in_front = not is_backpack_in_front
	SoundManager.play_click()
	if is_backpack_in_front:
		backpack_btn.text = "✅ ĐÃ ĐEO TRƯỚC NGỰC (GỌN 48px - BẢO VỆ MOCHI AN TOÀN!)"
		backpack_btn.add_theme_color_override("font_color", Color(0.1, 0.6, 0.2, 1.0))
		cat_speech_lbl.text = "Tuyệt vời! Balo đeo trước ngực giúp giảm 40% diện tích va chạm và Mochi trong túi vận chuyển được an toàn! 🐾"
	else:
		backpack_btn.text = "🎒 TƯ THẾ HIỆN TẠI: ĐEO SAU LƯNG (RỘNG 80px - DỄ VA CHẠM)"
		backpack_btn.add_theme_color_override("font_color", Color(0.8, 0.2, 0.1, 1.0))
		cat_speech_lbl.text = "Cẩn thận! Đeo sau lưng trong khoang đông rất dễ va đập vào người khác đó Sen!"

func _process_level2_metro(delta: float) -> void:
	# Lực quán tính đẩy con trượt trôi dạt
	current_inertia_x = sin(Time.get_ticks_msec() / 600.0) * 25.0 * current_turn_direction
	
	# Nếu người chơi không tương tác, giá trị bị kéo dạt
	if not is_backpack_in_front:
		# Nếu đeo sau lưng, mỗi lần rung lắc lớn sẽ va chạm NPC
		if abs(current_inertia_x) > 20.0 and randf() < 0.05:
			npc_collision_count += 1
			cat_speech_lbl.text = "Ối! Balo sau lưng vừa quẹt trúng hành khách bên cạnh! Mau bấm nút Đeo Balo Trước Ngực đi Sen ơi! 😿"
			
	# Kiểm tra thanh thăng bằng trong vùng an toàn (38 .. 62)
	if balance_slider_value >= 38.0 and balance_slider_value <= 62.0:
		balance_hold_timer += delta
		if balance_hold_timer >= 2.0:
			balance_hold_timer = 0.0
			turns_cleared += 1
			current_turn_direction *= -1.0 # Đổi hướng cua tiếp theo
			SoundManager.play_success()
			
			var turn_lbl = level2_container.find_child("TurnCounterLabel", true, false) as Label
			if turn_lbl:
				turn_lbl.text = "Đã vượt qua: %d / %d khúc cua quán tính" % [turns_cleared, max_turns_required]
				
			if turns_cleared >= max_turns_required:
				_handle_metro_success()
			else:
				cat_speech_lbl.text = "Tốt lắm! Đã giữ vững thăng bằng khúc cua %d! Chuẩn bị cua tiếp theo!" % turns_cleared
	else:
		balance_hold_timer = maxf(0.0, balance_hold_timer - delta * 0.5)

func _handle_metro_success() -> void:
	completed_levels[2] = true
	SoundManager.play_success()
	cat_speech_lbl.text = "🎉 XUẤT SẮC! Hoàn thành hành trình Metro văn minh, giữ thăng bằng an toàn và tôn trọng không gian chung! ✨"
	
	get_tree().create_timer(1.2).timeout.connect(func():
		load_level(3)
	)

# =========================================================================
# LEVEL 3: CỨU HỘ ĐÊM MƯA & BẪY SỬA XE (DIAGNOSTIC & COST-RISK)
# =========================================================================
var btn_starter: Button = null
var btn_exhaust: Button = null
var btn_tire: Button = null
var btn_refuse_scam: Button = null
var btn_agree_scam: Button = null
var btn_student_rescue: Button = null

func _init_level3_motorbike() -> void:
	is_headlight_checked = false
	is_horn_checked = false
	is_exhaust_inspected = false
	is_tire_inspected = false
	diagnostic_finished = false
	negotiation_resolved = false
	_build_level3_ui()

func _build_level3_ui() -> void:
	if not level3_container: return
	for ch in level3_container.get_children(): ch.queue_free()
	
	var v_box = VBoxContainer.new()
	v_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	v_box.add_theme_constant_override("separation", 8)
	
	# Bối cảnh sự cố đêm mưa
	var scene_panel = PanelContainer.new()
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(0.12, 0.15, 0.22, 1.0)
	sb.border_color = Color(0.35, 0.45, 0.65, 1.0)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(10)
	scene_panel.add_theme_stylebox_override("panel", sb)
	
	var scene_lbl = Label.new()
	scene_lbl.text = "🌧️ 8:00 TỐI TRỜI MƯA TO - XE MÁY ĐỘT NHIÊN CHẾT MÁY VEN ĐƯỜNG\nHãy kiểm tra 3 vị trí trên xe để chẩn đoán chính xác nguyên nhân thực sự:"
	scene_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scene_lbl.add_theme_font_size_override("font_size", 11)
	scene_lbl.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0, 1.0))
	scene_panel.add_child(scene_lbl)
	v_box.add_child(scene_panel)
	
	# 3 Nút chẩn đoán xe máy
	var diag_hbox = HBoxContainer.new()
	diag_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	diag_hbox.add_theme_constant_override("separation", 10)
	
	btn_starter = Button.new()
	btn_starter.name = "BtnTestStarter"
	btn_starter.text = "⚡ BẤM ĐỀ & CÒI"
	btn_starter.custom_minimum_size = Vector2(110, 48)
	btn_starter.add_theme_font_size_override("font_size", 10)
	btn_starter.pressed.connect(_on_test_starter_pressed)
	JuicyButtonScript.attach_juice(btn_starter, true)
	diag_hbox.add_child(btn_starter)
	
	btn_exhaust = Button.new()
	btn_exhaust.name = "BtnInspectExhaust"
	btn_exhaust.text = "🔍 SOI ỐNG PÔ/XẢ"
	btn_exhaust.custom_minimum_size = Vector2(110, 48)
	btn_exhaust.add_theme_font_size_override("font_size", 10)
	btn_exhaust.pressed.connect(_on_inspect_exhaust_pressed)
	JuicyButtonScript.attach_juice(btn_exhaust, true)
	diag_hbox.add_child(btn_exhaust)
	
	btn_tire = Button.new()
	btn_tire.name = "BtnInspectTire"
	btn_tire.text = "🛞 KIỂM TRA LỐP"
	btn_tire.custom_minimum_size = Vector2(110, 48)
	btn_tire.add_theme_font_size_override("font_size", 10)
	btn_tire.pressed.connect(_on_inspect_tire_pressed)
	JuicyButtonScript.attach_juice(btn_tire, true)
	diag_hbox.add_child(btn_tire)
	
	v_box.add_child(diag_hbox)
	
	# Khu vực thợ sửa xe chặt chém
	var scam_panel = PanelContainer.new()
	scam_panel.name = "ScamNegotiationPanel"
	var sb_scam = StyleBoxFlat.new()
	sb_scam.bg_color = Color(0.98, 0.94, 0.92, 1.0)
	sb_scam.border_color = Color(0.85, 0.35, 0.25, 1.0)
	sb_scam.set_border_width_all(2)
	sb_scam.set_corner_radius_all(10)
	scam_panel.add_theme_stylebox_override("panel", sb_scam)
	
	var scam_vbox = VBoxContainer.new()
	scam_vbox.add_theme_constant_override("separation", 6)
	
	var scam_prompt = Label.new()
	scam_prompt.text = "🗣️ THỢ SỬA XE PHÁN: 'Cháy IC rồi em ơi! Thay IC 800k, thay ruột 350k, tổng 1.150.000đ!'"
	scam_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scam_prompt.add_theme_font_size_override("font_size", 11)
	scam_prompt.add_theme_color_override("font_color", Color(0.8, 0.2, 0.1, 1.0))
	scam_vbox.add_child(scam_prompt)
	
	var handbook_hint = Label.new()
	handbook_hint.text = "📖 Sổ tay giá chuẩn: Vá lốp 25k, thay ruột 90k • Xe còi to đèn sáng = IC KHÔNG HỎNG!"
	handbook_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	handbook_hint.add_theme_font_size_override("font_size", 10)
	handbook_hint.add_theme_color_override("font_color", Color(0.2, 0.5, 0.2, 1.0))
	scam_vbox.add_child(handbook_hint)
	
	var opt_hbox = HBoxContainer.new()
	opt_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	opt_hbox.add_theme_constant_override("separation", 8)
	
	btn_agree_scam = Button.new()
	btn_agree_scam.name = "BtnAgreeScam"
	btn_agree_scam.text = "❌ Đồng ý thay IC 800k\n(Chấp nhận giá chặt chém)"
	btn_agree_scam.add_theme_font_size_override("font_size", 10)
	btn_agree_scam.pressed.connect(_on_agree_scam_pressed)
	JuicyButtonScript.attach_juice(btn_agree_scam, true)
	opt_hbox.add_child(btn_agree_scam)
	
	btn_refuse_scam = Button.new()
	btn_refuse_scam.name = "BtnRefuseScam"
	btn_refuse_scam.text = "✔ Từ chối thay IC\n(Chỉ thay ruột 90k & xả nước)"
	btn_refuse_scam.add_theme_font_size_override("font_size", 10)
	btn_refuse_scam.pressed.connect(_on_refuse_scam_pressed)
	JuicyButtonScript.attach_juice(btn_refuse_scam, true)
	opt_hbox.add_child(btn_refuse_scam)
	
	btn_student_rescue = Button.new()
	btn_student_rescue.name = "BtnStudentRescue"
	btn_student_rescue.text = "📞 Gọi Cứu Hộ Sinh Viên\n(Hỗ trợ đẩy xe về KTX)"
	btn_student_rescue.add_theme_font_size_override("font_size", 10)
	btn_student_rescue.pressed.connect(_on_student_rescue_pressed)
	JuicyButtonScript.attach_juice(btn_student_rescue, true)
	opt_hbox.add_child(btn_student_rescue)
	
	scam_vbox.add_child(opt_hbox)
	scam_panel.add_child(scam_vbox)
	v_box.add_child(scam_panel)
	
	level3_container.add_child(v_box)

func _on_test_starter_pressed() -> void:
	SoundManager.play_click()
	is_headlight_checked = true
	is_horn_checked = true
	btn_starter.text = "⚡ ĐÈN SÁNG, CÒI TO ✔"
	cat_speech_lbl.text = "Bíp bíp! Đèn pha sáng rực, còi xe kêu to! Chứng tỏ bình ắc quy và IC hoàn toàn lành lặn, không hề bị cháy!"

func _on_inspect_exhaust_pressed() -> void:
	SoundManager.play_click()
	is_exhaust_inspected = true
	btn_exhaust.text = "🔍 ỐNG PÔ NGẬP NƯỚC ✔"
	cat_speech_lbl.text = "Nước mưa tràn vào ống pô gây ngộp bu-gi! Chỉ cần dựng chân chống nghiêng đạp nhồi xả nước ra là nổ máy được!"

func _on_inspect_tire_pressed() -> void:
	SoundManager.play_click()
	is_tire_inspected = true
	btn_tire.text = "🛞 LỐP BỊ ĐINH XẸP ✔"
	cat_speech_lbl.text = "Phát hiện 1 cây đinh găm vào lốp sau! Lốp xẹp lép, chỉ cần vá hoặc thay ruột mới giá 80k-90k là chạy tốt!"

func _process_level3_diagnostic(_delta: float) -> void:
	if is_headlight_checked and is_exhaust_inspected and is_tire_inspected:
		diagnostic_finished = true

func _on_agree_scam_pressed() -> void:
	SoundManager.play_card_pop()
	safe_failure_count += 1
	cat_speech_lbl.text = "ÚI GIỜI ƠI SEN! 💡 Đèn pha và còi xe vẫn hoạt động tốt thì IC KHÔNG HỂ HỎNG! Đồng ý là mất oan 800.000đ tiền mồ hôi nước mắt đó Sen ơi! 😿"

func _on_refuse_scam_pressed() -> void:
	SoundManager.play_success()
	negotiation_resolved = true
	completed_levels[3] = true
	cat_speech_lbl.text = "🎉 XUẤT SẮC! Thợ sửa xe chột dạ gật đầu: 'Thôi được rồi, thay ruột 90k và đạp nổ xả nước là xong!' Tiết kiệm hơn 1 triệu đồng! ✨"
	_show_transit_victory()

func _on_student_rescue_pressed() -> void:
	SoundManager.play_success()
	negotiation_resolved = true
	completed_levels[3] = true
	cat_speech_lbl.text = "🎉 QUYẾT ĐỊNH KHÔN NGOAN! Gọi đội cứu hộ sinh viên KTX tới hỗ trợ đẩy xe về, vừa an toàn vừa không bị chặt chém! ✨"
	_show_transit_victory()

# =========================================================================
# VICTORY & SUMMARY
# =========================================================================
func _show_transit_victory() -> void:
	SoundManager.play_success()
	var speech = "🎉 CHÚC MỪNG BẬC THẦY DI CHUYỂN ĐÔ THỊ!\n\n"
	speech += "Mèo con đã hoàn thành xuất sắc toàn bộ 3 Cấp độ Giả lập Giao thông:\n\n"
	speech += "✔ Cấp độ 1: Nhận diện tuyến buýt 01, 53, 150 & quẹt thẻ NFC đúng 0.6s.\n"
	speech += "✔ Cấp độ 2: Văn hóa đeo balo trước ngực & giữ thăng bằng quán tính Metro.\n"
	speech += "✔ Cấp độ 3: Chẩn đoán xe máy đêm mưa & đấu trí né bẫy thợ chặt chém 1 triệu đồng.\n\n"
	speech += "🎖️ Nhận danh hiệu 'Thổ Địa Giao Thông Văn Minh' & Thưởng +45 Cá Khô!"
	if victory_dialogue_lbl:
		victory_dialogue_lbl.text = speech
		
	_build_polaroid_transit_pass()
	if victory_modal:
		victory_modal.visible = true

func _build_polaroid_transit_pass() -> void:
	if polaroid_ticket_panel and is_instance_valid(polaroid_ticket_panel):
		polaroid_ticket_panel.queue_free()
		
	polaroid_ticket_panel = PanelContainer.new()
	polaroid_ticket_panel.name = "PolaroidTransitPass"
	polaroid_ticket_panel.custom_minimum_size = Vector2(0, 115)
	
	var sb = load("res://assets/UI/CatUIPaid/slices/cozy_achievements/polaroid_card_stylebox.tres")
	if sb:
		polaroid_ticket_panel.add_theme_stylebox_override("panel", sb)
	else:
		var flat = StyleBoxFlat.new()
		flat.bg_color = Color(1.0, 0.99, 0.95, 1.0)
		flat.border_color = Color(0.65, 0.45, 0.30, 1.0)
		flat.set_border_width_all(2)
		flat.set_corner_radius_all(10)
		polaroid_ticket_panel.add_theme_stylebox_override("panel", flat)
		
	var v = VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 4)
	
	var owner_name = GameManager.owner_name if "owner_name" in GameManager and GameManager.owner_name != "" else "Sen Thổ Địa"
	var room_name = GameManager.room_name if "room_name" in GameManager and GameManager.room_name != "" else "Phòng Trọ Số 1"
	
	var title = Label.new()
	title.text = "🎫 THẺ THÔNG HÀNH ĐÔ THỊ: XE BUÝT - METRO - XE MÁY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color(0.2, 0.45, 0.75, 1.0))
	v.add_child(title)
	
	var desc = Label.new()
	desc.text = "Cấp cho: %s • Trạm KTX: %s\nHoàn thành 3 cấp độ Giả lập Di chuyển thực tế • Không sợ lạc, không sợ bị chặt chém!" % [owner_name, room_name]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 9)
	desc.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3, 1.0))
	v.add_child(desc)
	
	polaroid_ticket_panel.add_child(v)
	
	var vbox = victory_modal.get_node_or_null("ModalPanel/VBox")
	if vbox:
		var scroll = vbox.get_node_or_null("Scroll")
		if scroll:
			vbox.add_child(polaroid_ticket_panel)
			vbox.move_child(polaroid_ticket_panel, scroll.get_index())
		else:
			vbox.add_child(polaroid_ticket_panel)

func _on_claim_reward_pressed() -> void:
	SoundManager.play_click()
	if victory_modal: victory_modal.visible = false
	GameManager.complete_lesson(16)
	var sim_steps = [
		{"icon": "🚌", "text": "Đọc BusMap, vẫy đúng tuyến 01, 53, 150"},
		{"icon": "💳", "text": "Quẹt thẻ xe buýt NFC chạm giữ đúng 0.6s"},
		{"icon": "🎒", "text": "Văn hóa đeo balo trước ngực trên Metro"},
		{"icon": "🛵", "text": "Chẩn đoán xe máy & né bẫy chặt chém 1 triệu"}
	]
	emit_signal("minigame_completed", sim_steps)

func _on_help_pressed() -> void:
	SoundManager.play_click()
	match current_level:
		1:
			cat_speech_lbl.text = "💡 MẸO BẮT XE BUÝT: Nhìn số xe trên đầu xe, khi xe cách trạm 5-10m hãy giữ nút Vẫy Tay 0.4s. Khi lên xe giữ thẻ NFC đúng 0.6s cho máy kêu Bíp!"
		2:
			cat_speech_lbl.text = "💡 MẸO METRO: Trên tàu đông người, luôn đeo balo trước ngực để không va trúng người khác và dùng thanh trượt giữ thăng bằng khi tàu vào cua!"
		3:
			cat_speech_lbl.text = "💡 MẸO XE MÁY: Nếu còi và đèn còn sáng thì ắc quy và IC không hỏng! Mưa lớn xe hay bị ngập pô và thủng lốp, chỉ cần vá lốp và xả nước!"
