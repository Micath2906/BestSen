@tool
extends SceneTree

func _init():
	print("--- GENERATING COZY ACHIEVEMENT BOARD ASSETS ---")
	var out_dir = "res://assets/UI/CatUIPaid/slices/cozy_achievements/"
	
	_generate_cork_board(out_dir + "cork_board_9patch.png", out_dir + "cork_board_9patch.tres")
	_generate_pin_tack(out_dir + "pin_tack_red.png", out_dir + "pin_tack_red.tres")
	_generate_polaroid_card(out_dir + "polaroid_card_9patch.png", out_dir + "polaroid_card_9patch.tres")
	_generate_locked_qmark(out_dir + "polaroid_locked_wood_qmark.png", out_dir + "polaroid_locked_wood_qmark.tres")
	_generate_parchment_scroll(out_dir + "parchment_scroll_cert_9patch.png", out_dir + "parchment_scroll_cert_9patch.tres")
	_generate_wax_seal(out_dir + "wax_seal_royal_gold.png", out_dir + "wax_seal_royal_gold.tres")
	_generate_ribbon(out_dir + "ribbon_red_gold.png", out_dir + "ribbon_red_gold.tres")
	
	print("--- ALL COZY ACHIEVEMENT ASSETS GENERATED! ---")
	quit(0)

func _generate_cork_board(png_path: String, tres_path: String):
	var w = 80
	var h = 80
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	
	var frame_thick = 14
	var wood_dark = Color("#2C180C")
	var wood_mid = Color("#5C361A")
	var wood_light = Color("#82502A")
	var wood_hi = Color("#A86E3E")
	
	var cork_base = Color("#C49A6C")
	var cork_dark1 = Color("#B08252")
	var cork_dark2 = Color("#99693B")
	var cork_light = Color("#DCB384")
	
	for y in range(h):
		for x in range(w):
			var d_left = x
			var d_right = w - 1 - x
			var d_top = y
			var d_bot = h - 1 - y
			var edge_dist = min(d_left, min(d_right, min(d_top, d_bot)))
			
			if edge_dist < 2:
				img.set_pixel(x, y, wood_dark)
			elif edge_dist < 4:
				img.set_pixel(x, y, wood_hi if (x + y) % 3 != 0 else wood_mid)
			elif edge_dist < frame_thick - 3:
				var grain = (x * 3 + y * 7) % 7
				if grain == 0:
					img.set_pixel(x, y, wood_hi)
				elif grain < 4:
					img.set_pixel(x, y, wood_mid)
				else:
					img.set_pixel(x, y, wood_light)
			elif edge_dist < frame_thick:
				# Inner bevel shadow
				img.set_pixel(x, y, wood_dark)
			else:
				# Cork board center with organic grains
				var noise_val = (x * 19 + y * 37 + (x ^ y) * 11) % 100
				if noise_val < 15:
					img.set_pixel(x, y, cork_dark2)
				elif noise_val < 35:
					img.set_pixel(x, y, cork_dark1)
				elif noise_val > 82:
					img.set_pixel(x, y, cork_light)
				else:
					img.set_pixel(x, y, cork_base)
					
	img.save_png(png_path)
	_save_texture_resource(png_path, tres_path)
	print("Generated: %s" % png_path)

