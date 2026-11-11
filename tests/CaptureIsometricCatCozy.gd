extends Node

const OUTPUT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d"

func _ready() -> void:
	print("[CaptureIsometricCatCozy] Starting visual capture...")
	_run_captures()

func _run_captures() -> void:
	# 1. Capture Room with IsometricCat showing Pixel Shadow and Chat Bubble
	var room_scn = preload("res://scenes/IsometricRoomView.tscn").instantiate()
	add_child(room_scn)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var cat = room_scn.get_node_or_null("World/IsometricCat")
	if cat:
		cat.show_dialogue("Phòng trọ 2.5D ấm cúng quá Sen ơi! 🐾", 10.0)
	
	await get_tree().process_frame
	await get_tree().process_frame
	_save_viewport_png(OUTPUT_DIR + "/verify_isocat_shadow_and_bubble.png")
	
	# 2. Capture Petting Cat with Squash & Stretch and Floating Hearts
	if cat:
		cat.handle_touch(-20.0) # Pet head/ear
	
	await get_tree().create_timer(0.2).timeout
	await get_tree().process_frame
	_save_viewport_png(OUTPUT_DIR + "/verify_isocat_petting_hearts.png")
	
	room_scn.queue_free()
	await get_tree().process_frame
	print("[CaptureIsometricCatCozy] FINISHED CAPTURING!")
	get_tree().quit(0)

func _save_viewport_png(path: String) -> void:
	var vp = get_viewport()
	if not vp:
		return
	var tex = vp.get_texture()
	if not tex:
		return
	var img = tex.get_image()
	if not img:
		return
	var err = img.save_png(path)
	if err == OK:
		print("  [SCREENSHOT SAVED] -> ", path)
	else:
		printerr("  [ERROR SAVING SCREENSHOT]: ", err)
