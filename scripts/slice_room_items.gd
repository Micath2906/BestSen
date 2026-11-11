@tool
extends SceneTree

func _init() -> void:
	print("\n--- SLICING SINGLE FURNITURE ITEMS ---")
	var out_dir = ProjectSettings.globalize_path("res://assets/sprites/room_items/")
	DirAccess.make_dir_recursive_absolute(out_dir)
	
	# 1. CatBowls (32x32 -> 4 bowls of 16x16)
	var bowls_img = Image.new()
	bowls_img.load(ProjectSettings.globalize_path("res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/CatToys/CatBowls.png"))
	print("CatBowls:", bowls_img.get_width(), "x", bowls_img.get_height())
	
	# Bowl 1: Top-left (16x16)
	var bowl_blue = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	bowl_blue.blit_rect(bowls_img, Rect2i(0, 0, 16, 16), Vector2i.ZERO)
	bowl_blue.save_png(out_dir + "bowl_blue.png")
	
	# Bowl 2: Top-right (16x16)
	var bowl_green = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	bowl_green.blit_rect(bowls_img, Rect2i(16, 0, 16, 16), Vector2i.ZERO)
	bowl_green.save_png(out_dir + "bowl_green.png")
	
	# Create a cute Dual Bowl set (two bowls side-by-side: 30x16)
	var dual_bowl = Image.create(30, 16, false, Image.FORMAT_RGBA8)
	dual_bowl.fill(Color(0, 0, 0, 0))
	dual_bowl.blit_rect(bowl_blue, Rect2i(0, 0, 16, 16), Vector2i(0, 0))
	dual_bowl.blit_rect(bowl_green, Rect2i(0, 0, 16, 16), Vector2i(14, 0))
	dual_bowl.save_png(out_dir + "dual_bowl_pair.png")
	print("Saved dual_bowl_pair.png!")
	
	# 2. CatHomes (126x126 -> 4 houses of 63x63)
	var homes_img = Image.new()
	homes_img.load(ProjectSettings.globalize_path("res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Beds/CatHomes.png"))
	var home_teal = Image.create(63, 63, false, Image.FORMAT_RGBA8)
	home_teal.blit_rect(homes_img, Rect2i(0, 0, 63, 63), Vector2i.ZERO)
	home_teal.save_png(out_dir + "single_cat_home.png")
	print("Saved single_cat_home.png!")
	
	quit()
