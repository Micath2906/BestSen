extends Control

const ARTIFACT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/"

func _ready() -> void:
	print(">>> BẮT ĐẦU CHỤP ẢNH MINH CHỨNG YÊU CẦU 10 (FINAL QUALITY) <<<")
	
	# [1] CHỤP CAT PROFILE HUD VỚI AVATAR MOCHI KHỚP KHUNG & CẤP ĐỘ MÈO
	GameManager.selected_avatar_id = 8 # Mochi (White-DifferentEyes)
	GameManager.selected_avatar_frame = "beige"
	GameManager.cat_mastery_level = 1
	
	var hud_scene = load("res://scenes/CatProfileHUD.tscn")
	var hud = hud_scene.instantiate()
	add_child(hud)
	hud.size = Vector2(540, 100)
	hud.position = Vector2(0, 40)
	hud.update_avatar()
	hud.update_hud()
	
	await get_tree().create_timer(0.5).timeout
	var img_hud = get_viewport().get_texture().get_image()
	img_hud.save_png(ARTIFACT_DIR + "screenshot_hud_level_mochi.png")
	
	# Crop riêng khu vực avatar & cấp độ (Avatar 56x56 + LevelBadge bên dưới)
	var crop_av = img_hud.get_region(Rect2i(55, 42, 95, 96))
	crop_av.save_png(ARTIFACT_DIR + "screenshot_avatar_and_level_closeup.png")
	print("Đã chụp: screenshot_avatar_and_level_closeup.png")
	hud.queue_free()
	
	# [2] CHỤP MENU CÀI ĐẶT HỆ THỐNG MỚI (SETTING MODAL)
	var menu_scene = load("res://scenes/MainMenu.tscn")
	var menu = menu_scene.instantiate()
	add_child(menu)
	menu.get_node("HomeView").visible = false
	menu.get_node("SettingModal").visible = true
	
	await get_tree().create_timer(0.5).timeout
	var img_setting = get_viewport().get_texture().get_image()
	var crop_set = img_setting.get_region(Rect2i(75, 230, 390, 520))
	crop_set.save_png(ARTIFACT_DIR + "screenshot_setting_modal_new.png")
	print("Đã chụp: screenshot_setting_modal_new.png")
	menu.queue_free()
	
	# [3] CHỤP MENU TẠM DỪNG TRÒ CHƠI MỚI (PAUSE MODAL)
	var pause_scene = load("res://scenes/PauseModal.tscn")
	var pause = pause_scene.instantiate()
	add_child(pause)
	pause.open()
	
	await get_tree().create_timer(0.5).timeout
	var img_pause = get_viewport().get_texture().get_image()
	var crop_pause = img_pause.get_region(Rect2i(75, 260, 390, 480))
	crop_pause.save_png(ARTIFACT_DIR + "screenshot_pause_modal_new.png")
	print("Đã chụp: screenshot_pause_modal_new.png")
	pause.queue_free()
	
	# [4] CHỤP TOÀN CẢNH PHÒNG CLASSIC VỚI MOCHI, POCHI VÀ NỘI THẤT ĐƠN GIẢN
	GameManager.set_classic_bg(1)
	var room_scene = load("res://scenes/IsometricRoomView.tscn")
	var room = room_scene.instantiate()
	add_child(room)
	
	await get_tree().create_timer(0.6).timeout
	var img_room = get_viewport().get_texture().get_image()
	img_room.save_png(ARTIFACT_DIR + "screenshot_classic_room_mochi_pochi.png")
	print("Đã chụp: screenshot_classic_room_mochi_pochi.png")
	room.queue_free()
	
	print(">>> HOÀN THÀNH TẤT CẢ 4 ẢNH CHỤP MINH CHỨNG! <<<")
	get_tree().quit(0)
