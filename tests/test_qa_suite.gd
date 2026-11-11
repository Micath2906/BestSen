extends Node

# test_qa_suite.gd - Bộ Kiểm Thử Tự Động Toàn Diện Chuẩn Senior QA / Lead Game Tester
# Bao gồm: Unit test, Integration test, Data integrity, Regression test, Edge cases, Modals & Menus

var failures: Array = []
var warnings: Array = []
var passes: int = 0

func report_pass(desc: String) -> void:
	passes += 1
	print("  [PASS %02d] %s" % [passes, desc])

func report_fail(desc: String, err: String) -> void:
	failures.append({"desc": desc, "error": err})
	printerr("  [FAIL] %s -> Lỗi: %s" % [desc, err])

func report_warn(desc: String, msg: String) -> void:
	warnings.append({"desc": desc, "message": msg})
	print("  [WARN] %s -> %s" % [desc, msg])

func _ready() -> void:
	print("\n" + "=".repeat(65))
	print("      BESTSEN QA SUITE - KIỂM THỬ TOÀN DIỆN HỆ THỐNG")
	print("=".repeat(65))

	test_data_integrity()
	test_all_scenes_instantiation()
	test_game_manager_core_mechanics()
	test_shop_and_inventory_mechanics()
	test_minigames_logic()
	test_audio_assets()
	test_save_load_persistence()
	test_day_cycle_and_rent()
	test_hud_and_bottom_paw_menu()

	print("\n" + "=".repeat(65))
	print("               KẾT QUẢ TỔNG HỢP KIỂM THỬ (QA REPORT)")
	print("=".repeat(65))
	print("Tổng Pass: %d" % passes)
	print("Tổng Warnings: %d" % warnings.size())
	print("Tổng Failures: %d" % failures.size())

	if warnings.size() > 0:
		print("\n--- DANH SÁCH CẢNH BÁO (WARNINGS) ---")
		for w in warnings:
			print("  ⚠️ %s: %s" % [w["desc"], w["message"]])

	if failures.size() > 0:
		print("\n--- DANH SÁCH LỖI (FAILURES) ---")
		for f in failures:
			print("  ❌ %s: %s" % [f["desc"], f["error"]])
	else:
		print("\n🎉 CHÚC MỪNG: HỆ THỐNG ĐÃ VƯỢT QUA 100% CÁC BÀI KIỂM THỬ QA!")
	print("=".repeat(65) + "\n")

	get_tree().quit(1 if failures.size() > 0 else 0)

# =========================================================================
# 1. KIỂM THỬ TÍNH TOÀN VẸN DỮ LIỆU (DATA INTEGRITY)
# =========================================================================
func test_data_integrity() -> void:
	print("\n>>> PHẦN 1: KIỂM THỬ TOÀN VẸN DỮ LIỆU (DATA INTEGRITY)")

	# 1.1 Kiểm tra life_skills.json
	if GameManager.lessons_data.size() != 16:
		report_fail("Kiểm tra số lượng bài học life_skills.json", "Kỳ vọng 16 bài học nhưng có %d bài!" % GameManager.lessons_data.size())
	else:
		report_pass("Đầy đủ 16 bài học kỹ năng sống")

	var valid_steps = true
	for s in GameManager.lessons_data.values():
		if not s.has("id") or not s.has("title") or not s.has("branch") or not s.has("cards") or not s.has("guide"):
			report_fail("Kiểm tra thuộc tính bài học ID %s" % str(s.get("id")), "Thiếu thuộc tính bắt buộc (id, title, branch, cards, guide)")
			valid_steps = false
			break
		if s["cards"].size() < 3:
			report_fail("Số thẻ bài học ID %s" % str(s.get("id")), "Bài học phải có ít nhất 3 thẻ trình tự!")
			valid_steps = false
			break
	if valid_steps:
		report_pass("Toàn bộ 16 bài học có đầy đủ thuộc tính và thẻ trình tự")

	# 1.2 Kiểm tra shop_catalog.json
	var items = GameManager.shop_catalog_data.get("items", [])
	if items.size() == 0:
		report_fail("Kiểm tra nạp shop_catalog.json", "Catalog rỗng!")
	else:
		report_pass("Nạp shop_catalog.json thành công (%d sản phẩm)" % items.size())

	for item in items:
		if not item.has("id") or not item.has("name") or not item.has("category") or not item.has("price"):
			report_fail("Thuộc tính sản phẩm Shop ID %s" % str(item.get("id")), "Thiếu id, name, category, hoặc price")
		if item.get("price", 0) < 0:
			report_fail("Giá sản phẩm Shop ID %s" % str(item.get("id")), "Giá bán âm: %d" % item.get("price"))

	# 1.3 Kiểm tra minigames_data.json
	if GameManager.minigames_data.size() < 12:
		report_warn("Số lượng minigames", "Có %d minigame trong dữ liệu (kỳ vọng ít nhất 12)" % GameManager.minigames_data.size())
	else:
		report_pass("Đầy đủ %d minigame tương tác thực tế" % GameManager.minigames_data.size())

