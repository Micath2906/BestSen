extends SceneTree

# Slices and prepares genuine pixel wear sprites for 32x32 cats
func _init() -> void:
	var out_dir = "assets/sprites/costumes/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	
	print("--- EXTRACTING WEARABLE ASSETS FOR CATS ---")
	
	# 1. Bows & Ribbons (from CatwithRibbon)
	# CatwithRibbon has 32x32 frames. In Sitting frame (y=0, x=0..32), the ribbon is at the head
	_extract_ribbon("assets/furnitures/PetMobileGameAsset/PetMobileGameAsset/Cats/CatSprites/CatwithRibbon/CatPackRibbonRed.png", out_dir + "bow_red.png")
	_extract_ribbon("assets/furnitures/PetMobileGameAsset/PetMobileGameAsset/Cats/CatSprites/CatwithRibbon/CatPackRibbonBlue.png", out_dir + "bow_blue.png")
	_extract_ribbon("assets/furnitures/PetMobileGameAsset/PetMobileGameAsset/Cats/CatSprites/CatwithRibbon/CatPackRibbonPink.png", out_dir + "bow_pink.png")
	_extract_ribbon("assets/furnitures/PetMobileGameAsset/PetMobileGameAsset/Cats/CatSprites/CatwithRibbon/CatPackRibbonYellow.png", out_dir + "bow_yellow.png")
	
	# 2. Xmas Hats & Reindeer Antlers
	# DeerHat/PNG:
	var deer_sheet = "assets/cats/XmasCatsPaid/XmasCatsPaid/DeerHat/PNG/Sittingg.png"
	if FileAccess.file_exists(deer_sheet):
		_extract_deer_antlers(deer_sheet, out_dir + "hat_reindeer.png")
		
	var santa_sheet = "assets/cats/XmasCatsPaid/XmasCatsPaid/RedShortXmasHat/PNG/Sittingg.png"
	if FileAccess.file_exists(santa_sheet):
		_extract_santa_hat(santa_sheet, out_dir + "hat_santa.png")
		
	# 3. Witch Hat & Dracula Cape
	var witch_sheet = "assets/cats/CatPackHalloweenPAID/CatPackHalloweenPAID/witch.png"
	if FileAccess.file_exists(witch_sheet):
		_extract_witch_hat(witch_sheet, out_dir + "hat_witch.png")
		
	var dracula_sheet = "assets/cats/CatPackHalloweenPAID/CatPackHalloweenPAID/draculacats.png"
	if FileAccess.file_exists(dracula_sheet):
		_extract_dracula_cape(dracula_sheet, out_dir + "cloth_dracula_cape.png")
		
	# 4. Batman Mask
	var mask_sheet = "assets/cats/BatmanCatPaid/BatmanCatPaid/BlackMask/Sittingg.png"
	if FileAccess.file_exists(mask_sheet):
		_extract_batman_mask(mask_sheet, out_dir + "acc_batman_mask.png")
		
	# 5. Student Baseball Cap & Glasses
	_craft_student_cap(out_dir + "hat_cap_blue.png")
	_craft_smart_glasses(out_dir + "acc_glasses.png")
	_craft_student_hoodie(out_dir + "cloth_hoodie.png")
	_craft_winter_sweater(out_dir + "cloth_sweater.png")
	_craft_gold_bell_collar(out_dir + "bow_bell.png")
	
	print("ALL WEARABLE ASSETS READY!")
	quit(0)

func _extract_ribbon(sheet_path: String, out_path: String) -> void:
	if not FileAccess.file_exists(sheet_path): return
	var img = Image.load_from_file(sheet_path)
	# In frame 0 (sitting), ribbon is centered between cat ears around (11, 2) size 14x10
	var ribbon = img.get_region(Rect2i(7, 0, 18, 12))
	var trim = _trim_rect(ribbon)
	if trim.size.x > 0:
		ribbon.get_region(trim).save_png(out_path)
		print("  -> Saved Ribbon: %s" % out_path.get_file())

func _extract_deer_antlers(sheet_path: String, out_path: String) -> void:
	var img = Image.load_from_file(sheet_path)
	# Top head antlers region
	var antlers = img.get_region(Rect2i(4, 2, 24, 15))
	var trim = _trim_rect(antlers)
	if trim.size.x > 0:
		antlers.get_region(trim).save_png(out_path)
		print("  -> Saved Deer Hat: %s" % out_path.get_file())

func _extract_santa_hat(sheet_path: String, out_path: String) -> void:
	var img = Image.load_from_file(sheet_path)
	var hat = img.get_region(Rect2i(5, 1, 24, 16))
	var trim = _trim_rect(hat)
	if trim.size.x > 0:
		hat.get_region(trim).save_png(out_path)
		print("  -> Saved Santa Hat: %s" % out_path.get_file())

func _extract_witch_hat(sheet_path: String, out_path: String) -> void:
	var img = Image.load_from_file(sheet_path)
	var hat = img.get_region(Rect2i(6, 0, 22, 17))
	var trim = _trim_rect(hat)
	if trim.size.x > 0:
		hat.get_region(trim).save_png(out_path)
		print("  -> Saved Witch Hat: %s" % out_path.get_file())

