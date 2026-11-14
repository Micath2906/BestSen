extends Node

const OUTPUT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d"

func _ready() -> void:
	print("[CaptureShopShowcase] Starting visual captures for Shop...")
	_run()

func _run() -> void:
	GameManager.fish = 500
	GameManager.cat_mastery_level = 3
	
	var shop_scene = preload("res://scenes/ShopView.tscn")
	var shop_view = shop_scene.instantiate()
	add_child(shop_view)
	shop_view.custom_minimum_size = Vector2(540, 960)
	shop_view.size = Vector2(540, 960)
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	
	# 1. Capture Costumes Tab with fitting preview
	var hat_item = GameManager.get_shop_item("c_hat_bunny")
	var clothes_item = GameManager.get_shop_item("c_hoodie_student")
	shop_view._try_on_costume(hat_item)
	shop_view._try_on_costume(clothes_item)
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_shop_costumes_fitting.png")
	print("Captured: verify_shop_costumes_fitting.png")
	
	# 2. Capture Food Tab with delicious drawn sprites
	shop_view._switch_main_category("food")
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_shop_food_category.png")
	print("Captured: verify_shop_food_category.png")
	
	# 3. Capture Decor Tab
	shop_view._switch_main_category("decor")
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_shop_decor_category.png")
	print("Captured: verify_shop_decor_category.png")
	
	# 4. Capture Detail Modal for a Food item with dialogue & buff badges
	var tuna_item = GameManager.get_shop_item("f_pate_tuna")
	shop_view._open_detail(tuna_item)
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_shop_item_detail_modal.png")
	print("Captured: verify_shop_item_detail_modal.png")
	
	shop_view.queue_free()
	print("[CaptureShopShowcase] ALL CAPTURES FINISHED!")
	get_tree().quit(0)

func _save_viewport(path: String) -> void:
	var vp = get_viewport()
	if not vp: return
	var tex = vp.get_texture()
	if not tex: return
	var img = tex.get_image()
	if not img: return
	img.save_png(path)