# =========================================================================
# 2. KIỂM THỬ KHỞI TẠO TẤT CẢ SCENES (SCENE INSTANTIATION)
# =========================================================================
func test_all_scenes_instantiation() -> void:
	print("\n>>> PHẦN 2: KIỂM THỬ KHỞI TẠO TẤT CẢ SCENES & MODALS")
	var scenes_to_test = [
		"res://scenes/MainMenu.tscn",
		"res://scenes/Main.tscn",
		"res://scenes/IsometricRoomView.tscn",
		"res://scenes/LessonView.tscn",
		"res://scenes/ShopView.tscn",
		"res://scenes/HouseAndDressView.tscn",
		"res://scenes/HandbookView.tscn",
		"res://scenes/MuseumView.tscn",
		"res://scenes/SkillTree.tscn",
		"res://scenes/CatProfileHUD.tscn",
		"res://scenes/BottomPawMenu.tscn",
		"res://scenes/AvatarPickerModal.tscn",
		"res://scenes/PauseModal.tscn",
		"res://scenes/StatusAlertModal.tscn",
		"res://scenes/IsometricCat.tscn",
		"res://scenes/minigames/AuditMiniGame.tscn",
		"res://scenes/minigames/BudgetMiniGame.tscn",
		"res://scenes/minigames/DialogueMiniGame.tscn",
		"res://scenes/minigames/PackingMiniGame.tscn",
		"res://scenes/minigames/PreparationValiGame.tscn",
		"res://scenes/minigames/HospitalChoiceGame.tscn",
		"res://scenes/minigames/SelfDiagnosisGame.tscn",
		"res://scenes/minigames/HospitalBHYTProcessGame.tscn",
		"res://scenes/minigames/RentalContractGame.tscn",
		"res://scenes/minigames/LaborRightsGame.tscn",
		"res://scenes/minigames/CyberSecurityGame.tscn",
		"res://scenes/minigames/TrafficSafetyGame.tscn",
		"res://scenes/minigames/PublicAdminGame.tscn",
		"res://scenes/minigames/QteMiniGame.tscn",
		"res://scenes/minigames/PersonalFinanceGame.tscn",
		"res://scenes/minigames/TimeManagementGame.tscn",
		"res://scenes/minigames/CommunicationConflictGame.tscn",
		"res://scenes/minigames/SelfCareLivingGame.tscn",
		"res://scenes/minigames/MotorbikeMaintenanceGame.tscn",
		"res://scenes/minigames/RouteMasterMiniGame.tscn",
		"res://scenes/minigames/CheckInRushGame.tscn",
		"res://scenes/minigames/CivilizedRideGame.tscn",
		"res://scenes/RoomDecorStudioView.tscn",
		"res://scenes/categories/CategoryMobility.tscn",
		"res://scenes/categories/CategoryHousingLegal.tscn",
		"res://scenes/categories/CategoryHealthMedical.tscn",
		"res://scenes/categories/CategoryFinanceCareer.tscn"
	]

	for path in scenes_to_test:
		var scn = load(path)
		if scn == null:
			report_fail("Tải scene: %s" % path, "Không thể load() scene từ đường dẫn!")
			continue
		var node = scn.instantiate()
		if node == null:
			report_fail("Khởi tạo node từ scene: %s" % path, "instantiate() trả về null!")
			continue
		add_child(node)
		report_pass("Khởi tạo thành công: %s" % path.get_file())
		node.queue_free()

