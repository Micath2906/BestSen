@tool
extends SceneTree

func _init() -> void:
	for i in [1, 2, 3, 4, 5]:
		var p = "res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Rooms/Room%d.png" % i
		var img = Image.new()
		img.load(ProjectSettings.globalize_path(p))
		# Check average color of floor
		var c = img.get_pixel(256, 350)
		print("Room%d floor color at (256, 350): r=%.2f g=%.2f b=%.2f" % [i, c.r, c.g, c.b])
	quit()
