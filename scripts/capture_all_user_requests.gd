extends SceneTree

var step = 0
var main_instance: Node = null

func _init():
	var packed = load("res://scenes/Main.tscn")
	main_instance = packed.instantiate()
	root.add_child(main_instance)

func _process(_delta):
	step += 1
	if step == 5:
		# Chụp ảnh 1: Phòng trọ tối giản 4 vật dụng & Cửa Hàng góc trên bên phải
		_save_screenshot("res://screenshot_verified_room_minimal_and_shop.png")
	elif step == 10:
		# Mở Drawer Cho Ăn (Chỉ hiển thị đồ đang có)
		var bottom_menu = main_instance.get_node("BottomPawMenu")
		bottom_menu._toggle_drawer("food")
	elif step == 15:
		_save_screenshot("res://screenshot_verified_food_drawer.png")
	elif step == 20:
		# Mở Drawer Đồ Chơi (Cuộn len 1 phút +10 mood)
		var bottom_menu = main_instance.get_node("BottomPawMenu")
		bottom_menu._toggle_drawer("play")
	elif step == 25:
		_save_screenshot("res://screenshot_verified_play_drawer.png")
	elif step == 30:
		# Mở Drawer Học Kỹ Năng
		var bottom_menu = main_instance.get_node("BottomPawMenu")
		bottom_menu._toggle_drawer("learn")
	elif step == 35:
		_save_screenshot("res://screenshot_verified_learn_drawer.png")
	elif step == 40:
		# Mở Drawer Cẩm Nang
		var bottom_menu = main_instance.get_node("BottomPawMenu")
		bottom_menu._toggle_drawer("handbook")
	elif step == 45:
		_save_screenshot("res://screenshot_verified_handbook_drawer.png")
	elif step == 50:
		# Mở Modal AvatarPickerModal (Thay Skin & Khung)
		var bottom_menu = main_instance.get_node("BottomPawMenu")
		bottom_menu.close_drawer()
		var avatar_modal = main_instance.get_node("AvatarPickerModal")
		avatar_modal.open()
	elif step == 55:
		_save_screenshot("res://screenshot_verified_avatar_modal.png")
	elif step == 60:
		# Mở PauseModal để kiểm tra thanh slider phẳng tròn sạch đẹp
		var avatar_modal = main_instance.get_node("AvatarPickerModal")
		avatar_modal.close()
		var pause_modal = main_instance.get_node("PauseModal")
		pause_modal.open()
		var sfx_slider = pause_modal.get_node("Panel/VBox/SFXBox/HBox/SliderSFX")
		sfx_slider.value = 0.0
	elif step == 65:
		_save_screenshot("res://screenshot_verified_slider_clean.png")
		print("=== COMPLETED ALL SCREENSHOTS ===")
		quit()

func _save_screenshot(path: String) -> void:
	var img = root.get_texture().get_image()
	if img:
		img.save_png(path)
		print("Successfully saved: ", path)
	else:
		print("Failed to capture image for: ", path)
