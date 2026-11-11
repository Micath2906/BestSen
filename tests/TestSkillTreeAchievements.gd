extends Node

const ARTIFACT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/"

func _ready() -> void:
	print("========================================================")
	print("   BEST SEN - SUITE KIỂM THỬ MỤC XEM THÀNH TỰU & PUZZLE   ")
	print("========================================================")
	
	# [1] KIỂM THỬ KHỞI TẠO ACHIEVEMENT MODAL
	print("\n[1] Kiểm thử Khởi tạo AchievementModal.tscn:")
	var modal_scene = load("res://scenes/AchievementModal.tscn")
	assert(modal_scene != null, "Scene AchievementModal.tscn phải nạp thành công!")
	var modal = modal_scene.instantiate()
	add_child(modal)
	assert(modal != null, "AchievementModal phải instantiate thành công!")
	print("  -> Khởi tạo AchievementModal thành công!")
	
	# [2] KIỂM THỬ DỮ LIỆU 4 BỘ TRANH GHÉP PUZZLE
	print("\n[2] Kiểm thử Dữ liệu 4 Bộ Ghép Tranh Puzzle & 16 Mảnh:")
	assert(modal.PUZZLE_SETS.size() == 4, "Phải có đúng 4 bộ Puzzle Tranh Ghép!")
	assert(modal.LOOT_PIECES.size() == 16, "Phải có đủ 16 mảnh ghép tương ứng 16 bài học!")
	print("  -> 4 Bộ Puzzle (Thổ Địa, Thuê Trọ, Y Tế, Tài Chính) & 16 Mảnh ghép PASS 100%!")
	
	# [3] KIỂM THỬ LOGIC GHÉP MẢNH & NHẬN CHỨNG NHẬN DANH DỰ
	print("\n[3] Kiểm thử Logic Ghép Đủ 4 Mảnh & Nhận Chứng Nhận:")
	# Giả lập hoàn thành 4 bài của Bộ 1 (Thổ Địa Đường Phố)
	GameManager.completed_lessons = [1, 2, 3, 4]
	GameManager.claimed_certificates = []
	var prev_fish = GameManager.fish
	
	modal.refresh_achievements()
	var set1_card = modal.puzzle_list_container.get_child(0)
	assert(set1_card != null, "Card Bộ 1 phải tồn tại!")
	
	# Nhận chứng nhận Bộ 1
	var set1_data = modal.PUZZLE_SETS[0]
	modal._claim_certificate(set1_data)
	
	assert(GameManager.is_certificate_claimed("cert_street"), "Chứng nhận cert_street phải được lưu thành công!")
	assert(GameManager.fish == prev_fish + 50, "Nhận chứng nhận phải thưởng +50.000đ tiền mặt!")
	assert(modal.cert_popup.visible == true, "Popup Bằng Chứng Nhận Hoàng Gia phải hiển thị rực rỡ!")
	print("  -> Nhận Chứng Nhận Thổ Địa Thành Phố & Thưởng +50.000đ PASS 100%!")
	modal.cert_popup.visible = false
	modal.queue_free()
	
	# [4] KIỂM THỬ TÍCH HỢP NÚT XEM THÀNH TỰU TRONG SKILLTREE (HỌC KỸ NĂNG)
	print("\n[4] Kiểm thử Nút 'Xem Thành Tựu' trong SkillTree.tscn:")
	var tree_scene = load("res://scenes/SkillTree.tscn")
	assert(tree_scene != null, "SkillTree.tscn phải nạp thành công!")
	var tree = tree_scene.instantiate()
	add_child(tree)
	
	assert(tree.btn_achievements != null, "Nút btn_achievements phải hiện diện trên SkillTree!")
	assert(tree.achievement_modal != null, "achievement_modal phải được khởi tạo bên trong SkillTree!")
	assert(tree.btn_preview_puzzle != null, "Nút xem puzzle trong LevelPreviewModal phải hiện diện!")
	
	# Test bấm nút mở thành tựu từ SkillTree
	tree.btn_achievements.emit_signal("pressed")
	assert(tree.achievement_modal.visible == true, "Bấm nút Thành tựu phải mở AchievementModal!")
	tree.achievement_modal.visible = false
	print("  -> Nút Xem Thành Tựu trong Bản Đồ Học Kỹ Năng PASS 100%!")
	tree.queue_free()
	
	# [5] KIỂM THỬ TÍCH HỢP NÚT XEM THÀNH TỰU TRONG LESSONVIEW (MÀN HỌC BÀI)
	print("\n[5] Kiểm thử Nút 'Xem Thành Tựu' trong LessonView.tscn:")
	var lesson_scene = load("res://scenes/LessonView.tscn")
	assert(lesson_scene != null, "LessonView.tscn phải nạp thành công!")
	var lesson_view = lesson_scene.instantiate()
	add_child(lesson_view)
	
	assert(lesson_view.btn_achievements != null, "Nút btn_achievements phải hiện diện trong Header LessonView!")
	assert(lesson_view.achievement_modal != null, "achievement_modal phải được tích hợp sẵn trong LessonView!")
	
	# Test bấm nút mở thành tựu từ LessonView
	lesson_view.btn_achievements.emit_signal("pressed")
	assert(lesson_view.achievement_modal.visible == true, "Bấm nút Thành tựu từ bài học phải mở AchievementModal!")
	print("  -> Nút Xem Thành Tựu trong Màn Học Bài PASS 100%!")
	lesson_view.queue_free()
	
	# [6] CHỤP ẢNH MINH CHỨNG TRỰC QUAN GIAO DIỆN THÀNH TỰU & PUZZLE
	print("\n[6] Chụp Ảnh Minh Chứng Trực Quan Thành Tựu & Puzzle:")
	var show_modal = modal_scene.instantiate()
	add_child(show_modal)
	show_modal.size = Vector2(540, 960)
	show_modal.open()
	
	await get_tree().create_timer(0.5).timeout
	var vp = get_viewport()
	if vp and vp.get_texture():
		var img = vp.get_texture().get_image()
		if img:
			img.save_png(ARTIFACT_DIR + "screenshot_achievement_puzzle_modal_full.png")
			# Crop khu vực card thành tựu & tranh ghép
			var crop_card = img.get_region(Rect2i(25, 135, 490, 690))
			crop_card.save_png(ARTIFACT_DIR + "screenshot_achievement_modal_card.png")
			print("Đã chụp: screenshot_achievement_modal_card.png")
	
	# Mở popup Bằng Chứng Nhận và chụp
	show_modal._show_cert_popup(show_modal.PUZZLE_SETS[0])
	await get_tree().create_timer(0.4).timeout
	var vp_cert = get_viewport()
	if vp_cert and vp_cert.get_texture():
		var img_cert = vp_cert.get_texture().get_image()
		if img_cert:
			var crop_cert = img_cert.get_region(Rect2i(60, 240, 420, 480))
			crop_cert.save_png(ARTIFACT_DIR + "screenshot_certificate_popup.png")
			print("Đã chụp: screenshot_certificate_popup.png")
	
	show_modal.queue_free()
	
	# Chụp thêm giao diện SkillTree có nút Xem Thành Tựu nổi bật
	var show_tree = tree_scene.instantiate()
	add_child(show_tree)
	show_tree.size = Vector2(540, 960)
	show_tree.refresh_list()
	await get_tree().create_timer(0.5).timeout
	var vp_tree = get_viewport()
	if vp_tree and vp_tree.get_texture():
		var img_tree = vp_tree.get_texture().get_image()
		if img_tree:
			var crop_tree_banner = img_tree.get_region(Rect2i(10, 115, 520, 160))
			crop_tree_banner.save_png(ARTIFACT_DIR + "screenshot_skilltree_achievement_button.png")
			print("Đã chụp: screenshot_skilltree_achievement_button.png")
	show_tree.queue_free()
	
	print("\n========================================================")
	print("   TẤT CẢ TÍNH NĂNG XEM THÀNH TỰU ĐẠT CHUẨN XUẤT SẮC 100%!  ")
	print("========================================================")
	get_tree().quit(0)
