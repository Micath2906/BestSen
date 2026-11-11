extends Control

# CapturePauseAndPuzzle.gd
# Kiểm thử toàn diện và chụp màn hình:
# 1. Nút Pause góc trên bên trái & Modal Pause (Cài đặt âm lượng, rung, về Menu chính)
# 2. Đơn vị tiền tệ 💵 VNĐ
# 3. Hệ thống Tranh Ghép Puzzle 4 bộ và Bằng Khen Hoàng Gia Vinh Danh (Certificate Modal)

func _ready() -> void:
	print("\n========================================================")
	print("   BEST SEN - TEST PAUSE MODAL & PUZZLE CERTIFICATES    ")
	print("========================================================")
	_run_flow()

func _run_flow() -> void:
	# Khởi tạo game state chuẩn
	GameManager.reset_save_data()
	GameManager.set_owner_name("Minh Anh")
	GameManager.set_cat_name("Mochi")
	GameManager.selected_avatar_id = 0
	GameManager.fish = 90
	
	# [1] KIỂM THỬ ĐƠN VỊ TIỀN TỆ
	print("\n[1] Kiểm thử hiển thị tiền tệ:")
	var curr_90 = GameManager.format_currency(90)
	var curr_50 = GameManager.format_currency(50)
	var curr_100 = GameManager.format_currency(100)
	assert(curr_90 == "90.000đ", "Format 90 cá thành 90.000đ thất bại: " + curr_90)
	assert(curr_50 == "50.000đ", "Format 50 cá thành 50.000đ thất bại: " + curr_50)
	assert(curr_100 == "100.000đ", "Format 100 cá thành 100.000đ thất bại: " + curr_100)
	print("  -> Format 90 -> %s, 50 -> %s, 100 -> %s PASS!" % [curr_90, curr_50, curr_100])
	
	# [2] KIỂM THỬ IN-GAME MAIN & PAUSE MODAL
	print("\n[2] Kiểm thử Main View & Pause Modal:")
	var main_scene = load("res://scenes/Main.tscn").instantiate()
	add_child(main_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var hud = main_scene.get_node("CatProfileHUD")
	var btn_pause = hud.get_node("HUDContainer/HBox/BtnPause")
	var coin_label = hud.lbl_fish_val
	var pause_modal = main_scene.get_node("PauseModal")
	
	assert(btn_pause != null, "Không tìm thấy nút BtnPause ở HUD góc trên bên trái!")
	assert(pause_modal != null, "Không tìm thấy PauseModal trong Main!")
	assert(coin_label.text == "90.000đ", "HUD hiển thị tiền không phải 90.000đ! Nhận được: " + coin_label.text)
	print("  -> Nút Pause ở góc trên bên trái: TỒN TẠI!")
	print("  -> HUD hiển thị tiền: %s (Biểu tượng tiền 💵): CHUẨN XÁC!" % coin_label.text)
	
	# Mở Pause Modal
	btn_pause.emit_signal("pressed")
	await get_tree().process_frame
	await get_tree().process_frame
	assert(pause_modal.visible == true, "PauseModal không mở khi bấm BtnPause!")
	print("  -> Mở Pause Modal thành công qua BtnPause!")
	
	# Chụp màn hình Pause Modal
	await _capture("screenshot_ingame_pause_modal.png")
	
	# Đóng Pause modal
	var btn_resume = pause_modal.get_node("Panel/VBox/BtnResume")
	btn_resume.emit_signal("pressed")
	await get_tree().process_frame
	assert(pause_modal.visible == false, "Nút Resume không đóng PauseModal!")
	print("  -> Đóng Pause Modal thành công bằng nút Tiếp tục chơi!")
	
	remove_child(main_scene)
	main_scene.queue_free()
	await get_tree().process_frame
	
	# [3] KIỂM THỬ BẢO TÀNG & BỘ SƯU TẬP PUZZLE
	print("\n[3] Kiểm thử Bảo Tàng & Bộ Sưu Tập Puzzle Tranh Ghép:")
	# Thiết lập đã học xong 4 bài đầu tiên (Bài 1, 2, 3, 4 -> Bộ Thổ Địa Thành Phố)
	GameManager.completed_lessons = [1, 2, 3, 4]
	
	var museum_scene = load("res://scenes/MuseumView.tscn").instantiate()
	add_child(museum_scene)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var pz_container = museum_scene.get_node("ScrollContainer/VBox/PuzzleContainer")
	assert(pz_container != null, "Không tìm thấy PuzzleContainer!")
	assert(pz_container.get_child_count() == 4, "Phải có đúng 4 bộ sưu tập puzzle! Nhận được: %d" % pz_container.get_child_count())
	print("  -> 4 Bộ Sưu Tập Tranh Ghép Puzzle đã nạp thành công:")
	for child in pz_container.get_children():
		print("     * " + child.name)
		
	# Cuộn xuống phần Puzzle để chụp ảnh
	var scroll = museum_scene.get_node("ScrollContainer")
	scroll.scroll_vertical = 240
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Chụp màn hình Puzzle collections
	await _capture("screenshot_puzzle_collections.png")
	
	# [4] KIỂM THỬ NHẬN BẰNG KHEN HOÀNG GIA & THƯỞNG TIỀN
	print("\n[4] Kiểm thử Nhận Bằng Khen Hoàng Gia (Royal Certificate):")
	var set1_card = pz_container.get_child(0)
	var claim_btn = set1_card.find_child("BtnClaim", true, false)
	assert(claim_btn != null, "Không tìm thấy nút Nhận Bằng Khen ở bộ puzzle 1 đã hoàn thành!")
	assert(claim_btn.text.contains("NHẬN CHỨNG NHẬN"), "Nút chưa ở trạng thái Nhận Bằng: " + claim_btn.text)
	
	var fish_before = GameManager.fish
	# Click Nhận Bằng Khen
	claim_btn.emit_signal("pressed")
	await get_tree().process_frame
	await get_tree().process_frame
	
	var cert_modal = museum_scene.get_node("CertificateModal")
	assert(cert_modal.visible == true, "CertificateModal không mở khi nhận bằng!")
	
	var cert_title = museum_scene.get_node("CertificateModal/CertPanel/VBox/CertTitle").text
	var cert_rank = museum_scene.get_node("CertificateModal/CertPanel/VBox/CertRank").text
	var cert_recip = museum_scene.get_node("CertificateModal/CertPanel/VBox/RecipientLabel").text
	var cert_reward = museum_scene.get_node("CertificateModal/CertPanel/VBox/RewardBox/VBox/RewardLabel").text
	
	assert(cert_title.contains("THỔ ĐỊA"), "Tiêu đề chứng nhận không khớp: " + cert_title)
	assert(cert_rank.contains("ĐƯỜNG PHỐ"), "Danh hiệu không khớp: " + cert_rank)
	assert(cert_recip.contains("Minh Anh") and cert_recip.contains("Mochi"), "Tên người nhận không khớp: " + cert_recip)
	assert(GameManager.fish == fish_before + 50, "Cộng tiền thưởng thất bại! Trước: %d, Sau: %d" % [fish_before, GameManager.fish])
	assert(GameManager.is_certificate_claimed("cert_street") == true, "Chứng nhận chưa lưu vào claimed_certificates!")
	print("  -> Certificate Modal hiển thị danh hiệu: %s" % cert_rank)
	print("  -> Kính tặng: %s" % cert_recip)
	print("  -> Tiền thưởng: %s (Tiền tăng từ %d lên %d = %s) PASS!" % [cert_reward, fish_before, GameManager.fish, GameManager.format_currency(GameManager.fish)])
	
	# Chụp ảnh Certificate Modal
	await _capture("screenshot_royal_certificate_modal.png")
	
	# Đóng modal chứng nhận
	var btn_close_cert = museum_scene.get_node("CertificateModal/CertPanel/VBox/BtnCloseCert")
	btn_close_cert.emit_signal("pressed")
	await get_tree().process_frame
	assert(cert_modal.visible == false, "Modal chứng nhận không đóng sau khi bấm nút xác nhận!")
	print("  -> Đóng Modal Chứng Nhận thành công!")
	
	# Kiểm tra nút đổi thành "Xem Bằng Khen"
	var view_cert_btn = museum_scene.find_child("BtnViewCert", true, false)
	assert(view_cert_btn != null and view_cert_btn.text.contains("Xem Bằng"), "Nút sau khi nhận phải chuyển sang Xem Bằng!")
	print("  -> Nút chuyển sang trạng thái: [📜 Xem Bằng Khen] thành công!")
	
	print("\n========================================================")
	print("       TẤT CẢ KIỂM THỬ PAUSE & PUZZLE THÀNH CÔNG!       ")
	print("========================================================")
	get_tree().quit(0)

func _capture(filename: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var image = get_viewport().get_texture().get_image()
	var save_path = "res://" + filename
	image.save_png(save_path)
	print("  [CAPTURE] Đã lưu ảnh: %s (%dx%d)" % [filename, image.get_width(), image.get_height()])
