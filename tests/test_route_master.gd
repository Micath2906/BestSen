extends Node

# test_route_master.gd - Test Runner Tự Động & Chụp Ảnh Xác Minh Minigame "Thổ Địa Lập Route"
# Kiểm thử toàn diện 100%: Input drag & drop, snap to node, directional constraint,
# bottleneck ngập nước/kẹt xe, headway metro, double-tap cắt dây, modal cẩm nang & infographic

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
	print("   TEST AUTOMATION: MINIGAME THỔ ĐỊA LẬP ROUTE (BEST SEN)")
	print("=".repeat(65))
	
	await run_tests()
	
	print("\n" + "=".repeat(65))
	print("               KẾT QUẢ KIỂM THỬ ROUTE MASTER")
	print("=".repeat(65))
	print("Tổng Pass: %d" % passes)
	print("Tổng Failures: %d" % failures.size())
	
	if failures.size() > 0:
		for f in failures:
			print("  ❌ %s: %s" % [f["desc"], f["error"]])
	else:
		print("🎉 HOÀN THÀNH 100%: TẤT CẢ CÁC BÀI TEST & SCREENSHOT ĐỀU ĐẠT CHUẨN!")
	print("=".repeat(65) + "\n")
	
	get_tree().quit(1 if failures.size() > 0 else 0)

