extends SceneTree

func _init() -> void:
	var path = "res://assets/CatMegaFree/CatRoomFree/Furnitures.png"
	var img = Image.load_from_file(path)
	var w = img.get_width()
	var h = img.get_height()
	print("Loaded Furnitures.png: ", w, "x", h)
	
	var visited = []
	visited.resize(w * h)
	visited.fill(false)
	
	var islands = []
	
	for y in range(h):
		for x in range(w):
			var idx = y * w + x
			if visited[idx]: continue
			visited[idx] = true
			
			if img.get_pixel(x, y).a > 0.05:
				# Flood fill to find bounding box
				var q = [Vector2i(x, y)]
				var min_x = x
				var max_x = x
				var min_y = y
				var max_y = y
				var px_count = 0
				
				while q.size() > 0:
					var p = q.pop_back()
					px_count += 1
					if p.x < min_x: min_x = p.x
					if p.x > max_x: max_x = p.x
					if p.y < min_y: min_y = p.y
					if p.y > max_y: max_y = p.y
					
					var neighbors = [
						Vector2i(p.x + 1, p.y),
						Vector2i(p.x - 1, p.y),
						Vector2i(p.x, p.y + 1),
						Vector2i(p.x, p.y - 1),
					]
					for n in neighbors:
						if n.x >= 0 and n.x < w and n.y >= 0 and n.y < h:
							var n_idx = n.y * w + n.x
							if not visited[n_idx]:
								visited[n_idx] = true
								if img.get_pixel(n.x, n.y).a > 0.05:
									q.append(n)
									
				if px_count > 60: # Only significant objects
					islands.append({
						"rect": Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1),
						"pixels": px_count
					})
					
	print("Found %d furniture items!" % islands.size())
	islands.sort_custom(func(a, b): return a.rect.position.y < b.rect.position.y)
	
	for i in range(islands.size()):
		var item = islands[i]
		var r: Rect2i = item["rect"]
		print("Item %2d: pos=(%3d, %3d), size=(%3d, %3d), pixels=%4d" % [i, r.position.x, r.position.y, r.size.x, r.size.y, item["pixels"]])
		
		# Crop and save to tests/furn_item_XX.png
		var crop = Image.create(r.size.x, r.size.y, false, Image.FORMAT_RGBA8)
		crop.blit_rect(img, r, Vector2i(0, 0))
		crop.save_png("res://tests/furn_item_%02d.png" % i)
		
	quit()
