extends Control

func _ready() -> void:
	var lv_scene = load("res://scenes/LessonView.tscn")
	var lv = lv_scene.instantiate()
	add_child(lv)
	lv.load_lesson(1)
	
	# Match card 1 to slot 0
	var card_1 = {}
	for c in lv.shuffled_cards:
		if c["step"] == 1: card_1 = c
	lv._attempt_match_card_to_slot(card_1, 0)
	
	await get_tree().create_timer(0.4).timeout
	
	var scroll: ScrollContainer = lv.get_node("CardsSection/ScrollContainer")
	print("Before setting scroll: v_scroll min=", scroll.get_v_scroll_bar().min_value, " max=", scroll.get_v_scroll_bar().max_value, " val=", scroll.scroll_vertical)
	
	# Scroll all the way down
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)
	print("Set scroll_vertical to: ", scroll.scroll_vertical)
	
	await get_tree().create_timer(0.2).timeout
	
	var img = get_viewport().get_texture().get_image()
	img.save_png("D:/BestSen/screenshot_scrolled_away.png")
	print("Saved to D:/BestSen/screenshot_scrolled_away.png")
	
	get_tree().quit(0)
