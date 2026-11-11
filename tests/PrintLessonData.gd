extends SceneTree

func _init() -> void:
	var gm = load("res://scripts/GameManager.gd").new()
	gm._ready()
	print("--- LESSON 1 DATA ---")
	print(JSON.stringify(gm.lessons_data.get(1, {}), "  "))
	print("--- LESSON 2 DATA ---")
	print(JSON.stringify(gm.lessons_data.get(2, {}), "  "))
	quit(0)
