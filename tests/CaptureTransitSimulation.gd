extends Node

const OUTPUT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d"

func _ready() -> void:
	print("[CaptureTransitSimulation] Starting visual captures...")
	_run()

func _run() -> void:
	var scn = preload("res://scenes/minigames/TransitSimulation.tscn")
	var sim = scn.instantiate()
	add_child(sim)
	sim.custom_minimum_size = Vector2(540, 960)
	sim.size = Vector2(540, 960)
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	
	# 1. Level 1: Stop bus 53 at curb, open NFC panel with radial ring
	sim.load_level(1)
	sim.current_bus_route = 53
	sim.bus_position_x = 420.0
	sim._handle_bus_wave_success()
	sim.is_nfc_card_held = true
	sim.nfc_dwell_time = 0.42
	if sim.nfc_radial_ring:
		sim.nfc_radial_ring.progress = 0.70
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_transit_lvl1_bus_wave_nfc.png")
	print("Captured: verify_transit_lvl1_bus_wave_nfc.png")
	
	# 2. Level 2: Metro with backpack in front (48px) and wooden slider
	sim.load_level(2)
	sim._on_toggle_backpack_pressed() # Toggle to 48px
	sim.balance_slider_value = 54.0
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_transit_lvl2_metro_inertia.png")
	print("Captured: verify_transit_lvl2_metro_inertia.png")
	
	# 3. Level 3: Motorbike Diagnostic with headlight beam on and 12.6V
	sim.load_level(3)
	sim._on_test_starter_pressed()
	sim._on_inspect_exhaust_pressed()
	sim._on_inspect_tire_pressed()
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_transit_lvl3_motorbike_diagnostic.png")
	print("Captured: verify_transit_lvl3_motorbike_diagnostic.png")
	
	# 4. Victory Polaroid Transit Pass
	sim._show_transit_victory()
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_transit_victory_polaroid.png")
	print("Captured: verify_transit_victory_polaroid.png")
	
	sim.queue_free()
	print("[CaptureTransitSimulation] ALL CAPTURES FINISHED!")
	get_tree().quit(0)

func _save_viewport(path: String) -> void:
	var vp = get_viewport()
	if not vp: return
	var tex = vp.get_texture()
	if not tex: return
	var img = tex.get_image()
	if not img: return
	img.save_png(path)
