extends Node

const OUTPUT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d"

func _ready() -> void:
	print("[CaptureHouseAndDressCozy] Starting visual captures...")
	_run_captures()

func _run_captures() -> void:
	var view_scn = preload("res://scenes/HouseAndDressView.tscn").instantiate()
	add_child(view_scn)
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Mặc đồ đẹp cho Boss
	view_scn.preview_costumes["clothes"] = "c_hoodie_student"
	view_scn.preview_costumes["hats"] = "c_hat_cap"
	view_scn.preview_costumes["bows"] = "c_bow_red"
	view_scn.preview_costumes["accessories"] = "c_acc_glasses"
	view_scn._render_stage_cat()
	view_scn._render_dress_items()
	
	await get_tree().create_timer(0.3).timeout
	await get_tree().process_frame
	_save_viewport_png(OUTPUT_DIR + "/verify_house_dress_stage_and_clipboard.png")
	
	# Chuyển sang decor mode
	view_scn.switch_mode("decor")
	await get_tree().create_timer(0.3).timeout
	await get_tree().process_frame
	_save_viewport_png(OUTPUT_DIR + "/verify_house_decor_chest_and_stars.png")
	
	view_scn.queue_free()
	await get_tree().process_frame
	print("[CaptureHouseAndDressCozy] ALL CAPTURES COMPLETE!")
	get_tree().quit(0)

func _save_viewport_png(path: String) -> void:
	var vp = get_viewport()
	if not vp: return
	var tex = vp.get_texture()
	if not tex: return
	var img = tex.get_image()
	if not img: return
	var err = img.save_png(path)
	if err == OK:
		print("  [SAVED SCREENSHOT] -> ", path)
	else:
		printerr("  [ERROR SAVING SCREENSHOT]: ", err)
