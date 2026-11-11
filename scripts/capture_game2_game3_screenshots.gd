extends Node

# capture_game2_game3_screenshots.gd - Tự động chụp các trạng thái trực quan của Game 2 và Game 3

const OUT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/"

func _ready() -> void:
	print(">>> BẮT ĐẦU CHỤP ẢNH MINH CHỨNG GAME 2 VÀ GAME 3...")
	await get_tree().process_frame
	await get_tree().process_frame
	
	await capture_game_2()
	await capture_game_3()
	
	print(">>> HOÀN THÀNH CHỤP TOÀN BỘ ẢNH MINH CHỨNG!")
	get_tree().quit()

func save_screen(filename: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	var img = get_viewport().get_texture().get_image()
	var full_path = OUT_DIR + filename
	img.save_png(full_path)
	print("  -> Đã lưu ảnh: ", full_path)

func capture_game_2() -> void:
	print("\n--- CHỤP ẢNH GAME 2: LỰA CHỌN BỆNH VIỆN ĐÚNG BỆNH ---")
	var hosp_scn = load("res://scenes/minigames/HospitalChoiceGame.tscn")
	var node = hosp_scn.instantiate()
	add_child(node)
	var data = GameManager.get_minigame_data(2)
	node.load_minigame(data)
	
	# 1. Ca 1 - Giai đoạn 1 (Chuyên Khoa)
	await save_screen("screenshot_game2_case1_phase1.png")
	
	# 2. Ca 1 - Giai đoạn 2 (Bệnh Viện)
	var c1_p1_correct = data["cases"][0]["phase_1_options"][0]
	node._on_option_selected(c1_p1_correct)
	await save_screen("screenshot_game2_case1_phase2.png")
	
	# 3. Chọn sai -> Báo động cấp cứu sai cơ sở
	var c1_p2_wrong = data["cases"][0]["phase_2_options"][2] # Phòng khám nha khoa
	node._on_option_selected(c1_p2_wrong)
	await save_screen("screenshot_game2_fail_warning.png")
	
	# Đóng modal fail & reset
	node._on_restart_from_beginning_pressed()
	
	# Vượt qua Ca 1 sang Ca 2
	node._on_option_selected(c1_p1_correct)
	var c1_p2_correct = data["cases"][0]["phase_2_options"][0]
	node._on_option_selected(c1_p2_correct)
	
	# 4. Ca 2 - Sốt xuất huyết
	await save_screen("screenshot_game2_case2_dengue.png")
	
	# Vượt qua Ca 2 & Ca 3 tới Victory
	var c2_p1_correct = data["cases"][1]["phase_1_options"][0]
	var c2_p2_correct = data["cases"][1]["phase_2_options"][0]
	node._on_option_selected(c2_p1_correct)
	node._on_option_selected(c2_p2_correct)
	
	var c3_p1_correct = data["cases"][2]["phase_1_options"][0]
	var c3_p2_correct = data["cases"][2]["phase_2_options"][0]
	node._on_option_selected(c3_p1_correct)
	node._on_option_selected(c3_p2_correct)
	
	# 5. Victory Modal Game 2
	await save_screen("screenshot_game2_victory.png")
	node.queue_free()

func capture_game_3() -> void:
	print("\n--- CHỤP ẢNH GAME 3: XÁC ĐỊNH ĐÚNG BỆNH TRƯỚC KHI UỐNG THUỐC ---")
	var diag_scn = load("res://scenes/minigames/SelfDiagnosisGame.tscn")
	var node = diag_scn.instantiate()
	add_child(node)
	var data = GameManager.get_minigame_data(3)
	node.load_minigame(data)
	
	# 1. Ca 1 - Lượt 1: Dụng cụ chẩn đoán
	await save_screen("screenshot_game3_case1_turn1_tools.png")
	
	# 2. Chọn đúng Nhiệt kế -> Hiện Bảng Thống Kê Thông Tin
	var d1_tool_correct = data["cases"][0]["turn_1_items"][0]
	node._on_turn_1_item_selected(d1_tool_correct)
	await save_screen("screenshot_game3_case1_stat_sheet.png")
	
	# 3. Lượt 2: Chọn thuốc đặc trị
	node._on_proceed_to_turn_2_pressed()
	await save_screen("screenshot_game3_case1_turn2_medicines.png")
	
	# 4. Chọn sai thuốc (Kháng sinh) -> Màn hình Game Over
	var d1_med_wrong = data["cases"][0]["turn_2_items"][1]
	node._on_turn_2_item_selected(d1_med_wrong)
	await save_screen("screenshot_game3_game_over.png")
	
	# Đóng Game Over & Hoàn thành toàn bộ để chụp Victory
	node._on_retry_pressed()
	node._on_turn_1_item_selected(d1_tool_correct)
	node._on_proceed_to_turn_2_pressed()
	var d1_med_correct = data["cases"][0]["turn_2_items"][0]
	node._on_turn_2_item_selected(d1_med_correct)
	
	# Ca 2
	var d2_tool = data["cases"][1]["turn_1_items"][0]
	var d2_med = data["cases"][1]["turn_2_items"][0]
	node._on_turn_1_item_selected(d2_tool)
	node._on_proceed_to_turn_2_pressed()
	node._on_turn_2_item_selected(d2_med)
	
	# Ca 3
	var d3_tool = data["cases"][2]["turn_1_items"][0]
	var d3_med = data["cases"][2]["turn_2_items"][0]
	node._on_turn_1_item_selected(d3_tool)
	node._on_proceed_to_turn_2_pressed()
	node._on_turn_2_item_selected(d3_med)
	
	# 5. Victory Modal Game 3
	await save_screen("screenshot_game3_victory.png")
	node.queue_free()
