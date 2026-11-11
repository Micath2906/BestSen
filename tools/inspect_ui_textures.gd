extends SceneTree

func _init() -> void:
	var paths = [
		"assets/UI/CatUIPaid/CatUIPaid/catUI.png",
		"assets/sprites/cat_ui.png",
		"assets/sprites/ui/top_hud.png"
	]
	for p in paths:
		var img = Image.load_from_file(p)
		if img:
			print(p, " -> size: ", img.get_size(), " format: ", img.get_format())
		else:
			print(p, " -> NOT FOUND")
	quit()
