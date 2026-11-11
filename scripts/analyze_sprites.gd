@tool
extends SceneTree

func _init() -> void:
	print("\n--- ANALYZING SPRITESHEET FRAMES ---")
	var samples = [
		{"path": "res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/TigerCatPaid/PNG/IdleCatt.png", "name": "Tiger Idle"},
		{"path": "res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/TigerCatPaid/PNG/Idle2Catt.png", "name": "Tiger Idle2"},
		{"path": "res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/TigerCatPaid/PNG/Sittingg.png", "name": "Tiger Sit"},
		{"path": "res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/TigerCatPaid/PNG/SleepCatt.png", "name": "Tiger Sleep"},
		{"path": "res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/TigerCatPaid/PNG/RunCatt.png", "name": "Tiger Run"},
		{"path": "res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/TigerCatPaid/PNG/JumpCattt.png", "name": "Tiger Jump"},
		{"path": "res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/ThreeColorPaid/IdleCatt.png", "name": "ThreeColor Idle"},
		{"path": "res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/BlackCat/PNG/IdleCatb.png", "name": "BlackCat Idle"},
		{"path": "res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/CatClassical/IdleClassical.png", "name": "Classical Idle"},
		{"path": "res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/CatToys/BlueBall-Sheet.png", "name": "BlueBall Sheet"},
		{"path": "res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/CatToys/Mouse-Sheet.png", "name": "Mouse Sheet"}
	]
	
	for s in samples:
		var img = Image.new()
		var p = ProjectSettings.globalize_path(s["path"])
		var err = img.load(p)
		if err == OK:
			var w = img.get_width()
			var h = img.get_height()
			var frames = w / h
			print("%s: total=%dx%d -> aspect=%f -> likely frame size: %dx%d (%d frames)" % [s["name"], w, h, float(w)/h, h, h, frames])
		else:
			print("Error loading:", s["path"])
			
	quit()
