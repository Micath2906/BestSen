extends Node

## TestUXOverhaul.gd - Kiểm thử toàn diện 7 Task Nâng Cấp UX/Game Design (Tasks 1..7)

const MinigameBaseScript = preload("res://scripts/minigames/MinigameBase.gd")
const DraggableItemScript = preload("res://scripts/minigames/DraggableItem.gd")
const JuicyButtonScript = preload("res://scripts/ui/JuicyButton.gd")

var _passes: int = 0
var _fails: int = 0

func _assert(cond: bool, msg: String, detail: String = "") -> void:
	if cond:
		_passes += 1
		print("  [PASS %02d] %s" % [_passes, msg])
	else:
		_fails += 1
		printerr("  [FAIL] %s%s" % [msg, (" -> " + detail) if detail != "" else ""])

func _ready() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ TOÀN DIỆN 7 TASK UX OVERHAUL ===")
	await get_tree().process_frame

	await _test_task3_minigame_base_and_draggable()
	await _test_task2_theme_and_hud_dock()
	await _test_task1_main_menu_onboarding()
	await _test_task4_metro_3phase_and_polaroid()
	await _test_task5_budget_draggable_and_flash_sale()
	await _test_task6_packing_4x5_lshape_and_mischief()
	await _test_task7_living_habitat()

	print("=== UX OVERHAUL SUMMARY: %d PASS, %d FAIL ===" % [_passes, _fails])
	get_tree().quit(1 if _fails > 0 else 0)

func _test_task3_minigame_base_and_draggable() -> void:
	print("\n--- [TASK 3] MinigameBase FSM & DraggableItem ---")
	var mg = MinigameBaseScript.new()
	add_child(mg)
	await get_tree().process_frame

	_assert(mg.current_state == MinigameBaseScript.State.INTRO, "Task 3: State khởi đầu là INTRO")
	_assert(not mg.can_accept_input(), "Task 3: Không nhận input ở trạng thái INTRO")
	await mg.begin_minigame_loop("", 0.0)
	_assert(mg.current_state == MinigameBaseScript.State.PLAYING and mg.can_accept_input(),
		"Task 3: begin_minigame_loop chuyển sang PLAYING & mở input")
	_assert(mg.try_acquire_drag(101), "Task 3: Con trỏ #101 khóa drag thành công")
	_assert(not mg.try_acquire_drag(202), "Task 3: Chống đa chạm khóa con trỏ #202")
	mg.release_drag(101)
	_assert(mg.try_acquire_drag(202), "Task 3: Sau khi nhả #101, #202 được phép kéo")

	var done_flag := {"ok": false}
	mg.minigame_completed.connect(func(_s): done_flag["ok"] = true)
	await mg.complete_minigame(0.01, [{"icon": "✨", "text": "Done"}])
	_assert(done_flag["ok"] and mg.current_state == MinigameBaseScript.State.COMPLETED,
		"Task 3: complete_minigame phát signal & khóa sang COMPLETED")

	var di = DraggableItemScript.new()
	di.custom_minimum_size = Vector2(60, 60)
	di.size = Vector2(60, 60)
	add_child(di)
	await get_tree().process_frame
	_assert(is_equal_approx(di.drag_scale, 1.12) and di.get_node_or_null("TouchHitMargin") != null,
		"Task 3: DraggableItem có drag_scale=1.12x & TouchHitMargin +20%")

	di.queue_free()
	mg.queue_free()
	await get_tree().process_frame

func _test_task2_theme_and_hud_dock() -> void:
	print("\n--- [TASK 2] MainTheme Cozy Palette, JuicyButton & HUD/Dock ---")
	var theme: Theme = load("res://assets/themes/MainTheme.tres")
	_assert(theme != null and theme.default_font != null, "Task 2: Nạp MainTheme.tres kèm font SVN-Retron 2000")
	var btn_col: Color = theme.get_color("font_color", "Button")
	_assert(btn_col.r > 0.85 and btn_col.g > 0.85, "Task 2: Nút chữ kem chuẩn #FDF6E3")

	var btn := Button.new()
	btn.text = "Test"
	add_child(btn)
	JuicyButtonScript.attach_juice(btn, true)
	btn.button_down.emit()
	_assert(btn.has_meta("_juicy_attached"), "Task 2: JuicyButton attach_juice gắn phản hồi xúc giác thành công")
	btn.queue_free()

	var hud = load("res://scenes/CatProfileHUD.tscn").instantiate()
	add_child(hud)
	await get_tree().process_frame
	_assert(hud.btn_pause.has_meta("_juicy_attached") and hud.btn_shop.has_meta("_juicy_attached"),
		"Task 2: CatProfileHUD nút bấm có JuicyButton feedback")
	hud.queue_free()
	await get_tree().process_frame

