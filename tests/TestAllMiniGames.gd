extends Node

# TestAllMiniGames.gd - Kiểm thử tự động toàn diện Tất cả các Hệ Mini-Game & Kỹ năng

func _ready() -> void:
	print("\n========================================================")
	print("   BEST SEN - SUITE KIỂM THỬ TOÀN BỘ GAMEPLAY MINI-GAME  ")
	print("========================================================")
	
	# [1] KIỂM THỬ GAMEPLAY 1: SOI LỖI BẰNG KÍNH LÚP CỦA MÈO (AUDIT MINI-GAME)
	print("\n[1] Kiểm thử Gameplay 'Soi Lỗi Bằng Kính Lúp Của Mèo' (Audit Mode - Lesson 6):")
	var audit_scene = load("res://scenes/minigames/AuditMiniGame.tscn")
	var audit_node = audit_scene.instantiate()
	add_child(audit_node)
	
	var audit_data = GameManager.get_minigame_data(6)
	assert(audit_data.get("type") == "audit", "Lesson 6 phải có minigame audit!")
	audit_node.load_minigame(audit_data)
	assert(audit_node.total_required == 3, "Bài học 6 phải yêu cầu cào đúng 3 bẫy PCCC!")
	
	# Bấm vào điều khoản an toàn
	var safe_clause = null
	var red_clause_1 = null
	var red_clause_2 = null
	var red_clause_3 = null
	for c in audit_data["clauses"]:
		if not c["is_red_flag"] and safe_clause == null:
			safe_clause = c
		elif c["is_red_flag"]:
			if red_clause_1 == null: red_clause_1 = c
			elif red_clause_2 == null: red_clause_2 = c
			elif red_clause_3 == null: red_clause_3 = c
			
	var dummy_btn = Button.new()
	audit_node._on_clause_clicked(safe_clause, dummy_btn)
	assert(audit_node.found_flags == 0, "Bấm điều khoản an toàn không được tăng điểm bẫy!")
	
	# Cào rách 3 bẫy đỏ
	audit_node._on_clause_clicked(red_clause_1, dummy_btn)
	assert(audit_node.found_flags == 1, "Cào bẫy 1 phải tăng found_flags lên 1!")
	audit_node._on_clause_clicked(red_clause_2, dummy_btn)
	assert(audit_node.found_flags == 2, "Cào bẫy 2 phải tăng found_flags lên 2!")
	audit_node._on_clause_clicked(red_clause_3, dummy_btn)
	assert(audit_node.found_flags == 3, "Cào bẫy 3 phải tăng found_flags lên 3!")
	
	var audit_steps = await audit_node.minigame_completed
	assert(audit_steps.size() == 4, "Cào đủ 3 bẫy phải phát tín hiệu hoàn thành minigame với 4 bước sim_steps!")
	print("  -> Soi lỗi an toàn: Phát hiện đủ 3 bẫy nguy hiểm PASS 100%!")
	audit_node.queue_free()
	
	# [2] KIỂM THỬ GAMEPLAY 2: BA LÔ SINH TỒN / XẾP ĐỒ VÀO GIỎ (PACKING MINI-GAME)
	print("\n[2] Kiểm thử Gameplay 'Ba Lô Sinh Tồn / Xếp Đồ Vào Giỏ' (Packing Puzzle - Lesson 11):")
	var packing_scene = load("res://scenes/minigames/PackingMiniGame.tscn")
	var packing_node = packing_scene.instantiate()
	add_child(packing_node)
	
	var packing_data = GameManager.get_minigame_data(11)
	assert(packing_data.get("type") == "packing", "Lesson 11 phải có minigame packing!")
	packing_node.load_minigame(packing_data)
	assert(packing_node.max_slots == 4, "Ba lô phải có sức chứa đúng 4 ô đồ!")
	
	# Lọc vật phẩm
	var req_items = []
	var junk_item = null
	for it in packing_data["items"]:
		if it["is_required"]:
			req_items.append(it)
		else:
			junk_item = it
			
	packing_node._add_to_backpack(req_items[0])
	packing_node._add_to_backpack(req_items[1])
	packing_node._add_to_backpack(req_items[2])
	packing_node._add_to_backpack(junk_item)
	assert(packing_node.packed_items.size() == 4, "Đã xếp đủ 4 món vào ba lô!")
	
	# Bấm kiểm tra -> phải bị từ chối do mang đồ linh tinh
	var packing_completed = false
	packing_node.minigame_completed.connect(func(steps): packing_completed = true)
	packing_node._on_pack_done_pressed()
	assert(packing_completed == false, "Mang đồ thừa không được phép hoàn thành bài học!")
	
	# Tháo đồ thừa ra, nhét món bắt buộc thứ 4
	packing_node._remove_from_backpack(junk_item)
	assert(packing_node.packed_items.size() == 3, "Tháo đồ thừa thành công!")
	packing_node._add_to_backpack(req_items[3])
	assert(packing_node.packed_items.size() == 4, "Đã đủ 4 món bắt buộc sinh tồn!")
	
	packing_node._on_pack_done_pressed()
	var pack_steps = await packing_node.minigame_completed
	assert(pack_steps.size() == 4, "Chuẩn bị đúng 4 vật phẩm phải phát tín hiệu hoàn thành!")
	print("  -> Xếp hộp thuốc cứu thương: Hoàn thành 4 món cốt lõi PASS 100%!")
	packing_node.queue_free()
	
	# [3] KIỂM THỬ GAMEPLAY 3: CÂN BẰNG 3 HŨ TIỀN (BUDGET ALLOCATOR)
	print("\n[3] Kiểm thử Gameplay 'Giữ Thăng Bằng Cân Đối 3 Hũ Tiền' (Budget Allocator - Lesson 13):")
	var budget_scene = load("res://scenes/minigames/BudgetMiniGame.tscn")
	var budget_node = budget_scene.instantiate()
	add_child(budget_node)
	
	var budget_data = GameManager.get_minigame_data(13)
	assert(budget_data.get("type") == "budget", "Lesson 13 phải có minigame budget!")
	budget_node.load_minigame(budget_data)
	assert(budget_node.total_budget == 90, "Ngân sách sinh viên đầu tháng phải có đúng 90 Cá Khô!")
	
	# Test phân bổ sai
	budget_node._on_slider_changed("survive", 10)
	budget_node._on_slider_changed("growth", 70)
	budget_node._on_slider_changed("emergency", 10)
	assert(budget_node._is_balanced_state() == false, "Dồn tiền ăn chơi không được phép thăng bằng!")
	
	# Test nút Tỷ lệ vàng (50% - 30% - 20%)
	budget_node._apply_gold_preset()
	assert(budget_node.val_survive == 45, "Hũ sống còn phải là 45 cá (50%)!")
	assert(budget_node.val_growth == 27, "Hũ học tập/bạn bè phải là 27 cá (30%)!")
	assert(budget_node.val_emergency == 18, "Hũ khẩn cấp phải là 18 cá (20%)!")
	assert(budget_node._is_balanced_state() == true, "Tỷ lệ 50-30-20 phải đạt trạng thái cân bằng tuyệt đối!")
	
	budget_node._on_check_balance_pressed()
	var budget_steps = await budget_node.minigame_completed
	assert(budget_steps.size() == 4, "Cán cân thăng bằng phải phát tín hiệu hoàn thành!")
	print("  -> Cân đối ngân sách 90 Cá Khô theo tỷ lệ vàng 50-30-20 PASS 100%!")
	budget_node.queue_free()
	
	# [4] KIỂM THỬ GAMEPLAY 4: MÈO PHẢN XẠ NHANH (TIMING / QTE)
	print("\n[4] Kiểm thử Gameplay 'Mèo Phản Xạ Nhanh' (Quick Time Event - Lesson 12):")
	var qte_scene = load("res://scenes/minigames/QteMiniGame.tscn")
	var qte_node = qte_scene.instantiate()
	add_child(qte_node)
	
	var qte_data = GameManager.get_minigame_data(12)
	assert(qte_data.get("type") == "qte", "Lesson 12 phải có minigame QTE!")
	qte_node.load_minigame(qte_data)
	
	# Test bấm quá sớm
	qte_node.progress = 0.2
	qte_node._on_action_pressed()
	assert("Rẽ nhầm" in qte_node.cat_speech.text or "lạc" in qte_node.cat_speech.text or "sớm" in qte_node.cat_speech.text or "Chưa tới" in qte_node.cat_speech.text, "Bấm sớm phải nhắc nhở chưa tới lối ra!")
	
	# Test canh chuẩn VÙNG XANH AN TOÀN
	qte_node._restart_qte()
	qte_node.progress = 0.70
	qte_node._on_action_pressed()
	
	var qte_steps = await qte_node.minigame_completed
	assert(qte_steps.size() == 4, "Bấm trúng vùng an toàn phải phát tín hiệu hoàn thành!")
	print("  -> Bật xi-nhan thoát bùng binh đúng vùng xanh an toàn PASS 100%!")
	qte_node.queue_free()
	
	# [5] KIỂM THỬ GAMEPLAY 5: MÈO ĐỐI ĐÁP TÌNH HUỐNG (DIALOGUE ROLE-PLAY)
	print("\n[5] Kiểm thử Gameplay 'Mèo Đóng Vai / Đối Đáp Tình Huống' (Dialogue Role-play - Lesson 8):")
	var dia_scene = load("res://scenes/minigames/DialogueMiniGame.tscn")
	var dia_node = dia_scene.instantiate()
	add_child(dia_node)
	
	var dia_data = GameManager.get_minigame_data(8)
	assert(dia_data.get("type") == "dialogue", "Lesson 8 phải có minigame dialogue!")
	dia_node.load_minigame(dia_data)
	
	var wrong_opt = null
	var correct_opt = null
	for opt in dia_data["options"]:
		if opt["is_correct"]: correct_opt = opt
		else: wrong_opt = opt
		
	dia_node._on_option_selected(wrong_opt)
	assert(dia_node.result_modal.get_meta("is_correct") == false, "Chọn câu bẫy phải hiển thị cảnh báo rủi ro!")
	dia_node._on_close_result_pressed()
	
	var dia_steps = []
	dia_node.minigame_completed.connect(func(steps): dia_steps.append_array(steps))
	dia_node._on_option_selected(correct_opt)
	assert(dia_node.result_modal.get_meta("is_correct") == true, "Chọn câu bản lĩnh phải đạt 10 điểm!")
	dia_node._on_close_result_pressed()
	assert(dia_steps.size() == 4, "Đóng modal câu đúng phải phát tín hiệu hoàn thành!")
	print("  -> Đối đáp tình huống giao tiếp phòng trọ PASS 100%!")
	dia_node.queue_free()
	
	# [6] KIỂM THỬ TÍCH HỢP LESSONVIEW & BỘ CHUYỂN ĐỔI CHẾ ĐỘ
	print("\n[6] Kiểm thử tích hợp LessonView & Mode Switcher:")
	var lv_scene = load("res://scenes/LessonView.tscn")
	var lv_node = lv_scene.instantiate()
	add_child(lv_node)
	
	lv_node.load_lesson(1)
	assert(lv_node.current_mode == "minigame", "Bài 1 mặc định khởi chạy Mini-game Thực Hành!")
	assert(lv_node.active_minigame_instance != null, "Phải khởi tạo active_minigame_instance!")
	
	lv_node.set_mode("cards")
	assert(lv_node.current_mode == "cards", "Chuyển sang chế độ Thẻ bài thành công!")
	assert(lv_node.minigame_host.visible == false, "MiniGameHost phải ẩn khi xem Thẻ bài!")
	
	lv_node.load_lesson(9)
	assert(lv_node.current_mode == "cards", "Bài 9 không có minigame phải mặc định hiển thị Thẻ bài!")
	print("  -> Chuyển đổi linh hoạt giữa Mini-game và Thẻ Flashcard PASS 100%!")
	lv_node.queue_free()
	
	# [7] KIỂM THỬ GAME 1: LỜI DẶN DÒ CỦA MẸ (XẾP VALI & DÁN NHÃN ĐIỀN KHUYẾT THUỐC)
	print("\n[7] Kiểm thử Game 1: Lời dặn dò của Mẹ khi lên đại học (PreparationValiGame):")
	var prep_scene = load("res://scenes/minigames/PreparationValiGame.tscn")
	var prep_node = prep_scene.instantiate()
	add_child(prep_node)
	var prep_data = GameManager.get_minigame_data(1)
	prep_node.load_minigame(prep_data)
	assert(prep_node.current_phase == 1, "Mặc định ở Phase 1: Xếp Vali!")
	
	var prep_req_items = {}
	for it in prep_data["available_items"]:
		if it["is_required"]: prep_req_items[it["target_slot"]] = it
	for s_id in prep_req_items:
		prep_node._attempt_pack_item_to_slot(prep_req_items[s_id], s_id)
	assert(prep_node.packed_slots.size() == 4, "Đã xếp đủ 4 ngăn trong vali!")
	
	prep_node._switch_to_phase2()
	for med in prep_data["medicine_puzzles"]:
		prep_node._attempt_fill_label_to_medicine(med["correct_label"], med["id"])
	assert(prep_node.solved_medicines.size() == 5, "Đã dán đúng cả 5 nhãn thuốc thiết yếu!")
	
	prep_node._on_finish_game_pressed()
	var prep_completed = [false]
	prep_node.minigame_completed.connect(func(steps): prep_completed[0] = true)
	prep_node._on_claim_reward_pressed()
	assert(prep_completed[0] == true, "Phát tín hiệu hoàn thành Game 1 thành công!")
	print("  -> Game 1 Xếp Vali & Dán nhãn điền khuyết thuốc PASS 100%!")
	prep_node.queue_free()
	
	# [8] KIỂM THỬ GAME 2: LỰA CHỌN BỆNH VIỆN ĐÚNG BỆNH (HOSPITAL CHOICE GAME)
	print("\n[8] Kiểm thử Game 2: Lựa chọn bệnh viện đúng bệnh (HospitalChoiceGame):")
	var hosp_scene = load("res://scenes/minigames/HospitalChoiceGame.tscn")
	var hosp_node = hosp_scene.instantiate()
	add_child(hosp_node)
	var hosp_data = GameManager.get_minigame_data(2)
	hosp_node.load_minigame(hosp_data)
	
	# 3 Ca bệnh
	for i in range(3):
		var p1_c = hosp_data["cases"][i]["phase_1_options"][0]
		var p2_c = hosp_data["cases"][i]["phase_2_options"][0]
		hosp_node._on_option_selected(p1_c)
		hosp_node._on_option_selected(p2_c)
	assert(hosp_node.victory_modal.visible == true, "Cấp cứu thành công cả 3 ca!")
	
	var hosp_completed = [false]
	hosp_node.minigame_completed.connect(func(steps): hosp_completed[0] = true)
	hosp_node._on_claim_reward_pressed()
	assert(hosp_completed[0] == true, "Hoàn thành Game 2 thành công!")
	print("  -> Game 2 Lựa chọn bệnh viện đúng bệnh PASS 100%!")
	hosp_node.queue_free()
	
	# [9] KIỂM THỬ GAME 3: XÁC ĐỊNH ĐÚNG BỆNH TRƯỚC KHI UỐNG THUỐC (SELF DIAGNOSIS GAME)
	print("\n[9] Kiểm thử Game 3: Xác định đúng bệnh trước khi uống thuốc (SelfDiagnosisGame):")
	var diag_scene = load("res://scenes/minigames/SelfDiagnosisGame.tscn")
	var diag_node = diag_scene.instantiate()
	add_child(diag_node)
	var diag_data = GameManager.get_minigame_data(3)
	diag_node.load_minigame(diag_data)
	
	for i in range(3):
		var tool = diag_data["cases"][i]["turn_1_items"][0]
		var med = diag_data["cases"][i]["turn_2_items"][0]
		diag_node._on_turn_1_item_selected(tool)
		diag_node._on_proceed_to_turn_2_pressed()
		diag_node._on_turn_2_item_selected(med)
	assert(diag_node.victory_modal.visible == true, "Hoàn thành cả 3 ca bệnh!")
	
	var diag_completed = [false]
	diag_node.minigame_completed.connect(func(steps): diag_completed[0] = true)
	diag_node._on_claim_reward_pressed()
	assert(diag_completed[0] == true, "Hoàn thành Game 3 thành công!")
	print("  -> Game 3 Bảng thống kê thông tin & Chọn thuốc đúng bệnh PASS 100%!")
	diag_node.queue_free()
	
	# [10] KIỂM THỬ GAME BHYT: KÉO THẢ ĐI KHÁM BHYT ĐÚNG QUY TRÌNH (HOSPITAL BHYT PROCESS GAME)
	print("\n[10] Kiểm thử Game BHYT: Quy trình khám chữa bệnh BHYT đúng tuyến (Lesson 10):")
	var bhyt_scene = load("res://scenes/minigames/HospitalBHYTProcessGame.tscn")
	var bhyt_node = bhyt_scene.instantiate()
	add_child(bhyt_node)
	var bhyt_data = GameManager.get_minigame_data(10)
	assert(bhyt_data.get("type") == "bhyt_process", "Lesson 10 phải có minigame bhyt_process!")
	bhyt_node.load_minigame(bhyt_data)
	assert(bhyt_node.current_phase == 1, "Bắt đầu ở Phase 1: Chuẩn bị 4 giấy tờ BHYT!")
	
	# Thử nhét đồ bẫy (Gấu bông khổng lồ)
	var junk_bear = {"id": "junk_bear", "name": "Gấu Bông", "is_required": false, "fail_msg": "Bác sĩ mắng đó!"}
	bhyt_node._attempt_pack_doc(junk_bear)
	assert(bhyt_node.packed_docs.size() == 0, "Không được phép xếp đồ bẫy vào túi hồ sơ BHYT!")
	
	# Xếp đủ 4 giấy tờ hợp lệ
	for d in bhyt_node.REQUIRED_DOCS:
		bhyt_node._attempt_pack_doc(d)
	assert(bhyt_node.packed_docs.size() == 4, "Đã xếp đủ 4 giấy tờ BHYT cốt lõi!")
	assert(bhyt_node.btn_go_phase2.disabled == false, "Nút chuyển sang Phase 2 phải mở khóa!")
	
	# Chuyển sang Phase 2: 6 bước khám BHYT
	bhyt_node._switch_to_phase2()
	assert(bhyt_node.current_phase == 2, "Đã chuyển sang Phase 2: Dòng thời gian 6 chặng khám!")
	
	# Thử đặt sai bước
	bhyt_node.selected_action_card = bhyt_node.BHYT_6_STEPS[5] # Bước 6 đặt vào ô 1
	bhyt_node._on_slot_pressed(1)
	assert(not bhyt_node.solved_steps.has(1), "Không cho phép đặt sai thứ tự bước khám!")
	
	# Đặt đúng tuần tự 6 bước
	for step_info in bhyt_node.BHYT_6_STEPS:
		var s_idx = step_info["step"]
		bhyt_node.selected_action_card = step_info.duplicate()
		bhyt_node._on_slot_pressed(s_idx)
	assert(bhyt_node.solved_steps.size() == 6, "Đã hoàn thành chuẩn xác quy trình 6 bước khám BHYT!")
	assert(bhyt_node.btn_finish_bhyt.disabled == false, "Nút hoàn thành khám BHYT phải mở khóa!")
	
	bhyt_node._on_finish_bhyt_pressed()
	assert(bhyt_node.victory_modal.visible == true, "Victory modal phải mở!")
	var bhyt_completed = [false]
	bhyt_node.minigame_completed.connect(func(steps): bhyt_completed[0] = true)
	bhyt_node._on_claim_reward_pressed()
	assert(bhyt_completed[0] == true, "Phát tín hiệu minigame_completed thành công!")
	print("  -> Game BHYT: Chuẩn bị 4 giấy tờ & 6 Chặng khám chữa bệnh đúng tuyến PASS 100%!")
	bhyt_node.queue_free()
	
	# [11] KIỂM THỬ KỸ NĂNG 1: HỢP ĐỒNG THUÊ NHÀ (RENTAL CONTRACT GAME)
	print("\n[11] Kiểm thử Kỹ năng 1: Hiểu biết pháp luật Hợp đồng thuê nhà (Lesson 5):")
	var rental_scene = load("res://scenes/minigames/RentalContractGame.tscn")
	var rental_node = rental_scene.instantiate()
	add_child(rental_node)
	var rental_data = GameManager.get_minigame_data(5)
	assert(rental_data.get("type") == "rental_contract", "Lesson 5 phải có minigame rental_contract!")
	rental_node.load_minigame(rental_data)
	assert(rental_node.current_phase == 1, "Game 1: Nối tình huống vi phạm với giải pháp!")
	
	# Nối đúng 3 cặp tình huống - giải pháp
	for p in rental_node.MATCHING_PAIRS:
		rental_node._on_col_a_pressed(p["id"])
		rental_node._on_col_b_pressed(p["id"])
	assert(rental_node.matched_pairs.size() == 3, "Đã nối đúng toàn bộ 3 cặp pháp lý thuê nhà!")
	assert(rental_node.btn_go_phase2.disabled == false, "Nút chuyển Game 2 phải mở khóa!")
	
	# Sang Game 2: Sắp xếp 4 bước quy trình ký hợp đồng an toàn
	rental_node._switch_to_phase2()
	assert(rental_node.current_phase == 2, "Đã chuyển sang Game 2!")
	for s_info in rental_node.SAFE_CONTRACT_STEPS:
		rental_node.selected_step_card = s_info.duplicate()
		rental_node._on_phase2_slot_pressed(s_info["step"])
	assert(rental_node.solved_contract_steps.size() == 4, "Đã xếp đúng quy trình 4 bước ký HĐ an toàn!")
	assert(rental_node.btn_finish_game.disabled == false, "Nút hoàn thành phải mở khóa!")
	
	rental_node._on_finish_game_pressed()
	var rental_completed = [false]
	rental_node.minigame_completed.connect(func(steps): rental_completed[0] = true)
	rental_node._on_claim_reward_pressed()
	assert(rental_completed[0] == true, "Phát tín hiệu hoàn thành Kỹ năng 1 thành công!")
	print("  -> Kỹ năng 1 Hợp đồng thuê nhà (Nối giải pháp & Quy trình 4 bước) PASS 100%!")
	rental_node.queue_free()
	
	# [12] KIỂM THỬ KỸ NĂNG 2: QUYỀN LAO ĐỘNG CHO NGƯỜI TRẺ (LABOR RIGHTS GAME)
	print("\n[12] Kiểm thử Kỹ năng 2: Quyền lao động và HĐLĐ người trẻ (Lesson 15):")
	var labor_scene = load("res://scenes/minigames/LaborRightsGame.tscn")
	var labor_node = labor_scene.instantiate()
	add_child(labor_node)
	var labor_data = GameManager.get_minigame_data(15)
	assert(labor_data.get("type") == "labor_rights", "Lesson 15 phải có minigame labor_rights!")
	labor_node.load_minigame(labor_data)
	assert(labor_node.current_phase == 1, "Game 1: Nối chế định với con số luật định!")
	
	# Nối 3 cặp
	for p in labor_node.MATCHING_PAIRS:
		labor_node._on_col_a_pressed(p["id"])
		labor_node._on_col_b_pressed(p["id"])
	assert(labor_node.matched_pairs.size() == 3, "Đã nối đúng 3 chế định lao động cốt lõi!")
	assert(labor_node.btn_go_phase2.disabled == false, "Nút sang Game 2 mở khóa!")
	
	# Sang Game 2: Phân loại Đúng luật vs Vi phạm
	labor_node._switch_to_phase2()
	assert(labor_node.current_phase == 2, "Đã sang Game 2: Phân loại!")
	for scen in labor_node.CLASSIFY_SCENARIOS:
		labor_node.selected_classify_card = scen.duplicate()
		var target = "legal" if scen["is_legal"] else "illegal"
		labor_node._on_basket_chosen(target)
	assert(labor_node.categorized_items.size() == 4, "Đã phân loại chính xác 4 tình huống lao động!")
	assert(labor_node.btn_finish_game.disabled == false, "Nút hoàn thành mở khóa!")
	
	labor_node._on_finish_game_pressed()
	var labor_completed = [false]
	labor_node.minigame_completed.connect(func(steps): labor_completed[0] = true)
	labor_node._on_claim_reward_pressed()
	assert(labor_completed[0] == true, "Phát tín hiệu hoàn thành Kỹ năng 2 thành công!")
	print("  -> Kỹ năng 2 Quyền lao động (Nối con số & Phân loại đúng luật vs vi phạm) PASS 100%!")
	labor_node.queue_free()
	
	# [13] KIỂM THỬ KỸ NĂNG 3: AN NINH MẠNG & BẢO VỆ DỮ LIỆU CÁ NHÂN (CYBER SECURITY GAME)
	print("\n[13] Kiểm thử Kỹ năng 3: Luật An ninh mạng & Bảo vệ dữ liệu cá nhân (Lesson 14):")
	var cyber_scene = load("res://scenes/minigames/CyberSecurityGame.tscn")
	var cyber_node = cyber_scene.instantiate()
	add_child(cyber_node)
	var cyber_data = GameManager.get_minigame_data(14)
	assert(cyber_data.get("type") == "cyber_security", "Lesson 14 phải có minigame cyber_security!")
	cyber_node.load_minigame(cyber_data)
	assert(cyber_node.current_phase == 1, "Game 1: Nối hành vi vi phạm với hình thức xử lý!")
	
	for p in cyber_node.MATCHING_PAIRS:
		cyber_node._on_col_a_pressed(p["id"])
		cyber_node._on_col_b_pressed(p["id"])
	assert(cyber_node.matched_pairs.size() == 3, "Đã nối đúng 3 cặp chế tài an ninh mạng!")
	
	cyber_node._switch_to_phase2()
	assert(cyber_node.current_phase == 2, "Đã sang Game 2: Trắc nghiệm Đúng/Sai!")
	for i in range(cyber_node.shuffled_quiz.size()):
		var q = cyber_node.shuffled_quiz[i]
		cyber_node._on_answer_selected(q["correct_answer"])
		if i < cyber_node.shuffled_quiz.size() - 1:
			cyber_node._on_next_question_pressed()
	assert(cyber_node.correct_answers_count == 4, "Trả lời đúng 4/4 câu trắc nghiệm an ninh mạng!")
	assert(cyber_node.btn_finish_game.visible == true, "Nút hoàn thành hiển thị!")
	
	cyber_node._on_finish_game_pressed()
	var cyber_completed = [false]
	cyber_node.minigame_completed.connect(func(steps): cyber_completed[0] = true)
	cyber_node._on_claim_reward_pressed()
	assert(cyber_completed[0] == true, "Phát tín hiệu hoàn thành Kỹ năng 3 thành công!")
	print("  -> Kỹ năng 3 Luật An ninh mạng (Nối chế tài & Trắc nghiệm Đúng/Sai 4 câu) PASS 100%!")
	cyber_node.queue_free()
	
	# [14] KIỂM THỬ KỸ NĂNG 4: AN TOÀN GIAO THÔNG (TRAFFIC SAFETY GAME)
	print("\n[14] Kiểm thử Kỹ năng 4: An toàn giao thông & Xử lý vi phạm (Lesson 4):")
	var traffic_scene = load("res://scenes/minigames/TrafficSafetyGame.tscn")
	var traffic_node = traffic_scene.instantiate()
	add_child(traffic_node)
	var traffic_data = GameManager.get_minigame_data(4)
	assert(traffic_data.get("type") == "traffic_safety", "Lesson 4 phải có minigame traffic_safety!")
	traffic_node.load_minigame(traffic_data)
	assert(traffic_node.current_phase == 1, "Game 1: Nối lỗi vi phạm với mức phạt!")
	
	for p in traffic_node.MATCHING_PAIRS:
		traffic_node._on_col_a_pressed(p["id"])
		traffic_node._on_col_b_pressed(p["id"])
	assert(traffic_node.matched_pairs.size() == 3, "Đã nối đúng 3 mức xử phạt giao thông!")
	
	traffic_node._switch_to_phase2()
	assert(traffic_node.current_phase == 2, "Đã sang Game 2: Sắp xếp 4 bước va chạm!")
	for s_info in traffic_node.COLLISION_STEPS:
		traffic_node.selected_step_card = s_info.duplicate()
		traffic_node._on_phase2_slot_pressed(s_info["step"])
	assert(traffic_node.solved_steps.size() == 4, "Đã xếp đúng 4 bước xử lý va chạm nhẹ!")
	
	traffic_node._on_finish_game_pressed()
	var traffic_completed = [false]
	traffic_node.minigame_completed.connect(func(steps): traffic_completed[0] = true)
	traffic_node._on_claim_reward_pressed()
	assert(traffic_completed[0] == true, "Phát tín hiệu hoàn thành Kỹ năng 4 thành công!")
	print("  -> Kỹ năng 4 An toàn giao thông (Nối mức phạt & 4 bước va chạm) PASS 100%!")
	traffic_node.queue_free()
	
	# [15] KIỂM THỬ KỸ NĂNG 5: HÀNH CHÍNH CÔNG & VNEID (PUBLIC ADMIN GAME)
	print("\n[15] Kiểm thử Kỹ năng 5: Thủ tục Hành chính công & VNeID (Lesson 7):")
	var admin_scene = load("res://scenes/minigames/PublicAdminGame.tscn")
	var admin_node = admin_scene.instantiate()
	add_child(admin_node)
	var admin_data = GameManager.get_minigame_data(7)
	assert(admin_data.get("type") == "public_admin", "Lesson 7 phải có minigame public_admin!")
	admin_node.load_minigame(admin_data)
	assert(admin_node.current_phase == 1, "Game 1: Nối thủ tục giấy tờ với cơ quan thẩm quyền!")
	
	for p in admin_node.MATCHING_PAIRS:
		admin_node._on_col_a_pressed(p["id"])
		admin_node._on_col_b_pressed(p["id"])
	assert(admin_node.matched_pairs.size() == 3, "Đã nối đúng 3 cơ quan giải quyết thủ tục!")
	
	admin_node._switch_to_phase2()
	assert(admin_node.current_phase == 2, "Đã sang Game 2: 4 bước nộp hồ sơ qua VNeID!")
	for s_info in admin_node.PUBLIC_ADMIN_STEPS:
		admin_node.selected_step_card = s_info.duplicate()
		admin_node._on_phase2_slot_pressed(s_info["step"])
	assert(admin_node.solved_steps.size() == 4, "Đã xếp đúng 4 bước nộp hồ sơ DVC trực tuyến!")
	
	admin_node._on_finish_game_pressed()
	var admin_completed = [false]
	admin_node.minigame_completed.connect(func(steps): admin_completed[0] = true)
	admin_node._on_claim_reward_pressed()
	assert(admin_completed[0] == true, "Phát tín hiệu hoàn thành Kỹ năng 5 thành công!")
	print("  -> Kỹ năng 5 Thủ tục Hành chính công (Nối cơ quan & 4 bước VNeID) PASS 100%!")
	admin_node.queue_free()
	
	# [16] KIỂM THỬ KỸ NĂNG: QUẢN LÝ TÀI CHÍNH CÁ NHÂN (PERSONAL FINANCE GAME)
	print("\n[16] Kiểm thử Kỹ năng: Quản lý tài chính cá nhân (PersonalFinanceGame):")
	var pf_scene = load("res://scenes/minigames/PersonalFinanceGame.tscn")
	var pf_node = pf_scene.instantiate()
	add_child(pf_node)
	pf_node.load_minigame()
	assert(pf_node.current_phase == 1, "Game 1: Nối 5 khoản chi với nhóm chi phí!")
	
	for p in pf_node.MATCHING_PAIRS:
		pf_node._on_col_a_pressed(p["id"])
		pf_node._on_col_b_pressed(p["id"])
	assert(pf_node.matched_pairs.size() == 5, "Đã nối đúng 5 khoản chi tiêu vào các nhóm chi phí!")
	assert(pf_node.btn_go_phase2.disabled == false, "Nút sang Game 2 mở khóa!")
	
	pf_node._switch_to_phase2()
	assert(pf_node.current_phase == 2, "Đã sang Game 2: Sống sót với 5 triệu đồng!")
	for i in range(pf_node.SCENARIOS.size()):
		var scen = pf_node.SCENARIOS[i]
		var pf_opt = null
		for opt in scen["options"]:
			if opt["is_correct"]:
				pf_opt = opt
				break
		assert(pf_opt != null, "Mỗi tình huống phải có 1 đáp án đúng!")
		pf_node._on_option_chosen(pf_opt, Button.new())
		if i < pf_node.SCENARIOS.size() - 1:
			pf_node._on_next_scenario_pressed()
	assert(pf_node.completed_scenarios == 3, "Đã giải quyết chuẩn xác 3/3 tình huống tài chính phát sinh!")
	assert(pf_node.btn_finish_game.visible == true, "Nút hoàn thành game hiển thị!")
	
	pf_node._on_finish_game_pressed()
	var pf_completed = [false]
	pf_node.minigame_completed.connect(func(steps): pf_completed[0] = true)
	pf_node._on_claim_reward_pressed()
	assert(pf_completed[0] == true, "Phát tín hiệu hoàn thành Quản lý tài chính thành công!")
	print("  -> Quản lý tài chính cá nhân (Nối 5 khoản chi & Sống sót 5 triệu đồng) PASS 100%!")
	pf_node.queue_free()
	
	# [17] KIỂM THỬ KỸ NĂNG: QUẢN LÝ THỜI GIAN & DEADLINE (TIME MANAGEMENT GAME)
	print("\n[17] Kiểm thử Kỹ năng: Quản lý thời gian và công việc (TimeManagementGame):")
	var time_scene = load("res://scenes/minigames/TimeManagementGame.tscn")
	var time_node = time_scene.instantiate()
	add_child(time_node)
	time_node.load_minigame()
	assert(time_node.current_phase == 1, "Game 1: Sắp xếp 7 hoạt động sinh hoạt một ngày!")
	
	for act in time_node.SCHEDULE_ACTIVITIES:
		time_node.selected_activity_card = act.duplicate()
		time_node._on_slot_pressed(act["step"])
	assert(time_node.solved_activities.size() == 7, "Đã xếp đúng 7 mốc thời gian biểu sinh hoạt khoa học!")
	assert(time_node.btn_go_phase2.disabled == false, "Nút sang Game 2 mở khóa!")
	
	time_node._switch_to_phase2()
	assert(time_node.current_phase == 2, "Đã sang Game 2: Deadline đang đến & Ma trận Eisenhower!")
	for i in range(time_node.DEADLINE_QUESTIONS.size()):
		var q = time_node.DEADLINE_QUESTIONS[i]
		var t_opt = null
		for opt in q["options"]:
			if opt["is_correct"]:
				t_opt = opt
				break
		assert(t_opt != null, "Mỗi câu hỏi phải có đáp án đúng!")
		time_node._on_deadline_option_chosen(t_opt, Button.new())
		if i < time_node.DEADLINE_QUESTIONS.size() - 1:
			time_node._on_next_q_pressed()
	assert(time_node.completed_q_count == 3, "Đã hoàn thành 3/3 câu hỏi ma trận ưu tiên!")
	assert(time_node.btn_finish_game.visible == true, "Nút hoàn thành game hiển thị!")
	
	time_node._on_finish_game_pressed()
	var time_completed = [false]
	time_node.minigame_completed.connect(func(steps): time_completed[0] = true)
	time_node._on_claim_reward_pressed()
	assert(time_completed[0] == true, "Phát tín hiệu hoàn thành Quản lý thời gian thành công!")
	print("  -> Quản lý thời gian (7 mốc sinh hoạt & Ma trận Eisenhower Deadline) PASS 100%!")
	time_node.queue_free()
	
	# [18] KIỂM THỬ KỸ NĂNG: GIAO TIẾP VÀ GIẢI QUYẾT MÂU THUẪN (COMMUNICATION CONFLICT GAME)
	print("\n[18] Kiểm thử Kỹ năng: Giao tiếp & Giải quyết mâu thuẫn (CommunicationConflictGame):")
	var comm_scene = load("res://scenes/minigames/CommunicationConflictGame.tscn")
	var comm_node = comm_scene.instantiate()
	add_child(comm_node)
	comm_node.load_minigame()
	assert(comm_node.current_phase == 1, "Game 1: Nếu là bạn, bạn sẽ nói gì?")
	
	for i in range(comm_node.SITUATIONS.size()):
		var sit = comm_node.SITUATIONS[i]
		var cm_opt = null
		for opt in sit["options"]:
			if opt["is_correct"]:
				cm_opt = opt
				break
		assert(cm_opt != null, "Mỗi tình huống phải có đáp án đúng!")
		comm_node._on_situation_option_chosen(cm_opt, Button.new())
		if i < comm_node.SITUATIONS.size() - 1:
			comm_node._on_next_situation_pressed()
	assert(comm_node.completed_sit_count == 3, "Đã chọn đúng cách ứng xử cho 3/3 tình huống mâu thuẫn!")
	assert(comm_node.btn_go_phase2.visible == true, "Nút sang Game 2 mở khóa!")
	
	comm_node._switch_to_phase2()
	assert(comm_node.current_phase == 2, "Đã sang Game 2: Giao tiếp Xanh hay Đỏ?")
	for c in comm_node.SPEECH_CARDS:
		comm_node.selected_speech_card = c.duplicate()
		var target_basket = "green" if c["is_green"] else "red"
		comm_node._on_basket_chosen(target_basket)
	assert(comm_node.categorized_cards.size() == 6, "Đã phân loại đúng 6/6 câu nói vào rổ Xanh và Đỏ!")
	assert(comm_node.btn_finish_game.visible == true, "Nút hoàn thành game hiển thị!")
	
	comm_node._on_finish_game_pressed()
	var comm_completed = [false]
	comm_node.minigame_completed.connect(func(steps): comm_completed[0] = true)
	comm_node._on_claim_reward_pressed()
	assert(comm_completed[0] == true, "Phát tín hiệu hoàn thành Giao tiếp & Mâu thuẫn thành công!")
	print("  -> Giao tiếp & Giải quyết mâu thuẫn (3 tình huống ứng xử & 6 câu Xanh/Đỏ) PASS 100%!")
	comm_node.queue_free()
	
	# [19] KIỂM THỬ KỸ NĂNG: TỰ CHĂM SÓC BẢN THÂN & SINH HOẠT (SELF CARE LIVING GAME)
	print("\n[19] Kiểm thử Kỹ năng: Tự chăm sóc bản thân & Quản lý sinh hoạt (SelfCareLivingGame):")
	var care_scene = load("res://scenes/minigames/SelfCareLivingGame.tscn")
	var care_node = care_scene.instantiate()
	add_child(care_node)
	care_node.load_minigame()
	assert(care_node.current_phase == 1, "Game 1: Sắp xếp 4 bước quy trình giặt giũ!")
	
	for st in care_node.LAUNDRY_STEPS:
		care_node.selected_step_card = st.duplicate()
		care_node._on_slot_pressed(st["step"])
	assert(care_node.solved_laundry_steps.size() == 4, "Đã xếp đúng 4 bước quy trình giặt giũ khoa học!")
	assert(care_node.btn_go_phase2.disabled == false, "Nút sang Game 2 mở khóa!")
	
	care_node._switch_to_phase2()
	assert(care_node.current_phase == 2, "Đã sang Game 2: Hôm nay ăn gì & An toàn thực phẩm!")
	for i in range(care_node.FOOD_QUIZ_QUESTIONS.size()):
		var q = care_node.FOOD_QUIZ_QUESTIONS[i]
		var cr_opt = null
		for opt in q["options"]:
			if opt["is_correct"]:
				cr_opt = opt
				break
		assert(cr_opt != null, "Mỗi câu hỏi phải có đáp án đúng!")
		care_node._on_food_option_chosen(cr_opt, Button.new())
		if i < care_node.FOOD_QUIZ_QUESTIONS.size() - 1:
			care_node._on_next_q_pressed()
	assert(care_node.completed_q_count == 3, "Đã trả lời đúng 3/3 câu hỏi dinh dưỡng & tủ lạnh an toàn!")
	assert(care_node.btn_finish_game.visible == true, "Nút hoàn thành game hiển thị!")
	
	care_node._on_finish_game_pressed()
	var care_completed = [false]
	care_node.minigame_completed.connect(func(steps): care_completed[0] = true)
	care_node._on_claim_reward_pressed()
	assert(care_completed[0] == true, "Phát tín hiệu hoàn thành Tự chăm sóc bản thân thành công!")
	print("  -> Tự chăm sóc bản thân (4 bước giặt giũ & 3 câu Hôm nay ăn gì) PASS 100%!")
	care_node.queue_free()
	
	# [20] KIỂM THỬ KỸ NĂNG: BẢO DƯỠNG & SỰ CỐ XE MÁY (MOTORBIKE MAINTENANCE GAME)
	print("\n[20] Kiểm thử Kỹ năng: Bảo dưỡng & Sự cố xe máy (MotorbikeMaintenanceGame):")
	var motor_scene = load("res://scenes/minigames/MotorbikeMaintenanceGame.tscn")
	var motor_node = motor_scene.instantiate()
	add_child(motor_node)
	motor_node.load_minigame()
	assert(motor_node.current_phase == 1, "Game 1: Nối 5 dấu hiệu hư hỏng với biện pháp bảo dưỡng!")
	
	for p in motor_node.MATCHING_PAIRS:
		motor_node._on_col_a_pressed(p["id"])
		motor_node._on_col_b_pressed(p["id"])
	assert(motor_node.matched_pairs.size() == 5, "Đã nối đúng 5 cặp dấu hiệu hư hỏng xe máy!")
	assert(motor_node.btn_go_phase2.disabled == false, "Nút sang Game 2 mở khóa!")
	
	motor_node._switch_to_phase2()
	assert(motor_node.current_phase == 2, "Đã sang Game 2: Thợ sửa xe tập sự!")
	for i in range(motor_node.MECHANIC_CASES.size()):
		var c = motor_node.MECHANIC_CASES[i]
		var mt_opt = null
		for opt in c["options"]:
			if opt["is_correct"]:
				mt_opt = opt
				break
		assert(mt_opt != null, "Mỗi tình huống phải có đáp án đúng!")
		motor_node._on_case_option_chosen(mt_opt, Button.new())
		if i < motor_node.MECHANIC_CASES.size() - 1:
			motor_node._on_next_case_pressed()
	assert(motor_node.completed_case_count == 4, "Đã chẩn đoán chính xác 4/4 tình huống sự cố xe máy!")
	assert(motor_node.btn_finish_game.visible == true, "Nút hoàn thành game hiển thị!")
	
	motor_node._on_finish_game_pressed()
	var motor_completed = [false]
	motor_node.minigame_completed.connect(func(steps): motor_completed[0] = true)
	motor_node._on_claim_reward_pressed()
	assert(motor_completed[0] == true, "Phát tín hiệu hoàn thành Bảo dưỡng xe máy thành công!")
	print("  -> Bảo dưỡng xe máy (Nối 5 dấu hiệu & 4 tình huống chẩn đoán) PASS 100%!")
	motor_node.queue_free()
	
	print("\n========================================================")
	print("   TẤT CẢ 20 HỆ THỐNG GAMEPLAY MINI-GAME PASS 100%!   ")
	print("========================================================")
	get_tree().quit()
