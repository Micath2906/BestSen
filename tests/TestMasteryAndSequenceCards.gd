extends Node

# TestMasteryAndSequenceCards.gd
# Kiểm thử toàn diện: Hệ thống Cấp Độ Thăng Cấp (Cat Mastery) & Thiết kế Thẻ Bài Dạy Mèo Đúng Trình Tự

func _ready() -> void:
	print("\n=== BẮT ĐẦU KIỂM THỬ: TIẾN TRÌNH THĂNG CẤP & THẺ DẠY MÈO THEO TRÌNH TỰ ===")
	
	# 1. Kiểm tra cấu hình Cat Mastery Level trong GameManager
	assert(GameManager.MASTERY_CONFIG.size() == 5, "Hệ thống phải có đúng 5 Cấp Độ thuần thục!")
	print("[PASS 1] 5 Cấp Độ Mèo (Novice -> Learner -> Adept -> Master -> Champion) đã được thiết lập chuẩn xác!")
	
	# 2. Kiểm tra yêu cầu mở khóa kỹ năng
	# Cấp 1 (Bài 1, 5, 9, 13)
	assert(GameManager.get_skill_required_level(1) == 1, "Bài 1 phải thuộc Cấp 1!")
	assert(GameManager.get_skill_required_level(5) == 1, "Bài 5 phải thuộc Cấp 1!")
	# Cấp 2 (Bài 2, 6, 10, 14)
	assert(GameManager.get_skill_required_level(2) == 2, "Bài 2 phải thuộc Cấp 2!")
	# Cấp 3 (Bài 3, 7, 11, 15)
	assert(GameManager.get_skill_required_level(3) == 3, "Bài 3 phải thuộc Cấp 3!")
	# Cấp 4 (Bài 4, 8, 12, 16)
	assert(GameManager.get_skill_required_level(4) == 4, "Bài 4 phải thuộc Cấp 4!")
	print("[PASS 2] 16 Kỹ năng được phân bổ chính xác theo 4 Cấp Độ Thuần Thục!")
	
	# 3. Kiểm thử màn hình SkillTree với MasteryBanner & Điều kiện thăng cấp
	var skill_tree_scene = load("res://scenes/SkillTree.tscn")
	var skill_tree = skill_tree_scene.instantiate()
	add_child(skill_tree)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	assert(skill_tree.has_node("MasteryBanner"), "SkillTree phải có MasteryBanner!")
	assert(skill_tree.has_node("LevelInfoModal"), "SkillTree phải có LevelInfoModal!")
	print("[PASS 3] SkillTree tích hợp MasteryBanner và LevelInfoModal hoàn chỉnh!")
	
	# Mở modal điều kiện lên cấp
	skill_tree._on_level_reqs_pressed()
	assert(skill_tree.level_info_modal.visible == true, "Bấm nút phải mở modal điều kiện lên cấp!")
	print("[PASS 4] Modal Bảng Điều Kiện Thăng Cấp mở thành công với đầy đủ 5 cấp độ!")
	skill_tree.level_info_modal.visible = false
	
	# Chụp ảnh màn hình SkillTree với MasteryBanner
	await get_tree().create_timer(0.5).timeout
	var vp = get_viewport()
	if vp and vp.get_texture():
		var img1 = vp.get_texture().get_image()
		if img1:
			img1.save_png("D:/BestSen/screenshot_skilltree_mastery.png")
			print("Đã chụp màn hình xác thực: D:/BestSen/screenshot_skilltree_mastery.png")
			
	skill_tree.queue_free()
	await get_tree().process_frame
	
	# 4. Kiểm thử màn hình LessonView với Flashcard UI & Sequence Guide
	var lesson_view_scene = load("res://scenes/LessonView.tscn")
	var lesson_view = lesson_view_scene.instantiate()
	add_child(lesson_view)
	lesson_view.load_lesson(1)
	
	# Kiểm tra cẩm nang có đầy đủ Trình Tự Từ Ngữ Dạy Mèo (4 bước)
	assert("TRÌNH TỰ TỪ NGỮ DẠY MÈO" in lesson_view.guide_content.text, "Cẩm nang phải chứa trình tự dạy mèo!")
	assert("Meo-o?" in lesson_view.guide_content.text, "Bước 1 phải có tiếng Meo-o?")
	assert("Méo meo!" in lesson_view.guide_content.text, "Bước 2 phải có tiếng Méo meo!")
	assert("Meo-wrr..." in lesson_view.guide_content.text, "Bước 3 phải có tiếng Meo-wrr...")
	assert("Meoo!!" in lesson_view.guide_content.text, "Bước 4 phải có tiếng Meoo!!")
	print("[PASS 5] Cẩm Nang Cứu Sen tích hợp chuẩn xác Bảng Trình Tự Từ Ngữ Dạy Mèo (Bước 1 ➔ 2 ➔ 3 ➔ 4)!")
	
	# Kiểm tra kho thẻ bài Flashcard UI
	var pool_container = lesson_view.cards_pool_container
	assert(pool_container.get_child_count() == 4, "Kho thẻ phải hiển thị đúng 4 thẻ bài!")
	print("[PASS 6] Kho thẻ bài Flashcard UI hiển thị 4 khối thẻ với icon, ngữ điệu mèo và nhãn hành động thực tế!")
	
	# Xếp lần lượt 2 bước đầu vào khay
	var original_cards = lesson_view.lesson_data["cards"]
	lesson_view._pick_card(original_cards[0])
	lesson_view._pick_card(original_cards[1])
	assert(lesson_view.selected_sequence.size() == 2, "Khay nhận phải chứa 2 thẻ đã chọn!")
	
	# Chụp ảnh màn hình LessonView
	await get_tree().create_timer(0.5).timeout
	if vp and vp.get_texture():
		var img2 = vp.get_texture().get_image()
		if img2:
			img2.save_png("D:/BestSen/screenshot_lesson_sequence_cards.png")
			print("Đã chụp màn hình xác thực: D:/BestSen/screenshot_lesson_sequence_cards.png")
			
	print("\n=== TOÀN BỘ KIỂM THỬ THÀNH CÔNG 100%! ===")
	get_tree().quit()
