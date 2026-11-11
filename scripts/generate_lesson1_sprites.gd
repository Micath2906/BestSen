@tool
extends SceneTree

func _init() -> void:
	print("Generating pixel art sprites for Lesson 1: Preparation Vali & Mother's Advice...")
	
	_create_step1_suitcase()
	_create_step2_med_box()
	_create_step3_labeling()
	_create_step4_ready()
	
	print("Finished generating sprites for Lesson 1!")
	quit()

func _create_step1_suitcase() -> void:
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	# Background warm soft glow
	for x in range(4, 60):
		for y in range(8, 58):
			img.set_pixel(x, y, Color(0.96, 0.92, 0.86, 0.4))
			
	# Vali body (Open suitcase)
	for x in range(8, 56):
		for y in range(12, 54):
			img.set_pixel(x, y, Color(0.28, 0.45, 0.65, 1.0)) # Deep denim blue
	for x in range(10, 54):
		for y in range(14, 52):
			img.set_pixel(x, y, Color(0.92, 0.88, 0.82, 1.0)) # Inner fabric
			
	# 4 Compartments divider lines
	for x in range(10, 54):
		img.set_pixel(x, 32, Color(0.65, 0.55, 0.45, 1.0))
		img.set_pixel(x, 33, Color(0.50, 0.40, 0.30, 1.0))
	for y in range(14, 52):
		img.set_pixel(31, y, Color(0.65, 0.55, 0.45, 1.0))
		img.set_pixel(32, y, Color(0.50, 0.40, 0.30, 1.0))
		
	# Compartment 1 (Top Left: Med kit icon red cross)
	for x in range(16, 26):
		for y in range(18, 28):
			img.set_pixel(x, y, Color(0.95, 0.95, 0.95, 1.0))
	for x in range(19, 23):
		for y in range(19, 27):
			img.set_pixel(x, y, Color(0.90, 0.25, 0.25, 1.0))
	for x in range(17, 25):
		for y in range(21, 25):
			img.set_pixel(x, y, Color(0.90, 0.25, 0.25, 1.0))
			
	# Compartment 2 (Top Right: Documents / Certificate folder)
	for x in range(38, 48):
		for y in range(18, 28):
			img.set_pixel(x, y, Color(0.95, 0.80, 0.20, 1.0)) # Golden folder
	for x in range(40, 46):
		for y in range(20, 26):
			img.set_pixel(x, y, Color(1.0, 1.0, 1.0, 1.0)) # Document sheet
			
	# Compartment 3 (Bottom Left: Clothes)
	for x in range(16, 26):
		for y in range(38, 48):
			img.set_pixel(x, y, Color(0.35, 0.70, 0.55, 1.0)) # Folded shirt
	for x in range(18, 24):
		for y in range(39, 41):
			img.set_pixel(x, y, Color(1.0, 1.0, 1.0, 0.8)) # Collar
			
	# Compartment 4 (Bottom Right: Laptop & Tech)
	for x in range(37, 49):
		for y in range(38, 48):
			img.set_pixel(x, y, Color(0.40, 0.45, 0.50, 1.0)) # Laptop base
	for x in range(39, 47):
		for y in range(40, 45):
			img.set_pixel(x, y, Color(0.40, 0.75, 0.95, 1.0)) # Screen glow
			
	# Suitcase handle
	for x in range(26, 38):
		img.set_pixel(x, 9, Color(0.20, 0.20, 0.20, 1.0))
		img.set_pixel(x, 10, Color(0.20, 0.20, 0.20, 1.0))
	img.set_pixel(26, 11, Color(0.20, 0.20, 0.20, 1.0))
	img.set_pixel(37, 11, Color(0.20, 0.20, 0.20, 1.0))
	
	img.save_png("res://assets/sprites/skills/lesson_01_step_1.png")

func _create_step2_med_box() -> void:
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	# First aid medicine tin box
	for x in range(10, 54):
		for y in range(14, 50):
			img.set_pixel(x, y, Color(0.96, 0.96, 0.98, 1.0)) # White tin box
			
	# Box borders & shadow
	for x in range(10, 54):
		img.set_pixel(x, 14, Color(0.80, 0.82, 0.86, 1.0))
		img.set_pixel(x, 49, Color(0.60, 0.62, 0.66, 1.0))
	for y in range(14, 50):
		img.set_pixel(10, y, Color(0.80, 0.82, 0.86, 1.0))
		img.set_pixel(53, y, Color(0.60, 0.62, 0.66, 1.0))
		
	# Big red medical cross in center
	for x in range(28, 36):
		for y in range(20, 44):
			img.set_pixel(x, y, Color(0.92, 0.22, 0.22, 1.0))
	for x in range(20, 44):
		for y in range(28, 36):
			img.set_pixel(x, y, Color(0.92, 0.22, 0.22, 1.0))
			
	# Medicine blister strip on left
	for x in range(12, 18):
		for y in range(18, 30):
			img.set_pixel(x, y, Color(0.75, 0.88, 0.95, 1.0))
	img.set_pixel(14, 21, Color(0.95, 0.40, 0.40, 1.0))
	img.set_pixel(16, 21, Color(0.95, 0.40, 0.40, 1.0))
	img.set_pixel(14, 26, Color(0.95, 0.40, 0.40, 1.0))
	img.set_pixel(16, 26, Color(0.95, 0.40, 0.40, 1.0))
	
	# Amber medicine bottle on right
	for x in range(46, 52):
		for y in range(22, 34):
			img.set_pixel(x, y, Color(0.78, 0.45, 0.15, 1.0)) # Amber glass
	for x in range(47, 51):
		img.set_pixel(x, 20, Color(0.95, 0.95, 0.95, 1.0)) # White cap
		img.set_pixel(x, 21, Color(0.95, 0.95, 0.95, 1.0))
		
	img.save_png("res://assets/sprites/skills/lesson_01_step_2.png")

