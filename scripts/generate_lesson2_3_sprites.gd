@tool
extends SceneTree

func _init() -> void:
	print("Generating pixel art sprites for Lesson 2 (Hospital Choice) & Lesson 3 (Self Diagnosis)...")
	
	_create_lesson2_sprites()
	_create_lesson3_sprites()
	
	print("Finished generating sprites for Lesson 2 & 3!")
	quit()

func _create_lesson2_sprites() -> void:
	# Step 1: Sick roommate in bed / injured
	var img1 = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img1.fill(Color(0, 0, 0, 0))
	for x in range(8, 56):
		for y in range(20, 52):
			img1.set_pixel(x, y, Color(0.92, 0.94, 0.96, 1.0)) # Bed sheet
	# Pillow
	for x in range(12, 24):
		for y in range(22, 34):
			img1.set_pixel(x, y, Color(1.0, 1.0, 1.0, 1.0))
	# Sick cat head with bandage / thermometer
	for x in range(14, 22):
		for y in range(24, 32):
			img1.set_pixel(x, y, Color(0.95, 0.70, 0.40, 1.0)) # Orange cat
	# Swollen leg with ice pack
	for x in range(40, 50):
		for y in range(36, 46):
			img1.set_pixel(x, y, Color(0.40, 0.75, 0.95, 1.0)) # Ice pack
	img1.save_png("res://assets/sprites/skills/lesson_02_step_1.png")
	
	# Step 2: Medical Specialty icon (Stethoscope & Cross)
	var img2 = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img2.fill(Color(0, 0, 0, 0))
	# Circular badge
	for x in range(10, 54):
		for y in range(10, 54):
			if (Vector2(x-32, y-32).length() <= 22):
				img2.set_pixel(x, y, Color(0.20, 0.65, 0.85, 1.0))
	# Red cross in white square
	for x in range(24, 40):
		for y in range(24, 40):
			img2.set_pixel(x, y, Color(1.0, 1.0, 1.0, 1.0))
	for x in range(29, 35):
		for y in range(26, 38):
			img2.set_pixel(x, y, Color(0.90, 0.20, 0.20, 1.0))
	for x in range(26, 38):
		for y in range(29, 35):
			img2.set_pixel(x, y, Color(0.90, 0.20, 0.20, 1.0))
	img2.save_png("res://assets/sprites/skills/lesson_02_step_2.png")
	
	# Step 3: Hospital building with emergency ambulance
	var img3 = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img3.fill(Color(0, 0, 0, 0))
	# Hospital building
	for x in range(14, 50):
		for y in range(16, 52):
			img3.set_pixel(x, y, Color(0.95, 0.95, 0.97, 1.0))
	# Windows
	for row in range(3):
		for col in range(3):
			var wx = 18 + col * 10
			var wy = 22 + row * 8
			for px in range(wx, wx + 6):
				for py in range(wy, wy + 5):
					img3.set_pixel(px, py, Color(0.35, 0.65, 0.90, 1.0))
	# Hospital red cross on top
	for x in range(29, 35):
		for y in range(10, 18):
			img3.set_pixel(x, y, Color(0.90, 0.20, 0.20, 1.0))
	for x in range(26, 38):
		for y in range(12, 16):
			img3.set_pixel(x, y, Color(0.90, 0.20, 0.20, 1.0))
	img3.save_png("res://assets/sprites/skills/lesson_02_step_3.png")
	
	# Step 4: Roommate recovered & high five
	var img4 = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img4.fill(Color(0, 0, 0, 0))
	# Golden laurel wreath / heart
	for x in range(8, 56):
		for y in range(8, 56):
			img4.set_pixel(x, y, Color(0.98, 0.96, 0.90, 0.5))
	# Two happy cats side by side
	for x in range(18, 28):
		for y in range(24, 44):
			img4.set_pixel(x, y, Color(0.95, 0.65, 0.35, 1.0)) # Cat 1
	for x in range(36, 46):
		for y in range(24, 44):
			img4.set_pixel(x, y, Color(0.40, 0.70, 0.95, 1.0)) # Cat 2
	# Green medical checkmark in center
	for i in range(5):
		img4.set_pixel(28 + i, 28 + i, Color(0.15, 0.80, 0.35, 1.0))
	for i in range(10):
		img4.set_pixel(32 + i, 32 - i, Color(0.15, 0.80, 0.35, 1.0))
	img4.save_png("res://assets/sprites/skills/lesson_02_step_4.png")

