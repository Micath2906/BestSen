extends SceneTree

func _init() -> void:
	var path_cat1 = "res://assets/Free pack/Free pack/cat 1.png"
	var img = Image.load_from_file(path_cat1)
	
	for r in range(15):
		var non_empty_cols = []
		for c in range(22):
			var has_px = false
			for x in range(32): # wait! Could a tile be 32x32?
				for y in range(32):
					if (c * 32 + x < img.get_width()) and (r * 32 + y < img.get_height()):
						if img.get_pixel(c * 32 + x, r * 32 + y).a > 0.1:
							has_px = true
							break
				if has_px:
					break
			if has_px:
				non_empty_cols.append(c)
		print("32x32 Grid - Row ", r, " active cols: ", non_empty_cols)
	quit()
