@tool
extends SceneTree

func _init() -> void:
	var files = [
		"res://assets/UI/CatUIPaid/CatUIPaid/catUI.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatUserInterface/BONUSPastelUI.png",
		"res://assets/furnitures/CatRoomPaid/CatRoomPaid/Catroompaid.png",
		"res://assets/furnitures/CatRoomPaid/CatRoomPaid/Rooms/Room1.png",
		"res://assets/furnitures/CatRoomPaid/CatRoomPaid/ExampleRooms/ExampleRoom.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/Siamese/PNG/IdleCatt.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/Siamese/PNG/SleepCattt.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/Siamese/PNG/Sittingg.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/Siamese/PNG/RunCatt.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/CatToys/CatBowls.png",
		"res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Beds/CatBedPink.png"
	]
	print("\n--- CHECKING ASSETS DIMENSIONS ---")
	for f in files:
		var img = Image.new()
		var err = img.load(ProjectSettings.globalize_path(f))
		if err == OK:
			print(f.get_file(), " -> ", img.get_width(), "x", img.get_height())
		else:
			print("FAIL TO LOAD:", f)
	quit()
