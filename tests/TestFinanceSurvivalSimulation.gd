extends Node

# TestFinanceSurvivalSimulation.gd - Bộ kiểm thử tự động Trụ Cột 3: Tài Chính & Chống Lừa Đảo
# Kiểm tra chi tiết 3 Cấp độ: Siêu thị thông thái (Đơn giá 100g) -> Dòng tiền 30 ngày (Ngăn đợi 24h) -> Rà soát bẫy lừa đảo số

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
	print("   KIỂM THỬ TRỤ CỘT 3: TÀI CHÍNH & LỪA ĐẢO SỐ (FINANCE) ")
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
	var finance_scene = load("res://scenes/minigames/FinanceSurvivalSimulation.tscn")
	_assert_test(finance_scene != null, "Load FinanceSurvivalSimulation.tscn thành công")
	
	var sim = finance_scene.instantiate()
	add_child(sim)
	_assert_test(sim != null, "Khởi tạo FinanceSurvivalSimulation node thành công")
	
	# ---------------------------------------------------------
	# [TEST CẤP ĐỘ 1: SIÊU THỊ THÔNG THÁI & SOI ĐƠN GIÁ 100G]
	# ---------------------------------------------------------
	print("\n--- [LEVEL 1] Siêu Thị Thông Thái & Đơn Giá 100g ---")
	sim.load_level(1)
	_assert_test(sim.current_level == 1, "Level 1 khởi tạo chính xác")
	_assert_test(sim.current_budget == 200000, "Ngân sách ban đầu là 200.000đ")
	
	# Lật mặt sau xem chi tiết gạo nhỏ vs gạo lớn
	sim._on_flip_product("rice_small")
	_assert_test(sim.inspected_items.has("rice_small"), "Lật thẻ xem gạo nhỏ 300g")
	sim._on_flip_product("rice_big")
	_assert_test(sim.inspected_items.has("rice_big"), "Lật thẻ xem gạo lớn 500g")
	
	# Bẫy 1: Thử mua trứng giảm giá hết hạn
	sim._on_toggle_cart_item("eggs_spoiled")
	_assert_test(sim.cart_items.has("eggs_spoiled"), "Bỏ trứng giảm giá vào giỏ")
	sim._on_checkout_pressed()
	_assert_test(sim.safe_failure_count == 1, "Thanh toán trứng hết hạn kích hoạt Safe Failure")
	_assert_test(sim.cat_speech_lbl.text.contains("ngộ độc"), "Mochi cảnh báo nguy cơ ngộ độc thực phẩm")
	
	# Bỏ trứng hết hạn ra, thêm túi gạo nhỏ
	sim._on_toggle_cart_item("eggs_spoiled") # Gỡ bỏ
	sim._on_toggle_cart_item("rice_small")
	sim._on_checkout_pressed()
	_assert_test(sim.safe_failure_count == 2, "Thanh toán túi gạo nhỏ kích hoạt Safe Failure bẫy bao bì")
	_assert_test(sim.cat_speech_lbl.text.contains("BẪY BAO BÌ NHỎ"), "Mochi giải thích đơn giá 15k/100g đắt hơn 10k/100g")
	
	# Chọn đúng giỏ hàng chuẩn: rice_big + eggs_fresh + pate_mochi
	sim._on_toggle_cart_item("rice_small") # Gỡ bỏ
	sim._on_toggle_cart_item("rice_big")   # 50.000đ
	sim._on_toggle_cart_item("eggs_fresh") # 30.000đ
	sim._on_toggle_cart_item("pate_mochi") # 35.000đ
	_assert_test(sim.cart_items.size() == 3, "Giỏ hàng có đủ 3 món chất lượng")
	_assert_test(sim.current_budget == 85000, "Ngân sách còn lại 85.000đ chuẩn xác (200k - 115k)")
	
	sim._on_checkout_pressed()
	_assert_test(sim.is_basket_checked_out == true, "Thanh toán giỏ hàng thông thái thành công")
	_assert_test(sim.completed_levels.has(1), "Hoàn thành Level 1 Siêu Thị")
	
	# ---------------------------------------------------------
	# [TEST CẤP ĐỘ 2: DÒNG TIỀN 30 NGÀY & NGĂN ĐỢI 24 GIỜ]
	# ---------------------------------------------------------
	print("\n--- [LEVEL 2] Dòng Tiền 30 Ngày & Ngăn Đợi 24 Giờ ---")
	sim.load_level(2)
	_assert_test(sim.current_level == 2, "Chuyển sang Level 2 Dòng tiền thành công")
	_assert_test(sim.cash_balance == 6000000, "Số dư ban đầu 6.000.000đ")
	
	# Tiến ngày tới Ngày 5 (Trừ tiền nhà)
	for i in range(4): sim._on_next_day_pressed()
	_assert_test(sim.sim_day == 5, "Đã tiến tới Ngày 5")
	_assert_test(sim.cash_balance == 3500000, "Ngày 5 tự động trừ tiền trọ 2.500.000đ còn 3.500.000đ")
	
	# Tiến ngày tới Ngày 12 (Flash sale xuất hiện)
	for i in range(7): sim._on_next_day_pressed()
	_assert_test(sim.sim_day == 12, "Đã tiến tới Ngày 12")
	_assert_test(sim.flash_sale_panel.visible == true, "Cám dỗ Flash Sale xuất hiện")
	_assert_test(sim.btn_next_day.disabled == true, "Khóa nút chuyển ngày buộc người chơi ra quyết định")
	
	# Quyết định khôn ngoan: Kéo vào Ngăn Đợi 24 Giờ
	sim._on_put_in_cooling_box_pressed()
	_assert_test(sim.is_impulse_cooling == true, "Kích hoạt Ngăn Đợi 24 Giờ làm nguội cơn nghiện mua sắm")
	_assert_test(sim.flash_sale_panel.visible == false, "Tắt popup Flash sale")
	_assert_test(sim.cash_balance == 3500000, "Số dư không bị trừ tiền oan")
	
	# Tiến sang Ngày 13 (Hết 24h)
	sim._on_next_day_pressed()
	_assert_test(sim.sim_day == 13, "Tiến tới Ngày 13")
	_assert_test(sim.impulse_cooled_off == true, "Sau 24 giờ cơn thèm mua sắm hạ nhiệt thành công")
	
	# Tiến tới Ngày 15 (Điện nước) và Ngày 25 (Ăn uống) và Ngày 30 (Tổng kết)
	for i in range(17): sim._on_next_day_pressed()
	_assert_test(sim.sim_day == 30, "Hoàn tất chu kỳ 30 ngày")
	_assert_test(sim.cash_balance == 1500000, "Quỹ khẩn cấp còn nguyên 1.500.000đ")
	_assert_test(sim.cashflow_completed == true, "Hoàn thành Level 2 Phòng thủ chốt đơn")
	
	# ---------------------------------------------------------
	# [TEST CẤP ĐỘ 3: RÀ SOÁT LỪA ĐẢO SỐ & PHÁP Y TIN NHẮN]
	# ---------------------------------------------------------
	print("\n--- [LEVEL 3] Rà Soát Lừa Đảo Số & Pháp Y Tin Nhắn ---")
	sim.load_level(3)
	_assert_test(sim.current_level == 3, "Chuyển sang Level 3 Lừa đảo số thành công")
	_assert_test(sim.blocked_scams.size() == 0, "Ban đầu chưa chặn tin nhắn nào")
	
	# 1. Soi tin nhắn Ngân hàng giả mạo
	sim._on_select_scam("bank_phishing")
	_assert_test(sim.selected_scam_id == "bank_phishing", "Chọn tin nhắn giả mạo Vietcombank")
	_assert_test(sim.scam_flag_lbl.text.contains(".cc"), "Phát hiện tên miền lạ .cc")
	sim._on_execute_scam_action()
	_assert_test(sim.blocked_scams.has("bank_phishing"), "Đã chặn & báo cáo tin nhắn ngân hàng giả mạo")
	
	# 2. Soi bẫy Việc nhẹ lương cao nạp cọc
	sim._on_select_scam("job_deposit_trap")
	_assert_test(sim.scam_flag_lbl.text.contains("nạp cọc"), "Phát hiện bẫy nạp cọc việc nhẹ lương cao")
	_assert_test(sim.scam_law_lbl.text.contains("Điều 290"), "Dẫn chứng Điều 290 Bộ luật Hình sự")
	sim._on_execute_scam_action()
	_assert_test(sim.blocked_scams.has("job_deposit_trap"), "Đã từ chối & chặn bẫy cọc online")
	
	# 3. Soi bẫy giả danh Công an đe dọa
	sim._on_select_scam("police_impersonation")
	_assert_test(sim.scam_flag_lbl.text.contains("chuyển tiền"), "Bóc trần công an không làm việc hay bắt chuyển tiền qua điện thoại")
	sim._on_execute_scam_action()
	_assert_test(sim.blocked_scams.has("police_impersonation"), "Đã báo cáo tổng đài 113")
	_assert_test(sim.completed_levels.has(3), "Hoàn thành Level 3 Lừa đảo số")
	
	# ---------------------------------------------------------
	# [TEST TỔNG THỂ: VICTORY MODAL & POLAROID CERTIFICATE]
	# ---------------------------------------------------------
	print("\n--- [VICTORY] Modal & Chứng Nhận Polaroid Chủ Nhân Tài Chính ---")
	_assert_test(sim.victory_modal.visible == true, "Victory modal hiển thị sau khi hoàn tất 3 cấp độ")
	_assert_test(sim.polaroid_cert_panel != null, "Chứng nhận Chủ Nhân Tài Chính & An Toàn Số đã được tạo")
	
	# Test phát signal claim reward
	var steps_received: Array = []
	sim.minigame_completed.connect(func(steps):
		steps_received.append_array(steps)
	)
	sim._on_claim_reward_pressed()
	_assert_test(steps_received.size() == 4, "Phát signal minigame_completed kèm đủ 4 bước mô phỏng")
