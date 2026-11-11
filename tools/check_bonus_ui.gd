extends SceneTree

func _init() -> void:
	var path = "assets/cats/CatMegaBundle/CatMegaBundle/CatUserInterface/BONUSPastelUI.png"
	var img = Image.load_from_file(path)
	if img:
		print("BONUSPastelUI.png size: ", img.get_size())
	quit()
