extends SceneTree

func _init() -> void:
	var path = OS.get_user_data_dir() + "/save_game.json"
	print("User data dir: ", path)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Removed old save_game.json!")
	else:
		print("No old save_game.json found.")
	quit(0)
