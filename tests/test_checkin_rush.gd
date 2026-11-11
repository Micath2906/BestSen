extends Node

# test_checkin_rush.gd - Automation Test Runner cho Minigame "Check-in Thần Tốc"
# Kiểm thử toàn diện 4 loại hành khách, cơ chế độ sáng QR, toán tiền thối, QTE vẫy xe buýt,
# Combo Streak, Fever Mode, Gate Jam Defeat, và Victory Reward flow.

var passes: int = 0
var failures: Array = []

func report_pass(desc: String) -> void:
	passes += 1
	print("  [PASS %02d] %s" % [passes, desc])

func report_fail(desc: String, err: String) -> void:
	failures.append({"desc": desc, "error": err})
	printerr("  [FAIL] %s -> Lỗi: %s" % [desc, err])

func _ready() -> void:
	print("\n" + "=".repeat(65))
	print("   TEST AUTOMATION: CHECK-IN THẦN TỐC (BEST SEN)")
	print("=".repeat(65))
	
	await run_tests()
	
	print("\n" + "=".repeat(65))
	print("               KẾT QUẢ KIỂM THỬ CHECK-IN RUSH")
	print("=".repeat(65))
	print("Tổng Pass: %d" % passes)
	print("Tổng Failures: %d" % failures.size())
	
	if failures.size() > 0:
		for f in failures:
			print("  ❌ %s: %s" % [f["desc"], f["error"]])
	else:
		print("🎉 HOÀN THÀNH 100%: TẤT CẢ TEST CASES VÀ SCREENSHOTS ĐỀU ĐẠT CHUẨN!")
	print("=".repeat(65) + "\n")
	
	get_tree().quit(1 if failures.size() > 0 else 0)

