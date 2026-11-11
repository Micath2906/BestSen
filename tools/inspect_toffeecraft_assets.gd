extends SceneTree

func _init() -> void:
	var path_cat = "assets/UI/CatUIPaid/CatUIPaid/catUI.png"
	var img_cat = Image.load_from_file(path_cat)
	
	var path_bonus = "assets/cats/CatMegaBundle/CatMegaBundle/CatUserInterface/BONUSPastelUI.png"
	var img_bonus = Image.load_from_file(path_bonus)
	
	var out_dir = "assets/UI/ToffeeHUD/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	
	# Let's inspect catUI icons around (0..128, 450..550)
	print("--- INSPECTING catUI ICONS & FRAMES ---")
	
	# In catUI.png, let's see what is at:
	# (27, 472): icon_coin
	# (39, 472): icon_heart
	# (40, 488): icon_pause
	# (0, 270, 28, 28): frame_rounded_cream
	# (30, 270, 28, 28): frame_rounded_sand
	
	# Let's inspect the progress bars in BONUSPastelUI:
	# At (384, 192, 48, 16), (512, 192, 48, 16), etc.
	# Let's save samples to out_dir
	_save(img_bonus, Rect2i(384, 192, 48, 16), out_dir + "test_bar_1.png")
	_save(img_bonus, Rect2i(512, 192, 48, 16), out_dir + "test_bar_2.png")
	_save(img_bonus, Rect2i(384, 224, 48, 16), out_dir + "test_bar_3.png")
	_save(img_bonus, Rect2i(512, 224, 48, 16), out_dir + "test_bar_4.png")
	_save(img_bonus, Rect2i(384, 256, 48, 16), out_dir + "test_bar_5.png")
	_save(img_bonus, Rect2i(512, 256, 48, 16), out_dir + "test_bar_6.png")
	
	# Also let's inspect the 90x27 items in BONUSPastelUI:
	_save(img_bonus, Rect2i(195, 1, 90, 27), out_dir + "test_banner_1.png")
	_save(img_bonus, Rect2i(292, 3, 90, 25), out_dir + "test_banner_2.png")
	_save(img_bonus, Rect2i(1, 4, 77, 25), out_dir + "test_banner_3.png")
	
	# Also let's inspect small icons in BONUSPastelUI around (480..600, 880..950)
	_save(img_bonus, Rect2i(487, 881, 18, 15), out_dir + "test_icon_1.png")
	_save(img_bonus, Rect2i(519, 881, 18, 15), out_dir + "test_icon_2.png")
	_save(img_bonus, Rect2i(551, 881, 18, 15), out_dir + "test_icon_3.png")
	_save(img_bonus, Rect2i(487, 913, 18, 15), out_dir + "test_icon_4.png")
	_save(img_bonus, Rect2i(519, 913, 18, 15), out_dir + "test_icon_5.png")
	_save(img_bonus, Rect2i(551, 913, 18, 15), out_dir + "test_icon_6.png")
	
	# Let's inspect ribbons / badges in catUI & BONUSPastelUI:
	# In BONUSPastelUI:
	# (421, 692, 39, 40), (417, 633, 47, 48), (261, 691, 88, 44), (4, 838, 87, 44)
	_save(img_bonus, Rect2i(421, 692, 39, 40), out_dir + "test_badge_1.png")
	_save(img_bonus, Rect2i(417, 633, 47, 48), out_dir + "test_badge_2.png")
	_save(img_bonus, Rect2i(261, 691, 88, 44), out_dir + "test_scroll_1.png")
	_save(img_bonus, Rect2i(4, 838, 87, 44), out_dir + "test_scroll_2.png")
	_save(img_bonus, Rect2i(740, 256, 88, 80), out_dir + "test_frame_1.png")
	
	print("Saved test samples!")
	quit()

func _save(src: Image, rect: Rect2i, path: String) -> void:
	var sub = src.get_region(rect)
	sub.save_png(path)
