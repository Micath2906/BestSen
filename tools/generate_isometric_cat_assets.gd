extends SceneTree

# tools/generate_isometric_cat_assets.gd
# Generates:
# 1. shadow_pixel_ellipse.png (and .tres): Pixel blurry ellipse shadow (alpha 0.4)
# 2. chat_bubble_9patch.png (and .tres): 9-slice cream chat bubble with coffee-brown border
# 3. chat_bubble_tail.png (and .tres): Pointy downward pixel tail pointing to cat's ear
# 4. heart_particle_pixel.png (and .tres): Cute pixel floating heart

func _init() -> void:
	print("[AssetGen] Generating IsometricCat ToffeeCraft assets...")
	_generate_shadow()
	_generate_chat_bubble_9patch()
	_generate_chat_bubble_tail()
	_generate_heart_particle()
	print("[AssetGen] ALL ASSETS GENERATED SUCCESSFULLY!")
	quit(0)

func _generate_shadow() -> void:
	var w = 44
	var h = 20
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var cx = float(w) / 2.0
	var cy = float(h) / 2.0
	var rx = 19.5
	var ry = 8.5
	
	for y in range(h):
		for x in range(w):
			var dx = (float(x) - cx + 0.5) / rx
			var dy = (float(y) - cy + 0.5) / ry
			var dist = sqrt(dx * dx + dy * dy)
			if dist <= 1.0:
				var falloff = 1.0 - pow(dist, 1.4)
				var a = clampf(falloff * 0.40, 0.0, 0.40)
				# Soft coffee-charcoal floor shadow
				img.set_pixel(x, y, Color(0.12, 0.08, 0.06, a))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				
	var dir = "res://assets/sprites/cats/"
	_save_image_and_tres(img, dir + "shadow_pixel_ellipse.png", dir + "shadow_pixel_ellipse.tres")

func _generate_chat_bubble_9patch() -> void:
	var size = 32
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	
	var col_border = Color("#3C2415") # Coffee brown
	var col_border_soft = Color("#5A3D28")
	var col_inner_bevel = Color("#F3ECE0")
	var col_fill = Color("#FFFDF8") # Warm cream
	var col_shadow = Color(0.2, 0.1, 0.05, 0.15)
	
	for y in range(size):
		for x in range(size):
			img.set_pixel(x, y, Color(0, 0, 0, 0))
			
	# Rounded rectangle with radius 5px
	for y in range(size):
		for x in range(size):
			var in_x = (x >= 2 and x < size - 2)
			var in_y = (y >= 2 and y < size - 2)
			
			# Corner checks (radius 4)
			var is_corner = false
			if (x <= 4 and y <= 4 and Vector2(x - 4, y - 4).length() > 3.8):
				is_corner = true
			elif (x >= size - 5 and y <= 4 and Vector2(x - (size - 5), y - 4).length() > 3.8):
				is_corner = true
			elif (x <= 4 and y >= size - 5 and Vector2(x - 4, y - (size - 5)).length() > 3.8):
				is_corner = true
			elif (x >= size - 5 and y >= size - 5 and Vector2(x - (size - 5), y - (size - 5)).length() > 3.8):
				is_corner = true
				
			if is_corner:
				continue
				
			# Border 2px
			var is_outer_border = (x < 2 or x >= size - 2 or y < 2 or y >= size - 2)
			var is_inner_border = (x < 3 or x >= size - 3 or y < 3 or y >= size - 3)
			
			if is_outer_border:
				img.set_pixel(x, y, col_border)
			elif is_inner_border:
				img.set_pixel(x, y, col_border_soft)
			elif y == 3 or x == 3:
				img.set_pixel(x, y, col_inner_bevel)
			else:
				img.set_pixel(x, y, col_fill)
				
	var dir = "res://assets/UI/CatUIPaid/slices/"
	_save_image_and_tres(img, dir + "chat_bubble_9patch.png", dir + "chat_bubble_9patch.tres")

