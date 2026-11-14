extends Node

const OUTPUT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d"

func _ready() -> void:
	print("[CaptureFinanceShowcase] Starting visual captures...")
	_run()

func _run() -> void:
	var scn = preload("res://scenes/minigames/FinanceSurvivalSimulation.tscn")
	var sim = scn.instantiate()
	add_child(sim)
	sim.custom_minimum_size = Vector2(540, 960)
	sim.size = Vector2(540, 960)
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	
	# 1. Level 1: Supermarket Shelf Scanner with 9-patch & Unit-Price Flip
	sim.load_level(1)
	sim._on_flip_product("rice_small")
	sim._on_flip_product("rice_big")
	sim._on_toggle_cart_item("rice_big")
	sim._on_toggle_cart_item("pate_mochi")
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_finance_lvl1_shelf_scanner.png")
	print("Captured: verify_finance_lvl1_shelf_scanner.png")
	
	# 2. Level 2: 30-Day Cashflow & 24h Impulse Cooling-off Box
	sim.load_level(2)
	for i in range(11):
		sim._on_next_day_pressed()
	# Day 12: Flash Sale active
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_finance_lvl2_cashflow_cooling_box.png")
	print("Captured: verify_finance_lvl2_cashflow_cooling_box.png")
	
	# 3. Level 3: Smartphone SMS Scam Forensics & Text Hotspots
	sim.load_level(3)
	sim._on_select_scam("bank_phishing")
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_finance_lvl3_scam_hotspots.png")
	print("Captured: verify_finance_lvl3_scam_hotspots.png")
	
	# 4. Victory Polaroid Certificate
	sim._show_finance_victory()
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_finance_victory_polaroid.png")
	print("Captured: verify_finance_victory_polaroid.png")
	
	sim.queue_free()
	print("[CaptureFinanceShowcase] ALL CAPTURES FINISHED!")
	get_tree().quit(0)

func _save_viewport(path: String) -> void:
	var vp = get_viewport()
	if not vp: return
	var tex = vp.get_texture()
	if not tex: return
	var img = tex.get_image()
	if not img: return
	img.save_png(path)