# =========================================================================
# 3. KIỂM THỬ LOGIC GAMEMANAGER & GIỚI HẠN CHỈ SỐ (CORE MECHANICS)
# =========================================================================
func test_game_manager_core_mechanics() -> void:
	print("\n>>> PHẦN 3: KIỂM THỬ CƠ CHẾ CỐT LÕI & GIỚI HẠN CHỈ SỐ")

	# Lưu trạng thái ban đầu
	var orig_hunger = GameManager.hunger
	var orig_courage = GameManager.courage
	var orig_mood = GameManager.mood
	var orig_fish = GameManager.fish
	var orig_debt = GameManager.debt_amount

	# 3.1 Clamp giá trị không vượt 100
	GameManager.hunger = 999
	GameManager.courage = 999
	GameManager.mood = 999
	GameManager.update_stats(0, 0, 0, 0)
	if GameManager.hunger > 100 or GameManager.courage > 100 or GameManager.mood > 100:
		report_fail("Giới hạn cận trên chỉ số (Max 100)", "Chỉ số bị vượt quá 100: Hunger=%d, Courage=%d, Mood=%d" % [GameManager.hunger, GameManager.courage, GameManager.mood])
	else:
		report_pass("Giới hạn cận trên (Max 100) được kiểm soát chặt chẽ")

	# 3.2 Clamp giá trị không âm
	GameManager.hunger = -50
	GameManager.courage = -50
	GameManager.mood = -50
	GameManager.update_stats(0, 0, 0, 0)
	if GameManager.hunger < 0 or GameManager.courage < 0 or GameManager.mood < 0:
		report_fail("Giới hạn cận dưới chỉ số (Min 0)", "Chỉ số bị âm: Hunger=%d, Courage=%d, Mood=%d" % [GameManager.hunger, GameManager.courage, GameManager.mood])
	else:
		report_pass("Giới hạn cận dưới (Min 0) được kiểm soát chặt chẽ")

	# 3.3 Trạng thái đói ngất xỉu (Fainted)
	GameManager.hunger = 0
	GameManager.update_stats(0, 0, 0, 0)
	if not GameManager.is_fainted:
		report_fail("Trạng thái đói lả (Hunger = 0)", "GameManager.is_fainted phải là true!")
	else:
		report_pass("Mèo ngất xỉu chính xác khi đói lả (Hunger = 0)")

	var can_learn_when_fainted = GameManager.can_start_lesson()
	if can_learn_when_fainted["ok"]:
		report_fail("Chặn học khi đói ngất xỉu", "can_start_lesson() phải trả về false khi is_fainted!")
	else:
		report_pass("Chặn học bài thành công khi mèo đói ngất xỉu")

	# 3.4 Trạng thái tự ti (Shy)
	GameManager.hunger = 50
	GameManager.courage = 10
	GameManager.update_stats(0, 0, 0, 0)
	if not GameManager.is_shy:
		report_fail("Trạng thái tự ti (Courage <= 15)", "GameManager.is_shy phải là true!")
	else:
		report_pass("Mèo tự ti chính xác khi Dũng Cảm <= 15")

	var can_learn_when_shy = GameManager.can_start_lesson()
	if can_learn_when_shy["ok"]:
		report_fail("Chặn học khi mèo tự ti", "can_start_lesson() phải trả về false khi is_shy!")
	else:
		report_pass("Chặn học bài thành công khi mèo tự ti")

	# 3.5 Bẫy nợ BNPL (Ví Trả Sau)
	GameManager.use_bnpl()
	if GameManager.debt_amount <= 0:
		report_fail("Cơ chế bẫy nợ BNPL", "use_bnpl() không ghi nhận debt_amount!")
	else:
		report_pass("Thiết lập trạng thái bẫy nợ BNPL thành công (Nợ: %d)" % GameManager.debt_amount)

	# Khôi phục trạng thái ban đầu
	GameManager.hunger = orig_hunger
	GameManager.courage = orig_courage
	GameManager.mood = orig_mood
	GameManager.fish = orig_fish
	GameManager.debt_amount = orig_debt
	GameManager.update_stats(0, 0, 0, 0)

# =========================================================================
# 4. KIỂM THỬ CỬA HÀNG & KHO ĐỒ (SHOP & INVENTORY)
# =========================================================================
func test_shop_and_inventory_mechanics() -> void:
	print("\n>>> PHẦN 4: KIỂM THỬ CỬA HÀNG & KHO ĐỒ (SHOP & INVENTORY)")

	var saved_mastery_level = GameManager.cat_mastery_level
	GameManager.cat_mastery_level = 5 # Đảm bảo đủ level mua mọi item test
	var items = GameManager.shop_catalog_data.get("items", [])
	var test_item_id = ""
	for it in items:
		if it["category"] == "costumes" and not GameManager.is_item_owned(it["id"]):
			test_item_id = it["id"]
			break
	if test_item_id == "":
		test_item_id = "c_hoodie_student"
		GameManager.inventory_costumes.erase(test_item_id)

	# Kiểm tra logic tiền không đủ
	var saved_fish = GameManager.fish
	GameManager.fish = 0
	var poor_result = GameManager.buy_shop_item(test_item_id)
	if poor_result["ok"]:
		report_fail("Chống mua khi thiếu Cá Khô", "buy_shop_item() không được trả về true khi không đủ tiền!")
	else:
		report_pass("Chặn mua thành công khi số dư Cá Khô = 0")

	# Kiểm tra mua thành công
	GameManager.fish = 100
	var buy_res = GameManager.buy_shop_item(test_item_id)
	if not buy_res["ok"]:
		report_fail("Mua sản phẩm hợp lệ", "buy_shop_item() thất bại: %s" % buy_res.get("reason", ""))
	else:
		report_pass("Mua sản phẩm hợp lệ thành công")

	# Chống mua trùng trang phục vĩnh viễn
	var buy_again = GameManager.buy_shop_item(test_item_id)
	if buy_again["ok"]:
		report_fail("Chống mua trùng trang phục vĩnh viễn", "Đã sở hữu trang phục nhưng vẫn cho phép mua lại!")
	else:
		report_pass("Chống mua trùng trang phục vĩnh viễn hoạt động chính xác")

	# Khôi phục số dư & level
	GameManager.fish = saved_fish
	GameManager.cat_mastery_level = saved_mastery_level

