extends SceneTree

func _init():
	print("--- GENERATING LITTER BOX SPRITE ---")
	var w = 64
	var h = 42
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	# Colors
	var c_outline = Color("38281e")       # Dark brown outline
	var c_rim = Color("68b0c8")           # Pastel teal/sky rim
	var c_rim_hi = Color("92d2e6")        # Rim highlight
	var c_rim_shadow = Color("48889e")    # Rim shadow
	var c_tray_front = Color("589cb2")    # Front outer wall
	var c_tray_shadow = Color("3c7284")   # Base shadow
	var c_sand_base = Color("e8d8be")     # Sand base
	var c_sand_hi = Color("f6ecd8")       # Sand highlight
	var c_sand_grain = Color("d4be9e")    # Sand grain shadow
	var c_scoop = Color("e8845c")         # Coral/orange scoop
	var c_scoop_hi = Color("ffa882")      # Scoop highlight
	
	# Isometric tray dimensions
	var cx = 32
	var cy = 20
	var rx = 28.0
	var ry = 14.0
	var depth = 14
	
	# 1. Front and side walls (extrude down from cy to cy + depth)
	for y in range(cy, cy + depth + 1):
		for x in range(cx - int(rx), cx + int(rx) + 1):
			var dx = (x - cx) / rx
			var dy = (y - depth - cy) / ry
			# Bottom ellipse or top ellipse
			var d_top = dx * dx + dy * dy
			var dy_bot = (y - cy) / ry
			var d_bot = dx * dx + dy_bot * dy_bot
			if d_bot <= 1.0 or (d_top <= 1.0 and y <= cy + depth):
				if y >= cy:
					# Outer wall pixel
					var col = c_tray_front
					if y > cy + depth - 3:
						col = c_tray_shadow
					elif dx > 0.4:
						col = c_tray_shadow
					elif dx < -0.4:
						col = c_rim_hi
					img.set_pixel(x, y, col)
	
	# 2. Outer rim ellipse
	for y in range(cy - int(ry), cy + int(ry) + 1):
		for x in range(cx - int(rx), cx + int(rx) + 1):
			var dx = (x - cx) / rx
			var dy = (y - cy) / ry
			var dist = dx * dx + dy * dy
			if dist <= 1.0:
				var rim_col = c_rim
				if dy < -0.3:
					rim_col = c_rim_hi
				elif dy > 0.3:
					rim_col = c_rim_shadow
				img.set_pixel(x, y, rim_col)
	
	# 3. Inner sand bed (smaller ellipse offset down slightly)
	var in_rx = 23.0
	var in_ry = 10.5
	var in_cy = cy + 2
	for y in range(in_cy - int(in_ry), in_cy + int(in_ry) + 1):
		for x in range(cx - int(in_rx), cx + int(in_rx) + 1):
			var dx = (x - cx) / in_rx
			var dy = (y - in_cy) / in_ry
			var dist = dx * dx + dy * dy
			if dist <= 1.0:
				var sand_col = c_sand_base
				# Grains pattern
				if (x * 7 + y * 13) % 5 == 0:
					sand_col = c_sand_grain
				elif (x * 11 + y * 3) % 7 == 0:
					sand_col = c_sand_hi
				if dy < -0.4:
					sand_col = c_sand_grain.lerp(c_rim_shadow, 0.35) # Inner rim shadow
				img.set_pixel(x, y, sand_col)
	
	# 4. Small scoop (xẻng xúc cát) resting on the right side
	# Scoop handle
	var scoop_pts = [
		Vector2i(48, 12), Vector2i(49, 11), Vector2i(50, 10), Vector2i(51, 9), Vector2i(52, 8),
		Vector2i(49, 12), Vector2i(50, 11), Vector2i(51, 10), Vector2i(52, 9), Vector2i(53, 8)
	]
	for p in scoop_pts:
		img.set_pixel(p.x, p.y, c_scoop_hi)
	# Scoop head (spade)
	for sx in range(43, 49):
		for sy in range(12, 17):
			var d_sc = abs(sx - 46) + abs(sy - 14)
			if d_sc <= 4:
				img.set_pixel(sx, sy, c_scoop)
	# Scoop slots
	img.set_pixel(45, 14, c_outline)
	img.set_pixel(47, 14, c_outline)
	
	# 5. Paw print on front of the tray
	var paw_col = Color("f6ecd8")
	img.set_pixel(32, 28, paw_col)
	img.set_pixel(31, 28, paw_col)
	img.set_pixel(33, 28, paw_col)
	img.set_pixel(32, 29, paw_col)
	# Toes
	img.set_pixel(30, 26, paw_col)
	img.set_pixel(32, 25, paw_col)
	img.set_pixel(34, 26, paw_col)
	
	# 6. Outline trace
	var outlined = Image.create(w, h, false, Image.FORMAT_RGBA8)
	outlined.fill(Color(0, 0, 0, 0))
	for y in range(h):
		for x in range(w):
			var cur = img.get_pixel(x, y)
			if cur.a > 0.05:
				outlined.set_pixel(x, y, cur)
			else:
				# Check 4 neighbors
				var has_solid = false
				for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
					var nx = x + offset.x
					var ny = y + offset.y
					if nx >= 0 and nx < w and ny >= 0 and ny < h:
						if img.get_pixel(nx, ny).a > 0.05:
							has_solid = true
							break
				if has_solid:
					outlined.set_pixel(x, y, c_outline)
	
	var save_path = "res://assets/sprites/room_items/litter_box.png"
	var err = outlined.save_png(ProjectSettings.globalize_path(save_path))
	print("Saved litter box to ", save_path, " -> code ", err)
	quit()
