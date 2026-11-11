extends Node

# CaptureAchievementBoardCozy.gd
# Captures high quality visual screenshots of the Cozy Cork Board Achievement Modal
# and the Parchment Scroll Certificate Popup with Wax Seal & Ribbon.

const OUTPUT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d"

func _ready() -> void:
	print("[CaptureAchievementBoardCozy] Starting visual capture...")
	_run_captures()

func _run_captures() -> void:
	# 1. Unlock first 5 lessons in GameManager so we have a mix of unlocked & locked polaroids
	GameManager.completed_lessons = [1, 2, 3, 4, 5]
	
	var modal_scn = preload("res://scenes/AchievementModal.tscn").instantiate()
	add_child(modal_scn)
	modal_scn.custom_minimum_size = Vector2(540, 960)
	modal_scn.size = Vector2(540, 960)
	modal_scn.open()
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport_png(OUTPUT_DIR + "/verify_achievement_cork_board_polaroid_grid.png")
	print("Captured: verify_achievement_cork_board_polaroid_grid.png")
	
	# 2. Open Parchment Scroll Certificate Popup
	modal_scn._show_cert_popup(modal_scn.PUZZLE_SETS[0])
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	
	_save_viewport_png(OUTPUT_DIR + "/verify_certificate_parchment_scroll_wax_seal.png")
	print("Captured: verify_certificate_parchment_scroll_wax_seal.png")
	
	# 3. Open Polaroid Piece Popup
	modal_scn.cert_popup.visible = false
	modal_scn._show_piece_popup(modal_scn.LOOT_PIECES[0], true)
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport_png(OUTPUT_DIR + "/verify_polaroid_piece_detail_popup.png")
	print("Captured: verify_polaroid_piece_detail_popup.png")
	
	modal_scn.queue_free()
	print("[CaptureAchievementBoardCozy] ALL VISUAL CAPTURES FINISHED!")
	get_tree().quit(0)

func _save_viewport_png(path: String) -> void:
	var vp = get_viewport()
	if not vp: return
	var tex = vp.get_texture()
	if not tex: return
	var img = tex.get_image()
	if not img: return
	img.save_png(path)
