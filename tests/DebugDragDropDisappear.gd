extends Node

func _ready() -> void:
	var lv_scene = load("res://scenes/LessonView.tscn")
	var lv = lv_scene.instantiate()
	add_child(lv)
	lv.load_lesson(1)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("--- MATCHING CARD 1 TO SLOT 0 ---")
	var card_1 = {}
	for c in lv.shuffled_cards:
		if c["step"] == 1:
			card_1 = c
			break
	lv._attempt_match_card_to_slot(card_1, 0)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var scroll = lv.get_node("CardsSection/ScrollContainer")
	var pool = lv.cards_pool_container
	print("--- AFTER MATCH 1 ---")
	print("CardsSection pos: ", lv.get_node("CardsSection").position, " size: ", lv.get_node("CardsSection").size)
	print("ScrollContainer pos: ", scroll.position, " size: ", scroll.size, " scroll_vertical: ", scroll.scroll_vertical)
	print("CardsPoolContainer pos: ", pool.position, " size: ", pool.size)
	print("Pool child count: ", pool.get_child_count())
	for i in range(pool.get_child_count()):
		var p = pool.get_child(i)
		print("  Card ", i, " visible: ", p.visible, " pos: ", p.position, " size: ", p.size, " global_pos: ", p.global_position)
		
	get_tree().quit(0)