func _extract_dracula_cape(sheet_path: String, out_path: String) -> void:
	var img = Image.load_from_file(sheet_path)
	var cape = img.get_region(Rect2i(5, 14, 22, 18))
	var trim = _trim_rect(cape)
	if trim.size.x > 0:
		cape.get_region(trim).save_png(out_path)
		print("  -> Saved Dracula Cape: %s" % out_path.get_file())

func _extract_batman_mask(sheet_path: String, out_path: String) -> void:
	var img = Image.load_from_file(sheet_path)
	var mask = img.get_region(Rect2i(7, 5, 18, 12))
	var trim = _trim_rect(mask)
	if trim.size.x > 0:
		mask.get_region(trim).save_png(out_path)
		print("  -> Saved Batman Mask: %s" % out_path.get_file())

func _craft_student_cap(out_path: String) -> void:
	# 18x10 pixel cap with visor
	var img = Image.create(20, 11, false, Image.FORMAT_RGBA8)
	var blue = Color("3a86ff")
	var dark_blue = Color("1e3d7a")
	var highlight = Color("80b5ff")
	# Dome of cap
	for y in range(2, 8):
		for x in range(3, 17):
			img.set_pixel(x, y, blue)
	for x in range(4, 16):
		img.set_pixel(x, 1, blue)
	for x in range(6, 14):
		img.set_pixel(x, 0, highlight)
	# Visor pointing right
	for x in range(12, 20):
		img.set_pixel(x, 7, dark_blue)
	for x in range(13, 19):
		img.set_pixel(x, 8, dark_blue)
	img.save_png(out_path)
	print("  -> Crafted: hat_cap_blue.png")

func _craft_smart_glasses(out_path: String) -> void:
	var img = Image.create(18, 8, false, Image.FORMAT_RGBA8)
	var frame_c = Color("1a1a1a")
	var glass_c = Color(0.85, 0.95, 1.0, 0.6)
	# Two square lenses
	for y in range(1, 6):
		for x in range(1, 7):
			img.set_pixel(x, y, glass_c)
		for x in range(10, 16):
			img.set_pixel(x, y, glass_c)
	# Frame borders
	for x in range(0, 8):
		img.set_pixel(x, 0, frame_c)
		img.set_pixel(x, 6, frame_c)
	for x in range(9, 17):
		img.set_pixel(x, 0, frame_c)
		img.set_pixel(x, 6, frame_c)
	for y in range(0, 7):
		img.set_pixel(0, y, frame_c)
		img.set_pixel(7, y, frame_c)
		img.set_pixel(9, y, frame_c)
		img.set_pixel(16, y, frame_c)
	# Bridge
	img.set_pixel(8, 2, frame_c)
	img.save_png(out_path)
	print("  -> Crafted: acc_glasses.png")

func _craft_student_hoodie(out_path: String) -> void:
	# 22x14 hoodie fitting cat torso
	var img = Image.create(22, 14, false, Image.FORMAT_RGBA8)
	var yellow = Color("f4a261")
	var dark_y = Color("e76f51")
	for y in range(2, 13):
		for x in range(2, 20):
			img.set_pixel(x, y, yellow)
	# Collar / strings
	img.set_pixel(10, 3, Color.WHITE)
	img.set_pixel(10, 4, Color.WHITE)
	img.set_pixel(11, 3, Color.WHITE)
	img.set_pixel(11, 5, Color.WHITE)
	# Hem border
	for x in range(2, 20):
		img.set_pixel(x, 13, dark_y)
	img.save_png(out_path)
	print("  -> Crafted: cloth_hoodie.png")

func _craft_winter_sweater(out_path: String) -> void:
	var img = Image.create(22, 14, false, Image.FORMAT_RGBA8)
	var red = Color("d90429")
	var white = Color("edf2f4")
	for y in range(2, 13):
		for x in range(2, 20):
			var c = white if (y == 5 or y == 9) else red
			img.set_pixel(x, y, c)
	img.save_png(out_path)
	print("  -> Crafted: cloth_sweater.png")

func _craft_gold_bell_collar(out_path: String) -> void:
	var img = Image.create(16, 10, false, Image.FORMAT_RGBA8)
	var red = Color("e63946")
	var gold = Color("ffb703")
	# Red collar band
	for x in range(1, 15):
		img.set_pixel(x, 2, red)
		img.set_pixel(x, 3, red)
	# Gold bell in center
	for y in range(4, 9):
		for x in range(6, 10):
			img.set_pixel(x, y, gold)
	img.set_pixel(8, 6, Color("222222"))
	img.save_png(out_path)
	print("  -> Crafted: bow_bell.png")

func _trim_rect(img: Image) -> Rect2i:
	var min_x = img.get_width()
	var min_y = img.get_height()
	var max_x = -1
	var max_y = -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a > 0.1:
				if x < min_x: min_x = x
				if y < min_y: min_y = y
				if x > max_x: max_x = x
				if y > max_y: max_y = y
	if max_x < min_x or max_y < min_y:
		return Rect2i(0, 0, 0, 0)
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
