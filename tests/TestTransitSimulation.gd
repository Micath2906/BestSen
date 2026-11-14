extends Node

# TestTransitSimulation.gd - Bộ kiểm thử tự động toàn diện Trụ Cột 1: Giả lập Giao Thông Đô Thị
# Kiểm tra chi tiết 3 Cấp độ: Bus & NFC -> Metro Balo & Quán tính -> Chẩn đoán xe máy đêm mưa

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
	print("   KIỂM THỬ TRỤ CỘT 1: GIẢ LẬP GIAO THÔNG (TRANSIT SIM)  ")
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
	var transit_scene = load("res://scenes/minigames/TransitSimulation.tscn")
	_assert_test(transit_scene != null, "Load TransitSimulation.tscn thành công")
	
	var sim = transit_scene.instantiate()
	add_child(sim)
	_assert_test(sim != null, "Khởi tạo TransitSimulation node thành công")
	
	# ---------------------------------------------------------
	# [TEST CẤP ĐỘ 1: BẮT ĐÚNG TUYẾN XE BUÝT & QUẸT THẺ NFC]
	# ---------------------------------------------------------
	print("\n--- [LEVEL 1] Bắt Đúng Tuyến & Quẹt Thẻ NFC ---")
	sim.load_level(1)
	_assert_test(sim.current_level == 1, "Level 1 khởi tạo chính xác")
	_assert_test(sim.TARGET_BUS_ROUTES.has(1) and sim.TARGET_BUS_ROUTES.has(53) and sim.TARGET_BUS_ROUTES.has(150), "Lộ trình mục tiêu có đủ 3 tuyến 01, 53, 150")
	
	# Test vẫy sai tuyến (Xe 8 đi Suối Tiên)
	sim.current_bus_route = 8
	sim.bus_position_x = 400.0 # Trong trigger zone
	sim._handle_bus_wave_success()
	_assert_test(sim.safe_failure_count == 1, "Vẫy sai tuyến kích hoạt Safe Failure không cho lên xe")
	_assert_test(sim.is_bus_stopped == false, "Xe sai tuyến không dừng lại")
	
	# Test vẫy đúng tuyến (Xe 53 đi Bến Thành)
	sim.current_bus_route = 53
	sim.bus_position_x = 400.0
	sim._handle_bus_wave_success()
	_assert_test(sim.is_bus_stopped == true, "Vẫy đúng xe 53 khiến xe dừng lại tấp lề")
	_assert_test(sim.bus_nfc_panel.visible == true, "Bảng đầu đọc thẻ NFC mở ra")
	
	# Test nhấc thẻ NFC quá sớm (<0.55s)
	sim.is_nfc_card_held = true
	sim.nfc_dwell_time = 0.3
	sim._on_nfc_card_up()
	_assert_test(sim.nfc_success == false, "Nhấc thẻ ở 0.3s không được quẹt thành công")
	_assert_test(sim.cat_speech_lbl.text.contains("0.6 giây"), "Mochi nhắc nhở giữ thẻ đủ 0.6s")
	
	# Test chạm giữ đủ 0.6s
	sim.is_nfc_card_held = true
	sim.nfc_dwell_time = 0.65
	sim._handle_nfc_success()
	_assert_test(sim.nfc_success == true, "Quẹt thẻ NFC đủ 0.6s thành công")
	_assert_test(sim.completed_levels.has(1), "Hoàn thành Level 1 Bus & NFC")
	
	# ---------------------------------------------------------
	# [TEST CẤP ĐỘ 2: METRO GIỜ CAO ĐIỂM & THĂNG BẰNG QUÁN TÍNH]
	# ---------------------------------------------------------
	print("\n--- [LEVEL 2] Metro Văn Hóa Balo & Thăng Bằng Quán Tính ---")
	sim.load_level(2)
	_assert_test(sim.current_level == 2, "Chuyển sang Level 2 Metro thành công")
	_assert_test(sim.is_backpack_in_front == false, "Ban đầu ba lô đeo sau lưng (dễ va chạm)")
	
	# Test toggle đeo balo trước ngực
	sim._on_toggle_backpack_pressed()
	_assert_test(sim.is_backpack_in_front == true, "Bấm toggle chuyển sang đeo balo trước ngực an toàn")
	_assert_test(sim.backpack_btn.text.contains("48px"), "Balo trước ngực thu gọn diện tích còn 48px")
	
	# Test giữ thăng bằng quán tính qua 3 khúc cua
	sim.balance_slider_value = 50.0 # Vùng an toàn
	sim._process_level2_metro(2.1) # Giữ đủ 2 giây
	_assert_test(sim.turns_cleared == 1, "Vượt qua khúc cua số 1")
	
	sim._process_level2_metro(2.1) # Cua số 2
	sim._process_level2_metro(2.1) # Cua số 3
	_assert_test(sim.turns_cleared >= 3, "Đã vượt qua đủ 3 khúc cua quán tính")
	_assert_test(sim.completed_levels.has(2), "Hoàn thành Level 2 Metro Văn Minh")
	
	# ---------------------------------------------------------
	# [TEST CẤP ĐỘ 3: CHẨN ĐOÁN XE MÁY ĐÊM MƯA & NÉ BẪY CHẶT CHÉM]
	# ---------------------------------------------------------
	print("\n--- [LEVEL 3] Chẩn Đoán Xe Máy Đêm Mưa & Né Bẫy Chặt Chém ---")
	sim.load_level(3)
	_assert_test(sim.current_level == 3, "Chuyển sang Level 3 Xe Máy thành công")
	
	# Test bấm thử đề máy & còi
	sim._on_test_starter_pressed()
	_assert_test(sim.is_headlight_checked and sim.is_horn_checked, "Đèn pha và còi xe kiểm tra hoạt động tốt")
	
	# Test soi ống pô
	sim._on_inspect_exhaust_pressed()
	_assert_test(sim.is_exhaust_inspected, "Soi phát hiện ống pô ngập nước")
	
	# Test kiểm tra lốp
	sim._on_inspect_tire_pressed()
	_assert_test(sim.is_tire_inspected, "Kiểm tra phát hiện lốp bị đinh xẹp")
	
	sim._process_level3_diagnostic(0.1)
	_assert_test(sim.diagnostic_finished == true, "Hoàn tất chẩn đoán đủ 3 vị trí trên xe")
	
	# Test bấm chấp nhận thay IC 800k (Bẫy lừa đảo)
	var old_fails = sim.safe_failure_count
	sim._on_agree_scam_pressed()
	_assert_test(sim.safe_failure_count == old_fails + 1, "Đồng ý thay IC kích hoạt Safe Failure cảnh báo mất tiền oan")
	_assert_test(sim.negotiation_resolved == false, "Chưa cho qua bài khi chọn bẫy lừa")
	
	# Test từ chối thay IC (Chọn phương án đúng)
	sim._on_refuse_scam_pressed()
	_assert_test(sim.negotiation_resolved == true, "Đấu lý từ chối thay IC thành công")
	_assert_test(sim.completed_levels.has(3), "Hoàn thành Level 3 Cứu Hộ Đêm Mưa")
	
	# Test Victory Modal & Polaroid Pass
	_assert_test(sim.victory_modal.visible == true, "VictoryModal mở ra khi hoàn thành")
	_assert_test(sim.polaroid_ticket_panel != null, "Tạo Thẻ Thông Hành Polaroid cá nhân hóa thành công")
	
	# Test claim reward signal
	var completed_signal = [false]
	var steps_received = []
	sim.minigame_completed.connect(func(steps):
		completed_signal[0] = true
		steps_received.append_array(steps)
	)
	sim._on_claim_reward_pressed()
	_assert_test(completed_signal[0] == true, "Phát tín hiệu minigame_completed thành công")
	_assert_test(steps_received.size() >= 4, "Trả về đủ 4 bước hành động giáo dục")
	
	sim.queue_free()
