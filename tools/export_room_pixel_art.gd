extends SceneTree

func _init() -> void:
	print("--- EXPORTING ROOM PIXEL ART ITEMS ---")
	var path_furn = "res://assets/CatMegaFree/CatRoomFree/Furnitures.png"
	var img = Image.load_from_file(path_furn)
	
	var out_dir = "res://assets/sprites/room_items"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	
	# Định nghĩa các tọa độ chuẩn từ kết quả flood-fill:
	var items = {
		# Đệm ngủ mèo (Plush Beds)
		"cushion_bed": Rect2i(202, 235, 110, 82),      # Terracotta/Pink ấm cúng
		"cushion_bed_blue": Rect2i(202, 137, 110, 82), # Blue cushion
		"cushion_bed_green": Rect2i(329, 235, 110, 82),# Sage green cushion
		
		# Cây cào móng sisal (Scratch post / Cat tree)
		"scratch_post": Rect2i(191, 16, 64, 110),
		
		# Bát ăn và bát nước
		"bowl_food": Rect2i(395, 335, 43, 37),  # Bát hạt gốm vàng nhạt
		"bowl_water": Rect2i(460, 335, 43, 37), # Bát nước gốm xanh trong
		
		# Cây cảnh decor
		"potted_plant": Rect2i(140, 298, 45, 108), # Cây bàng Singapore chậu gốm
		"bonsai_pot": Rect2i(132, 225, 23, 29),     # Chậu bonsai nhỏ
		
		# Cửa sổ & Tranh treo tường
		"window_iso": Rect2i(19, 0, 61, 95),       # Khung cửa sổ đón nắng
		"wall_art": Rect2i(460, 194, 39, 89),      # Tranh treo tường cây lá
		"bookshelf": Rect2i(14, 288, 100, 128),    # Kệ sách gỗ 3 tầng sinh viên
		"water_fountain": Rect2i(197, 331, 55, 77) # Đài phun nước
	}
	
	for key in items:
		var r: Rect2i = items[key]
		var crop = Image.create(r.size.x, r.size.y, false, Image.FORMAT_RGBA8)
		crop.blit_rect(img, r, Vector2i(0, 0))
		var file_path = "%s/%s.png" % [out_dir, key]
		crop.save_png(file_path)
		print("Saved %s -> %s (%dx%d)" % [key, file_path, r.size.x, r.size.y])
		
	# Tạo khay đôi (Dual Tray) ghép 2 bát ăn & nước trên 1 tấm đế gỗ isometric
	var bowl_food = Image.create(43, 37, false, Image.FORMAT_RGBA8)
	bowl_food.blit_rect(img, Rect2i(395, 335, 43, 37), Vector2i(0, 0))
	var bowl_water = Image.create(43, 37, false, Image.FORMAT_RGBA8)
	bowl_water.blit_rect(img, Rect2i(460, 335, 43, 37), Vector2i(0, 0))
	
	# Ghép 2 bát cạnh nhau theo phối cảnh isometric
	var dual_tray_img = Image.create(78, 50, false, Image.FORMAT_RGBA8)
	# Bát thức ăn bên trái (hơi chếch lên sau)
	dual_tray_img.blit_rect(bowl_food, Rect2i(0, 0, 43, 37), Vector2i(0, 4))
	# Bát nước bên phải (chếch xuống trước)
	dual_tray_img.blit_rect(bowl_water, Rect2i(0, 0, 43, 37), Vector2i(34, 12))
	dual_tray_img.save_png("%s/dual_tray.png" % out_dir)
	print("Saved dual_tray.png (78x50)")
	
	# Copy Box3.png thành cardboard_box.png
	var box_path = "res://assets/CatPackFree/CatPackFree/Box3.png"
	var box_img = Image.load_from_file(box_path)
	if box_img:
		box_img.save_png("%s/cardboard_box.png" % out_dir)
		print("Saved cardboard_box.png from Box3.png")
		
	quit()
