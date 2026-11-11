extends Control

# TestRoomRender.gd
func _ready() -> void:
	print("\n--- TESTING ROOM VIEW RENDERING ---")
	var room = load("res://scenes/IsometricRoomView.tscn").instantiate()
	add_child(room)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var img = get_viewport().get_texture().get_image()
	img.save_png("res://test_room_render.png")
	print("Saved test_room_render.png!")
	get_tree().quit(0)
