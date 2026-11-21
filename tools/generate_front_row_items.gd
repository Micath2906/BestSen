@tool
extends SceneTree

# Generates clean, crisp front-row pixel art items for the cozy room
func _init() -> void:
	print("--- GENERATING FRONT-ROW CAT ITEMS ---")
	_generate_bowls()
	_generate_cushion_bed()
	_generate_litter_box()
	_generate_shoe_mat()
	quit(0)

func _generate_bowls() -> void:
	# Empty Food Bowl (36x22)
	var img_empty = Image.create(36, 22, false, Image.FORMAT_RGBA8)
	var img_full = Image.create(36, 22, false, Image.FORMAT_RGBA8)
	var img_water = Image.create(36, 22, false, Image.FORMAT_RGBA8)
	
	var col_shadow = Color(0.15, 0.1, 0.08, 0.25)
	var col_rim = Color.from_string("#E5D2BA", Color.WHITE)
	var col_ceramic_hi = Color.from_string("#E08B5B", Color.WHITE)
	var col_ceramic = Color.from_string("#C66938", Color.WHITE)
	var col_ceramic_dark = Color.from_string("#96461D", Color.WHITE)
	var col_inner_empty = Color.from_string("#3D2314", Color.WHITE)
	var col_inner_bowl = Color.from_string("#5C3620", Color.WHITE)
	
	var col_kibble_1 = Color.from_string("#96572A", Color.WHITE)
	var col_kibble_2 = Color.from_string("#C47D42", Color.WHITE)
	var col_kibble_hi = Color.from_string("#E5A66E", Color.WHITE)
	
	var col_water_deep = Color.from_string("#2B7A9C", Color.WHITE)
	var col_water_mid = Color.from_string("#4DB3DB", Color.WHITE)
	var col_water_hi = Color.from_string("#B8EAF8", Color.WHITE)
	
	for img in [img_empty, img_full, img_water]:
		# Shadow
		_fill_ellipse(img, Vector2(18, 17), 16, 5, col_shadow)
		# Outer ceramic body
		_fill_ellipse(img, Vector2(18, 13), 15, 8, col_ceramic_dark)
		_fill_ellipse(img, Vector2(18, 11), 15, 8, col_ceramic)
		_fill_ellipse(img, Vector2(18, 9), 14, 7, col_ceramic_hi)
		# Top rim
		_fill_ellipse(img, Vector2(18, 7), 14, 6, col_rim)
		_fill_ellipse(img, Vector2(18, 8), 12, 5, col_inner_bowl)
		
	# Empty: dark interior
	_fill_ellipse(img_empty, Vector2(18, 9), 11, 4, col_inner_empty)
	
	# Full: pile of crunchy kibble
	_fill_ellipse(img_full, Vector2(18, 8), 11, 4, col_kibble_1)
	for py in range(5, 9):
		for px in range(10, 27):
			if (px + py * 3) % 4 == 0:
				img_full.set_pixel(px, py, col_kibble_2)
			elif (px + py * 2) % 5 == 0:
				img_full.set_pixel(px, py, col_kibble_hi)
				
	# Water: sparkling clean water
	_fill_ellipse(img_water, Vector2(18, 8), 11, 4, col_water_deep)
	_fill_ellipse(img_water, Vector2(18, 8), 9, 3, col_water_mid)
	# Highlights
	img_water.set_pixel(13, 7, col_water_hi)
	img_water.set_pixel(14, 7, col_water_hi)
	img_water.set_pixel(15, 7, col_water_hi)
	img_water.set_pixel(22, 9, col_water_hi)
	img_water.set_pixel(23, 9, col_water_hi)

	_save_both(img_empty, "furniture_cat_bowl_empty.png")
	_save_both(img_full, "furniture_cat_bowl_full.png")
	_save_both(img_water, "furniture_cat_water_bowl.png")

func _generate_cushion_bed() -> void:
	# Cozy Donut Cat Bed (100x65)
	var img = Image.create(100, 65, false, Image.FORMAT_RGBA8)
	var col_shadow = Color(0.15, 0.1, 0.08, 0.22)
	_fill_ellipse(img, Vector2(50, 48), 46, 16, col_shadow)
	
	var col_plush_dark = Color.from_string("#9B5C35", Color.WHITE)
	var col_plush_mid = Color.from_string("#C88152", Color.WHITE)
	var col_plush_light = Color.from_string("#E5A77B", Color.WHITE)
	var col_inner_dark = Color.from_string("#E2D4C0", Color.WHITE)
	var col_inner_light = Color.from_string("#FFF8ED", Color.WHITE)
	var col_paw = Color.from_string("#D97706", Color.WHITE)
	
	# Outer rim
	_fill_ellipse(img, Vector2(50, 40), 44, 20, col_plush_dark)
	_fill_ellipse(img, Vector2(50, 36), 44, 19, col_plush_mid)
	_fill_ellipse(img, Vector2(50, 32), 43, 18, col_plush_light)
	
	# Fluffy inner cushion
	_fill_ellipse(img, Vector2(50, 33), 32, 14, col_inner_dark)
	_fill_ellipse(img, Vector2(50, 31), 30, 13, col_inner_light)
	
	# Cute little paw embroidery on front edge
	img.set_pixel(50, 46, col_paw)
	img.set_pixel(49, 47, col_paw)
	img.set_pixel(51, 47, col_paw)
	img.set_pixel(48, 44, col_paw)
	img.set_pixel(52, 44, col_paw)
	img.set_pixel(50, 43, col_paw)
	
	_save_both(img, "furniture_cushion_bed.png")

