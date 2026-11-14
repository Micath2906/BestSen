extends Control

# HousingLegalSimulation.gd - Module Giả Lập Hệ Thống & Xúc Giác: Trụ Cột Thuê Trọ & Pháp Lý Đời Sống
# Cấp độ 1: "Thám Tử Đi Xem Trọ" (Interactive Environmental Inspection)
# Cấp độ 2: "Soi Hợp Đồng Thuê Nhà" (Papers, Please Auditing Mechanics & Wax Seal)
# Cấp độ 3: "Quản Trị Phụ Tải & Kiểm Toán Hóa Đơn" (Circuit Breaker Sim & Bill Calculator)

signal minigame_completed(sim_steps)
signal back_requested

const JuicyButtonScript = preload("res://scripts/ui/JuicyButton.gd")

enum Level {
	LEVEL_1_ROOM_INSPECTION = 1,
	LEVEL_2_PAPERS_PLEASE = 2,
	LEVEL_3_POWER_BILL = 3
}

# Node references
@onready var header_box: HBoxContainer = $Header
@onready var btn_back: Button = $Header/BtnBack
@onready var btn_help: Button = $Header/BtnHelp
@onready var title_lbl: Label = $Header/TitleLabel
@onready var level_badge_lbl: Label = $Header/LevelBadgeLabel

@onready var cat_speech_lbl: Label = $MascotBox/SpeechBubble/CatSpeechLabel
@onready var mascot_avatar: TextureRect = $MascotBox/CatAvatar

@onready var level1_container: Control = $Level1Container
@onready var level2_container: Control = $Level2Container
@onready var level3_container: Control = $Level3Container

@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue_lbl: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

var current_level: int = 1
var is_level_active: bool = false
var safe_failure_count: int = 0
var completed_levels: Dictionary = {}

# Level 1 State: Room Defect Inspection
var defect_water_found: bool = false
var defect_meter_found: bool = false
var defect_ceiling_found: bool = false
var defect_door_found: bool = false
var all_switches_turned_off: bool = false

# Level 2 State: Papers, Please Contract Auditing
var red_flags_corrected: Dictionary = {} # flag_idx -> true
var contract_sealed: bool = false

# Level 3 State: Circuit Breaker & Bill Calculator
const MAX_POWER_WATTAGE: int = 3000
var is_cooker_on: bool = false  # 2000W
var is_kettle_on: bool = false  # 1500W
var is_fan_on: bool = true      # 60W
var is_lamp_on: bool = true     # 20W
var is_cb_tripped: bool = false
var bill_audited_correctly: bool = false

var polaroid_cert_panel: PanelContainer = null

func _ready() -> void:
	_setup_header_and_buttons()
	if victory_modal: victory_modal.visible = false
	if not is_level_active:
		load_level(1)

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
			level_badge_lbl.text = "CẤP ĐỘ 1 / 3: THÁM TỬ XEM TRỌ"
			title_lbl.text = "Kiểm Tra Lỗi Ẩn Phòng Trọ 2.5D"
			cat_speech_lbl.text = "Meo! Phòng mới sơn rất đẹp nhưng coi chừng lỗi ẩn! Dùng kính lúp kiểm tra vòi nước, công tơ điện quay lén, dột trần và khóa cửa nhé! 🐾"
			_init_level1_inspection()
		2:
			level_badge_lbl.text = "CẤP ĐỘ 2 / 3: ĐỐI CHIẾU HỢP ĐỒNG"
			title_lbl.text = "Soi Bẫy Hợp Đồng Phong Cách Papers, Please"
			cat_speech_lbl.text = "Dùng bút dạ quang đối chiếu văn bản bên phải với luật bên trái để bóc trần 3 điều khoản gài bẫy, sửa đổi xong kéo con dấu sáp vàng đóng xác nhận nhé Sen! 📜"
			_init_level2_papers_please()
		3:
			level_badge_lbl.text = "CẤP ĐỘ 3 / 3: SINH TỒN PHÒNG TRỌ"
			title_lbl.text = "Quản Trị Phụ Tải & Kiểm Toán Hóa Đơn"
			cat_speech_lbl.text = "Phòng trọ giới hạn 3000W, cẩn thận bật bếp và ấm cùng lúc bị nhảy Aptomat tối om! Sau đó nhớ tính lại hóa đơn điện xem chủ trọ có tính nhầm không nha! ⚡"
			_init_level3_power_bill()

