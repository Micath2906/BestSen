extends SceneTree

func _init() -> void:
	var path_list = "res://assets/Free pack/Free pack/cat 16x16 animation list.png"
	var img = Image.load_from_file(path_list)
	var crop1 = Image.create(432, 160, false, Image.FORMAT_RGBA8)
	crop1.blit_rect(img, Rect2i(0, 0, 432, 160), Vector2i(0, 0))
	crop1.save_png("res://tests/debug_top_rows.png")
	print("Saved debug_top_rows.png")
	quit()
