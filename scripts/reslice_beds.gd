extends SceneTree

func _init() -> void:
	var path = "assets/furnitures/PetMobileGameAsset/PetMobileGameAsset/Furnitures,Playgrounds,Toys.png"
	var img = Image.load_from_file(path)
	var out_dir = "assets/sprites/room_items/mobile/"
	
	_save_trimmed(img, Rect2i(0, 545, 115, 80), out_dir + "bed_mobile_blue.png")
	_save_trimmed(img, Rect2i(120, 545, 115, 80), out_dir + "bed_mobile_dark.png")
	_save_trimmed(img, Rect2i(0, 630, 115, 80), out_dir + "bed_mobile_pink.png")
	_save_trimmed(img, Rect2i(120, 630, 115, 80), out_dir + "bed_mobile_green.png")
	_save_trimmed(img, Rect2i(0, 715, 115, 80), out_dir + "bed_mobile_purple.png")
	_save_trimmed(img, Rect2i(120, 715, 115, 80), out_dir + "bed_mobile_teal.png")
	
	print("BEDS RESLICED PERFECTLY!")
	quit(0)

func _save_trimmed(src: Image, rect: Rect2i, out_path: String) -> void:
	var sub = src.get_region(rect)
	var trim = _trim(sub)
	if trim.size.x > 0 and trim.size.y > 0:
		sub.get_region(trim).save_png(out_path)
		print("  -> %s (%dx%d)" % [out_path.get_file(), trim.size.x, trim.size.y])
	else:
		sub.save_png(out_path)

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
