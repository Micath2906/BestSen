@tool
extends SceneTree

func _init():
	print("--- CONVERTING PIXEL ATLAS ICONS TO GODOT TRES ---")
	var dir_path = "res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/"
	var dir = DirAccess.open(dir_path)
	if not dir:
		push_error("Directory not found")
		quit(1)
		return
		
	dir.list_dir_begin()
	var fname = dir.get_next()
	var count = 0
	while fname != "":
		if fname.ends_with(".png"):
			var base_name = fname.get_basename()
			var png_file = dir_path + fname
			var tres_file = dir_path + base_name + ".tres"
			
			var img = Image.load_from_file(ProjectSettings.globalize_path(png_file))
			if img:
				var tex = ImageTexture.create_from_image(img)
				ResourceSaver.save(tex, tres_file)
				count += 1
				print("Converted: %s -> %s" % [fname, base_name + ".tres"])
		fname = dir.get_next()
		
	print("Converted %d pixel atlas textures successfully!" % count)
	quit(0)
