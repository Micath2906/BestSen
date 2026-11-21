extends Control

const ARTIFACT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/9d50b208-48ba-454e-8e4f-32bb5c4f469c/"

func _ready() -> void:
	print(">>> BẮT ĐẦU CHỤP ẢNH XÁC THỰC TOÀN BỘ 5 TASK MỚI <<<")
	_capture_flow()

func _capture_flow() -> void:
	# 1. MainMenu & Playtest Hub Modal
	print("--- 1. Chụp MainMenu & Hub Modal ---")
	var mm_scene = load("res://scenes/MainMenu.tscn")
	var mm = mm_scene.instantiate()
	add_child(mm)
	await get_tree().process_frame
	await get_tree().process_frame
	_save_screenshot("fix_01_main_menu.png")
	
	mm._open_playtest_hub()
	await get_tree().process_frame
	await get_tree().process_frame
	_save_screenshot("fix_09_playtest_hub.png")
	mm.queue_free()
	await get_tree().process_frame

	# 2. Shop View
	print("--- 2. Chụp ShopView ---")
	var shop_scene = load("res://scenes/ShopView.tscn")
	var shop = shop_scene.instantiate()
	add_child(shop)
	await get_tree().process_frame
	await get_tree().process_frame
	_save_screenshot("fix_02_shop_fitting_room.png")
	shop.queue_free()
	await get_tree().process_frame

	# 3. Main Cozy Room (with study desk, warm lamp, bookshelf, window, boho rug)
	print("--- 3. Chụp Cozy Main Room ---")
	var room_scene = load("res://scenes/IsometricRoomView.tscn")
	var room = room_scene.instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	_save_screenshot("fix_03_cozy_main_room.png")
	room.queue_free()
	await get_tree().process_frame

	# 4. Task 1: Packing Tetris Game
	print("--- 4. Chụp Packing Tetris Game ---")
	var packing_scene = load("res://scenes/minigames/packing_tetris_game.tscn")
	var packing = packing_scene.instantiate()
	add_child(packing)
	await get_tree().process_frame
	await get_tree().process_frame
	_save_screenshot("fix_04_packing_minigame.png")
	packing.queue_free()
	await get_tree().process_frame

	# 5. Task 2: Spot Difference Game (Real life inspection images)
	print("--- 5. Chụp Room Inspection Diff Game ---")
	var diff_scene = load("res://scenes/minigames/room_inspection_diff_game.tscn")
	var diff = diff_scene.instantiate()
	add_child(diff)
	await get_tree().process_frame
	await get_tree().process_frame
	_save_screenshot("fix_05_room_diff_game.png")
	diff.queue_free()
	await get_tree().process_frame

	# 6. Task 3: Doctor Simulation Game
	print("--- 6. Chụp Doctor Simulation Game ---")
	var doc_scene = load("res://scenes/minigames/doctor_simulation_game.tscn")
	var doc = doc_scene.instantiate()
	add_child(doc)
	await get_tree().process_frame
	await get_tree().process_frame
	_save_screenshot("fix_06_doctor_simulation.png")
	doc.queue_free()
	await get_tree().process_frame

	# 7. Task 4: Budget Jars Game (Fullscreen 2.000.000đ simulation)
	print("--- 7. Chụp Budget Jars Game ---")
	var budget_scene = load("res://scenes/minigames/budget_jars_game.tscn")
	var budget = budget_scene.instantiate()
	add_child(budget)
	await get_tree().process_frame
	await get_tree().process_frame
	_save_screenshot("fix_07_budget_jars.png")
	budget.queue_free()
	await get_tree().process_frame

	print(">>> HOÀN THÀNH CHỤP ẢNH TẤT CẢ CÁC MÀN HÌNH FIX! <<<")
	get_tree().quit(0)

func _save_screenshot(filename: String) -> void:
	var img = get_viewport().get_texture().get_image()
	var full_path = ARTIFACT_DIR + filename
	img.save_png(full_path)
	print("  -> Đã lưu ảnh: ", full_path)
