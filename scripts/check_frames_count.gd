@tool
extends SceneTree

const BASE = "res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/"

func _init() -> void:
	var anims = ["idle", "idle2", "sit", "sleep", "run", "jump", "hurt"]
	var breeds = [
		{"name": "Tiger", "idle": BASE + "TigerCatPaid/PNG/IdleCatt.png", "idle2": BASE + "TigerCatPaid/PNG/Idle2Catt.png", "sit": BASE + "TigerCatPaid/PNG/Sittingg.png", "sleep": BASE + "TigerCatPaid/PNG/SleepCatt.png", "run": BASE + "TigerCatPaid/PNG/RunCatt.png", "jump": BASE + "TigerCatPaid/PNG/JumpCattt.png", "hurt": BASE + "TigerCatPaid/PNG/HurtCattt.png"},
		{"name": "Brown", "idle": BASE + "BrownCat/IdleCattt.png", "idle2": BASE + "BrownCat/Idle2Cattt.png", "sit": BASE + "BrownCat/Sittinggg.png", "sleep": BASE + "BrownCat/SleepCattt.png", "run": BASE + "BrownCat/RunCattt.png", "jump": BASE + "BrownCat/JumpCatttt.png", "hurt": BASE + "BrownCat/HurtCatttt.png"},
		{"name": "ThreeColor", "idle": BASE + "ThreeColorPaid/IdleCatt.png", "idle2": BASE + "ThreeColorPaid/Idle2Catt.png", "sit": BASE + "ThreeColorPaid/Sittingg.png", "sleep": BASE + "ThreeColorPaid/SleepCatt.png", "run": BASE + "ThreeColorPaid/RunCatt.png", "jump": BASE + "ThreeColorPaid/JumpCattt.png", "hurt": BASE + "ThreeColorPaid/HurtCattt.png"},
		{"name": "Black", "idle": BASE + "BlackCat/PNG/IdleCatb.png", "idle2": BASE + "BlackCat/PNG/Idle2Catb.png", "sit": BASE + "BlackCat/PNG/Sittingb.png", "sleep": BASE + "BlackCat/PNG/SleepCatb.png", "run": BASE + "BlackCat/PNG/RunCatb.png", "jump": BASE + "BlackCat/PNG/JumpCabt.png", "hurt": BASE + "BlackCat/PNG/HurtCatb.png"},
		{"name": "Batman", "idle": BASE + "BatmanCatPaid/BlackMask/IdleCatt.png", "idle2": BASE + "BatmanCatPaid/BlackMask/IdleCatt.png", "sit": BASE + "BatmanCatPaid/BlackMask/Sittingg.png", "sleep": BASE + "BatmanCatPaid/BlackMask/SleepCatt.png", "run": BASE + "BatmanCatPaid/BlackMask/RunCatt.png", "jump": BASE + "BatmanCatPaid/BlackMask/JumpCattt.png", "hurt": BASE + "BatmanCatPaid/BlackMask/HurtCattt.png"},
		{"name": "White", "idle": BASE + "White-DifferentEyes/IdleCatttt.png", "idle2": BASE + "White-DifferentEyes/Idle2Catttt.png", "sit": BASE + "White-DifferentEyes/Sittingggg.png", "sleep": BASE + "White-DifferentEyes/SleepCatttt.png", "run": BASE + "White-DifferentEyes/RunCatttt.png", "jump": BASE + "White-DifferentEyes/JumpCattttt.png", "hurt": BASE + "White-DifferentEyes/HurtCattttt.png"},
		{"name": "Siamese", "idle": BASE + "Siamese/PNG/IdleCattt.png", "idle2": BASE + "Siamese/PNG/Idle2Cattt.png", "sit": BASE + "Siamese/PNG/Sittinggg.png", "sleep": BASE + "Siamese/PNG/SleepCattt.png", "run": BASE + "Siamese/PNG/RunCattt.png", "jump": BASE + "Siamese/PNG/JumpCatttt.png", "hurt": BASE + "Siamese/PNG/HurtCatttt.png"},
		{"name": "Classical", "idle": BASE + "CatClassical/BlueCollar/IdleCat.png", "idle2": BASE + "CatClassical/BlueCollar/Idle2Cat.png", "sit": BASE + "CatClassical/BlueCollar/Sitting.png", "sleep": BASE + "CatClassical/BlueCollar/SleepCat.png", "run": BASE + "CatClassical/BlueCollar/RunCat.png", "jump": BASE + "CatClassical/BlueCollar/JumpCat.png", "hurt": BASE + "CatClassical/BlueCollar/HurtCat.png"}
	]
	for b in breeds:
		var line = b["name"] + ":"
		for a in anims:
			var img = Image.new()
			if img.load(ProjectSettings.globalize_path(b[a])) == OK:
				var fc = img.get_width() / 32
				line += " " + a + "=" + str(fc)
			else:
				line += " " + a + "=FAIL"
		print(line)
	quit()