# =========================================================================
# LEVEL 1: THÁM TỬ ĐI XEM TRỌ (ROOM DEFECT INSPECTOR)
# =========================================================================
var btn_tap: Button = null
var btn_switch_meter: Button = null
var btn_meter_report: Button = null
var btn_ceiling: Button = null
var btn_door: Button = null

func _init_level1_inspection() -> void:
	defect_water_found = false
	defect_meter_found = false
	defect_ceiling_found = false
	defect_door_found = false
	all_switches_turned_off = false
	_build_level1_ui()

func _build_level1_ui() -> void:
	if not level1_container: return
	for ch in level1_container.get_children(): ch.queue_free()
	
	var v_box = VBoxContainer.new()
	v_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	v_box.add_theme_constant_override("separation", 10)
	
	var room_panel = PanelContainer.new()
	room_panel.custom_minimum_size = Vector2(0, 160)
	var sb_room = StyleBoxFlat.new()
	sb_room.bg_color = Color(0.95, 0.93, 0.88, 1.0)
	sb_room.border_color = Color(0.7, 0.55, 0.4, 1.0)
	sb_room.set_border_width_all(2)
	sb_room.set_corner_radius_all(10)
	room_panel.add_theme_stylebox_override("panel", sb_room)
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 10)
	
	# 1. Vòi nước
	btn_tap = Button.new()
	btn_tap.name = "BtnWaterTap"
	btn_tap.text = "🚰 VẶN THỬ VÒI NƯỚC"
	btn_tap.custom_minimum_size = Vector2(210, 52)
	btn_tap.add_theme_font_size_override("font_size", 11)
	btn_tap.pressed.connect(_on_water_tap_pressed)
	JuicyButtonScript.attach_juice(btn_tap, true)
	grid.add_child(btn_tap)
	
	# 2. Trần nhà mái tôn
	btn_ceiling = Button.new()
	btn_ceiling.name = "BtnCeilingStain"
	btn_ceiling.text = "🏠 SOI TRẦN & MÁI TÔN"
	btn_ceiling.custom_minimum_size = Vector2(210, 52)
	btn_ceiling.add_theme_font_size_override("font_size", 11)
	btn_ceiling.pressed.connect(_on_ceiling_pressed)
	JuicyButtonScript.attach_juice(btn_ceiling, true)
	grid.add_child(btn_ceiling)
	
	# 3. Chốt khóa cửa
	btn_door = Button.new()
	btn_door.name = "BtnDoorLock"
	btn_door.text = "🚪 LẮC THỬ CHỐT CỬA"
	btn_door.custom_minimum_size = Vector2(210, 52)
	btn_door.add_theme_font_size_override("font_size", 11)
	btn_door.pressed.connect(_on_door_lock_pressed)
	JuicyButtonScript.attach_juice(btn_door, true)
	grid.add_child(btn_door)
	
	# 4. Công tắc & Công tơ điện
	btn_switch_meter = Button.new()
	btn_switch_meter.name = "BtnSwitchMeter"
	btn_switch_meter.text = "⚡ TẮT HẾT ĐIỆN & SOI CÔNG TƠ"
	btn_switch_meter.custom_minimum_size = Vector2(210, 52)
	btn_switch_meter.add_theme_font_size_override("font_size", 11)
	btn_switch_meter.pressed.connect(_on_switch_meter_pressed)
	JuicyButtonScript.attach_juice(btn_switch_meter, true)
	grid.add_child(btn_switch_meter)
	
	room_panel.add_child(grid)
	v_box.add_child(room_panel)
	
	# Tiến trình phát hiện lỗi
	var defect_counter = Label.new()
	defect_counter.name = "DefectCounterLabel"
	defect_counter.text = "Lỗi hạ tầng đã phát hiện: 0 / 4"
	defect_counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	defect_counter.add_theme_font_size_override("font_size", 11)
	defect_counter.add_theme_color_override("font_color", Color(0.2, 0.55, 0.3, 1.0))
	v_box.add_child(defect_counter)
	
	level1_container.add_child(v_box)

