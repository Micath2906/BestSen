extends SceneTree

func _init() -> void:
	var path_idx = "res://assets/Free pack/Free pack/Frame indexes.png"
	var img = Image.load_from_file(path_idx)
	print("Frame indexes size: ", img.get_size())
	
	# Let's check non-empty tiles in the first 10 rows
	for r in range(10):
		var non_empty_cols = []
		for c in range(22):
			var has_px = false
			for x in range(16):
				for y in range(16):
					if img.get_pixel(c * 16 + x, r * 16 + y).a > 0.1:
						has_px = true
						break
				if has_px:
					break
			if has_px:
				non_empty_cols.append(c)
		print("Row ", r, " active cols: ", non_empty_cols)
	quit()