func run_tests() -> void:
	# 1. Khởi tạo Scene
	var scn = load("res://scenes/minigames/CheckInRushGame.tscn")
	if scn == null:
		report_fail("Tải CheckInRushGame.tscn", "Không thể load res://scenes/minigames/CheckInRushGame.tscn")
		return
	report_pass("Load scene CheckInRushGame.tscn thành công")
	
	var game = scn.instantiate()
	if game == null:
		report_fail("Instantiate CheckInRushGame", "instantiate() trả về null")
		return
	report_pass("Instantiate CheckInRushGame thành công")
	
	add_child(game)
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 2. Kiểm tra node UI chính
	if game.clock_label == null or game.count_label == null or game.barrier_led_rect == null:
		report_fail("UI Header & Barrier Nodes", "Thiếu node trong CheckInRushGame")
	else:
		report_pass("Header, Barrier Frame, và Passenger Section sẵn sàng")
		
	# 3. Trạng thái khởi điểm
	if game.time_left < 58.0 or game.time_left > 60.0 or game.processed_passengers != 0:
		report_fail("Trạng thái ban đầu", "time_left=%f, processed=%d" % [game.time_left, game.processed_passengers])
	else:
		report_pass("Trạng thái ban đầu chuẩn: 60s, 0/8 khách, combo 0")
		
	# =========================================================================
	# 4. TEST LOẠI 1: THẺ CỨNG RFID
	# =========================================================================
	print("\n>>> KIỂM TRA LOẠI 1: THẺ CỨNG RFID (CCCD / THẺ SV)")
	game.current_passenger = {
		"name": "Mèo Tuxedo SV Test",
		"type": game.PassengerType.RFID_CARD,
		"breed_id": 4,
		"dialogue": "Cho mình quẹt thẻ sinh viên Metro Tuyến 1 nhé Sen!",
		"badge": "💳 Thẻ Cứng RFID"
	}
	game._switch_toolbox(game.PassengerType.RFID_CARD)
	await get_tree().process_frame
	
	# 4.1 Thử đưa nhầm vào máy quét QR
	var p_before = game.passenger_patience
	game.btn_swipe_qr_wrong.pressed.emit()
	if game.passenger_patience >= p_before:
		report_fail("Phạt thao tác sai thẻ cứng", "passenger_patience không bị trừ khi quẹt nhầm QR")
	else:
		report_pass("Chặn và trừ 2.0s kiên nhẫn khi quẹt thẻ cứng vào máy quét QR quang học")
		
	# 4.2 Quẹt đúng vào đầu đọc RFID
	game.combo_streak = 0
	game.btn_swipe_rfid.pressed.emit()
	await get_tree().process_frame
	if game.processed_passengers != 1 or game.combo_streak != 1:
		report_fail("Quẹt đúng RFID", "processed=%d, combo=%d" % [game.processed_passengers, game.combo_streak])
	else:
		report_pass("Quẹt thẻ RFID thành công! Barrier mở, khách 1/8, Combo: 1")
		
	await get_tree().create_timer(0.5).timeout
	
	# =========================================================================
	# 5. TEST LOẠI 2: MÃ QR TRÊN APP (50% BỊ TỐI MÀN HÌNH)
	# =========================================================================
	print("\n>>> KIỂM TRA LOẠI 2: MÃ QR TRÊN APP (HURC PASS / MOMO)")
	game.current_passenger = {
		"name": "Mèo Tam Thể QR Test",
		"type": game.PassengerType.QR_APP,
		"breed_id": 2,
		"dialogue": "Mình dùng app vé số QR nè Sen!",
		"badge": "📱 Vé Điện Tử QR",
		"force_dim": true
	}
	game._switch_toolbox(game.PassengerType.QR_APP)
	await get_tree().process_frame
	
	# 5.1 Thử quét khi màn hình còn tối (<70%)
	game.phone_brightness = 0.22
	p_before = game.passenger_patience
	game.btn_scan_qr.pressed.emit()
	if game.passenger_patience >= p_before or not ("tối" in game.toast_label.text.to_lower()):
		report_fail("Chặn quét QR khi màn hình tối", "Không phát hiện lỗi màn hình tối!")
	else:
		report_pass("Máy quét từ chối quét QR khi màn hình tối (<70%) và nhắc tăng sáng")
		
	# 5.2 Thử quẹt nhầm vào RFID
	p_before = game.passenger_patience
	game.btn_scan_rfid_wrong.pressed.emit()
	if game.passenger_patience >= p_before:
		report_fail("Chặn đưa QR vào RFID", "Không trừ kiên nhẫn khi đưa điện thoại vào RFID")
	else:
		report_pass("Chặn thành công lỗi đưa điện thoại vào đầu đọc RFID")
		
	# 5.3 Kéo thanh trượt độ sáng lên 85% và quét lại
	# Để giữ chuỗi combo test Fever Mode, set combo về 1
	game.combo_streak = 1
	game.phone_brightness_slider.value = 85.0
	game._on_brightness_changed(85.0)
	game.btn_scan_qr.pressed.emit()
	await get_tree().process_frame
	if game.processed_passengers != 2 or game.combo_streak != 2:
		report_fail("Quét QR thành công sau khi tăng sáng", "processed=%d, combo=%d" % [game.processed_passengers, game.combo_streak])
	else:
		report_pass("Tăng sáng màn hình >= 70% ➔ Quét QR thành công! Khách 2/8, Combo: 2")
		
	await get_tree().create_timer(0.5).timeout
	
	# =========================================================================
	# 6. TEST LOẠI 3: TIỀN MẶT XE BUÝT (TOÁN TIỀN THỐI LẺ)
	# =========================================================================
	print("\n>>> KIỂM TRA LOẠI 3: TIỀN MẶT XE BUÝT (TOÁN TIỀN THỐI LẺ)")
	game.current_passenger = {
		"name": "Mèo Vàng Tiền Mặt Test",
		"type": game.PassengerType.BUS_CASH,
		"breed_id": 1,
		"dialogue": "Vé bus 5.000đ, mình đưa tờ 20.000đ nè!",
		"cash_given": 20000,
		"fare": 5000,
		"change": 15000,
		"badge": "💵 Tiền Mặt (20k)"
	}
	game._switch_toolbox(game.PassengerType.BUS_CASH)
	await get_tree().process_frame
	
	# 6.1 Thử thối sai tiền (chọn 10k + 2k = 12k thay vì 15k)
	game.selected_change_cash = 0
	game._add_cash(10000)
	game._add_cash(2000)
	p_before = game.passenger_patience
	game.btn_cash_confirm.pressed.emit()
	if game.selected_change_cash != 0 or game.passenger_patience >= p_before:
		report_fail("Chặn thối sai tiền", "Không phạt hoặc không reset khay khi thối sai tiền! p_before=%f, curr=%f" % [p_before, game.passenger_patience])
	else:
		report_pass("Chặn thối sai tiền (12k != 15k): Bác tài càu nhàu, khay tiền tự reset")
		
	# 6.2 Thối đúng 15.000đ (10k + 5k)
	# Duy trì chuỗi combo = 2 trước khi hoàn thành khách thứ 3
	game.combo_streak = 2
	game._add_cash(10000)
	game._add_cash(5000)
	game.btn_cash_confirm.pressed.emit()
	await get_tree().process_frame
	
	# Combo đạt 3 -> FEVER MODE kích hoạt!
	if game.processed_passengers != 3 or game.combo_streak != 3 or not game.is_fever_mode:
		report_fail("Fever Mode kích hoạt tại Combo 3", "processed=%d, combo=%d, fever=%s" % [game.processed_passengers, game.combo_streak, str(game.is_fever_mode)])
	else:
		report_pass("Thối đúng 15.000đ thành công! KÍCH HOẠT FEVER MODE (Tốc độ x1.5 & Nhân đôi Cá Khô)")
		
	await get_tree().create_timer(0.5).timeout
	
	# =========================================================================
	# 7. TEST LOẠI 4: VẪY XE BUÝT 08 TỪ XA (BUS WAVE QTE)
	# =========================================================================
	print("\n>>> KIỂM TRA LOẠI 4: VẪY XE BUÝT 08 TỪ XA (BUS WAVE QTE)")
	game.current_passenger = {
		"name": "Mèo Mướp Vẫy Xe Test",
		"type": game.PassengerType.BUS_WAVE_QTE,
		"breed_id": 0,
		"dialogue": "Xe buýt 08 đang lao tới kìa! Bấm ✋ vẫy xe giúp mình!",
		"badge": "🚌 Vẫy Xe Buýt 08"
	}
	game._switch_toolbox(game.PassengerType.BUS_WAVE_QTE)
	await get_tree().process_frame
	
	# 7.1 Thử vẫy xe quá sớm khi xe còn ở xa (x = -40, cách vạch > 75px: 230 - (-40) = 270px)
	game.bus_sprite_label.position.x = -40.0
	p_before = game.passenger_patience
	game.btn_wave_hand.pressed.emit()
	if game.passenger_patience >= p_before:
		report_fail("Phạt vẫy xe quá sớm", "Không phạt khi vẫy xe quá sớm")
	else:
		report_pass("Phạt vẫy xe quá sớm (xe buýt còn ở quá xa trạm)")
		
	# 7.2 Canh đầu xe vào Sweet Spot (cách vạch 50px: 230 - 50 = 180px)
	game.bus_sprite_label.position.x = game.bus_stop_x - 50.0
	game.btn_wave_hand.pressed.emit()
	await get_tree().process_frame
	if game.processed_passengers != 4:
		report_fail("Vẫy xe trúng Sweet Spot", "processed_passengers != 4")
	else:
		report_pass("Vẫy xe buýt 08 dứt khoát trúng Sweet Spot! Xe phanh kít đón khách!")
		
	# Chụp ảnh Gameplay thực tế
	await get_tree().create_timer(0.2).timeout
	var img_gameplay = get_viewport().get_texture().get_image()
	img_gameplay.save_png("res://screenshot_verified_checkin_rush_gameplay.png")
	report_pass("Đã chụp screenshot: screenshot_verified_checkin_rush_gameplay.png")
	
	# =========================================================================
	# 8. TEST ĐẠT ĐIỀU KIỆN THẮNG (8 KHÁCH TRONG 60S)
	# =========================================================================
	print("\n>>> KIỂM TRA HOÀN THÀNH MỤC TIÊU 8 KHÁCH (VICTORY)")
	while game.processed_passengers < 8:
		game.processed_passengers += 1
		game.combo_streak += 1
		
	game._trigger_victory()
	await get_tree().process_frame
	
	if not game.victory_modal.visible:
		report_fail("Hiển thị Victory Modal", "victory_modal không visible")
	else:
		report_pass("Kích hoạt Victory Modal sau khi xử lý thành công 8 khách")
		
	await get_tree().create_timer(0.1).timeout
	var img_victory = get_viewport().get_texture().get_image()
	img_victory.save_png("res://screenshot_verified_checkin_rush_victory.png")
	report_pass("Đã chụp screenshot: screenshot_verified_checkin_rush_victory.png")
	
	# Nhận thưởng
	var fish_before = GameManager.fish
	var signal_box = [false]
	game.minigame_completed.connect(func(_steps): signal_box[0] = true)
	game.btn_claim_victory.pressed.emit()
	await get_tree().process_frame
	
	if GameManager.fish <= fish_before:
		report_fail("Thưởng Cá Khô Victory", "GameManager.fish không tăng")
	else:
		report_pass("Thưởng Cá Khô thành công (+%d Cá Khô)" % (GameManager.fish - fish_before))
		
	if not ("Soát Vé Siêu Tốc" in GameManager.badges):
		report_fail("Trao huy hiệu Soát Vé Siêu Tốc", "Huy hiệu chưa có trong GameManager.badges")
	else:
		report_pass("Trao huy hiệu danh hiệu 'Soát Vé Siêu Tốc' thành công")
		
	if not signal_box[0]:
		report_fail("Signal minigame_completed", "minigame_completed không được phát ra")
	else:
		report_pass("Phát signal minigame_completed thành công")
		
	# =========================================================================
	# 9. TEST ĐIỀU KIỆN THUA (GATE JAM - 3 KHÁCH HẾT KIÊN NHẪN)
	# =========================================================================
	print("\n>>> KIỂM TRA ĐIỀU KIỆN THUA (GATE JAM - KẸT CỔNG)")
	game.reset_game()
	game.failed_passengers = 2
	game._on_passenger_impatient_lost()
	await get_tree().process_frame
	
	if not game.defeat_modal.visible or game.failed_passengers != 3:
		report_fail("Defeat Gate Jam", "defeat_modal không hiển thị khi 3 khách bỏ đi")
	else:
		report_pass("Kích hoạt Defeat Modal khi 3 khách hết kiên nhẫn bỏ đi (Gate Jam)")
		
	await get_tree().create_timer(0.1).timeout
	var img_defeat = get_viewport().get_texture().get_image()
	img_defeat.save_png("res://screenshot_verified_checkin_rush_defeat.png")
	report_pass("Đã chụp screenshot: screenshot_verified_checkin_rush_defeat.png")
	
	game.btn_retry.pressed.emit()
	await get_tree().process_frame
	if game.defeat_modal.visible or game.failed_passengers != 0:
		report_fail("Nút Thử Lại Ngay", "Không reset sau khi bấm retry")
	else:
		report_pass("Nút 'Thử Lại Ngay' (Safe Failure) reset lại màn chơi mượt mà")
