extends SceneTree

# test_isometric_and_data.gd - Kiểm thử toàn diện kiến trúc dữ liệu JSON & phòng Isometric 2.5D

func _init():
	print("=== BẮT ĐẦU KIỂM THỬ KIẾN TRÚC JSON & ISOMETRIC 2.5D ===")
	
	# 1. Kiểm tra data/skills.json
	var skills_file = FileAccess.open("res://data/skills.json", FileAccess.READ)
	assert(skills_file != null, "Không mở được data/skills.json")
	var skills_json = JSON.parse_string(skills_file.get_as_text())
	assert(skills_json != null, "Lỗi cú pháp JSON data/skills.json")
	assert(skills_json["skills"].size() == 16, "skills.json phải chứa đúng 16 kỹ năng sống!")
	for s in skills_json["skills"]:
		assert(s.has("handbook_3_steps"), "Kỹ năng %d thiếu handbook_3_steps" % s["skill_id"])
		assert(s["handbook_3_steps"].size() == 3, "Kỹ năng %d cẩm nang phải có đúng 3 bước thực tế" % s["skill_id"])
		assert(s["required_cards"].size() == 4, "Kỹ năng %d phải có đúng 4 thẻ bài" % s["skill_id"])
	print("[PASS 1] 16 Kỹ năng sống & Cẩm nang 3 bước hợp lệ 100%!")
	
	# 2. Kiểm tra data/cards.json
	var cards_file = FileAccess.open("res://data/cards.json", FileAccess.READ)
	assert(cards_file != null, "Không mở được data/cards.json")
	var cards_json = JSON.parse_string(cards_file.get_as_text())
	assert(cards_json != null, "Lỗi cú pháp JSON data/cards.json")
	assert(cards_json["cards"].size() == 64, "cards.json phải chứa đủ 64 thẻ bài cho 16 bài học (16x4)!")
	for c in cards_json["cards"]:
		assert(c.has("cat_sound"), "Thẻ %d thiếu ngữ điệu tiếng mèo" % c["card_id"])
		assert(c.has("action_icon"), "Thẻ %d thiếu action_icon thực tế" % c["card_id"])
		assert(c.has("error_feedback"), "Thẻ %d thiếu error_feedback" % c["card_id"])
	print("[PASS 2] 64 Thẻ bài kéo thả với ngữ điệu tiếng Mèo hợp lệ 100%!")
	
	# 3. Kiểm tra data/loot_tables.json
	var loot_file = FileAccess.open("res://data/loot_tables.json", FileAccess.READ)
	assert(loot_file != null, "Không mở được data/loot_tables.json")
	var loot_json = JSON.parse_string(loot_file.get_as_text())
	assert(loot_json != null, "Lỗi cú pháp JSON data/loot_tables.json")
	assert(loot_json["mastery_levels"].size() == 5, "Bảng tỷ lệ rơi phải có đủ 5 cấp độ Cat Mastery!")
	assert(loot_json["items_pool"].has("soft_currency"), "Thiếu nhóm soft_currency")
	assert(loot_json["items_pool"].has("decor_common"), "Thiếu nhóm decor_common")
	assert(loot_json["items_pool"].has("cat_costume"), "Thiếu nhóm cat_costume")
	assert(loot_json["items_pool"].has("legendary"), "Thiếu nhóm legendary")
	print("[PASS 3] Hệ thống Gacha Loot Table theo 5 cấp Mastery hợp lệ 100%!")
	
	# 4. Kiểm tra data/peer_system.json
	var peer_file = FileAccess.open("res://data/peer_system.json", FileAccess.READ)
	assert(peer_file != null, "Không mở được data/peer_system.json")
	var peer_json = JSON.parse_string(peer_file.get_as_text())
	assert(peer_json != null, "Lỗi cú pháp JSON data/peer_system.json")
	assert(peer_json["daily_relief_limits"]["max_send_per_day"] == 20, "Giới hạn gửi cứu trợ phải là 20 Cá/ngày")
	assert(peer_json["daily_relief_limits"]["max_receive_per_day"] == 40, "Giới hạn nhận cứu trợ phải là 40 Cá/ngày")
	assert(peer_json["mock_friends"].size() >= 3, "Cần tối thiểu 3 bạn bè mẫu ghé thăm phòng 2.5D")
	print("[PASS 4] Hệ thống Bạn bè & Quỹ cứu trợ sinh viên (20/40 Cá) hợp lệ 100%!")
	
	# 5. Kiểm tra toán học IsometricGrid (2:1 Dimetric)
	var IsometricGrid = load("res://scripts/IsometricGrid.gd")
	var origin = Vector2(270.0, 436.0)
	var test_grid = Vector2(3.0, 5.0)
	var screen_pos = IsometricGrid.grid_to_screen(test_grid, origin)
	var back_grid = IsometricGrid.screen_to_grid(screen_pos, origin)
	assert(abs(back_grid.x - test_grid.x) < 0.001, "Lỗi chuyển đổi ngược trục U!")
	assert(abs(back_grid.y - test_grid.y) < 0.001, "Lỗi chuyển đổi ngược trục V!")
	print("[PASS 5] Động cơ toán học Isometric 2.5D Dimetric chính xác tuyệt đối!")
	
	print("=== TẤT CẢ KIỂM THỬ THÀNH CÔNG VƯỢT TRỘI 100% ===")
	quit()
