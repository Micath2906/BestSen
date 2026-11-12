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
	print("=== BẮT ĐẦU KIỂM THỬ SPRINT 4: GP-ED-03 & GP-ED-04 ===")
	await get_tree().process_frame
	await _test_gp_ed_03_budget()
	await _test_gp_ed_04_packing()

	print("=== SPRINT 4 SUMMARY: %d PASS, %d FAIL ===" % [_pass_count, _fail_count])
	if _fail_count == 0:
		print("=== SPRINT 4 VERIFICATION: ALL PASSED! ===")
		get_tree().quit(0)
	else:
		get_tree().quit(1)

func _test_gp_ed_03_budget() -> void:
	var scn: PackedScene = load("res://scenes/minigames/BudgetMiniGame.tscn")
	var budget = scn.instantiate()
	add_child(budget)
	await get_tree().process_frame

	var data: Dictionary = GameManager.get_minigame_data(13)
	_assert(not data.is_empty(), "GP-ED-03: Tải dữ liệu Budget lesson 13 thành công")
	budget.load_minigame(data)
	await get_tree().process_frame

	var jars_card := budget.get_node_or_null("JarsCard") as PanelContainer
	_assert(jars_card != null, "GP-ED-03: Tồn tại JarsCard")
	var jars_sb := jars_card.get_theme_stylebox("panel")
	_assert(jars_sb is StyleBoxTexture and jars_sb.texture == preload("res://assets/UI/CatUIPaid/slices/cozy_dress/vintage_chest_shelf_9patch.tres"),
		"GP-ED-03: JarsCard dùng vintage_chest_shelf_9patch.tres StyleBoxTexture")

	_assert(budget.bill_drawer_tray != null and budget.bill_chip_buttons.size() >= 3,
		"GP-ED-03: BillDrawerTray có ít nhất 3 tờ tiền kéo thả")

	# Reset & test drop_bill_into_jar + wax seal
	budget.val_survive = 10
	budget.val_growth = 60
	budget.val_emergency = 20
	budget._update_sliders_ui()
	budget._update_scale_visual()
	_assert(not budget.is_essentials_sealed and not budget.wax_seal_stamp.visible,
		"GP-ED-03: WaxSealStamp ẩn khi quỹ Sống còn chưa đạt min")

	budget.drop_bill_into_jar("survive", 35)
	_assert(budget.val_survive >= 45, "GP-ED-03: drop_bill_into_jar tăng val_survive >= 45 (got %d)" % budget.val_survive)
	_assert(budget.is_essentials_sealed and budget.wax_seal_stamp.visible,
		"GP-ED-03: Đủ quỹ Sống còn -> WaxSealStamp đóng dấu sáp vàng hiển thị")

	# Trigger Safe Failure
	budget.val_survive = 10
	budget.val_growth = 75
	budget.val_emergency = 5
	budget._update_sliders_ui()
	budget._on_check_balance_pressed()
	await get_tree().process_frame

	_assert(budget.safe_failure_count == 1, "GP-ED-03: Safe Failure ghi nhận 1 lần không khóa retry")
	_assert(budget.safe_fail_preview != null and budget.safe_fail_preview.visible,
		"GP-ED-03: BudgetSafeFailPreview hiển thị khi lệch ngân sách")
	_assert(budget.empty_bowl_icon != null and budget.sleepy_cat_preview != null,
		"GP-ED-03: Preview thất bại an toàn có EmptyBowlIcon & SleepyCatPreview")
	_assert(budget.budget_cozy_dialog != null and budget.budget_cozy_dialog.visible,
		"GP-ED-03: BudgetCozyDialog hiển thị gợi ý thân thiện")
	_assert(not budget.btn_check_balance.disabled,
		"GP-ED-03: Nút kiểm tra vẫn mở để người chơi thử lại ngay")

	# Complete cleanly
	var b_state := {"done": false}
	budget.minigame_completed.connect(func(_s): b_state["done"] = true)
	budget._apply_gold_preset()
	_assert(not budget.safe_fail_preview.visible, "GP-ED-03: _apply_gold_preset ẩn preview lỗi cũ")
	budget._on_check_balance_pressed()
	await get_tree().create_timer(1.35).timeout
	_assert(b_state["done"], "GP-ED-03: Tỷ lệ vàng phát signal minigame_completed")

	budget.queue_free()
	await get_tree().process_frame

