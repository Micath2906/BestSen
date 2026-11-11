@tool
extends SceneTree

func _init() -> void:
	var r1 = Image.new()
	r1.load(ProjectSettings.globalize_path("res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Rooms/Room1.png"))
	var used = r1.get_used_rect()
	print("Room1 used rect:", used)
	var ex = Image.new()
	ex.load(ProjectSettings.globalize_path("res://assets/furnitures/CatRoomPaid/CatRoomPaid/ExampleRooms/ExampleRoom.png"))
	print("ExampleRoom used rect:", ex.get_used_rect())
	quit()
