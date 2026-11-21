extends Node

## test_new_minigames_standalone.gd
## Automated headless test suite for:
## 1. PixelPlaceholderFactory runtime generator & cache.
## 2. Standalone Packing Tetris Game (packing_tetris_game.tscn).
## 3. Standalone Room Inspection & Legal Diff Game (room_inspection_diff_game.tscn).
## 4. Standalone Doctor Simulation Game (doctor_simulation_game.tscn).
## 5. Standalone Budget Jars 2.000.000đ Game (budget_jars_game.tscn).

const PixelPlaceholderFactory = preload("res://scripts/utils/PixelPlaceholderFactory.gd")

var pass_count: int = 0
var fail_count: int = 0

func _ready() -> void:
	print("\n========================================================")
	print("  TEST SUITE: 5 REDESIGNED COZY MINIGAMES & PIXEL ART")
	print("========================================================\n")
	_run_all_tests()

func _assert_true(condition: bool, test_name: String) -> void:
	if condition:
		pass_count += 1
		print("  [PASS %02d] %s" % [pass_count, test_name])
	else:
		fail_count += 1
		printerr("  [FAIL %02d] %s" % [fail_count, test_name])

func _run_all_tests() -> void:
	await _test_pixel_placeholder_factory()
	await _test_packing_tetris_game_standalone()
	await _test_room_inspection_diff_game_standalone()
	await _test_doctor_simulation_game_standalone()
	await _test_budget_jars_game_standalone()
	
	print("\n========================================================")
	print("  TỔNG KẾT KIỂM THỬ: PASS=%d, FAIL=%d" % [pass_count, fail_count])
	print("========================================================")
	
	if fail_count == 0:
		print("🎉 TẤT CẢ 5 MINIGAME REDESIGN COZY PIXEL PASS 100%!\n")
		get_tree().quit(0)
	else:
		printerr("❌ CÓ %d BÀI KIỂM THỬ THẤT BẠI!" % fail_count)
		get_tree().quit(1)

func _test_pixel_placeholder_factory() -> void:
	print(">>> PHẦN 1: KIỂM THỬ PIXEL PLACEHOLDER FACTORY")
	var tex_clothes = PixelPlaceholderFactory.get_or_create("test_clothes", Vector2i(64, 64), PixelPlaceholderFactory.Category.CLOTHES)
	_assert_true(tex_clothes != null, "Khởi tạo texture quần áo thành công")
	_assert_true(tex_clothes.get_size() == Vector2(64, 64), "Kích thước texture quần áo đạt chuẩn pixel")

	var tex_docs = PixelPlaceholderFactory.get_or_create("test_docs", Vector2i(64, 64), PixelPlaceholderFactory.Category.DOCS)
	_assert_true(tex_docs != null, "Khởi tạo texture hồ sơ thành công")

	var tex_med = PixelPlaceholderFactory.get_or_create("test_med", Vector2i(64, 64), PixelPlaceholderFactory.Category.MEDICINE)
	_assert_true(tex_med != null, "Khởi tạo texture y tế thành công")

	var tex_tech = PixelPlaceholderFactory.get_or_create("test_tech", Vector2i(64, 64), PixelPlaceholderFactory.Category.TECH)
	_assert_true(tex_tech != null, "Khởi tạo texture công nghệ thành công")

	var tex_cached = PixelPlaceholderFactory.get_or_create("test_clothes", Vector2i(64, 64), PixelPlaceholderFactory.Category.CLOTHES)
	_assert_true(tex_cached == tex_clothes, "Texture được nạp đúng từ bộ nhớ đệm cache (Idempotent)")

