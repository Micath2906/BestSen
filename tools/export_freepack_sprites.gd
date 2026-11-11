extends SceneTree

func _init() -> void:
	print("--- EXPORTING FREEPACK CAT ANIMATION FRAMES ---")
	
	var skins = {
		"orange": "res://assets/Free pack/Free pack/cat 1.6.png",
		"charcoal": "res://assets/Free pack/Free pack/cat 1.png",
		"white": "res://assets/Free pack/Free pack/cat 1.9.png",
	}
	
	# Directory check
	var base_dir = "res://assets/sprites/cats"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(base_dir))
	
	# Mapping của các animation từ 53 hàng (32x32 tiles):
	# [prefix, row, [col_indices]]
	var anim_exports = [
		# Tư thế ngồi & đứng
		["sit_front", 0, [0]],
		["sit_back", 0, [1]],
		["sit_ur", 0, [2]],
		["sit_ul", 0, [3]],
		["sit_dr", 0, [4]], # Isometric chuẩn
		["sit_dl", 0, [5]], # Isometric chuẩn
		["stand_dr", 1, [4]],
		["stand_dl", 1, [5]],
		["loaf", 3, [0]],
		
		# 8 hướng di chuyển Isometric chuẩn xác
		["walk_down", 4, [0, 1, 2, 3]],
		["walk_up", 5, [0, 1, 2, 3]],
		["walk_right", 6, [0, 1, 2, 3, 4, 5, 6, 7]],
		["walk_left", 7, [0, 1, 2, 3, 4, 5, 6, 7]],
		["walk_dl", 8, [0, 1, 2, 3, 4, 5]], # Down-Left Isometric
		["walk_dr", 9, [0, 1, 2, 3, 4, 5]], # Down-Right Isometric
		["walk_ur", 10, [0, 1, 2, 3, 4, 5]], # Up-Right Isometric
		["walk_ul", 11, [0, 1, 2, 3, 4, 5]], # Up-Left Isometric
		
		# Ngủ & Ngất xỉu
		["sleep", 16, [0, 1, 0, 1]], # Cuộn tròn thở nhịp nhàng
		["sleep_right", 17, [0, 1, 0, 1]],
		["faint", 18, [0, 1, 0, 1]], # Nằm bẹp xỉu (Sploot)
		
		# Ăn uống
		["eat_dr", 24, [0, 1, 2, 3, 4, 5, 6, 7]], # Ăn hướng khay thức ăn
		["eat_dl", 25, [0, 1, 2, 3, 4, 5, 6, 7]], # Uống hướng khay nước
		
		# Biểu cảm & Hành vi mèo
		["meow", 28, [0, 1, 2, 1]], # Kêu meo mở miệng
		["yawn", 32, [0, 1, 2, 3, 4, 5, 6, 7]], # Ngáp ngủ
		["wash", 36, [0, 1, 2, 3, 4, 5, 6, 7, 8]], # Rửa mặt liếm lông
		["scratch", 39, [0, 1, 2, 3, 4, 5, 6, 7]], # Cào móng sisal
		["paw_toy", 48, [0, 1, 2, 3, 4, 5, 6, 7, 8]], # Vồ cần câu lông vũ
		["celebrate", 52, [0, 1, 2, 3]], # Đứng 2 chân ăn mừng
	]
	
	for skin_name in skins:
		var sheet_path = skins[skin_name]
		var img = Image.load_from_file(sheet_path)
		if not img:
			push_error("Failed to load: " + sheet_path)
			continue
			
		var skin_dir = base_dir + "/" + skin_name
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(skin_dir))
		
		for item in anim_exports:
			var prefix = item[0]
			var row = item[1]
			var cols = item[2]
			
			for i in range(cols.size()):
				var col = cols[i]
				var frame_img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
				frame_img.blit_rect(img, Rect2i(col * 32, row * 32, 32, 32), Vector2i(0, 0))
				
				# Lưu vào thư mục skin
				var out_path = "%s/%s_%d.png" % [skin_dir, prefix, i]
				frame_img.save_png(out_path)
				
				# Nếu là skin mặc định ("orange"), lưu trực tiếp vào assets/sprites/cats/ để làm default
				if skin_name == "orange":
					var default_path = "%s/%s_%d.png" % [base_dir, prefix, i]
					frame_img.save_png(default_path)
					
		# Lưu các sprite chính thay thế sprite cũ
		if skin_name == "orange":
			# cat_idle_dr -> cat_sit_0.png
			var idle_dr = Image.create(32, 32, false, Image.FORMAT_RGBA8)
			idle_dr.blit_rect(img, Rect2i(4 * 32, 0 * 32, 32, 32), Vector2i(0, 0))
			idle_dr.save_png(base_dir + "/cat_sit_0.png")
			idle_dr.save_png("res://assets/sprites/cat_idle.png")
			
			# cat_idle_dl -> cat_sit_1.png
			var idle_dl = Image.create(32, 32, false, Image.FORMAT_RGBA8)
			idle_dl.blit_rect(img, Rect2i(5 * 32, 0 * 32, 32, 32), Vector2i(0, 0))
			idle_dl.save_png(base_dir + "/cat_sit_1.png")
			
			# cat_walk_dr -> cat_walk_0..3.png
			for w in range(4):
				var w_frame = Image.create(32, 32, false, Image.FORMAT_RGBA8)
				w_frame.blit_rect(img, Rect2i(w * 32, 9 * 32, 32, 32), Vector2i(0, 0))
				w_frame.save_png("%s/cat_walk_%d.png" % [base_dir, w])
				
			# cat_sleep -> cat_sleep_0..3.png
			for s in range(4):
				var s_col = (s % 2)
				var s_frame = Image.create(32, 32, false, Image.FORMAT_RGBA8)
				s_frame.blit_rect(img, Rect2i(s_col * 32, 16 * 32, 32, 32), Vector2i(0, 0))
				s_frame.save_png("%s/cat_sleep_%d.png" % [base_dir, s])
				
	print("EXPORT COMPLETE! Successfully exported all 3 cat skins and animations!")
	quit()
