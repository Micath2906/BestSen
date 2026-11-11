extends SceneTree

func _init() -> void:
	var path_dec = "assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Decorations/CatRoomDecorations.png"
	var img_dec = Image.load_from_file(path_dec)
	if img_dec:
		print("CatRoomDecorations.png size: ", img_dec.get_size())
	quit()
