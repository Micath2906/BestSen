extends SceneTree

func _init() -> void:
	var path_cat = "assets/UI/CatUIPaid/CatUIPaid/catUI.png"
	var img_cat = Image.load_from_file(path_cat)
	
	# Let's inspect the actual frames in catUI.png:
	# Earlier we saw in detect_spritesheet_islands:
	# Comp at (263, 454), size (85, 115) -> panel_cat_ear_cream
	# Comp at (358, 454), size (85, 115) -> panel_cat_ear_beige
	# Comp at (112, 818), size (96, 61) -> modal_popup_beige
	# Comp at (165, 5), size (75, 43) -> dialog_cat_sleep_orange
	# Comp at (2, 2), size (76, 28)
	# Comp at (82, 2), size (76, 28)
	
	var out_dir = "assets/UI/ToffeeHUD/"
	_save(img_cat, Rect2i(2, 2, 76, 28), out_dir + "cat_comp_2_2.png")
	_save(img_cat, Rect2i(82, 2, 76, 28), out_dir + "cat_comp_82_2.png")
	_save(img_cat, Rect2i(2, 34, 76, 28), out_dir + "cat_comp_2_34.png")
	_save(img_cat, Rect2i(112, 818, 96, 61), out_dir + "cat_modal_beige.png")
	_save(img_cat, Rect2i(358, 454, 85, 115), out_dir + "cat_panel_beige.png")
	quit()

func _save(src: Image, rect: Rect2i, path: String) -> void:
	var sub = src.get_region(rect)
	sub.save_png(path)
