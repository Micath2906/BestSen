extends Control

# HealthcareWellnessSimulation.gd - Module Giả Lập Hệ Thống & Xúc Giác: Trụ Cột Y Tế, BHYT & Sức Khỏe
# Cấp độ 1: "Sơ Cứu Tại Chỗ & Chia Liều Thuốc" (Tactile Burn Cooling & Dosage Calculation)
# Cấp độ 2: "Hành Trình BHYT Bệnh Viện Công" (5-Station Procedural Routing & Anti-Tout)
# Cấp độ 3: "Nhịp Sinh Học & Hơi Thở 4-7-8 Cùng Mochi" (Circadian Rhythm & Cozy Breathing)

signal minigame_completed(sim_steps)
signal back_requested

const JuicyButtonScript = preload("res://scripts/ui/JuicyButton.gd")

enum Level {
	LEVEL_1_FIRST_AID = 1,
	LEVEL_2_BHYT_HOSPITAL = 2,
	LEVEL_3_WELLNESS_BREATH = 3
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

# Level 1 State: First Aid & Dosage
var is_burn_cooled: bool = false
var is_burn_bandaged: bool = false
var burn_cool_timer: float = 0.0
var fever_dosage_cut: bool = false
var fever_water_taken: bool = false

# Level 2 State: 5-Station BHYT Routing
var current_station: int = 1 # 1: Kiosk, 2: Tiếp nhận, 3: Bác sĩ, 4: Viện phí, 5: Dược BHYT
var tout_rejected: bool = false
var bhyt_docs_presented: bool = false

# Level 3 State: Circadian & 4-7-8 Breathing
var focus_stat: int = 50
var stress_stat: int = 85
var hydration_stat: int = 30
var breathing_phase: String = "IDLE" # INHALE_4, HOLD_7, EXHALE_8, FINISHED
var breathing_progress: float = 0.0
var breathing_cycles_done: int = 0

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
			level_badge_lbl.text = "CẤP ĐỘ 1 / 3: SƠ CỨU & LIỀU THUỐC"
			title_lbl.text = "Xử Lý Bỏng Chuẩn Y Khoa & Chia Liều Hạ Sốt"
			cat_speech_lbl.text = "Bị bỏng nước sôi chớ bôi kem đánh răng hay nước mắm nha Sen! Xả nước mát 15-20 phút, sau đó tính liều hạ sốt 10-15mg/kg cho người 50kg nhé! 🩹"
			_init_level1_first_aid()
		2:
			level_badge_lbl.text = "CẤP ĐỘ 2 / 3: HÀNH TRÌNH BHYT"
			title_lbl.text = "Điều Hướng 5 Trạm Bệnh Viện Công & Né Cò Mồi"
			cat_speech_lbl.text = "Lần đầu đi bệnh viện công đông đúc: Đi qua đủ 5 trạm từ Kiosk tới Quầy dược BHYT và kiên quyết từ chối cò mồi 300k nhé! 🏥"
			_init_level2_bhyt_hospital()
		3:
			level_badge_lbl.text = "CẤP ĐỘ 3 / 3: HƠI THỞ 4-7-8 CÙNG MOCHI"
			title_lbl.text = "Cân Bằng Thần Kinh Mùa Thi & Hồi Phục Thân Tâm"
			cat_speech_lbl.text = "Căng thẳng thi cử và uống quá nhiều cà phê làm tim đập nhanh! Ngồi xuống cùng Mochi tập thở 4-7-8 để hạ nhịp tim và ngủ đủ giấc nào! 🐾"
			_init_level3_wellness_breathing()

# =========================================================================
# LEVEL 1: SƠ CỨU TẠI CHỖ & CHIA LIỀU THUỐC (FIRST AID & DOSAGE)
# =========================================================================
var btn_water_cool: Button = null
var btn_toothpaste: Button = null
var btn_ice: Button = null
var btn_sterile_gauze: Button = null

var btn_cut_paracetamol: Button = null
var btn_drink_warm_water: Button = null
var dosage_label: Label = null

func _init_level1_first_aid() -> void:
	is_burn_cooled = false
	is_burn_bandaged = false
	burn_cool_timer = 0.0
	fever_dosage_cut = false
	fever_water_taken = false
	_build_level1_ui()

func _build_level1_ui() -> void:
	if not level1_container: return
	for ch in level1_container.get_children(): ch.queue_free()
	
