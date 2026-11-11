extends Node

# TestStoryLessonView.gd
# Kiểm thử toàn diện Gameplay: Interactive Storytelling / Điền ô trống kể chuyện (Fill-in-the-Blank Adventure)

func _ready() -> void:
	print("\n========================================================")
	print("   KIỂM THỬ GAMEPLAY: INTERACTIVE STORYTELLING ADVENTURE   ")
	print("========================================================")
	
	# 1. Kiểm tra nạp dữ liệu từ story_lessons.json qua GameManager
	var story_data = GameManager.get_story_data("story_commute_bus_01")
	assert(not story_data.is_empty(), "Phải nạp được story 'story_commute_bus_01' từ JSON!")
	assert(story_data.get("steps", []).size() == 3, "Câu chuyện xe buýt phải có đúng 3 bước!")
	print("[PASS 1] Dữ liệu JSON kịch bản kể chuyện 3 bước nạp thành công 100%!")
	
	# 2. Khởi tạo scene StoryLessonView
	var story_scene = load("res://scenes/StoryLessonView.tscn")
	var story_view = story_scene.instantiate()
	add_child(story_view)
	story_view.load_story(story_data)
	
	await get_tree().create_timer(0.4).timeout
	var vp = get_viewport()
	
	# Chụp ảnh Bước 1 khởi đầu
	assert(story_view.current_step_idx == 0, "Bắt đầu ở Bước 1!")
	print("[PASS 2] Khởi tạo giao diện Chuyến Xe Buýt Đầu Tiên Của Mèo - Bước 1!")
	if vp and vp.get_texture():
		var img1 = vp.get_texture().get_image()
		if img1:
			img1.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_story_step_1_overview.png")
			print("Saved: screenshot_story_step_1_overview.png")
			
	# 3. Thử điền thẻ sai: card_cry (Ngồi bệt xuống đường khóc)
	var step1 = story_data["steps"][0]
	var card_cry = null
	var card_busmap = null
	for c in step1["cards"]:
		if c["id"] == "card_cry": card_cry = c
		elif c["id"] == "card_busmap": card_busmap = c
		
	assert(card_cry != null and card_busmap != null, "Bước 1 phải có card_cry và card_busmap!")
	story_view._attempt_fill_blank(card_cry, "blank_1")
	
	assert("Khóc hông giải quyết được gì" in story_view.cat_bubble.text, "Mèo phải nhắc nhở khi kéo thẻ khóc lóc!")
	print("[PASS 3] Phản hồi khi chọn sai hoạt động chuẩn xác: '", story_view.cat_bubble.text, "'")
	
	await get_tree().create_timer(0.3).timeout
	if vp and vp.get_texture():
		var img1_fail = vp.get_texture().get_image()
		if img1_fail:
			img1_fail.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_story_step_1_fail_reaction.png")
			print("Saved: screenshot_story_step_1_fail_reaction.png")
			
	# 4. Điền thẻ ĐÚNG: card_busmap (Tra cứu ứng dụng BusMap)
	story_view._attempt_fill_blank(card_busmap, "blank_1")
	assert(story_view.filled_blanks.has("blank_1"), "Ô blank_1 phải được điền thành công!")
	assert("Méo-tick!" in story_view.cat_bubble.text, "Mèo phải reo mừng Méo-tick khi điền đúng!")
	print("[PASS 4] Điền đúng Thẻ A (BusMap) thành công, ô trống được chuyển sang Thẻ Đã Gắn!")
	
	await get_tree().create_timer(0.3).timeout
	if vp and vp.get_texture():
		var img1_win = vp.get_texture().get_image()
		if img1_win:
			img1_win.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_story_step_1_correct.png")
			print("Saved: screenshot_story_step_1_correct.png")
			
	# Đợi chuyển sang Bước 2
	await get_tree().create_timer(1.3).timeout
	assert(story_view.current_step_idx == 1, "Phải tự động chuyển sang Bước 2!")
	print("[PASS 5] Tự động chuyển mạch truyện sang Bước 2: Vẫy Xe Và Lên Cửa Trước!")
	
	# 5. Điền Bước 2: card_wave (blank_2) và card_cash (blank_3)
	var step2 = story_data["steps"][1]
	var card_wave = null
	var card_cash = null
	for c in step2["cards"]:
		if c["id"] == "card_wave": card_wave = c
		elif c["id"] == "card_cash": card_cash = c
		
	story_view._attempt_fill_blank(card_wave, "blank_2")
	story_view._attempt_fill_blank(card_cash, "blank_3")
	assert(story_view.filled_blanks.size() == 2, "Bước 2 phải điền đủ 2 ô trống!")
	print("[PASS 6] Điền đúng 2 ô trống Bước 2: Vẫy xe dứt khoát 50m & Cầm sẵn 5k tiền lẻ!")
	
	await get_tree().create_timer(0.3).timeout
	if vp and vp.get_texture():
		var img2 = vp.get_texture().get_image()
		if img2:
			img2.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_story_step_2_bus_boarded.png")
			print("Saved: screenshot_story_step_2_bus_boarded.png")
			
	# Đợi chuyển sang Bước 3
	await get_tree().create_timer(1.3).timeout
	assert(story_view.current_step_idx == 2, "Phải tự động chuyển sang Bước 3!")
	print("[PASS 7] Tự động chuyển mạch truyện sang Bước 3: Giữ An Toàn Và Xuống Trạm!")
	
	# 6. Điền Bước 3: card_backpack (blank_4) và card_bell (blank_5)
	var step3 = story_data["steps"][2]
	var card_backpack = null
	var card_bell = null
	for c in step3["cards"]:
		if c["id"] == "card_backpack": card_backpack = c
		elif c["id"] == "card_bell": card_bell = c
		
	story_view._attempt_fill_blank(card_backpack, "blank_4")
	story_view._attempt_fill_blank(card_bell, "blank_5")
	assert(story_view.filled_blanks.size() == 2, "Bước 3 phải điền đủ 2 ô trống!")
	print("[PASS 8] Điền đúng 2 ô trống Bước 3: Ôm ba lô trước ngực & Bấm chuông đỏ 100m!")
	
	await get_tree().create_timer(0.3).timeout
	if vp and vp.get_texture():
		var img3 = vp.get_texture().get_image()
		if img3:
			img3.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_story_step_3_arrival.png")
			print("Saved: screenshot_story_step_3_arrival.png")
			
	# 7. Hoàn thành chuyến đi & kiểm tra Victory Modal
	await get_tree().create_timer(1.4).timeout
	assert(story_view.victory_modal.visible == true, "VictoryModal phải hiển thị khi hoàn thành câu chuyện!")
	assert("Thổ Địa Tuyến 08" in GameManager.badges, "Phải mở khóa danh hiệu Thổ Địa Tuyến 08!")
	print("[PASS 9] Màn hình chúc mừng xuất hiện, vinh danh 'Thổ Địa Tuyến 08' & trao thưởng thành công!")
	
	if vp and vp.get_texture():
		var img_win = vp.get_texture().get_image()
		if img_win:
			img_win.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_story_victory_modal.png")
			print("Saved: screenshot_story_victory_modal.png")
			
	print("\n========================================================")
	print("   TOÀN BỘ KIỂM THỬ INTERACTIVE STORYTELLING PASS 100%!   ")
	print("========================================================")
	get_tree().quit()
