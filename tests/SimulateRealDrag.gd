extends Control

func _ready() -> void:
	var lv_scene = load("res://scenes/LessonView.tscn")
	var lv = lv_scene.instantiate()
	add_child(lv)
	lv.load_lesson(1)
	
	await get_tree().create_timer(0.5).timeout
	
	# Find card 1 in cards_pool_container
	var pool = lv.cards_pool_container
	var target_card_panel: Control = null
	for c in pool.get_children():
		# check if this is step 1
		target_card_panel = c
		break
		
	var start_pos = target_card_panel.global_position + Vector2(100, 30)
	var slot_0 = lv.slots_container.get_child(0)
	var end_pos = slot_0.global_position + Vector2(50, 70)
	
	print("Dragging from ", start_pos, " to ", end_pos)
	
	# 1. Mouse down on target_card_panel
	var ev_down = InputEventMouseButton.new()
	ev_down.button_index = MOUSE_BUTTON_LEFT
	ev_down.pressed = true
	ev_down.position = start_pos
	ev_down.global_position = start_pos
	target_card_panel.gui_input.emit(ev_down)
	
	await get_tree().create_timer(0.1).timeout
	
	# 2. Mouse motion across to end_pos
	for step in range(1, 10):
		var cur_pos = start_pos.lerp(end_pos, step / 10.0)
		var ev_move = InputEventMouseMotion.new()
		ev_move.position = cur_pos
		ev_move.global_position = cur_pos
		ev_move.relative = Vector2(0, -20)
		lv._input(ev_move)
		await get_tree().create_timer(0.02).timeout
		
	await get_tree().create_timer(0.1).timeout
	
	# 3. Mouse up at end_pos
	var ev_up = InputEventMouseButton.new()
	ev_up.button_index = MOUSE_BUTTON_LEFT
	ev_up.pressed = false
	ev_up.position = end_pos
	ev_up.global_position = end_pos
	lv._input(ev_up)
	
	await get_tree().create_timer(0.5).timeout
	
	print("After drag: matched_slots = ", lv.matched_slots)
	print("Pool children count = ", pool.get_child_count())
	for i in range(pool.get_child_count()):
		var p = pool.get_child(i)
		print("  child ", i, " visible=", p.visible, " size=", p.size, " global_pos=", p.global_position)
		
	var scroll = lv.get_node("CardsSection/ScrollContainer")
	print("ScrollContainer scroll_vertical = ", scroll.scroll_vertical, " size = ", scroll.size)
	
	var img = get_viewport().get_texture().get_image()
	img.save_png("D:/BestSen/screenshot_simulate_real_drag.png")
	
	get_tree().quit(0)
