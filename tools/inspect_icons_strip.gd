extends SceneTree

func _init() -> void:
	var path_cat = "assets/UI/CatUIPaid/CatUIPaid/catUI.png"
	var img_cat = Image.load_from_file(path_cat)
	
	var path_bonus = "assets/cats/CatMegaBundle/CatMegaBundle/CatUserInterface/BONUSPastelUI.png"
	var img_bonus = Image.load_from_file(path_bonus)
	
	var out_dir = "assets/UI/ToffeeHUD/"
	
	# Let's inspect catUI.png icons:
	# Row around y=472:
	# x=1: home? x=14: gear? x=27: coin? x=40: pause? x=52: star? x=64: check? x=77: cross?
	# Let's crop y=470..520, x=0..120
	_save(img_cat, Rect2i(0, 470, 128, 60), out_dir + "cat_icons_strip.png")
	
	# In catUI.png, let's see what is at y=190..240 (fishbone icons)
	_save(img_cat, Rect2i(450, 190, 60, 40), out_dir + "cat_fish_strip.png")
	
	# In BONUSPastelUI.png:
	# Buttons at (496, 547, 48, 24), (560, 547, 48, 24), (496, 579, 48, 24)
	# Also let's check square buttons:
	# Are there 24x24 or 32x32 square buttons?
	# Let's check catUI.png:
	# We have btn_paw_sq_cream, btn_paw_sq_pressed, btn_paw_sq_tan, btn_paw_sq_dark!
	# What about pause and shop icons?
	# In catUI.png, there is icon_pause.png, icon_cart / icon_shirt / icon_decor?
	
	quit()

func _save(src: Image, rect: Rect2i, path: String) -> void:
	var sub = src.get_region(rect)
	sub.save_png(path)
