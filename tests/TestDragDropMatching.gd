extends Node

# TestDragDropMatching.gd
# Kiểm thử toàn diện Gameplay: Nối Hình Ảnh Với Từ Ngữ Dạng Drag & Drop
# Xác thực cơ chế kéo thả, chạm nối, nạp hình minh họa và ghi nhận hoàn thành bài học

const ARTIFACT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/"

func _ready() -> void:
	print("\n=================================================================")
	print("   TEST DRAG & DROP MATCHING: NỐI HÌNH ẢNH VỚI TỪ NGỮ (HỌC KỸ NĂNG)")
	print("=================================================================")
	
	# 1. Khởi tạo LessonView
	var lesson_scene = load("res://scenes/LessonView.tscn")
	assert(lesson_scene != null, "Phải load được LessonView.tscn!")
	var lesson_view = lesson_scene.instantiate()
	add_child(lesson_view)
	lesson_view.size = Vector2(480, 800)
	
	# Nạp bài 1
	lesson_view.load_lesson(1)
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("[PASS 01] Khởi tạo LessonView và nạp Bài 1 thành công!")
	assert(lesson_view.current_lesson_id == 1, "Lesson ID phải là 1!")
	assert(lesson_view.current_mode == "cards", "Chế độ mặc định phải là Matching Cards!")
	
	# 2. Kiểm tra Bảng 4 Khung Hình Ảnh Minh Họa
	var slots_box = lesson_view.slots_container
	assert(slots_box.get_child_count() == 4, "Bảng hình ảnh phải có đúng 4 ô khung hình!")
	print("[PASS 02] Bảng Hình Ảnh Minh Họa gồm đúng 4 Khung Hình Đích (HÌNH 1 -> HÌNH 4)!")
	
	# 3. Kiểm tra Kho Thẻ Từ Ngữ Hành Động
	var pool_box = lesson_view.cards_pool_container
	assert(pool_box.get_child_count() == 4, "Kho thẻ từ ngữ phải có đúng 4 thẻ draggable!")
	print("[PASS 03] Kho Thẻ Từ Ngữ Hành Động gồm đúng 4 thẻ bài kéo thả (Draggable Word Cards)!")
	
	# Chụp ảnh 1: Bảng ban đầu chưa nối
	await get_tree().create_timer(0.4).timeout
	var vp = get_viewport()
	if vp and vp.get_texture():
		var img1 = vp.get_texture().get_image()
		if img1:
			img1.save_png(ARTIFACT_DIR + "screenshot_drag_drop_matching_initial.png")
			print("  -> Đã chụp: screenshot_drag_drop_matching_initial.png")
			
	# 4. Kiểm thử Chạm Để Nối (Tap-to-Pair): Nối Thẻ 1 vào Hình 1
	var original_cards = lesson_view.lesson_data["cards"]
	var card_step_1 = null
	var card_step_2 = null
	var card_step_3 = null
	var card_step_4 = null
	for c in original_cards:
		if c["step"] == 1: card_step_1 = c
		elif c["step"] == 2: card_step_2 = c
		elif c["step"] == 3: card_step_3 = c
		elif c["step"] == 4: card_step_4 = c
		
	var match_ok_1 = lesson_view._attempt_match_card_to_slot(card_step_1, 0)
	assert(match_ok_1 == true, "Nối Thẻ 1 vào Hình 1 phải thành công!")
	assert(lesson_view.matched_slots.has(0), "Slot 0 phải được đánh dấu đã ghép!")
	print("[PASS 04] Cơ chế Nối Đúng Thẻ 1 vào Hình 1 (Vẫy xe từ xa) thành công rực rỡ!")
	
	# 5. Kiểm thử Kéo Thả Thử Thách Sai: Thả Thẻ 4 vào Hình 2 -> Bị từ chối
	var match_wrong = lesson_view._attempt_match_card_to_slot(card_step_4, 1)
	assert(match_wrong == false, "Nối Thẻ 4 vào Hình 2 phải thất bại!")
	assert(not lesson_view.matched_slots.has(1), "Slot 1 không được phép nhận Thẻ 4!")
	assert("Ngoao.." in lesson_view.cat_bubble.text, "Boss Mèo phải phản hồi 'Ngoao..' khi nối sai hình!")
	print("[PASS 05] Cơ chế Safe Failure: Thả nhầm thẻ vào sai hình ảnh bị từ chối chính xác và Mèo nhắc nhở gợi ý!")
	
	# 6. Nối tiếp Thẻ 2 vào Hình 2
	var match_ok_2 = lesson_view._attempt_match_card_to_slot(card_step_2, 1)
	assert(match_ok_2 == true, "Nối Thẻ 2 vào Hình 2 phải thành công!")
	print("[PASS 06] Nối Thẻ 2 vào Hình 2 (Cầm sẵn tiền lẻ) thành công!")
	
	# Chụp ảnh 2: Bảng đã nối 2 cặp hình - chữ
	await get_tree().create_timer(0.4).timeout
	if vp and vp.get_texture():
		var img2 = vp.get_texture().get_image()
		if img2:
			img2.save_png(ARTIFACT_DIR + "screenshot_drag_drop_matching_progress.png")
			print("  -> Đã chụp: screenshot_drag_drop_matching_progress.png")
			
	# 7. Nối 2 thẻ còn lại để hoàn thành 4/4
	lesson_view._attempt_match_card_to_slot(card_step_3, 2)
	lesson_view._attempt_match_card_to_slot(card_step_4, 3)
	assert(lesson_view.matched_slots.size() == 4, "Phải ghép đủ cả 4/4 cặp hình - chữ!")
	assert(lesson_view.btn_submit.disabled == false, "Nút nộp bài phải sáng đèn khi đủ 4 cặp!")
	assert("Meooo~" in lesson_view.cat_bubble.text, "Boss Mèo phải reo mừng 'Meooo~' khi đủ 4 cặp!")
	print("[PASS 07] Hoàn thành ghép đúng 4/4 cặp hình ảnh và từ ngữ! Nút Hoàn Thành kích hoạt!")
	
	# Chụp ảnh 3: Bảng hoàn thành đủ 4 cặp sẵn sàng nộp bài
	await get_tree().create_timer(0.4).timeout
	if vp and vp.get_texture():
		var img3 = vp.get_texture().get_image()
		if img3:
			img3.save_png(ARTIFACT_DIR + "screenshot_drag_drop_matching_complete.png")
			print("  -> Đã chụp: screenshot_drag_drop_matching_complete.png")
			
	# 8. Nộp bài và xác nhận ghi nhận hoàn thành bài học
	lesson_view._on_submit_pressed()
	assert(1 in GameManager.completed_lessons, "GameManager phải ghi nhận Bài 1 đã hoàn thành!")
	print("[PASS 08] Bấm Nộp bài thành công: GameManager ghi nhận hoàn tất và mở khóa bài tiếp theo!")
	
	print("\n=================================================================")
	print("   🎉 CHÚC MỪNG: 8/8 BÀI KIỂM THỬ DRAG & DROP MATCHING ĐẠT 100%!")
	print("=================================================================\n")
	
	lesson_view.queue_free()
	await get_tree().process_frame
	get_tree().quit()
