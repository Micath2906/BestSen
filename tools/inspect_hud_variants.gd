extends SceneTree

func _init() -> void:
	var path_cat = "assets/UI/CatUIPaid/CatUIPaid/catUI.png"
	var img_cat = Image.load_from_file(path_cat)
	var out_dir = "assets/UI/ToffeeHUD/"
	
	_save(img_cat, Rect2i(82, 2, 76, 28), out_dir + "hud_variant_1.png")
	_save(img_cat, Rect2i(2, 34, 76, 28), out_dir + "hud_variant_2.png")
	_save(img_cat, Rect2i(82, 34, 76, 28), out_dir + "hud_variant_3.png")
	_save(img_cat, Rect2i(2, 66, 76, 28), out_dir + "hud_variant_4.png")
	_save(img_cat, Rect2i(82, 66, 76, 28), out_dir + "hud_variant_5.png")
	_save(img_cat, Rect2i(2, 98, 76, 28), out_dir + "hud_variant_6.png")
	_save(img_cat, Rect2i(82, 98, 76, 28), out_dir + "hud_variant_7.png")
	
	# Also let's inspect the sub-parts of these HUDs!
	# The avatar box alone: around (2, 2, 28, 28)
	# The progress bar empty frame / track:
	# The progress bar fill:
	# The coin scroll panel:
	quit()

func _save(src: Image, rect: Rect2i, path: String) -> void:
	var sub = src.get_region(rect)
	sub.save_png(path)