func _on_water_tap_pressed() -> void:
	SoundManager.play_click()
	defect_water_found = true
	btn_tap.text = "🚰 NƯỚC CHẢY RẤT YẾU ✔"
	btn_tap.add_theme_color_override("font_color", Color(0.8, 0.4, 0.1, 1.0))
	cat_speech_lbl.text = "Phát hiện lỗi 1: Mở hết cỡ mà nước chỉ chảy nhỏ giọt! Giờ cao điểm cả dãy trọ tắm là mất nước chắc luôn!"
	_check_level1_progress()

func _on_ceiling_pressed() -> void:
	SoundManager.play_click()
	defect_ceiling_found = true
	btn_ceiling.text = "🏠 VẾT Ố VÀNG DỘT MƯA ✔"
	btn_ceiling.add_theme_color_override("font_color", Color(0.8, 0.4, 0.1, 1.0))
	cat_speech_lbl.text = "Phát hiện lỗi 2: Dùng kính lúp soi thấy góc trần loang ố vàng lớn! Mưa rào là dột nước vào giường đệm!"
	_check_level1_progress()

func _on_door_lock_pressed() -> void:
	SoundManager.play_click()
	defect_door_found = true
	btn_door.text = "🚪 CHỐT KHÓA RỈ LỎNG LẺO ✔"
	btn_door.add_theme_color_override("font_color", Color(0.8, 0.4, 0.1, 1.0))
	cat_speech_lbl.text = "Phát hiện lỗi 3: Ốc vít bản lề cửa bị rỉ và lỏng lẻo, dùng tay lay nhẹ đã lung lay! Rất dễ bị cạy cửa trộm đồ!"
	_check_level1_progress()

func _on_switch_meter_pressed() -> void:
	SoundManager.play_click()
	all_switches_turned_off = true
	defect_meter_found = true
	btn_switch_meter.text = "⚡ ĐÃ TẮT ĐIỆN: CÔNG TƠ VẪN QUAY! ✔"
	btn_switch_meter.add_theme_color_override("font_color", Color(0.85, 0.2, 0.1, 1.0))
	cat_speech_lbl.text = "BẮT ĐƯỢC LỖI NGUY HIỂM: Tắt sạch đèn quạt nhưng đĩa công tơ vẫn quay đều! Có thể bị rò điện âm tường hoặc bị câu trộm điện!"
	_check_level1_progress()

func _check_level1_progress() -> void:
	var count = 0
	if defect_water_found: count += 1
	if defect_ceiling_found: count += 1
	if defect_door_found: count += 1
	if defect_meter_found: count += 1
	
	var lbl = level1_container.find_child("DefectCounterLabel", true, false) as Label
	if lbl: lbl.text = "Lỗi hạ tầng đã phát hiện: %d / 4" % count
	
	if count >= 4 and not completed_levels.has(1):
		completed_levels[1] = true
		SoundManager.play_success()
		cat_speech_lbl.text = "🎉 XUẤT SẮC! Đã lập biên bản 4 lỗi hạ tầng yêu cầu chủ trọ khắc phục trước khi đặt cọc! Chuyển sang soi Hợp Đồng nào! ✨"
		get_tree().create_timer(1.2).timeout.connect(func():
			load_level(2)
		)

# =========================================================================
# LEVEL 2: SOI HỢP ĐỒNG PHONG CÁCH PAPERS, PLEASE
# =========================================================================
var btn_flag1: Button = null
var btn_flag2: Button = null
var btn_flag3: Button = null
var btn_seal: Button = null

func _init_level2_papers_please() -> void:
	red_flags_corrected.clear()
	contract_sealed = false
	_build_level2_ui()