func _generate_litter_box() -> void:
	# Modern pastel litter box (80x50)
	var img = Image.create(80, 50, false, Image.FORMAT_RGBA8)
	var col_shadow = Color(0.15, 0.1, 0.08, 0.22)
	_fill_ellipse(img, Vector2(40, 38), 36, 11, col_shadow)
	
	var col_tray_dark = Color.from_string("#3D7A6E", Color.WHITE)
	var col_tray_mid = Color.from_string("#52A394", Color.WHITE)
	var col_tray_hi = Color.from_string("#72C4B5", Color.WHITE)
	var col_tray_rim = Color.from_string("#E8F6F4", Color.WHITE)
	var col_sand_dark = Color.from_string("#D8CEBF", Color.WHITE)
	var col_sand_mid = Color.from_string("#EDE5D8", Color.WHITE)
	var col_sand_hi = Color.from_string("#FAF7F2", Color.WHITE)
	
	_fill_ellipse(img, Vector2(40, 30), 34, 15, col_tray_dark)
	_fill_ellipse(img, Vector2(40, 27), 34, 15, col_tray_mid)
	_fill_ellipse(img, Vector2(40, 24), 33, 14, col_tray_hi)
	_fill_ellipse(img, Vector2(40, 22), 33, 13, col_tray_rim)
	
	# Sand basin
	_fill_ellipse(img, Vector2(40, 24), 28, 10, col_sand_dark)
	_fill_ellipse(img, Vector2(40, 23), 26, 9, col_sand_mid)
	# Sand granules
	for py in range(18, 28):
		for px in range(18, 62):
			if (px * 7 + py * 11) % 6 == 0 and img.get_pixel(px, py).a > 0.5:
				img.set_pixel(px, py, col_sand_hi)
				
	# Cute little scoop hanging on right rim
	var col_scoop = Color.from_string("#F59E0B", Color.WHITE)
	for y in range(12, 26):
		img.set_pixel(66, y, col_scoop)
	img.set_pixel(65, 23, col_scoop)
	img.set_pixel(67, 23, col_scoop)
	img.set_pixel(65, 24, col_scoop)
	img.set_pixel(67, 24, col_scoop)
	
	_save_both(img, "furniture_litter_box.png")

func _generate_shoe_mat() -> void:
	# Neat entrance coir mat with house slippers (64x32)
	var img = Image.create(64, 32, false, Image.FORMAT_RGBA8)
	var col_shadow = Color(0.15, 0.1, 0.08, 0.2)
	_fill_ellipse(img, Vector2(32, 22), 28, 9, col_shadow)
	
	var col_mat_dark = Color.from_string("#8D6E4A", Color.WHITE)
	var col_mat_mid = Color.from_string("#B8956A", Color.WHITE)
	var col_mat_border = Color.from_string("#664D31", Color.WHITE)
	
	_fill_ellipse(img, Vector2(32, 17), 26, 8, col_mat_border)
	_fill_ellipse(img, Vector2(32, 16), 24, 7, col_mat_dark)
	_fill_ellipse(img, Vector2(32, 15), 23, 6, col_mat_mid)
	
	# Pair of cute student slippers parked neatly (X=23 and X=41)
	var col_slip_sole = Color.from_string("#5A361C", Color.WHITE)
	var col_slip_cloth = Color.from_string("#D97706", Color.WHITE)
	var col_slip_hi = Color.from_string("#FDE68A", Color.WHITE)
	
	for sx in [22, 38]:
		_fill_ellipse(img, Vector2(sx, 16), 5, 8, col_slip_sole)
		_fill_ellipse(img, Vector2(sx, 14), 5, 7, col_slip_cloth)
		_fill_ellipse(img, Vector2(sx, 12), 4, 4, col_slip_hi)
		
	_save_both(img, "furniture_shoe_mat.png")

func _fill_ellipse(img: Image, center: Vector2, rx: float, ry: float, col: Color) -> void:
	var x0 = maxi(0, int(center.x - rx - 1))
	var x1 = mini(img.get_width() - 1, int(center.x + rx + 1))
	var y0 = maxi(0, int(center.y - ry - 1))
	var y1 = mini(img.get_height() - 1, int(center.y + ry + 1))
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			var dx = (float(x) - center.x) / rx
			var dy = (float(y) - center.y) / ry
			if dx * dx + dy * dy <= 1.0:
				if col.a < 1.0:
					var old = img.get_pixel(x, y)
					img.set_pixel(x, y, old.blend(col))
				else:
					img.set_pixel(x, y, col)

func _save_both(img: Image, filename: String) -> void:
	var p1 = "D:/BestSen/assets/sprites/room_decor/" + filename
	var p2 = "assets/sprites/room_decor/" + filename
	img.save_png(p1)
	img.save_png(p2)
	print("Saved: ", filename)
