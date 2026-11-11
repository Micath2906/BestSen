extends Node

func _ready() -> void:
	print("=== BẮT ĐẦU CHỤP ẢNH MINH CHỨNG GAME BHYT & 5 BỘ KỸ NĂNG PHÁP LUẬT ===")
	
	# [1] BHYT GAME
	var bhyt_scene = load("res://scenes/minigames/HospitalBHYTProcessGame.tscn")
	var bhyt_node = bhyt_scene.instantiate()
	add_child(bhyt_node)
	bhyt_node.load_minigame(GameManager.get_minigame_data(10))
	await _wait_frames()
	await _capture("screenshot_bhyt_phase1_docs.png")
	
	for d in bhyt_node.REQUIRED_DOCS:
		bhyt_node._attempt_pack_doc(d)
	bhyt_node._switch_to_phase2()
	await _wait_frames()
	await _capture("screenshot_bhyt_phase2_timeline.png")
	bhyt_node.queue_free()
	
	# [2] RENTAL CONTRACT GAME (Kỹ năng 1)
	var rental_scene = load("res://scenes/minigames/RentalContractGame.tscn")
	var rental_node = rental_scene.instantiate()
	add_child(rental_node)
	rental_node.load_minigame(GameManager.get_minigame_data(5))
	await _wait_frames()
	await _capture("screenshot_rental_phase1_matching.png")
	
	for p in rental_node.MATCHING_PAIRS:
		rental_node._on_col_a_pressed(p["id"])
		rental_node._on_col_b_pressed(p["id"])
	rental_node._switch_to_phase2()
	await _wait_frames()
	await _capture("screenshot_rental_phase2_steps.png")
	rental_node.queue_free()
	
	# [3] LABOR RIGHTS GAME (Kỹ năng 2)
	var labor_scene = load("res://scenes/minigames/LaborRightsGame.tscn")
	var labor_node = labor_scene.instantiate()
	add_child(labor_node)
	labor_node.load_minigame(GameManager.get_minigame_data(15))
	await _wait_frames()
	await _capture("screenshot_labor_phase1_matching.png")
	
	for p in labor_node.MATCHING_PAIRS:
		labor_node._on_col_a_pressed(p["id"])
		labor_node._on_col_b_pressed(p["id"])
	labor_node._switch_to_phase2()
	await _wait_frames()
	await _capture("screenshot_labor_phase2_classify.png")
	labor_node.queue_free()
	
	# [4] CYBER SECURITY GAME (Kỹ năng 3)
	var cyber_scene = load("res://scenes/minigames/CyberSecurityGame.tscn")
	var cyber_node = cyber_scene.instantiate()
	add_child(cyber_node)
	cyber_node.load_minigame(GameManager.get_minigame_data(14))
	await _wait_frames()
	await _capture("screenshot_cyber_phase1_matching.png")
	
	for p in cyber_node.MATCHING_PAIRS:
		cyber_node._on_col_a_pressed(p["id"])
		cyber_node._on_col_b_pressed(p["id"])
	cyber_node._switch_to_phase2()
	await _wait_frames()
	await _capture("screenshot_cyber_phase2_quiz.png")
	cyber_node.queue_free()
	
	# [5] TRAFFIC SAFETY GAME (Kỹ năng 4)
	var traffic_scene = load("res://scenes/minigames/TrafficSafetyGame.tscn")
	var traffic_node = traffic_scene.instantiate()
	add_child(traffic_node)
	traffic_node.load_minigame(GameManager.get_minigame_data(4))
	await _wait_frames()
	await _capture("screenshot_traffic_phase1_matching.png")
	
	for p in traffic_node.MATCHING_PAIRS:
		traffic_node._on_col_a_pressed(p["id"])
		traffic_node._on_col_b_pressed(p["id"])
	traffic_node._switch_to_phase2()
	await _wait_frames()
	await _capture("screenshot_traffic_phase2_steps.png")
	traffic_node.queue_free()
	
	# [6] PUBLIC ADMIN GAME (Kỹ năng 5)
	var admin_scene = load("res://scenes/minigames/PublicAdminGame.tscn")
	var admin_node = admin_scene.instantiate()
	add_child(admin_node)
	admin_node.load_minigame(GameManager.get_minigame_data(7))
	await _wait_frames()
	await _capture("screenshot_admin_phase1_matching.png")
	
	for p in admin_node.MATCHING_PAIRS:
		admin_node._on_col_a_pressed(p["id"])
		admin_node._on_col_b_pressed(p["id"])
	admin_node._switch_to_phase2()
	await _wait_frames()
	await _capture("screenshot_admin_phase2_vneid.png")
	admin_node.queue_free()
	
	print("=== HOÀN THÀNH CHỤP TOÀN BỘ 12 ẢNH MINH CHỨNG ===")
	get_tree().quit()

func _wait_frames() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.15).timeout

func _capture(file_name: String) -> void:
	var img = get_viewport().get_texture().get_image()
	var artifact_dir = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d"
	var save_path = artifact_dir + "/" + file_name
	img.save_png(save_path)
	print("Đã chụp và lưu thành công: ", file_name)
