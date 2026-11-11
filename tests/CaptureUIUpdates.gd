extends Node

func _ready() -> void:
	print("--- CAPTURING UI UPDATES SCREENSHOTS ---")
	get_viewport().size = Vector2i(540, 960)
	
	# 1. Capture Skill Tree
	var tree_scene = preload("res://scenes/SkillTree.tscn").instantiate()
	add_child(tree_scene)
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	var img = get_viewport().get_texture().get_image()
	img.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_skill_tree_updated.png")
	print("Saved screenshot_skill_tree_updated.png")
	
	remove_child(tree_scene)
	tree_scene.queue_free()
	
	# 2. Capture Minigame (Personal Finance)
	var game_scene = preload("res://scenes/minigames/PersonalFinanceGame.tscn").instantiate()
	add_child(game_scene)
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	var img2 = get_viewport().get_texture().get_image()
	img2.save_png("C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_minigame_updated.png")
	print("Saved screenshot_minigame_updated.png")
	
	get_tree().quit(0)
