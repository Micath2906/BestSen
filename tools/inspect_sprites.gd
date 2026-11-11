extends SceneTree

func _init() -> void:
	var files = [
		"res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/TigerCatPaid/PNG/IdleCatt.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/TigerCatPaid/PNG/Idle2Catt.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/TigerCatPaid/PNG/Sittingg.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/TigerCatPaid/PNG/SleepCatt.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/Mochi/Sprites/Classical/Individual/Box1.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/Mochi/Sprites/Classical/Individual/Box2.png",
		"res://assets/cats/RetroCatsPaid/RetroCatsPaid/Cats/Sprites/Box1.png"
	]
	for f in files:
		var img = Image.new()
		var err = img.load(ProjectSettings.globalize_path(f))
		if err == OK:
			print(f, " => ", img.get_width(), "x", img.get_height(), " (Frame size 32 -> ", img.get_width() / 32, " frames)")
		else:
			print("Error loading ", f)
	quit(0)
