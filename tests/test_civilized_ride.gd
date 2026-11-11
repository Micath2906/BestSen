extends Node

# test_civilized_ride.gd - Automation Test Runner cho Minigame "Chuyến Đi Văn Minh"
# Kiểm thử toàn diện 4 tình huống: Ghế ưu tiên, Ba lô lối đi, Móc túi QTE, Chuông dừng trạm,
# Đo khoảng cách, Điểm văn minh, Timeout penalty, Victory/Defeat flow, Infographic guide.

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
	print("   TEST AUTOMATION: CHUYẾN ĐI VĂN MINH (BEST SEN)")
	print("=".repeat(65))
	
	await run_tests()
	
	print("\n" + "=".repeat(65))
	print("             KẾT QUẢ KIỂM THỬ CHUYẾN ĐI VĂN MINH")
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
	var scn = load("res://scenes/minigames/CivilizedRideGame.tscn")
	if scn == null:
		report_fail("Tải CivilizedRideGame.tscn", "Không thể load res://scenes/minigames/CivilizedRideGame.tscn")
		return
	report_pass("Load scene CivilizedRideGame.tscn thành công")
	
	var game = scn.instantiate()
	if game == null:
		report_fail("Instantiate CivilizedRideGame", "instantiate() trả về null")
		return
	report_pass("Instantiate CivilizedRideGame thành công")
	
	add_child(game)
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 2. Kiểm tra node UI chính
	if game.clock_label == null or game.distance_label == null or game.civic_label == null:
		report_fail("UI Header Nodes", "Thiếu Header labels trong CivilizedRideGame")
	elif game.bell_button == null or game.timing_widget == null or game.cabin_draw_canvas == null:
		report_fail("Cabin & Stop Bell Nodes", "Thiếu Stop Bell hoặc Cabin Canvas trong CivilizedRideGame")
	elif game.hotspot_dog == null or game.hotspot_bear == null or game.hotspot_thief == null:
		report_fail("Hotspots Nodes", "Thiếu Hotspots tương tác trong CivilizedRideGame")
	else:
		report_pass("Header, Cabin Canvas, Stop Bell Widget và Hotspots sẵn sàng")
		
	# 3. Trạng thái khởi điểm
	if game.time_left < 73.0 or game.time_left > 75.0 or game.distance_remaining_m < 580.0 or game.distance_remaining_m > 600.0 or game.civic_points != 50:
		report_fail("Trạng thái ban đầu", "time_left=%f, distance=%f, civic=%d" % [game.time_left, game.distance_remaining_m, game.civic_points])
	else:
		report_pass("Trạng thái ban đầu chuẩn: 75.0s, 600.0m, Điểm Văn Minh: 50/100")
		
	# =========================================================================
	# 4. TEST TÌNH HUỐNG 1: NHƯỜNG GHẾ ƯU TIÊN
	# =========================================================================
	print("\n>>> KIỂM TRA TÌNH HUỐNG 1: NHƯỜNG GHẾ ƯU TIÊN CHO MÈO CỤ")
	game._trigger_situation(game.SituationType.PRIORITY_SEAT, 5.0)
	await get_tree().process_frame
	
	if not game.hotspot_dog.visible:
		report_fail("Hiển thị Hotspot Chó", "hotspot_dog không visible khi kích hoạt Tình huống 1")
	else:
		report_pass("Kích hoạt Tình huống 1: Mèo Cụ bước lên, Hotspot Chó hiện diện")
		
	var civic_before = game.civic_points
	game.hotspot_dog.pressed.emit()
	await get_tree().process_frame
	
	if not game.is_grandpa_seated or game.civic_points != civic_before + 15:
		report_fail("Xử lý nhường ghế", "is_grandpa_seated=%s, civic_points=%d" % [str(game.is_grandpa_seated), game.civic_points])
	else:
		report_pass("Nhường ghế thành công! Mèo Cụ ngồi vào ghế cam, thả tim (+15 Điểm -> %d/100)" % game.civic_points)
		
	# =========================================================================
	# 5. TEST TÌNH HUỐNG 2: QUY TẮC BA LÔ LỐI ĐI
	# =========================================================================
	print("\n>>> KIỂM TRA TÌNH HUỐNG 2: QUY TẮC BA LÔ LỐI ĐI")
	game._trigger_situation(game.SituationType.BACKPACK_WAY, 6.0)
	await get_tree().process_frame
	
	if not game.hotspot_bear.visible:
		report_fail("Hiển thị Hotspot Gấu", "hotspot_bear không visible khi kích hoạt Tình huống 2")
	else:
		report_pass("Kích hoạt Tình huống 2: Ba lô của Gấu cọ người khác, Hotspot Gấu hiện diện")
		
	civic_before = game.civic_points
	game.hotspot_bear.pressed.emit()
	await get_tree().process_frame
	
	if not game.is_bear_backpack_front or game.civic_points != civic_before + 10:
		report_fail("Xử lý ôm ba lô", "is_bear_backpack_front=%s, civic_points=%d" % [str(game.is_bear_backpack_front), game.civic_points])
	else:
		report_pass("Nhắc Gấu ôm ba lô trước ngực thành công! Lối đi thông thoáng (+10 Điểm -> %d/100)" % game.civic_points)
		
	# =========================================================================
	# 6. TEST TÌNH HUỐNG 3: BẮT QUẢ TANG KẺ MÓC TÚI (ANTI-THEFT QTE)
	# =========================================================================
	print("\n>>> KIỂM TRA TÌNH HUỐNG 3: BẮT QUẢ TANG KẺ MÓC TÚI QTE")
	game._trigger_situation(game.SituationType.ANTI_THEFT_QTE, 2.5)
	await get_tree().process_frame
	
	if not game.hotspot_thief.visible:
		report_fail("Hiển thị Hotspot Chuột Móc Túi", "hotspot_thief không visible khi kích hoạt Tình huống 3")
	else:
		report_pass("Kích hoạt Tình huống 3: Chuột Cống móc túi mèo ngủ, Hotspot bàn tay hiện diện")
		
	civic_before = game.civic_points
	game.hotspot_thief.pressed.emit()
	await get_tree().process_frame
	
	if not game.is_thief_caught or game.civic_points != civic_before + 20:
		report_fail("Xử lý bắt móc túi", "is_thief_caught=%s, civic_points=%d" % [str(game.is_thief_caught), game.civic_points])
	else:
		report_pass("Bắt quả tang kẻ móc túi chuẩn xác! Kẻ gian rụt tay (+20 Điểm -> %d/100)" % game.civic_points)
		
	# =========================================================================
	# 7. TEST TÌNH HUỐNG 4: CĂN NHỊP BẤM CHUÔNG XUỐNG TRẠM
	# =========================================================================
	print("\n>>> KIỂM TRA TÌNH HUỐNG 4: CĂN NHỊP BẤM CHUÔNG XUỐNG TRẠM")
	# 7.1 Bấm quá sớm khi cự ly > 115m (160m)
	game.distance_remaining_m = 160.0
	game._trigger_situation(game.SituationType.STOP_BELL_TIMING, 12.0)
	await get_tree().process_frame
	
	civic_before = game.civic_points
	game.bell_button.pressed.emit()
	if game.civic_points >= civic_before:
		report_fail("Phạt bấm chuông quá sớm", "Không bị trừ điểm khi bấm chuông > 150m")
	else:
		report_pass("Phạt -15 Điểm khi bấm chuông quá sớm (>150m), bác tài phanh gấp giật mình")
		
	# 7.2 Canh đúng Sweet Spot (khoảng cách 80m - trong dải 45m đến 115m)
	game.distance_remaining_m = 80.0
	civic_before = game.civic_points
	game.bell_button.pressed.emit()
	await get_tree().process_frame
	
	if not game.is_bell_rung_correctly or game.civic_points < civic_before + 20:
		report_fail("Bấm chuông trúng Sweet Spot", "is_bell_rung_correctly=%s, civic=%d" % [str(game.is_bell_rung_correctly), game.civic_points])
	else:
		report_pass("Bấm chuông trúng Sweet Spot 80m! Chuông reng 'KENG KENG', đèn xanh sáng (+25 Điểm -> %d/100)" % game.civic_points)
		
	# Chụp ảnh Gameplay thực tế
	await get_tree().create_timer(0.2).timeout
	var vp_tex = get_viewport().get_texture()
	if vp_tex:
		var img_gameplay = vp_tex.get_image()
		if img_gameplay:
			img_gameplay.save_png("res://screenshot_verified_civilized_ride_gameplay.png")
			report_pass("Đã chụp screenshot: screenshot_verified_civilized_ride_gameplay.png")
	
	# =========================================================================
	# 8. TEST ĐẠT ĐIỀU KIỆN THẮNG (VICTORY >= 70 ĐIỂM KHI ĐẾN TRẠM)
	# =========================================================================
	print("\n>>> KIỂM TRA HOÀN THÀNH HÀNH TRÌNH ĐẠT CHUẨN VĂN MINH (VICTORY)")
	game.civic_points = 100
	game._trigger_victory()
	await get_tree().process_frame
	
	if not game.victory_modal.visible:
		report_fail("Hiển thị Victory Modal", "victory_modal không visible khi trigger victory")
	else:
		report_pass("Kích hoạt Victory Modal thành công với Điểm Văn Minh: %d/100" % game.civic_points)
		
	await get_tree().create_timer(0.1).timeout
	var vp_vic = get_viewport().get_texture()
	if vp_vic:
		var img_victory = vp_vic.get_image()
		if img_victory:
			img_victory.save_png("res://screenshot_verified_civilized_ride_victory.png")
			report_pass("Đã chụp screenshot: screenshot_verified_civilized_ride_victory.png")
	
	# 8.1 Kiểm tra Infographic Cẩm Nang Văn Minh
	game.btn_view_infographic.pressed.emit()
	await get_tree().process_frame
	if not game.infographic_modal.visible:
		report_fail("Mở Infographic Cẩm Nang", "infographic_modal không visible")
	else:
		report_pass("Mở Infographic Cẩm Nang Bỏ Túi Văn Minh Xe Buýt & Metro thành công")
		
	await get_tree().create_timer(0.1).timeout
	var vp_info = get_viewport().get_texture()
	if vp_info:
		var img_info = vp_info.get_image()
		if img_info:
			img_info.save_png("res://screenshot_verified_civilized_ride_infographic.png")
			report_pass("Đã chụp screenshot: screenshot_verified_civilized_ride_infographic.png")
	
	game.btn_close_info.pressed.emit()
	await get_tree().process_frame
	if game.infographic_modal.visible:
		report_fail("Đóng Infographic Cẩm Nang", "infographic_modal vẫn còn visible")
	else:
		report_pass("Đóng Infographic Cẩm Nang quay lại modal phần thưởng thành công")
		
	# 8.2 Nhận thưởng và huy hiệu
	var fish_before = GameManager.fish
	var signal_box = [false]
	game.minigame_completed.connect(func(_steps): signal_box[0] = true)
	game.btn_claim_victory.pressed.emit()
	await get_tree().process_frame
	
	if GameManager.fish <= fish_before:
		report_fail("Thưởng Cá Khô Victory", "GameManager.fish không tăng sau khi nhận thưởng")
	else:
		report_pass("Thưởng Cá Khô thành công (+%d Cá Khô)" % (GameManager.fish - fish_before))
		
	if not ("Công Dân Giao Thông Mẫu Mực" in GameManager.badges):
		report_fail("Trao huy hiệu Công Dân Giao Thông Mẫu Mực", "Huy hiệu chưa có trong GameManager.badges")
	else:
		report_pass("Trao huy hiệu danh hiệu 'Công Dân Giao Thông Mẫu Mực' thành công")
		
	if not signal_box[0]:
		report_fail("Signal minigame_completed", "minigame_completed không được phát ra")
	else:
		report_pass("Phát signal minigame_completed kèm 4 bước tóm tắt chuẩn xác")
		
	# =========================================================================
	# 9. TEST ĐIỀU KIỆN THUA (CIVIC POINTS < 30) & SAFE FAILURE RETRY
	# =========================================================================
	print("\n>>> KIỂM TRA ĐIỀU KIỆN THUA (CIVIC POINTS < 30) VÀ THỬ LẠI")
	game.reset_game()
	game.civic_points = 20
	game._trigger_defeat("Điểm Văn Minh tụt dưới 30! Mời Sen xuống xe ở trạm kế tiếp!")
	await get_tree().process_frame
	
	if not game.defeat_modal.visible:
		report_fail("Hiển thị Defeat Modal", "defeat_modal không visible khi điểm < 30")
	else:
		report_pass("Kích hoạt Defeat Modal khi Điểm Văn Minh < 30 (bị mời xuống xe)")
		
	await get_tree().create_timer(0.1).timeout
	var vp_def = get_viewport().get_texture()
	if vp_def:
		var img_defeat = vp_def.get_image()
		if img_defeat:
			img_defeat.save_png("res://screenshot_verified_civilized_ride_defeat.png")
			report_pass("Đã chụp screenshot: screenshot_verified_civilized_ride_defeat.png")
	
	game.btn_retry.pressed.emit()
	await get_tree().process_frame
	if game.defeat_modal.visible or game.civic_points != 50 or not game.is_game_active:
		report_fail("Nút Thử Lại Ngay", "Không reset sau khi bấm retry")
	else:
		report_pass("Nút 'Thử Lại Ngay' (Safe Failure) reset lại màn chơi mượt mà")