func _test_packing_tetris_game_standalone() -> void:
	print("\n>>> PHẦN 2: KIỂM THỬ STANDALONE PACKING TETRIS GAME (packing_tetris_game.tscn)")
	var scene = load("res://scenes/minigames/packing_tetris_game.tscn")
	_assert_true(scene != null, "Nạp resource packing_tetris_game.tscn thành công")

	var node = scene.instantiate()
	add_child(node)
	_assert_true(node != null, "Instantiate packing_tetris_game thành công")
	await get_tree().process_frame

	# Check 4 Bags
	_assert_true(node.bags_data.size() == 4, "Tetris: Cấu hình chuẩn 4 túi riêng biệt")
	_assert_true(node.bags_data[0].id == "clothes", "Tetris: Túi 1 là Quần áo")
	_assert_true(node.bags_data[1].id == "docs", "Tetris: Túi 2 là Hồ sơ")
	_assert_true(node.bags_data[2].id == "meds", "Tetris: Túi 3 là Y tế")
	_assert_true(node.bags_data[3].id == "tech", "Tetris: Túi 4 là Công nghệ")

	# Check Controls & Buttons
	_assert_true(node.find_child("BtnBack", true, false) != null, "Tetris: Có nút BtnBack")
	_assert_true(node.btn_rotate != null, "Tetris: Có nút Xoay vật phẩm 90°")
	_assert_true(node.btn_clear_bag != null, "Tetris: Có nút Lấy hết đồ ra")
	_assert_true(node.btn_finish_bag != null, "Tetris: Có nút Khóa kéo túi")

	# Select Item & Rotate
	var bag = node.bags_data[0]
	var item_hoodie = bag.items[0]
	node._select_item_to_place(item_hoodie)
	_assert_true(node.selected_item_data.id == "hoodie", "Tetris: Chọn thành công item Hoodie 2x2")

	var old_shape = node.selected_item_rotated_shape.duplicate(true)
	node._on_rotate_pressed()
	_assert_true(node.selected_item_rotated_shape.size() == old_shape[0].size(), "Tetris: Xoay ma trận 90° thành công")

	# Place on grid
	node._on_cell_clicked(0, 0)
	_assert_true(node.placed_items.has("hoodie"), "Tetris: Đặt thành công Hoodie vào ô (0, 0)")
	_assert_true(node.grid_cells[0][0] == "hoodie", "Tetris: Ô lưới ghi nhận mã hoodie")

	# Remove from grid
	node._remove_placed_item("hoodie")
	_assert_true(not node.placed_items.has("hoodie"), "Tetris: Nhấc thành công Hoodie ra khỏi lưới")
	_assert_true(node.grid_cells[0][0] == "", "Tetris: Ô lưới được dọn sạch")

	# Place all items in bag 0
	for it in bag.items:
		node.placed_items[it.get("id")] = {"pos": Vector2i(0, 0), "shape": it.get("shape")}
	_assert_true(node.placed_items.size() == bag.items.size(), "Tetris: Đã xếp đủ tất cả các món đồ trong túi")

	node.queue_free()
	await get_tree().process_frame

func _test_room_inspection_diff_game_standalone() -> void:
	print("\n>>> PHẦN 3: KIỂM THỬ STANDALONE SPOT DIFFERENCE GAME (room_inspection_diff_game.tscn)")
	var scene = load("res://scenes/minigames/room_inspection_diff_game.tscn")
	_assert_true(scene != null, "Nạp resource room_inspection_diff_game.tscn thành công")

	var node = scene.instantiate()
	add_child(node)
	_assert_true(node != null, "Instantiate room_inspection_diff_game thành công")
	await get_tree().process_frame

	# Check 3 Stages
	_assert_true(node.stages.size() == 3, "Diff Game: Cấu hình đầy đủ 3 màn so sánh thực tế")
	_assert_true(node.stages[0].id == "room", "Diff Game: Màn 1 - Căn phòng trọ")
	_assert_true(node.stages[1].id == "meter", "Diff Game: Màn 2 - Công tơ điện nước")
	_assert_true(node.stages[2].id == "contract", "Diff Game: Màn 3 - Bút dạ quang hợp đồng")

	# Check UI Images & Areas
	_assert_true(node.tex_ad != null and node.tex_ad.texture != null, "Diff Game: Có texture ảnh quảng cáo chuẩn")
	_assert_true(node.tex_real != null and node.tex_real.texture != null, "Diff Game: Có texture ảnh thực tế có bẫy")
	_assert_true(node.find_child("BtnBack", true, false) != null, "Diff Game: Có nút BtnBack")

	# Stage 1: Room Inspection (5 errors)
	var stage0 = node.stages[0]
	_assert_true(stage0.errors.size() == 5, "Diff Game: Màn 1 có đủ 5 bẫy hạ tầng")

	# Simulate clicking error 1 (vòi rỉ)
	var ev1 = InputEventMouseButton.new()
	ev1.pressed = true
	ev1.button_index = MOUSE_BUTTON_LEFT
	ev1.position = Vector2(55, 100) # Inside rect (45, 90, 35, 35)
	node._on_real_image_clicked(ev1)

	_assert_true(node.found_errors.has("leak_tap"), "Diff Game: Phát hiện thành công Vòi Nước Bồn Rửa Bị Rỉ")
	_assert_true(node.popup_dialog.visible == true, "Diff Game: Mở popup cẩm nang giải thích lỗi")

	# Switch to Stage 2 (Meter)
	node._load_stage(1)
	_assert_true(node.current_stage_idx == 1, "Diff Game: Chuyển màn 2 Công Tơ Điện Nước thành công")
	_assert_true(node.stages[1].errors.size() == 3, "Diff Game: Màn 2 có đủ 3 bẫy gian lận")

	# Switch to Stage 3 (Contract)
	node._load_stage(2)
	_assert_true(node.current_stage_idx == 2, "Diff Game: Chuyển màn 3 Hợp Đồng Thuê thành công")
	_assert_true(node.stages[2].errors.size() == 3, "Diff Game: Màn 3 có đủ 3 bẫy điều khoản câu chữ")

	node.queue_free()
	await get_tree().process_frame

