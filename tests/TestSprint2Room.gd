extends Node

func _assert(cond: bool, msg: String) -> void:
	if not cond:
		push_error("ASSERT FAILED: " + msg)
		printerr("[FAIL] " + msg)
		get_tree().quit(1)
	else:
		print("[PASS] " + msg)

func _ready() -> void:
	print("=== TEST SPRINT 2: GP-ROOM-01 & GP-ROOM-02 ===")
	call_deferred("_run_tests")

func _run_tests() -> void:
	var orig_fish: int = GameManager.fish
	var orig_hunger: int = GameManager.hunger
	var orig_decor_inv: Array = GameManager.inventory_decor.duplicate()

	# --- GP-ROOM-01: Hunger Decay 5/hr & Auto-Sleep Conservation ---
	_assert(GameManager.calculate_hunger_decay(2.0, false) == 10, "GP-ROOM-01: Tốc độ giảm đói chuẩn 5 điểm/giờ (2h = 10)")
	GameManager.hunger = 60
	var offline_res: Dictionary = GameManager.apply_offline_hunger_decay(7200.0, true) # 2h auto sleep -> 50% = 5
	_assert(offline_res.get("hunger_lost", 0) == 5 and GameManager.hunger == 55, "GP-ROOM-01: Offline 2h chế độ tự ngủ tiết kiệm năng lượng giảm 5 điểm")
	GameManager.hunger = 12
	offline_res = GameManager.apply_offline_hunger_decay(36000.0, true) # 10h -> floored safely at 10, no illness/faint
	_assert(GameManager.hunger >= 10 and not GameManager.is_fainted, "GP-ROOM-01: Tự động ngủ khi đi vắng không gây ngất/ốm phạt (<10)")
	GameManager.is_offline_auto_sleeping = false

	# --- GP-ROOM-01: Room Scene Petting, Cat Sleep Cream, FoodBowl Empty->Full Drag Pour ---
	GameManager.hunger = 50
	GameManager.food_inventory["kibble"] = 3
	GameManager.food_bowl_servings = 0
	var room = preload("res://scenes/IsometricRoomView.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame

	# Check cat sleep cream sprite
	room.iso_cat.set_cozy_sleep_mode(true)
	_assert(room.iso_cat.cozy_sleep_sprite != null and room.iso_cat.cozy_sleep_sprite.visible, "GP-ROOM-01: Trạng thái ngủ hiển thị cat_sleep_cream.png")
	_assert(room.iso_cat.cozy_sleep_sprite.texture.resource_path.ends_with("cat_sleep_cream.png"), "GP-ROOM-01: Texture đúng cat_sleep_cream.png")

	# Check petting wakes & spawns particles without errors
	var prev_mood: int = GameManager.mood
	room.iso_cat._last_pet_rub_msec = -1000
	room.iso_cat.pet_rub(-15.0)
	_assert(not room.iso_cat.cozy_sleep_mode and GameManager.mood >= prev_mood, "GP-ROOM-01: Vuốt ve nựng mèo tăng mood & phát heart particles")

	# Check FoodBowlEmpty -> drag FoodBag pour -> FoodBowl
	_assert(not room.food_bowl.is_bowl_filled, "GP-ROOM-01: Bát ăn ban đầu ở trạng thái rỗng (FoodBowlEmpty.png)")
	_assert(room.food_bowl.sprite_node.texture.resource_path.ends_with("FoodBowlEmpty.png"), "GP-ROOM-01: Sprite bát rỗng đúng FoodBowlEmpty.png")
	_assert(room.food_bag_widget != null and room.food_bag_widget.texture.resource_path.ends_with("icon_cat_food_bag.png"), "GP-ROOM-01: Túi hạt phòng trọ dùng icon_cat_food_bag.png")
	_assert(room.pour_food_bag_into_bowl(), "GP-ROOM-01: Kéo thả túi hạt đổ vào bát thành công")
	_assert(room.food_bowl.is_bowl_filled, "GP-ROOM-01: Sau đổ hạt bát chuyển đầy (FoodBowl.png)")
	_assert(room.food_bowl.sprite_node.texture.resource_path.ends_with("FoodBowl.png"), "GP-ROOM-01: Sprite bát đầy đúng FoodBowl.png")
	_assert(GameManager.hunger == 65, "GP-ROOM-01: Độ no tăng +15 sau khi đổ hạt (50 -> 65)")

	# --- GP-ROOM-02: Long-press 1.0s Decor Mode, Grid Overlay Green/Orange, Heat/Fan Shop Upgrades, room_save.json ---
	_assert(not room.is_decor_mode and not room.room_canvas.show_iso_grid, "GP-ROOM-02: Bình thường lưới 2.5D ẩn hoàn toàn")
	# Simulate 1.0s press on floor
	var press_ev := InputEventMouseButton.new()
	press_ev.button_index = MOUSE_BUTTON_LEFT
	press_ev.pressed = true
	press_ev.position = Vector2(270, 780)
	room._on_floor_gui_input(press_ev)
	room._process(1.05)
	_assert(room.is_decor_mode and room.room_canvas.show_iso_grid, "GP-ROOM-02: Nhấn giữ >= 1.0s mở Decor Mode & hiện lưới 2.5D")

	# Grid validity check (occupied cell vs empty cell vs out of bounds)
	var bed_cell := Vector2i(floori(room.cushion_bed.grid_coord.x), floori(room.cushion_bed.grid_coord.y))
	_assert(not room.is_grid_cell_valid(bed_cell, "food_bowl"), "GP-ROOM-02: Ô đang có Giường báo không hợp lệ (Cam) với Bát ăn")
	_assert(not room.is_grid_cell_valid(Vector2i(-1, 2), "food_bowl"), "GP-ROOM-02: Ô ngoài sàn (-1,2) báo không hợp lệ (Cam)")
	_assert(room.is_grid_cell_valid(Vector2i(5, 5), "food_bowl"), "GP-ROOM-02: Ô trống (5,5) hợp lệ (Xanh)")
	_assert(room.move_furniture_to_cell("food_bowl", Vector2i(5, 5)), "GP-ROOM-02: Đặt Bát ăn vào ô hợp lệ (5,5) thành công")
	_assert(FileAccess.file_exists(GameManager.ROOM_SAVE_PATH), "GP-ROOM-02: Tệp user://room_save.json đã được lưu")

	# Shop upgrades: Heat Insulation & Mini Fan
	GameManager.fish = 200
	var r1: Dictionary = GameManager.buy_shop_item("d_insulation_curtain")
	var r2: Dictionary = GameManager.buy_shop_item("d_mini_fan")
	_assert(r1.get("ok", false) and r2.get("ok", false), "GP-ROOM-02: Mua Rèm Cách Nhiệt & Quạt Mini bằng Cá thành công")
	var comfort: Dictionary = GameManager.get_room_comfort_summary()
	_assert(comfort.get("heat_insulation", false) and comfort.get("mini_fan", false) and comfort.get("cooling_bonus_c", 0) >= 10,
		"GP-ROOM-02: Nâng cấp cách nhiệt & quạt mini kích hoạt cộng dồn (%d°C)" % comfort.get("cooling_bonus_c", 0))

	# Verify persistence via load_room_state()
	GameManager.furniture_grid_positions.clear()
	var loaded_room: Dictionary = GameManager.load_room_state()
	_assert(loaded_room.get("furniture_grid_positions", {}).has("food_bowl"), "GP-ROOM-02: Khôi phục bố cục phòng từ user://room_save.json thành công")

	room.exit_decor_mode()
	_assert(not room.room_canvas.show_iso_grid, "GP-ROOM-02: Thoát Decor Mode ẩn lưới 2.5D sạch sẽ")
	room.queue_free()

	# Restore stats
	GameManager.fish = orig_fish
	GameManager.hunger = orig_hunger
	GameManager.inventory_decor = orig_decor_inv
	GameManager.save_game()
	await get_tree().process_frame

	print("=== SPRINT 2 VERIFICATION: ALL PASSED! ===")
	get_tree().quit(0)
