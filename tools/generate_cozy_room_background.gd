@tool
extends SceneTree

# Generates a pixel art cozy student room background (540x960)
# Wall: Y = 0 to 450 (Warm cream eggshell with timber accents)
# Baseboard: Y = 445 to 462 (Rich warm walnut wood)
# Floor: Y = 462 to 960 (Warm oak parquet planks with cozy grain)

func _init() -> void:
	print("--- GENERATING COZY ROOM BACKGROUND ---")
	var w = 540
	var h = 960
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	
	# Base Colors
	var col_wall_base = Color.from_string("#F7F1E5", Color.WHITE)
	var col_wall_stripe = Color.from_string("#EDE3D1", Color.WHITE)
	var col_wall_shadow = Color.from_string("#E2D5C0", Color.WHITE)
	
	var col_baseboard_top = Color.from_string("#B8835A", Color.WHITE)
	var col_baseboard_main = Color.from_string("#8D5B36", Color.WHITE)
	var col_baseboard_bot = Color.from_string("#5A361C", Color.WHITE)
	
	var col_floor_1 = Color.from_string("#DEB281", Color.WHITE)
	var col_floor_2 = Color.from_string("#D5A672", Color.WHITE)
	var col_floor_3 = Color.from_string("#CC9A64", Color.WHITE)
	var col_floor_groove = Color.from_string("#A47242", Color.WHITE)
	var col_floor_highlight = Color.from_string("#E7C396", Color.WHITE)
	
	# 1. Fill Wall (Y: 0 to 445)
	for y in range(0, 445):
		for x in range(0, w):
			var c = col_wall_base
			# Vertical paneling pattern (every 20px)
			if x % 20 == 0:
				c = col_wall_stripe
			elif x % 20 == 1:
				c = col_wall_shadow
			# Subtle ambient shadow at room side corners (x < 30 or x > 510)
			if x < 28:
				var fade = float(28 - x) / 28.0
				c = c.lerp(Color.from_string("#D8C9B0", Color.WHITE), fade * 0.45)
			elif x > 512:
				var fade = float(x - 512) / 28.0
				c = c.lerp(Color.from_string("#D8C9B0", Color.WHITE), fade * 0.45)
			# Top shadow under HUD banner (Y: 120 to 140)
			if y > 120 and y < 145:
				var top_fade = float(145 - y) / 25.0
				c = c.lerp(Color.from_string("#E2D4BF", Color.WHITE), top_fade * 0.3)
			img.set_pixel(x, y, c)
			
	# Picture rail / Wall molding line at Y = 160
	for x in range(0, w):
		img.set_pixel(x, 158, col_baseboard_top)
		img.set_pixel(x, 159, col_baseboard_main)
		img.set_pixel(x, 160, col_baseboard_bot)

	# 2. Rich Walnut Wood Baseboard (Y: 445 to 462)
	for y in range(445, 462):
		for x in range(0, w):
			var c = col_baseboard_main
			if y == 445:
				c = Color.from_string("#E2B28B", Color.WHITE) # Top highlight
			elif y == 446:
				c = col_baseboard_top
			elif y >= 459:
				c = col_baseboard_bot # Bottom contact shadow
			elif x % 45 == 0:
				c = col_baseboard_bot # Baseboard vertical section lines
			# Side corner shadows
			if x < 28 or x > 512:
				c = c.darkened(0.12)
			img.set_pixel(x, y, c)

	# 3. Honey-Oak Parquet Floor Planks (Y: 462 to 960)
	var plank_h = 28 # Height of each horizontal plank row
	var plank_w = 90 # Length of each plank brick
	
	for y in range(462, h):
		var row_idx = int((y - 462) / plank_h)
		var y_in_row = (y - 462) % plank_h
		var row_offset = (row_idx * 45) % plank_w # Staggered brick pattern
		
		for x in range(0, w):
			var col_idx = int((x + row_offset) / plank_w)
			var x_in_plank = (x + row_offset) % plank_w
			
			# Pick plank tone based on (row_idx, col_idx) pseudo-random
			var tone_seed = (row_idx * 7 + col_idx * 13) % 3
			var base_c = col_floor_1
			if tone_seed == 1:
				base_c = col_floor_2
			elif tone_seed == 2:
				base_c = col_floor_3
				
			# Perspective depth: rows further down (closer to camera) are slightly warmer & lighter
			var depth_factor = float(y - 462) / float(h - 462)
			base_c = base_c.lerp(Color.from_string("#E4BA8A", Color.WHITE), depth_factor * 0.18)
			
			# Horizontal groove between plank rows
			if y_in_row == 0:
				base_c = col_floor_groove # Top dark groove line
			elif y_in_row == 1:
				base_c = col_floor_highlight # Highlight bevel on top edge of plank
			elif y_in_row == plank_h - 1:
				base_c = col_floor_groove.lerp(base_c, 0.4)
				
			# Vertical joint between planks
			if x_in_plank == 0:
				base_c = col_floor_groove
			elif x_in_plank == 1:
				base_c = col_floor_highlight.lerp(base_c, 0.5)
				
			# Subtle natural wood grain lines (every 6px vertically)
			if y_in_row % 7 == 3:
				base_c = base_c.darkened(0.04)
			elif y_in_row % 7 == 5:
				base_c = base_c.lightened(0.03)
				
			# Room side ambient occlusion shadows (vignette at walls)
			if x < 28:
				var fade = float(28 - x) / 28.0
				base_c = base_c.lerp(Color.from_string("#A87A4D", Color.WHITE), fade * 0.4)
			elif x > 512:
				var fade = float(x - 512) / 28.0
				base_c = base_c.lerp(Color.from_string("#A87A4D", Color.WHITE), fade * 0.4)
				
			img.set_pixel(x, y, base_c)

	var save_path = "D:/BestSen/assets/sprites/room_decor/cozy_student_room_bg.png"
	img.save_png(save_path)
	print("SUCCESS: Saved cozy room background to ", save_path)
	
	# Also copy to worktree
	var wt_path = "assets/sprites/room_decor/cozy_student_room_bg.png"
	img.save_png(wt_path)
	print("SUCCESS: Saved cozy room background to worktree ", wt_path)
	
	quit(0)