func _generate_pin_tack(png_path: String, tres_path: String):
	var sz = 24
	var img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var center = Vector2(12, 10)
	var radius = 6.5
	
	# Pin needle shadow
	for p in [Vector2(14, 16), Vector2(15, 17), Vector2(16, 18)]:
		img.set_pixel(p.x, p.y, Color(0, 0, 0, 0.35))
		
	# Needle
	for p in [Vector2(11, 14), Vector2(12, 16), Vector2(13, 18)]:
		img.set_pixel(p.x, p.y, Color("#A0A5B0"))
		
	# Pin head
	for y in range(sz):
		for x in range(sz):
			var dist = Vector2(x, y).distance_to(center)
			if dist <= radius:
				var shadow_dist = Vector2(x, y).distance_to(Vector2(9, 8))
				if shadow_dist < 2.0:
					img.set_pixel(x, y, Color("#FFAAAA")) # Highlight
				elif shadow_dist < 4.0:
					img.set_pixel(x, y, Color("#F03D3D")) # Primary red
				elif dist <= radius - 0.8:
					img.set_pixel(x, y, Color("#C21E1E")) # Mid tone
				else:
					img.set_pixel(x, y, Color("#6B0808")) # Rim / shadow
					
	img.save_png(png_path)
	_save_texture_resource(png_path, tres_path)
	print("Generated: %s" % png_path)

func _generate_polaroid_card(png_path: String, tres_path: String):
	var w = 54
	var h = 64
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var paper_white = Color("#FCFAF5")
	var paper_shade = Color("#EBE4D5")
	var border_col = Color("#D3CBB9")
	var drop_shadow = Color(0, 0, 0, 0.22)
	
	# Drop shadow
	for y in range(4, h):
		for x in range(4, w):
			img.set_pixel(x, y, drop_shadow)
			
	# Paper card (0..w-4, 0..h-4)
	for y in range(h - 4):
		for x in range(w - 4):
			if x == 0 or y == 0 or x == w - 5 or y == h - 5:
				img.set_pixel(x, y, border_col)
			elif y > h - 14:
				# Bottom margin area for caption
				img.set_pixel(x, y, paper_shade if y == h - 6 else paper_white)
			else:
				img.set_pixel(x, y, paper_white)
				
	# Top red pin tack
	for py in range(1, 5):
		for px in range(w/2 - 4, w/2):
			img.set_pixel(px, py, Color("#D62828"))
	img.set_pixel(w/2 - 3, 2, Color("#FFAAAA"))
	
	img.save_png(png_path)
	_save_texture_resource(png_path, tres_path)
	print("Generated: %s" % png_path)

func _generate_locked_qmark(png_path: String, tres_path: String):
	var sz = 40
	var img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
	
	var bg_wood = Color("#3A312A")
	var bg_inner = Color("#2D2520")
	var wood_q_light = Color("#DEB887")
	var wood_q_mid = Color("#AF7D49")
	var wood_q_dark = Color("#5A391E")
	
	for y in range(sz):
		for x in range(sz):
			if x < 2 or y < 2 or x >= sz - 2 or y >= sz - 2:
				img.set_pixel(x, y, bg_wood)
			else:
				img.set_pixel(x, y, bg_inner)
				
	# Draw carved '?' icon
	var qmark_coords = [
		# Arc top
		Vector2(17, 10), Vector2(18, 10), Vector2(19, 10), Vector2(20, 10), Vector2(21, 10), Vector2(22, 10),
		Vector2(15, 11), Vector2(16, 11), Vector2(23, 11), Vector2(24, 11),
		Vector2(14, 12), Vector2(15, 12), Vector2(24, 12), Vector2(25, 12),
		Vector2(14, 13), Vector2(15, 13), Vector2(24, 13), Vector2(25, 13),
		Vector2(23, 14), Vector2(24, 14),
		Vector2(21, 15), Vector2(22, 15), Vector2(23, 15),
		Vector2(19, 16), Vector2(20, 16), Vector2(21, 16),
		# Neck
		Vector2(19, 17), Vector2(20, 17),
		Vector2(19, 18), Vector2(20, 18),
		Vector2(19, 19), Vector2(20, 19),
		Vector2(19, 20), Vector2(20, 20),
		Vector2(19, 21), Vector2(20, 21),
		# Dot
		Vector2(19, 25), Vector2(20, 25),
		Vector2(19, 26), Vector2(20, 26),
		Vector2(19, 27), Vector2(20, 27)
	]
	
	for coord in qmark_coords:
		img.set_pixel(coord.x, coord.y, wood_q_mid)
		if coord.y <= 13 or coord.x <= 18:
			img.set_pixel(coord.x, coord.y, wood_q_light)
			
	# Carved shadow below qmark
	for coord in qmark_coords:
		var sy = coord.y + 1
		if sy < sz and not Vector2(coord.x, sy) in qmark_coords:
			img.set_pixel(coord.x, sy, wood_q_dark)
			
	img.save_png(png_path)
	_save_texture_resource(png_path, tres_path)
	print("Generated: %s" % png_path)

