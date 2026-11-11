extends SceneTree

func _init():
	var packed = load("res://scenes/MainMenu.tscn")
	var node = packed.instantiate()
	root.add_child(node)
	
	# Mở SettingModal
	var modal = node.get_node("SettingModal")
	modal.visible = true
	var sfx_slider = node.get_node("SettingModal/Panel/VBox/SFXBox/HBox/SliderSFX")
	var bgm_slider = node.get_node("SettingModal/Panel/VBox/BGMBox/HBox/SliderBGM")
	sfx_slider.value = 0.0
	bgm_slider.value = 80.0
	
	for i in range(3):
		await process_frame
		
	var img = root.get_texture().get_image()
	img.save_png("res://screenshot_settings_slider_fixed.png")
	print("Saved screenshot_settings_slider_fixed.png")
	quit()