func _test_gp_ed_04_packing() -> void:
	var scn: PackedScene = load("res://scenes/minigames/PackingMiniGame.tscn")
	var pack = scn.instantiate()
	add_child(pack)
	await get_tree().process_frame

	var data: Dictionary = GameManager.get_minigame_data(11)
	_assert(not data.is_empty(), "GP-ED-04: Tải dữ liệu Packing lesson 11 thành công")
	pack.load_minigame(data)
	await get_tree().process_frame
	await get_tree().process_frame

	var bp_card := pack.get_node_or_null("BackpackCard") as PanelContainer
	var bp_sb := bp_card.get_theme_stylebox("panel") if bp_card else null
	_assert(bp_sb is StyleBoxTexture and bp_sb.texture == preload("res://assets/UI/CatUIPaid/slices/cozy_dress/clipboard_wood_frame_9patch.tres"),
		"GP-ED-04: BackpackCard dùng clipboard_wood_frame_9patch.tres")

	_assert(pack.checklist_cork_card != null and pack.checklist_cork_card.get_theme_stylebox("panel") is StyleBoxTexture,
		"GP-ED-04: ChecklistCorkCard dùng StyleBoxTexture bảng bần")
	_assert(pack.pin_tack_sprite != null and pack.pin_tack_sprite.texture == preload("res://assets/UI/CatUIPaid/slices/cozy_achievements/pin_tack_red.tres"),
		"GP-ED-04: PinTackSprite đính ghim đỏ pin_tack_red.tres")

	_assert(pack.tetris_grid_4x3 != null and pack.tetris_grid_4x3.columns == 4 and pack.tetris_grid_4x3.get_child_count() == 12,
		"GP-ED-04: TetrisGrid4x3 có đúng 4 cột x 3 hàng = 12 ô")
	_assert(pack.btn_rotate_item != null and pack.btn_rotate_item.custom_minimum_size.y >= 56.0,
		"GP-ED-04: BtnRotateItem đạt vùng chạm tối thiểu >= 56dp")

	# Tìm các vật phẩm required & junk từ available_items
	var req_items: Array = []
	var junk_item: Dictionary = {}
	for it in pack.available_items:
		if it.get("is_required", false):
			req_items.append(it)
		elif junk_item.is_empty():
			junk_item = it

	_assert(req_items.size() == 4 and not junk_item.is_empty(), "GP-ED-04: Lesson 11 có 4 món bắt buộc và >= 1 món gây nhiễu")

	# Test footprint & rotation
	var test_wide := {"id": "item_bandage", "name": "Băng gạc", "is_required": true}
	_assert(pack.get_item_footprint(test_wide, false) == Vector2i(2, 1),
		"GP-ED-04: Footprint mặc định băng gạc là 2x1")
	pack.btn_rotate_item.pressed.emit()
	_assert(pack.is_item_rotated and pack.get_item_footprint(test_wide, pack.is_item_rotated) == Vector2i(1, 2),
		"GP-ED-04: Bấm Xoay Món (90°) đảo chiều 2x1 -> 1x2")

	# Test bounds & overlap on 4x3 grid
	_assert(not pack.can_place_in_grid(test_wide, Vector2i(3, 0), false),
		"GP-ED-04: Từ chối đặt khối 2x1 tràn biên tại x=3")
	_assert(pack.place_item_at_cell(req_items[0], Vector2i(0, 0), false),
		"GP-ED-04: Đặt vật phẩm 0 tại (0, 0) thành công")
	var big_2x1 := {"id": "first_aid_pack", "name": "Túi sơ cứu", "is_required": true, "grid_size": Vector2i(2, 1)}
	_assert(not pack.can_place_in_grid(big_2x1, Vector2i(0, 0), false),
		"GP-ED-04: Chặn đặt chồng lấn lên ô (0, 0) đã chiếm")

	# Test Safe Failure khi nhét 3 món đúng + 1 món sai (đủ 4 slot) & nhấn Kiểm tra
	pack.place_item_at_cell(req_items[1], Vector2i(1, 0), false)
	pack.place_item_at_cell(req_items[2], Vector2i(3, 0), false)
	pack.place_item_at_cell(junk_item, Vector2i(0, 2), false)
	pack._on_pack_done_pressed()
	await get_tree().process_frame
	_assert(pack.safe_failure_count == 1, "GP-ED-04: Đóng gói sai kích hoạt Safe Failure (count=1)")
	_assert(pack.packing_cozy_dialog != null and pack.packing_cozy_dialog.visible,
		"GP-ED-04: PackingCozyDialog hiện hội thoại Boss Mèo cười khúc khích + gợi ý")
	_assert(not pack.btn_pack_done.disabled,
		"GP-ED-04: Nút Done không bị khóa sau Safe Failure")

	# Gỡ món sai, nhét đủ 4 món đúng & hoàn thành
	pack.remove_item_from_grid(junk_item, true)
	for i in range(1, req_items.size()):
		if not pack._is_item_packed(req_items[i]):
			pack._add_to_backpack(req_items[i])
	await get_tree().process_frame

	# Kiểm tra Checklist cork board cập nhật đủ [✅]
	var checked_cnt := 0
	for ch in pack.checklist_vbox.get_children():
		for sub in ch.find_children("*", "Label", true, false):
			if "[✅]" in (sub as Label).text:
				checked_cnt += 1
	_assert(checked_cnt == 4, "GP-ED-04: Cork Checklist đánh dấu [✅] đủ 4/4 món (got %d)" % checked_cnt)

	var p_state := {"done": false}
	pack.minigame_completed.connect(func(_s): p_state["done"] = true)
	pack._on_pack_done_pressed()
	await get_tree().create_timer(1.35).timeout
	_assert(p_state["done"], "GP-ED-04: Đóng gói chuẩn 4/4 món phát signal minigame_completed")

	pack.queue_free()
	await get_tree().process_frame
