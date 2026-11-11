extends SceneTree

func _init() -> void:
	var img = Image.load_from_file("D:/BestSen/assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/White-DifferentEyes/Sittingggg.png")
	if img:
		print("Sittingggg size: ", img.get_size())
	var idle = Image.load_from_file("D:/BestSen/assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/White-DifferentEyes/IdleCatttt.png")
	if idle:
		print("IdleCatttt size: ", idle.get_size())
	quit()
