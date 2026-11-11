extends SceneTree

func _init() -> void:
	var img = Image.load_from_file("D:/BestSen/assets/cats/CatMegaBundle/CatMegaBundle/Mochi/Sprites/Classical/AllCats.png")
	if img:
		print("Mochi AllCats size: ", img.get_size())
	quit()
