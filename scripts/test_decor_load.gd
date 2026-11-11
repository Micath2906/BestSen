extends SceneTree

func _init():
	var res = load("res://scenes/RoomDecorStudioView.tscn")
	print("RoomDecorStudioView loaded successfully: ", res != null)
	if res:
		var node = res.instantiate()
		print("Instantiated node name: ", node.name)
		node.queue_free()
	quit()