	var v_box = VBoxContainer.new()
	v_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	v_box.add_theme_constant_override("separation", 8)
	
	# Phần 1: Sơ cứu Bỏng nước sôi
	var burn_panel = PanelContainer.new()
	var sb_burn = StyleBoxFlat.new()
	sb_burn.bg_color = Color(1.0, 0.96, 0.94, 1.0)
	sb_burn.border_color = Color(0.9, 0.45, 0.3, 1.0)
	sb_burn.set_border_width_all(2)
	sb_burn.set_corner_radius_all(10)
	burn_panel.add_theme_stylebox_override("panel", sb_burn)
	
	var b_vbox = VBoxContainer.new()
	b_vbox.add_theme_constant_override("separation", 6)
	
	var b_title = Label.new()
	b_title.text = "🔥 TÌNH HUỐNG 1: BỎNG NƯỚC SÔI Ở MU BÀN TAY (CẦN XỬ TRÍ GẤP)"
	b_title.add_theme_font_size_override("font_size", 10)
	b_title.add_theme_color_override("font_color", Color(0.8, 0.25, 0.1, 1.0))
	b_vbox.add_child(b_title)
	
	var b_hbox = HBoxContainer.new()
	b_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	b_hbox.add_theme_constant_override("separation", 8)
	
	btn_water_cool = Button.new()
	btn_water_cool.name = "BtnWaterCool"
	btn_water_cool.text = "🚰 Ngâm/Xả Dưới Vòi Nước Mát (15-20p)"
	btn_water_cool.add_theme_font_size_override("font_size", 9)
	btn_water_cool.pressed.connect(_on_water_cool_pressed)
	JuicyButtonScript.attach_juice(btn_water_cool, true)
	b_hbox.add_child(btn_water_cool)
	
	btn_toothpaste = Button.new()
	btn_toothpaste.name = "BtnToothpaste"
	btn_toothpaste.text = "🪥 Bôi Kem Đánh Răng"
	btn_toothpaste.add_theme_font_size_override("font_size", 9)
	btn_toothpaste.pressed.connect(_on_bad_burn_treatment_pressed.bind("kem đánh răng"))
	JuicyButtonScript.attach_juice(btn_toothpaste, true)
	b_hbox.add_child(btn_toothpaste)
	
	btn_ice = Button.new()
	btn_ice.name = "BtnIce"
	btn_ice.text = "🧊 Đắp Trực Tiếp Đá Lạnh"
	btn_ice.add_theme_font_size_override("font_size", 9)
	btn_ice.pressed.connect(_on_bad_burn_treatment_pressed.bind("đá lạnh buốt"))
	JuicyButtonScript.attach_juice(btn_ice, true)
	b_hbox.add_child(btn_ice)
	
	btn_sterile_gauze = Button.new()
	btn_sterile_gauze.name = "BtnSterileGauze"
	btn_sterile_gauze.text = "🩹 Băng Gạc Vô Trùng Nhẹ Nhàng"
	btn_sterile_gauze.add_theme_font_size_override("font_size", 9)
	btn_sterile_gauze.disabled = true
	btn_sterile_gauze.pressed.connect(_on_sterile_gauze_pressed)
	JuicyButtonScript.attach_juice(btn_sterile_gauze, true)
	b_hbox.add_child(btn_sterile_gauze)
	
	b_vbox.add_child(b_hbox)
	burn_panel.add_child(b_vbox)
	v_box.add_child(burn_panel)
	
	# Phần 2: Cắt liều thuốc hạ sốt cho người 50kg
	var fever_panel = PanelContainer.new()
	var sb_fever = StyleBoxFlat.new()
	sb_fever.bg_color = Color(0.94, 0.97, 0.99, 1.0)
	sb_fever.border_color = Color(0.3, 0.6, 0.85, 1.0)
	sb_fever.set_border_width_all(2)
	sb_fever.set_corner_radius_all(10)
	fever_panel.add_theme_stylebox_override("panel", sb_fever)
	
	var f_vbox = VBoxContainer.new()
	f_vbox.add_theme_constant_override("separation", 6)
	
