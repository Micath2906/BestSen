extends Node

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("ASSERT FAILED: " + msg)
		printerr("[FAIL] " + msg)
		get_tree().quit(1)
	else:
		print("[PASS] " + msg)

func _ready() -> void:
	print("=== TEST SPRINT 1: UI-01, UI-02, UI-03 ===")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var orig_hunger: int = GameManager.hunger

	# --- UI-01: CatProfileHUD & Main Safe Area ---
	var hud_scene = preload("res://scenes/CatProfileHUD.tscn").instantiate()
	add_child(hud_scene)
	await get_tree().process_frame

	var hud_container = hud_scene.get_node_or_null("HUDContainer") as NinePatchRect
	_assert(hud_container != null, "UI-01: HUDContainer là NinePatchRect")
	_assert(hud_container.patch_margin_left == 14 and hud_container.patch_margin_top == 10 and hud_container.patch_margin_right == 14 and hud_container.patch_margin_bottom == 10,
		"UI-01: 9-patch margin đúng (14,10,14,10)")
	_assert(hud_scene.current_hud_state == hud_scene.HUDState.NORMAL, "UI-01: Mặc định HUDState.NORMAL")

	hud_scene.set_hud_state(hud_scene.HUDState.MINIGAME_ACTIVE)
	_assert(hud_scene.current_hud_state == hud_scene.HUDState.MINIGAME_ACTIVE, "UI-01: Chuyển sang MINIGAME_ACTIVE")
	_assert(hud_scene.mini_hud_panel != null and hud_scene.mini_hud_panel.visible, "UI-01: MiniHudPanel hiển thị ở góc trên trái")
	_assert(not hud_container.visible, "UI-01: HUDContainer thu gọn khi minigame active")
	hud_scene.update_minigame_hud(15.2, 0.75)

	hud_scene.set_hud_state(hud_scene.HUDState.NORMAL)
	_assert(hud_container.visible and not hud_scene.mini_hud_panel.visible, "UI-01: Khôi phục HUDState.NORMAL")

	# Low hunger 2Hz sine wave offset ±2px without popup
	GameManager.hunger = 80
	hud_scene.update_hud()
	await get_tree().process_frame
	hud_scene._hunger_base_cached = false
	hud_scene._hunger_jitter_phase = 0.0
	GameManager.hunger = 15
	hud_scene.update_hud()
	hud_scene._process(0.125) # sin(TAU * 2.0 * 0.125) = sin(PI/2) = 1.0 -> +2.0px
	var offset_diff: float = absf(hud_scene.hunger_bar.position.x - hud_scene._hunger_bar_base_x)
	_assert(absf(offset_diff - 2.0) < 0.15, "UI-01: Thanh đói <20%% rung sóng sine ±2px tại 2Hz (diff=%.2f)" % offset_diff)
	GameManager.hunger = 80
	hud_scene.update_hud()
	hud_scene._process(0.016)
	_assert(absf(hud_scene.hunger_bar.position.x - hud_scene._hunger_bar_base_x) < 0.05, "UI-01: Trả thanh đói về vị trí gốc khi hồi phục (actual=%.2f, base=%.2f)" % [hud_scene.hunger_bar.position.x, hud_scene._hunger_bar_base_x])
	GameManager.hunger = orig_hunger
	hud_scene.queue_free()

	# --- UI-01 + UI-02: Main Safe Area & Tab Preservation ---
	var main_scene = preload("res://scenes/Main.tscn").instantiate()
	add_child(main_scene)
	await get_tree().process_frame

	main_scene.apply_safe_area_margins(44.0, 34.0)
	_assert(main_scene.cat_profile_hud.offset_top >= 44.0 and absf(main_scene.views_container.offset_top - 44.0) < 0.1,
		"UI-01: Main.apply_safe_area_margins giữ top>=44dp (hud=%.1f, views=%.1f)" % [main_scene.cat_profile_hud.offset_top, main_scene.views_container.offset_top])
	_assert(absf(main_scene.bottom_paw_menu.offset_bottom + 34.0) < 0.1,
		"UI-01: Main.apply_safe_area_margins giữ bottom=34dp (offset=%.1f)" % main_scene.bottom_paw_menu.offset_bottom)
	var bottom_menu = main_scene.bottom_paw_menu
	_assert(bottom_menu != null, "UI-02: BottomPawMenu tồn tại trong Main")
	var dock_h: float = bottom_menu.dock_panel.size.y
	_assert(absf(dock_h - 64.0) < 0.1, "UI-02: DockPanel cao đúng 64dp (%.1f)" % dock_h)
	for btn in [bottom_menu.btn_home, bottom_menu.btn_food, bottom_menu.btn_play, bottom_menu.btn_learn, bottom_menu.btn_handbook]:
		_assert(btn.size.x >= 56.0 and btn.size.y >= 56.0, "UI-02: Touch target %s >= 56x56dp (%.1fx%.1f)" % [btn.name, btn.size.x, btn.size.y])
	_assert(bottom_menu.sliding_paw_indicator != null, "UI-02: Con trỏ dấu chân SlidingPawIndicator tồn tại")

	_assert(main_scene.cached_room_view != null, "UI-02: Phòng trọ khởi tạo sẵn trong cached_room_view")
	var room_id_before: int = main_scene.cached_room_view.get_instance_id()
	main_scene.switch_to_map()
	_assert(main_scene.cached_room_view.get_instance_id() == room_id_before and not main_scene.cached_room_view.visible,
		"UI-02: Chuyển tab giữ nguyên instance phòng trọ (không giải phóng)")
	var t0: int = Time.get_ticks_usec()
	main_scene.switch_to_room()
	var t_switch_ms: float = float(Time.get_ticks_usec() - t0) / 1000.0
	_assert(main_scene.cached_room_view.get_instance_id() == room_id_before and main_scene.cached_room_view.visible,
		"UI-02: Quay lại Phòng trọ không load lại scene từ đầu (%.2f ms)" % t_switch_ms)
	_assert(t_switch_ms < 16.0, "UI-02: Tốc độ phản hồi chuyển về phòng < 16ms (actual=%.2f ms)" % t_switch_ms)
	main_scene.queue_free()

	# --- UI-03: CozyDialogBox & JSON Schema & IsometricCat Typewriter ---
	var dlg: Dictionary = GameManager.get_cozy_dialog("metro_fail_01")
	_assert(not dlg.is_empty() and str(dlg.get("pedagogical_tip", "")) != "", "UI-03: Tải schema JSON cozy_dialogs.json đầy đủ pedagogical_tip")
	_assert(str(dlg.get("text", "")).length() <= 60, "UI-03: metro_fail_01 <= 60 ký tự")

	var cozy_box = preload("res://scenes/ui/CozyDialogBox.tscn").instantiate()
	add_child(cozy_box)
	await get_tree().process_frame
	_assert(cozy_box.show_dialog_by_id("metro_fail_01", 12.0, false), "UI-03: Hiển thị metro_fail_01 lên CozyDialogBox")
	_assert(cozy_box.dialog_label.get_theme_constant("outline_size") == 1, "UI-03: Font dialog có outline 1px")
	_assert(cozy_box.dialog_label.get_theme_color("font_outline_color") == Color("#3d251e"), "UI-03: Màu outline đúng #3d251e")
	cozy_box._process(0.15)
	_assert(cozy_box.dialog_label.visible_characters == 5, "UI-03: Typewriter 0.03s/ký tự hiện 5 ký tự sau 0.15s (actual=%d)" % cozy_box.dialog_label.visible_characters)
	cozy_box.handle_tap()
	_assert(cozy_box.dialog_label.visible_characters == -1, "UI-03: Chạm vào khung thoại hiện full text ngay lập tức")
	var chunks = cozy_box.split_cozy_chunks("Đây là một câu thoại rất dài để kiểm tra tự động ngắt đoạn không vượt quá sáu mươi ký tự mỗi lần hiển thị.")
	_assert(chunks.size() >= 2, "UI-03: Câu >60 ký tự được chia thành %d đoạn" % chunks.size())
	for c in chunks:
		_assert(c.length() <= 60, "UI-03: Mỗi đoạn sau tách <= 60 ký tự (len=%d)" % c.length())
	cozy_box.queue_free()

	var cat = preload("res://scenes/IsometricCat.tscn").instantiate()
	add_child(cat)
	await get_tree().process_frame
	cat.show_dialogue("Ngủ một giấc cho khỏe nhé!", 4.0)
	_assert(cat._is_typing_dialogue, "UI-03: IsometricCat bật typewriter khi gọi show_dialogue()")
	cat._process(0.12)
	_assert(cat.dialogue_label.visible_characters >= 4, "UI-03: Typewriter IsometricCat chạy theo delta")
	cat.reveal_dialogue_instantly()
	_assert(not cat._is_typing_dialogue and cat.dialogue_label.visible_characters == -1, "UI-03: reveal_dialogue_instantly() hoàn thành tức thì")
	var tail_x_right: float = cat.bubble_tail.offset_left
	cat.last_facing_right = false
	cat._align_bubble_tail()
	_assert(cat.bubble_tail.offset_left != tail_x_right, "UI-03: Đuôi bong bóng thoại IsometricCat đổi hướng theo miệng mèo")
	cat.queue_free()

	print("=== SPRINT 1 VERIFICATION: ALL PASSED! ===")
	get_tree().quit(0)
