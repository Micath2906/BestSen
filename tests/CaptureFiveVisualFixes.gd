extends Node

# CaptureFiveVisualFixes.gd
# Captures high quality screenshots verifying all 5 issues shown in the user's images:
# 1. SkillTree: Active level node has no floating cat / "DẠY BOSS!", uses clean pulse + cream paw (Fix for Image 1 & 2)
# 2. SkillTree & Minigames: Back button uses pixel arrow (icon_arrow_left.png), no blue box emoji (Fix for Image 3)
# 3. Minigame Phase 1: Correctly matched pair turns vibrant emerald green with white text, not grey disabled (Fix for Image 4)
# 4. Minigame Phase 2: Steps do not leak answers, placeholders say "Chạm thẻ bên dưới", no overflow (Fix for Image 5)

const OUTPUT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d"

func _ready() -> void:
	print("[CaptureFiveVisualFixes] Starting visual verification...")
	_run_captures()

func _run_captures() -> void:
	# 1. Capture SkillTree (Fixes Image 1, 2, 3)
	await _capture_skill_tree()
	
	# 2. Capture TrafficSafety Phase 1 with green matched pair (Fixes Image 4)
	await _capture_traffic_phase1()
	
	# 3. Capture TrafficSafety Phase 2 clean layout & hidden answers (Fixes Image 5)
	await _capture_traffic_phase2()
	
	# 4. Capture BottomPawMenu with ToffeeCraft shelf & drawer
	await _capture_bottom_paw_menu()
	
	print("[CaptureFiveVisualFixes] ALL VISUAL CAPTURES COMPLETED SUCCESSFULLY!")
	get_tree().quit(0)

func _capture_skill_tree() -> void:
	var scn = preload("res://scenes/SkillTree.tscn").instantiate()
	add_child(scn)
	await get_tree().process_frame
	await get_tree().process_frame
	
	_save_viewport_png(OUTPUT_DIR + "/verify_fix_1_2_3_skilltree.png")
	scn.queue_free()
	await get_tree().process_frame

func _capture_traffic_phase1() -> void:
	var scn = preload("res://scenes/minigames/TrafficSafetyGame.tscn").instantiate()
	add_child(scn)
	await get_tree().process_frame
	
	scn.load_minigame({})
	# Simulate matching the first pair
	if scn.shuffled_pairs_a.size() > 0:
		var p1 = scn.shuffled_pairs_a[0]
		scn._on_col_a_pressed(p1["id"])
		scn._on_col_b_pressed(p1["id"])
	
	await get_tree().process_frame
	await get_tree().process_frame
	_save_viewport_png(OUTPUT_DIR + "/verify_fix_4_green_matched.png")
	scn.queue_free()
	await get_tree().process_frame

func _capture_traffic_phase2() -> void:
	var scn = preload("res://scenes/minigames/TrafficSafetyGame.tscn").instantiate()
	add_child(scn)
	await get_tree().process_frame
	
	scn.load_minigame({})
	scn._switch_to_phase2()
	
	await get_tree().process_frame
	await get_tree().process_frame
	_save_viewport_png(OUTPUT_DIR + "/verify_fix_5_phase2_clean.png")
	scn.queue_free()
	await get_tree().process_frame

func _capture_bottom_paw_menu() -> void:
	var scn = preload("res://scenes/IsometricRoomView.tscn").instantiate()
	add_child(scn)
	await get_tree().process_frame
	
	var menu = preload("res://scenes/BottomPawMenu.tscn").instantiate()
	scn.add_child(menu)
	menu.set_view_mode("room")
	menu.set_active_tab("room")
	await get_tree().process_frame
	await get_tree().process_frame
	_save_viewport_png(OUTPUT_DIR + "/verify_bottom_paw_shelf.png")
	
	# Open Food drawer
	menu._toggle_drawer("food")
	await get_tree().create_timer(0.4).timeout
	_save_viewport_png(OUTPUT_DIR + "/verify_bottom_paw_drawer_food.png")
	
	# Open Play drawer
	menu._toggle_drawer("play")
	await get_tree().create_timer(0.4).timeout
	_save_viewport_png(OUTPUT_DIR + "/verify_bottom_paw_drawer_play.png")
	
	scn.queue_free()
	await get_tree().process_frame

func _save_viewport_png(path: String) -> void:
	var img = get_viewport().get_texture().get_image()
	if img:
		var err = img.save_png(path)
		if err == OK:
			print("  [SAVED] -> ", path)
		else:
			printerr("  [ERROR] save_png failed: ", err)
	else:
		printerr("  [ERROR] Viewport image is null")