func _test_doctor_simulation_game_standalone() -> void:
	print("\n>>> PHẦN 4: KIỂM THỬ STANDALONE DOCTOR SIMULATION GAME (doctor_simulation_game.tscn)")
	var scene = load("res://scenes/minigames/doctor_simulation_game.tscn")
	_assert_true(scene != null, "Nạp resource doctor_simulation_game.tscn thành công")

	var node = scene.instantiate()
	add_child(node)
	_assert_true(node != null, "Instantiate doctor_simulation_game thành công")
	await get_tree().process_frame

	# Check UI
	_assert_true(node.find_child("BtnBack", true, false) != null, "Doctor: Có nút BtnBack")
	_assert_true(node.lbl_temp_lcd != null, "Doctor: Có màn hình nhiệt độ LCD")
	_assert_true(node.tex_patient != null and node.tex_patient.texture != null, "Doctor: Có sprite Mèo bệnh nhân sốt trên giường")

	# Step 1: Measure Temperature
	_assert_true(node.current_step == node.Step.MEASURE_TEMP, "Doctor: Ban đầu ở bước đo nhiệt độ")
	node._on_measure_temp()
	_assert_true(node.current_step == node.Step.COOL_DOWN_PHYSICAL, "Doctor: Đo xong chuyển sang hạ sốt vật lý")
	_assert_true(node.lbl_temp_lcd.text.contains("39.2°C"), "Doctor: LCD hiển thị nhiệt độ sốt cao 39.2°C")

	# Step 2: Trap - Ice Pack
	var fail_before = node.safe_failures
	node._on_use_ice_trap()
	_assert_true(node.safe_failures > fail_before, "Doctor: Ghi nhận thử sai an toàn khi chọn túi đá lạnh")
	_assert_true(node.warning_modal.visible == true, "Doctor: Hiện cảnh báo cấm chườm đá lạnh")
	node.warning_modal.visible = false

	# Step 2: Correct - Warm Towel
	node._on_use_warm_towel()
	_assert_true(node.current_step == node.Step.CHOOSE_MEDICINE, "Doctor: Dùng khăn ấm thành công, chuyển sang chọn thuốc")

	# Step 3: Trap - Antibiotic & Overdose
	node._on_choose_antibiotic_trap()
	_assert_true(node.warning_modal.visible == true, "Doctor: Cảnh báo bẫy lạm dụng kháng sinh cho sốt virus")
	node.warning_modal.visible = false

	node._on_choose_overdose_trap()
	_assert_true(node.warning_modal.visible == true, "Doctor: Cảnh báo bẫy quá liều Paracetamol 1000mg hại gan")
	node.warning_modal.visible = false

	# Step 3: Correct - Paracetamol 500mg
	node._on_choose_para500()
	_assert_true(node.current_step == node.Step.HYDRATE_ORESOL, "Doctor: Uống đúng liều 500mg, chuyển sang bù Oresol")

	# Step 4: Correct - Oresol 200ml
	node._on_hydrate_oresol_correct()
	_assert_true(node.current_step == node.Step.CURED, "Doctor: Mèo con hồi phục hoàn toàn 37.0°C")
	_assert_true(node.victory_modal.visible == true, "Doctor: Hiện modal phong tặng Bác Sĩ Mèo Xuất Sắc")

	node.queue_free()
	await get_tree().process_frame

