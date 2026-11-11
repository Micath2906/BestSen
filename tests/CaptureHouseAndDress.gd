extends Control

@onready var main = $Main

func _ready() -> void:
	await get_tree().create_timer(0.8).timeout
	
	# 1. Chụp màn hình phòng Isometric với các nút Quick Action mới và đồ trang trí
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("D:/BestSen/screenshot_isometric_room_updated.png")
	print("Captured: screenshot_isometric_room_updated.png")
	
	# 2. Mở Tủ Đồ Ngôi Sao (Dressing Room)
	main.switch_to_house_dress("dress")
	await get_tree().create_timer(0.6).timeout
	
	var house_view = main.current_view_node
	# Mặc set đồ đẹp cho Boss để showcase
	GameManager.equip_costume_slot("clothes", "c_hoodie_student")
	GameManager.equip_costume_slot("hats", "c_hat_cap")
	GameManager.equip_costume_slot("bows", "c_bow_red")
	GameManager.equip_costume_slot("accessories", "c_acc_glasses")
	if house_view and house_view.has_method("_sync_from_game_manager"):
		house_view._sync_from_game_manager()
	await get_tree().create_timer(0.4).timeout
	
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("D:/BestSen/screenshot_dressing_room.png")
	print("Captured: screenshot_dressing_room.png")
	
	# 3. Chuyển sang Trang Trí Nhà Cửa (Room Decorator)
	if house_view and house_view.has_method("switch_mode"):
		house_view.switch_mode("decor")
		await get_tree().create_timer(0.5).timeout
		
	var img3 = get_viewport().get_texture().get_image()
	img3.save_png("D:/BestSen/screenshot_room_decor.png")
	print("Captured: screenshot_room_decor.png")
	
	print("ALL HOUSE & DRESS SCREENSHOTS CAPTURED!")
	get_tree().quit()