func _build_level2_ui() -> void:
	if not level2_container: return
	for ch in level2_container.get_children(): ch.queue_free()
	
	var v_box = VBoxContainer.new()
	v_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	v_box.add_theme_constant_override("separation", 8)
	
	# Bàn đối chiếu song song
	var desk_hbox = HBoxContainer.new()
	desk_hbox.add_theme_constant_override("separation", 8)
	desk_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Khung trái: Sổ tay thỏa thuận miệng & Pháp luật
	var memo_panel = PanelContainer.new()
	memo_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb_memo = StyleBoxFlat.new()
	sb_memo.bg_color = Color(0.93, 0.96, 0.98, 1.0)
	sb_memo.border_color = Color(0.25, 0.55, 0.85, 1.0)
	sb_memo.set_border_width_all(2)
	sb_memo.set_corner_radius_all(10)
	memo_panel.add_theme_stylebox_override("panel", sb_memo)
	
	var memo_lbl = Label.new()
	memo_lbl.text = "📖 THỎA THUẬN MIỆNG & LUẬT:\n\n1. Cọc 1 tháng, báo trước 30 ngày dọn đi được trả lại 100% cọc (Điều 328 BLDS).\n\n2. Giá điện thỏa thuận 3.500đ/kWh theo đồng hồ riêng.\n\n3. Chủ trọ có nghĩa vụ làm tạm trú cho người thuê (Luật Cư trú)."
	memo_lbl.add_theme_font_size_override("font_size", 10)
	memo_lbl.add_theme_color_override("font_color", Color(0.1, 0.3, 0.6, 1.0))
	memo_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	memo_panel.add_child(memo_lbl)
	desk_hbox.add_child(memo_panel)
	
	# Khung phải: Hợp đồng của chủ trọ có 3 điều khoản gài bẫy
	var contract_panel = PanelContainer.new()
	contract_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb_ct = StyleBoxFlat.new()
	sb_ct.bg_color = Color(0.98, 0.96, 0.92, 1.0)
	sb_ct.border_color = Color(0.7, 0.5, 0.3, 1.0)
	sb_ct.set_border_width_all(2)
	sb_ct.set_corner_radius_all(10)
	contract_panel.add_theme_stylebox_override("panel", sb_ct)
	
	var ct_vbox = VBoxContainer.new()
	ct_vbox.add_theme_constant_override("separation", 6)
	
	var ct_title = Label.new()
	ct_title.text = "📜 BẢN HỢP ĐỒNG CẦN BẮT LỖI BẪY (CHẠM ĐỂ SỬA):"
	ct_title.add_theme_font_size_override("font_size", 10)
	ct_title.add_theme_color_override("font_color", Color(0.4, 0.2, 0.1, 1.0))
	ct_vbox.add_child(ct_title)
	
	btn_flag1 = Button.new()
	btn_flag1.name = "BtnClauseDeposit"
	btn_flag1.text = "❌ ĐK 1: Dọn ra trước 12 tháng mất 100% cọc dù lý do gì"
	btn_flag1.add_theme_font_size_override("font_size", 9)
	btn_flag1.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn_flag1.pressed.connect(func(): _on_correct_flag_pressed(1))
	JuicyButtonScript.attach_juice(btn_flag1, true)
	ct_vbox.add_child(btn_flag1)
	
	btn_flag2 = Button.new()
	btn_flag2.name = "BtnClausePower"
	btn_flag2.text = "❌ ĐK 2: Giá điện tính theo quy định nội bộ của chủ nhà"
	btn_flag2.add_theme_font_size_override("font_size", 9)
	btn_flag2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn_flag2.pressed.connect(func(): _on_correct_flag_pressed(2))
	JuicyButtonScript.attach_juice(btn_flag2, true)
	ct_vbox.add_child(btn_flag2)
	
	btn_flag3 = Button.new()
	btn_flag3.name = "BtnClauseResidence"
	btn_flag3.text = "❌ ĐK 3: Bên thuê tự chịu nếu bị phạt không đăng ký tạm trú"
	btn_flag3.add_theme_font_size_override("font_size", 9)
	btn_flag3.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn_flag3.pressed.connect(func(): _on_correct_flag_pressed(3))
	JuicyButtonScript.attach_juice(btn_flag3, true)
	ct_vbox.add_child(btn_flag3)
	
	contract_panel.add_child(ct_vbox)
	desk_hbox.add_child(contract_panel)
	v_box.add_child(desk_hbox)
	
	# Nút đóng dấu sáp vàng
	btn_seal = Button.new()
	btn_seal.name = "BtnWaxSeal"
	btn_seal.text = "🔒 HÃY SỬA ĐỦ 3 ĐIỀU KHOẢN TRƯỚC KHI ĐÓNG DẤU SÁP"
	btn_seal.custom_minimum_size = Vector2(0, 44)
	btn_seal.disabled = true
	var seal_tex = load("res://assets/UI/CatUIPaid/slices/cozy_achievements/wax_seal_royal_gold.tres")
	if seal_tex: btn_seal.icon = seal_tex
	btn_seal.pressed.connect(_on_wax_seal_pressed)
	JuicyButtonScript.attach_juice(btn_seal, true)
	v_box.add_child(btn_seal)
	
	level2_container.add_child(v_box)