func _generate_parchment_scroll(png_path: String, tres_path: String):
	var w = 84
	var h = 84
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	
	var paper_cream = Color("#FFFDF8")
	var paper_aged = Color("#F8F0DC")
	var paper_gold_border = Color("#D4AF37")
	var paper_curl_dark = Color("#7A5424")
	var paper_curl_light = Color("#E4C286")
	var scroll_edge = Color("#3B220E")
	
	for y in range(h):
		for x in range(w):
			# Scroll curl at top (0..8) and bottom (h-9..h-1)
			if y < 8 or y >= h - 8:
				if x == 0 or x == w - 1 or y == 0 or y == h - 1:
					img.set_pixel(x, y, scroll_edge)
				elif y == 2 or y == 3 or y == h - 3 or y == h - 4:
					img.set_pixel(x, y, paper_curl_light)
				elif y == 5 or y == 6 or y == h - 6 or y == h - 7:
					img.set_pixel(x, y, paper_curl_dark)
				else:
					img.set_pixel(x, y, paper_aged)
			else:
				# Body of scroll
				if x == 0 or x == w - 1:
					img.set_pixel(x, y, scroll_edge)
				elif x < 5 or x >= w - 5:
					img.set_pixel(x, y, paper_aged)
				elif x == 5 or x == w - 6 or y == 9 or y == h - 10:
					img.set_pixel(x, y, paper_gold_border) # Golden border inlay
				else:
					# Parchment texture
					var dist_edge = min(x, min(w - 1 - x, min(y, h - 1 - y)))
					if dist_edge < 12:
						img.set_pixel(x, y, paper_aged)
					else:
						img.set_pixel(x, y, paper_cream)
						
	img.save_png(png_path)
	_save_texture_resource(png_path, tres_path)
	print("Generated: %s" % png_path)