func _test_task1_main_menu_onboarding() -> void:
	print("\n--- [TASK 1] Diegetic Rental Contract Onboarding ---")
	var mm = load("res://scenes/MainMenu.tscn").instantiate()
	add_child(mm)
	await get_tree().process_frame
	mm._open_cat_creation()
	await get_tree().process_frame

	_assert(mm.current_breed_idx == 8, "Task 1: Mặc định chọn Boss Mochi (idx=8)")
	_assert(mm.btn_start_game.get_node_or_null("WaxSealStampOverlay") != null or mm.wax_seal_stamp_rect != null,
		"Task 1: Nút xác nhận dùng Con Dấu Sáp Vàng Hoàng Gia (WaxSealStampOverlay)")
	var owner_inp: LineEdit = mm.edit_owner_name as LineEdit
	var rnd_btn := mm.find_child("BtnRandomOwnerName", true, false) as Button
	_assert(rnd_btn != null, "Task 1: Tồn tại nút Xúc xắc gợi ý tên Sen (BtnRandomOwnerName)")
	if rnd_btn:
		rnd_btn.pressed.emit()
		_assert(not owner_inp.text.strip_edges().is_empty(), "Task 1: Xúc xắc tự điền tên Sen nhanh: %s" % owner_inp.text)
	mm.queue_free()
	await get_tree().process_frame

func _test_task4_metro_3phase_and_polaroid() -> void:
	print("\n--- [TASK 4] Metro 3 Pha Văn Minh & Vé Polaroid ---")
	var cir = load("res://scenes/minigames/CheckInRushGame.tscn").instantiate()
	add_child(cir)
	await get_tree().process_frame

	_assert(cir.find_child("DragMetroCard", true, false) != null and cir.rfid_ring_draw != null,
		"Task 4: Tồn tại thẻ DraggableItem DragMetroCard & vòng tròn RfidRingDraw")

	# Pha 1 nhả tay sớm (<0.5s) -> Safe Failure tiếng Tít không trừ mạng
	cir.rfid_sensor_target.button_down.emit()
	cir._process(0.25)
	cir.rfid_sensor_target.button_up.emit()
	_assert(cir.safe_failure_count == 1 and cir.failed_passengers == 0,
		"Task 4: Pha 1 nhả sớm <0.5s kích hoạt Safe Failure không mất mạng")
	_assert("Tít!" in cir.afc_window_label.text,
		"Task 4: Thông báo đúng lời thoại: %s" % cir.afc_window_label.text)

	# Pha 2: Ra Trước - Vào Sau
	cir.enter_metro_phase(cir.METRO_PHASE_ALIGHT)
	_assert(cir.metro_phase == cir.METRO_PHASE_ALIGHT, "Task 4: Chuyển vào Pha 2 (Ra Trước - Vào Sau)")
	cir.rush_into_center()
	_assert(cir.safe_failure_count == 2 and "bật nảy" in cir.phase2_alighting_status_lbl.text,
		"Task 4: Lao giữa bật nảy nhẹ (Safe Failure)")
	cir.stand_aside_for_alighting("left")
	_assert(cir.metro_phase == cir.METRO_PHASE_PRIORITY_SEAT,
		"Task 4: Nép Trái nhường khách xong chuyển sang Pha 3 (Ghế Ưu Tiên)")

	# Pha 3: Ghế Ưu Tiên Trái Tim
	GameManager.courage = 50
	var courage_before: int = GameManager.courage
	cir.yield_priority_seat_metro()
	_assert(cir.priority_seat_yielded and GameManager.courage >= courage_before + 15,
		"Task 4: Bấm Ghế Ưu Tiên tăng +15 Điểm Tự Lập")

	# Vé Polaroid
	cir._trigger_victory()
	_assert(cir.metro_polaroid_ticket != null and cir.metro_polaroid_ticket.visible,
		"Task 4: Hiển thị Vé Tàu Kỷ Niệm Polaroid trên VictoryModal")

	cir.queue_free()
	await get_tree().process_frame