func _on_correct_flag_pressed(flag_idx: int) -> void:
	SoundManager.play_success()
	red_flags_corrected[flag_idx] = true
	
	match flag_idx:
		1:
			btn_flag1.text = "✔ ĐK 1: Báo trước 30 ngày được hoàn trả 100% cọc (Đã sửa)"
			btn_flag1.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25, 1.0))
			cat_speech_lbl.text = "Đã bắt lỗi bẫy cọc! Theo Điều 328 Bộ luật Dân sự, hợp đồng thuê trọ phải quy định hoàn cọc khi báo trước đúng hạn!"
		2:
			btn_flag2.text = "✔ ĐK 2: Giá điện cố định 3.500đ/kWh theo đồng hồ riêng (Đã sửa)"
			btn_flag2.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25, 1.0))
			cat_speech_lbl.text = "Đã bắt lỗi giá điện mập mờ! Đơn giá điện nước bắt buộc phải ghi rõ bằng số cụ thể kèm chỉ số ban đầu!"
		3:
			btn_flag3.text = "✔ ĐK 3: Bên cho thuê có nghĩa vụ đăng ký tạm trú (Đã sửa)"
			btn_flag3.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25, 1.0))
			cat_speech_lbl.text = "Đã bắt lỗi trốn tạm trú! Theo Luật Cư trú, chủ trọ có trách nhiệm phối hợp khai báo tạm trú cho người thuê!"
			
	if red_flags_corrected.size() >= 3:
		btn_seal.disabled = false
		btn_seal.text = "🔏 ĐÓNG DẤU SÁP VÀNG: XÁC NHẬN HỢP ĐỒNG MINH BẠCH"
		btn_seal.add_theme_color_override("font_color", Color(0.85, 0.65, 0.1, 1.0))

func _on_wax_seal_pressed() -> void:
	contract_sealed = true
	completed_levels[2] = true
	SoundManager.play_success()
	cat_speech_lbl.text = "🎉 CỘP! Đóng con dấu sáp vàng thành công! Hợp đồng đã an toàn, không lo bị gài bẫy mất cọc! Chuyển sang Level 3 nào! ✨"
	get_tree().create_timer(1.2).timeout.connect(func():
		load_level(3)
	)

# =========================================================================
# LEVEL 3: QUẢN TRỊ PHỤ TẢI & KIỂM TOÁN HÓA ĐƠN
# =========================================================================
var btn_cooker: Button = null
var btn_kettle: Button = null
var btn_cb_reset: Button = null
var power_status_lbl: Label = null
var btn_bill_correct: Button = null
var btn_bill_scam: Button = null

func _init_level3_power_bill() -> void:
	is_cooker_on = false
	is_kettle_on = false
	is_fan_on = true
	is_lamp_on = true
	is_cb_tripped = false
	bill_audited_correctly = false
	_build_level3_ui()

