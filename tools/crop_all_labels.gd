extends SceneTree

func _init() -> void:
	var path_list = "res://assets/Free pack/Free pack/cat 16x16 animation list.png"
	var img = Image.load_from_file(path_list)
	
	# Crop left 100 pixels in 4 vertical chunks of 424 pixels each
	for i in range(4):
		var y_start = i * 424
		var chunk = Image.create(100, 424, false, Image.FORMAT_RGBA8)
		chunk.blit_rect(img, Rect2i(0, y_start, 100, 424), Vector2i(0, 0))
		chunk.save_png("res://tests/labels_chunk_%d.png" % i)
		print("Saved labels_chunk_%d.png" % i)
	quit()
