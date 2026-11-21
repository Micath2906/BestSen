extends SceneTree

func _init():
	_craft_backpack_yellow()
	_craft_helmet_motor()
	_craft_bunny_ears()
	_craft_grad_robe()
	_craft_scarf_volunteer()
	print("ALL COZY COSTUMES CRAFTED!")
	quit()

func _craft_backpack_yellow():
	var img = Image.create(16, 18, false, Image.FORMAT_RGBA8)
	var col_main = Color("#E5A93C")     # Mustard yellow
	var col_dark = Color("#B87820")     # Deep shade
	var col_light = Color("#FBD368")    # Highlight
	var col_strap = Color("#5C3B1E")    # Leather brown
	var col_buckle = Color("#FFF8D0")   # Golden buckle
	var col_outline = Color("#3A220F")  # Dark outline
	
	# Body: x from 2 to 13, y from 4 to 16
	for y in range(4, 17):
		for x in range(2, 14):
			img.set_pixel(x, y, col_main)
	
	# Outline
	for x in range(3, 13):
		img.set_pixel(x, 3, col_outline)
		img.set_pixel(x, 17, col_outline)
	for y in range(4, 17):
		img.set_pixel(1, y, col_outline)
		img.set_pixel(14, y, col_outline)
		
	# Shading bottom and right
	for x in range(2, 14):
		img.set_pixel(x, 16, col_dark)
	for y in range(4, 16):
		img.set_pixel(13, y, col_dark)
		
	# Highlight top and left
	for x in range(3, 12):
		img.set_pixel(x, 4, col_light)
	for y in range(5, 14):
		img.set_pixel(2, y, col_light)
		
	# Front pocket: x: 4..11, y: 9..14
	for y in range(9, 15):
		for x in range(4, 12):
			img.set_pixel(x, y, col_dark)
	for x in range(5, 11):
		img.set_pixel(x, 9, col_light)
		
	# Straps & buckle
	img.set_pixel(6, 11, col_buckle)
	img.set_pixel(9, 11, col_buckle)
	img.set_pixel(6, 12, col_strap)
	img.set_pixel(9, 12, col_strap)
	
	# Top handle loop
	img.set_pixel(7, 2, col_strap)
	img.set_pixel(8, 2, col_strap)
	
	img.save_png("res://assets/sprites/costumes/acc_backpack_yellow.png")
	print("Saved acc_backpack_yellow.png (16x18)")

func _craft_helmet_motor():
	var img = Image.create(22, 14, false, Image.FORMAT_RGBA8)
	var col_shell = Color("#D93829")    # Crimson red
	var col_dark = Color("#9E2218")     # Shadow red
	var col_shine = Color("#FF7D70")    # Highlight
	var col_visor = Color("#2C3E50")    # Dark visor glass
	var col_glint = Color("#85C1E9")    # Visor reflection
	var col_strap = Color("#2C1E14")    # Dark outline / strap
	
	# Dome: y from 1 to 9
	for y in range(2, 10):
		for x in range(3, 19):
			img.set_pixel(x, y, col_shell)
			
	# Top rounded
	for x in range(6, 16):
		img.set_pixel(x, 1, col_shell)
	for x in range(7, 15):
		img.set_pixel(x, 0, col_strap) # top rim
		
	# Outline
	for x in range(3, 6):
		img.set_pixel(x, 1, col_strap)
	for x in range(16, 19):
		img.set_pixel(x, 1, col_strap)
	for y in range(2, 10):
		img.set_pixel(2, y, col_strap)
		img.set_pixel(19, y, col_strap)
		
	# Highlight shine on dome
	for x in range(6, 12):
		img.set_pixel(x, 2, col_shine)
	for x in range(7, 10):
		img.set_pixel(x, 3, col_shine)
		
	# Dark shade on right/back
	for y in range(3, 10):
		img.set_pixel(18, y, col_dark)
		img.set_pixel(17, y, col_dark)
		
	# Visor line at bottom: y = 9..11, x = 4..17
	for x in range(4, 18):
		img.set_pixel(x, 9, col_visor)
		img.set_pixel(x, 10, col_strap)
	# Glint on visor
	img.set_pixel(7, 9, col_glint)
	img.set_pixel(8, 9, col_glint)
	
	img.save_png("res://assets/sprites/costumes/hat_helmet_motor.png")
	print("Saved hat_helmet_motor.png (22x14)")

