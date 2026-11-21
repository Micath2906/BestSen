extends Control

# DOCTOR SIMULATION GAME (BÁC SĨ MÈO NHÍ: CỨU THƯƠNG ĐÊM SỐT)
# Mô phỏng tương tác thực tế: Đo nhiệt độ -> Lau khăn ấm -> Tính liều Paracetamol -> Pha Oresol

signal minigame_completed(result: Dictionary)

enum Step {
	MEASURE_TEMP,
	COOL_DOWN_PHYSICAL,
	CHOOSE_MEDICINE,
	HYDRATE_ORESOL,
	CURED
}

var current_step: Step = Step.MEASURE_TEMP
var current_temp: float = 39.2
var safe_failures: int = 0

# UI references
var lbl_temp_lcd: Label
var lbl_patient_status: Label
var tex_patient: TextureRect
var step_instruction_lbl: Label
var tools_container: VBoxContainer
var victory_modal: PanelContainer
var warning_modal: PanelContainer
var lbl_warning_text: Label

func _ready() -> void:
	_build_ui()
	_update_view()

func _build_ui() -> void:
	var bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#FFFDF9")
	add_child(bg)

	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.set("theme_override_constants/separation", 8)
	add_child(main_vbox)

	# 1. Header Bar
	var header = PanelContainer.new()
	header.custom_minimum_size = Vector2(0, 48)
	var h_sb = StyleBoxFlat.new()
	h_sb.bg_color = Color("#059669")
	h_sb.content_margin_left = 12
	h_sb.content_margin_right = 12
	header.add_theme_stylebox_override("panel", h_sb)
	main_vbox.add_child(header)

	var header_hbox = HBoxContainer.new()
	header.add_child(header_hbox)

	var btn_back = Button.new()
	btn_back.name = "BtnBack"
	btn_back.text = "⬅ QUAY LẠI"
	btn_back.custom_minimum_size = Vector2(85, 32)
	btn_back.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_back.pressed.connect(_on_back_pressed)
	header_hbox.add_child(btn_back)

	var title_lbl = Label.new()
	title_lbl.text = "🩺 BÁC SĨ MÈO NHÍ: CỨU THƯƠNG ĐÊM SỐT"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 13)
	title_lbl.add_theme_color_override("font_color", Color.WHITE)
	header_hbox.add_child(title_lbl)

	# 2. Patient Monitor Bar (LCD Digital Thermometer)
	var monitor_panel = PanelContainer.new()
	var m_sb = StyleBoxFlat.new()
	m_sb.bg_color = Color("#1F2937")
	m_sb.border_color = Color("#374151")
	m_sb.set_border_width_all(3)
	m_sb.set_corner_radius_all(10)
	m_sb.content_margin_left = 16
	m_sb.content_margin_right = 16
	m_sb.content_margin_top = 8
	m_sb.content_margin_bottom = 8
	monitor_panel.add_theme_stylebox_override("panel", m_sb)
	main_vbox.add_child(monitor_panel)

	var mon_hbox = HBoxContainer.new()
	monitor_panel.add_child(mon_hbox)

	var lbl_patient_info = Label.new()
	lbl_patient_info.text = "🐱 Bệnh nhân: Mochi | Cân nặng: 40.0 kg"
	lbl_patient_info.add_theme_font_size_override("font_size", 11)
	lbl_patient_info.add_theme_color_override("font_color", Color("#9CA3AF"))
	lbl_patient_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mon_hbox.add_child(lbl_patient_info)

	lbl_temp_lcd = Label.new()
	lbl_temp_lcd.text = "🌡️ 39.2°C [SỐT CAO]"
	lbl_temp_lcd.add_theme_font_size_override("font_size", 14)
	lbl_temp_lcd.add_theme_color_override("font_color", Color("#EF4444"))
	mon_hbox.add_child(lbl_temp_lcd)

	# 3. Patient Bed Area
	var bed_panel = PanelContainer.new()
	bed_panel.custom_minimum_size = Vector2(0, 240)
	var bed_sb = StyleBoxFlat.new()
	bed_sb.bg_color = Color("#ECFDF5")
	bed_sb.border_color = Color("#10B981")
	bed_sb.set_border_width_all(2)
	bed_sb.set_corner_radius_all(12)
	bed_sb.content_margin_left = 12
	bed_sb.content_margin_right = 12
	bed_sb.content_margin_top = 10
	bed_sb.content_margin_bottom = 10
	bed_panel.add_theme_stylebox_override("panel", bed_sb)
	main_vbox.add_child(bed_panel)

	var bed_vbox = VBoxContainer.new()
	bed_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	bed_vbox.set("theme_override_constants/separation", 6)
	bed_panel.add_child(bed_vbox)

	tex_patient = TextureRect.new()
	tex_patient.texture = GameManager.load_texture("res://assets/sprites/minigames/doctor/cat_patient_fever.png")
	tex_patient.custom_minimum_size = Vector2(160, 150)
	tex_patient.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	tex_patient.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bed_vbox.add_child(tex_patient)

	lbl_patient_status = Label.new()
	lbl_patient_status.text = "Mochi đang sốt li bì, trán nóng rực, thở dốc..."
	lbl_patient_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_patient_status.add_theme_font_size_override("font_size", 11)
	lbl_patient_status.add_theme_color_override("font_color", Color("#065F46"))
	bed_vbox.add_child(lbl_patient_status)

	# 4. Doctor Step & Action Tray
	var step_panel = PanelContainer.new()
	var s_sb = StyleBoxFlat.new()
	s_sb.bg_color = Color("#FFFBEB")
	s_sb.border_color = Color("#F59E0B")
	s_sb.set_border_width_all(2)
	s_sb.set_corner_radius_all(8)
	s_sb.content_margin_left = 12
	s_sb.content_margin_right = 12
	s_sb.content_margin_top = 6
	s_sb.content_margin_bottom = 6
	step_panel.add_theme_stylebox_override("panel", s_sb)
	main_vbox.add_child(step_panel)

	step_instruction_lbl = Label.new()
	step_instruction_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	step_instruction_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	step_instruction_lbl.add_theme_font_size_override("font_size", 11)
	step_instruction_lbl.add_theme_color_override("font_color", Color("#92400E"))
	step_panel.add_child(step_instruction_lbl)

	# 5. Interactive Tool Buttons Container
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)

	var center_tools = CenterContainer.new()
	center_tools.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(center_tools)

	tools_container = VBoxContainer.new()
	tools_container.custom_minimum_size = Vector2(460, 0)
	tools_container.set("theme_override_constants/separation", 10)
	center_tools.add_child(tools_container)

	# 6. Educational Warning Popup
	warning_modal = PanelContainer.new()
	warning_modal.visible = false
	var w_sb = StyleBoxFlat.new()
	w_sb.bg_color = Color("#FEF2F2")
	w_sb.border_color = Color("#EF4444")
	w_sb.set_border_width_all(3)
	w_sb.set_corner_radius_all(10)
	w_sb.content_margin_left = 14
	w_sb.content_margin_right = 14
	w_sb.content_margin_top = 10
	w_sb.content_margin_bottom = 10
	warning_modal.add_theme_stylebox_override("panel", w_sb)
	main_vbox.add_child(warning_modal)

	var w_vbox = VBoxContainer.new()
	warning_modal.add_child(w_vbox)

	var w_title = Label.new()
	w_title.text = "⚠️ CẢNH BÁO Y KHOA NGUY HIỂM!"
	w_title.add_theme_font_size_override("font_size", 12)
	w_title.add_theme_color_override("font_color", Color("#991B1B"))
	w_vbox.add_child(w_title)

	lbl_warning_text = Label.new()
	lbl_warning_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_warning_text.add_theme_font_size_override("font_size", 10)
	lbl_warning_text.add_theme_color_override("font_color", Color("#7F1D1D"))
	w_vbox.add_child(lbl_warning_text)

	var btn_close_warn = Button.new()
	btn_close_warn.text = "ĐÃ RÚT KINH NGHIỆM ✖"
	btn_close_warn.custom_minimum_size = Vector2(0, 28)
	btn_close_warn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_close_warn.pressed.connect(func(): warning_modal.visible = false)
	w_vbox.add_child(btn_close_warn)

	# 7. Victory Modal
	victory_modal = PanelContainer.new()
	victory_modal.visible = false
	var vic_sb = StyleBoxFlat.new()
	vic_sb.bg_color = Color("#ECFDF5")
	vic_sb.border_color = Color("#10B981")
	vic_sb.set_border_width_all(4)
	vic_sb.set_corner_radius_all(12)
	vic_sb.content_margin_left = 16
	vic_sb.content_margin_right = 16
	vic_sb.content_margin_top = 12
	vic_sb.content_margin_bottom = 12
	victory_modal.add_theme_stylebox_override("panel", vic_sb)
	main_vbox.add_child(victory_modal)

	var vic_vbox = VBoxContainer.new()
	victory_modal.add_child(vic_vbox)

	var vic_title = Label.new()
	vic_title.text = "🏆 PHONG TẶNG: BÁC SĨ MÈO XUẤT SẮC!"
	vic_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vic_title.add_theme_font_size_override("font_size", 14)
	vic_title.add_theme_color_override("font_color", Color("#065F46"))
	vic_vbox.add_child(vic_title)

	var vic_desc = Label.new()
	vic_desc.text = "Bạn đã nắm vững quy trình xử lý sốt cấp tính:\n1. Đo nhiệt độ chính xác\n2. Lau mát khăn ấm 35-37°C\n3. Uống đúng liều Paracetamol theo cân nặng\n4. Bù đủ nước & điện giải Oresol!"
	vic_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vic_desc.add_theme_font_size_override("font_size", 10)
	vic_desc.add_theme_color_override("font_color", Color("#047857"))
	vic_vbox.add_child(vic_desc)

	var btn_finish = Button.new()
	btn_finish.text = "🎉 HOÀN THÀNH VÀ LƯU KỸ NĂNG"
	btn_finish.custom_minimum_size = Vector2(0, 36)
	btn_finish.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn_finish.pressed.connect(_on_back_pressed)
	vic_vbox.add_child(btn_finish)

