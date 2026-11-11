extends SceneTree

func _init() -> void:
	var path_cat1 = "res://assets/Free pack/Free pack/cat 1.png"
	var img = Image.load_from_file(path_cat1)
	print("--- FRAME COUNTS PER ROW IN CAT 1.PNG ---")
	
	for row in range(106):
		var y = row * 16
		var frames = 0
		for col in range(22):
			var x = col * 16
			var has_px = false
			for dx in range(16):
				for dy in range(16):
					if img.get_pixel(x + dx, y + dy).a > 0.05:
						has_px = true
						break
				if has_px:
					break
			if has_px:
				frames += 1
		if frames > 0:
			print("Row %3d (y=%4d): %2d frames" % [row, y, frames])
			
	quit()
