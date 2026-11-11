extends Node

func _ready() -> void:
	var lv_scene = load("res://scenes/LessonView.tscn")
	var lv = lv_scene.instantiate()
	add_child(lv)
	lv.load_lesson(1)
	
	var scroll: ScrollContainer = lv.get_node("CardsSection/ScrollContainer")
	print("Initial scroll_vertical: ", scroll.scroll_vertical)
	
	# Simulate setting scroll_vertical to 300
	scroll.scroll_vertical = 300
	print("Simulated scrolled: ", scroll.scroll_vertical)
	
	# Match card 1
	var card_1 = lv.shuffled_cards[0]
	for c in lv.shuffled_cards:
		if c["step"] == 1: card_1 = c
	lv._attempt_match_card_to_slot(card_1, 0)
	
	print("After match, scroll_vertical: ", scroll.scroll_vertical)
	
	get_tree().quit(0)
