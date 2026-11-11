extends Control

@onready var main = $Main

func _ready() -> void:
	await get_tree().create_timer(0.8).timeout
	
	# 1. Chuyển sang Cửa hàng (ShopView)
	main.switch_to_shop()
	await get_tree().create_timer(0.6).timeout
	
	var shop_view = main.current_view_node
	
	# Chụp 1: ShopView mặc định - Danh mục Trang Phục & Subcategories
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("D:/BestSen/screenshot_shop_costumes.png")
	print("Captured: screenshot_shop_costumes.png")
	
	# Chụp 2: Chuyển sang Trang Trí Nhà Cửa, lọc Cây cảnh hoặc Giường đệm
	if shop_view and shop_view.has_method("_switch_main_category"):
		shop_view._switch_main_category("decor")
		await get_tree().create_timer(0.4).timeout
		shop_view._switch_sub_category("beds")
		await get_tree().create_timer(0.4).timeout
		
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("D:/BestSen/screenshot_shop_decor.png")
	print("Captured: screenshot_shop_decor.png")
	
	# Chụp 3: Chuyển sang Đồ Ăn Cho Mèo, mở Modal Xem Chi Tiết
	if shop_view and shop_view.has_method("_switch_main_category"):
		shop_view._switch_main_category("food")
		await get_tree().create_timer(0.4).timeout
		var pate_item = GameManager.get_shop_item("f_pate_salmon")
		if pate_item.is_empty():
			pate_item = GameManager.get_shop_item("f_pate_tuna")
		if not pate_item.is_empty():
			shop_view._open_detail(pate_item)
			await get_tree().create_timer(0.4).timeout
			
	var img3 = get_viewport().get_texture().get_image()
	img3.save_png("D:/BestSen/screenshot_shop_food_detail.png")
	print("Captured: screenshot_shop_food_detail.png")
	
	print("ALL SHOP SCREENSHOTS CAPTURED!")
	get_tree().quit()
