extends Node

func _ready() -> void:
	print("=== TEST REAL MOUSE PARSE EVENT ===")
	var main_scene = load("res://scenes/Main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	
	await get_tree().create_timer(0.4).timeout
	main.start_lesson(1)
	await get_tree().create_timer(0.4).timeout
	
	var lv = main.current_view_node
	var pool = lv.cards_pool_container
	var scroll: ScrollContainer = lv.get_node("CardsSection/ScrollContainer")
	
	# Find step 1 card panel
	var card_1_panel = null
	for p in pool.get_children():
		card_1_panel = p
		break
		
	var start_pos = card_1_panel.global_position + Vector2(100, 30)
	var slot_0 = lv.slots_container.get_child(0)
	var end_pos = slot_0.global_position + Vector2(50, 70)
	
	print("Starting real mouse drag from ", start_pos, " to ", end_pos)
	
	# 1. Mouse down via Viewport
	var ev_down = InputEventMouseButton.new()
	ev_down.button_index = MOUSE_BUTTON_LEFT
	ev_down.pressed = true
	ev_down.position = start_pos
	ev_down.global_position = start_pos
	Input.parse_input_event(ev_down)
	
	await get_tree().create_timer(0.05).timeout
	
	# 2. Mouse motion steps
	for step in range(1, 15):
		var cur_pos = start_pos.lerp(end_pos, step / 15.0)
		var ev_move = InputEventMouseMotion.new()
		ev_move.position = cur_pos
		ev_move.global_position = cur_pos
		Input.parse_input_event(ev_move)
		await get_tree().create_timer(0.02).timeout
		
	await get_tree().create_timer(0.05).timeout
	
	# 3. Mouse up
	var ev_up = InputEventMouseButton.new()
	ev_up.button_index = MOUSE_BUTTON_LEFT
	ev_up.pressed = false
	ev_up.position = end_pos
	ev_up.global_position = end_pos
	Input.parse_input_event(ev_up)
	
	await get_tree().create_timer(0.4).timeout
	
	print("After drag: scroll_vertical = ", scroll.scroll_vertical)
	print("Matched slots = ", lv.matched_slots)
	print("Pool child count = ", pool.get_child_count())
	for i in range(pool.get_child_count()):
		var c = pool.get_child(i)
		print("  card ", i, " visible=", c.visible, " size=", c.size, " global_pos=", c.global_position)
		
	var img = get_viewport().get_texture().get_image()
	img.save_png("D:/BestSen/screenshot_real_parse_event.png")
	
	get_tree().quit(0)
