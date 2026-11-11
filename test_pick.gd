extends SceneTree
func _init():
	var gm = load("res://scripts/GameManager.gd").new()
	gm.load_json_data()
	var lv = load("res://scenes/LessonView.tscn").instantiate()
	lv.load_lesson(1)
	var orig = lv.lesson_data["cards"]
	lv._pick_card(orig[0])
	print("After pick 0: matched_slots size=", lv.matched_slots.size(), " selected_seq=", lv.selected_sequence.size())
	lv._pick_card(orig[1])
	print("After pick 1: matched_slots size=", lv.matched_slots.size(), " selected_seq=", lv.selected_sequence.size())
	lv.free()
	quit(0)
