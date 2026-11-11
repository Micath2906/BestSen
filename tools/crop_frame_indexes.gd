extends SceneTree

func _init() -> void:
	var path_idx = "res://assets/Free pack/Free pack/Frame indexes.png"
	var img = Image.load_from_file(path_idx)
	if img:
		var crop1 = Image.create(352, 320, false, Image.FORMAT_RGBA8)
		crop1.blit_rect(img, Rect2i(0, 0, 352, 320), Vector2i(0, 0))
		crop1.save_png("res://tests/debug_frame_indexes_1.png")
		print("Saved debug_frame_indexes_1.png")
	quit()
