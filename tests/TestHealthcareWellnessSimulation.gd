extends Node

# TestHealthcareWellnessSimulation.gd - Bộ kiểm thử tự động Trụ Cột 4: Y Tế, BHYT & Sức Khỏe
# Kiểm tra chi tiết 3 Cấp độ: Sơ cứu bỏng & Liều hạ sốt -> 5 Trạm BHYT & Né cò mồi -> Hơi thở 4-7-8 cùng Mochi

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
	print("   KIỂM THỬ TRỤ CỘT 4: Y TẾ, BHYT & SỨC KHỎE (HEALTHCARE) ")
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
	var health_scene = load("res://scenes/minigames/HealthcareWellnessSimulation.tscn")
	_assert_test(health_scene != null, "Load HealthcareWellnessSimulation.tscn thành công")
	
	var sim = health_scene.instantiate()
	add_child(sim)
	_assert_test(sim != null, "Khởi tạo HealthcareWellnessSimulation node thành công")
	
	# ---------------------------------------------------------
	# [TEST CẤP ĐỘ 1: SƠ CỨU BỎNG NƯỚC SÔI & CHIA LIỀU HẠ SỐT]
	# ---------------------------------------------------------
	print("\n--- [LEVEL 1] Sơ Cứu Bỏng & Liều Hạ Sốt ---")
	sim.load_level(1)
	_assert_test(sim.current_level == 1, "Level 1 khởi tạo chính xác")
	_assert_test(sim.is_burn_cooled == false and sim.is_burn_bandaged == false, "Trạng thái ban đầu chưa sơ cứu")
	
	# Bẫy 1: Thử bôi kem đánh răng lên vết bỏng
	sim._on_bad_burn_treatment_pressed("kem đánh răng")
	_assert_test(sim.safe_failure_count == 1, "Bôi kem đánh răng kích hoạt Safe Failure")
	_assert_test(sim.cat_speech_lbl.text.contains("hoại tử"), "Mochi cảnh báo nguy cơ bí nhiệt và hoại tử sâu")
	
	# Xử trí đúng: Ngâm/xả dưới vòi nước mát
	sim._on_water_cool_pressed()
	_assert_test(sim.is_burn_cooled == true, "Đã hạ nhiệt bằng vòi nước mát 15-20p")
	_assert_test(sim.btn_sterile_gauze.disabled == false, "Mở khóa nút băng gạc vô trùng")
	
	# Băng gạc vô trùng
	sim._on_sterile_gauze_pressed()
	_assert_test(sim.is_burn_bandaged == true, "Đã băng gạc vô trùng nhẹ nhàng không vỡ bọng nước")
	
	# Tính liều hạ sốt Paracetamol cho người 50kg (10mg/kg = 500mg)
	sim._on_cut_paracetamol_pressed()
	_assert_test(sim.fever_dosage_cut == true, "Đã cắt đúng liều 1 viên 500mg")
	_assert_test(sim.btn_drink_warm_water.disabled == false, "Mở khóa nút uống nước ấm")
	
	# Uống cùng nước ấm
	sim._on_drink_warm_water_pressed()
	_assert_test(sim.fever_water_taken == true, "Đã uống đủ nước ấm bù dịch")
	_assert_test(sim.completed_levels.has(1), "Hoàn thành Level 1 Sơ cứu & Liều thuốc")
	
	# ---------------------------------------------------------
	# [TEST CẤP ĐỘ 2: HÀNH TRÌNH 5 TRẠM BHYT & NÉ CÒ MỒI]
	# ---------------------------------------------------------
	print("\n--- [LEVEL 2] 5 Trạm BHYT & Né Cò Mồi ---")
	sim.load_level(2)
	_assert_test(sim.current_level == 2, "Chuyển sang Level 2 BHYT thành công")
	_assert_test(sim.current_station == 1, "Bắt đầu tại Trạm 1: Kiosk tự động")
	
	# Trạm 1: Kiosk lấy số
	sim._on_station_action_pressed()
	_assert_test(sim.current_station == 2, "Tiến sang Trạm 2: Tiếp nhận hồ sơ BHYT")
	_assert_test(sim.btn_reject_tout.visible == true, "Cò mồi 300k xuất hiện tại cổng tiếp nhận")
	
	# Cố đi tiếp khi chưa xử lý cò mồi
	sim._on_station_action_pressed()
	_assert_test(sim.current_station == 2, "Chưa xử lý cò mồi thì không cho qua trạm")
	
	# Kiên quyết từ chối cò mồi
	sim._on_reject_tout_pressed()
	_assert_test(sim.tout_rejected == true, "Đã từ chối cò mồi và báo bảo vệ an ninh")
	
	# Tiếp tục xuất trình BHYT + CCCD
	sim._on_station_action_pressed()
	_assert_test(sim.current_station == 3, "Tiến sang Trạm 3: Bác sĩ chẩn đoán")
	
	# Trạm 3: Khám bệnh
	sim._on_station_action_pressed()
	_assert_test(sim.current_station == 4, "Tiến sang Trạm 4: Quầy thanh toán viện phí đồng chi trả")
	
	# Trạm 4: Thanh toán viện phí
	sim._on_station_action_pressed()
	_assert_test(sim.current_station == 5, "Tiến sang Trạm 5: Quầy dược BHYT")
	
	# Trạm 5: Nhận thuốc BHYT
	sim._on_station_action_pressed()
	_assert_test(sim.completed_levels.has(2), "Hoàn thành toàn bộ 5 Trạm quy trình BHYT")
	
	# ---------------------------------------------------------
	# [TEST CẤP ĐỘ 3: NHỊP SINH HỌC & HƠI THỞ 4-7-8 CÙNG MOCHI]
	# ---------------------------------------------------------
	print("\n--- [LEVEL 3] Nhịp Sinh Học & Hơi Thở 4-7-8 Cùng Mochi ---")
	sim.load_level(3)
	_assert_test(sim.current_level == 3, "Chuyển sang Level 3 Nhịp sinh học thành công")
	_assert_test(sim.stress_stat == 85, "Mức độ căng thẳng ban đầu báo động: 85/100")
	_assert_test(sim.btn_sleep_now.disabled == true, "Đang căng thẳng thì chưa thể ngủ sâu giấc")
	
	# Kích hoạt bài tập thở 4-7-8
	sim._on_start_breathing_pressed()
	_assert_test(sim.breathing_phase == "INHALE_4", "Giai đoạn 1: Hít vào bằng mũi 4 giây")
	
	# Giả lập hoàn tất chu kỳ thở
	sim._finish_breathing_cycle()
	_assert_test(sim.stress_stat == 25, "Hơi thở 4-7-8 kích hoạt thần kinh phó giao cảm hạ stress xuống 25")
	_assert_test(sim.focus_stat == 80, "Độ tập trung tinh thần tăng lên 80")
	_assert_test(sim.btn_sleep_now.disabled == false, "Đã mở khóa nút đi ngủ phục hồi não bộ")
	
	# Tắt đèn đi ngủ
	sim._on_sleep_now_pressed()
	_assert_test(sim.completed_levels.has(3), "Hoàn thành Level 3 Thân tâm tự lập")
	
	# ---------------------------------------------------------
	# [TEST TỔNG THỂ: VICTORY MODAL & POLAROID CERTIFICATE]
	# ---------------------------------------------------------
	print("\n--- [VICTORY] Modal & Chứng Nhận Polaroid Bậc Thầy Sức Khỏe ---")
	_assert_test(sim.victory_modal.visible == true, "Victory modal hiển thị sau khi hoàn tất 3 cấp độ")
	_assert_test(sim.polaroid_cert_panel != null, "Chứng nhận Bậc Thầy Sức Khỏe đã được tạo")
	
	# Test phát signal claim reward
	var steps_received: Array = []
	sim.minigame_completed.connect(func(steps):
		steps_received.append_array(steps)
	)
	sim._on_claim_reward_pressed()
	_assert_test(steps_received.size() == 4, "Phát signal minigame_completed kèm đủ 4 bước mô phỏng")
