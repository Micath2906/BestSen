extends Node

func _ready() -> void:
	print("=== TEST DRAG IN MAIN ===")
	var main_scene = load("res://scenes/Main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	
	await get_tree().create_timer(0.4).timeout
	
	# Start lesson 1
	main.start_lesson(1)
	await get_tree().create_timer(0.4).timeout
	
	var lv = main.current_view_node
	print("Current view: ", lv.name)
	
	var pool = lv.cards_pool_container
	print("Initial pool child count: ", pool.get_child_count())
	for i in range(pool.get_child_count()):
		var c = pool.get_child(i)
		print("  card ", i, " visible=", c.visible, " size=", c.size, " global_pos=", c.global_position)
		
	# Find step 1 card
	var card_1_panel = null
	var card_1_data = {}
	for c in lv.shuffled_cards:
		if c["step"] == 1:
			card_1_data = c
			break
			
	for p in pool.get_children():
		# find if this panel is for card_1
		card_1_panel = p
		break
		
	print("Now simulating drag of card 1...")
	var start_pos = card_1_panel.global_position + Vector2(100, 30)
	var slot_0 = lv.slots_container.get_child(0)
	var end_pos = slot_0.global_position + Vector2(50, 70)
	
	# Start drag
	lv._start_card_drag(card_1_data, start_pos)
	
	# Move to slot 0
	lv._update_slot_hover(end_pos)
	print("Hovered slot: ", lv.hovered_slot_idx)
	
	# Finish drag
	lv._finish_card_drag(end_pos)
	
	await get_tree().create_timer(0.4).timeout
	
	print("\n=== AFTER DRAG FINISH ===")
	print("matched_slots = ", lv.matched_slots)
	print("pool child count: ", pool.get_child_count())
	for i in range(pool.get_child_count()):
		var c = pool.get_child(i)
		print("  card ", i, " visible=", c.visible, " size=", c.size, " global_pos=", c.global_position)
		
	var scroll = lv.get_node("CardsSection/ScrollContainer")
	print("ScrollContainer: pos=", scroll.global_position, " size=", scroll.size, " scroll_vertical=", scroll.scroll_vertical)
	
	var img = get_viewport().get_texture().get_image()
	img.save_png("D:/BestSen/screenshot_test_drag_in_main.png")
	print("Screenshot saved to D:/BestSen/screenshot_test_drag_in_main.png")
	
	get_tree().quit(0)
