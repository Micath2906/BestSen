extends SceneTree

func _init() -> void:
	var path_cat1 = "res://assets/Free pack/Free pack/cat 1.png"
	var img = Image.load_from_file(path_cat1)
	
	# Let's crop 4 frames of walk down (Row 4) at 32x32:
	var test_walk = Image.create(32 * 4, 32, false, Image.FORMAT_RGBA8)
	for i in range(4):
		test_walk.blit_rect(img, Rect2i(i * 32, 4 * 32, 32, 32), Vector2i(i * 32, 0))
	test_walk.save_png("res://tests/test_32x32_walk_down.png")
	
	# Crop Row 9 (walk right down - isometric) 6 frames:
	var test_iso_walk = Image.create(32 * 6, 32, false, Image.FORMAT_RGBA8)
	for i in range(6):
		test_iso_walk.blit_rect(img, Rect2i(i * 32, 9 * 32, 32, 32), Vector2i(i * 32, 0))
	test_iso_walk.save_png("res://tests/test_32x32_walk_iso_down_right.png")
	
	# Crop Row 0 (sitting) 6 frames:
	var test_sit = Image.create(32 * 6, 32, false, Image.FORMAT_RGBA8)
	for i in range(6):
		test_sit.blit_rect(img, Rect2i(i * 32, 0, 32, 32), Vector2i(i * 32, 0))
	test_sit.save_png("res://tests/test_32x32_sit.png")
	
	print("Saved 32x32 test crops!")
	quit()
