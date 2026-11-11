extends SceneTree

func _init() -> void:
	var path_dec = "assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Decorations/CatRoomDecorations.png"
	var img_dec = Image.load_from_file(path_dec)
	
	var path_furn = "assets/UI/PetMobileGameAsset/PetMobileGameAsset/Furnitures,Playgrounds,Toys.png"
	var img_furn = Image.load_from_file(path_furn)
	
	var out_dir = "assets/UI/ToffeeHUD/"
	
	# Let's see some samples from CatRoomDecorations.png:
	# Picture frames on wall:
	# Usually wall decor is at the top rows or left rows
	_save(img_dec, Rect2i(0, 0, 128, 128), out_dir + "decor_sample_1.png")
	_save(img_dec, Rect2i(128, 0, 128, 128), out_dir + "decor_sample_2.png")
	_save(img_dec, Rect2i(256, 0, 128, 128), out_dir + "decor_sample_3.png")
	_save(img_dec, Rect2i(384, 0, 128, 128), out_dir + "decor_sample_4.png")
	
	if img_furn:
		_save(img_furn, Rect2i(0, 0, 128, 128), out_dir + "furn_sample_1.png")
		_save(img_furn, Rect2i(128, 0, 128, 128), out_dir + "furn_sample_2.png")
	
	quit()

func _save(src: Image, rect: Rect2i, path: String) -> void:
	var sub = src.get_region(rect)
	sub.save_png(path)
