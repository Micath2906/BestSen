extends SceneTree

func _init() -> void:
	var path_list = "res://assets/Free pack/Free pack/cat 16x16 animation list.png"
	var img = Image.load_from_file(path_list)
	var w = img.get_width()
	var h = img.get_height()
	print("Image size:", w, "x", h)
	
	# Check column occupancy
	var col_has_pixels = []
	for x in range(w):
		var has_px = false
		for y in range(h):
			if img.get_pixel(x, y).a > 0.1:
				has_px = true
				break
		if has_px:
			col_has_pixels.append(x)
			
	print("Columns with pixels: min=", col_has_pixels[0], " max=", col_has_pixels[col_has_pixels.size() - 1])
	
	# Check row occupancy
	var rows_info = []
	for y in range(0, h, 16):
		var count = 0
		for x in range(w):
			for dy in range(16):
				if y + dy < h and img.get_pixel(x, y + dy).a > 0.1:
					count += 1
		if count > 0:
			rows_info.append(y / 16)
			
	print("Total active 16x16 rows:", rows_info.size(), "out of", h / 16)
	print("Active rows sample (first 30):", rows_info.slice(0, 30))
	quit()