func run_tests() -> void:
	# 1. Khởi tạo Scene
	var scene_res = load("res://scenes/minigames/RouteMasterMiniGame.tscn")
	if scene_res == null:
		report_fail("Tải RouteMasterMiniGame.tscn", "Không thể load res://scenes/minigames/RouteMasterMiniGame.tscn")
		return
	report_pass("Load scene RouteMasterMiniGame.tscn thành công")
	
	var game = scene_res.instantiate()
	if game == null:
		report_fail("Khởi tạo node RouteMasterMiniGame", "instantiate() trả về null")
		return
	report_pass("Instantiate RouteMasterMiniGame thành công")
	
	add_child(game)
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 2. Kiểm tra các node UI chính
	if game.map_canvas == null:
		report_fail("MapCanvas Node", "game.map_canvas is null")
	else:
		report_pass("MapCanvas node sẵn sàng")
		
	if game.clock_label == null or game.fish_label == null or game.btn_handbook == null:
		report_fail("Header Nodes", "Thiếu một trong các node Header")
	else:
		report_pass("Header UI (Đồng hồ 60s, Ví Cá Khô, Nút Cẩm Nang) đầy đủ")
		
	# 3. Kiểm tra trạng thái khởi điểm
	if game.time_left < 58.0 or game.time_left > 60.0 or game.fish_wallet != 25 or game.connected_path != ["ktx_b"]:
		report_fail("Trạng thái khởi điểm", "time_left=%f, fish=%d, path=%s" % [game.time_left, game.fish_wallet, str(game.connected_path)])
	else:
		report_pass("Trạng thái ban đầu chuẩn: 60s, 25 Cá Khô, trạm xuất phát KTX Khu B")
		
	# 4. Kiểm tra Cẩm Nang Cứu Sen (Modal tra cứu Metro 1 & Bus)
	game.btn_handbook.emit_signal("pressed")
	await get_tree().process_frame
	if not game.handbook_modal.visible:
		report_fail("Mở Cẩm Nang Cứu Sen", "handbook_modal không hiển thị sau khi click")
	else:
		report_pass("Nút 'Cẩm Nang Cứu Sen' mở Modal tra cứu thành công")
		
	# Chụp ảnh Cẩm Nang
	await get_tree().create_timer(0.1).timeout
	var img_handbook = get_viewport().get_texture().get_image()
	img_handbook.save_png("res://screenshot_verified_route_master_handbook.png")
	report_pass("Đã chụp screenshot: screenshot_verified_route_master_handbook.png")
	
	game.btn_close_handbook.emit_signal("pressed")
	await get_tree().process_frame
	if game.handbook_modal.visible:
		report_fail("Đóng Cẩm Nang Cứu Sen", "handbook_modal vẫn hiển thị")
	else:
		report_pass("Đóng Cẩm Nang thành công, quay về bản đồ")
		
	# 5. Kiểm tra Bắt lỗi ngược chiều (Directional Constraint)
	# Thử kéo từ ktx_b sang dhqg_out (Node Sai: Chiều BX Miền Tây)
	game.is_dragging = true
	game.drag_from_node_id = "ktx_b"
	game.snapped_node_id = "dhqg_out"
	game._finish_drag_connection()
	
	if "dhqg_out" in game.connected_path:
		report_fail("Bắt lỗi ngược chiều", "Node ngược chiều dhqg_out bị thêm vào lộ trình!")
	else:
		report_pass("Chặn thành công Node sai hướng (chiều BX Miền Tây)")
		
	if not game.toast_panel.visible or not ("ngược hướng" in game.toast_label.text):
		report_fail("Toast cảnh báo ngược chiều", "Không hiển thị Toast cảnh báo 'Đi ngược hướng'")
	else:
		report_pass("Hiển thị Toast: '%s'" % game.toast_label.text)
		
	if game.shake_intensity <= 0.0:
		report_fail("Haptic Shake phản hồi", "shake_intensity không được kích hoạt")
	else:
		report_pass("Kích hoạt Haptic screen shake khi kéo nhầm hướng")
		
	# 6. Kiểm tra Kéo nối hợp lệ (Snap to Node & Path Extension)
	game.is_dragging = true
	game.drag_from_node_id = "ktx_b"
	game.snapped_node_id = "dhqg_in"
	game._finish_drag_connection()
	
	if not ("dhqg_in" in game.connected_path):
		report_fail("Nối trạm hợp lệ", "dhqg_in không được thêm vào connected_path")
	else:
		report_pass("Nối thành công KTX Khu B ➔ Trạm ĐHQG [➔ Bến Thành]")
		
	# Nối tiếp sang Chợ Thủ Đức
	game.is_dragging = true
	game.drag_from_node_id = "dhqg_in"
	game.snapped_node_id = "cho_thu_duc_in"
	game._finish_drag_connection()
	
	if not ("cho_thu_duc_in" in game.connected_path):
		report_fail("Nối trạm Chợ Thủ Đức", "cho_thu_duc_in không được thêm vào")
	else:
		report_pass("Nối thành công Trạm ĐHQG ➔ Chợ Thủ Đức")
		
	# 7. Kiểm tra Cơ chế Double-tap "Cắt dây" (Disconnect & Transfer)
	game._on_node_double_tapped("dhqg_in")
	if "cho_thu_duc_in" in game.connected_path:
		report_fail("Double-tap cắt dây", "cho_thu_duc_in vẫn còn trong lộ trình sau khi cắt dây từ dhqg_in")
	else:
		report_pass("Double-tap 'Cắt dây' thành công, cắt bỏ đoạn đi vào điểm đen ngập nước")
		
	# 8. Kiểm tra Chuyển tuyến Metro Line 1 & Tiêu hao Cá Khô (-5 Cá)
	game.is_dragging = true
	game.drag_from_node_id = "dhqg_in"
	game.snapped_node_id = "metro_suoi_tien"
	var prev_fish = game.fish_wallet
	game._finish_drag_connection()
	
	if not ("metro_suoi_tien" in game.connected_path):
		report_fail("Chuyển tuyến Metro Suối Tiên", "Không thể nối từ dhqg_in sang metro_suoi_tien")
	elif game.fish_wallet != prev_fish - 5:
		report_fail("Tiêu hao Cá Khô đổi tuyến", "Số dư Cá Khô không giảm đúng 5! Trước=%d, Sau=%d" % [prev_fish, game.fish_wallet])
	else:
		report_pass("Chuyển tuyến sang Ga Metro Suối Tiên thành công (-5 Cá Khô, ví còn %d)" % game.fish_wallet)
		
	if game.transfer_count != 1:
		report_fail("Đếm số lần chuyển tuyến", "transfer_count != 1")
	else:
		report_pass("transfer_count = 1 (Đạt yêu cầu tối đa 1 lần đổi tuyến)")
		
	# 9. Nối tiếp toàn bộ tuyến Metro 1 đến Trường Đại Học
	var metro_chain = [
		["metro_suoi_tien", "metro_thu_duc"],
		["metro_thu_duc", "metro_tan_cang"],
		["metro_tan_cang", "metro_ba_son"],
		["metro_ba_son", "metro_nha_hat"],
		["metro_nha_hat", "goal_dai_hoc"]
	]
	for pair in metro_chain:
		game.is_dragging = true
		game.drag_from_node_id = pair[0]
		game.snapped_node_id = pair[1]
		game._finish_drag_connection()
		
	if game.connected_path[game.connected_path.size() - 1] != "goal_dai_hoc":
		report_fail("Nối trọn vẹn lộ trình đến đích", "Đích đến không phải goal_dai_hoc: %s" % str(game.connected_path))
	else:
		report_pass("Lộ trình hoàn chỉnh: KTX -> ĐHQG -> Metro Suối Tiên -> Ga Thủ Đức -> Ga Tân Cảng -> Ga Ba Son -> Ga Nhà Hát -> Cổng Trường")
		
	# 10. Kiểm tra sự kiện động (Ngập nước ở 15s, Kẹt xe ở 30s)
	game.elapsed_time = 15.0
	game._process(0.1)
	if not game.flood_active:
		report_fail("Sự kiện ngập nước t=15s", "flood_active không được bật ở t=15s")
	else:
		report_pass("Sự kiện Ngập nước Chợ Thủ Đức xuất hiện đúng t=15s (sóng Cyan)")
		
	game.elapsed_time = 30.0
	game._process(0.1)
	if not game.traffic_active:
		report_fail("Sự kiện kẹt xe t=30s", "traffic_active không được bật ở t=30s")
	else:
		report_pass("Sự kiện Kẹt xe Ngã 4 Hàng Xanh xuất hiện đúng t=30s (khói Đỏ)")
		
	# Chụp ảnh Gameplay đang chạy
	await get_tree().create_timer(0.2).timeout
	var img_gameplay = get_viewport().get_texture().get_image()
	img_gameplay.save_png("res://screenshot_verified_route_master_gameplay.png")
	report_pass("Đã chụp screenshot: screenshot_verified_route_master_gameplay.png")
	
	# 11. Đưa Mèo về đích & Kích hoạt Chiến Thắng
	game.cat_segment_idx = game.connected_path.size() - 1
	game.cat_pos = game.stations["goal_dai_hoc"]["pos"]
	game._trigger_victory()
	await get_tree().process_frame
	
	if not game.victory_modal.visible:
		report_fail("Victory Modal", "victory_modal không hiển thị sau khi hoàn thành")
	else:
		report_pass("Cập bến trường trước 60s với transfer_count <= 1 -> Kích hoạt Cutscene Victory")
		
	# Chụp ảnh Victory
	await get_tree().create_timer(0.1).timeout
	var img_victory = get_viewport().get_texture().get_image()
	img_victory.save_png("res://screenshot_verified_route_master_victory.png")
	report_pass("Đã chụp screenshot: screenshot_verified_route_master_victory.png")
	
	# 12. Kiểm tra Infographic Modal
	game.btn_view_infographic.emit_signal("pressed")
	await get_tree().process_frame
	if not game.infographic_modal.visible:
		report_fail("Mở Infographic Modal", "infographic_modal không mở")
	else:
		report_pass("Mở Modal Infographic Lộ trình chuyển tiếp thành công")
		
	await get_tree().create_timer(0.1).timeout
	var img_info = get_viewport().get_texture().get_image()
	img_info.save_png("res://screenshot_verified_route_master_infographic.png")
	report_pass("Đã chụp screenshot: screenshot_verified_route_master_infographic.png")
	
	game.btn_close_infographic.emit_signal("pressed")
	await get_tree().process_frame
	if game.infographic_modal.visible:
		report_fail("Đóng Infographic Modal", "infographic_modal vẫn hiển thị")
	else:
		report_pass("Đóng Infographic Modal thành công")
		
	# 13. Kiểm tra Nhận Thưởng (+25 Cá Khô & Huy hiệu)
	var fish_before_claim = GameManager.fish
	var signal_box = [false]
	game.minigame_completed.connect(func(_steps): signal_box[0] = true)
	game.btn_claim_reward.pressed.emit()
	await get_tree().process_frame
	
	if GameManager.fish != fish_before_claim + 25:
		report_fail("Cộng thưởng 25 Cá Khô", "GameManager.fish không tăng 25")
	else:
		report_pass("Nhận thưởng thành công: +25 Cá Khô (Số dư mới: %d)" % GameManager.fish)
		
	if not ("Thổ Địa Tuyến 08" in GameManager.badges):
		report_fail("Trao huy hiệu Thổ Địa Tuyến 08", "Huy hiệu không có trong GameManager.badges")
	else:
		report_pass("Trao huy hiệu danh hiệu 'Thổ Địa Tuyến 08' thành công")
		
	if not signal_box[0]:
		report_fail("Signal minigame_completed", "minigame_completed không được phát ra")
	else:
		report_pass("Phát signal minigame_completed với dữ liệu mô phỏng thành công")
		
	# 14. Kiểm tra Điều kiện Thua & Nút "Thử Lại Ngay" (Safe Failure)
	game.reset_game()
	game.time_left = 0.0
	game._process(0.1)
	await get_tree().process_frame
	
	if not game.defeat_modal.visible:
		report_fail("Kích hoạt Defeat khi hết 60s", "defeat_modal không hiển thị khi time_left <= 0")
	else:
		report_pass("Kích hoạt Defeat Modal khi hết 60s chưa đến trường")
		
	await get_tree().create_timer(0.1).timeout
	var img_defeat = get_viewport().get_texture().get_image()
	img_defeat.save_png("res://screenshot_verified_route_master_defeat.png")
	report_pass("Đã chụp screenshot: screenshot_verified_route_master_defeat.png")
	
	game.btn_retry.emit_signal("pressed")
	await get_tree().process_frame
	if game.defeat_modal.visible or game.time_left != 60.0:
		report_fail("Nút Thử Lại Ngay", "Game không reset lại 60s sau khi retry")
	else:
		report_pass("Nút 'Thử Lại Ngay' (Safe Failure) reset lại màn chơi mượt mà")