func _build_level3_ui() -> void:
	if not level3_container: return
	for ch in level3_container.get_children(): ch.queue_free()
	
	var v_box = VBoxContainer.new()
	v_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	v_box.add_theme_constant_override("separation", 8)
	
	# Phần 1: Phụ tải điện & Aptomat
	var power_panel = PanelContainer.new()
	var sb_p = StyleBoxFlat.new()
	sb_p.bg_color = Color(0.97, 0.95, 0.90, 1.0)
	sb_p.border_color = Color(0.7, 0.5, 0.3, 1.0)
	sb_p.set_border_width_all(2)
	sb_p.set_corner_radius_all(10)
	power_panel.add_theme_stylebox_override("panel", sb_p)
	
	var p_vbox = VBoxContainer.new()
	p_vbox.add_theme_constant_override("separation", 6)
	
	power_status_lbl = Label.new()
	power_status_lbl.name = "PowerStatusLabel"
	power_status_lbl.text = "⚡ CÔNG SUẤT HIỆN TẠI: 80W / 3000W (AN TOÀN)"
	power_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	power_status_lbl.add_theme_font_size_override("font_size", 11)
	power_status_lbl.add_theme_color_override("font_color", Color(0.1, 0.5, 0.2, 1.0))
	p_vbox.add_child(power_status_lbl)
	
	var switch_hbox = HBoxContainer.new()
	switch_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	switch_hbox.add_theme_constant_override("separation", 8)
	
	btn_cooker = Button.new()
	btn_cooker.name = "BtnCooker"
	btn_cooker.text = "🍳 Bếp Từ (2000W): TẮT"
	btn_cooker.add_theme_font_size_override("font_size", 10)
	btn_cooker.pressed.connect(_on_toggle_cooker)
	JuicyButtonScript.attach_juice(btn_cooker, true)
	switch_hbox.add_child(btn_cooker)
	
	btn_kettle = Button.new()
	btn_kettle.name = "BtnKettle"
	btn_kettle.text = "🫖 Ấm Siêu Tốc (1500W): TẮT"
	btn_kettle.add_theme_font_size_override("font_size", 10)
	btn_kettle.pressed.connect(_on_toggle_kettle)
	JuicyButtonScript.attach_juice(btn_kettle, true)
	switch_hbox.add_child(btn_kettle)
	
	btn_cb_reset = Button.new()
	btn_cb_reset.name = "BtnCbReset"
	btn_cb_reset.text = "🔌 CẦU DAO (CB): ĐANG BẬT"
	btn_cb_reset.disabled = true
	btn_cb_reset.add_theme_font_size_override("font_size", 10)
	btn_cb_reset.pressed.connect(_on_cb_reset_pressed)
	JuicyButtonScript.attach_juice(btn_cb_reset, true)
	switch_hbox.add_child(btn_cb_reset)
	
	p_vbox.add_child(switch_hbox)
	power_panel.add_child(p_vbox)
	v_box.add_child(power_panel)
	
	# Phần 2: Kiểm toán hóa đơn tiền điện cuối tháng
	var bill_panel = PanelContainer.new()
	var sb_b = StyleBoxFlat.new()
	sb_b.bg_color = Color(0.98, 0.96, 0.94, 1.0)
	sb_b.border_color = Color(0.4, 0.55, 0.75, 1.0)
	sb_b.set_border_width_all(2)
	sb_b.set_corner_radius_all(10)
	bill_panel.add_theme_stylebox_override("panel", sb_b)
	
	var b_vbox = VBoxContainer.new()
	b_vbox.add_theme_constant_override("separation", 6)
	
	var bill_info = Label.new()
	bill_info.text = "🧾 KIỂM TOÁN HÓA ĐƠN TIỀN ĐIỆN:\nCông tơ: Số cũ 1240, Số mới 1310 ➔ Thực tế: 70 kWh x 3.500đ = 245.000đ\nChủ nhà gửi giấy báo: 120 kWh = 420.000đ (Bị tính khống thêm 50 kWh!)"
	bill_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bill_info.add_theme_font_size_override("font_size", 10)
	bill_info.add_theme_color_override("font_color", Color(0.2, 0.25, 0.35, 1.0))
	b_vbox.add_child(bill_info)
	
	var bill_btn_hbox = HBoxContainer.new()
	bill_btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	bill_btn_hbox.add_theme_constant_override("separation", 10)
	
	btn_bill_scam = Button.new()
	btn_bill_scam.name = "BtnBillPayScam"
	btn_bill_scam.text = "❌ Trả luôn 420.000đ theo giấy báo"
	btn_bill_scam.add_theme_font_size_override("font_size", 10)
	btn_bill_scam.pressed.connect(_on_bill_pay_scam)
	JuicyButtonScript.attach_juice(btn_bill_scam, true)
	bill_btn_hbox.add_child(btn_bill_scam)
	
	btn_bill_correct = Button.new()
	btn_bill_correct.name = "BtnBillAuditCorrect"
	btn_bill_correct.text = "✔ Đối chiếu công tơ: Chỉ trả đúng 245.000đ"
	btn_bill_correct.add_theme_font_size_override("font_size", 10)
	btn_bill_correct.pressed.connect(_on_bill_audit_correct)
	JuicyButtonScript.attach_juice(btn_bill_correct, true)
	bill_btn_hbox.add_child(btn_bill_correct)
	
	b_vbox.add_child(bill_btn_hbox)
	bill_panel.add_child(b_vbox)
	v_box.add_child(bill_panel)
	
	level3_container.add_child(v_box)

func _calculate_current_power() -> int:
	var total = 80 # Đèn + Quạt
	if is_cooker_on: total += 2000
	if is_kettle_on: total += 1500
	return total

