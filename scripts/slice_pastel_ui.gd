@tool
extends SceneTree

func _init() -> void:
	print("\n--- SLICING BONUSPastelUI.png ---")
	_slice_sheet("res://assets/cats/CatMegaBundle/CatMegaBundle/CatUserInterface/BONUSPastelUI.png", "res://assets/sprites/pastel_ui_slices/")
	quit()

func _slice_sheet(src_path: String, out_dir_res: String) -> void:
	var img = Image.new()
	var err = img.load(ProjectSettings.globalize_path(src_path))
	if err != OK:
		print("Error loading:", src_path)
		return
		
	var out_dir_abs = ProjectSettings.globalize_path(out_dir_res)
	DirAccess.make_dir_recursive_absolute(out_dir_abs)
	
	var w = img.get_width()
	var h = img.get_height()
	var visited = []
	for y in range(h):
		var row = []
		row.resize(w)
		row.fill(false)
		visited.append(row)
		
	var count = 0
	for y in range(0, h, 2):
		for x in range(0, w, 2):
			if not visited[y][x] and img.get_pixel(x, y).a > 0.05:
				var min_x = x
				var max_x = x
				var min_y = y
				var max_y = y
				
				var queue = [Vector2i(x, y)]
				visited[y][x] = true
				
				while not queue.is_empty():
					var pt = queue.pop_back()
					var px = pt.x
					var py = pt.y
					
					min_x = mini(min_x, px)
					max_x = maxi(max_x, px)
					min_y = mini(min_y, py)
					max_y = maxi(max_y, py)
					
					var neighbors = [
						Vector2i(px + 1, py), Vector2i(px - 1, py),
						Vector2i(px, py + 1), Vector2i(px, py - 1),
						Vector2i(px + 2, py), Vector2i(px - 2, py),
						Vector2i(px, py + 2), Vector2i(px, py - 2)
					]
					for nb in neighbors:
						if nb.x >= 0 and nb.x < w and nb.y >= 0 and nb.y < h:
							if not visited[nb.y][nb.x]:
								visited[nb.y][nb.x] = true
								if img.get_pixel(nb.x, nb.y).a > 0.05:
									queue.push_back(nb)
									
				var bw = max_x - min_x + 1
				var bh = max_y - min_y + 1
				if bw >= 12 and bh >= 12:
					var sub_img = Image.create(bw, bh, false, Image.FORMAT_RGBA8)
					sub_img.blit_rect(img, Rect2i(min_x, min_y, bw, bh), Vector2i.ZERO)
					var filename = "pastel_%d_%dx%d_at_%d_%d.png" % [count, bw, bh, min_x, min_y]
					sub_img.save_png(out_dir_abs + "/" + filename)
					count += 1
					if count <= 25:
						print("Pastel Slice %d: %dx%d at (%d, %d)" % [count, bw, bh, min_x, min_y])
						
	print("Total Pastel slices extracted:", count)
