extends SceneTree

func _init():
	var gm = load("res://scripts/GameManager.gd").new()
	gm.load_json_data()
	var l1 = gm.lessons_data.get(1, {})
	var cards = l1.get("cards", [])
	print("Cards count: ", cards.size())
	for c in cards:
		print("Card: ", c)
	quit()
