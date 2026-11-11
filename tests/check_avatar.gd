extends SceneTree

func _init() -> void:
	var f8 = Image.load_from_file("D:/BestSen/assets/sprites/avatars/framed_avatar_8.png")
	var a8 = Image.load_from_file("D:/BestSen/assets/sprites/avatars/avatar_8.png")
	print("framed_avatar_8: ", f8.get_size() if f8 else "null")
	print("avatar_8: ", a8.get_size() if a8 else "null")
	quit()
