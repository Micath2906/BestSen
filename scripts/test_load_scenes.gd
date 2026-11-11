extends SceneTree

func _init():
	var m = load("res://scenes/MainMenu.tscn")
	print("MainMenu loaded:", m != null)
	var p = load("res://scenes/PauseModal.tscn")
	print("PauseModal loaded:", p != null)
	quit()