func _update_view() -> void:
	for child in tools_container.get_children():
		child.queue_free()

	match current_step:
		Step.MEASURE_TEMP:
			lbl_temp_lcd.text = "🌡️ ?? ?°C [CHƯA ĐO]"
			lbl_temp_lcd.add_theme_color_override("font_color", Color("#9CA3AF"))
			step_instruction_lbl.text = "BƯỚC 1: Dùng nhiệt kế điện tử kẹp vào nách hoặc tai Mochi để xác định chính xác thân nhiệt!"
			
			var btn_thermo = _create_tool_card("res://assets/sprites/minigames/doctor/tool_thermometer.png", "Kẹp Nhiệt Kế Điện Tử", "Chạm để kẹp vào nách Mochi và đo trong 5 giây", Color("#3B82F6"))
			btn_thermo.pressed.connect(_on_measure_temp)
			tools_container.add_child(btn_thermo)

		Step.COOL_DOWN_PHYSICAL:
			lbl_temp_lcd.text = "🌡️ 39.2°C [SỐT CAO CO GIẬT]"
			lbl_temp_lcd.add_theme_color_override("font_color", Color("#EF4444"))
			step_instruction_lbl.text = "BƯỚC 2: Thân nhiệt 39.2°C! Hãy chọn phương pháp hạ sốt vật lý an toàn trước khi dùng thuốc:"

			# Choice 1: Warm Towel (Correct)
			var btn_warm = _create_tool_card("res://assets/sprites/minigames/doctor/tool_warm_towel.png", "Khăn Nước Ấm 35 - 37°C", "Lau trán, 2 bên nách và 2 bên bẹn để giãn mạch giải nhiệt", Color("#10B981"))
			btn_warm.pressed.connect(_on_use_warm_towel)
			tools_container.add_child(btn_warm)

			# Choice 2: Ice Pack (Trap!)
			var btn_ice = _create_tool_card("res://assets/sprites/minigames/doctor/tool_ice_pack_trap.png", "Túi Chườm Đá Lạnh", "Chườm đá lạnh trực tiếp lên trán và nách", Color("#EF4444"))
			btn_ice.pressed.connect(_on_use_ice_trap)
			tools_container.add_child(btn_ice)

		Step.CHOOSE_MEDICINE:
			lbl_temp_lcd.text = "🌡️ 38.4°C [HẠ NHẸ NHỜ KHĂN ẤM]"
			lbl_temp_lcd.add_theme_color_override("font_color", Color("#F59E0B"))
			step_instruction_lbl.text = "BƯỚC 3: Mochi nặng 40kg (Liều chuẩn: 10-15mg/kg = 400-600mg). Chọn đúng loại thuốc trong tủ:"

			# Choice A: Paracetamol 500mg (Correct!)
			var btn_p500 = _create_tool_card("res://assets/sprites/minigames/doctor/tool_para_500.png", "Paracetamol 500mg (1 Viên)", "Đúng hàm lượng cho thể trạng 40kg + Cốc nước ấm", Color("#10B981"))
			btn_p500.pressed.connect(_on_choose_para500)
			tools_container.add_child(btn_p500)

			# Choice B: Paracetamol 1000mg (Overdose trap)
			var btn_p1000 = _create_tool_card("res://assets/sprites/minigames/doctor/tool_para_500.png", "Paracetamol 1000mg (Liều Cao)", "Uống liều cao cho nhanh cắt sốt", Color("#DC2626"))
			btn_p1000.pressed.connect(_on_choose_overdose_trap)
			tools_container.add_child(btn_p1000)

			# Choice C: Antibiotic Amoxicillin (Trap)
			var btn_ab = _create_tool_card("res://assets/sprites/minigames/doctor/tool_para_500.png", "Kháng Sinh Amoxicillin", "Uống kháng sinh phòng nhiễm trùng", Color("#6B7280"))
			btn_ab.pressed.connect(_on_choose_antibiotic_trap)
			tools_container.add_child(btn_ab)

		Step.HYDRATE_ORESOL:
			lbl_temp_lcd.text = "🌡️ 37.5°C [ĐÃ HẠ NHỜ THUỐC]"
			lbl_temp_lcd.add_theme_color_override("font_color", Color("#10B981"))
			step_instruction_lbl.text = "BƯỚC 4: Sốt cao toát mồ hôi mất rất nhiều muối và nước. Pha bù điện giải Oresol đúng tỷ lệ:"

			# Choice 1: Pha đúng 200ml (Correct)
			var btn_o200 = _create_tool_card("res://assets/sprites/minigames/doctor/tool_oresol_cup.png", "Pha Đúng 200ml Nước Đun Sôi Để Nguội", "Khuấy tan hoàn toàn và cho Mochi uống từng ngụm nhỏ", Color("#10B981"))
			btn_o200.pressed.connect(_on_hydrate_oresol_correct)
			tools_container.add_child(btn_o200)

			# Choice 2: Pha đậm đặc ít nước (Trap)
			var btn_odense = _create_tool_card("res://assets/sprites/minigames/doctor/tool_oresol_cup.png", "Pha Đậm Đặc Với 1 Ngụm Nước Cho Nhanh", "Pha ít nước cho Mochi uống 1 hơi hết luôn", Color("#EF4444"))
			btn_odense.pressed.connect(_on_hydrate_dense_trap)
			tools_container.add_child(btn_odense)

		Step.CURED:
			lbl_temp_lcd.text = "🌡️ 37.0°C [THÂN NHIỆT LÝ TƯỞNG]"
			lbl_temp_lcd.add_theme_color_override("font_color", Color("#059669"))
			step_instruction_lbl.text = "🎉 Mochi đã hoàn toàn cắt sốt, hồi phục khỏe khoắn và tràn đầy năng lượng!"
			tex_patient.texture = GameManager.load_texture("res://assets/sprites/minigames/doctor/cat_patient_cured.png")
			lbl_patient_status.text = "Mochi: Meo meo! Cảm ơn Bác Sĩ Sen đã chăm sóc em đúng cách nha!"
			victory_modal.visible = true
			emit_signal("minigame_completed", {"status": "victory", "safe_failures": safe_failures})

