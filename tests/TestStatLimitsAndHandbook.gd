extends Node

func _ready() -> void:
	print("\n=== BẮT ĐẦU KIỂM THỬ: CẨM NANG GÓC TRÊN BÊN TRÁI & GIỚI HẠN CHỈ SỐ ===")
	
	# Đặt baseline chuẩn cho test môi trường độc lập
	GameManager.fish = 90
	GameManager.mood = 85
	GameManager.courage = 80
	GameManager.hunger = 70
	GameManager.is_fainted = false
	GameManager.is_shy = false
	
	# 1. Khởi tạo Main Scene
	var main_scene = load("res://scenes/Main.tscn")
	var main_node = main_scene.instantiate()
	add_child(main_node)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 2. Kiểm tra nút Cẩm Nang nhanh
	var room_view = main_node.current_view_node
	var btn_handbook: Button = room_view.get_node("UnifiedActionRow/BtnHandbookQuick") if room_view else null
	assert(btn_handbook != null, "Phòng chính phải có nút BtnHandbookQuick trong hàng gom 3 nút!")
	print("[PASS 1] Nút '📖 Cẩm Nang' nằm trong hàng trung tâm gom 3 nút hoạt động hoàn hảo!")
	
	# Kiểm tra bấm nút Cẩm Nang nhanh mở HandbookView
	btn_handbook.emit_signal("pressed")
	await get_tree().process_frame
	assert(main_node.current_tab_name == "handbook", "Bấm nút phải chuyển sang màn hình Handbook!")
	print("[PASS 2] Bấm nút Cẩm Nang nhanh mở Thư viện Cẩm nang cứu nguy 24/7 thành công!")
	
	# Quay về phòng trọ
	main_node.switch_to_room()
	await get_tree().process_frame
	
	# 3. Kiểm thử giới hạn No vượt quá (hunger >= 100) -> Không ăn được nữa
	print("\n--- Kiểm thử khi Độ No vượt quá 100 ---")
	GameManager.hunger = 100
	GameManager.update_stats(0, 0, 0, 0)
	var feed_check = GameManager.can_feed()
	assert(feed_check["ok"] == false, "Khi Độ No = 100, can_feed() phải trả về false!")
	
	var initial_fish = GameManager.fish
	var feed_result = GameManager.feed_basic()
	assert(feed_result == false, "feed_basic() phải trả về false khi Mèo đã no căng!")
	assert(GameManager.fish == initial_fish, "Không được trừ Cá Khô khi Mèo từ chối ăn!")
	
	var hud = main_node.get_node("CatProfileHUD")
	var hunger_lbl = hud.get_node("HUDContainer/HBox/RightInfo/BarsContainer/HungerRow/HungerValueLabel")
	assert(hunger_lbl.text == "100/100", "HUD phải hiển thị số thuần 100/100 gọn gàng!")
	print("[PASS 3] Khi No = 100, Mèo từ chối ăn thành công, bảo toàn ngân sách Cá Khô và HUD hiển thị 100/100 sạch sẽ!")
	
	# 4. Kiểm thử khi Độ No quá thấp (hunger <= 0) -> Mèo xỉu, không được đi học
	print("\n--- Kiểm thử khi Độ No <= 0 (Mèo Xỉu) ---")
	GameManager.hunger = 0
	GameManager.update_stats(0, 0, 0, 0)
	assert(GameManager.is_fainted == true, "Mèo phải ở trạng thái ngất xỉu (is_fainted = true)!")
	assert("0/100" in hunger_lbl.text, "HUD phải hiển thị '0/100'!")
	
	var lesson_check = GameManager.can_start_lesson()
	assert(lesson_check["ok"] == false, "Mèo ngất xỉu không được phép đi học!")
	assert("ngất xỉu" in lesson_check["reason"], "Lý do chặn học phải nêu rõ Mèo ngất xỉu vì hạ đường huyết!")
	print("[PASS 4] Khi Độ No = 0, Mèo ngất xỉu (XỈU! 😵), bị đình công từ chối học kỹ năng!")
	
	# Cấp cứu cho Mèo hồi tỉnh
	GameManager.hunger = 0 # reset
	# Cho ăn để hồi tỉnh
	GameManager.update_stats(0, +30, 0, 0) # Hồi tỉnh 30 no
	assert(GameManager.is_fainted == false, "Cho ăn xong Mèo phải hồi tỉnh!")
	print("[PASS 5] Cấp cứu thức ăn thành công, Boss đã hồi tỉnh và Độ No = %d!" % GameManager.hunger)
	
	# 5. Kiểm thử khi Dũng Cảm quá thấp (courage <= 15) -> Mèo tự ti không muốn đi học
	print("\n--- Kiểm thử khi Dũng Cảm <= 15 (Mèo Tự Ti) ---")
	GameManager.courage = 10
	GameManager.update_stats(0, 0, 0, 0)
	assert(GameManager.is_shy == true, "Mèo phải ở trạng thái tự ti (is_shy = true)!")
	
	var courage_lbl = hud.get_node("HUDContainer/HBox/RightInfo/BarsContainer/CourageRow/CourageValueLabel")
	assert("10/100" in courage_lbl.text, "HUD phải hiển thị '10/100'!")
	
	var shy_lesson_check = GameManager.can_start_lesson()
	assert(shy_lesson_check["ok"] == false, "Mèo tự ti không được phép đi học!")
	assert("tự ti" in shy_lesson_check["reason"], "Lý do chặn phải nêu rõ Mèo đang quá tự ti!")
	print("[PASS 6] Khi Dũng Cảm <= 15, Mèo tự ti trốn trong phòng, từ chối ra ngoài học kỹ năng!")
	
	# Hồi phục tự tin
	GameManager.play_box() # +15 Dũng cảm
	GameManager.play_feather() # +40 Dũng cảm
	assert(GameManager.courage > 20, "Dũng cảm phải được phục hồi > 20!")
	assert(GameManager.can_start_lesson()["ok"] == true, "Khi hết tự ti, Mèo sẵn sàng đi học trở lại!")
	print("[PASS 7] Cho chơi cần câu lông vũ & thùng carton giúp Mèo lấy lại tự tin (%d/100) và sẵn sàng đi học!" % GameManager.courage)
	
	# 6. Chụp ảnh màn hình kiểm chứng giao diện
	# Đặt chỉ số cân bằng đẹp mắt
	GameManager.hunger = 75
	GameManager.courage = 85
	GameManager.mood = 90
	GameManager.update_stats(0, 0, 0, 0)
	
	await get_tree().create_timer(0.8).timeout
	var viewport = get_viewport()
	if viewport:
		var tex = viewport.get_texture()
		if tex:
			var img = tex.get_image()
			if img:
				img.save_png("D:/BestSen/screenshot_stat_limits_and_handbook.png")
				print("Đã chụp ảnh màn hình xác thực: D:/BestSen/screenshot_stat_limits_and_handbook.png")
	
	print("\n=== TOÀN BỘ KIỂM THỬ THÀNH CÔNG 100%! ===")
	get_tree().quit()
