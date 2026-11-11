extends Control

func _ready() -> void:
	print("--- TEST LESSON 1 RENDER ---")
	var lv_scene = load("res://scenes/LessonView.tscn")
	var lv = lv_scene.instantiate()
	add_child(lv)
	
	lv.load_lesson(1)
	
	var slots = lv.get_node("SlotsSection/SlotsContainer")
	var pool = lv.get_node("CardsSection/ScrollContainer/CardsPoolContainer")
	print("Slots child count: ", slots.get_child_count())
	print("Pool child count: ", pool.get_child_count())
	
	for i in range(slots.get_child_count()):
		var c = slots.get_child(i)
		print("Slot ", i, " rect: ", c.get_rect(), " global: ", c.get_global_rect(), " vis: ", c.visible)
		
	for i in range(pool.get_child_count()):
		var c = pool.get_child(i)
		print("Card ", i, " rect: ", c.get_rect(), " global: ", c.get_global_rect(), " vis: ", c.visible)
		
	await get_tree().create_timer(0.3).timeout
	var img = get_viewport().get_texture().get_image()
	img.save_png("res://tests/test_lesson_1_render.png")
	print("Saved screenshot to res://tests/test_lesson_1_render.png")
	get_tree().quit(0)