	dosage_label = Label.new()
	dosage_label.name = "DosageLabel"
	dosage_label.text = "🌡️ TÌNH HUỐNG 2: SỐT CAO 38.8°C (CÂN NẶNG 50KG)\nCông thức: 10 - 15 mg/kg ➔ Liều chuẩn: 500mg - 750mg Paracetamol"
	dosage_label.add_theme_font_size_override("font_size", 10)
	dosage_label.add_theme_color_override("font_color", Color(0.1, 0.35, 0.6, 1.0))
	f_vbox.add_child(dosage_label)
	
	var f_hbox = HBoxContainer.new()
	f_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	f_hbox.add_theme_constant_override("separation", 10)
	
	btn_cut_paracetamol = Button.new()
	btn_cut_paracetamol.name = "BtnCutParacetamol"
	btn_cut_paracetamol.text = "✂️ Dùng Kéo Cắt 1 Viên Paracetamol 500mg"
	btn_cut_paracetamol.add_theme_font_size_override("font_size", 9)
	var scissors_tex = load("res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_16_scissors.tres")
	if scissors_tex: btn_cut_paracetamol.icon = scissors_tex
	btn_cut_paracetamol.pressed.connect(_on_cut_paracetamol_pressed)
	JuicyButtonScript.attach_juice(btn_cut_paracetamol, true)
	f_hbox.add_child(btn_cut_paracetamol)
	
	btn_drink_warm_water = Button.new()
	btn_drink_warm_water.name = "BtnDrinkWarmWater"
	btn_drink_warm_water.text = "🥛 Uống Cùng Cốc Nước Ấm Lớn"
	btn_drink_warm_water.add_theme_font_size_override("font_size", 9)
	var thermos_tex = load("res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_12_thermos.tres")
	if thermos_tex: btn_drink_warm_water.icon = thermos_tex
	btn_drink_warm_water.disabled = true
	btn_drink_warm_water.pressed.connect(_on_drink_warm_water_pressed)
	JuicyButtonScript.attach_juice(btn_drink_warm_water, true)
	f_hbox.add_child(btn_drink_warm_water)
	
	f_vbox.add_child(f_hbox)
	fever_panel.add_child(f_vbox)
	v_box.add_child(fever_panel)
	
	level1_container.add_child(v_box)

func _on_bad_burn_treatment_pressed(substance: String) -> void:
	SoundManager.play_fail()
	safe_failure_count += 1
	cat_speech_lbl.text = "❌ NGUY HIỂM! Tuyệt đối không bôi %s lên vết bỏng! Sẽ làm bí nhiệt gây hoại tử sâu hoặc bỏng lạnh co mạch máu cực kỳ nguy hiểm! Mau xả nước mát!" % substance

func _on_water_cool_pressed() -> void:
	SoundManager.play_success()
	is_burn_cooled = true
	btn_water_cool.text = "✔ ĐÃ HẠ NHIỆT VÒI NƯỚC MÁT 15P"
	btn_water_cool.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25, 1.0))
	btn_sterile_gauze.disabled = false
	cat_speech_lbl.text = "Chính xác! Nước mát sạch chảy nhẹ giúp hạ nhiệt lớp biểu bì, giảm phồng rộp và giảm đau đớn tức thì! Giờ hãy băng gạc vô trùng nhẹ nhàng!"

func _on_sterile_gauze_pressed() -> void:
	SoundManager.play_success()
	is_burn_bandaged = true
	btn_sterile_gauze.text = "✔ ĐÃ BĂNG GẠC VÔ TRÙNG AN TOÀN"
	btn_sterile_gauze.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25, 1.0))
	cat_speech_lbl.text = "Xử lý bỏng hoàn hảo! Băng nhẹ tay tránh làm vỡ bọng nước. Giờ chuyển sang xử lý sốt cao 38.8°C nhé!"
	_check_level1_completion()

func _on_cut_paracetamol_pressed() -> void:
	SoundManager.play_card_pop()
	fever_dosage_cut = true
	btn_cut_paracetamol.text = "✔ ĐÃ CẮT ĐÚNG 1 VIÊN 500mg (10mg/kg)"
	btn_cut_paracetamol.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25, 1.0))
	btn_drink_warm_water.disabled = false
	cat_speech_lbl.text = "Tính liều chuẩn xác: 50kg x 10mg/kg = 500mg! Uống cùng một cốc nước ấm lớn để hạ sốt và bù nước nha Sen!"

