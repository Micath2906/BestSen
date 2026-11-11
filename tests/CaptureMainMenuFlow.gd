extends Control

@onready var menu = $MainMenu

var main_scene_res = preload("res://scenes/Main.tscn")
var main_node: Control = null

func _ready() -> void:
	await get_tree().create_timer(0.4).timeout
	
	# Đảm bảo reset trạng thái sạch ban đầu để test
	GameManager.has_completed_onboarding = false
	menu._setup_home_view()
	
	# === 1. KIỂM THỬ GIAO DIỆN CHÍNH (MAIN MENU) ===
	assert(menu != null, "MainMenu phải được khởi tạo!")
	assert(menu.home_view.visible == true, "HomeView phải hiển thị khi mới mở game!")
	assert(menu.btn_play.visible == true, "Nút Play phải có mặt!")
	assert(menu.btn_setting.visible == true, "Nút Setting phải có mặt!")
	assert(menu.btn_info.visible == true, "Nút Info phải có mặt!")
	print("MainMenu UI nodes: PASS!")
	
	# Chụp ảnh 1: Màn hình Main Menu
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("D:/BestSen/screenshot_main_menu.png")
	print("Captured: screenshot_main_menu.png")
	
	# === 2. KIỂM THỬ MODAL CÀI ĐẶT (SETTING) ===
	menu.btn_setting.emit_signal("pressed")
	await get_tree().create_timer(0.3).timeout
	assert(menu.setting_modal.visible == true, "Setting modal phải hiển thị!")
	menu.slider_sfx.value = 85.0
	menu.slider_sfx.value_changed.emit(85.0)
	assert(int(SoundManager.sfx_volume * 100) == 85, "Âm lượng SFX phải cập nhật 85%!")
	
	# Chụp ảnh 2: Cài Đặt (Setting Modal)
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("D:/BestSen/screenshot_main_menu_setting.png")
	print("Captured: screenshot_main_menu_setting.png")
	
	# Đóng Setting
	menu.btn_close_setting.emit_signal("pressed")
	await get_tree().create_timer(0.2).timeout
	assert(menu.setting_modal.visible == false, "Setting modal phải đóng!")
	
	# === 3. KIỂM THỬ MODAL THÔNG TIN (INFO) ===
	menu.btn_info.emit_signal("pressed")
	await get_tree().create_timer(0.3).timeout
	assert(menu.info_modal.visible == true, "Info modal phải hiển thị!")
	
	# Chụp ảnh 3: Thông Tin (Info Modal)
	var img3 = get_viewport().get_texture().get_image()
	img3.save_png("D:/BestSen/screenshot_main_menu_info.png")
	print("Captured: screenshot_main_menu_info.png")
	
	# Đóng Info
	menu.btn_close_info.emit_signal("pressed")
	await get_tree().create_timer(0.2).timeout
	assert(menu.info_modal.visible == false, "Info modal phải đóng!")
	
	# === 4. KIỂM THỬ BẤM PLAY -> MỞ CHỌN LOÀI MÈO & ĐẶT TÊN ===
	menu.btn_play.emit_signal("pressed")
	await get_tree().create_timer(0.3).timeout
	assert(menu.cat_creation_view.visible == true, "CatCreationView phải hiển thị khi bấm Play!")
	assert(menu.home_view.visible == false, "HomeView phải ẩn khi vào tạo mèo!")
	print("Open CatCreationView: PASS!")
	
	# Thử bấm chuyển giống mèo: ◀ / ▶
	var initial_breed = menu.current_breed_idx
	menu.btn_next_breed.emit_signal("pressed")
	await get_tree().create_timer(0.1).timeout
	assert(menu.current_breed_idx == (initial_breed + 1) % 8, "Nút tiếp phải chuyển giống mèo kế tiếp!")
	
	# Thử chuyển đến giống mèo số 4 (Mèo Tuxedo Quý Tộc)
	menu.current_breed_idx = 4
	menu._update_breed_display()
	assert(menu.breed_name_label.text.contains("Mèo Tuxedo Quý Tộc"), "Nhãn giống mèo phải là Mèo Tuxedo!")
	
	# Đặt tên mèo bằng nút xúc xắc hoặc gõ tên
	menu.btn_random_cat_name.emit_signal("pressed")
	assert(menu.edit_cat_name.text != "", "Tên mèo ngẫu nhiên không được rỗng!")
	
	# Gõ tên tùy chỉnh: "Boss Bánh Bao"
	menu.edit_cat_name.text = "Boss Bánh Bao"
	menu.edit_room_name.text = "Phòng Trọ Boss Bánh Bao"
	menu.edit_owner_name.text = "Sen Tân Sinh Viên"
	await get_tree().create_timer(0.2).timeout
	
	# Chụp ảnh 4: Màn hình chọn mèo và đặt tên
	var img4 = get_viewport().get_texture().get_image()
	img4.save_png("D:/BestSen/screenshot_cat_creation_screen.png")
	print("Captured: screenshot_cat_creation_screen.png")
	
	# === 5. BẤM BẮT ĐẦU VÀO PHÒNG TRỌ ===
	var start_received = {"ok": false}
	menu.start_game_requested.connect(func(c_name, b_id, r_name):
		start_received["ok"] = true
		print("Received start_game_requested: ", c_name, " breed: ", b_id, " room: ", r_name)
	)
	menu.btn_start_game.emit_signal("pressed")
	await get_tree().create_timer(0.3).timeout
	assert(start_received["ok"], "start_game_requested signal phải được phát ra!")
	
	# Kiểm tra dữ liệu GameManager đã được lưu chuẩn xác
	assert(GameManager.selected_avatar_id == 4, "Avatar ID phải là 4 (Tuxedo)!")
	assert(GameManager.get_cat_name() == "Boss Bánh Bao", "Tên mèo phải là 'Boss Bánh Bao'!")
	assert(GameManager.get_room_name() == "Phòng Trọ Boss Bánh Bao", "Tên phòng phải là 'Phòng Trọ Boss Bánh Bao'!")
	assert(GameManager.has_completed_onboarding == true, "has_completed_onboarding phải là true!")
	print("GameManager profile state: PASS!")
	
	# === 6. VÀO GAME VÀ CHỤP PHÒNG TRỌ SAU KHI TẠO MÈO ===
	menu.visible = false
	main_node = main_scene_res.instantiate()
	add_child(main_node)
	await get_tree().create_timer(0.5).timeout
	
	# Chụp ảnh 5: Màn hình game trong phòng trọ sau khi tạo mèo
	var img5 = get_viewport().get_texture().get_image()
	img5.save_png("D:/BestSen/screenshot_game_after_creation.png")
	print("Captured: screenshot_game_after_creation.png")
	
	# === 7. KIỂM THỬ NÚT VỀ MENU VÀ NÚT TIẾP TỤC ===
	main_node.queue_free()
	main_node = null
	menu.visible = true
	menu.cat_creation_view.visible = false
	menu.home_view.visible = true
	menu._setup_home_view()
	assert(menu.btn_continue.visible == true, "Sau khi có mèo, nút Tiếp Tục phải xuất hiện trên Main Menu!")
	await get_tree().create_timer(0.3).timeout
	
	var img6 = get_viewport().get_texture().get_image()
	img6.save_png("D:/BestSen/screenshot_main_menu_continue.png")
	print("Captured: screenshot_main_menu_continue.png")
	
	print("ALL MAIN MENU & CAT CREATION TESTS PASSED 100%!")
	get_tree().quit()
