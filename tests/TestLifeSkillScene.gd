extends Node

func _ready() -> void:
	print("\n=== BẮT ĐẦU KIỂM THỬ SCENE TÍCH HỢP LIFE_SKILLS.JSON ===")
	
	# 1. Kiểm tra GameManager đã nạp dữ liệu từ life_skills.json
	assert(GameManager.lessons_data.size() == 16, "Cần có chính xác 16 kỹ năng sống sinh viên!")
	print("[PASS 1] GameManager đã nạp 16 bài học từ life_skills.json thành công!")
	
	# 2. Tạo LessonView và nạp bài 1
	var lesson_view_scene = load("res://scenes/LessonView.tscn")
	var lesson_view = lesson_view_scene.instantiate()
	add_child(lesson_view)
	lesson_view.load_lesson(1)
	
	print("[PASS 2] Đã nạp bài 1: '", lesson_view.lesson_data.get("title", ""), "'")
	assert(lesson_view.lesson_data.get("title", "") == "Tra cứu BusMap & Tìm tuyến xe", "Tên bài 1 chưa đúng!")
	
	# 3. Kiểm tra các thẻ bài (puzzle_cards)
	var cards = lesson_view.lesson_data.get("cards", [])
	assert(cards.size() == 4, "Phải có đúng 4 thẻ bài!")
	print("[PASS 3] 4 Thẻ âm thanh mèo & hành động thực tế đã nạp thành công:")
	for c in cards:
		print("  - [Bước %d] Icon: %s | Âm thanh: %s | Nội dung: %s" % [c["step"], c["icon"], c["meow"], c["text"]])
		
	# 4. Kiểm tra Safe Failure (chọn sai thứ tự)
	var wrong_seq = []
	# Đưa bước 4 lên đầu
	for c in cards:
		if c["step"] == 4:
			wrong_seq.append(c)
	for c in cards:
		if c["step"] != 4:
			wrong_seq.append(c)
			
	lesson_view.selected_sequence = wrong_seq
	lesson_view._on_submit_pressed()
	
	assert("Ngoao.." in lesson_view.cat_bubble.text, "Mèo phải phát tiếng Ngoao.. khi xếp sai!")
	print("[PASS 4] Safe Failure hoạt động chuẩn: Mèo phát tiếng Ngoao.. và hiển thị gợi ý: '", lesson_view.cat_bubble.text, "'")
	
	# 5. Xếp đúng 100%
	var correct_seq = []
	for step in [1, 2, 3, 4]:
		for c in cards:
			if c["step"] == step:
				correct_seq.append(c)
				break
				
	lesson_view.selected_sequence = correct_seq
	lesson_view._render_slots()
	lesson_view._on_submit_pressed()
	assert("Meooo~" in lesson_view.cat_bubble.text, "Mèo phải reo mừng Meooo~!")
	print("[PASS 5] Xếp đúng 100% kích hoạt thành công, Mèo reo mừng Meooo~!")
	
	# Chuẩn bị giao diện đẹp để chụp ảnh màn hình
	lesson_view.load_lesson(1)
	# Chọn 2 thẻ đầu vào slot để minh họa cơ chế kéo thả chuỗi
	lesson_view._pick_card(cards[0])
	lesson_view._pick_card(cards[1])
	
	# Đợi giao diện render hoàn tất
	await get_tree().create_timer(0.6).timeout
	var viewport = get_viewport()
	if viewport:
		var tex = viewport.get_texture()
		if tex:
			var img = tex.get_image()
			if img:
				img.save_png("D:/BestSen/screenshot_lesson_lifeskill.png")
				print("Đã chụp màn hình xác thực: D:/BestSen/screenshot_lesson_lifeskill.png")
	
	print("\n=== TOÀN BỘ KIỂM THỬ TÍCH HỢP LIFE_SKILLS THÀNH CÔNG 100%! ===")
	get_tree().quit()