func _on_drink_warm_water_pressed() -> void:
	SoundManager.play_success()
	fever_water_taken = true
	btn_drink_warm_water.text = "✔ ĐÃ UỐNG ĐỦ NƯỚC ẤM"
	btn_drink_warm_water.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25, 1.0))
	cat_speech_lbl.text = "Tuyệt vời! Lưu ý cốt tử: Uống cách nhau 4-6 tiếng, không quá 4g/ngày để bảo vệ tế bào gan! Chuyển sang Level 2 BHYT nào! ✨"
	_check_level1_completion()

func _check_level1_completion() -> void:
	if is_burn_bandaged and fever_water_taken and not completed_levels.has(1):
		completed_levels[1] = true
		get_tree().create_timer(1.2).timeout.connect(func():
			load_level(2)
		)

# =========================================================================
# LEVEL 2: HÀNH TRÌNH BHYT BỆNH VIỆN CÔNG (5-STATION PROCEDURAL ROUTING)
# =========================================================================
var station_status_lbl: Label = null
var btn_station_action: Button = null
var btn_reject_tout: Button = null

const STATIONS_DATA = [
	{
		"station_id": 1,
		"name": "Trạm 1: Kiosk Lấy Số Thứ Tự",
		"desc": "Chạm màn hình cảm ứng: Chọn 'Khám BHYT' ➔ Chọn chuyên khoa 'Khám Nội Tổng Quát'.",
		"btn_text": "🎫 LẤY PHIẾU KHÁM NỘI CÓ BHYT"
	},
	{
		"station_id": 2,
		"name": "Trạm 2: Quầy Tiếp Nhận & Xuất Trình Giấy Tờ",
		"desc": "Xuất trình Thẻ BHYT (hoặc app VssID) + CCCD gắn chip. (Bên ngoài có cò mồi gạ 300k khám nhanh).",
		"btn_text": "📁 XUẤT TRÌNH BHYT + CCCD (QUYỀN LỢI 80-100%%)"
	},
	{
		"station_id": 3,
		"name": "Trạm 3: Phòng Bác Sĩ Chẩn Đoán",
		"desc": "Khai báo thành thật triệu chứng đau ngực/sốt, tiền sử dị ứng thuốc, không giấu bệnh.",
		"btn_text": "🩺 KHAI BÁO TRIỆU CHỨNG & TIỀN SỬ DỊ ỨNG"
	},
	{
		"station_id": 4,
		"name": "Trạm 4: Quầy Thanh Toán Viện Phí Đồng Chi Trả",
		"desc": "Kiểm tra bảng kê chi phí: BHYT đã chi trả phần lớn, chỉ nộp phần đồng chi trả hợp pháp.",
		"btn_text": "💳 THANH TOÁN PHẦN ĐỒNG CHI TRẢ QUA QR"
	},
	{
		"station_id": 5,
		"name": "Trạm 5: Quầy Dược BHYT Lãnh Thuốc",
		"desc": "Đối chiếu tên thuốc, số lượng và hạn sử dụng trên đơn thuốc trước khi rời bệnh viện.",
		"btn_text": "💊 KIỂM TRA ĐƠN THUỐC & NHẬN ĐẦY ĐỦ THUỐC BHYT"
	}
]

func _init_level2_bhyt_hospital() -> void:
	current_station = 1
	tout_rejected = false
	bhyt_docs_presented = false
	_build_level2_ui()

