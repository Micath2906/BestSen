extends Control

@onready var main = $Main

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	
	# Đảm bảo kho thức ăn có số lượng chuẩn để showcase
	GameManager.food_inventory = {
		"kibble": 5,
		"pate": 2,
		"dry_fish": 3
	}
	
	# 1. Mở drawer "Cho Ăn"
	main.bottom_paw_menu._toggle_drawer("food")
	await get_tree().create_timer(0.4).timeout
	
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("D:/BestSen/screenshot_food_drawer_inventory.png")
	print("Captured: screenshot_food_drawer_inventory.png")
	
	# 2. Giả lập hết Pate (pate = 0) và hết Hạt (kibble = 0) để kiểm tra trạng thái hết hàng
	GameManager.food_inventory["pate"] = 0
	main.bottom_paw_menu._build_drawer_content("food")
	await get_tree().create_timer(0.3).timeout
	
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("D:/BestSen/screenshot_food_drawer_out_of_stock.png")
	print("Captured: screenshot_food_drawer_out_of_stock.png")
	
	# 3. Thử chạm vào nút Pate đã hết (phải chuyển hướng sang Cửa Hàng - Tab Đồ Ăn)
	var pate_card = main.bottom_paw_menu.drawer_content.get_child(1) # nút thứ 2 là pate
	assert(pate_card != null, "Phải tìm thấy thẻ Pate!")
	pate_card.emit_signal("pressed")
	await get_tree().create_timer(0.4).timeout
	
	assert(main.current_tab_name == "shop", "Phải tự động chuyển sang Shop!")
	var shop_view = main.current_view_node
	assert(shop_view != null and shop_view.current_main_cat == "food", "Shop phải mở sẵn tab Đồ Ăn (food)!")
	print("Redirect to shop food tab: PASS!")
	
	var img3 = get_viewport().get_texture().get_image()
	img3.save_png("D:/BestSen/screenshot_shop_redirected_from_empty_food.png")
	print("Captured: screenshot_shop_redirected_from_empty_food.png")
	
	print("ALL FOOD DRAWER TESTS PASSED!")
	get_tree().quit()
