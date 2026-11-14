extends Node

const OUTPUT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d"

func _ready() -> void:
	print("[CaptureHousingShowcase] Starting visual captures...")
	_run()

func _run() -> void:
	var scn = preload("res://scenes/minigames/HousingLegalSimulation.tscn")
	var sim = scn.instantiate()
	add_child(sim)
	sim.custom_minimum_size = Vector2(540, 960)
	sim.size = Vector2(540, 960)
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	
	# 1. Level 1: Room Defect Inspector with 5 Hotspots & Magnifier
	sim.load_level(1)
	sim._on_water_tap_pressed()
	sim._on_ceiling_pressed()
	sim._on_switch_meter_pressed()
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_housing_lvl1_room_defect_magnifier.png")
	print("Captured: verify_housing_lvl1_room_defect_magnifier.png")
	
	# 2. Level 2: Papers Please Dual Contracts & Wax Seal
	sim.load_level(2)
	sim._on_correct_flag_pressed(1)
	sim._on_correct_flag_pressed(2)
	sim._on_correct_flag_pressed(3)
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_housing_lvl2_papers_please_contract.png")
	print("Captured: verify_housing_lvl2_papers_please_contract.png")
	
	# 3. Level 3: Circuit Breaker Overload & Electricity Bill Calculator
	sim.load_level(3)
	sim._on_toggle_cooker()
	sim._on_toggle_kettle() # Triggers overload & blackout
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_housing_lvl3_blackout_power_bill.png")
	print("Captured: verify_housing_lvl3_blackout_power_bill.png")
	
	# 4. Victory Polaroid Certificate
	sim._show_housing_victory()
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	_save_viewport(OUTPUT_DIR + "/verify_housing_victory_polaroid.png")
	print("Captured: verify_housing_victory_polaroid.png")
	
	sim.queue_free()
	print("[CaptureHousingShowcase] ALL CAPTURES FINISHED!")
	get_tree().quit(0)

func _save_viewport(path: String) -> void:
	var vp = get_viewport()
	if not vp: return
	var tex = vp.get_texture()
	if not tex: return
	var img = tex.get_image()
	if not img: return
	img.save_png(path)
