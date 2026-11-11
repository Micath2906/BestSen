extends Node

# CaptureFiveLifeSkillsGames.gd - Chụp ảnh minh chứng 10 màn chơi của 5 Kỹ năng Sống & Tự Lập mới

const ARTIFACT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/"

func _ready() -> void:
	print("=== BẮT ĐẦU CHỤP ẢNH MINH CHỨNG 5 BỘ KỸ NĂNG SỐNG & TỰ LẬP MỚI ===")
	
	# [1] KỸ NĂNG 1: QUẢN LÝ TÀI CHÍNH CÁ NHÂN
	print("\n--- Chụp ảnh: Quản lý tài chính cá nhân ---")
	var pf_scene = load("res://scenes/minigames/PersonalFinanceGame.tscn")
	var pf_node = pf_scene.instantiate()
	add_child(pf_node)
	pf_node.load_minigame()
	await _wait_frames()
	await _capture("screenshot_finance_phase1_matching.png")
	
	for p in pf_node.MATCHING_PAIRS:
		pf_node._on_col_a_pressed(p["id"])
		pf_node._on_col_b_pressed(p["id"])
	pf_node._switch_to_phase2()
	await _wait_frames()
	await _capture("screenshot_finance_phase2_survival.png")
	pf_node.queue_free()
	
	# [2] KỸ NĂNG 2: QUẢN LÝ THỜI GIAN & DEADLINE
	print("\n--- Chụp ảnh: Quản lý thời gian và công việc ---")
	var time_scene = load("res://scenes/minigames/TimeManagementGame.tscn")
	var time_node = time_scene.instantiate()
	add_child(time_node)
	time_node.load_minigame()
	await _wait_frames()
	await _capture("screenshot_time_phase1_timeline.png")
	
	for act in time_node.SCHEDULE_ACTIVITIES:
		time_node.selected_activity_card = act.duplicate()
		time_node._on_slot_pressed(act["step"])
	time_node._switch_to_phase2()
	await _wait_frames()
	await _capture("screenshot_time_phase2_deadline.png")
	time_node.queue_free()
	
	# [3] KỸ NĂNG 3: GIAO TIẾP VÀ GIẢI QUYẾT MÂU THUẪN
	print("\n--- Chụp ảnh: Giao tiếp & Giải quyết mâu thuẫn ---")
	var comm_scene = load("res://scenes/minigames/CommunicationConflictGame.tscn")
	var comm_node = comm_scene.instantiate()
	add_child(comm_node)
	comm_node.load_minigame()
	await _wait_frames()
	await _capture("screenshot_comm_phase1_dialogue.png")
	
	for i in range(comm_node.SITUATIONS.size()):
		var sit = comm_node.SITUATIONS[i]
		for opt in sit["options"]:
			if opt["is_correct"]:
				comm_node._on_situation_option_chosen(opt, Button.new())
				break
		if i < comm_node.SITUATIONS.size() - 1:
			comm_node._on_next_situation_pressed()
	comm_node._switch_to_phase2()
	await _wait_frames()
	await _capture("screenshot_comm_phase2_green_red.png")
	comm_node.queue_free()
	
	# [4] KỸ NĂNG 4: TỰ CHĂM SÓC BẢN THÂN & SINH HOẠT
	print("\n--- Chụp ảnh: Tự chăm sóc bản thân & Sinh hoạt ---")
	var care_scene = load("res://scenes/minigames/SelfCareLivingGame.tscn")
	var care_node = care_scene.instantiate()
	add_child(care_node)
	care_node.load_minigame()
	await _wait_frames()
	await _capture("screenshot_selfcare_phase1_laundry.png")
	
	for st in care_node.LAUNDRY_STEPS:
		care_node.selected_step_card = st.duplicate()
		care_node._on_slot_pressed(st["step"])
	care_node._switch_to_phase2()
	await _wait_frames()
	await _capture("screenshot_selfcare_phase2_nutrition.png")
	care_node.queue_free()
	
	# [5] KỸ NĂNG 5: BẢO DƯỠNG & SỰ CỐ XE MÁY
	print("\n--- Chụp ảnh: Bảo dưỡng & Sự cố xe máy ---")
	var motor_scene = load("res://scenes/minigames/MotorbikeMaintenanceGame.tscn")
	var motor_node = motor_scene.instantiate()
	add_child(motor_node)
	motor_node.load_minigame()
	await _wait_frames()
	await _capture("screenshot_motorbike_phase1_matching.png")
	
	for p in motor_node.MATCHING_PAIRS:
		motor_node._on_col_a_pressed(p["id"])
		motor_node._on_col_b_pressed(p["id"])
	motor_node._switch_to_phase2()
	await _wait_frames()
	await _capture("screenshot_motorbike_phase2_mechanic.png")
	motor_node.queue_free()
	
	print("\n=== ĐÃ CHỤP THÀNH CÔNG 10 ẢNH MINH CHỨNG 5 KỸ NĂNG SỐNG TỰ LẬP! ===")
	get_tree().quit()

func _wait_frames(count: int = 5) -> void:
	for i in range(count):
		await get_tree().process_frame

func _capture(file_name: String) -> void:
	await get_tree().process_frame
	var img = get_viewport().get_texture().get_image()
	var path = ARTIFACT_DIR + file_name
	var err = img.save_png(path)
	if err == OK:
		print("  -> Đã lưu ảnh: ", path)
	else:
		printerr("  -> LỖI LƯU ẢNH: ", path, " (Mã lỗi: ", err, ")")
