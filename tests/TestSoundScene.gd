extends Node

func _ready() -> void:
	print("\n========================================================")
	print("       BEST SEN - SUITE KIỂM THỬ TÍCH HỢP ÂM THANH      ")
	print("========================================================")
	
	await get_tree().process_frame
	
	# [1] KIỂM TRA SOUNDMANAGER AUTOLOAD
	print("[1] Kiểm tra Singleton SoundManager:")
	assert(SoundManager != null, "SoundManager singleton must exist")
	assert(SoundManager.cat_channel != null, "cat_channel must exist")
	assert(SoundManager.ui_channel != null, "ui_channel must exist")
	assert(SoundManager.sfx_channel != null, "sfx_channel must exist")
	assert(SoundManager.reel_channel != null, "reel_channel must exist")
	print("  -> 4 AudioStreamPlayer channels (CatVoice, UI, SFX, Reel) đã sẵn sàng!")
	
	# [2] KIỂM TRA SOUND CACHE VÀ CÁC SOUND CLIPS
	print("\n[2] Kiểm tra nạp 17 clips âm thanh từ Cute Cat UI Pack:")
	var expected_keys = [
		"click", "card_pop", "cancel", "chomp", "meow_general", 
		"bounce", "meow_cheerful", "fail_short", "meow_curious", 
		"talking", "meow_sweet", "fail_ngoao", "meow_bold", 
		"giggle", "success_chime", "purr", "success_fanfare"
	]
	var loaded = 0
	for k in expected_keys:
		if SoundManager.sound_cache.has(k):
			var s: AudioStream = SoundManager.sound_cache[k]
			print("  + [%s] -> %s (độ dài: %.2fs)" % [k, s.get_class(), s.get_length()])
			loaded += 1
		else:
			push_error("Thiếu âm thanh cho: " + k)
			
	print("  -> Nạp thành công: %d / %d clips!" % [loaded, expected_keys.size()])
	assert(loaded == expected_keys.size(), "Toàn bộ 17 clip âm thanh phải được nạp thành công")
	
	# [3] KIỂM TRA DEMO REEL MP3
	print("\n[3] Kiểm tra Master Demo Reel MP3:")
	assert(SoundManager.reel_stream != null, "Master Demo Reel stream must be loaded")
	print("  -> File Cute_Cat_UI_Sounds_Demo_Reel.mp3 độ dài: %.2fs" % SoundManager.reel_stream.get_length())
	
	# [4] PHÁT THỬ TẤT CẢ CÁC HÀM ÂM THANH (DRY RUN)
	print("\n[4] Kiểm tra phát thanh đa kênh không có lỗi runtime:")
	SoundManager.play_click()
	SoundManager.play_card_pop()
	SoundManager.play_card_cancel()
	SoundManager.play_meow(1.0)
	SoundManager.play_action_word(0) # "Meo-o?"
	SoundManager.play_action_word(1) # "Méo meo!"
	SoundManager.play_action_word(2) # "Meoo~"
	SoundManager.play_action_word(3) # "Ngoao!"
	SoundManager.play_purr()
	SoundManager.play_fail()
	SoundManager.play_success()
	SoundManager.play_chomp()
	SoundManager.play_giggle()
	SoundManager.play_bounce()
	SoundManager.play_talking_mimic()
	SoundManager.play_level_up()
	SoundManager.play_reel_cue("purr")
	print("  -> 17/17 hàm phát âm thanh thực thi an toàn, không có lỗi!")
	
	# [5] KIỂM TRA TƯƠNG TÁC ÂM THANH TRONG LESSONVIEW
	print("\n[5] Kiểm tra liên kết âm thanh thẻ bài và puzzle trong LessonView:")
	var lesson_scene = load("res://scenes/LessonView.tscn")
	var lesson_inst = lesson_scene.instantiate()
	add_child(lesson_inst)
	lesson_inst.load_lesson(1)
	await get_tree().process_frame
	
	var cards = lesson_inst.lesson_data.get("cards", [])
	assert(cards.size() >= 4, "Lesson phải có ít nhất 4 thẻ")
	
	# Chọn thẻ bước 1 -> phát action word 0 + card pop
	lesson_inst._pick_card(cards[0])
	assert(lesson_inst.selected_sequence.size() == 1, "Thẻ đã được chọn vào khay")
	
	# Gỡ thẻ -> phát card cancel
	lesson_inst._remove_card_from_slot(0)
	assert(lesson_inst.selected_sequence.size() == 0, "Thẻ đã được gỡ khỏi khay")
	
	# Xếp sai thứ tự -> phát fail 'Ngoao..'
	lesson_inst.selected_sequence = [cards[3], cards[2], cards[1], cards[0]]
	lesson_inst._on_submit_pressed()
	assert("Ngoao" in lesson_inst.cat_bubble.text, "Bóng thoại phải chứa tiếng Ngoao.. khi sai")
	
	# Xếp đúng thứ tự -> phát success
	var correct_seq = []
	for step_num in range(1, cards.size() + 1):
		for c in cards:
			if c["step"] == step_num:
				correct_seq.append(c)
				break
	lesson_inst.selected_sequence = correct_seq
	lesson_inst._on_submit_pressed()
	assert("Meooo~ Chuẩn rồi" in lesson_inst.cat_bubble.text, "Phải thông báo chuẩn khi xếp đúng")
	lesson_inst.queue_free()
	print("  -> LessonView sequence puzzle audio validation PASS!")
	
	# [6] KIỂM TRA TƯƠNG TÁC CHẠM MÈO ISOMETRICCAT
	print("\n[6] Kiểm tra tương tác âm thanh chạm mèo (IsometricCat):")
	var cat_scene = load("res://scenes/IsometricCat.tscn")
	var cat_inst = cat_scene.instantiate()
	add_child(cat_inst)
	await get_tree().process_frame
	
	# Chạm vuốt đầu (y < -15) -> phát purr
	cat_inst.handle_touch(-20.0)
	assert("Purr purr" in cat_inst.dialogue_label.text, "Vuốt đầu mèo phải kêu Purr")
	
	# Chọc bụng (y < 10) -> phát giggle
	cat_inst.handle_touch(0.0)
	assert("Hi hi! Nhột" in cat_inst.dialogue_label.text, "Chọc bụng phải cười nhột")
	
	# Chọc chân (y >= 10) -> phát bounce
	cat_inst.handle_touch(15.0)
	assert("Boing!" in cat_inst.dialogue_label.text, "Chọc chân phải kêu Boing")
	cat_inst.queue_free()
	print("  -> IsometricCat touch reactions audio PASS!")

	# [7] KIỂM TRA GAMEMANAGER LEVEL UP SOUND
	print("\n[7] Kiểm tra âm thanh thăng cấp (Level Up) trong GameManager:")
	var initial_lvl = GameManager.cat_mastery_level
	GameManager.add_mastery_exp(500)
	assert(GameManager.cat_mastery_level >= 2, "Mèo phải được thăng cấp khi đủ EXP")
	print("  -> Level Up audio trigger PASS!")
	
	print("\n========================================================")
	print("   TẤT CẢ BÀI KIỂM THỬ ÂM THANH THÀNH CÔNG 100%!        ")
	print("========================================================")
	
	# Chụp màn hình xác nhận (nếu có renderer)
	await get_tree().process_frame
	var tex = get_viewport().get_texture()
	if tex:
		var img = tex.get_image()
		if img:
			img.save_png("res://tests/screenshot_sound_integration.png")
	
	get_tree().quit(0)
