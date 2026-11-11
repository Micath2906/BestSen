extends SceneTree

# Slices mobile models from PetMobileGameAsset/Furnitures,Playgrounds,Toys.png
func _init() -> void:
	var path = "assets/furnitures/PetMobileGameAsset/PetMobileGameAsset/Furnitures,Playgrounds,Toys.png"
	var img = Image.load_from_file(path)
	var out_dir = "assets/sprites/room_items/mobile/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	
	print("--- SLICING PET MOBILE GAME FURNITURES ---")
	
	# 1. Cat Beds (Oval & Square plush beds from PetMobileGameAsset)
	# Beds around y=440..660, x=0..240
	_save_trimmed(img, Rect2i(2, 452, 110, 80), out_dir + "bed_mobile_blue.png")
	_save_trimmed(img, Rect2i(120, 452, 110, 80), out_dir + "bed_mobile_dark.png")
	_save_trimmed(img, Rect2i(2, 538, 110, 80), out_dir + "bed_mobile_pink.png")
	_save_trimmed(img, Rect2i(120, 538, 110, 80), out_dir + "bed_mobile_green.png")
	
	# 2. Cat Scratch Trees & Perches (x=500..800, y=150..350)
	_save_trimmed(img, Rect2i(525, 245, 68, 105), out_dir + "scratch_tree_mobile_tan.png")
	_save_trimmed(img, Rect2i(615, 245, 68, 105), out_dir + "scratch_tree_mobile_green.png")
	_save_trimmed(img, Rect2i(710, 245, 68, 105), out_dir + "scratch_tree_mobile_blue.png")
	
	# 3. Simple Bowls (from BowlSprites.png in PetMobileGameAsset)
	var bowls_path = "assets/furnitures/PetMobileGameAsset/PetMobileGameAsset/BowlSprites.png"
	if FileAccess.file_exists(bowls_path):
		var b_img = Image.load_from_file(bowls_path)
		# Blue food bowl with kibble
		_save_trimmed(b_img, Rect2i(10, 15, 45, 36), out_dir + "bowl_mobile_blue_food.png")
		# Green water bowl
		_save_trimmed(b_img, Rect2i(70, 75, 45, 36), out_dir + "bowl_mobile_green_water.png")
		# Dual pair: combine them side by side
		var dual = Image.create(85, 38, false, Image.FORMAT_RGBA8)
		var b1 = b_img.get_region(Rect2i(10, 15, 40, 36))
		var b2 = b_img.get_region(Rect2i(70, 75, 40, 36))
		dual.blit_rect(b1, Rect2i(0, 0, 40, 36), Vector2i(0, 0))
		dual.blit_rect(b2, Rect2i(0, 0, 40, 36), Vector2i(42, 0))
		dual.save_png(out_dir + "bowl_mobile_dual.png")
		print("  -> Saved bowl_mobile_dual.png")
		
	# 4. Cardboard Box / Carrier from PetMobileGameAsset (x=740..980, y=615..710)
	_save_trimmed(img, Rect2i(745, 615, 55, 50), out_dir + "carrier_mobile_brown.png")
	_save_trimmed(img, Rect2i(810, 615, 55, 50), out_dir + "carrier_mobile_purple.png")
	
	# 5. Plants from PetMobileGameAsset (x=800..950, y=260..430)
	_save_trimmed(img, Rect2i(810, 260, 32, 55), out_dir + "plant_mobile_tall.png")
	_save_trimmed(img, Rect2i(840, 260, 32, 55), out_dir + "plant_mobile_pot.png")
	_save_trimmed(img, Rect2i(810, 370, 32, 55), out_dir + "plant_mobile_monstera.png")
	
	# 6. Windows from PetMobileGameAsset (x=505..870, y=5..160)
	_save_trimmed(img, Rect2i(508, 10, 70, 68), out_dir + "window_mobile_blue_curtains.png")
	_save_trimmed(img, Rect2i(602, 10, 70, 68), out_dir + "window_mobile_yellow_curtains.png")
	
	print("ALL PET MOBILE GAME FURNITURES SLICED!")
	quit(0)

func _save_trimmed(src: Image, rect: Rect2i, out_path: String) -> void:
	var sub = src.get_region(rect)
	var trim = _trim(sub)
	if trim.size.x > 0 and trim.size.y > 0:
		sub.get_region(trim).save_png(out_path)
		print("  -> %s (%dx%d)" % [out_path.get_file(), trim.size.x, trim.size.y])
	else:
		sub.save_png(out_path)
		print("  -> %s untrimmed" % out_path.get_file())

func _trim(img: Image) -> Rect2i:
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
