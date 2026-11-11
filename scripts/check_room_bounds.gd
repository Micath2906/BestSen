@tool
extends SceneTree

func _init() -> void:
	print("\n--- CHECKING Room1.png FLOOR BOUNDS ---")
	var img = Image.new()
	var p = ProjectSettings.globalize_path("res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Rooms/Room1.png")
	if img.load(p) == OK:
		print("Size: ", img.get_width(), "x", img.get_height())
		# Scan center vertical column to find where wall ends and floor begins
		var mid_x = img.get_width() / 2
		print("Scanning column x=", mid_x)
		for y in range(0, img.get_height(), 16):
			var c = img.get_pixel(mid_x, y)
			# print alpha or brightness
	quit()