func _create_tool_card(icon_path: String, title: String, desc: String, border_c: Color) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(440, 56)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var sb = StyleBoxFlat.new()
	sb.bg_color = Color("#FFFDF9")
	sb.border_color = border_c
	sb.set_border_width_all(2)
	sb.border_width_bottom = 4
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)

	var hbox = HBoxContainer.new()
	hbox.set("theme_override_constants/separation", 10)
	btn.add_child(hbox)

	var tex = TextureRect.new()
	tex.texture = GameManager.load_texture(icon_path)
	tex.custom_minimum_size = Vector2(36, 36)
	tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hbox.add_child(tex)

	var vbox = VBoxContainer.new()
	vbox.set("theme_override_constants/separation", 2)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	var t_lbl = Label.new()
	t_lbl.text = title
	t_lbl.add_theme_font_size_override("font_size", 11)
	t_lbl.add_theme_color_override("font_color", Color("#1F2937"))
	vbox.add_child(t_lbl)

	var d_lbl = Label.new()
	d_lbl.text = desc
	d_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d_lbl.add_theme_font_size_override("font_size", 9)
	d_lbl.add_theme_color_override("font_color", Color("#4B5563"))
	vbox.add_child(d_lbl)

	return btn

# Step Actions
func _on_measure_temp() -> void:
	SoundManager.play_success()
	current_step = Step.COOL_DOWN_PHYSICAL
	_update_view()

