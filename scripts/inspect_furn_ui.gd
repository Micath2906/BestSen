extends SceneTree

func _init() -> void:
	var path = "assets/furnitures/PetMobileGameAsset/PetMobileGameAsset/Furnitures,Playgrounds,Toys.png"
	var img = Image.load_from_file(path)
	if not img:
		print("Cannot load Furnitures,Playgrounds,Toys.png")
		quit(1)
		return
	print("Furnitures,Playgrounds,Toys.png Size: ", img.get_size())
	quit(0)