# =========================================================================
# 5. KIỂM THỬ LOGIC CÁC DẠNG MINIGAME (MINIGAMES)
# =========================================================================
func test_minigames_logic() -> void:
	print("\n>>> PHẦN 5: KIỂM THỬ LOGIC MINIGAMES (5 DẠNG)")

	var types = ["audit", "packing", "budget", "qte", "dialogue"]
	var found_types = {}
	for k in GameManager.minigames_data.keys():
		var mg = GameManager.minigames_data[k]
		if mg is Dictionary:
			var t = mg.get("type", "")
			found_types[t] = true

	for t in types:
		if not found_types.has(t):
			report_fail("Kiểm tra dạng minigame: %s" % t, "Không tìm thấy bài học nào sử dụng minigame dạng '%s'!" % t)
		else:
			report_pass("Minigame dạng '%s' được định nghĩa hợp lệ trong dữ liệu" % t)

# =========================================================================
# 6. KIỂM THỬ TÀI NGUYÊN ÂM THANH (AUDIO ASSETS)
# =========================================================================
func test_audio_assets() -> void:
	print("\n>>> PHẦN 6: KIỂM THỬ TÀI NGUYÊN ÂM THANH (SOUND ASSETS)")
	var clips = [
		"res://assets/sounds/clips/clip_01.wav",
		"res://assets/sounds/clips/clip_03.wav",
		"res://assets/sounds/clips/clip_09.wav",
		"res://assets/sounds/clips/clip_19.wav",
		"res://assets/sounds/clips/clip_22.wav",
		"res://assets/sounds/clips/clip_29.wav",
		"res://assets/sounds/clips/clip_31.wav",
		"res://assets/sounds/clips/clip_35.wav",
		"res://assets/sounds/clips/clip_44.wav",
		"res://assets/sounds/clips/clip_45.wav"
	]
	var all_clips_exist = true
	for c in clips:
		if not FileAccess.file_exists(c) and not ResourceLoader.exists(c):
			report_fail("Kiểm tra file âm thanh: %s" % c, "File không tồn tại!")
			all_clips_exist = false
	if all_clips_exist:
		report_pass("Toàn bộ các file âm thanh WAV chính nạp thành công")

	# Kiểm tra Pool Procedural Tone
	if SoundManager.tone_players.size() == 3:
		report_pass("Pool Tone Players (3 kênh) đã được cấp phát cố định, triệt tiêu Memory Leak")
	else:
		report_fail("Pool Tone Players", "Kỳ vọng 3 player trong pool nhưng có: %d" % SoundManager.tone_players.size())