func _create_step3_labeling() -> void:
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	# Mother's warm letter & label sticker paper
	for x in range(10, 54):
		for y in range(12, 52):
			img.set_pixel(x, y, Color(1.0, 0.98, 0.92, 1.0)) # Warm parchment note
	for x in range(10, 54):
		img.set_pixel(x, 12, Color(0.90, 0.80, 0.65, 1.0))
		img.set_pixel(x, 51, Color(0.85, 0.72, 0.55, 1.0))
	for y in range(12, 52):
		img.set_pixel(10, y, Color(0.90, 0.80, 0.65, 1.0))
		img.set_pixel(53, y, Color(0.85, 0.72, 0.55, 1.0))
		
	# Red heart seal at top (Mother's love)
	var heart_coords = [
		Vector2i(29, 16), Vector2i(30, 16), Vector2i(33, 16), Vector2i(34, 16),
		Vector2i(28, 17), Vector2i(29, 17), Vector2i(30, 17), Vector2i(31, 17), Vector2i(32, 17), Vector2i(33, 17), Vector2i(34, 17), Vector2i(35, 17),
		Vector2i(29, 18), Vector2i(30, 18), Vector2i(31, 18), Vector2i(32, 18), Vector2i(33, 18), Vector2i(34, 18),
		Vector2i(30, 19), Vector2i(31, 19), Vector2i(32, 19), Vector2i(33, 19),
		Vector2i(31, 20), Vector2i(32, 20)
	]
	for pt in heart_coords:
		img.set_pixel(pt.x, pt.y, Color(0.92, 0.25, 0.35, 1.0))
		
	# Fill in blank box sticker
	for x in range(16, 48):
		for y in range(24, 34):
			img.set_pixel(x, y, Color(0.92, 0.96, 1.0, 1.0))
	for x in range(16, 48):
		img.set_pixel(x, 24, Color(0.35, 0.65, 0.95, 1.0))
		img.set_pixel(x, 33, Color(0.35, 0.65, 0.95, 1.0))
	for y in range(24, 34):
		img.set_pixel(16, y, Color(0.35, 0.65, 0.95, 1.0))
		img.set_pixel(47, y, Color(0.35, 0.65, 0.95, 1.0))
		
	# Pen / marker tip pointing to the blank
	for i in range(10):
		var px = 46 + i
		var py = 36 + i
		if px < 60 and py < 60:
			img.set_pixel(px, py, Color(0.95, 0.60, 0.15, 1.0))
	img.set_pixel(45, 35, Color(0.15, 0.15, 0.15, 1.0)) # Nib
	
	# Note lines representing mother's advice
	for y in [38, 42, 46]:
		for x in range(16, 42):
			img.set_pixel(x, y, Color(0.70, 0.60, 0.50, 0.6))
			
	img.save_png("res://assets/sprites/skills/lesson_01_step_3.png")

func _create_step4_ready() -> void:
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	# Closed shiny suitcase ready to go
	for x in range(12, 52):
		for y in range(16, 54):
			img.set_pixel(x, y, Color(0.28, 0.45, 0.65, 1.0)) # Suitcase body
	# Zipper highlight
	for y in range(16, 54):
		img.set_pixel(31, y, Color(0.95, 0.80, 0.25, 1.0))
		img.set_pixel(32, y, Color(0.85, 0.68, 0.15, 1.0))
		
	# Shiny corners
	for corner_x in [12, 13, 14, 50, 51, 52]:
		for corner_y in [16, 17, 18, 52, 53, 54]:
			img.set_pixel(corner_x, corner_y, Color(0.85, 0.70, 0.20, 1.0))
			
	# Wheels at bottom
	for x in range(16, 22):
		for y in range(54, 58):
			img.set_pixel(x, y, Color(0.20, 0.20, 0.20, 1.0))
	for x in range(42, 48):
		for y in range(54, 58):
			img.set_pixel(x, y, Color(0.20, 0.20, 0.20, 1.0))
			
	# Telescopic handle extended
	for y in range(4, 16):
		img.set_pixel(24, y, Color(0.60, 0.65, 0.70, 1.0))
		img.set_pixel(39, y, Color(0.60, 0.65, 0.70, 1.0))
	for x in range(22, 42):
		img.set_pixel(x, 4, Color(0.20, 0.20, 0.20, 1.0))
		img.set_pixel(x, 5, Color(0.20, 0.20, 0.20, 1.0))
		
	# Green checkmark badge (Ready / 100%)
	for i in range(5):
		img.set_pixel(42 + i, 28 + i, Color(0.18, 0.80, 0.35, 1.0))
		img.set_pixel(42 + i, 29 + i, Color(0.18, 0.80, 0.35, 1.0))
	for i in range(10):
		img.set_pixel(46 + i, 32 - i, Color(0.18, 0.80, 0.35, 1.0))
		img.set_pixel(46 + i, 33 - i, Color(0.18, 0.80, 0.35, 1.0))
		
	img.save_png("res://assets/sprites/skills/lesson_01_step_4.png")