func _on_toggle_cooker() -> void:
	if is_cb_tripped: return
	is_cooker_on = not is_cooker_on
	SoundManager.play_click()
	btn_cooker.text = "🍳 Bếp Từ (2000W): BẬT" if is_cooker_on else "🍳 Bếp Từ (2000W): TẮT"
	_update_power_state()

func _on_toggle_kettle() -> void:
	if is_cb_tripped: return
	is_kettle_on = not is_kettle_on
	SoundManager.play_click()
	btn_kettle.text = "🫖 Ấm Siêu Tốc (1500W): BẬT" if is_kettle_on else "🫖 Ấm Siêu Tốc (1500W): TẮT"
	_update_power_state()

func _update_power_state() -> void:
	var power = _calculate_current_power()
	if power > MAX_POWER_WATTAGE:
		# QUÁ TẢI -> NHẢY APTOMAT
		is_cb_tripped = true
		SoundManager.play_fail()
		power_status_lbl.text = "💥 TÁCH! QUÁ TẢI %dW > 3000W - CẦU DAO (CB) ĐÃ NHẢY!" % power
		power_status_lbl.add_theme_color_override("font_color", Color(0.85, 0.2, 0.1, 1.0))
		btn_cb_reset.disabled = false
		btn_cb_reset.text = "🔴 CB ĐÃ SẬP! (TẮT BỚT ĐỒ RỒI BẤM BẬT LẠI)"
		cat_speech_lbl.text = "MEOOO! Tối om rồi Sen ơi! Bếp từ 2000W + Ấm nước 1500W = 3500W quá tải cầu dao 3000W rồi! Mau tắt bớt 1 món đi rồi gạt lại cầu dao nhé!"
	else:
		power_status_lbl.text = "⚡ CÔNG SUẤT: %dW / 3000W (AN TOÀN)" % power
		power_status_lbl.add_theme_color_override("font_color", Color(0.1, 0.5, 0.2, 1.0))

func _on_cb_reset_pressed() -> void:
	var power = _calculate_current_power()
	if power > MAX_POWER_WATTAGE:
		SoundManager.play_card_pop()
		cat_speech_lbl.text = "Chưa được Sen ơi! Công suất vẫn đang là %dW, gạt cầu dao lên sẽ bị nảy lại ngay! Tắt bếp từ hoặc ấm nước trước đã!" % power
	else:
		is_cb_tripped = false
		btn_cb_reset.disabled = true
		btn_cb_reset.text = "🔌 CẦU DAO (CB): ĐANG BẬT"
		SoundManager.play_success()
		cat_speech_lbl.text = "Đèn sáng trở lại rồi! Nhớ bài học: Không bật bếp từ cùng lúc với ấm siêu tốc để chống nhảy CB nhé!"
		_update_power_state()

func _on_bill_pay_scam() -> void:
	SoundManager.play_card_pop()
	safe_failure_count += 1
	cat_speech_lbl.text = "ÚI GIỜI ƠI SEN! 💡 Lấy số mới 1310 trừ số cũ 1240 chỉ ra 70 kWh thôi! Chủ trọ tính nhầm 120 kWh làm Sen mất toi 175.000đ oan đó!"

func _on_bill_audit_correct() -> void:
	bill_audited_correctly = true
	completed_levels[3] = true
	SoundManager.play_success()
	cat_speech_lbl.text = "🎉 XUẤT SẮC! Đưa ảnh chụp công tơ cho chủ trọ, chủ trọ xin lỗi tính nhầm và chỉ thu đúng 245.000đ! Tiết kiệm tiền triệu mỗi năm! ✨"
	_show_housing_victory()

# =========================================================================
# VICTORY MODAL & CERTIFICATE
# =========================================================================
func _show_housing_victory() -> void:
	SoundManager.play_success()
	var speech = "🎉 CHÚC MỪNG BẬC THẦY SINH TỒN PHÒNG TRỌ!\n\n"
	speech += "Mèo con đã hoàn thành xuất sắc toàn bộ 3 Cấp độ Pháp lý & Đời sống Thuê Trọ:\n\n"
	speech += "✔ Cấp độ 1: Bắt trọn 4 lỗi hạ tầng (nước yếu, dột trần, lỏng khóa, công tơ quay lén).\n"
	speech += "✔ Cấp độ 2: Soi 3 điều khoản gài bẫy hợp đồng & đóng dấu sáp vàng minh bạch.\n"
	speech += "✔ Cấp độ 3: Quản trị phụ tải 3000W chống nhảy CB & kiểm toán hóa đơn chuẩn xác.\n\n"
	speech += "🎖️ Nhận danh hiệu 'Thám Tử Thuê Trọ Minh Bạch' & Thưởng +45 Cá Khô!"
	if victory_dialogue_lbl:
		victory_dialogue_lbl.text = speech
		
	_build_polaroid_housing_pass()
	if victory_modal:
		victory_modal.visible = true

