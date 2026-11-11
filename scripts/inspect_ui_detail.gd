@tool
extends SceneTree

func _init() -> void:
	print("\n--- ANALYZING BONUSPastelUI.png and catUI.png ---")
	_inspect_ui("res://assets/UI/CatUIPaid/CatUIPaid/catUI.png", "catUI")
	_inspect_ui("res://assets/cats/CatMegaBundle/CatMegaBundle/CatUserInterface/BONUSPastelUI.png", "BONUSPastelUI")
	quit()

func _inspect_ui(path: String, prefix: String) -> void:
	var img = Image.new()
	var err = img.load(ProjectSettings.globalize_path(path))
	if err != OK:
		print("Failed to load:", path)
		return
	print("[%s] Size: %dx%d" % [prefix, img.get_width(), img.get_height()])
	
	# Sample some non-transparent sub-regions
	# We can write an automated rectangular island finder to see what sub-elements exist
	var w = img.get_width()
	var h = img.get_height()
	print("Checking top-left 128x128...")
	var non_empty = 0
	for y in range(0, mini(h, 128)):
		for x in range(0, mini(w, 128)):
			if img.get_pixel(x, y).a > 0.05:
				non_empty += 1
	print("Non-empty pixels in 128x128:", non_empty)