func _craft_bunny_ears():
	var img = Image.create(22, 16, false, Image.FORMAT_RGBA8)
	var col_cap = Color("#E8DCC4")      # Cream knit
	var col_dark = Color("#C4B498")     # Knit shadow
	var col_pink = Color("#F1948A")     # Inner ear pink
	var col_outline = Color("#4A3B32")  # Warm outline
	
	# Cap base: y = 9..14, x = 3..18
	for y in range(9, 14):
		for x in range(3, 19):
			img.set_pixel(x, y, col_cap)
	for x in range(4, 18):
		img.set_pixel(x, 14, col_outline)
		img.set_pixel(x, 8, col_cap)
	for y in range(9, 14):
		img.set_pixel(2, y, col_outline)
		img.set_pixel(19, y, col_outline)
		
	# Left ear: x = 5..8, y = 1..8
	for y in range(2, 9):
		for x in range(5, 9):
			img.set_pixel(x, y, col_cap)
			if x in [6, 7] and y in range(3, 8):
				img.set_pixel(x, y, col_pink)
	for x in range(6, 8):
		img.set_pixel(x, 1, col_outline)
	for y in range(2, 9):
		img.set_pixel(4, y, col_outline)
		img.set_pixel(9, y, col_outline)
		
	# Right ear: x = 13..16, y = 1..8
	for y in range(2, 9):
		for x in range(13, 17):
			img.set_pixel(x, y, col_cap)
			if x in [14, 15] and y in range(3, 8):
				img.set_pixel(x, y, col_pink)
	for x in range(14, 16):
		img.set_pixel(x, 1, col_outline)
	for y in range(2, 9):
		img.set_pixel(12, y, col_outline)
		img.set_pixel(17, y, col_outline)
		
	img.save_png("res://assets/sprites/costumes/hat_bunny_ears.png")
	print("Saved hat_bunny_ears.png (22x16)")

func _craft_grad_robe():
	var img = Image.create(22, 18, false, Image.FORMAT_RGBA8)
	var col_gown = Color("#1B263B")     # Deep academic navy
	var col_dark = Color("#0D1B2A")     # Deep shadow
	var col_gold = Color("#F4D03F")     # Gold sash
	var col_red = Color("#C0392B")      # Red ribbon
	var col_out = Color("#0A1118")
	
	# Gown torso: y = 2..16, x = 3..18
	for y in range(3, 17):
		for x in range(3, 19):
			img.set_pixel(x, y, col_gown)
	# Bottom hem
	for x in range(2, 20):
		img.set_pixel(x, 17, col_out)
	for y in range(3, 17):
		img.set_pixel(2, y, col_out)
		img.set_pixel(19, y, col_out)
	for x in range(4, 18):
		img.set_pixel(x, 2, col_out)
		
	# Golden sash V-neck
	img.set_pixel(7, 3, col_gold)
	img.set_pixel(8, 4, col_gold)
	img.set_pixel(9, 5, col_gold)
	img.set_pixel(10, 6, col_gold)
	img.set_pixel(11, 6, col_gold)
	img.set_pixel(12, 5, col_gold)
	img.set_pixel(13, 4, col_gold)
	img.set_pixel(14, 3, col_gold)
	
	# Red honor ribbon in center
	img.set_pixel(10, 7, col_red)
	img.set_pixel(11, 7, col_red)
	img.set_pixel(10, 8, col_red)
	img.set_pixel(11, 8, col_red)
	
	# Shading folds
	for y in range(8, 16):
		img.set_pixel(6, y, col_dark)
		img.set_pixel(15, y, col_dark)
		
	img.save_png("res://assets/sprites/costumes/cloth_grad_robe.png")
	print("Saved cloth_grad_robe.png (22x18)")

func _craft_scarf_volunteer():
	var img = Image.create(20, 10, false, Image.FORMAT_RGBA8)
	var col_w = Color("#FDFEFE")        # White
	var col_k = Color("#212F3D")        # Dark navy/black plaid
	var col_out = Color("#17202A")
	
	# Checkered band: y = 2..7, x = 2..17
	for y in range(2, 8):
		for x in range(2, 18):
			if (x + y) % 2 == 0:
				img.set_pixel(x, y, col_w)
			else:
				img.set_pixel(x, y, col_k)
				
	# Outline
	for x in range(2, 18):
		img.set_pixel(x, 1, col_out)
		img.set_pixel(x, 8, col_out)
	img.set_pixel(1, 4, col_out)
	img.set_pixel(18, 4, col_out)
	
	# Little tied knot at center
	img.set_pixel(9, 8, col_w)
	img.set_pixel(10, 8, col_k)
	img.set_pixel(9, 9, col_out)
	img.set_pixel(10, 9, col_out)
	
	img.save_png("res://assets/sprites/costumes/bow_scarf_volunteer.png")
	print("Saved bow_scarf_volunteer.png (20x10)")
