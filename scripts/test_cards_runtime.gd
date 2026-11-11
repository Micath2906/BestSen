extends SceneTree

func _init():
	var gm = load("res://scripts/GameManager.gd").new()
	gm.load_json_data()
	var l1 = gm.lessons_data.get(1, {})
	print("LESSON 1 TITLE: ", l1.get("title", ""))
	var cards = l1.get("cards", [])
	for c in cards:
		print("CARD: ", c)
	quit()