func _build_level2_ui() -> void:
	if not level2_container: return
	for ch in level2_container.get_children(): ch.queue_free()
	
	var v_box = VBoxContainer.new()
	v_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	v_box.add_theme_constant_override("separation", 8)
	
	# Khung Trạm hiện tại
	var st_panel = PanelContainer.new()
	var sb_st = StyleBoxFlat.new()
	sb_st.bg_color = Color(0.96, 0.98, 0.96, 1.0)
	sb_st.border_color = Color(0.25, 0.65, 0.35, 1.0)
	sb_st.set_border_width_all(2)
	sb_st.set_corner_radius_all(10)
	st_panel.add_theme_stylebox_override("panel", sb_st)
	
	var s_vbox = VBoxContainer.new()
	s_vbox.add_theme_constant_override("separation", 6)
	
	station_status_lbl = Label.new()
	station_status_lbl.name = "StationStatusLabel"
	station_status_lbl.text = "🏥 TRẠM 1 / 5: KIOSK TỰ ĐỘNG - LẤY PHIẾU THỨ TỰ"
	station_status_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	station_status_lbl.add_theme_font_size_override("font_size", 11)
	station_status_lbl.add_theme_color_override("font_color", Color(0.15, 0.5, 0.2, 1.0))
	s_vbox.add_child(station_status_lbl)
	
	var s_desc = Label.new()
	s_desc.name = "StationDescLabel"
	s_desc.text = STATIONS_DATA[0]["desc"]
	s_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	s_desc.add_theme_font_size_override("font_size", 9)
	s_desc.add_theme_color_override("font_color", Color(0.3, 0.3, 0.3, 1.0))
	s_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	s_vbox.add_child(s_desc)
	
	st_panel.add_child(s_vbox)
	v_box.add_child(st_panel)
	
	# Nút Cò Mồi (Chỉ xuất hiện ở Trạm 2)
	btn_reject_tout = Button.new()
	btn_reject_tout.name = "BtnRejectTout"
	btn_reject_tout.text = "⚠️ CÒ MỒI BẢO: 'ĐƯA 300K KHÁM VIP KHỎI CHỜ' ➔ [TỪ CHỐI & BÁO BẢO VỆ]"
	btn_reject_tout.custom_minimum_size = Vector2(0, 38)
	btn_reject_tout.add_theme_font_size_override("font_size", 9)
	btn_reject_tout.add_theme_color_override("font_color", Color(0.85, 0.25, 0.1, 1.0))
	btn_reject_tout.visible = false
	btn_reject_tout.pressed.connect(_on_reject_tout_pressed)
	JuicyButtonScript.attach_juice(btn_reject_tout, true)
	v_box.add_child(btn_reject_tout)
	
	# Nút Hành Động Trạm
	btn_station_action = Button.new()
	btn_station_action.name = "BtnStationAction"
	btn_station_action.text = STATIONS_DATA[0]["btn_text"]
	btn_station_action.custom_minimum_size = Vector2(0, 44)
	btn_station_action.add_theme_font_size_override("font_size", 10)
	btn_station_action.pressed.connect(_on_station_action_pressed)
	JuicyButtonScript.attach_juice(btn_station_action, true)
	v_box.add_child(btn_station_action)
	
	level2_container.add_child(v_box)

func _on_reject_tout_pressed() -> void:
	SoundManager.play_success()
	tout_rejected = true
	btn_reject_tout.text = "✔ ĐÃ TỪ CHỐI CÒ MỒI: KHÔNG TIẾP TAY TIÊU CỰC"
	btn_reject_tout.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25, 1.0))
	btn_reject_tout.disabled = true
	cat_speech_lbl.text = "Rất tỉnh táo Sen ơi! Cò mồi bệnh viện là lừa đảo hoặc tiếp tay tiêu cực! Khám BHYT chính quy vừa an toàn vừa tiết kiệm!"

func _on_station_action_pressed() -> void:
	SoundManager.play_click()
	
	if current_station == 2 and not tout_rejected:
		cat_speech_lbl.text = "Sen hãy nhấn từ chối cò mồi bên trên trước khi xuất trình BHYT nhé! 🐾"
		return
		
	current_station += 1
	if current_station <= 5:
		var st_data = STATIONS_DATA[current_station - 1]
		station_status_lbl.text = "🏥 TRẠM %d / 5: %s" % [current_station, st_data["name"]]
		var desc_lbl = level2_container.find_child("StationDescLabel", true, false) as Label
		if desc_lbl: desc_lbl.text = st_data["desc"]
		btn_station_action.text = st_data["btn_text"]
		
		if current_station == 2:
			btn_reject_tout.visible = true
		else:
			btn_reject_tout.visible = false
			
		cat_speech_lbl.text = "Đã qua %s! Tiếp tục thực hiện đúng quy trình nào Sen!" % st_data["name"]
	else:
		completed_levels[2] = true
		SoundManager.play_success()
		cat_speech_lbl.text = "🎉 XUẤT SẮC! Hoàn tất cả 5 trạm quy trình BHYT bệnh viện công! Bác sĩ tận tình, thuốc men đầy đủ, chi phí được BHYT thanh toán đúng luật! Chuyển sang Level 3 nào! ✨"
		get_tree().create_timer(1.2).timeout.connect(func():
			load_level(3)
		)