func _generate_wax_seal(png_path: String, tres_path: String):
	var sz = 52
	var img = Image.create(sz, sz, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var center = Vector2(sz / 2.0, sz / 2.0)
	var base_radius = 21.0
	
	var gold_bright = Color("#FFE57F")
	var gold_mid = Color("#FFC107")
	var gold_dark = Color("#C67C00")
	var gold_deep = Color("#854C00")
	var gold_hi = Color("#FFF9C4")
	
	# Scalloped melted wax perimeter
	for y in range(sz):
		for x in range(sz):
			var v = Vector2(x, y) - center
			var dist = v.length()
			var angle = atan2(v.y, v.x)
			var scallop = sin(angle * 10.0) * 2.2
			var eff_r = base_radius + scallop
			
			if dist <= eff_r:
				if dist > eff_r - 2.0:
					img.set_pixel(x, y, gold_deep)
				elif dist > eff_r - 4.5:
					img.set_pixel(x, y, gold_dark)
				elif dist > 14.0 and dist <= 16.5:
					# Inner relief ring
					img.set_pixel(x, y, gold_bright)
				elif dist > 12.0 and dist <= 14.0:
					img.set_pixel(x, y, gold_deep)
				else:
					# Inner wax bed
					var d_hi = Vector2(x, y).distance_to(Vector2(20, 18))
					if d_hi < 8.0:
						img.set_pixel(x, y, gold_bright)
					else:
						img.set_pixel(x, y, gold_mid)
						
	# Draw Crown + Cat Paw emblem in the center (in gold relief)
	var emblem_coords = [
		# Crown peaks
		Vector2(20, 17), Vector2(26, 15), Vector2(32, 17),
		Vector2(20, 18), Vector2(23, 18), Vector2(26, 18), Vector2(29, 18), Vector2(32, 18),
		Vector2(21, 19), Vector2(22, 19), Vector2(23, 19), Vector2(24, 19), Vector2(25, 19),
		Vector2(26, 19), Vector2(27, 19), Vector2(28, 19), Vector2(29, 19), Vector2(30, 19), Vector2(31, 19),
		# Paw Main Pad
		Vector2(24, 28), Vector2(25, 28), Vector2(26, 28), Vector2(27, 28),
		Vector2(23, 29), Vector2(24, 29), Vector2(25, 29), Vector2(26, 29), Vector2(27, 29), Vector2(28, 29),
		Vector2(23, 30), Vector2(24, 30), Vector2(25, 30), Vector2(26, 30), Vector2(27, 30), Vector2(28, 30),
		Vector2(24, 31), Vector2(25, 31), Vector2(26, 31), Vector2(27, 31),
		# 4 Toe Beans
		Vector2(21, 25), Vector2(22, 25), Vector2(21, 26), Vector2(22, 26),
		Vector2(24, 23), Vector2(25, 23), Vector2(24, 24), Vector2(25, 24),
		Vector2(27, 23), Vector2(28, 23), Vector2(27, 24), Vector2(28, 24),
		Vector2(30, 25), Vector2(31, 25), Vector2(30, 26), Vector2(31, 26)
	]
	
	for c in emblem_coords:
		img.set_pixel(c.x, c.y, gold_hi)
		img.set_pixel(c.x, c.y + 1, gold_deep)
		
	img.save_png(png_path)
	_save_texture_resource(png_path, tres_path)
	print("Generated: %s" % png_path)

func _generate_ribbon(png_path: String, tres_path: String):
	var w = 68
	var h = 34
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var red_deep = Color("#7F0000")
	var red_mid = Color("#C62828")
	var red_hi = Color("#E53935")
	var gold_edge = Color("#FFD54F")
	
	# Left ribbon tail
	for step in range(24):
		var x = 24 - step
		var y_top = 4 + step * 0.8
		var y_bot = y_top + 10
		for y in range(int(y_top), int(y_bot)):
			if y < h:
				if y == int(y_top) or y == int(y_bot) - 1:
					img.set_pixel(x, y, gold_edge)
				elif y == int(y_top) + 1:
					img.set_pixel(x, y, red_hi)
				else:
					img.set_pixel(x, y, red_mid)
					
	# Right ribbon tail
	for step in range(24):
		var x = w - 24 + step
		var y_top = 4 + step * 0.8
		var y_bot = y_top + 10
		for y in range(int(y_top), int(y_bot)):
			if y < h:
				if y == int(y_top) or y == int(y_bot) - 1:
					img.set_pixel(x, y, gold_edge)
				elif y == int(y_top) + 1:
					img.set_pixel(x, y, red_hi)
				else:
					img.set_pixel(x, y, red_mid)
					
	# Central banner band
	for y in range(6, 16):
		for x in range(16, w - 16):
			if y == 6 or y == 15:
				img.set_pixel(x, y, gold_edge)
			elif y == 7:
				img.set_pixel(x, y, red_hi)
			else:
				img.set_pixel(x, y, red_mid)
				
	img.save_png(png_path)
	_save_texture_resource(png_path, tres_path)
	print("Generated: %s" % png_path)

func _save_texture_resource(png_path: String, tres_path: String):
	var img = Image.load_from_file(ProjectSettings.globalize_path(png_path))
	if not img:
		push_error("Failed to load img for tres: %s" % png_path)
		return
	var tex = ImageTexture.create_from_image(img)
	ResourceSaver.save(tex, tres_path)