func _create_lesson3_sprites() -> void:
	# Step 1: Diagnostic tool (Digital thermometer measuring 38.8C)
	var img1 = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img1.fill(Color(0, 0, 0, 0))
	# Thermometer body
	for x in range(16, 48):
		for y in range(26, 38):
			img1.set_pixel(x, y, Color(0.96, 0.96, 0.98, 1.0))
	# Metal probe tip
	for x in range(8, 16):
		for y in range(28, 36):
			img1.set_pixel(x, y, Color(0.75, 0.80, 0.85, 1.0))
	# Digital LCD screen showing red glow (Fever)
	for x in range(26, 42):
		for y in range(29, 35):
			img1.set_pixel(x, y, Color(0.95, 0.25, 0.25, 1.0))
	img1.save_png("res://assets/sprites/skills/lesson_03_step_1.png")
	
	# Step 2: Diagnostic Information Sheet (Bảng thống kê đo đạc)
	var img2 = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img2.fill(Color(0, 0, 0, 0))
	# Clipboard
	for x in range(12, 52):
		for y in range(10, 54):
			img2.set_pixel(x, y, Color(0.60, 0.40, 0.25, 1.0)) # Brown board
	# Paper sheet
	for x in range(15, 49):
		for y in range(14, 51):
			img2.set_pixel(x, y, Color(1.0, 1.0, 1.0, 1.0)) # White paper
	# Clip top
	for x in range(26, 38):
		for y in range(8, 15):
			img2.set_pixel(x, y, Color(0.70, 0.75, 0.80, 1.0)) # Silver clip
	# Lines representing test metrics
	for ly in [20, 26, 32, 38, 44]:
		for lx in range(20, 44):
			img2.set_pixel(lx, ly, Color(0.35, 0.45, 0.60, 0.8))
	img2.save_png("res://assets/sprites/skills/lesson_03_step_2.png")
	
	# Step 3: Targeted medicine bottle (Right medicine choice)
	var img3 = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img3.fill(Color(0, 0, 0, 0))
	# Medicine blister strip & amber bottle
	for x in range(12, 32):
		for y in range(18, 48):
			img3.set_pixel(x, y, Color(0.85, 0.90, 0.95, 1.0)) # Foil blister
	# Red/white pills on blister
	for bx in [16, 26]:
		for by in [24, 34, 42]:
			img3.set_pixel(bx, by, Color(0.95, 0.25, 0.25, 1.0))
			img3.set_pixel(bx + 1, by, Color(1.0, 1.0, 1.0, 1.0))
	# Amber bottle on right
	for x in range(38, 52):
		for y in range(22, 48):
			img3.set_pixel(x, y, Color(0.78, 0.45, 0.15, 1.0))
	for x in range(40, 50):
		for y in range(18, 22):
			img3.set_pixel(x, y, Color(0.95, 0.95, 0.95, 1.0)) # Cap
	img3.save_png("res://assets/sprites/skills/lesson_03_step_3.png")
	
	# Step 4: Health 100% recovered badge
	var img4 = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img4.fill(Color(0, 0, 0, 0))
	# Golden glowing shield
	for x in range(12, 52):
		for y in range(10, 54):
			if (Vector2(x-32, y-30).length() <= 20):
				img4.set_pixel(x, y, Color(0.95, 0.75, 0.20, 1.0))
	# Heart in center
	for x in range(24, 40):
		for y in range(22, 38):
			img4.set_pixel(x, y, Color(0.90, 0.20, 0.30, 1.0))
	img4.save_png("res://assets/sprites/skills/lesson_03_step_4.png")
