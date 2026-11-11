extends Control

# CaptureBrightMenuAndCatDrag.gd - Kiểm thử tự động & chụp ảnh showcase:
# 1. Background Main Menu sáng sủa, ấm cúng
# 2. Cơ chế Kéo Thả Mèo (Direct Cat Drag & Drop) tới nội thất
# 3. Giao diện bài học Flashcard Kéo Thả theo lý thuyết, đồ họa & font chữ ấm áp bớt AI

func _ready() -> void:
	await get_tree().create_timer(0.4).timeout
	print("\n=== BẮT ĐẦU KIỂM THỬ SHOWCASE GIAO DIỆN MỚI ===")
	
	# --- 1. CHỤP MAIN MENU SÁNG SỦA ---
	var main_menu_scene = load("res://scenes/MainMenu.tscn")
	var menu_node = main_menu_scene.instantiate()
	add_child(menu_node)
	await get_tree().create_timer(0.4).timeout
	
	var img_menu = get_viewport().get_texture().get_image()
	img_menu.save_png("D:/BestSen/screenshot_bright_main_menu.png")
	print("✓ Đã chụp Main Menu sáng sủa: screenshot_bright_main_menu.png")
	menu_node.queue_free()
	await get_tree().create_timer(0.2).timeout
	
	# --- 2. KIỂM THỬ PHÒNG TRỌ & KÉO THẢ MÈO ---
	var main_scene = load("res://scenes/Main.tscn")
	var main_node = main_scene.instantiate()
	add_child(main_node)
	await get_tree().create_timer(0.4).timeout
	
	var room_view = main_node.current_view_node
	assert(room_view != null, "Phải có room_view!")
	var cat = room_view.iso_cat
	assert(cat != null, "Phải có iso_cat!")
	
	# Kéo mèo lên khỏi mặt sàn
	cat.start_drag()
	cat.position = Vector2(250.0, 750.0)
	cat.dialogue_label.text = "Đang được Sen bế đi dạo phòng! 🐾"
	await get_tree().create_timer(0.3).timeout
	
	var img_cat_drag = get_viewport().get_texture().get_image()
	img_cat_drag.save_png("D:/BestSen/screenshot_cat_drag_interaction.png")
	print("✓ Đã chụp Kéo Thả Mèo: screenshot_cat_drag_interaction.png")
	
	# Thả mèo vào Đệm Ngủ (Cushion Bed)
	room_view._on_cat_dropped_at(room_view.cushion_bed.position)
	await get_tree().create_timer(0.4).timeout
	
	var img_cat_bed = get_viewport().get_texture().get_image()
	img_cat_bed.save_png("D:/BestSen/screenshot_cat_dropped_at_bed.png")
	print("✓ Đã chụp Mèo ngủ trên đệm sau khi thả: screenshot_cat_dropped_at_bed.png")
	
	# --- 3. KIỂM THỬ BÀI HỌC KÉO THẢ FLASHCARD THEO LÝ THUYẾT ---
	main_node.switch_to_map()
	await get_tree().create_timer(0.3).timeout
	
	# Mở bài 1
	main_node.start_lesson(1)
	await get_tree().create_timer(0.4).timeout
	
	var lesson_view = main_node.current_view_node
	assert(lesson_view != null, "Phải mở LessonView!")
	lesson_view.set_mode("cards")
	await get_tree().create_timer(0.3).timeout
	
	# Kéo 2 thẻ bài vào bảng 4 bước
	var cards = lesson_view.lesson_data.get("cards", [])
	lesson_view._place_card_at_slot(cards[0], 0)
	lesson_view._place_card_at_slot(cards[1], 1)
	await get_tree().create_timer(0.3).timeout
	
	var img_lesson = get_viewport().get_texture().get_image()
	img_lesson.save_png("D:/BestSen/screenshot_lesson_cards_drag_drop.png")
	print("✓ Đã chụp Bài học Kéo Thả Flashcard: screenshot_lesson_cards_drag_drop.png")
	
	# Mở Sổ tay bỏ túi
	lesson_view._on_guide_pressed()
	await get_tree().create_timer(0.3).timeout
	
	var img_guide = get_viewport().get_texture().get_image()
	img_guide.save_png("D:/BestSen/screenshot_lesson_guide_handbook.png")
	print("✓ Đã chụp Sổ tay bỏ túi: screenshot_lesson_guide_handbook.png")
	
	print("\n=== TOÀN BỘ KIỂM THỬ & CHỤP ẢNH SHOWCASE THÀNH CÔNG 100%! ===")
	get_tree().quit()