func _generate_chat_bubble_tail() -> void:
	var w = 12
	var h = 9
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var col_border = Color("#3C2415")
	var col_fill = Color("#FFFDF8")
	
	for y in range(h):
		for x in range(w):
			img.set_pixel(x, y, Color(0, 0, 0, 0))
			
	# Downward pointing tail / beak pointing to the cat's ear (offset slightly left-center)
	# Shape from top y=0 to bottom y=8
	var shape = [
		# y=0: connecting top (open into bubble body)
		[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0],
		# y=1
		[0, 2, 1, 1, 1, 1, 1, 1, 1, 2, 0, 0],
		# y=2
		[0, 2, 1, 1, 1, 1, 1, 1, 2, 0, 0, 0],
		# y=3
		[0, 0, 2, 1, 1, 1, 1, 2, 0, 0, 0, 0],
		# y=4
		[0, 0, 2, 1, 1, 1, 2, 0, 0, 0, 0, 0],
		# y=5
		[0, 0, 0, 2, 1, 2, 0, 0, 0, 0, 0, 0],
		# y=6
		[0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0],
		# y=7
		[0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0],
		# y=8
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	]
	
	for y in range(h):
		for x in range(w):
			var val = shape[y][x]
			if val == 1:
				img.set_pixel(x, y, col_fill)
			elif val == 2:
				img.set_pixel(x, y, col_border)
				
	var dir = "res://assets/UI/CatUIPaid/slices/"
	_save_image_and_tres(img, dir + "chat_bubble_tail.png", dir + "chat_bubble_tail.tres")

func _generate_heart_particle() -> void:
	var w = 12
	var h = 10
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var col_outline = Color("#4D121B")
	var col_main = Color("#FF5E7E")
	var col_dark = Color("#DE3B5B")
	var col_shine = Color("#FFAEC0")
	
	for y in range(h):
		for x in range(w):
			img.set_pixel(x, y, Color(0, 0, 0, 0))
			
	# 0 = transparent, 1 = outline, 2 = main, 3 = dark, 4 = shine
	var grid = [
		[0, 1, 1, 0, 0, 0, 0, 1, 1, 0, 0, 0],
		[1, 4, 4, 1, 0, 0, 1, 2, 2, 1, 0, 0],
		[1, 4, 2, 2, 1, 1, 2, 2, 2, 1, 0, 0],
		[1, 2, 2, 2, 2, 2, 2, 2, 3, 1, 0, 0],
		[0, 1, 2, 2, 2, 2, 2, 3, 1, 0, 0, 0],
		[0, 0, 1, 2, 2, 2, 3, 1, 0, 0, 0, 0],
		[0, 0, 0, 1, 2, 3, 1, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
		[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	]
	
	for y in range(h):
		for x in range(w):
			var v = grid[y][x]
			if v == 1: img.set_pixel(x, y, col_outline)
			elif v == 2: img.set_pixel(x, y, col_main)
			elif v == 3: img.set_pixel(x, y, col_dark)
			elif v == 4: img.set_pixel(x, y, col_shine)
			
	var dir = "res://assets/UI/CatUIPaid/slices/"
	_save_image_and_tres(img, dir + "heart_particle_pixel.png", dir + "heart_particle_pixel.tres")

func _save_image_and_tres(img: Image, png_path: String, tres_path: String) -> void:
	var global_png = ProjectSettings.globalize_path(png_path)
	var err = img.save_png(global_png)
	if err == OK:
		print("  [SAVED PNG] -> ", png_path)
	else:
		printerr("  [ERROR] saving PNG: ", err)
		
	var tex = ImageTexture.create_from_image(img)
	var r_err = ResourceSaver.save(tex, tres_path)
	if r_err == OK:
		print("  [SAVED TRES] -> ", tres_path)
	else:
		printerr("  [ERROR] saving TRES: ", r_err)