func _build_polaroid_housing_pass() -> void:
	if polaroid_cert_panel and is_instance_valid(polaroid_cert_panel):
		polaroid_cert_panel.queue_free()
		
	polaroid_cert_panel = PanelContainer.new()
	polaroid_cert_panel.name = "PolaroidHousingPass"
	polaroid_cert_panel.custom_minimum_size = Vector2(0, 115)
	
	var sb = load("res://assets/UI/CatUIPaid/slices/cozy_achievements/parchment_scroll_stylebox.tres")
	if sb:
		polaroid_cert_panel.add_theme_stylebox_override("panel", sb)
	else:
		var flat = StyleBoxFlat.new()
		flat.bg_color = Color(0.98, 0.96, 0.92, 1.0)
		flat.border_color = Color(0.65, 0.45, 0.30, 1.0)
		flat.set_border_width_all(2)
		flat.set_corner_radius_all(10)
		polaroid_cert_panel.add_theme_stylebox_override("panel", flat)
		
	var v = VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 4)
	
	var owner_name = GameManager.owner_name if "owner_name" in GameManager and GameManager.owner_name != "" else "Sen Thám Tử"
	var room_name = GameManager.room_name if "room_name" in GameManager and GameManager.room_name != "" else "Phòng Trọ Số 1"
	
	var title = Label.new()
	title.text = "📜 CHỨNG NHẬN: THÁM TỬ PHÒNG TRỌ VĂN MINH"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color(0.42, 0.22, 0.08, 1.0))
	v.add_child(title)
	
	var desc = Label.new()
	desc.text = "Cấp cho: %s • Địa chỉ: %s\nHoàn tất 3 Cấp độ Giả lập Thuê trọ & Pháp lý • An cư lạc nghiệp, vững vàng tự lập!" % [owner_name, room_name]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 9)
	desc.add_theme_color_override("font_color", Color(0.35, 0.28, 0.22, 1.0))
	v.add_child(desc)
	
	polaroid_cert_panel.add_child(v)
	
	var vbox = victory_modal.get_node_or_null("ModalPanel/VBox")
	if vbox:
		var scroll = vbox.get_node_or_null("Scroll")
		if scroll:
			vbox.add_child(polaroid_cert_panel)
			vbox.move_child(polaroid_cert_panel, scroll.get_index())
		else:
			vbox.add_child(polaroid_cert_panel)

func _on_claim_reward_pressed() -> void:
	SoundManager.play_click()
	if victory_modal: victory_modal.visible = false
	GameManager.complete_lesson(5)
	var sim_steps = [
		{"icon": "🔍", "text": "Bắt 4 lỗi hạ tầng phòng trọ 2.5D"},
		{"icon": "📑", "text": "Soi bẫy hợp đồng phong cách Papers, Please"},
		{"icon": "🔏", "text": "Đóng dấu sáp vàng bảo toàn tiền cọc"},
		{"icon": "⚡", "text": "Quản lý phụ tải CB & kiểm toán điện 70 kWh"}
	]
	emit_signal("minigame_completed", sim_steps)

func _on_help_pressed() -> void:
	SoundManager.play_click()
	match current_level:
		1:
			cat_speech_lbl.text = "💡 MẸO XEM PHÒNG: Luôn vặn vòi nước kiểm tra áp lực, tắt hết đèn xem công tơ có quay lén không, soi vết ố dột trần và lay chốt cửa!"
		2:
			cat_speech_lbl.text = "💡 MẸO HỢP ĐỒNG: Gạch sửa các điều khoản mất cọc vô lý, giá điện mập mờ và trốn tạm trú trước khi ký tên đóng dấu!"
		3:
			cat_speech_lbl.text = "💡 MẸO ĐIỆN NƯỚC: Tổng công suất thiết bị không vượt quá 3000W. Lấy số mới trừ số cũ nhân 3.500đ để ra tiền điện chính xác!"
