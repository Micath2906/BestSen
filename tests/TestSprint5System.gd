extends Node

var _pass_count: int = 0
var _fail_count: int = 0

func _assert(cond: bool, msg: String) -> void:
	if cond:
		_pass_count += 1
		print("[PASS %d] %s" % [_pass_count, msg])
	else:
		_fail_count += 1
		printerr("[FAIL] %s" % msg)

func _ready() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ SPRINT 5: SYS-01 & SYS-02 ===")
	await get_tree().process_frame
	await _test_sys_01_encrypted_save()
	await _test_sys_02_audio_buses_haptics_and_pause_modal()

	# Khôi phục trạng thái sạch sẽ sau test
	GameManager.reset_save_data()
	SoundManager.set_bgm_enabled(true)
	SoundManager.set_sfx_enabled(true)
	SoundManager.set_bgm_volume(0.8)
	SoundManager.set_sfx_volume(1.0)
	SoundManager.set_haptic_enabled(true)

	print("=== SPRINT 5 SUMMARY: %d PASS, %d FAIL ===" % [_pass_count, _fail_count])
	if _fail_count == 0:
		print("=== SPRINT 5 VERIFICATION: ALL PASSED! ===")
		get_tree().quit(0)
	else:
		get_tree().quit(1)

func _test_sys_01_encrypted_save() -> void:
	GameManager.fish = 321
	GameManager.current_day = 14
	GameManager.save_game()

	_assert(FileAccess.file_exists(GameManager.BEST_SEN_SAVE_PATH),
		"SYS-01: File mã hóa user://best_sen_data.save được tạo qua atomic write")
	_assert(GameManager.is_encrypted_save_valid(),
		"SYS-01: File mã hóa vượt qua kiểm tra AES-256 + MD5")

	# Benchmark thời gian ghi save (< 5ms trên luồng encrypted atomic save)
	var min_usec := 999999
	for _i in range(5):
		GameManager.save_game()
		min_usec = mini(min_usec, GameManager.last_encrypted_write_usec)
	var min_ms := float(min_usec) / 1000.0
	_assert(min_ms < 5.0, "SYS-01: Thời gian ghi save atomic AES+MD5 < 5ms (min=%.2f ms)" % min_ms)

	# Kiểm tra file trên đĩa thực sự được mã hóa (không chứa JSON văn bản thuần)
	var raw_bytes := FileAccess.get_file_as_bytes(GameManager.BEST_SEN_SAVE_PATH)
	var raw_ascii := raw_bytes.get_string_from_ascii()
	_assert(raw_bytes.size() > 32 and not ("fish" in raw_ascii),
		"SYS-01: Nội dung trên đĩa bị mã hóa AES-256 (không đọc được plaintext JSON)")

	# Kiểm tra Unified Player Profile schema
	var prof := GameManager.build_player_profile()
	_assert(prof.get("schema_version", 0) == 3 and prof.has("identity") and prof.has("stats") and prof.has("room") and prof.has("audio_settings"),
		"SYS-01: Schema player_profile thống nhất đầy đủ identity/stats/progress/room/audio_settings")

	# Kiểm tra phát hiện & từ chối file giả mạo MD5
	var f_enc := FileAccess.open_encrypted(GameManager.BEST_SEN_SAVE_PATH, FileAccess.READ, GameManager._get_aes_key_bytes())
	var txt := f_enc.get_as_text()
	f_enc.close()
	var parts := txt.split("|", true, 2)
	var tampered_txt := "BS3|deadbeef000000000000000000000000|" + parts[2]
	var f_w := FileAccess.open_encrypted(GameManager.BEST_SEN_SAVE_PATH, FileAccess.WRITE, GameManager._get_aes_key_bytes())
	f_w.store_string(tampered_txt)
	f_w.close()
	_assert(not GameManager.is_encrypted_save_valid(),
		"SYS-01: Từ chối payload bị sai lệch MD5 checksum")

	# Kiểm tra từ chối file rác nhị phân bị hỏng hoàn toàn
	var abs_save := ProjectSettings.globalize_path(GameManager.BEST_SEN_SAVE_PATH)
	var corrupt_f := FileAccess.open(GameManager.BEST_SEN_SAVE_PATH, FileAccess.WRITE)
	corrupt_f.store_buffer(PackedByteArray([0xDE, 0xAD, 0xBE, 0xEF, 0x00, 0x01, 0x02]))
	corrupt_f.close()
	_assert(GameManager._try_load_encrypted_save().is_empty(),
		"SYS-01: An toàn không crash khi gặp file best_sen_data.save hỏng nhị phân")

	# Kiểm tra Auto-Migration từ legacy user://save_game.json khi mất file mã hóa
	DirAccess.remove_absolute(abs_save)
	_assert(not FileAccess.file_exists(GameManager.BEST_SEN_SAVE_PATH),
		"SYS-01: Xóa file mã hóa để chuẩn bị test auto-migration từ JSON cũ")

	GameManager.fish = 777
	GameManager.current_day = 28
	GameManager.save_game() # Tạo save_game.json có 777 cá
	DirAccess.remove_absolute(abs_save) # Xóa bản mã hóa, chỉ giữ save_game.json cũ
	GameManager.fish = 10
	GameManager.current_day = 1
	GameManager.load_game()
	_assert(GameManager.fish == 777 and GameManager.current_day == 28,
		"SYS-01: Load thành công dữ liệu legacy (fish=777, day=28)")
	_assert(GameManager.was_migrated_from_legacy and GameManager.last_save_loaded_source == "legacy_migrated",
		"SYS-01: Đánh dấu auto-migration từ save_game.json sang best_sen_data.save")
	_assert(GameManager.is_encrypted_save_valid(),
		"SYS-01: File mã hóa best_sen_data.save tự động được tạo và hợp lệ sau migration")

