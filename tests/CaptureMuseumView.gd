extends Control

@onready var main = $Main

func _ready() -> void:
	await get_tree().create_timer(0.4).timeout
	
	# Chuẩn bị dữ liệu: mở khóa 4 bài học (1, 2, 4, 7) để tủ trưng bày có cả cúp vàng lẫn cúp gỗ chưa mở
	GameManager.completed_lessons = [1, 2, 4, 7]
	
	# 1. Chuyển sang màn hình Bảo Tàng Sinh Tồn (Museum)
	main.switch_to_museum()
	await get_tree().create_timer(0.4).timeout
	
	var museum_view = main.current_view_node
	assert(museum_view != null, "MuseumView phải được khởi tạo!")
	assert(main.current_tab_name == "museum", "Tab hiện tại phải là museum!")
	
	# Kiểm tra hiển thị tiến độ 4/16
	assert(museum_view.loot_grid.get_child_count() == 16, "Tủ kính phải có đúng 16 bục trưng bày!")
	assert(museum_view.badges_container.get_child_count() == 6, "Bộ sưu tập huy hiệu phải có 6 huy hiệu!")
	assert(museum_view.total_loot_label.text.contains("4/16"), "Nhãn tiến độ phải hiển thị 4/16 chiến lợi phẩm!")
	print("Museum data verification: PASS (16 slots, 6 badges, 4/16 progress)")
	
	# 2. Chụp ảnh màn hình Bảo Tàng đã tái thiết kế (Nửa trên)
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("D:/BestSen/screenshot_museum_redesign.png")
	print("Captured: screenshot_museum_redesign.png")
	
	# Cuộn xuống để chụp phần Huy Hiệu & Bạn Bè (Nửa dưới)
	var scroll = museum_view.get_node("ScrollContainer")
	scroll.scroll_vertical = 850
	await get_tree().create_timer(0.3).timeout
	var img_scroll = get_viewport().get_texture().get_image()
	img_scroll.save_png("D:/BestSen/screenshot_museum_social_section.png")
	print("Captured: screenshot_museum_social_section.png")
	scroll.scroll_vertical = 0
	await get_tree().create_timer(0.2).timeout
	
	# 3. Chạm vào ô cúp Bài 1 (đã mở khóa) để mở Modal Chi Tiết
	var slot_0 = museum_view.loot_grid.get_child(0)
	var ev_click = InputEventMouseButton.new()
	ev_click.button_index = MOUSE_BUTTON_LEFT
	ev_click.pressed = true
	slot_0.gui_input.emit(ev_click)
	await get_tree().create_timer(0.3).timeout
	
	assert(museum_view.inspect_modal.visible == true, "Inspect modal phải hiển thị khi chạm vào cúp đã mở khóa!")
	assert(museum_view.modal_title.text == "Cuống vé xe buýt số 08", "Tên vật phẩm trong modal phải chính xác!")
	print("Inspect modal opened: PASS!")
	
	# 4. Chụp ảnh màn hình Modal chi tiết
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("D:/BestSen/screenshot_museum_inspect_modal.png")
	print("Captured: screenshot_museum_inspect_modal.png")
	
	# 5. Đóng modal chi tiết
	museum_view.btn_close_inspect.emit_signal("pressed")
	await get_tree().create_timer(0.2).timeout
	assert(museum_view.inspect_modal.visible == false, "Inspect modal phải ẩn sau khi đóng!")
	print("Close inspect modal: PASS!")
	
	# 6. Thử chạm nút ⬅ Về Phòng
	museum_view.btn_back.emit_signal("pressed")
	await get_tree().create_timer(0.3).timeout
	assert(main.current_tab_name == "room", "Nút Về Phòng phải chuyển view về room!")
	print("Back to room button: PASS!")
	
	print("ALL MUSEUM REDESIGN TESTS PASSED!")
	get_tree().quit()
