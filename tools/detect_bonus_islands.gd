extends SceneTree

func _init() -> void:
	var path = "assets/cats/CatMegaBundle/CatMegaBundle/CatUserInterface/BONUSPastelUI.png"
	var img = Image.load_from_file(path)
	var w = img.get_width()
	var h = img.get_height()
	
	var visited = []
	visited.resize(w * h)
	visited.fill(false)
	var components = []
	
	for y in range(h):
		for x in range(w):
			var idx = y * w + x
			if visited[idx]: continue
			visited[idx] = true
			if img.get_pixel(x, y).a < 0.05: continue
			
			var min_x = x
			var max_x = x
			var min_y = y
			var max_y = y
			var queue = [Vector2i(x, y)]
			
			while queue.size() > 0:
				var p = queue.pop_back()
				if p.x < min_x: min_x = p.x
				if p.x > max_x: max_x = p.x
				if p.y < min_y: min_y = p.y
				if p.y > max_y: max_y = p.y
				
				for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
					var nx = p.x + dir.x
					var ny = p.y + dir.y
					if nx >= 0 and nx < w and ny >= 0 and ny < h:
						var nidx = ny * w + nx
						if not visited[nidx]:
							visited[nidx] = true
							if img.get_pixel(nx, ny).a >= 0.05:
								queue.push_back(Vector2i(nx, ny))
			var rect = Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
			if rect.size.x >= 24 and rect.size.y >= 16:
				components.append(rect)
	print("Found %d components in BONUSPastelUI.png >= 24x16:" % components.size())
	for c in components:
		if c.size.x >= 40 or c.size.y >= 30:
			print("  Comp at (%d, %d), size (%d, %d)" % [c.position.x, c.position.y, c.size.x, c.size.y])
	quit()
