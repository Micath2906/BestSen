extends SceneTree

func _init() -> void:
	var mochi_full = Image.load_from_file("D:/BestSen/assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/White-DifferentEyes/Sittingggg.png")
	var frame0 = mochi_full.get_region(Rect2i(0, 0, 32, 32))
	var used = frame0.get_used_rect()
	print("Mochi Sittingggg frame 0 used rect: ", used)
	
	var pochi_full = Image.load_from_file("D:/BestSen/assets/cats/CatMegaBundle/CatMegaBundle/Pochi/Sprites/Idle.png")
	# Pochi Idle is 64x64 per frame or what?
	print("Pochi full size: ", pochi_full.get_size())
	var pochi_frame0 = pochi_full.get_region(Rect2i(0, 0, pochi_full.get_height(), pochi_full.get_height()))
	print("Pochi frame 0 used rect: ", pochi_frame0.get_used_rect())
	quit()