func _test_task5_budget_draggable_and_flash_sale() -> void:
	print("\n--- [TASK 5] Chiếc Ví Của Sen & Flash Sale Trà Sữa ---")
	var b = load("res://scenes/minigames/BudgetMiniGame.tscn").instantiate()
	add_child(b)
	await get_tree().process_frame
	b.load_minigame(GameManager.get_minigame_data(13))
	await get_tree().process_frame

	_assert(b.drag_bill_items.size() == 3 and b.jar_target_bars.size() == 3,
		"Task 5: Có đủ 3 tờ Cá Khô DraggableItem & 3 thanh mức mục tiêu")
	var emg_before: int = b.val_emergency
	var grow_before: int = b.val_growth
	b.trigger_flash_sale_temptation()
	_assert(b.flash_sale_bubble != null and b.flash_sale_bubble.visible,
		"Task 5: Hiện bong bóng cám dỗ Flash Sale 50% Trà Sữa")
	b.flash_sale_bubble.pressed.emit()
	_assert(b.flash_sale_tempted_count == 1 and b.val_emergency < emg_before and b.val_growth > grow_before,
		"Task 5: Chạm Flash Sale trừ quỹ Tiết Kiệm chuyển sang Mong Muốn & Mochi nhắc nhở")

	b.queue_free()
	await get_tree().process_frame

func _test_task6_packing_4x5_lshape_and_mischief() -> void:
	print("\n--- [TASK 6] Ba Lô 4x5, Khối L-Shape & Cuộn Len Mochi ---")
	var p = load("res://scenes/minigames/PackingMiniGame.tscn").instantiate()
	add_child(p)
	await get_tree().process_frame
	p.load_minigame(GameManager.get_minigame_data(11))
	await get_tree().process_frame

	p.enable_4x5_grid(true)
	_assert(p.tetris_grid_4x5 != null and p.tetris_grid_4x5.get_child_count() == 20 and p.active_grid_rows == 5,
		"Task 6: Chế độ mở rộng Ngăn 4x5 có đủ 20 ô")

	var pen_item := {"id": "loot_05_pen", "name": "Bút & thước", "is_required": true}
	var c0 = p.get_item_cells(pen_item, false)
	var c1 = p.get_item_cells(pen_item, true)
	_assert(c0.size() == 3 and c0 != c1, "Task 6: Bút & thước có hình L-shape 3 ô & xoay 90° chuẩn")

	var spawned: bool = p.spawn_mochi_mischief_toy()
	_assert(spawned and p.mochi_yarn_in_backpack, "Task 6: Mochi lén nhét Cuộn Len vào ba lô")
	p._on_pack_done_pressed()
	_assert(p.safe_failure_count == 1, "Task 6: Bị chặn kéo khóa khi còn Cuộn Len Mochi (Safe Failure)")
	p.remove_item_from_grid({"id": "mochi_yarn_toy"}, false)
	_assert(not p.mochi_yarn_in_backpack, "Task 6: Kéo trả Cuộn Len về Mochi thành công")

	p.queue_free()
	await get_tree().process_frame

func _test_task7_living_habitat() -> void:
	print("\n--- [TASK 7] Boss Mochi Tự Trị, Vuốt Ve, Đổ Hạt & Bảng Ghim Tường ---")
	GameManager.hunger = 80
	GameManager.completed_lessons = [1, 2, 11]
	var room = load("res://scenes/IsometricRoomView.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	room.refresh_wall_achievement_board()

	var action: String = room.iso_cat.run_autonomous_behavior()
	_assert(action in ["WANDER_RUG", "SLEEP", "PLAY_BOX"], "Task 7: Mochi no tự chạy AI tự trị (%s)" % action)
	GameManager.hunger = 20
	var hungry_action: String = room.iso_cat.run_autonomous_behavior()
	_assert(hungry_action == "SEEK_FOOD", "Task 7: Khi đói < 30 Mochi tự tìm bát ăn (%s)" % hungry_action)

	var bond_before: int = room.iso_cat.pet_bonding_points
	room.iso_cat._last_pet_rub_msec = -1000
	room.iso_cat.pet_rub(-12.0)
	_assert(room.iso_cat.pet_bonding_points == bond_before + 1, "Task 7: Vuốt ve tăng gắn kết + purr + tim bay")

	var cork: Control = room.get_node_or_null("RoomAchievementCorkBoard") as Control
	var tray: HBoxContainer = room.wall_polaroid_tray as HBoxContainer
	_assert(cork != null and tray != null and tray.get_child_count() == 3,
		"Task 7: Bảng ghim tường đính đủ 3 ảnh Polaroid kỹ năng đã học")

	room.queue_free()
	await get_tree().process_frame
