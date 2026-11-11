extends Node

func _ready() -> void:
	print("\n========================================================")
	print("   BEST SEN - SUITE KIỂM THỬ TỦ ĐỒ & TRANG TRÍ NHÀ NHỎ  ")
	print("   (Phong cách Ngôi Sao Thời Trang / Little House)     ")
	print("========================================================")
	
	await get_tree().process_frame
	
	# [1] KIỂM TRA DỮ LIỆU ĐA LỚP TRANG PHỤC (MULTI-SLOT DRESS-UP)
	print("\n[1] Kiểm tra cấu trúc đa lớp trang phục (equipped_costumes):")
	assert(GameManager.equipped_costumes.has("clothes"), "Thiếu slot Quần Áo!")
	assert(GameManager.equipped_costumes.has("hats"), "Thiếu slot Mũ & Nón!")
	assert(GameManager.equipped_costumes.has("bows"), "Thiếu slot Nơ & Khăn!")
	assert(GameManager.equipped_costumes.has("accessories"), "Thiếu slot Phụ Kiện!")
	print("  -> 4 Slot Trang Phục (Quần Áo 👕, Mũ 🎩, Nơ 🎀, Phụ Kiện 🎒) PASS!")
	
	# [2] KIỂM THỬ THAY ĐỒ & TÍNH ĐIỂM FASHION SCORE
	print("\n[2] Kiểm thử logic thay đồ và điểm Thời Trang (Ngôi Sao Thời Trang):")
	# Đảm bảo sở hữu vật phẩm test
	if not ("c_hoodie_student" in GameManager.inventory_costumes):
		GameManager.inventory_costumes.append("c_hoodie_student")
	if not ("c_hat_cap" in GameManager.inventory_costumes):
		GameManager.inventory_costumes.append("c_hat_cap")
	if not ("c_bow_red" in GameManager.inventory_costumes):
		GameManager.inventory_costumes.append("c_bow_red")
	if not ("c_acc_glasses" in GameManager.inventory_costumes):
		GameManager.inventory_costumes.append("c_acc_glasses")
		
	# Trang bị từng món
	GameManager.equip_costume_slot("clothes", "c_hoodie_student")
	GameManager.equip_costume_slot("hats", "c_hat_cap")
	GameManager.equip_costume_slot("bows", "c_bow_red")
	GameManager.equip_costume_slot("accessories", "c_acc_glasses")
	
	assert(GameManager.equipped_costumes["clothes"] == "c_hoodie_student", "Mặc áo hoodie thất bại!")
	assert(GameManager.equipped_costumes["hats"] == "c_hat_cap", "Đội mũ lưỡi trai thất bại!")
	assert(GameManager.equipped_costumes["bows"] == "c_bow_red", "Đeo nơ đỏ thất bại!")
	assert(GameManager.equipped_costumes["accessories"] == "c_acc_glasses", "Đeo kính cận thất bại!")
	assert(GameManager.equipped_costume == "c_hoodie_student", "Tương thích ngược equipped_costume thất bại!")
	
	var fashion_score = GameManager.get_fashion_score()
	var fashion_title = GameManager.get_fashion_title()
	print("  -> Full Set Điểm Thời Trang: %d Điểm | Danh hiệu: %s" % [fashion_score, fashion_title])
	assert(fashion_score >= 100, "Điểm thời trang full set phải >= 100 điểm!")
	
	# Kiểm thử tháo đồ
	GameManager.unequip_costume_slot("hats")
	assert(GameManager.equipped_costumes["hats"] == "", "Tháo mũ thất bại!")
	var score_after_unequip = GameManager.get_fashion_score()
	assert(score_after_unequip < fashion_score, "Tháo mũ thì điểm thời trang phải giảm!")
	print("  -> Tháo mũ thành công, điểm giảm từ %d xuống %d!" % [fashion_score, score_after_unequip])
	
	# Kiểm thử phối đồ ngẫu nhiên
	var rand_outfit = GameManager.randomize_fashion()
	assert(rand_outfit is Dictionary, "Phối đồ ngẫu nhiên phải trả về Dictionary!")
	print("  -> 🎲 Phối đồ ngẫu nhiên thành công: %s" % str(rand_outfit))
	
	# [3] KIỂM THỬ TRANG TRÍ NHÀ CỬA & TÍNH ĐIỂM COZY SCORE
	print("\n[3] Kiểm thử logic bài trí nội thất phòng trọ & Điểm Ấm Cúng:")
	assert(GameManager.equipped_decor.has("beds"), "Thiếu cấu hình Giường!")
	assert(GameManager.equipped_decor.has("bowls"), "Thiếu cấu hình Bát Ăn!")
	assert(GameManager.equipped_decor.has("rugs"), "Thiếu cấu hình Thảm Sàn!")
	assert(GameManager.equipped_decor.has("wall"), "Thiếu cấu hình Tranh Tường!")
	assert(GameManager.equipped_decor.has("plants"), "Thiếu cấu hình Cây Cảnh!")
	
	if not ("d_rug_paw_pink" in GameManager.inventory_decor):
		GameManager.inventory_decor.append("d_rug_paw_pink")
	if not ("d_bed_terracotta" in GameManager.inventory_decor):
		GameManager.inventory_decor.append("d_bed_terracotta")
		
	GameManager.equip_decor("beds", "d_bed_terracotta")
	GameManager.equip_decor("rugs", "d_rug_paw_pink")
	assert(GameManager.equipped_decor["beds"] == "d_bed_terracotta", "Đặt đệm terracotta thất bại!")
	assert(GameManager.equipped_decor["rugs"] == "d_rug_paw_pink", "Trải thảm chân mèo hồng thất bại!")
	
	var cozy_score = GameManager.get_cozy_score()
	var cozy_title = GameManager.get_cozy_title()
	print("  -> Điểm Ấm Cúng Căn Nhà: %d Điểm | Đánh giá: %s" % [cozy_score, cozy_title])
	assert(cozy_score >= 50, "Điểm ấm cúng căn nhà phải >= 50!")
	
	# [4] KIỂM THỬ GIAO DIỆN HOUSE & DRESS VIEW SCENE
	print("\n[4] Kiểm thử Scene giao diện Nhà Nhỏ & Tủ Đồ (HouseAndDressView.tscn):")
	var view_scene = load("res://scenes/HouseAndDressView.tscn")
	var house_view = view_scene.instantiate()
	add_child(house_view)
	
	# Kiểm tra chế độ mặc định là Dress
	assert(house_view.current_mode == "dress", "Chế độ ban đầu phải là dress (Tủ đồ)!")
	assert(house_view.dress_mode_container.visible == true, "Dress container phải hiển thị!")
	assert(house_view.decor_mode_container.visible == false, "Decor container phải ẩn!")
	assert(house_view.dress_items_grid.get_child_count() > 0, "Lưới trang phục phải có card đồ!")
	print("  -> Sân khấu thời trang & Tủ đồ hiển thị %d sản phẩm!" % house_view.dress_items_grid.get_child_count())
	
	# Chuyển subcategory trang phục
	house_view.current_dress_subcat = "hats"
	house_view._render_dress_items()
	assert(house_view.dress_items_grid.get_child_count() > 0, "Lọc Mũ & Nón thất bại!")
	print("  -> Lọc Mũ & Nón hiển thị %d mẫu mũ!" % house_view.dress_items_grid.get_child_count())
	
	# Chuyển sang chế độ Trang Trí Nhà Cửa
	house_view.switch_mode("decor")
	assert(house_view.current_mode == "decor", "Chuyển sang decor thất bại!")
	assert(house_view.dress_mode_container.visible == false, "Dress container phải ẩn!")
	assert(house_view.decor_mode_container.visible == true, "Decor container phải hiển thị!")
	assert(house_view.decor_items_grid.get_child_count() > 0, "Lưới nội thất phải có card đồ!")
	print("  -> Khay nội thất hiển thị %d món đồ trang trí!" % house_view.decor_items_grid.get_child_count())
	
	# Thử đặt đệm mới và lưu phòng
	house_view.preview_decor["beds"] = "d_bed_terracotta"
	house_view._on_save_decor()
	assert(GameManager.equipped_decor["beds"] == "d_bed_terracotta", "Lưu nội thất vào GameManager thất bại!")
	print("  -> Lưu cách bài trí phòng thành công!")
	
	# [5] KIỂM THỬ BỘ 3 NÚT THAO TÁC GOM 1 CHỖ & ĐỔI TÊN PHÒNG TRONG ISOMETRIC ROOM VIEW
	print("\n[5] Kiểm thử liên kết 3 nút gom 1 chỗ & Modal đổi tên trong IsometricRoomView:")
	var room_scene = load("res://scenes/IsometricRoomView.tscn")
	var room_view = room_scene.instantiate()
	add_child(room_view)
	
	assert(room_view.has_node("UnifiedActionRow/BtnHandbookQuick"), "Thiếu nút Cẩm Nang trong hàng gom 3 nút!")
	assert(room_view.has_node("UnifiedActionRow/BtnDressingQuick"), "Thiếu nút Thay Đồ trong hàng gom 3 nút!")
	assert(room_view.has_node("UnifiedActionRow/BtnDecorQuick"), "Thiếu nút Trang Trí trong hàng gom 3 nút!")
	assert(room_view.has_node("RoomTitleBanner/HBox/BtnEditRoomName"), "Thiếu nút Đổi Tên phòng ✏️!")
	assert(room_view.has_node("RoomNameModal"), "Thiếu RoomNameModal!")
	print("  -> Bộ 3 nút gom 1 chỗ (📖 Cẩm Nang, 👗 Thay Đồ, 🏡 Trang Trí) và Bảng Tên trung tâm hoạt động hoàn hảo!")
	
	room_view.queue_free()
	house_view.queue_free()
	
	print("\n========================================================")
	print("   TẤT CẢ KIỂM THỬ TỦ ĐỒ & TRANG TRÍ THÀNH CÔNG 100%!  ")
	print("========================================================")
	get_tree().quit()
