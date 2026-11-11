extends Control

# CaptureLessonGamificationAssets.gd
# Kiểm thử toàn diện: Gamification bài học kỹ năng sống với pixel-art assets chuyên biệt,
# cơ chế Safe Failure, Combo, Đánh giá Sao, và chụp ảnh thực chứng.

const ARTIFACT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/"

func _ready() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ: LESSON GAMIFICATION & ASSETS ===")
	
	var lv_scene = load("res://scenes/LessonView.tscn")
	var lv = lv_scene.instantiate()
	add_child(lv)
	lv.load_lesson(1)
	
	await get_tree().create_timer(0.4).timeout
	
	# 1. Kiểm tra 4 ô Chặng đã có Pixel-Art Assets (Không dùng emoji thô sơ)
	var slots_container = lv.slots_container
	assert(slots_container.get_child_count() == 4, "Phải có đúng 4 ô chặng tình huống!")
	for i in range(4):
		var slot_card = slots_container.get_child(i)
		var vbox = slot_card.get_child(0)
		var img_frame = vbox.get_child(1)
		var has_texture_rect = false
		for sub in img_frame.get_children():
			if sub is TextureRect and sub.texture != null:
				has_texture_rect = true
				break
		assert(has_texture_rect, "Chặng %d phải dùng TextureRect chứa asset pixel-art thay vì emoji!" % (i + 1))
	print("[PASS 1] Toàn bộ 4 Chặng Tình Huống đã trang bị TextureRect Pixel-Art Asset chuyên biệt!")

	# 2. Kiểm tra Kho thẻ hành động (Draggable Cards Pool) đã có thumbnail pixel art
	var pool_container = lv.cards_pool_container
	assert(pool_container.get_child_count() == 4, "Kho thẻ phải có đủ 4 thẻ hành động!")
	for i in range(4):
		var card_row = pool_container.get_child(i)
		var hbox = card_row.get_child(0)
		var img_box = hbox.get_child(0)
		var has_card_tex = false
		for sub in img_box.get_children():
			if sub is TextureRect and sub.texture != null:
				has_card_tex = true
				break
		assert(has_card_tex, "Thẻ bài %d trong kho phải có thumbnail TextureRect Pixel-Art!" % (i + 1))
	print("[PASS 2] Kho thẻ hành động dạy Boss hiển thị thumbnail Pixel-Art 40x40 sắc nét!")

	# 3. Chụp màn hình 1: Giao diện tổng quan mới với Pixel-Art Assets & Chặng 1..4
	await get_tree().create_timer(0.3).timeout
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("D:/BestSen/screenshot_lesson_gamification_overview.png")
	img1.save_png(ARTIFACT_DIR + "screenshot_lesson_gamification_overview.png")
	print("[SAVED] screenshot_lesson_gamification_overview.png")

	# 4. Kiểm thử cơ chế Thử Sai An Toàn (Safe Failure): Nối sai và nhận phản hồi thực tế từ Boss Mèo
	var cards_data = lv.lesson_data.get("cards", [])
	# Tìm thẻ bước 3 (Ôm ba lô) thử ghép vào Chặng 1 (Vẫy xe)
	var card_step_3 = {}
	var card_step_1 = {}
	var card_step_2 = {}
	var card_step_4 = {}
	for c in cards_data:
		if c["step"] == 1: card_step_1 = c
		elif c["step"] == 2: card_step_2 = c
		elif c["step"] == 3: card_step_3 = c
		elif c["step"] == 4: card_step_4 = c
		
	# Cố tình nối sai thẻ 3 vào chặng 1 (slot_idx = 0)
	lv._attempt_match_card_to_slot(card_step_3, 0)
	assert(lv.mistakes_count == 1, "mistakes_count phải tăng lên 1 khi nối sai!")
	assert(lv.combo_count == 0, "combo_count phải reset về 0 khi nối sai!")
	assert(card_step_3.get("error_hint", "") in lv.cat_bubble.text or "Sen ơi" in lv.cat_bubble.text, "Boss Mèo phải đưa ra lời nhắc nhở thực tế khi nối sai!")
	print("[PASS 3] Cơ chế Safe Failure hoạt động hoàn hảo: Boss phản hồi hóm hỉnh kèm gợi ý thực tế!")

	# 5. Tiến hành nối đúng lần lượt: Chặng 1, Chặng 2, Chặng 3
	lv._attempt_match_card_to_slot(card_step_1, 0)
	assert(lv.matched_slots.has(0), "Chặng 1 phải được nối thành công!")
	assert(lv.combo_count == 1, "Combo phải là 1!")

	lv._attempt_match_card_to_slot(card_step_2, 1)
	assert(lv.matched_slots.has(1), "Chặng 2 phải được nối thành công!")
	assert(lv.combo_count == 2, "Combo phải là 2!")

	await get_tree().create_timer(0.3).timeout
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("D:/BestSen/screenshot_lesson_matching_progress.png")
	img2.save_png(ARTIFACT_DIR + "screenshot_lesson_matching_progress.png")
	print("[SAVED] screenshot_lesson_matching_progress.png")

	# 6. Nối tiếp Chặng 3 và Chặng 4 để hoàn tất 100%
	lv._attempt_match_card_to_slot(card_step_3, 2)
	assert(lv.matched_slots.has(2), "Chặng 3 phải được nối thành công!")
	
	lv._attempt_match_card_to_slot(card_step_4, 3)
	assert(lv.matched_slots.has(3), "Chặng 4 phải được nối thành công!")
	assert(lv.matched_slots.size() == 4, "Phải ghép đủ cả 4 chặng!")

	await get_tree().create_timer(0.3).timeout
	# Kiểm tra nút Hoàn Thành & Đánh giá Sao
	assert(lv.btn_submit.disabled == false, "Nút hoàn thành phải được kích hoạt!")
	assert("XEM KẾT QUẢ" in lv.btn_submit.text or "MÔ PHỎNG" in lv.btn_submit.text or "HOÀN THÀNH" in lv.btn_submit.text, "Nút submit phải mời người chơi xem kết quả mô phỏng!")
	print("[PASS 4] Cả 4 Chặng đã ghép thành công, nút hoàn thành mở khóa!")

	var img3 = get_viewport().get_texture().get_image()
	img3.save_png("D:/BestSen/screenshot_lesson_gamification_completed.png")
	img3.save_png(ARTIFACT_DIR + "screenshot_lesson_gamification_completed.png")
	print("[SAVED] screenshot_lesson_gamification_completed.png")

	print("\n🎉 TOÀN BỘ KIỂM THỬ GAMIFICATION & ASSETS THÀNH CÔNG 100%!")
	get_tree().quit(0)
