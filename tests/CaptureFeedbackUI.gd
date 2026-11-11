extends Control

@onready var main = $Main

func _ready() -> void:
	await get_tree().create_timer(0.6).timeout
	
	# Đảm bảo chỉ số cơ bản sạch sẽ để hiển thị thanh status đẹp
	GameManager.hunger = 70
	GameManager.courage = 80
	GameManager.mood = 90
	GameManager.stats_changed.emit()
	await get_tree().create_timer(0.3).timeout
	
	# 1. Chụp màn hình phòng chính với Bảng tên ở giữa, 3 nút gom 1 chỗ và thanh status chỉ số sạch
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("D:/BestSen/screenshot_room_unified_layout.png")
	print("Captured: screenshot_room_unified_layout.png")
	
	# 2. Mở Pop-up Cảnh Báo Trạng Thái (StatusAlertModal - Quá No hoặc Quá Stress)
	main._on_show_status_alert("too_full")
	await get_tree().create_timer(0.4).timeout
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("D:/BestSen/screenshot_status_alert_modal.png")
	print("Captured: screenshot_status_alert_modal.png")
	
	# Đóng pop-up cảnh báo
	if main.status_alert_modal:
		main.status_alert_modal.close()
	await get_tree().create_timer(0.2).timeout
	
	# 3. Mở Modal Đổi Tên Phòng (RoomNameModal)
	var room_view = main.current_view_node
	if room_view and room_view.has_method("_open_rename_modal"):
		room_view._open_rename_modal()
	await get_tree().create_timer(0.4).timeout
	var img3 = get_viewport().get_texture().get_image()
	img3.save_png("D:/BestSen/screenshot_room_rename_modal.png")
	print("Captured: screenshot_room_rename_modal.png")
	
	print("ALL FEEDBACK SCREENSHOTS CAPTURED!")
	get_tree().quit()
