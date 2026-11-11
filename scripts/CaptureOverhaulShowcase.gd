extends Control

# CaptureOverhaulShowcase.gd
# Chụp bộ ảnh showcase giao diện Main Menu mới, Khung Avatar Tai Mèo & Phòng Classic 2D

func _ready() -> void:
	print("\n=== BẮT ĐẦU CHỤP SHOWCASE GIAO DIỆN MỚI & PHÒNG CLASSIC ===")
	
	GameManager.selected_avatar_id = 0 # Mèo Mướp Cam
	GameManager.set_cat_name("Mèo Mướp Béo")
	GameManager.set_room_name("Phòng của Mèo Mướp Béo")
	GameManager.hunger = 85
	GameManager.courage = 90
	GameManager.fish = 181122 # Số đồng vàng như trong mẫu Image 2
	GameManager.selected_avatar_frame = "beige"
	GameManager.selected_classic_bg_id = 1
	
	# --- 1. CHỤP MAIN MENU MỚI (Card tai mèo Be, 3 nút PLAY, SETTINGS, EXIT) ---
	print("[1/5] Chụp Main Menu...")
	var menu = load("res://scenes/MainMenu.tscn").instantiate()
	add_child(menu)
	await _wait_frames(10)
	_save_screen("screenshot_new_main_menu.png")
	remove_child(menu)
	menu.queue_free()
	await _wait_frames(4)
	
	# --- 2. CHỤP CĂN PHÒNG BACKGROUND CLASSIC 2D #1 ---
	print("[2/5] Chụp Căn Phòng Classic 2D #1...")
	var room = load("res://scenes/IsometricRoomView.tscn").instantiate()
	add_child(room)
	# Thêm HUD lên đầu phòng để xem sự kết hợp hoàn hảo giữa HUD và Background
	var hud = load("res://scenes/CatProfileHUD.tscn").instantiate()
	hud.position = Vector2(0, 16)
	room.add_child(hud)
	await _wait_frames(12)
	_save_screen("screenshot_new_classic_room.png")
	
	# --- 3. CHỤP CĂN PHÒNG CLASSIC 2D ĐỔI BACKGROUND KHÁC (#5) ---
	print("[3/5] Chụp Căn Phòng Classic 2D #5...")
	GameManager.set_classic_bg(5)
	await _wait_frames(10)
	_save_screen("screenshot_new_classic_room_alt.png")
	GameManager.set_classic_bg(1)
	
	# --- 4. CHỤP MODAL TÙY BIẾN KHUNG AVATAR TAI MÈO (TAB KHUNG) ---
	print("[4/5] Chụp AvatarPickerModal Tab Khung Tai Mèo...")
	var modal = load("res://scenes/AvatarPickerModal.tscn").instantiate()
	room.add_child(modal)
	modal.open()
	modal._switch_tab("frames")
	await _wait_frames(10)
	_save_screen("screenshot_new_avatar_picker_frames.png")
	
	# --- 5. CHỤP MODAL TÙY BIẾN KHUNG AVATAR (TAB LOÀI MÈO) ---
	print("[5/5] Chụp AvatarPickerModal Tab Loài Mèo...")
	modal._switch_tab("avatars")
	await _wait_frames(10)
	_save_screen("screenshot_new_avatar_picker_cats.png")
	
	remove_child(room)
	room.queue_free()
	await _wait_frames(4)
	
	print("\n=== HOÀN TẤT CHỤP BỘ ẢNH SHOWCASE! ===")
	get_tree().quit(0)

func _wait_frames(count: int) -> void:
	for i in range(count):
		await get_tree().process_frame

func _save_screen(filename: String) -> void:
	var img = get_viewport().get_texture().get_image()
	if img != null:
		var project_path = "res://" + filename
		var global_path = ProjectSettings.globalize_path(project_path)
		img.save_png(global_path)
		print("  -> Đã lưu ảnh: %s" % global_path)
		
		# Copy sang thư mục artifact để user xem trực quan
		var artifact_path = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/" + filename
		img.save_png(artifact_path)
		print("  -> Đã lưu artifact: %s" % artifact_path)
	else:
		push_error("get_viewport image is null!")