func _on_use_warm_towel() -> void:
	SoundManager.play_success()
	current_step = Step.CHOOSE_MEDICINE
	_update_view()

func _on_use_ice_trap() -> void:
	SoundManager.play_click()
	safe_failures += 1
	lbl_warning_text.text = "CẢNH BÁO BẪY: Tuyệt đối KHÔNG chườm đá lạnh khi sốt! Đá lạnh làm co các mạch máu ngoại vi, khiến nhiệt lượng không thể thoát ra ngoài mà dồn vào cơ quan nội tạng, có thể gây sốt cao co giật và bỏng lạnh!"
	warning_modal.visible = true

func _choose_correct_para():
	SoundManager.play_success()
	current_step = Step.HYDRATE_ORESOL
	_update_view()

func _on_choose_para500() -> void:
	_choose_correct_para()

func _on_choose_overdose_trap() -> void:
	SoundManager.play_click()
	safe_failures += 1
	lbl_warning_text.text = "CẢNH BÁO QUÁ LIỀU: Paracetamol liều 1000mg là quá tải với người/mèo 40kg! Liều chuẩn y khoa là 10-15mg/kg (tức 400-600mg). Dùng 1000mg sẽ gây ngộ độc và hoại tử tế bào gan cấp tính!"
	warning_modal.visible = true

func _on_choose_antibiotic_trap() -> void:
	SoundManager.play_click()
	safe_failures += 1
	lbl_warning_text.text = "CẢNH BÁO KHÁNG KHÁNG SINH: Cảm sốt thông thường đa phần do VIRUS, thuốc kháng sinh chỉ diệt VI KHUẨN! Uống bừa bãi sẽ tiêu diệt lợi khuẩn đường ruột và sinh ra vi khuẩn kháng thuốc cực kỳ nguy hiểm!"
	warning_modal.visible = true

func _on_hydrate_oresol_correct() -> void:
	SoundManager.play_success()
	current_step = Step.CURED
	_update_view()

func _on_hydrate_dense_trap() -> void:
	SoundManager.play_click()
	safe_failures += 1
	lbl_warning_text.text = "CẢNH BÁO NGUY KỊCH: Pha Oresol quá đặc (ít nước) sẽ làm tăng áp lực thẩm thấu trong máu, hút nước từ các tế bào ra ngoài, dẫn tới tình trạng mất nước tế bào và có nguy cơ phù não, tử vong! Bắt buộc pha đúng định lượng trên gói!"
	warning_modal.visible = true

func _on_back_pressed() -> void:
	SoundManager.play_click()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