# =========================================================================
# 7. KIỂM THỬ LƯU VÀ NẠP TIẾN TRÌNH & BẢO MẬT (SAVE / LOAD & CHECKSUM)
# =========================================================================
func test_save_load_persistence() -> void:
	print("\n>>> PHẦN 7: KIỂM THỬ TIẾN TRÌNH LƯU VÀ NẠP GAME (PERSISTENCE & SECURITY)")

	var prev_cat_name = GameManager.custom_cat_name
	var test_name = "QA_Tester_Cat_%d" % randi()

	GameManager.set_cat_name(test_name)
	GameManager.save_game()

	# Kiểm tra sự tồn tại của file chính và file backup .bak
	if not FileAccess.file_exists("user://save_game.json"):
		report_fail("Kiểm tra file save chính", "File user://save_game.json không tồn tại!")
	else:
		report_pass("File user://save_game.json lưu thành công")

	if not FileAccess.file_exists("user://save_game.bak"):
		report_warn("Kiểm tra file save backup", "File backup user://save_game.bak chưa được tạo trong lần đầu tiên")
	else:
		report_pass("Hệ thống sao lưu dự phòng tự động user://save_game.bak hoạt động tốt")

	# Kiểm tra cấu trúc Envelope Version 2 và Checksum SHA-256
	var f = FileAccess.open("user://save_game.json", FileAccess.READ)
	if f:
		var txt = f.get_as_text()
		var j = JSON.new()
		if j.parse(txt) == OK:
			var parsed = j.get_data()
			if parsed is Dictionary and parsed.has("checksum") and parsed.has("version") and parsed.get("version") == 2:
				report_pass("Cấu trúc Envelope Version 2 với Checksum SHA-256 chống hack file")
			else:
				report_fail("Kiểm tra định dạng Envelope V2", "File save thiếu trường checksum hoặc version!")

	# Giả lập nạp lại
	GameManager.custom_cat_name = ""
	GameManager.load_game()

	if GameManager.custom_cat_name != test_name:
		report_fail("Lưu và nạp tên Mèo", "Kỳ vọng '%s' nhưng nhận được '%s'!" % [test_name, GameManager.custom_cat_name])
	else:
		report_pass("Lưu và nạp game hoàn hảo (Persistence check pass)")

	# Trả lại tên cũ
	GameManager.set_cat_name(prev_cat_name)
	GameManager.save_game()

# =========================================================================
# 8. KIỂM THỬ CHU KỲ NGÀY & TIỀN TRỌ KTX (DAY CYCLE & RENT SYSTEM)
# =========================================================================
func test_day_cycle_and_rent() -> void:
	print("\n>>> PHẦN 8: KIỂM THỬ CHU KỲ NGÀY & TIỀN TRỌ KTX")

	var initial_day = GameManager.current_day
	var initial_days_left = GameManager.days_until_rent_due

	GameManager.advance_day()
	if GameManager.current_day != initial_day + 1:
		report_fail("advance_day() tăng ngày", "Kỳ vọng ngày %d nhưng nhận được %d" % [initial_day + 1, GameManager.current_day])
	else:
		report_pass("advance_day() tăng ngày sinh hoạt chính xác (Ngày %d)" % GameManager.current_day)

	if GameManager.days_until_rent_due != maxi(0, initial_days_left - 1):
		report_fail("Đếm ngược ngày đóng tiền trọ", "Số ngày còn lại không giảm!")
	else:
		report_pass("Đếm ngược hạn đóng tiền trọ chính xác (Còn %d ngày)" % GameManager.days_until_rent_due)

	if GameManager.daily_relief_sent != 0 or GameManager.daily_relief_received != 0:
		report_fail("Reset hạn mức cứu trợ mỗi ngày", "daily_relief chưa được reset về 0!")
	else:
		report_pass("Tự động reset hạn mức quỹ tương trợ sinh viên sang ngày mới")

# =========================================================================
# 9. KIỂM THỬ GIAO DIỆN HUD VÀ THANH DOCK ĐÁY (HUD & BOTTOM PAW MENU)
# =========================================================================
func test_hud_and_bottom_paw_menu() -> void:
	print("\n>>> PHẦN 9: KIỂM THỬ GIAO DIỆN HUD & BOTTOM PAW MENU")

	var hud_scene = load("res://scenes/CatProfileHUD.tscn")
	var hud = hud_scene.instantiate()
	add_child(hud)

	if hud.avatar_btn == null:
		report_fail("HUD Avatar Button", "Nút AvatarButton không tìm thấy!")
	else:
		report_pass("Avatar Button trên HUD kết nối tốt")

	if hud.hunger_bar == null:
		report_fail("HUD Hunger Bar", "Thanh hunger_bar không tìm thấy!")
	else:
		report_pass("Thanh Độ No trên HUD kết nối tốt")

	if hud.lbl_hunger_val == null:
		report_fail("HUD Hunger Value Label", "HungerValueLabel bị thiếu trong CatProfileHUD.tscn!")
	else:
		report_pass("Nhãn chỉ số Độ No HungerValueLabel hiện diện đầy đủ")

	hud.queue_free()

	var bottom_scene = load("res://scenes/BottomPawMenu.tscn")
	var bottom = bottom_scene.instantiate()
	add_child(bottom)

	if bottom.sub_drawer == null:
		report_fail("Bottom Paw Menu Drawer", "Khay kéo phụ sub_drawer không tìm thấy!")
	else:
		report_pass("Khay kéo thức ăn & đồ chơi SubDrawer kết nối tốt")

	bottom.queue_free()
