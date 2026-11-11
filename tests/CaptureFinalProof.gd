extends Control

const ARTIFACT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/"

func _ready() -> void:
	print(">>> BẮT ĐẦU CHỤP ẢNH MINH CHỨNG TƯƠNG TÁC PHÒNG & REDESIGN BÀI 1 <<<")
	
	# [1] CHỤP TOÀN CẢNH PHÒNG CLASSIC VỚI POCHI TRONG ĐỆM, BÁT ĂN VỪA VẶN, TRỤ SISAL THẬT
	GameManager.selected_avatar_id = 8 # Mochi
	GameManager.set_classic_bg(1)
	
	var room_scene = load("res://scenes/IsometricRoomView.tscn")
	var room = room_scene.instantiate()
	add_child(room)
	
	# Đặt Mochi ở vị trí giữa sàn thoáng đãng
	var cat = room.get_node("YSortEntities/IsoCat")
	cat.position = Vector2(270.0, 785.0)
	cat.set_state(cat.State.IDLE)
	
	await get_tree().create_timer(0.6).timeout
	var img_room = get_viewport().get_texture().get_image()
	img_room.save_png(ARTIFACT_DIR + "screenshot_classic_room_furniture_interactions.png")
	print("Đã chụp: screenshot_classic_room_furniture_interactions.png")
	
	# Crop riêng mặt sàn phòng trọ để thấy rõ 4 món nội thất & Mochi, Pochi
	var crop_floor = img_room.get_region(Rect2i(0, 660, 540, 240))
	crop_floor.save_png(ARTIFACT_DIR + "screenshot_room_floor_closeup.png")
	
	# [2] Tương tác: Mèo cào móng vào Trụ Sisal Thật
	var post = room.get_node("YSortEntities/ScratchPost")
	cat.position = post.position + Vector2(-28, 6)
	cat.anim_sprite.flip_h = false
	cat.set_state(cat.State.SCRATCH)
	
	await get_tree().create_timer(0.3).timeout
	var img_scratch = get_viewport().get_texture().get_image()
	img_scratch.save_png(ARTIFACT_DIR + "screenshot_cat_scratching_post.png")
	print("Đã chụp: screenshot_cat_scratching_post.png")
	
	# [3] Tương tác: Mèo đứng ăn hạt tại khay đôi
	var tray = room.get_node("YSortEntities/DualTray")
	cat.position = tray.position + Vector2(-28, 4)
	cat.anim_sprite.flip_h = false
	cat.set_state(cat.State.EAT)
	
	await get_tree().create_timer(0.3).timeout
	var img_eat = get_viewport().get_texture().get_image()
	img_eat.save_png(ARTIFACT_DIR + "screenshot_cat_eating_tray.png")
	print("Đã chụp: screenshot_cat_eating_tray.png")
	
	# [4] Tương tác: Mochi ngủ cùng Pochi trong đệm ấm
	var bed = room.get_node("YSortEntities/CushionBed")
	cat.position = bed.position + Vector2(25, 10)
	cat.anim_sprite.flip_h = false
	cat.set_state(cat.State.SLEEP)
	
	await get_tree().create_timer(0.3).timeout
	var img_sleep = get_viewport().get_texture().get_image()
	img_sleep.save_png(ARTIFACT_DIR + "screenshot_cats_sleeping_bed.png")
	print("Đã chụp: screenshot_cats_sleeping_bed.png")
	
	room.queue_free()
	
	# [5] CHỤP MÀN HÌNH BÀI 1 ĐÃ REDESIGN TOÀN DIỆN
	var lesson_scene = load("res://scenes/LessonView.tscn")
	var lv = lesson_scene.instantiate()
	add_child(lv)
	lv.size = Vector2(480, 800)
	lv.load_lesson(1)
	
	await get_tree().create_timer(0.5).timeout
	var img_lesson = get_viewport().get_texture().get_image()
	img_lesson.save_png(ARTIFACT_DIR + "screenshot_lesson_1_redesign_full.png")
	print("Đã chụp: screenshot_lesson_1_redesign_full.png")
	
	# Chọn thử thẻ để kiểm tra bong bóng gợi ý
	var card_to_tap = lv.shuffled_cards[0]
	lv._on_card_tap_selected(card_to_tap)
	await get_tree().create_timer(0.3).timeout
	var img_lesson_tap = get_viewport().get_texture().get_image()
	img_lesson_tap.save_png(ARTIFACT_DIR + "screenshot_lesson_1_card_selected.png")
	print("Đã chụp: screenshot_lesson_1_card_selected.png")
	
	# Nối thử 2 thẻ (Thẻ 1 và Thẻ 3 ba lô)
	for c in lv.shuffled_cards:
		if c["step"] == 1:
			lv._attempt_match_card_to_slot(c, 0)
		elif c["step"] == 3:
			lv._attempt_match_card_to_slot(c, 2)
			
	await get_tree().create_timer(0.3).timeout
	var img_lesson_matched = get_viewport().get_texture().get_image()
	img_lesson_matched.save_png(ARTIFACT_DIR + "screenshot_lesson_1_backpack_matched.png")
	print("Đã chụp: screenshot_lesson_1_backpack_matched.png")
	
	lv.queue_free()
	print(">>> HOÀN THÀNH TẤT CẢ ẢNH MINH CHỨNG MỚI NHẤT! <<<")
	get_tree().quit(0)