func _test_sys_02_audio_buses_haptics_and_pause_modal() -> void:
	var idx_master := AudioServer.get_bus_index("Master")
	var idx_bgm := AudioServer.get_bus_index("BGM")
	var idx_sfx := AudioServer.get_bus_index("SFX")
	_assert(idx_master == 0 and idx_bgm != -1 and idx_sfx != -1,
		"SYS-02: Hệ thống đủ 3 Bus AudioServer (Master, BGM, SFX)")
	_assert(AudioServer.get_bus_send(idx_bgm) == "Master" and AudioServer.get_bus_send(idx_sfx) == "Master",
		"SYS-02: Bus BGM & SFX định tuyến sạch về Master")

	_assert(SoundManager.bgm_channel.bus == "BGM" and SoundManager.sfx_channel.bus == "SFX" and SoundManager.ui_channel.bus == "SFX" and SoundManager.cat_channel.bus == "SFX",
		"SYS-02: Các AudioStreamPlayer gán đúng Bus BGM / SFX")

	SoundManager.set_sfx_enabled(true)
	SoundManager.set_sfx_volume(1.0)
	var sfx_db := AudioServer.get_bus_volume_db(idx_sfx)
	_assert(sfx_db <= -5.99,
		"SYS-02: Trần an toàn âm lượng SFX chuẩn hóa <= -6.0 dBFS (got %.2f dB)" % sfx_db)

	# Structured Haptics
	SoundManager.set_haptic_enabled(true)
	SoundManager.vibrate_tap()
	_assert(SoundManager.last_haptic_pattern == [15] and SoundManager.last_haptic_ms == 15,
		"SYS-02: Haptic chạm thẻ (tap) đúng nhịp 15ms")

	SoundManager.vibrate_confirm()
	_assert(SoundManager.last_haptic_pattern == [30, 50, 30],
		"SYS-02: Haptic xác nhận kép đúng nhịp 30-50-30ms")

	SoundManager.play_error_chime()
	_assert(SoundManager.last_haptic_pattern == [25] and SoundManager.last_haptic_ms == 25,
		"SYS-02: Âm báo lỗi nhẹ (error chime) kèm rung báo 25ms")

	SoundManager.last_haptic_ms = 0
	SoundManager.set_haptic_enabled(false)
	SoundManager.vibrate_tap()
	_assert(SoundManager.last_haptic_ms == 0,
		"SYS-02: Tắt Haptic chặn hoàn toàn kích hoạt rung mới")

	# PauseModal UI & Toggles
	var pm_scn: PackedScene = load("res://scenes/PauseModal.tscn")
	var pm = pm_scn.instantiate()
	add_child(pm)
	await get_tree().process_frame

	var p_sb := (pm.panel as PanelContainer).get_theme_stylebox("panel")
	_assert(p_sb is StyleBoxTexture and p_sb.texture == preload("res://assets/UI/CatUIPaid/slices/modal_popup_beige.png"),
		"SYS-02: PauseModal skin StyleBoxTexture dùng modal_popup_beige.png")
	_assert(pm.check_bgm != null and pm.check_sfx != null and pm.check_haptic != null,
		"SYS-02: PauseModal có đủ 3 công tắc độc lập BGM, SFX, Haptic")

	pm.check_bgm.button_pressed = false
	pm.check_bgm.toggled.emit(false)
	_assert(not SoundManager.bgm_enabled and AudioServer.is_bus_mute(idx_bgm),
		"SYS-02: Công tắc BGM tắt tiếng riêng Bus BGM")

	pm.check_sfx.button_pressed = false
	pm.check_sfx.toggled.emit(false)
	_assert(not SoundManager.sfx_enabled and AudioServer.is_bus_mute(idx_sfx),
		"SYS-02: Công tắc SFX tắt tiếng riêng Bus SFX")

	pm.check_haptic.button_pressed = true
	pm.check_haptic.toggled.emit(true)
	_assert(SoundManager.haptic_enabled,
		"SYS-02: Công tắc Haptic bật/tắt độc lập")

	pm.queue_free()
	await get_tree().process_frame
