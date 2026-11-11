extends Control

func _ready() -> void:
	print("--- TEST REAL RENDER LESSON VIEW ---")
	var lv_scene = load("res://scenes/LessonView.tscn")
	var lv = lv_scene.instantiate()
	add_child(lv)
	
	lv.load_lesson(1)
	
	# Wait 3 frames for layout to settle
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	
	var slots = lv.get_node("SlotsSection/SlotsContainer")
	var pool = lv.get_node("CardsSection/ScrollContainer/CardsPoolContainer")
	print("Slots count: ", slots.get_child_count(), " pos: ", slots.global_position, " size: ", slots.size)
	for i in range(slots.get_child_count()):
		var c = slots.get_child(i)
		print("Slot ", i, " gpos: ", c.global_position, " size: ", c.size, " vis: ", c.is_visible_in_tree())
		
	print("Pool count: ", pool.get_child_count(), " pos: ", pool.global_position, " size: ", pool.size)
	for i in range(pool.get_child_count()):
		var c = pool.get_child(i)
		print("Card ", i, " gpos: ", c.global_position, " size: ", c.size, " vis: ", c.is_visible_in_tree())
		
	var vp = get_viewport()
	var img = vp.get_texture().get_image()
	if img:
		img.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/test_lesson_1_real_render.png")
		print("SUCCESS SAVED: test_lesson_1_real_render.png")
	else:
		print("ERROR: img is null")
		
	get_tree().quit(0)
