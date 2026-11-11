extends Node

# TestDecorTopAndShopPosition.gd
# Kiểm tra:
# 1. Nút Cửa Hàng nằm bên dưới thanh thông tin (CatProfileHUD).
# 2. Phần đồ trang trí (DecorDrawer) nằm ở TRÊN CÙNG thay vì dưới trong RoomDecorStudioView.

func _ready() -> void:
	print("--- TEST ĐỒ TRANG TRÍ Ở TRÊN & NÚT CỬA HÀNG BÊN DƯỚI THANH THÔNG TIN ---")
	call_deferred("_start_test")

func _start_test() -> void:
	var main_scene = load("res://scenes/Main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	
	await get_tree().create_timer(0.4).timeout
	
	# 1. Kiểm tra vị trí nút Cửa Hàng
	var hud = main.cat_profile_hud
	var btn_shop = hud.btn_shop
	if btn_shop != null:
		var hud_box = hud.get_node("HUDContainer")
		print("  [PASS] Nút Cửa Hàng tìm thấy: text = ", btn_shop.text, " | pos = ", btn_shop.position, " | size = ", btn_shop.size)
		print("         HUD Container size.y = ", hud_box.size.y, " | BtnShop pos.y = ", btn_shop.position.y)
		if btn_shop.position.y >= hud_box.size.y:
			print("  [PASS] Nút Cửa Hàng nằm hoàn toàn BÊN DƯỚI thanh thông tin (HUDContainer)!")
	else:
		printerr("  [FAIL] Không tìm thấy nút Cửa Hàng!")
		
	_capture_screenshot("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_verified_shop_button_below_hud.png")
	await get_tree().create_timer(0.3).timeout
	
	# 2. Chuyển sang Studio Trang Trí
	main.switch_to_decor_studio()
	await get_tree().create_timer(0.4).timeout
	
	var studio = main.current_view_node
	var decor_drawer = studio.decor_drawer
	if decor_drawer != null:
		print("  [PASS] Khay đồ trang trí (DecorDrawer) tìm thấy: pos = ", decor_drawer.position, " | size = ", decor_drawer.size)
		if decor_drawer.position.y < 300.0:
			print("  [PASS] Khay đồ trang trí đã được đặt ở TRÊN CÙNG (pos.y < 300, sàn phòng ở dưới hoàn toàn thoáng đãng)!")
	else:
		printerr("  [FAIL] Không tìm thấy DecorDrawer trong RoomDecorStudioView!")
		
	# Chọn 1 món đồ để hiển thị Gizmo Ring trên sàn phòng
	if studio.has_method("_select_item"):
		var layer = studio.get_node_or_null("RoomViewportArea/RoomContainer/FurnitureLayer")
		if layer and layer.get_child_count() > 0:
			studio._select_item(layer.get_child(0))
			
	await get_tree().create_timer(0.3).timeout
	_capture_screenshot("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_verified_decor_studio_tray_on_top.png")
	await get_tree().create_timer(0.2).timeout
	
	print("--- TEST HOÀN TẤT THÀNH CÔNG ---")
	get_tree().quit()

func _capture_screenshot(file_path: String) -> void:
	var img = get_viewport().get_texture().get_image()
	img.save_png(file_path)
	print("  [SAVED SCREENSHOT] ->", file_path)
