extends SceneTree

func _init() -> void:
	print("Testing MainMenu loading...")
	var scene = load("res://scenes/MainMenu.tscn")
	if scene == null:
		print("ERROR: Failed to load MainMenu.tscn")
		quit(1)
		return
	print("SUCCESS: MainMenu.tscn loaded!")
	quit(0)
