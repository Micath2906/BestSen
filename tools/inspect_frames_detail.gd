extends SceneTree

func _init() -> void:
	var path_idle2 = "res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/TigerCatPaid/PNG/Idle2Catt.png"
	var img = Image.new()
	img.load(ProjectSettings.globalize_path(path_idle2))
	print("Idle2Catt size: ", img.get_width(), "x", img.get_height())
	
	var path_box = "res://assets/cats/CatMegaBundle/CatMegaBundle/Mochi/Sprites/Classical/Individual/Box1.png"
	var img_b = Image.new()
	img_b.load(ProjectSettings.globalize_path(path_box))
	print("Box1 size: ", img_b.get_width(), "x", img_b.get_height())
	
	quit(0)