# =========================================================================
# LEVEL 3: NHỊP SINH HỌC & HƠI THỞ 4-7-8 CÙNG MOCHI (WELLNESS & BREATHING)
# =========================================================================
var stat_stress_lbl: Label = null
var stat_focus_lbl: Label = null
var breath_circle_panel: PanelContainer = null
var breath_timer_lbl: Label = null
var btn_start_breath: Button = null
var btn_sleep_now: Button = null

func _init_level3_wellness_breathing() -> void:
	focus_stat = 50
	stress_stat = 85
	hydration_stat = 30
	breathing_phase = "IDLE"
	breathing_progress = 0.0
	breathing_cycles_done = 0
	_build_level3_ui()

func _build_level3_ui() -> void:
	if not level3_container: return
	for ch in level3_container.get_children(): ch.queue_free()
	
	var v_box = VBoxContainer.new()
	v_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	v_box.add_theme_constant_override("separation", 8)
	
	# Thanh trạng thái thể chất & tinh thần
	var stat_panel = PanelContainer.new()
	var sb_stat = StyleBoxFlat.new()
	sb_stat.bg_color = Color(0.97, 0.95, 0.92, 1.0)
	sb_stat.border_color = Color(0.7, 0.5, 0.35, 1.0)
	sb_stat.set_border_width_all(2)
	sb_stat.set_corner_radius_all(10)
	stat_panel.add_theme_stylebox_override("panel", sb_stat)
	
	var stat_hbox = HBoxContainer.new()
	stat_hbox.add_theme_constant_override("separation", 12)
	
	stat_stress_lbl = Label.new()
	stat_stress_lbl.text = "⚡ Căng thẳng: %d / 100 (BÁO ĐỘNG)" % stress_stat
	stat_stress_lbl.add_theme_font_size_override("font_size", 10)
	stat_stress_lbl.add_theme_color_override("font_color", Color(0.85, 0.25, 0.15, 1.0))
	stat_hbox.add_child(stat_stress_lbl)
	
	stat_focus_lbl = Label.new()
	stat_focus_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stat_focus_lbl.text = "🧠 Tập trung: %d / 100 • 🌙 1:00 AM" % focus_stat
	stat_focus_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stat_focus_lbl.add_theme_font_size_override("font_size", 10)
	stat_focus_lbl.add_theme_color_override("font_color", Color(0.4, 0.3, 0.2, 1.0))
	stat_hbox.add_child(stat_focus_lbl)
	
	stat_panel.add_child(stat_hbox)
	v_box.add_child(stat_panel)
	
	# Vòng tròn thở 4-7-8 (Cozy Breathing Widget)
	breath_circle_panel = PanelContainer.new()
	breath_circle_panel.name = "BreathCirclePanel"
	breath_circle_panel.custom_minimum_size = Vector2(0, 110)
	var sb_b = StyleBoxFlat.new()
	sb_b.bg_color = Color(0.92, 0.96, 0.98, 1.0)
	sb_b.border_color = Color(0.35, 0.65, 0.85, 1.0)
	sb_b.set_border_width_all(2)
	sb_b.set_corner_radius_all(14)
	breath_circle_panel.add_theme_stylebox_override("panel", sb_b)
	
	var b_vbox = VBoxContainer.new()
	b_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	b_vbox.add_theme_constant_override("separation", 4)
	
	var b_guide = Label.new()
	b_guide.text = "🌬️ BÀI TẬP THỞ 4-7-8 ĐIỀU HÒA THẦN KINH CÙNG MOCHI"
	b_guide.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b_guide.add_theme_font_size_override("font_size", 10)
	b_guide.add_theme_color_override("font_color", Color(0.15, 0.45, 0.7, 1.0))
	b_vbox.add_child(b_guide)
	
	breath_timer_lbl = Label.new()
	breath_timer_lbl.name = "BreathTimerLabel"
	breath_timer_lbl.text = "Hít vào bằng mũi (4s) ➔ Giữ hơi (7s) ➔ Thở ra từ từ bằng miệng (8s)"
	breath_timer_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	breath_timer_lbl.add_theme_font_size_override("font_size", 10)
	breath_timer_lbl.add_theme_color_override("font_color", Color(0.2, 0.35, 0.5, 1.0))
	b_vbox.add_child(breath_timer_lbl)
	
	breath_circle_panel.add_child(b_vbox)
	v_box.add_child(breath_circle_panel)
	
	# Nút Bắt đầu thở & Nút Đi ngủ
	var act_hbox = HBoxContainer.new()
	act_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	act_hbox.add_theme_constant_override("separation", 10)
	
	btn_start_breath = Button.new()
	btn_start_breath.name = "BtnStartBreath"
	btn_start_breath.text = "🫁 BẮT ĐẦU 1 CHU KỲ THỞ 4-7-8 (19 GIÂY)"
	btn_start_breath.custom_minimum_size = Vector2(230, 42)
	btn_start_breath.add_theme_font_size_override("font_size", 9)
	btn_start_breath.pressed.connect(_on_start_breathing_pressed)
	JuicyButtonScript.attach_juice(btn_start_breath, true)
	act_hbox.add_child(btn_start_breath)
	
	btn_sleep_now = Button.new()
	btn_sleep_now.name = "BtnSleepNow"
	btn_sleep_now.text = "🛌 TẮT ĐÈN NGỦ ĐỦ 7 TIẾNG ĐỂ PHỤC HỒI NÃO BỘ"
	btn_sleep_now.custom_minimum_size = Vector2(230, 42)
	btn_sleep_now.add_theme_font_size_override("font_size", 9)
	btn_sleep_now.disabled = true
	btn_sleep_now.pressed.connect(_on_sleep_now_pressed)
	JuicyButtonScript.attach_juice(btn_sleep_now, true)
	act_hbox.add_child(btn_sleep_now)
	
	v_box.add_child(act_hbox)
	level3_container.add_child(v_box)

