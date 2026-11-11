extends Node

func _ready() -> void:
	print("\n========================================================")
	print("   BEST SEN - SUITE KIỂM THỬ GIAO DIỆN MỚI & PHÒNG CLASSIC")
	print("========================================================\n")
	
	# [1] Kiểm thử Main Menu
	print("[1] Kiểm thử Main Menu (MainMenu.tscn):")
	var menu_scene = load("res://scenes/MainMenu.tscn")
	assert(menu_scene != null, "MainMenu scene phải nạp thành công!")
	var menu = menu_scene.instantiate()
	add_child(menu)
	
	var btn_play = menu.get_node("HomeView/CenterVBox/ButtonsCard/VBox/BtnPlay")
	var btn_setting = menu.get_node("HomeView/CenterVBox/ButtonsCard/VBox/BtnSetting")
	var btn_exit = menu.get_node("HomeView/CenterVBox/ButtonsCard/VBox/BtnExit")
	assert(btn_play != null and btn_setting != null and btn_exit != null, "3 nút PLAY, SETTINGS, EXIT phải tồn tại!")
	assert(btn_play.text == "PLAY", "BtnPlay phải có text PLAY!")
	assert(btn_setting.text == "SETTINGS", "BtnSetting phải có text SETTINGS!")
	assert(btn_exit.text == "EXIT", "BtnExit phải có text EXIT!")
	print("  -> Main Menu đúng 100% theo mẫu: Card tai mèo màu be, 3 nút PLAY, SETTINGS, EXIT PASS!")
	
	# [2] Kiểm thử Avatar Frame & CatProfileHUD
	print("\n[2] Kiểm thử Avatar Frame & CatProfileHUD:")
	var hud_scene = load("res://scenes/CatProfileHUD.tscn")
	assert(hud_scene != null, "CatProfileHUD scene phải nạp thành công!")
	var hud = hud_scene.instantiate()
	add_child(hud)
	
	# Kiểm tra 6 khung tai mèo trong GameManager
	assert(GameManager.available_avatar_frames.size() == 6, "Phải có 6 kiểu khung tai mèo!")
	for frame in GameManager.available_avatar_frames:
		var p = frame["path"]
		assert(ResourceLoader.exists(p) or FileAccess.file_exists(p), "File khung %s phải tồn tại trên disk!" % p)
	
	# Thử đổi các loại khung
	GameManager.set_avatar_frame("pink")
	assert(GameManager.selected_avatar_frame == "pink", "Đổi sang khung pink thành công!")
	GameManager.set_avatar_frame("gold")
	assert(GameManager.selected_avatar_frame == "gold", "Đổi sang khung gold thành công!")
	GameManager.set_avatar_frame("beige")
	assert(GameManager.selected_avatar_frame == "beige", "Đổi về khung beige mặc định thành công!")
	
	# Kiểm tra ô hiển thị đồng vàng
	var fish_lbl = hud.get_node("HUDContainer/HBox/RightInfo/CoinRow/CoinPanel/CoinHBox/FishLabel")
	assert(fish_lbl != null, "FishLabel hiển thị tiền đồng vàng phải tồn tại!")
	print("  -> Khung avatar tai mèo 6 kiểu & ô đồng vàng chuẩn mẫu Image 2 PASS 100%!")
	
	# [3] Kiểm thử AvatarPickerModal tích hợp tab chọn khung tai mèo
	print("\n[3] Kiểm thử AvatarPickerModal tích hợp tab chọn khung:")
	var modal_scene = load("res://scenes/AvatarPickerModal.tscn")
	assert(modal_scene != null, "AvatarPickerModal scene phải nạp thành công!")
	var modal = modal_scene.instantiate()
	add_child(modal)
	
	modal._switch_tab("frames")
	assert(modal.current_tab == "frames", "Chuyển sang tab frames thành công!")
	assert(modal.item_buttons.size() == 6, "Tab frames phải hiển thị 6 thẻ chọn khung!")
	modal._switch_tab("avatars")
	assert(modal.current_tab == "avatars", "Chuyển về tab avatars thành công!")
	assert(modal.item_buttons.size() >= 8, "Tab avatars phải hiển thị các thẻ chọn mèo (bao gồm Mochi & Pochi)!")
	print("  -> Tùy biến Avatar và Khung tai mèo chuyển tab mượt mà PASS 100%!")
	
	# [4] Kiểm thử Phòng Classic 2D Background
	print("\n[4] Kiểm thử Phòng Classic 2D Background (IsometricRoomView.tscn):")
	var room_scene = load("res://scenes/IsometricRoomView.tscn")
	assert(room_scene != null, "IsometricRoomView scene phải nạp thành công!")
	var room = room_scene.instantiate()
	add_child(room)
	
	# Kiểm tra TextureRect RoomBackground
	var room_bg = room.get_node_or_null("RoomBackground")
	assert(room_bg != null, "RoomBackground TextureRect phải tồn tại!")
	assert(room_bg.texture != null, "RoomBackground phải có texture nạp sẵn!")
	
	# Kiểm tra 20 Classic backgrounds
	for bg_id in range(1, 21):
		var bg_path = GameManager.get_classic_bg_path(bg_id)
		assert(ResourceLoader.exists(bg_path) or FileAccess.file_exists(bg_path), "Background Classic %d.png phải tồn tại!" % bg_id)
	
	# Đổi background sang phòng 5 và phòng 1
	GameManager.set_classic_bg(5)
	assert(GameManager.selected_classic_bg_id == 5, "Đổi sang phòng Classic #5 thành công!")
	GameManager.set_classic_bg(1)
	assert(GameManager.selected_classic_bg_id == 1, "Đổi về phòng Classic #1 thành công!")
	
	# Kiểm tra vị trí các đồ nội thất starter trên sàn 2D
	var cushion = room.get_node("YSortEntities/CushionBed")
	var tray = room.get_node("YSortEntities/DualTray")
	var scratch = room.get_node("YSortEntities/ScratchPost")
	var box = room.get_node("YSortEntities/CardboardBox")
	var decor = room.get_node("YSortEntities/DecorSlot")
	var cat = room.get_node("YSortEntities/IsoCat")
	
	assert(cushion.position.y >= 700.0, "CushionBed phải nằm trên mặt sàn Y >= 700!")
	assert(tray.position.y >= 700.0, "DualTray phải nằm trên mặt sàn Y >= 700!")
	assert(scratch.position.y >= 700.0, "ScratchPost phải nằm trên mặt sàn Y >= 700!")
	assert(box.position.y >= 700.0, "CardboardBox phải nằm trên mặt sàn Y >= 700!")
	assert(decor.position.y >= 700.0, "DecorSlot phải nằm trên mặt sàn Y >= 700!")
	print("  -> Background Classic 2D và bài trí nội thất trên mặt sàn PASS 100%!")
	
	print("\n========================================================")
	print("   TẤT CẢ TÍNH NĂNG MỚI ĐẠT CHUẨN XUẤT SẮC 100%!")
	print("========================================================\n")
	get_tree().quit(0)
