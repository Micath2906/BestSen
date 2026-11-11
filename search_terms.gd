extends SceneTree

func _init():
	var terms = ["175cc", "Dừng xe ngay", "DẠY BOSS", "Thoát", "Chụp ảnh"]
	_scan_dir("res://", terms)
	quit()

func _scan_dir(path: String, terms: Array):
	var dir = DirAccess.open(path)
	if not dir:
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue
		var full_path = path.path_join(file_name)
		if dir.current_is_dir():
			if file_name != ".git" and file_name != ".godot":
				_scan_dir(full_path, terms)
		else:
			if file_name.ends_with(".gd") or file_name.ends_with(".tscn"):
				var f = FileAccess.open(full_path, FileAccess.READ)
				if f:
					var txt = f.get_as_text()
					for t in terms:
						if t in txt:
							print("[%s] in %s" % [t, full_path])
		file_name = dir.get_next()
