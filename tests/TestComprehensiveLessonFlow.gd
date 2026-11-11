extends Control

func _ready() -> void:
	print("--- TEST COMPREHENSIVE LESSON FLOW ---")
	var main_scene = load("res://scenes/Main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	
	# 1. Test starting Lesson 1 from Main -> Opens StoryLessonView
	print("\n[TEST 1] Main.start_lesson(1):")
	main.start_lesson(1)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	var current_view = main.current_view_node
	print("Current view: ", current_view.name)
	assert(current_view.name == "StoryLessonView", "Mặc định Bài 1 phải mở StoryLessonView!")
	print("  -> StoryLessonView active successfully!")
	
	# Screenshot StoryLessonView Step 1
	var vp = get_viewport()
	var img_story = vp.get_texture().get_image()
	if img_story:
		img_story.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/verified_story_adventure_step1.png")
		print("  -> Saved: verified_story_adventure_step1.png")
		
	# 2. Test switching to Matching Mode (Khung Tranh) from StoryLessonView
	print("\n[TEST 2] Chuyển từ StoryLessonView sang Khung Tranh (Matching Mode):")
	current_view.emit_signal("open_matching_mode_requested")
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	var lv = main.current_view_node
	print("Current view after switch: ", lv.name)
	assert(lv.name == "LessonView", "Phải chuyển sang LessonView!")
	print("  -> LessonView active successfully!")
	
	# Check slots and cards count
	var slots = lv.get_node("SlotsSection/SlotsContainer")
	var pool = lv.get_node("CardsSection/ScrollContainer/CardsPoolContainer")
	assert(slots.get_child_count() == 4, "Phải có đúng 4 slot!")
	assert(pool.get_child_count() == 4, "Phải có đúng 4 thẻ trong kho!")
	print("  -> Slots: 4/4, Cards: 4/4 present!")
	
	# 3. Test Native Drag & Drop simulation on LessonView:
	# Thả Thẻ Chặng 1 vào Slot 0
	print("\n[TEST 3] Thả Thẻ Chặng 1 vào Slot 0 (Native Drop):")
	var card_step_1 = {}
	for c in lv.shuffled_cards:
		if c["step"] == 1: card_step_1 = c
	var slot_0 = slots.get_child(0)
	assert(slot_0._can_drop_data(Vector2(20, 20), card_step_1) == true, "Slot 0 phải nhận thẻ step 1!")
	slot_0._drop_data(Vector2(20, 20), card_step_1)
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	# Kiểm tra sau khi ghép 1 thẻ: CÁC THẺ KHÁC VẪN HIỂN THỊ ĐẦY ĐỦ 100%!
	print("Pool children after 1 match: ", pool.get_child_count())
	assert(pool.get_child_count() == 4, "Kho thẻ vẫn phải giữ đủ 4 thẻ sau khi ghép 1 thẻ!")
	for i in range(pool.get_child_count()):
		var ch = pool.get_child(i)
		assert(ch.is_visible_in_tree(), "Thẻ %d phải hiển thị!" % i)
	print("  -> XÁC NHẬN: Không còn lỗi biến mất thẻ! Cả 4 thẻ đều hiển thị hoàn hảo!")
	
	# Chụp ảnh sau khi ghép 1 thẻ
	var img_matched_1 = vp.get_texture().get_image()
	if img_matched_1:
		img_matched_1.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/verified_lesson_1_card_matched.png")
		print("  -> Saved: verified_lesson_1_card_matched.png")
		
	# 4. Thả nốt 3 thẻ còn lại vào các slot tương ứng
	print("\n[TEST 4] Thả nốt 3 thẻ còn lại vào 3 slot:")
	for s_num in [2, 3, 4]:
		var target_c = {}
		for c in lv.shuffled_cards:
			if c["step"] == s_num: target_c = c
		var target_slot = slots.get_child(s_num - 1)
		target_slot._drop_data(Vector2(20, 20), target_c)
		
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	var btn_sub: Button = lv.get_node("ActionFooter/BtnSubmit")
	print("BtnSubmit disabled: ", btn_sub.disabled, " text: ", btn_sub.text)
	assert(btn_sub.disabled == false, "BtnSubmit phải được kích hoạt sau khi ghép đủ 4 thẻ!")
	assert("HOÀN THÀNH" in btn_sub.text, "BtnSubmit phải có chữ HOÀN THÀNH!")
	print("  -> Toàn bộ 4 chặng ghép thành công, nút HOÀN THÀNH đã sẵn sàng!")
	
	# Chụp ảnh khi hoàn thành cả 4 thẻ
	var img_matched_all = vp.get_texture().get_image()
	if img_matched_all:
		img_matched_all.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/verified_lesson_all_matched.png")
		print("  -> Saved: verified_lesson_all_matched.png")
		
	print("\n========================================================")
	print("   KIỂM THỬ TOÀN DIỆN DRAG & DROP & STORY FLOW THÀNH CÔNG 100%!")
	print("========================================================")
	get_tree().quit(0)
