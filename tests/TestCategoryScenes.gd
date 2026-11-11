extends Node

# TestCategoryScenes.gd - Kiểm thử độc lập và toàn diện 4 Scene Danh Mục Kỹ Năng

func _ready() -> void:
	print("========================================================")
	print("   KIỂM THỬ 4 SCENE DANH MỤC KỸ NĂNG RIÊNG BIỆT (BESTSEN)")
	print("========================================================")
	
	var pass_count = 0
	var fail_count = 0
	
	var scenes_to_test = [
		{"path": "res://scenes/categories/CategoryMobility.tscn", "id": 1, "expected_games": 6, "name": "Đi Lại & Giao Thông"},
		{"path": "res://scenes/categories/CategoryHousingLegal.tscn", "id": 2, "expected_games": 5, "name": "Nơi Ở & Pháp Lý Cư Trú"},
		{"path": "res://scenes/categories/CategoryHealthMedical.tscn", "id": 3, "expected_games": 6, "name": "Y Tế & Sức Khỏe Tự Thân"},
		{"path": "res://scenes/categories/CategoryFinanceCareer.tscn", "id": 4, "expected_games": 6, "name": "Tài Chính & Việc Làm"}
	]
	
	for test in scenes_to_test:
		var scn_path = test["path"]
		print("\n--- Kiểm thử: %s (%s) ---" % [test["name"], scn_path])
		
		if not ResourceLoader.exists(scn_path):
			print("  [FAIL] Scene không tồn tại trên ổ đĩa: %s" % scn_path)
			fail_count += 1
			continue
			
		var packed = load(scn_path)
		if not packed:
			print("  [FAIL] Không thể load packed scene: %s" % scn_path)
			fail_count += 1
			continue
			
		var inst = packed.instantiate()
		if not inst:
			print("  [FAIL] Không thể instantiate scene: %s" % scn_path)
			fail_count += 1
			continue
			
		add_child(inst)
		
		# Kiểm tra thuộc tính
		if inst.category_id == test["id"]:
			print("  [PASS] category_id chính xác: %d" % inst.category_id)
			pass_count += 1
		else:
			print("  [FAIL] category_id sai: %d (kỳ vọng %d)" % [inst.category_id, test["id"]])
			fail_count += 1
			
		if inst.minigames_list.size() == test["expected_games"]:
			print("  [PASS] Số lượng minigames chính xác: %d minigames" % inst.minigames_list.size())
			pass_count += 1
		else:
			print("  [FAIL] Số lượng minigames sai: %d (kỳ vọng %d)" % [inst.minigames_list.size(), test["expected_games"]])
			fail_count += 1
			
		# Kiểm tra toàn bộ minigame con có thể tải được
		var all_subgames_ok = true
		for mg in inst.minigames_list:
			var sub_path = mg.get("scene_path", "")
			if not ResourceLoader.exists(sub_path):
				print("    [FAIL] Minigame scene con không tồn tại: %s (%s)" % [mg.get("title", ""), sub_path])
				all_subgames_ok = false
			else:
				var sub_packed = load(sub_path)
				if not sub_packed:
					print("    [FAIL] Minigame scene con không thể nạp: %s" % sub_path)
					all_subgames_ok = false
					
		if all_subgames_ok:
			print("  [PASS] Toàn bộ %d minigame trong danh mục đều hợp lệ và nạp thành công!" % inst.minigames_list.size())
			pass_count += 1
		else:
			fail_count += 1
			
		# Thử chạy 1 minigame vào holder
		var first_mg = inst.minigames_list[0]
		inst._launch_minigame(first_mg)
		if inst.minigame_holder.visible and inst.active_minigame_instance != null:
			print("  [PASS] Khởi chạy minigame vào container thành công: %s" % first_mg.get("title", ""))
			pass_count += 1
		else:
			print("  [FAIL] Không thể khởi chạy minigame vào container!")
			fail_count += 1
			
		inst._on_minigame_closed()
		if not inst.minigame_holder.visible and inst.active_minigame_instance == null:
			print("  [PASS] Đóng minigame và quay về danh sách thẻ bài thành công!")
			pass_count += 1
		else:
			print("  [FAIL] Đóng minigame không giải phóng đúng container!")
			fail_count += 1
			
		inst.queue_free()
		
	print("\n========================================================")
	print("KẾT QUẢ: PASS %d / %d | FAIL: %d" % [pass_count, pass_count + fail_count, fail_count])
	print("========================================================")
	
	if fail_count == 0:
		print("🎉 HOÀN TẤT: TẤT CẢ 4 DANH MỤC ĐẠT CHUẨN 100%!")
	get_tree().quit(0 if fail_count == 0 else 1)
