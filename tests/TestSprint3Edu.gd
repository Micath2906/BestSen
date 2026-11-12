extends Node

var pass_count: int = 0
var fail_count: int = 0

func _pass(label: String) -> void:
	pass_count += 1
	print("  [PASS %02d] %s" % [pass_count, label])

func _fail(label: String, reason: String) -> void:
	fail_count += 1
	printerr("  [FAIL] %s -> %s" % [label, reason])

func _assert(cond: bool, label: String, reason: String = "Assertion failed") -> void:
	if cond:
		_pass(label)
	else:
		_fail(label, reason)

func _ready() -> void:
	print("\n=== SPRINT 3 VERIFICATION: GP-ED-01 & GP-ED-02 ===")
	await _run_tests()
	print("\n=== SPRINT 3 SUMMARY: %d PASS, %d FAIL ===" % [pass_count, fail_count])
	if fail_count == 0:
		print("=== SPRINT 3 VERIFICATION: ALL PASSED! ===")
	get_tree().quit(1 if fail_count > 0 else 0)

func _run_tests() -> void:
	var hud_updates: Array = []
	var hud_cb := func(t_left: float, prog: float):
		hud_updates.append({"t": t_left, "p": prog})
	if GameManager and GameManager.has_signal("minigame_hud_updated"):
		GameManager.minigame_hud_updated.connect(hud_cb)

	# ---------------------------------------------------------
	# PART 1: GP-ED-01 (CheckInRushGame Metro Line 1 AFC)
	# ---------------------------------------------------------
	var cir_scn: PackedScene = load("res://scenes/minigames/CheckInRushGame.tscn")
	var cir = cir_scn.instantiate()
	add_child(cir)
	await get_tree().process_frame
	await get_tree().process_frame

	_assert(cir.btn_prep_key != null and cir.btn_prep_card != null, "CheckInRush Prep Tray (Key & Bus Card) tồn tại")
	_assert(cir.rfid_sensor_target != null and cir.rfid_dwell_bar != null, "CheckInRush RfidSensorCircle & DwellBar tồn tại")
	_assert(cir.btn_afc_swipe_forward != null and cir.metro_cozy_dialog != null, "CheckInRush BtnAfcSwipeForward & MetroCozyDialog tồn tại")

	# Nhấn nhầm chìa khóa -> Safe Failure không trừ mạng
	cir.btn_prep_key.pressed.emit()
	await get_tree().process_frame
	_assert(cir.safe_failure_count == 1, "Chọn nhầm chìa khóa tăng safe_failure_count == 1", "safe_failure_count=%d" % cir.safe_failure_count)
	_assert(cir.failed_passengers == 0, "Safe Failure không làm mất mạng (failed_passengers == 0)", "failed=%d" % cir.failed_passengers)
	_assert(cir.metro_cozy_dialog.visible, "Safe Failure bật MetroCozyDialog nhắc nhở dịu dàng")

	# Nhấn chọn Thẻ Metro -> sẵn sàng giữ 0.6s
	cir.btn_prep_card.pressed.emit()
	await get_tree().process_frame
	_assert(cir.is_card_prepped, "Chọn BtnPrepCard đánh dấu is_card_prepped == true")

	# Giữ đầu đọc RFID 0.65s -> đạt 100% và mở cổng 2.5s
	cir.rfid_sensor_target.button_down.emit()
	cir._process(0.35)
	_assert(cir.rfid_dwell_bar.value > 50.0 and cir.rfid_dwell_bar.value < 100.0, "Đang giữ RFID 0.35s: bar tăng dần (%.1f%%)" % cir.rfid_dwell_bar.value)
	cir._process(0.30)
	_assert(is_equal_approx(cir.rfid_dwell_bar.value, 100.0), "Giữ đủ >=0.6s: rfid_dwell_bar == 100%%", "val=%.1f" % cir.rfid_dwell_bar.value)
	_assert(cir.is_afc_gate_ready_to_pass and cir.btn_afc_swipe_forward.visible, "Mở cửa sổ Bước Qua Cổng 2.5s sau khi RFID dwell hoàn tất")

	# Giả lập trễ >2.5s -> Safe Failure timeout không trừ mạng
	cir._process(2.6)
	await get_tree().process_frame
	_assert(cir.safe_failure_count == 2, "Quá 2.5s qua cổng kích hoạt Safe Failure (count=2)", "safe_failure_count=%d" % cir.safe_failure_count)
	_assert(cir.failed_passengers == 0, "Timeout 2.5s Safe Failure không trừ failed_passengers")
	_assert(not cir.btn_afc_swipe_forward.visible and not cir.is_afc_gate_ready_to_pass, "Đóng nút Bước Qua Cổng sau timeout 2.5s")

	# Thử lại chuẩn xác: dwell >= 0.6s -> bấm Bước Qua Cổng
	cir.rfid_sensor_target.button_down.emit()
	cir._process(0.65)
	cir.btn_afc_swipe_forward.pressed.emit()
	await get_tree().process_frame
	_assert(cir.processed_passengers == 1 and cir.failed_passengers == 0, "Thử lại AFC hoàn thành trọn vẹn (processed=1, failed=0)")

	var hud_after_cir: int = hud_updates.size()
	_assert(hud_after_cir > 0, "CheckInRushGame phát signal GameManager.minigame_hud_updated (%d lần)" % hud_after_cir)

	cir.queue_free()
	await get_tree().process_frame

	# ---------------------------------------------------------
	# PART 2: GP-ED-02 (CivilizedRideGame Metro Priority Seat)
	# ---------------------------------------------------------
	var ride_scn: PackedScene = load("res://scenes/minigames/CivilizedRideGame.tscn")
	var ride = ride_scn.instantiate()
	add_child(ride)
	await get_tree().process_frame
	await get_tree().process_frame

	_assert(ride.choice_ring_360 != null and ride.btn_ring_yield != null and ride.btn_ring_keep_sitting != null, "CivilizedRide ChoiceRing360 & 2 nút lựa chọn tồn tại")
	_assert(ride.ride_cozy_dialog != null, "CivilizedRide RideCozyDialog tồn tại")

	var touch_ok: bool = true
	for hs in [ride.hotspot_dog, ride.hotspot_bear, ride.hotspot_thief]:
		if hs.custom_minimum_size.x < 56.0 or hs.custom_minimum_size.y < 56.0:
			touch_ok = false
	_assert(touch_ok, "Tất cả Hotspots đạt chuẩn touch target >= 56x56dp")

	# Kích hoạt Tình huống 1: Ghế ưu tiên
	ride._trigger_situation(ride.SituationType.PRIORITY_SEAT, 8.0)
	await get_tree().process_frame
	_assert(ride.choice_ring_360.visible, "Kích hoạt PRIORITY_SEAT hiển thị Vòng chọn 360° ChoiceRing360")

	# Chọn [Tiếp Tục Ngồi] -> Reflective Safe Failure không thua game
	ride.btn_ring_keep_sitting.pressed.emit()
	await get_tree().process_frame
	_assert(ride.reflective_safe_fails == 1, "Chọn Tiếp Tục Ngồi tăng reflective_safe_fails == 1")
	_assert(ride.ride_cozy_dialog.visible, "Chọn Tiếp Tục Ngồi hiện RideCozyDialog phản chiếu nhẹ nhàng")
	_assert(ride.is_game_active and not ride.defeat_modal.visible, "Reflective Safe Failure không làm thua ngay lập tức")

	# Chọn [Đứng Dậy Nhường] -> +15 Điểm Văn Minh & +15 Dũng Cảm
	GameManager.courage = 40
	var civic_before: int = ride.civic_points
	var courage_before: int = GameManager.courage
	ride.btn_ring_yield.pressed.emit()
	await get_tree().process_frame
	_assert(ride.civic_points == civic_before + 15, "Đứng Dậy Nhường tăng +15 Điểm Văn Minh (%d -> %d)" % [civic_before, ride.civic_points])
	_assert(GameManager.courage == courage_before + 15, "Đứng Dậy Nhường tăng +15 Điểm Dũng Cảm (%d -> %d)" % [courage_before, GameManager.courage])
	_assert(ride.courage_bonus_earned == 15 and ride.is_grandpa_seated and not ride.choice_ring_360.visible, "Mèo Cụ đã ngồi ghế cam & ChoiceRing360 ẩn gọn")
	_assert(hud_updates.size() > hud_after_cir, "CivilizedRideGame phát signal GameManager.minigame_hud_updated")

	ride.queue_free()
	await get_tree().process_frame
	if GameManager and GameManager.has_signal("minigame_hud_updated") and GameManager.minigame_hud_updated.is_connected(hud_cb):
		GameManager.minigame_hud_updated.disconnect(hud_cb)
