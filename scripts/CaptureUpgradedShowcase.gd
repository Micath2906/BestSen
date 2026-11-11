extends Control

# CaptureUpgradedShowcase.gd
# Chụp bộ ảnh showcase toàn diện sau khi cập nhật assets pixel-art và animation mượt mà

func _ready() -> void:
	print("\n=== BẮT ĐẦU CHỤP SHOWCASE ASSETS & ANIMATIONS MỚI ===")
	
	# Đảm bảo dữ liệu demo đẹp mắt
	GameManager.selected_avatar_id = 0 # Mèo Mướp Cam
	GameManager.set_cat_name("Mèo Mướp Béo")
	GameManager.set_room_name("Phòng của Mèo Mướp Béo")
	GameManager.hunger = 85
	GameManager.courage = 90
	GameManager.fish = 95
	
	# --- 1. CHỤP ISOMETRIC ROOM MỚI & CHI PHÍ HÀNG THÁNG ---
	print("[1/7] Chụp Isometric Room View...")
	var room = load("res://scenes/IsometricRoomView.tscn").instantiate()
	add_child(room)
	await _wait_frames(8)
	_save_screen("screenshot_new_room_view.png")
	
	# Mở Modal Chi Phí Hàng Tháng
	print("[2/7] Chụp Modal Chi Phí Hàng Tháng (KTX)...")
	room._open_monthly_expenses_modal()
	await _wait_frames(8)
	_save_screen("screenshot_new_monthly_expenses_modal.png")
	room._close_monthly_expenses_modal()
	await _wait_frames(4)
	remove_child(room)
	room.queue_free()
	await _wait_frames(4)
	
	# --- 2. CHỤP MAIN MENU VỚI CATUI CARD & SITTING CAT PLAY BUTTON ---
	print("[3/7] Chụp Main Menu...")
	var menu = load("res://scenes/MainMenu.tscn").instantiate()
	add_child(menu)
	await _wait_frames(8)
	_save_screen("screenshot_new_main_menu.png")
	
	# Mở Setting Modal để xem pixel track & wooden knob
	print("[4/7] Chụp Setting Modal...")
	menu._open_setting_modal()
	await _wait_frames(10)
	_save_screen("screenshot_new_setting_modal.png")
	menu.setting_modal.visible = false
	await _wait_frames(4)
	
	# --- 3. CHỤP CHỌN LOÀI MÈO (CHARACTER CREATION) ---
	print("[5/7] Chụp Character Creation (Chọn Mèo & Đặt Tên)...")
	menu._open_cat_creation()
	await _wait_frames(8)
	_save_screen("screenshot_new_main_menu_creation.png")
	remove_child(menu)
	menu.queue_free()
	await _wait_frames(4)
	
	# --- 4. CHỤP SHOP FITTING ROOM (MODEL MÈO 2/3 MÀN HÌNH VỚI QUẦN ÁO PIXEL) ---
	print("[6/7] Chụp Shop View Fitting Room...")
	var shop = load("res://scenes/ShopView.tscn").instantiate()
	add_child(shop)
	await _wait_frames(6)
	shop.preview_costumes["clothes"] = "c_hoodie_student"
	shop.preview_costumes["hats"] = "c_hat_cap"
	shop._render_cat_model()
	shop._render_products()
	await _wait_frames(8)
	_save_screen("screenshot_new_shop_fitting_room.png")
	
	# --- 5. CHỤP SHOP FURNITURE STAGE (XEM TRƯỚC NỘI THẤT MOBILE) ---
	print("[7/7] Chụp Shop Furniture Stage...")
	shop._switch_main_category("decor")
	await _wait_frames(6)
	var bed_blue = GameManager.get_shop_item("d_bed_mobile_blue")
	if not bed_blue.is_empty():
		shop._render_furniture_stage(bed_blue)
	await _wait_frames(8)
	_save_screen("screenshot_new_shop_furniture_stage.png")
	remove_child(shop)
	shop.queue_free()
	await _wait_frames(4)
	
	# --- 6. CHỤP HOUSE AND DRESS VIEW (SÂN KHẤU THỜI TRANG & PHÒNG TRỌ) ---
	print("[EXTRA] Chụp House & Dress View...")
	var house_dress = load("res://scenes/HouseAndDressView.tscn").instantiate()
	add_child(house_dress)
	await _wait_frames(8)
	_save_screen("screenshot_new_house_and_dress.png")
	remove_child(house_dress)
	house_dress.queue_free()
	await _wait_frames(4)
	
	print("\n=== HOÀN THÀNH CHỤP TOÀN BỘ SHOWCASE XUẤT SẮC! ===")
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
	else:
		push_error("get_viewport image is null!")
