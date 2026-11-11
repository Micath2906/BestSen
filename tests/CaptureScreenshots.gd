extends Control

@onready var main = $Main

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	
	# 1. Chụp màn hình phòng Isometric
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("D:/BestSen/screenshot_isometric_room.png")
	print("Captured: screenshot_isometric_room.png")
	
	# 2. Mở Cẩm Nang Cứu Sen
	main.switch_to_handbook()
	await get_tree().create_timer(0.6).timeout
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("D:/BestSen/screenshot_handbook_list.png")
	print("Captured: screenshot_handbook_list.png")
	
	# 3. Mở chi tiết cẩm nang bài 1
	var handbook_view = main.current_view_node
	if handbook_view and handbook_view.has_method("_open_detail"):
		handbook_view._open_detail(1)
		await get_tree().create_timer(0.6).timeout
		var img3 = get_viewport().get_texture().get_image()
		img3.save_png("D:/BestSen/screenshot_handbook_detail.png")
		print("Captured: screenshot_handbook_detail.png")
		handbook_view.detail_modal.visible = false
		await get_tree().create_timer(0.3).timeout
	
	# 4. Chuyển sang màn hình LessonView (Học kỹ năng bài 1)
	main.start_lesson(1)
	await get_tree().create_timer(0.6).timeout
	
	# Đặt 2 thẻ vào khay để thấy giao diện khay 3D đang chơi dở
	var lesson_view = main.current_view_node
	if lesson_view and "shuffled_cards" in lesson_view and lesson_view.shuffled_cards.size() >= 2:
		lesson_view._pick_card(lesson_view.shuffled_cards[0])
		lesson_view._pick_card(lesson_view.shuffled_cards[1])
		await get_tree().create_timer(0.3).timeout
		
	var img4 = get_viewport().get_texture().get_image()
	img4.save_png("D:/BestSen/screenshot_lesson_flashcards.png")
	print("Captured: screenshot_lesson_flashcards.png")
	
	print("ALL CAPTURES COMPLETED!")
	get_tree().quit()
