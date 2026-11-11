@tool
extends SceneTree

func _init() -> void:
	print("\n--- TESTING FURNITURE TEXTURE PATHS ---")
	var paths = [
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Beds/CatBedPink.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Beds/CatBedBlue.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/CatToys/CatBowls.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/PlayGrounds/CatPlayGround.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Beds/CatBoxes.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Beds/CatHomes.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Rooms/Room1.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Rooms/Room2.png"
	]
	for p in paths:
		var img = Image.new()
		var err = img.load(ProjectSettings.globalize_path(p))
		if err == OK:
			print(p.get_file(), " -> SUCCESS (", img.get_width(), "x", img.get_height(), ")")
		else:
			print(p.get_file(), " -> ERROR CODE:", err)
	quit()
