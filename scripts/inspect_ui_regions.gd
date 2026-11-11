@tool
extends SceneTree

func _init() -> void:
	_scan_image("res://assets/UI/CatUIPaid/CatUIPaid/catUI.png")
	_scan_image("res://assets/cats/CatMegaBundle/CatMegaBundle/CatUserInterface/BONUSPastelUI.png")
	quit()

func _scan_image(res_path: String) -> void:
	print("\n--- SCANNING: ", res_path.get_file(), " ---")
	var img = Image.new()
	var err = img.load(ProjectSettings.globalize_path(res_path))
	if err != OK:
		print("Failed to load: ", res_path)
		return
	print("Size: ", img.get_width(), "x", img.get_height())
	
	# Let's find used rect
	var used = img.get_used_rect()
	print("Used Rect: ", used)