func _on_start_breathing_pressed() -> void:
	SoundManager.play_success()
	btn_start_breath.disabled = true
	breathing_phase = "INHALE_4"
	breathing_cycles_done += 1
	
	# Mô phỏng nhanh chu kỳ thở
	breath_timer_lbl.text = "🍃 Hít vào thật sâu bằng mũi... (1... 2... 3... 4s)"
	breath_timer_lbl.add_theme_color_override("font_color", Color(0.1, 0.6, 0.3, 1.0))
	cat_speech_lbl.text = "Mochi cùng hít vào với Sen nè... Bụng phình ra nhẹ nhàng..."
	
	get_tree().create_timer(1.0).timeout.connect(func():
		breathing_phase = "HOLD_7"
		breath_timer_lbl.text = "⏸️ Giữ hơi thở lại... Nhịp tim đang chậm dần... (7s)"
		breath_timer_lbl.add_theme_color_override("font_color", Color(0.8, 0.5, 0.1, 1.0))
		cat_speech_lbl.text = "Giữ yên hơi thở... Nhịp tim đập chậm lại... Rất bình an..."
		
		get_tree().create_timer(1.0).timeout.connect(func():
			breathing_phase = "EXHALE_8"
			breath_timer_lbl.text = "🌬️ Thở ra từ từ bằng miệng, buông bỏ mọi lo âu... (8s)"
			breath_timer_lbl.add_theme_color_override("font_color", Color(0.2, 0.4, 0.8, 1.0))
			cat_speech_lbl.text = "Khà... Thở ra hết mệt mỏi... Mochi purr purr gừ gừ xoa dịu Sen..."
			
			get_tree().create_timer(1.0).timeout.connect(func():
				_finish_breathing_cycle()
			)
		)
	)

func _finish_breathing_cycle() -> void:
	breathing_phase = "FINISHED"
	stress_stat = 25
	focus_stat = 80
	if stat_stress_lbl:
		stat_stress_lbl.text = "⚡ Căng thẳng: %d / 100 (THƯ GIÃN)" % stress_stat
		stat_stress_lbl.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25, 1.0))
	if stat_focus_lbl:
		stat_focus_lbl.text = "🧠 Tập trung: %d / 100 • 🌙 1:00 AM" % focus_stat
		
	breath_timer_lbl.text = "✨ Chu kỳ hoàn tất! Nhịp tim đã ổn định, hệ thần kinh phó giao cảm được kích hoạt!"
	breath_timer_lbl.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25, 1.0))
	btn_sleep_now.disabled = false
	cat_speech_lbl.text = "Tâm trí đã thư thái rồi! Giờ là 1:00 AM, hãy tắt điện thoại đi ngủ để não bộ củng cố trí nhớ cho ngày thi mai nha Sen! 🐾"

