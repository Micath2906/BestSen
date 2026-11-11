extends SceneTree

# Slices authentic isometric furniture from Catroompaid.png
func _init() -> void:
	var src_path = "assets/furnitures/CatRoomPaid/CatRoomPaid/Catroompaid.png"
	var img = Image.load_from_file(src_path)
	if not img:
		print("ERROR: Could not load Catroompaid.png")
		quit(1)
		return
		
	var out_dir = "assets/sprites/room_items/"
	
	# 1. Potted Plant (Ficus / Monstera in terracotta pot)
	# Location: around x=132..180, y=285..398
	_slice_rect(img, Rect2i(135, 290, 48, 108), out_dir + "potted_ficus_terracotta.png")
	_slice_rect(img, Rect2i(135, 410, 48, 106), out_dir + "potted_ficus_blue.png")
	
	# 2. Cat Beds (Square plush bed with indented cushion)
	# Blue Bed: x=195, y=135, w=110, h=80
	_slice_rect(img, Rect2i(196, 137, 108, 80), out_dir + "cat_bed_blue_iso.png")
	# Pink/Terracotta Bed: x=195, y=225, w=110, h=80
	_slice_rect(img, Rect2i(196, 227, 108, 80), out_dir + "cat_bed_pink_iso.png")
	# Purple Bed: x=195, y=318, w=110, h=80
	_slice_rect(img, Rect2i(196, 318, 108, 80), out_dir + "cat_bed_purple_iso.png")
	
	# 3. Scratching Tree / Perch
	# Single pole perch with scratching column: x=187, y=15, w=62, h=108
	_slice_rect(img, Rect2i(187, 15, 62, 108), out_dir + "scratch_perch_wood.png")
	# Two-tier cat gym with ladder: x=546, y=217, w=108, h=156
	_slice_rect(img, Rect2i(546, 217, 108, 156), out_dir + "cat_gym_ladder.png")
	
	# 4. Wall Decorations
	# Framed Cactus Poster: x=697, y=192, w=39, h=87
	_slice_rect(img, Rect2i(697, 192, 39, 87), out_dir + "wall_cactus_poster.png")
	# Window with blue sky: x=20, y=15, w=58, h=78
	_slice_rect(img, Rect2i(20, 15, 58, 78), out_dir + "window_sky_white.png")
	
	# 5. Food & Water Bowls (Isometric single round bowls)
	# Blue food bowl: x=259, y=431, w=45, h=35
	_slice_rect(img, Rect2i(259, 431, 45, 35), out_dir + "bowl_blue_food.png")
	# Green water bowl: x=323, y=551, w=45, h=35
	_slice_rect(img, Rect2i(323, 551, 45, 35), out_dir + "bowl_green_water.png")
	
	# Also update potted_monstera.png with the genuine potted ficus
	var ficus = Image.load_from_file(out_dir + "potted_ficus_terracotta.png")
	if ficus:
		ficus.save_png(out_dir + "potted_monstera.png")
		print("Updated potted_monstera.png with genuine isometric potted plant!")
		
	print("ALL SLICES COMPLETED SUCCESSFULLY!")
	quit(0)

func _slice_rect(src: Image, rect: Rect2i, out_path: String) -> void:
	var sub = src.get_region(rect)
	# Trim empty alpha borders
	var trim_rect = _get_used_rect(sub)
	if trim_rect.size.x > 0 and trim_rect.size.y > 0:
		var trimmed = sub.get_region(trim_rect)
		trimmed.save_png(out_path)
		print("  -> Saved %s (%dx%d)" % [out_path, trim_rect.size.x, trim_rect.size.y])
	else:
		sub.save_png(out_path)
		print("  -> Saved untrimmed %s" % out_path)

func _get_used_rect(img: Image) -> Rect2i:
	var min_x = img.get_width()
	var min_y = img.get_height()
	var max_x = -1
	var max_y = -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a > 0.05:
				if x < min_x: min_x = x
				if y < min_y: min_y = y
				if x > max_x: max_x = x
				if y > max_y: max_y = y
	if max_x < min_x or max_y < min_y:
		return Rect2i(0, 0, 0, 0)
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
