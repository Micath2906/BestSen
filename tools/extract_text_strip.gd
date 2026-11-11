extends SceneTree

func _init() -> void:
	var path_list = "res://assets/Free pack/Free pack/cat 16x16 animation list.png"
	var img_list = Image.load_from_file(path_list)
	if img_list:
		var text_strip = Image.create(80, 1696, false, Image.FORMAT_RGBA8)
		text_strip.blit_rect(img_list, Rect2i(352, 0, 80, 1696), Vector2i(0, 0))
		text_strip.save_png("res://tests/animation_text_strip.png")
		print("Saved animation_text_strip.png")
	quit()
