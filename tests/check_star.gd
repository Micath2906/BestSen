extends SceneTree

func _init() -> void:
	var star = Image.load_from_file("D:/BestSen/assets/UI/CatUIPaid/slices/icon_star.png")
	if star:
		print("Star icon size: ", star.get_size())
	quit()
