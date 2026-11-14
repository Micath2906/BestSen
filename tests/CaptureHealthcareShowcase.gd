extends Node

const OUTPUT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d"

func _ready() -> void:
	print("[CaptureHealthcareShowcase] Starting visual captures...")
	_run()

func _run() -> void:
	var scn = preload("res://scenes/minigames/HealthcareWellnessSimulation.tscn")
	var sim = scn.instantiate()
	add_child(sim)
	sim.custom_minimum_size = Vector2(540, 960)
	sim.size = Vector2(540, 960)
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	
	# 1. Level 1: First Aid Burn Cooling & Night Fever Dosage
	sim.load_level(1)
	sim._on_water_cool_pressed()
	sim._on_cut_paracetamol_pressed()
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_healthcare_lvl1_first_aid_burn_dosage.png")
	print("Captured: verify_healthcare_lvl1_first_aid_burn_dosage.png")
	
	# 2. Level 2: 5-Station BHYT Top-down Map & Clipboard Document Inventory
	sim.load_level(2)
	sim._on_station_action_pressed() # Station 1 -> 2
	sim._on_reject_tout_pressed()    # Reject tout
	sim._on_station_action_pressed() # Station 2 -> 3 (Doctor with stethoscope)
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_healthcare_lvl2_bhyt_topdown_map_docs.png")
	print("Captured: verify_healthcare_lvl2_bhyt_topdown_map_docs.png")
	
	# 3. Level 3: Circadian Rhythm, Caffeine Vignette & Cozy Breathing With Mochi
	sim.load_level(3)
	sim._on_drink_coffee_pressed()
	sim._on_drink_coffee_pressed() # Triggers caffeine jitter + vignette
	sim._on_start_breathing_pressed()
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_healthcare_lvl3_caffeine_vignette_breathing.png")
	print("Captured: verify_healthcare_lvl3_caffeine_vignette_breathing.png")
	
	# 4. Victory Polaroid Certificate
	sim._show_healthcare_victory()
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_healthcare_victory_polaroid.png")
	print("Captured: verify_healthcare_victory_polaroid.png")
	
	sim.queue_free()
	print("[CaptureHealthcareShowcase] ALL CAPTURES FINISHED!")
	get_tree().quit(0)

func _save_viewport(path: String) -> void:
	var vp = get_viewport()
	if not vp: return
	var tex = vp.get_texture()
	if not tex: return
	var img = tex.get_image()
	if not img: return
	img.save_png(path)
