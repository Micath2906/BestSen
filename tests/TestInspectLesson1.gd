extends Node

func _ready() -> void:
	print("=== INSPECT LESSON VIEW INSTANTIATION ===")
	var lv_scene = load("res://scenes/LessonView.tscn")
	var lv = lv_scene.instantiate()
	add_child(lv)
	lv.load_lesson(1)
	
	print("shuffled_cards size: ", lv.shuffled_cards.size())
	for i in range(lv.shuffled_cards.size()):
		var c = lv.shuffled_cards[i]
		print("shuffled_cards[", i, "]: ", c)
		
	var pool = lv.get_node("CardsSection/ScrollContainer/CardsPoolContainer")
	print("Pool children count: ", pool.get_child_count())
	for i in range(pool.get_child_count()):
		var p = pool.get_child(i)
		# find labels
		for ch in p.get_children():
			if ch is HBoxContainer:
				for sub in ch.get_children():
					if sub is Label:
						print("  child label: ", sub.text)
					elif sub is VBoxContainer:
						for vsub in sub.get_children():
							if vsub is Label:
								print("  vbox label: ", vsub.text)
					elif sub is PanelContainer:
						for isub in sub.get_children():
							if isub is Label:
								print("  badge label: ", isub.text)
	get_tree().quit(0)
