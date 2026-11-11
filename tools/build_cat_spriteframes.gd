extends SceneTree

func _init() -> void:
	print("--- BUILDING SPRITEFRAMES FROM FREE PACK ---")
	
	# Mặc định sử dụng cat 1.6.png (Mèo vàng mướp sinh viên) hoặc cat 1.png (Mèo xám tro)
	var skins = {
		"cat_orange": "res://assets/Free pack/Free pack/cat 1.6.png",
		"cat_charcoal": "res://assets/Free pack/Free pack/cat 1.png",
		"cat_white": "res://assets/Free pack/Free pack/cat 1.9.png",
	}
	
	for skin_id in skins:
		var tex_path = skins[skin_id]
		var tex = load(tex_path)
		if not tex:
			var img = Image.load_from_file(tex_path)
			if img:
				tex = ImageTexture.create_from_image(img)
				
		if not tex:
			push_error("Cannot load texture for " + skin_id)
			continue
			
		var sf = SpriteFrames.new()
		
		# Định nghĩa danh sách animation: [tên, row, frame_count, speed, loop]
		var anim_defs = [
			["idle", 0, [4, 4, 4, 4, 4, 4, 4], 4.0, true], # Ngồi tư thế 3/4 Isometric
			["idle_left", 0, [5, 5, 5, 5, 5, 5, 5], 4.0, true],
			["walk_down_right", 9, [0, 1, 2, 3, 4, 5], 9.0, true],
			["walk_down_left", 8, [0, 1, 2, 3, 4, 5], 9.0, true],
			["walk_up_right", 10, [0, 1, 2, 3, 4, 5], 9.0, true],
			["walk_up_left", 11, [0, 1, 2, 3, 4, 5], 9.0, true],
			["walk_down", 4, [0, 1, 2, 3], 8.0, true],
			["walk_up", 5, [0, 1, 2, 3], 8.0, true],
			["walk_right", 6, [0, 1, 2, 3, 4, 5, 6, 7], 10.0, true],
			["walk_left", 7, [0, 1, 2, 3, 4, 5, 6, 7], 10.0, true],
			["sleep", 16, [0, 1], 2.0, true], # Cuộn tròn ngủ đệm
			["faint", 18, [0, 1], 2.0, true], # Nằm bẹp xỉu vì đói
			["eat", 24, [0, 1, 2, 3, 4, 5, 6, 7], 8.0, true], # Ăn hướng khay thức ăn
			["drink", 25, [0, 1, 2, 3, 4, 5, 6, 7], 8.0, true], # Uống nước
			["scratch", 39, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], 12.0, true], # Cào móng
			["paw_attack", 48, [0, 1, 2, 3, 4, 5, 6, 7, 8], 12.0, false], # Chơi vồ mồi
			["meow", 28, [0, 1, 2, 1], 6.0, false], # Kêu meo mở miệng
			["yawn", 32, [0, 1, 2, 3, 4, 5, 6, 7], 6.0, false], # Ngáp ngái ngủ
			["wash", 36, [0, 1, 2, 3, 4, 5, 6, 7, 8], 8.0, false], # Rửa mặt liếm vuốt
			["celebrate", 52, [0, 1, 2, 3], 8.0, true], # Đứng 2 chân ăn mừng
		]
		
		for a_def in anim_defs:
			var anim_name: String = a_def[0]
			var row: int = a_def[1]
			var cols: Array = a_def[2]
			var fps: float = a_def[3]
			var is_loop: bool = a_def[4]
			
			sf.add_animation(anim_name)
			sf.set_animation_speed(anim_name, fps)
			sf.set_animation_loop(anim_name, is_loop)
			
			for col in cols:
				var atlas = AtlasTexture.new()
				atlas.atlas = tex
				atlas.region = Rect2(col * 32, row * 32, 32, 32)
				atlas.filter_clip = true
				sf.add_frame(anim_name, atlas)
				
		var save_path = "res://assets/sprites/cats/%s_frames.tres" % skin_id
		var err = ResourceSaver.save(sf, save_path)
		print("Saved %s -> %s (Err: %d)" % [skin_id, save_path, err])
		
	quit()
