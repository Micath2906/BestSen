extends Control

# CaptureFoodBagShowcase.gd
# Chụp showcase hình ảnh túi thức ăn cho mèo trong Shop và icon Cho Ăn

func _ready() -> void:
	print("\n=== BẮT ĐẦU CHỤP SHOWCASE TÚI THỨC ĂN & ICON ĂN ===")
	
	GameManager.selected_avatar_id = 0
	GameManager.fish = 181122
	
	# --- 1. CHỤP SHOP VIEW: TAB ĐỒ ĂN & SÂN KHẤU XEM TRƯỚC TÚI HẠT ---
	print("[1/3] Chụp Shop View Tab Đồ Ăn...")
	var shop = load("res://scenes/ShopView.tscn").instantiate()
	add_child(shop)
	await _wait_frames(6)
	shop._switch_main_category("food")
	await _wait_frames(8)
	var kibble_item = GameManager.get_shop_item("f_kibble_salmon")
	if not kibble_item.is_empty():
		shop._render_furniture_stage(kibble_item)
	await _wait_frames(10)
	_save_screen("screenshot_shop_food_stage.png")
	
	# --- 2. CHỤP MODAL CHI TIẾT TÚI ĐỒ ĂN TRONG SHOP ---
	print("[2/3] Chụp Modal Chi Tiết Túi Đồ Ăn...")
	if not kibble_item.is_empty():
		shop._open_detail(kibble_item)
	await _wait_frames(10)
	_save_screen("screenshot_shop_food_detail.png")
	shop.detail_modal.visible = false
	remove_child(shop)
	shop.queue_free()
	await _wait_frames(4)
	
	# --- 3. CHỤP BOTTOM DOCK MENU: ICON ĂN & DRAWER THỨC ĂN ---
	print("[3/3] Chụp Bottom Paw Menu Icon Ăn & Drawer...")
	var root_view = Control.new()
	root_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root_view)
	
	# Thêm room background để làm nền
	var bg = TextureRect.new()
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.texture = GameManager.load_texture("res://assets/furnitures/PetMobileGameAsset/PetMobileGameAsset/Backgrounds/Classic/1.png")
	root_view.add_child(bg)
	
	var paw_menu = load("res://scenes/BottomPawMenu.tscn").instantiate()
	root_view.add_child(paw_menu)
	await _wait_frames(6)
	paw_menu._toggle_drawer("food")
	await _wait_frames(10)
	_save_screen("screenshot_bottom_paw_menu_food.png")
	
	remove_child(root_view)
	root_view.queue_free()
	await _wait_frames(4)
	
	print("\n=== HOÀN THÀNH CHỤP SHOWCASE TÚI THỨC ĂN! ===")
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