func _test_budget_jars_game_standalone() -> void:
	print("\n>>> PHẦN 5: KIỂM THỬ STANDALONE BUDGET JARS GAME (budget_jars_game.tscn)")
	var scene = load("res://scenes/minigames/budget_jars_game.tscn")
	_assert_true(scene != null, "Nạp resource budget_jars_game.tscn thành công")

	var node = scene.instantiate()
	add_child(node)
	_assert_true(node != null, "Instantiate budget_jars_game thành công")
	await get_tree().process_frame

	# Check 3 Jars
	_assert_true(node.jar_essential == 1000000, "Jars: Hũ Thiết Yếu ban đầu có đúng 1.000.000đ (50%)")
	_assert_true(node.jar_growth == 600000, "Jars: Hũ Phát Triển ban đầu có đúng 600.000đ (30%)")
	_assert_true(node.jar_emergency == 400000, "Jars: Hũ Khẩn Cấp ban đầu có đúng 400.000đ (20%)")
	_assert_true(node.jar_essential + node.jar_growth + node.jar_emergency == 2000000, "Jars: Tổng ngân sách chuẩn xác 2.000.000đ")

	# Check UI Elements (Sliders & LineEdits)
	_assert_true(node.find_child("BtnBack", true, false) != null, "Jars: Có nút BtnBack")
	_assert_true(node.slider_essential != null, "Jars: Có HSlider cho Hũ Thiết Yếu")
	_assert_true(node.edit_essential != null, "Jars: Có LineEdit nhập số cho Hũ Thiết Yếu")
	_assert_true(node.slider_growth != null, "Jars: Có HSlider cho Hũ Phát Triển")
	_assert_true(node.edit_growth != null, "Jars: Có LineEdit nhập số cho Hũ Phát Triển")
	_assert_true(node.slider_emergency != null, "Jars: Có HSlider cho Hũ Khẩn Cấp")
	_assert_true(node.edit_emergency != null, "Jars: Có LineEdit nhập số cho Hũ Khẩn Cấp")

	# Test Slider Adjustment
	node._on_slider_value_changed("essential", 1200000)
	_assert_true(node.jar_essential == 1200000, "Jars: Kéo Slider -> Hũ thiết yếu cập nhật lên 1.200.000đ")
	_assert_true(node.edit_essential.text == "1200000", "Jars: Kéo Slider -> LineEdit tự động cập nhật text 1200000")

	# Test Text Input Adjustment
	node._on_input_text_changed("growth", "500000")
	_assert_true(node.jar_growth == 500000, "Jars: Nhập số LineEdit -> Hũ phát triển cập nhật 500.000đ")
	_assert_true(node.slider_growth.value == 500000, "Jars: Nhập số LineEdit -> Slider tự động nhảy đến mốc 500.000đ")

	# Test Quick 50-30-20
	node._on_quick_503020_pressed()
	_assert_true(node.jar_essential == 1000000 and node.jar_growth == 600000 and node.jar_emergency == 400000, "Jars: Nút tỷ lệ vàng 50-30-20 khôi phục chính xác")

	_assert_true(node.event_card != null, "Jars: Có thẻ sự kiện mô phỏng 30 ngày")
	_assert_true(node.life_events.size() == 5, "Jars: Đầy đủ 5 tình huống thực tế sinh viên")

	# Simulate Event 1: Market food (essential)
	var ev0 = node.life_events[0]
	node._on_choice_selected(ev0.choices[0], ev0)
	_assert_true(node.jar_essential == 750000, "Jars: Chi 250k tiền ăn -> Hũ thiết yếu còn 750.000đ")

	# Simulate Event 2: Trap loan BNPL (rejecting trap)
	var ev2 = node.life_events[2]
	node._on_choice_selected(ev2.choices[0], ev2)
	_assert_true(node.result_modal.visible == true, "Jars: Từ chối bẫy nợ thành công, hiện phản hồi thông thái")

	node.queue_free()
	await get_tree().process_frame
