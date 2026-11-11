extends Node

func _ready() -> void:
	print("--- BẮT ĐẦU CHỤP ẢNH XÁC THỰC GAME 1: LỜI DẶN DÒ CỦA MẸ ---")
	
	var prep_scene = load("res://scenes/minigames/PreparationValiGame.tscn")
	var prep_node = prep_scene.instantiate()
	add_child(prep_node)
	
	var prep_data = GameManager.get_minigame_data(1)
	prep_node.load_minigame(prep_data)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 1. Chụp Phase 1 Khởi đầu (Vali 4 ngăn trống)
	await _capture("screenshot_game1_phase1_suitcase.png")
	
	# 2. Xếp đồ vào 4 ngăn
	for it in prep_data["available_items"]:
		if it["is_required"]:
			prep_node._attempt_pack_item_to_slot(it, it["target_slot"])
			
	await get_tree().process_frame
	await get_tree().process_frame
	await _capture("screenshot_game1_phase1_packed.png")
	
	# 3. Chuyển sang Phase 2: Dán nhãn thuốc
	prep_node._switch_to_phase2()
	await get_tree().process_frame
	await get_tree().process_frame
	await _capture("screenshot_game1_phase2_medicines.png")
	
	# 4. Dán nhãn 5 loại thuốc
	for med in prep_data["medicine_puzzles"]:
		prep_node._attempt_fill_label_to_medicine(med["correct_label"], med["id"])
		
	await get_tree().process_frame
	await get_tree().process_frame
	await _capture("screenshot_game1_phase2_solved.png")
	
	# 5. Mở Modal Chiến Thắng
	prep_node._on_finish_game_pressed()
	await get_tree().process_frame
	await get_tree().process_frame
	await _capture("screenshot_game1_victory.png")
	
	print("--- HOÀN THÀNH CHỤP ẢNH XÁC THỰC! ---")
	get_tree().quit()

func _capture(file_name: String) -> void:
	await get_tree().create_timer(0.2).timeout
	var img = get_viewport().get_texture().get_image()
	var artifact_dir = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d"
	var save_path = artifact_dir + "/" + file_name
	img.save_png(save_path)
	print("Đã chụp và lưu thành công: ", save_path)
