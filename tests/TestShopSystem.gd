extends Node

func _ready() -> void:
	print("\n========================================================")
	print("       BEST SEN - SUITE KIỂM THỬ CỬA HÀNG & PHÂN MỤC   ")
	print("========================================================")
	
	await get_tree().process_frame
	
	# [1] KIỂM TRA DỮ LIỆU SHOP CATALOG TỪ JSON
	print("\n[1] Kiểm tra nạp shop_catalog.json:")
	assert(GameManager.shop_catalog_data.has("main_categories"), "Phải có danh sách main_categories!")
	assert(GameManager.shop_catalog_data.has("items"), "Phải có danh sách items!")
	
	var main_cats = GameManager.shop_catalog_data["main_categories"]
	assert(main_cats.size() == 4, "Phải có đúng 4 danh mục chính (Trang phục, Trang trí, Đồ chơi, Đồ ăn)!")
	
	var cat_ids = []
	for c in main_cats:
		cat_ids.append(c["id"])
	assert("costumes" in cat_ids, "Thiếu danh mục Trang phục!")
	assert("decor" in cat_ids, "Thiếu danh mục Trang trí!")
	assert("toys" in cat_ids, "Thiếu danh mục Đồ chơi!")
	assert("food" in cat_ids, "Thiếu danh mục Đồ ăn!")
	print("  -> 4 Danh Mục Chính: Trang Phục 👔, Trang Trí 🏡, Đồ Chơi 🧸, Đồ Ăn 🐟 PASS!")
	
	# [2] KIỂM TRA PHÂN NHÓM CON (SUBCATEGORIES)
	print("\n[2] Kiểm tra phân nhóm chi tiết từng danh mục:")
	for c in main_cats:
		var sub_ids = []
		for sub in c["subcategories"]:
			sub_ids.append(sub["id"])
		print("  + [%s]: %s" % [c["name"], str(sub_ids)])
		match c["id"]:
			"costumes":
				assert("clothes" in sub_ids and "hats" in sub_ids and "bows" in sub_ids and "accessories" in sub_ids, "Thiếu subcat trong Trang phục!")
			"decor":
				assert("beds" in sub_ids and "bowls" in sub_ids and "rugs" in sub_ids and "wall" in sub_ids and "plants" in sub_ids, "Thiếu subcat trong Trang trí!")
			"toys":
				assert("wands" in sub_ids and "balls" in sub_ids and "scratchers" in sub_ids and "boxes" in sub_ids, "Thiếu subcat trong Đồ chơi!")
			"food":
				assert("kibble" in sub_ids and "pate" in sub_ids and "treats" in sub_ids and "catnip" in sub_ids, "Thiếu subcat trong Đồ ăn!")
				
	print("  -> Toàn bộ phân nhóm chi tiết (Quần áo, Mũ, Nơ, Giường, Bát ăn, Cần câu, Pate...) PASS 100%!")
	
	# [3] KIỂM TRA DANH SÁCH SẢN PHẨM (ITEMS)
	var items = GameManager.shop_catalog_data["items"]
	assert(items.size() >= 25, "Cần có tối thiểu 25 sản phẩm đa dạng trong tiệm tạp hóa!")
	print("\n[3] Tổng số sản phẩm trong shop: %d món" % items.size())
	for it in items:
		assert(it.has("id") and it.has("name") and it.has("category") and it.has("subcategory"), "Sản phẩm thiếu trường dữ liệu cốt lõi!")
		assert(it.has("price") and it["price"] >= 0, "Giá sản phẩm phải >= 0 Cá Khô!")
		assert(it.has("desc") and it["desc"] != "", "Sản phẩm thiếu mô tả sinh viên!")
		
	# [4] KIỂM THỬ LOGIC MUA SẮM & NỀN KINH TẾ CÁ KHÔ
	print("\n[4] Kiểm thử logic mua hàng & trừ tiền Cá Khô:")
	var init_fish = GameManager.fish
	var test_item_id = "c_hoodie_student" # Giá 25 Cá, yêu cầu Level 1
	var item_data = GameManager.get_shop_item(test_item_id)
	
	# Đảm bảo reset trạng thái kiểm thử cho item test
	if test_item_id in GameManager.inventory_costumes:
		GameManager.inventory_costumes.erase(test_item_id)
	GameManager.cat_mastery_level = 1
	GameManager.fish = 100
	
	var buy_res = GameManager.buy_shop_item(test_item_id)
	assert(buy_res["ok"] == true, "Mua vật phẩm hợp lệ thất bại: " + buy_res.get("reason", ""))
	assert(GameManager.fish == 75, "Trừ Cá Khô không chính xác (100 - 25 = 75)!")
	assert(GameManager.is_item_owned(test_item_id) == true, "Vật phẩm chưa được thêm vào kho đồ!")
	assert(GameManager.equipped_costume == test_item_id, "Áo chưa được tự động trang bị!")
	print("  -> Mua Áo Hoodie Sinh Viên thành công: Cá Khô còn 75 🐟, đã trang bị!")
	
	# Mua lại món đã sở hữu (phải báo lỗi)
	var duplicate_buy = GameManager.buy_shop_item(test_item_id)
	assert(duplicate_buy["ok"] == false, "Không được cho phép mua trùng trang phục vĩnh viễn!")
	print("  -> Chống mua trùng trang phục / đồ decor thành công!")
	
	# Thử mua món vượt cấp level (Cần Cấp 4 khi đang Cấp 1)
	GameManager.cat_mastery_level = 1
	var locked_item_id = "c_grad_robe" # Áo cử nhân cần cấp 4
	var locked_buy = GameManager.buy_shop_item(locked_item_id)
	assert(locked_buy["ok"] == false, "Không được mua vật phẩm bị khóa theo Cat Mastery Level!")
	print("  -> Kiểm tra giới hạn Level thăng cấp mua sắm thành công!")
	
	# Mua đồ ăn kiểm tra hồi phục chỉ số
	var old_hunger = GameManager.hunger
	GameManager.fish = 50
	var food_res = GameManager.buy_shop_item("f_pate_tuna")
	assert(food_res["ok"] == true, "Mua pate cá ngừ thất bại!")
	assert(GameManager.hunger >= old_hunger, "Ăn pate phải tăng Độ No!")
	print("  -> Mua đồ ăn thưởng thức tăng chỉ số thành công: No = %d/100!" % GameManager.hunger)
	
	# [5] KIỂM THỬ SCENE GIAO DIỆN SHOPVIEW
	print("\n[5] Kiểm thử khởi tạo giao diện ShopView:")
	var shop_scene = load("res://scenes/ShopView.tscn")
	var shop_view = shop_scene.instantiate()
	add_child(shop_view)
	
	# Kiểm tra tab Trang phục
	assert(shop_view.current_main_cat == "costumes", "Tab mặc định phải là Trang Phục!")
	assert(shop_view.products_grid.get_child_count() > 0, "Lưới sản phẩm phải hiển thị các card!")
	print("  -> Danh mục Trang Phục hiển thị %d sản phẩm!" % shop_view.products_grid.get_child_count())
	
	# Chuyển sang danh mục Trang Trí
	shop_view._switch_main_category("decor")
	assert(shop_view.current_main_cat == "decor", "Chuyển sang tab Trang Trí thất bại!")
	print("  -> Chuyển sang Trang Trí: %d sản phẩm nội thất!" % shop_view.products_grid.get_child_count())
	
	# Lọc theo subcategory "plants" (Cây cảnh)
	shop_view._switch_sub_category("plants")
	assert(shop_view.current_sub_cat == "plants", "Lọc subcategory Cây Cảnh thất bại!")
	print("  -> Lọc subcategory Cây Cảnh hiển thị: %d chậu cây!" % shop_view.products_grid.get_child_count())
	
	# Mở Modal Chi Tiết
	shop_view._open_detail(item_data)
	assert(shop_view.detail_modal.visible == true, "Modal chi tiết phải mở ra!")
	assert("Áo Hoodie Sinh Viên" in shop_view.detail_title.text, "Tiêu đề modal chi tiết không khớp!")
	print("  -> Modal xem chi tiết sản phẩm hoạt động hoàn hảo!")
	
	# Khôi phục Cá Khô ban đầu
	GameManager.fish = init_fish
	
	print("\n========================================================")
	print("   TẤT CẢ KIỂM THỬ CỬA HÀNG THÀNH CÔNG 100%!           ")
	print("========================================================")
	get_tree().quit()
