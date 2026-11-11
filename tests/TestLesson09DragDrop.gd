extends Control

# TestLesson09DragDrop.gd
# Kiểm thử toàn diện Bài 9: Kéo thả vào từng hình (Interactive Story & Khung Tranh)

func _ready() -> void:
	print("\n========================================================")
	print("   TEST BÀI 9: KÉO THẢ VÀO TỪNG HÌNH (SỐT CAO 39 ĐỘ)   ")
	print("========================================================")
	
	var main_scene = load("res://scenes/Main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	
	await get_tree().create_timer(0.3).timeout
	
	# 1. Bắt đầu Bài 9 từ Main -> Phải mở StoryLessonView (Kéo thả vào từng hình)
	print("\n[TEST 1] Main.start_lesson(9):")
	main.start_lesson(9)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	var current_view = main.current_view_node
	print("Current view: ", current_view.name)
	assert(current_view.name == "StoryLessonView", "Bài 9 phải mở StoryLessonView (Kéo thả vào từng hình)!")
	assert("Sốt" in current_view.title_label.text or "sốt" in current_view.title_label.text or "39" in current_view.title_label.text, "Tiêu đề phải là bài hạ sốt 39 độ!")
	print("  -> Title: ", current_view.title_label.text)
	print("  -> Subtitle: ", current_view.subtitle_label.text)
	
	var vp = get_viewport()
	if vp and vp.get_texture():
		var img_step1 = vp.get_texture().get_image()
		if img_step1:
			img_step1.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/verified_lesson_09_story_step1.png")
			print("  -> Saved: verified_lesson_09_story_step1.png")
			
	# 2. Thử điền đúng thẻ Chặng 1 của Bài 9: Meo-temp? (Kẹp nhiệt kế)
	var step1 = current_view.story_data["steps"][0]
	var correct_card = null
	for c in step1["cards"]:
		if c.get("is_correct", false):
			correct_card = c
			break
			
	assert(correct_card != null, "Phải tìm thấy thẻ đúng của Chặng 1!")
	print("  -> Correct card Chặng 1: ", correct_card.get("cat_sound", ""), " - ", correct_card.get("label", ""))
	current_view._attempt_fill_blank(correct_card, "blank_1")
	assert(current_view.filled_blanks.has("blank_1"), "Ô blank_1 phải được điền thành công!")
	print("  -> Điền đúng Chặng 1 thành công!")
	
	await get_tree().create_timer(0.3).timeout
	if vp and vp.get_texture():
		var img_step1_filled = vp.get_texture().get_image()
		if img_step1_filled:
			img_step1_filled.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/verified_lesson_09_story_step1_filled.png")
			print("  -> Saved: verified_lesson_09_story_step1_filled.png")
			
	# 3. Chuyển sang Khung Tranh (Matching Mode) của Bài 9
	print("\n[TEST 2] Chuyển sang Khung Tranh của Bài 9:")
	current_view.emit_signal("open_matching_mode_requested")
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	var lv = main.current_view_node
	print("Current view after switch: ", lv.name)
	assert(lv.name == "LessonView", "Phải chuyển sang LessonView!")
	assert(lv.current_lesson_id == 9, "LessonView phải nạp đúng Bài 9!")
	print("  -> LessonView active với Bài 9 thành công!")
	print("  -> Cat bubble text: ", lv.cat_bubble.text)
	assert(not "Bác tài" in lv.cat_bubble.text, "Cat bubble không được chứa text bác tài của xe buýt!")
	
	# 4. Kiểm tra kéo thả trực tiếp vào hình (Slot 0)
	var slots = lv.get_node("SlotsSection/SlotsContainer")
	var slot_0 = slots.get_child(0)
	
	# Tìm thẻ step 1 của Bài 9 trong pool
	var card_step_1 = {}
	for c in lv.shuffled_cards:
		if c["step"] == 1: card_step_1 = c
		
	assert(slot_0._can_drop_data(Vector2(20, 20), card_step_1) == true, "Slot 0 phải nhận drop của thẻ step 1!")
	slot_0._drop_data(Vector2(20, 20), card_step_1)
	
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	if vp and vp.get_texture():
		var img_lv9 = vp.get_texture().get_image()
		if img_lv9:
			img_lv9.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/verified_lesson_09_matching_view.png")
			print("  -> Saved: verified_lesson_09_matching_view.png")
			
	print("\n========================================================")
	print("   TOÀN BỘ KIỂM THỬ BÀI 9 PASS 100%!                    ")
	print("========================================================")
	get_tree().quit()
