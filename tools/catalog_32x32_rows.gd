extends SceneTree

func _init() -> void:
	var path_cat1 = "res://assets/Free pack/Free pack/cat 1.png"
	var img = Image.load_from_file(path_cat1)
	
	print("--- CATALOGING 53 ROWS (32x32) IN CAT 1.PNG ---")
	for r in range(53):
		var active_cols = 0
		for c in range(11):
			var has_px = false
			for x in range(32):
				for y in range(32):
					if img.get_pixel(c * 32 + x, r * 32 + y).a > 0.05:
						has_px = true
						break
				if has_px: break
			if has_px: active_cols += 1
		print("Row %2d (y=%4d): %2d frames" % [r, r * 32, active_cols])
	quit()
