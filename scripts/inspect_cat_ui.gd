extends SceneTree

func _init() -> void:
	var path = "assets/UI/CatUIPaid/CatUIPaid/catUI.png"
	var img = Image.load_from_file(path)
	if not img:
		print("Cannot load catUI.png")
		quit(1)
		return
	print("catUI.png Size: ", img.get_size()) # Width x Height
	quit(0)
