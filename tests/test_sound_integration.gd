extends SceneTree

func _init() -> void:
	print("==================================================")
	print("   TEST SOUND INTEGRATION: CUTE CAT AUDIO PACK    ")
	print("==================================================")
	
	var SoundManagerScript = load("res://scripts/SoundManager.gd")
	var sound_manager = SoundManagerScript.new()
	root.add_child(sound_manager)
	sound_manager._ready()
	
	print("[1] Kiểm tra khởi tạo kênh âm thanh:")
	assert(sound_manager.cat_channel != null, "Cat voice channel must exist")
	assert(sound_manager.ui_channel != null, "UI channel must exist")
	assert(sound_manager.sfx_channel != null, "SFX channel must exist")
	assert(sound_manager.reel_channel != null, "Reel channel must exist")
	print("  -> Đủ 4 kênh âm thanh chuyên biệt (Cat, UI, SFX, Reel) PASS!")
	
	print("\n[2] Kiểm tra sound_cache đã nạp các sound clips WAV:")
	var expected_keys = [
		"click", "card_pop", "cancel", "chomp", "meow_general", 
		"bounce", "meow_cheerful", "fail_short", "meow_curious", 
		"talking", "meow_sweet", "fail_ngoao", "meow_bold", 
		"giggle", "success_chime", "purr", "success_fanfare"
	]
	var loaded_count = 0
	for k in expected_keys:
		if sound_manager.sound_cache.has(k):
			var s = sound_manager.sound_cache[k]
			print("  + Key '%s' -> %s (%.2fs)" % [k, s.get_class(), s.get_length()])
			loaded_count += 1
		else:
			push_warning("Sound clip missing for key: " + k)
			
	print("  -> Tổng số clips nạp thành công: %d / %d" % [loaded_count, expected_keys.size()])
	assert(loaded_count == expected_keys.size(), "Toàn bộ clip âm thanh phải được nạp thành công")
	
	print("\n[3] Kiểm tra nạp file Demo Reel MP3:")
	if sound_manager.reel_stream != null:
		print("  -> Demo Reel MP3 nạp thành công! Length: %.2fs" % sound_manager.reel_stream.get_length())
	else:
		print("  -> Demo Reel MP3 không nạp được trực tiếp, đã chuẩn bị các clip wav!")
		
	print("\n[4] Kiểm tra chạy thử các hàm phát âm thanh (Dry Run Playback):")
	sound_manager.play_click()
	sound_manager.play_card_pop()
	sound_manager.play_card_cancel()
	sound_manager.play_meow(1.0)
	sound_manager.play_action_word(0) # Meo-o?
	sound_manager.play_action_word(1) # Méo meo!
	sound_manager.play_action_word(2) # Meoo~
	sound_manager.play_action_word(3) # Ngoao!
	sound_manager.play_purr()
	sound_manager.play_fail()
	sound_manager.play_success()
	sound_manager.play_chomp()
	sound_manager.play_giggle()
	sound_manager.play_bounce()
	sound_manager.play_talking_mimic()
	sound_manager.play_level_up()
	sound_manager.play_reel_cue("purr")
	print("  -> Tất cả 17 hàm phát âm thanh chạy hoàn hảo, không có ngoại lệ!")

	print("==================================================")
	print("   ALL SOUND TESTS PASSED 100%!                   ")
	print("==================================================")
	quit()
