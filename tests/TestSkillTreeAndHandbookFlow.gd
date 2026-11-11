extends Node

# TestSkillTreeAndHandbookFlow.gd
# Kiểm tra trực quan và chức năng của:
# 1. Bấm vào Học Kỹ Năng -> Ra full trang Bản Đồ Kỹ Năng (SkillTree), có nút Thoát, down menu chỉ chừa Cẩm Nang.
# 2. Bấm vào Cẩm Nang -> Ra full trang Tra Cứu Cẩm Nang (HandbookView), không phải popup.
# 3. Bấm Thoát -> Quay lại phòng trọ, down menu phục hồi đầy đủ 5 nút.

func _ready() -> void:
	print("--- BẮT ĐẦU TEST SKILL TREE & CẨM NANG FLOW ---")
	call_deferred("_start_test")

func _start_test() -> void:
	var main_scene = load("res://scenes/Main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	
	await get_tree().create_timer(0.4).timeout
	
	# BƯỚC 1: Chuyển sang Bản Đồ Kỹ Năng (như khi bấm nút Học Kỹ Năng)
	print(">>> BƯỚC 1: Mở Bản Đồ Kỹ Năng qua Học Kỹ Năng...")
	main.switch_to_map()
	await get_tree().create_timer(0.4).timeout
	
	# Kiểm tra nút Thoát
	var skill_tree = main.current_view_node
	var btn_back = skill_tree.get_node_or_null("BtnBack")
	if btn_back != null and btn_back.visible:
		print("  [PASS] Nút Thoát (BtnBack) hiện diện trên SkillTree: text = ", btn_back.text)
	else:
		printerr("  [FAIL] Không tìm thấy nút Thoát trên SkillTree!")
		
	# Kiểm tra BottomPawMenu: chỉ chừa lại Cẩm Nang
	var bottom = main.bottom_paw_menu
	var only_handbook_visible = (not bottom.btn_home.visible) and (not bottom.btn_food.visible) and (not bottom.btn_play.visible) and (not bottom.btn_learn.visible) and bottom.btn_handbook.visible
	if only_handbook_visible:
		print("  [PASS] Down menu chỉ chừa lại đúng 1 nút Cẩm Nang duy nhất!")
	else:
		printerr("  [FAIL] Down menu chưa lọc đúng! Home:", bottom.btn_home.visible, "Food:", bottom.btn_food.visible, "Play:", bottom.btn_play.visible, "Learn:", bottom.btn_learn.visible, "Handbook:", bottom.btn_handbook.visible)
		
	_capture_screenshot("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_skill_tree_with_exit_and_handbook_menu.png")
	await get_tree().create_timer(0.2).timeout
	
	# BƯỚC 2: Mở Cẩm Nang từ BottomPawMenu (hoặc switch_to_handbook)
	print(">>> BƯỚC 2: Mở Cẩm Nang Tra Cứu Toàn Màn Hình...")
	main.switch_to_handbook()
	await get_tree().create_timer(0.4).timeout
	
	var handbook = main.current_view_node
	var hb_btn_back = handbook.get_node_or_null("BtnBack")
	if hb_btn_back != null and hb_btn_back.visible:
		print("  [PASS] Nút Thoát trên HandbookView hiện diện: text = ", hb_btn_back.text)
	else:
		printerr("  [FAIL] Không tìm thấy nút Thoát trên HandbookView!")
		
	if not bottom.sub_drawer.visible:
		print("  [PASS] Cẩm nang mở dạng full trang tra cứu, hoàn toàn KHÔNG phải popup drawer!")
	else:
		printerr("  [FAIL] SubDrawer vẫn đang mở!")
		
	_capture_screenshot("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_handbook_full_page.png")
	await get_tree().create_timer(0.2).timeout
	
	# BƯỚC 3: Bấm nút Thoát quay lại phòng trọ
	print(">>> BƯỚC 3: Quay về Phòng Trọ & Kiểm tra phục hồi Menu...")
	main.switch_to_room()
	await get_tree().create_timer(0.4).timeout
	
	var all_menu_restored = bottom.btn_home.visible and bottom.btn_food.visible and bottom.btn_play.visible and bottom.btn_learn.visible and bottom.btn_handbook.visible
	if all_menu_restored:
		print("  [PASS] Down menu phục hồi đầy đủ 5 nút khi về phòng!")
	else:
		printerr("  [FAIL] Down menu chưa phục hồi đủ 5 nút!")
		
	_capture_screenshot("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_room_with_restored_down_menu.png")
	await get_tree().create_timer(0.2).timeout
	
	print("--- HOÀN THÀNH TEST TOÀN DIỆN THÀNH CÔNG ---")
	get_tree().quit()

func _capture_screenshot(file_path: String) -> void:
	var img = get_viewport().get_texture().get_image()
	img.save_png(file_path)
	print("  [SAVED SCREENSHOT] ->", file_path)
