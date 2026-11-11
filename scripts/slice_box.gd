@tool
extends SceneTree

func _init() -> void:
	var img = Image.new()
	img.load(ProjectSettings.globalize_path("res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Beds/CatBoxes.png"))
	print("CatBoxes:", img.get_width(), "x", img.get_height())
	# Save frame 0 (64x64)
	var box0 = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	box0.blit_rect(img, Rect2i(0, 0, 64, 64), Vector2i.ZERO)
	var out_dir = ProjectSettings.globalize_path("res://assets/sprites/room_items/")
	DirAccess.make_dir_recursive_absolute(out_dir)
	box0.save_png(out_dir + "cat_box_new.png")
	print("Saved cat_box_new.png!")
	quit()
