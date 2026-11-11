extends SceneTree

func _init() -> void:
	var path_cat = "assets/UI/CatUIPaid/CatUIPaid/catUI.png"
	var img_cat = Image.load_from_file(path_cat)
	print("catUI.png: ", img_cat.get_size())
	
	var path_bonus = "assets/cats/CatMegaBundle/CatMegaBundle/CatUserInterface/BONUSPastelUI.png"
	var img_bonus = Image.load_from_file(path_bonus)
	print("BONUSPastelUI.png: ", img_bonus.get_size())
	
	# Let's check some regions in catUI.png:
	# Earlier slice_perfect_cat_ui.gd sliced:
	# frame_rounded_cream: Rect2i(0, 270, 28, 28)
	# frame_rounded_sand: Rect2i(30, 270, 28, 28)
	# frame_rounded_dark: Rect2i(0, 375, 28, 28)
	
	# Let's inspect rows around 0..400 in catUI.png to find wood frames or parchment banners
	quit()
