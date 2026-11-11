extends SceneTree

func _init() -> void:
	var path_list = "res://assets/Free pack/Free pack/cat 16x16 animation list.png"
	var img = Image.load_from_file(path_list)
	var chunk = Image.create(100, 300, false, Image.FORMAT_RGBA8)
	chunk.blit_rect(img, Rect2i(0, 1396, 100, 300), Vector2i(0, 0))
	chunk.save_png("res://tests/labels_bottom_most.png")
	print("Saved labels_bottom_most.png")
	quit()
