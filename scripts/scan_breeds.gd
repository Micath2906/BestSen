@tool
extends SceneTree

func _init() -> void:
	print("\n--- SCANNING ALL CAT BREEDS IN LittleKitties ---")
	var dir = DirAccess.open("res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties")
	if dir:
		dir.list_dir_begin()
		var sub = dir.get_next()
		while sub != "":
			if dir.current_is_dir() and not sub.begins_with(".") and not sub.begins_with("__"):
				print("Folder: ", sub)
				var sub_dir = DirAccess.open("res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/" + sub)
				if sub_dir:
					_print_files(sub_dir, "res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/" + sub, 0)
			sub = dir.get_next()
	quit()

func _print_files(d: DirAccess, path: String, depth: int) -> void:
	if depth > 2: return
	d.list_dir_begin()
	var file_name = d.get_next()
	while file_name != "":
		if d.current_is_dir() and not file_name.begins_with(".") and not file_name.begins_with("__"):
			var next_d = DirAccess.open(path + "/" + file_name)
			if next_d:
				_print_files(next_d, path + "/" + file_name, depth + 1)
		elif file_name.ends_with(".png") and not file_name.begins_with("._"):
			print("   ", path.replace("res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/", ""), "/", file_name)
		file_name = d.get_next()
