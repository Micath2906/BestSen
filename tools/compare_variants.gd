extends SceneTree

func _init() -> void:
	var c1 = Image.load_from_file("res://assets/Free pack/Free pack/cat 1.png")
	var c16 = Image.load_from_file("res://assets/Free pack/Free pack/cat 1.6.png")
	var c19 = Image.load_from_file("res://assets/Free pack/Free pack/cat 1.9.png")
	
	# Crop first 4 rows (64x64) of each
	var comp = Image.create(192, 64, false, Image.FORMAT_RGBA8)
	comp.blit_rect(c1, Rect2i(0, 0, 64, 64), Vector2i(0, 0))
	comp.blit_rect(c16, Rect2i(0, 0, 64, 64), Vector2i(64, 0))
	comp.blit_rect(c19, Rect2i(0, 0, 64, 64), Vector2i(128, 0))
	comp.save_png("res://tests/cat_variants_comparison.png")
	print("Saved cat_variants_comparison.png")
	quit()
