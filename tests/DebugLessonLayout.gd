extends Node

func _ready() -> void:
	print("=== DEBUG LESSON LAYOUT IN MAIN ===")
	var main_scene = load("res://scenes/Main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	
	main.start_lesson(1)
	await get_tree().create_timer(0.3).timeout
	
	var lv = main.current_view_node
	print("lv node: ", lv)
	print("lv.visible: ", lv.visible)
	print("lv.size: ", lv.size)
	
	var slots_sec = lv.get_node("SlotsSection")
	print("SlotsSection position: ", slots_sec.position, " size: ", slots_sec.size, " visible: ", slots_sec.visible)
	var slots_cnt = lv.get_node("SlotsSection/SlotsContainer")
	print("SlotsContainer position: ", slots_cnt.position, " size: ", slots_cnt.size, " children: ", slots_cnt.get_child_count())
	for i in range(slots_cnt.get_child_count()):
		var ch = slots_cnt.get_child(i)
		print("  Slot ", i, " pos: ", ch.position, " size: ", ch.size, " visible: ", ch.visible)
		
	var cards_sec = lv.get_node("CardsSection")
	print("CardsSection position: ", cards_sec.position, " size: ", cards_sec.size, " visible: ", cards_sec.visible)
	var scroll = lv.get_node("CardsSection/ScrollContainer")
	print("ScrollContainer position: ", scroll.position, " size: ", scroll.size, " visible: ", scroll.visible)
	var pool = lv.get_node("CardsSection/ScrollContainer/CardsPoolContainer")
	print("CardsPoolContainer position: ", pool.position, " size: ", pool.size, " children: ", pool.get_child_count())
	for i in range(pool.get_child_count()):
		var ch = pool.get_child(i)
		print("  Card ", i, " pos: ", ch.position, " size: ", ch.size, " visible: ", ch.visible)
		
	var vp = get_viewport()
	if vp and vp.get_texture():
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_debug_lesson_layout.png")
			print("Saved: screenshot_debug_lesson_layout.png")
			
	get_tree().quit(0)
