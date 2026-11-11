extends Control

# CaptureUpdatedHUDAndTools.gd - Tự động chụp lại toàn bộ HUD và thanh công cụ đã thay thế icon bằng asset
func _ready() -> void:
	await get_tree().create_timer(0.4).timeout
	print("\n=== BẮT ĐẦU CHỤP SHOWCASE GIAO DIỆN HUD & THANH CÔNG CỤ MỚI ===")
	
	var main_scene = load("res://scenes/Main.tscn")
	var main_node = main_scene.instantiate()
	add_child(main_node)
	await get_tree().create_timer(0.6).timeout
	
	# 1. Chụp toàn cảnh phòng trọ với HUD và công cụ mới
	var img_full = get_viewport().get_texture().get_image()
	img_full.save_png("D:/BestSen/screenshot_updated_hud_full.png")
	print("✓ Đã chụp toàn cảnh: screenshot_updated_hud_full.png")
	
	# 2. Cắt cúp vùng đỉnh đầu (HUD + Banner + Quick Actions + Monthly Expenses)
	# Từ y = 0 đến y = 260
	var crop_rect = Rect2i(0, 0, img_full.get_width(), 260)
	var img_crop = img_full.get_region(crop_rect)
	img_crop.save_png("D:/BestSen/screenshot_updated_hud_tools_closeup.png")
	print("✓ Đã chụp cận cảnh HUD & Tools: screenshot_updated_hud_tools_closeup.png")
	
	# 3. Đổi avatar sang bé mèo khác và khung khác để kiểm tra tính linh hoạt
	GameManager.set_avatar(1)
	GameManager.set_avatar_frame("pink")
	await get_tree().create_timer(0.4).timeout
	
	var img_pink = get_viewport().get_texture().get_image()
	var img_pink_crop = img_pink.get_region(crop_rect)
	img_pink_crop.save_png("D:/BestSen/screenshot_updated_hud_pink_frame.png")
	print("✓ Đã chụp khung hồng + avatar khác: screenshot_updated_hud_pink_frame.png")
	
	# Reset về ban đầu
	GameManager.set_avatar(0)
	GameManager.set_avatar_frame("beige")
	
	print("\n=== HOÀN TẤT CHỤP SHOWCASE 100%! ===")
	get_tree().quit()
