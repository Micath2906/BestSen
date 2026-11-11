extends Control

var step = 0
var main_instance: Node = null

func _ready():
	var packed = load("res://scenes/Main.tscn")
	main_instance = packed.instantiate()
	add_child(main_instance)

func _process(_delta):
	step += 1
	if step == 10:
		_save_screenshot("res://screenshot_verified_room_minimal_and_shop.png")
	elif step == 15:
		var bottom_menu = main_instance.get_node("BottomPawMenu")
		bottom_menu._toggle_drawer("food")
	elif step == 35:
		_save_screenshot("res://screenshot_verified_food_drawer.png")
	elif step == 40:
		var bottom_menu = main_instance.get_node("BottomPawMenu")
		bottom_menu._toggle_drawer("play")
	elif step == 60:
		_save_screenshot("res://screenshot_verified_play_drawer.png")
	elif step == 65:
		var bottom_menu = main_instance.get_node("BottomPawMenu")
		bottom_menu._toggle_drawer("learn")
	elif step == 85:
		_save_screenshot("res://screenshot_verified_learn_drawer.png")
	elif step == 90:
		var bottom_menu = main_instance.get_node("BottomPawMenu")
		bottom_menu._toggle_drawer("handbook")
	elif step == 110:
		_save_screenshot("res://screenshot_verified_handbook_drawer.png")
	elif step == 115:
		var bottom_menu = main_instance.get_node("BottomPawMenu")
		bottom_menu.close_drawer()
		bottom_menu.sub_drawer.visible = false
	elif step == 125:
		var avatar_modal = main_instance.get_node("AvatarPickerModal")
		avatar_modal.open()
	elif step == 145:
		_save_screenshot("res://screenshot_verified_avatar_modal.png")
	elif step == 150:
		var avatar_modal = main_instance.get_node("AvatarPickerModal")
		avatar_modal.close()
		avatar_modal.visible = false
	elif step == 160:
		var pause_modal = main_instance.get_node("PauseModal")
		pause_modal.open()
		var sfx_slider = pause_modal.get_node("Panel/VBox/SFXBox/HBox/SliderSFX")
		sfx_slider.value = 0.0
	elif step == 180:
		_save_screenshot("res://screenshot_verified_slider_clean.png")
	elif step == 185:
		var pause_modal = main_instance.get_node("PauseModal")
		pause_modal.close()
		pause_modal.visible = false
	elif step == 195:
		var status_alert = main_instance.get_node("StatusAlertModal")
		status_alert.open("too_full")
	elif step == 215:
		_save_screenshot("res://screenshot_verified_status_alert_modal.png")
	elif step == 220:
		var status_alert = main_instance.get_node("StatusAlertModal")
		status_alert.close()
		status_alert.visible = false
		main_instance.start_lesson(1)
	elif step == 250:
		_save_screenshot("res://screenshot_verified_lesson_view.png")
		print("=== COMPLETED ALL SCREENSHOTS SUCCESSFULLY ===")
		get_tree().quit()

func _save_screenshot(path: String) -> void:
	var img = get_viewport().get_texture().get_image()
	if img:
		img.save_png(path)
		print("Successfully saved: ", path)
	else:
		print("Failed to capture: ", path)
