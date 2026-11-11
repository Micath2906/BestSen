@tool
extends SceneTree

func _init() -> void:
	print("\n--- ANALYZING catUI.png LAYOUT ---")
	var img = Image.new()
	var p = ProjectSettings.globalize_path("res://assets/UI/CatUIPaid/CatUIPaid/catUI.png")
	if img.load(p) == OK:
		print("Loaded catUI.png: ", img.get_width(), "x", img.get_height())
		# Scan top rows to see where dialogue boxes, bars, buttons are
		# Let's inspect some sample coordinates
	quit()
