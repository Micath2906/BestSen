extends SceneTree

func _init() -> void:
	print("--- INSPECTING FREE PACK CAT SPRITESHEET ---")
	var path_list = "res://assets/Free pack/Free pack/cat 16x16 animation list.png"
	var path_cat1 = "res://assets/Free pack/Free pack/cat 1.png"
	var path_idx = "res://assets/Free pack/Free pack/Frame indexes.png"
	
	var img_cat1 = Image.load_from_file(path_cat1)
	if img_cat1:
		print("Cat 1 loaded: ", img_cat1.get_size(), " format: ", img_cat1.get_format())
	else:
		print("Failed to load cat 1")
		
	var img_list = Image.load_from_file(path_list)
	if img_list:
		print("List loaded: ", img_list.get_size())
		# Check extra 80 pixels on the right: x from 352 to 431
		# Let's crop first 20 rows of the text region (x: 352, width: 80, y: 0, height: 320)
		var text_crop = Image.create(80, 320, false, Image.FORMAT_RGBA8)
		text_crop.blit_rect(img_list, Rect2i(352, 0, 80, 320), Vector2i(0, 0))
		text_crop.save_png("res://tests/debug_text_crop_1.png")
		print("Saved debug_text_crop_1.png")
	
	quit()