func _on_sleep_now_pressed() -> void:
	SoundManager.play_success()
	completed_levels[3] = true
	_show_healthcare_victory()

# =========================================================================
# VICTORY MODAL & CERTIFICATE
# =========================================================================
func _show_healthcare_victory() -> void:
	SoundManager.play_success()
	var speech = "🎉 CHÚC MỪNG BẬC THẦY SỨC KHỎE & THÂN TÂM TỰ LẬP!\n\n"
	speech += "Mèo con đã hoàn thành xuất sắc toàn bộ 3 Cấp độ Y Tế, BHYT & Sức Khỏe:\n\n"
	speech += "✔ Cấp độ 1: Xử lý bỏng bằng nước mát chuẩn y khoa & chia liều Paracetamol 10mg/kg.\n"
	speech += "✔ Cấp độ 2: Điều hướng 5 trạm bệnh viện công bằng thẻ BHYT & kiên quyết từ chối cò mồi.\n"
	speech += "✔ Cấp độ 3: Kích hoạt nhịp thở 4-7-8 cùng Mochi, đập tan stress mùa thi và ngủ đủ giấc.\n\n"
	speech += "🎖️ Nhận danh hiệu 'Bậc Thầy Sức Khỏe & Thân Tâm Tự Lập' & Thưởng +45 Cá Khô!"
	if victory_dialogue_lbl:
		victory_dialogue_lbl.text = speech
		
	_build_polaroid_healthcare_pass()
	if victory_modal:
		victory_modal.visible = true

func _build_polaroid_healthcare_pass() -> void:
	if polaroid_cert_panel and is_instance_valid(polaroid_cert_panel):
		polaroid_cert_panel.queue_free()
		
	polaroid_cert_panel = PanelContainer.new()
	polaroid_cert_panel.name = "PolaroidHealthcarePass"
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
	
	var owner_name = GameManager.owner_name if "owner_name" in GameManager and GameManager.owner_name != "" else "Sen Khỏe Mạnh"
	
	var title = Label.new()
	title.text = "📜 CHỨNG NHẬN: BẬC THẦY SỨC KHỎE & THÂN TÂM TỰ LẬP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color(0.42, 0.22, 0.08, 1.0))
	v.add_child(title)
	
	var desc = Label.new()
	desc.text = "Cấp cho: %s\nHoàn tất 3 Cấp độ Sơ Cứu Bỏng/Hạ Sốt, Quy Trình BHYT 5 Trạm & Hơi Thở 4-7-8 • Làm chủ thân tâm vững vàng!" % [owner_name]
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
	GameManager.complete_lesson(2)
	var sim_steps = [
		{"icon": "🩹", "text": "Sơ cứu bỏng bằng nước mát & tính liều hạ sốt 500mg"},
		{"icon": "🏥", "text": "Hoàn tất quy trình 5 trạm BHYT & né cò mồi"},
		{"icon": "🌬️", "text": "Thực hành chu kỳ thở 4-7-8 hạ căng thẳng mùa thi"},
		{"icon": "🌙", "text": "Tắt đèn ngủ đủ 7 tiếng phục hồi não bộ"}
	]
	emit_signal("minigame_completed", sim_steps)

func _on_help_pressed() -> void:
	SoundManager.play_click()
	match current_level:
		1:
			cat_speech_lbl.text = "💡 MẸO SƠ CỨU: Bỏng thì ngâm nước mát 15-20p, không bôi kem đánh răng. Hạ sốt tính 10-15mg/kg, uống cách 4-6 tiếng!"
		2:
			cat_speech_lbl.text = "💡 MẸO BHYT: Mang đủ BHYT và CCCD gắn chip. Tuyệt đối không nghe theo cò mồi ngoài cổng!"
		3:
			cat_speech_lbl.text = "💡 MẸO THƯ GIÃN: Hít 4s, giữ 7s, thở 8s để kích hoạt hệ thần kinh phó giao cảm giúp giảm stress nhanh chóng!"
