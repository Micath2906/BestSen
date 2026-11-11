@tool
extends SceneTree

func _init() -> void:
	print("\n--- INSPECTING FURNITURE ASSETS ---")
	var items = [
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Beds/CatBoxes.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Beds/CatHomes.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Beds/CatBedPink.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/CatToys/CatBowls.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/PlayGrounds/CatPlayGround.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/CatToys/toyss.png"
	]
	for p in items:
		var img = Image.new()
		if img.load(ProjectSettings.globalize_path(p)) == OK:
			print(p.get_file(), " -> size: ", img.get_width(), "x", img.get_height())
	quit()
