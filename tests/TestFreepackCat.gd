extends Node

func _ready() -> void:
	print("\n========================================================")
	print("    KIỂM THỬ MODEL VÀ ANIMATION MÈO TỪ FREEPACK        ")
	print("========================================================")
	
	await get_tree().process_frame
	
	# [1] KHỞI TẠO ISOMETRICCAT
	print("[1] Khởi tạo chú mèo IsometricCat:")
	var cat_scene = load("res://scenes/IsometricCat.tscn")
	var cat: Node2D = cat_scene.instantiate()
	add_child(cat)
	await get_tree().process_frame
	
	assert(cat.anim_sprite != null, "anim_sprite must exist")
	assert(cat.anim_sprite.sprite_frames != null, "sprite_frames must exist")
	print("  -> Node IsometricCat và AnimatedSprite2D đã sẵn sàng!")
	
	# [2] KIỂM TRA ĐẦY ĐỦ ANIMATION LIST
	print("\n[2] Kiểm tra danh sách animations từ Free Pack:")
	var required_anims = [
		"idle", "idle_left", "walk_dr", "walk_dl", "walk_ur", "walk_ul",
		"walk_down", "walk_up", "walk_right", "walk_left", "walk",
		"sleep", "faint", "eat", "drink", "scratch", "paw_toy", 
		"meow", "wash", "celebrate"
	]
	var sf: SpriteFrames = cat.anim_sprite.sprite_frames
	for anim_name in required_anims:
		assert(sf.has_animation(anim_name), "Thiếu animation: " + anim_name)
		var frame_cnt = sf.get_frame_count(anim_name)
		var fps = sf.get_animation_speed(anim_name)
		print("  + [%s] -> %d frames (%.1f FPS)" % [anim_name, frame_cnt, fps])
		assert(frame_cnt > 0, "Animation " + anim_name + " không có frame")
	print("  -> Toàn bộ 20/20 animation đã nạp thành công 100%!")
	
	# [3] KIỂM TRA ĐỘNG HỌC 8 HƯỚNG ISOMETRIC
	print("\n[3] Kiểm tra tính toán hướng đi bộ 8 hướng (Isometric 8-Way Walking):")
	var dir_tests = [
		[Vector2(2, 1), "walk_dr"],    # Xuống-Phải Isometric (+U)
		[Vector2(-2, 1), "walk_dl"],   # Xuống-Trái Isometric (+V)
		[Vector2(2, -1), "walk_ur"],   # Lên-Phải Isometric (-V)
		[Vector2(-2, -1), "walk_ul"],  # Lên-Trái Isometric (-U)
		[Vector2(0, 1), "walk_down"],  # Xuống thẳng
		[Vector2(0, -1), "walk_up"],   # Lên thẳng
		[Vector2(1, 0), "walk_right"], # Phải thẳng
		[Vector2(-1, 0), "walk_left"], # Trái thẳng
	]
	for dt in dir_tests:
		var vec: Vector2 = dt[0]
		var expected: String = dt[1]
		var calculated: String = cat._get_walk_anim_for_dir(vec.normalized())
		print("  + Hướng %s -> '%s' (Kỳ vọng: '%s')" % [vec, calculated, expected])
		assert(calculated == expected, "Sai hướng đi bộ cho vector " + str(vec))
	print("  -> Tính toán 8 hướng Isometric chính xác tuyệt đối!")
	
	# [4] KIỂM TRA CHUYỂN TRẠNG THÁI (STATES)
	print("\n[4] Kiểm tra kích hoạt các trạng thái game:")
	cat.set_state(cat.State.EAT)
	assert(cat.anim_sprite.animation == "eat", "Trạng thái EAT phải kích hoạt animation eat")
	print("  + State.EAT -> anim: " + cat.anim_sprite.animation)
	
	cat.set_state(cat.State.DRINK)
	assert(cat.anim_sprite.animation == "drink", "Trạng thái DRINK phải kích hoạt animation drink")
	print("  + State.DRINK -> anim: " + cat.anim_sprite.animation)
	
	cat.set_state(cat.State.SLEEP)
	assert(cat.anim_sprite.animation == "sleep", "Trạng thái SLEEP phải kích hoạt animation sleep")
	print("  + State.SLEEP -> anim: " + cat.anim_sprite.animation)
	
	cat.set_state(cat.State.FAINT)
	assert(cat.anim_sprite.animation == "faint", "Trạng thái FAINT phải kích hoạt animation faint")
	print("  + State.FAINT -> anim: " + cat.anim_sprite.animation)
	
	cat.set_state(cat.State.SCRATCH)
	assert(cat.anim_sprite.animation == "scratch", "Trạng thái SCRATCH phải kích hoạt animation scratch")
	print("  + State.SCRATCH -> anim: " + cat.anim_sprite.animation)
	
	cat.set_state(cat.State.IDLE)
	assert(cat.anim_sprite.animation == "idle" or cat.anim_sprite.animation == "idle_left" or cat.anim_sprite.animation == "idle2", "Trạng thái IDLE phải kích hoạt animation idle hoặc idle2")
	print("  + State.IDLE -> anim: " + cat.anim_sprite.animation)
	
	# [5] KIỂM TRA TƯƠNG TÁC CHẠM CẢM XÚC
	print("\n[5] Kiểm tra tương tác chạm trên thân mèo:")
	# Vuốt đầu -> wash
	cat.handle_touch(-20.0)
	assert(cat.anim_sprite.animation == "wash", "Vuốt đầu phải kích hoạt animation wash")
	print("  + Vuốt đầu -> anim wash (Grooming liếm vuốt) PASS!")
	
	# Chọc bụng -> paw_toy
	cat.handle_touch(0.0)
	assert(cat.anim_sprite.animation == "paw_toy", "Chọc bụng phải kích hoạt animation paw_toy")
	print("  + Cù lét bụng -> anim paw_toy (Vồ vờn nghịch) PASS!")
	
	# Chọc chân -> celebrate
	cat.handle_touch(15.0)
	assert(cat.anim_sprite.animation == "celebrate", "Chọc chân phải kích hoạt animation celebrate")
	print("  + Chọc chân -> anim celebrate (Đứng 2 chân) PASS!")
	
	# [6] KIỂM TRA ĐỔI MÀU LÔNG (SKIN SWITCHING)
	print("\n[6] Kiểm tra chuyển đổi 3 màu lông Free Pack:")
	cat.set_skin("charcoal")
	assert(cat.current_skin == "charcoal", "Skin phải đổi sang charcoal")
	print("  + Đổi sang skin 'charcoal' (Mèo xám tro) thành công!")
	
	cat.set_skin("white")
	assert(cat.current_skin == "white", "Skin phải đổi sang white")
	print("  + Đổi sang skin 'white' (Mèo trắng tuyết) thành công!")
	
	cat.set_skin("orange")
	assert(cat.current_skin == "orange", "Skin phải đổi sang orange")
	print("  + Đổi về skin mặc định 'orange' (Mèo vàng mướp sinh viên) thành công!")
	
	print("\n========================================================")
	print("   TẤT CẢ KIỂM THỬ FREEPACK CAT THÀNH CÔNG 100%!        ")
	print("========================================================")
	
	# Chụp màn hình xác nhận nếu có viewport
	await get_tree().process_frame
	var tex = get_viewport().get_texture()
	if tex:
		var img = tex.get_image()
		if img:
			img.save_png("res://tests/screenshot_freepack_cat.png")
			
	get_tree().quit(0)
