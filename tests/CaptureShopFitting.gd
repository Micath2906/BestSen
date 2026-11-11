extends Control

@onready var main = $Main

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	
	# Chuyển vào cửa hàng
	main.switch_to_shop()
	await get_tree().create_timer(0.4).timeout
	
	# Kiểm tra CatProfileHUD đã bị ẩn hoàn toàn
	assert(main.cat_profile_hud.visible == false, "CatProfileHUD phải bị ẩn khi vào cửa hàng!")
	print("CatProfileHUD hidden verification: PASS!")
	
	var shop_view = main.current_view_node
	assert(shop_view != null, "ShopView phải đang active!")
	assert(shop_view.has_node("FittingStage"), "Phải có FittingStage chiếm 2/3 màn hình!")
	
	# 1. Chụp màn hình ShopView ban đầu: Model mèo 2/3 màn hình, không có CatProfileHUD
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("D:/BestSen/screenshot_shop_fitting_stage_default.png")
	print("Captured: screenshot_shop_fitting_stage_default.png")
	
	# 2. Thử mặc set đồ mới (Mũ Tai Bèo hoặc Mũ Lưỡi Trai + Nơ Đỏ + Kính Mát)
	var cap_item = GameManager.get_shop_item("c_hat_cap")
	var bow_item = GameManager.get_shop_item("c_bow_red")
	var glass_item = GameManager.get_shop_item("c_glasses_smart")
	
	shop_view._try_on_costume(cap_item)
	shop_view._try_on_costume(bow_item)
	shop_view._try_on_costume(glass_item)
	await get_tree().create_timer(0.4).timeout
	
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("D:/BestSen/screenshot_shop_try_on_outfit.png")
	print("Captured: screenshot_shop_try_on_outfit.png")
	
	# 3. Chuyển sang mục Đồ Ăn (Food)
	shop_view._switch_main_category("food")
	await get_tree().create_timer(0.4).timeout
	
	var img3 = get_viewport().get_texture().get_image()
	img3.save_png("D:/BestSen/screenshot_shop_food_category.png")
	print("Captured: screenshot_shop_food_category.png")
	
	# 4. Kiểm tra quay lại phòng: CatProfileHUD hiển thị lại
	main.switch_to_room()
	await get_tree().create_timer(0.3).timeout
	assert(main.cat_profile_hud.visible == true, "CatProfileHUD phải hiện lại khi về phòng!")
	print("CatProfileHUD restored when back to room: PASS!")
	
	print("ALL SHOP FITTING TESTS & CAPTURES PASSED!")
	get_tree().quit()
