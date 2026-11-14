extends Node

# TestHousingLegalSimulation.gd - Bộ kiểm thử tự động Trụ Cột 2: Thuê Trọ & Pháp Lý Đời Sống
# Kiểm tra chi tiết 3 Cấp độ: Khảo sát lỗi phòng 2.5D -> Papers Please Hợp đồng -> Phụ tải CB & Kiểm toán điện

var pass_count: int = 0
var fail_count: int = 0

func _assert_test(cond: bool, test_name: String) -> void:
	if cond:
		pass_count += 1
		print("  [PASS %02d] %s" % [pass_count, test_name])
	else:
		fail_count += 1
		printerr("  [FAIL %02d] %s" % [fail_count, test_name])

func _ready() -> void:
	print("\n========================================================")
	print("   KIỂM THỬ TRỤ CỘT 2: THUÊ TRỌ & PHÁP LÝ (HOUSING SIM)  ")
	print("========================================================\n")
	
	_run_all_tests()
	
	print("\n========================================================")
	print("KẾT QUẢ KIỂM THỬ: %d PASS, %d FAIL" % [pass_count, fail_count])
	print("========================================================\n")
	
	if fail_count == 0:
		get_tree().quit(0)
	else:
		get_tree().quit(1)

func _run_all_tests() -> void:
	var housing_scene = load("res://scenes/minigames/HousingLegalSimulation.tscn")
	_assert_test(housing_scene != null, "Load HousingLegalSimulation.tscn thành công")
	
	var sim = housing_scene.instantiate()
	add_child(sim)
	_assert_test(sim != null, "Khởi tạo HousingLegalSimulation node thành công")
	
	# ---------------------------------------------------------
	# [TEST CẤP ĐỘ 1: THÁM TỬ XEM TRỌ & 4 LỖI HẠ TẦNG]
	# ---------------------------------------------------------
	print("\n--- [LEVEL 1] Thám Tử Xem Trọ & 4 Lỗi Hạ Tầng ---")
	sim.load_level(1)
	_assert_test(sim.current_level == 1, "Level 1 khởi tạo chính xác")
	_assert_test(sim.defect_water_found == false and sim.defect_meter_found == false, "Trạng thái ban đầu chưa tìm thấy lỗi")
	
	# 1. Soi vòi nước
	sim._on_water_tap_pressed()
	_assert_test(sim.defect_water_found == true, "Phát hiện lỗi vòi nước chảy yếu")
	_assert_test(sim.cat_speech_lbl.text.contains("nhỏ giọt"), "Mochi phản hồi cảnh báo mất nước giờ cao điểm")
	
	# 2. Soi trần nhà
	sim._on_ceiling_pressed()
	_assert_test(sim.defect_ceiling_found == true, "Phát hiện lỗi trần nhà loang ố dột mưa")
	
	# 3. Lay chốt cửa
	sim._on_door_lock_pressed()
	_assert_test(sim.defect_door_found == true, "Phát hiện lỗi chốt cửa lỏng lẻo rỉ sét")
	
	# 4. Tắt điện soi công tơ quay trộm
	sim._on_switch_meter_pressed()
	_assert_test(sim.defect_meter_found == true and sim.all_switches_turned_off == true, "Bắt được lỗi công tơ vẫn quay khi tắt sạch điện")
	_assert_test(sim.completed_levels.has(1), "Hoàn thành Level 1 Thám tử xem trọ")
	
	# ---------------------------------------------------------
	# [TEST CẤP ĐỘ 2: ĐỐI CHIẾU HỢP ĐỒNG & ĐÓNG DẤU SÁP VÀNG]
	# ---------------------------------------------------------
	print("\n--- [LEVEL 2] Soi Hợp Đồng Papers Please & Đóng Dấu Sáp ---")
	sim.load_level(2)
	_assert_test(sim.current_level == 2, "Chuyển sang Level 2 Hợp đồng thành công")
	_assert_test(sim.btn_seal.disabled == true, "Ban đầu con dấu sáp vàng bị khóa")
	
	# Bóc lỗi điều khoản 1 (Cọc)
	sim._on_correct_flag_pressed(1)
	_assert_test(sim.red_flags_corrected.has(1), "Bóc lỗi điều khoản cọc vô lý theo Điều 328 BLDS")
	_assert_test(sim.btn_seal.disabled == true, "Chưa đủ 3 lỗi, dấu sáp vẫn khóa")
	
	# Bóc lỗi điều khoản 2 (Điện)
	sim._on_correct_flag_pressed(2)
	_assert_test(sim.red_flags_corrected.has(2), "Bóc lỗi mập mờ giá điện nội bộ")
	
	# Bóc lỗi điều khoản 3 (Tạm trú)
	sim._on_correct_flag_pressed(3)
	_assert_test(sim.red_flags_corrected.has(3), "Bóc lỗi trốn đăng ký tạm trú theo Luật Cư trú")
	_assert_test(sim.btn_seal.disabled == false, "Đã sửa đủ 3 lỗi, mở khóa con dấu sáp vàng")
	
	# Đóng dấu sáp vàng
	sim._on_wax_seal_pressed()
	_assert_test(sim.contract_sealed == true, "Đóng dấu sáp xác nhận hợp đồng thành công")
	_assert_test(sim.completed_levels.has(2), "Hoàn thành Level 2 Hợp đồng thuê nhà")
	
	# ---------------------------------------------------------
	# [TEST CẤP ĐỘ 3: QUẢN TRỊ PHỤ TẢI CB & KIỂM TOÁN HÓA ĐƠN]
	# ---------------------------------------------------------
	print("\n--- [LEVEL 3] Phụ Tải Cầu Dao (CB) & Kiểm Toán Hóa Đơn ---")
	sim.load_level(3)
	_assert_test(sim.current_level == 3, "Chuyển sang Level 3 Quản trị phụ tải & Hóa đơn")
	_assert_test(sim._calculate_current_power() == 80, "Phụ tải cơ bản ban đầu 80W (Đèn + Quạt)")
	
	# Bật Bếp từ 2000W -> 2080W
	sim._on_toggle_cooker()
	_assert_test(sim.is_cooker_on == true, "Bếp từ 2000W đã bật")
	_assert_test(sim._calculate_current_power() == 2080, "Công suất 2080W <= 3000W (An toàn)")
	_assert_test(sim.is_cb_tripped == false, "Cầu dao chưa nhảy")
	
	# Bật Ấm siêu tốc 1500W -> 3580W -> QUÁ TẢI SẬP CB
	sim._on_toggle_kettle()
	_assert_test(sim.is_kettle_on == true, "Ấm siêu tốc 1500W đã bật")
	_assert_test(sim.is_cb_tripped == true, "Quá tải 3580W > 3000W làm cầu dao (CB) nhảy lập tức")
	_assert_test(sim.btn_cb_reset.disabled == false, "Nút gạt lại CB được kích hoạt")
	
	# Cố gạt lại CB khi phụ tải vẫn đang quá tải
	sim._on_cb_reset_pressed()
	_assert_test(sim.is_cb_tripped == true, "Chưa tắt thiết bị mà gạt CB sẽ bị nảy lại ngay")
	_assert_test(sim.cat_speech_lbl.text.contains("nảy lại ngay"), "Mochi hướng dẫn tắt bớt thiết bị")
	
	# Tắt ấm siêu tốc rồi gạt lại CB
	sim.is_kettle_on = false
	sim._on_cb_reset_pressed()
	_assert_test(sim.is_cb_tripped == false, "Tắt ấm điện đưa công suất về 2080W giúp đóng CB thành công")
	
	# Test trả hóa đơn bị khống (Safe Failure)
	sim._on_bill_pay_scam()
	_assert_test(sim.safe_failure_count == 1, "Bấm trả hóa đơn khống kích hoạt Safe Failure")
	_assert_test(sim.cat_speech_lbl.text.contains("175.000đ"), "Mochi giải thích bị mất tiền oan")
	
	# Test kiểm toán hóa đơn chuẩn xác (70 kWh x 3500 = 245.000đ)
	sim._on_bill_audit_correct()
	_assert_test(sim.bill_audited_correctly == true, "Kiểm toán đối chiếu công tơ chuẩn xác 245k thành công")
	_assert_test(sim.completed_levels.has(3), "Hoàn thành Level 3 Quản trị phòng trọ")
	
	# ---------------------------------------------------------
	# [TEST TỔNG THỂ: VICTORY MODAL & POLAROID CERTIFICATE]
	# ---------------------------------------------------------
	print("\n--- [VICTORY] Modal & Chứng Nhận Polaroid Thám Tử Phòng Trọ ---")
	_assert_test(sim.victory_modal.visible == true, "Victory modal hiển thị sau khi hoàn thành 3 level")
	_assert_test(sim.polaroid_cert_panel != null, "Tấm thẻ Chứng nhận Thám Tử Phòng Trọ đã được tạo")
	
	# Test phát signal claim reward
	var steps_received: Array = []
	sim.minigame_completed.connect(func(steps):
		steps_received.append_array(steps)
	)
	sim._on_claim_reward_pressed()
	_assert_test(steps_received.size() == 4, "Phát signal minigame_completed kèm đủ 4 bước mô phỏng")
