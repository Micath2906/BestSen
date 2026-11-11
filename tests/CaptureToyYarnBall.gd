extends Control

@onready var main = $Main

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	
	print("\n=== KIỂM THỬ THAY THẾ ASSET ĐỒ CHƠI CUỘN LEN ===")
	
	# 1. Kiểm tra Icon Đồ Chơi trên Thanh Điều Hướng (BottomPawMenu)
	var play_icon_rect = main.bottom_paw_menu.icon_play_rect
	assert(play_icon_rect != null, "Phải tìm thấy TextureRect icon Đồ Chơi!")
	assert(play_icon_rect.texture != null, "Icon Đồ Chơi phải có texture cuộn len pixel art!")
	print("✓ Icon Đồ Chơi trên BottomPawMenu đã nạp thành công:", play_icon_rect.texture.resource_path)
	
	# 2. Mở Drawer Đồ Chơi
	main.bottom_paw_menu._toggle_drawer("play")
	await get_tree().create_timer(0.4).timeout
	
	var img_drawer = get_viewport().get_texture().get_image()
	img_drawer.save_png("D:/BestSen/screenshot_bottom_paw_toy_drawer.png")
	print("✓ Đã chụp ảnh Drawer Đồ Chơi: screenshot_bottom_paw_toy_drawer.png")
	
	# 3. Kích hoạt thả cuộn len ra sàn phòng trọ
	main.bottom_paw_menu.close_drawer()
	await get_tree().create_timer(0.2).timeout
	
	var room_view = main.current_view_node
	assert(room_view != null, "Phải đang ở IsometricRoomView!")
	room_view.play_activity("yarn_ball")
	await get_tree().create_timer(0.35).timeout
	
	assert(room_view.toy_item.visible == true, "Cuộn len phải xuất hiện trên sàn!")
	assert(room_view.toy_sprite.visible == true, "ToySprite phải hiển thị!")
	assert(room_view.toy_sprite.texture != null, "ToySprite phải có texture cuộn len!")
	print("✓ Cuộn len đã rơi nảy trên sàn và Boss mèo đang lao tới vồ bắt!")
	
	var img_drop = get_viewport().get_texture().get_image()
	img_drop.save_png("D:/BestSen/screenshot_room_toy_yarn_drop.png")
	print("✓ Đã chụp ảnh Cuộn len trên sàn phòng: screenshot_room_toy_yarn_drop.png")
	
	# Đợi Boss vồ xong cuộn len
	await get_tree().create_timer(1.2).timeout
	
	# 4. Chuyển sang Cửa Hàng - Tab Đồ Chơi
	main.switch_to_shop("toys")
	await get_tree().create_timer(0.4).timeout
	
	var shop_view = main.current_view_node
	assert(shop_view != null and shop_view.current_main_cat == "toys", "Phải đang mở tab Đồ Chơi trong Shop!")
	
	# Tìm sản phẩm Cuộn Len để preview trên sân khấu
	var yarn_item = GameManager.get_shop_item("t_ball_rainbow")
	if yarn_item.is_empty():
		yarn_item = GameManager.get_shop_item("t_yarn_ball")
			
	assert(not yarn_item.is_empty(), "Phải tìm thấy sản phẩm Cuộn Len trong Shop!")
	shop_view._render_furniture_stage(yarn_item)
	await get_tree().create_timer(0.3).timeout
	
	assert(shop_view.furn_sprite.visible == true, "Sân khấu phải hiển thị sprite cuộn len!")
	assert(shop_view.furn_sprite.texture != null, "furn_sprite phải có texture cuộn len!")
	print("✓ Sân khấu ShopView hiển thị Cuộn Len với hiệu ứng squash & stretch!")
	
	var img_shop_stage = get_viewport().get_texture().get_image()
	img_shop_stage.save_png("D:/BestSen/screenshot_shop_toy_yarn_stage.png")
	print("✓ Đã chụp ảnh ShopView Sân Khấu Cuộn Len: screenshot_shop_toy_yarn_stage.png")
	
	# Mở chi tiết sản phẩm Cuộn Len
	shop_view._open_detail(yarn_item)
	await get_tree().create_timer(0.3).timeout
	
	var img_shop_detail = get_viewport().get_texture().get_image()
	img_shop_detail.save_png("D:/BestSen/screenshot_shop_toy_yarn_detail.png")
	print("✓ Đã chụp ảnh Modal Chi Tiết Cuộn Len: screenshot_shop_toy_yarn_detail.png")
	
	print("\n=== TOÀN BỘ KIỂM THỬ ĐỒ CHƠI CUỘN LEN THÀNH CÔNG 100%! ===")
	get_tree().quit()
