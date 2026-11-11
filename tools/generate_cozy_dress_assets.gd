extends SceneTree

# tools/generate_cozy_dress_assets.gd
# Generates cozy Dress-up & Room Decor pixel art assets:
# 1. floor_wood_parquet.png / .tres (Warm oak parquet floor pattern)
# 2. rug_woven_cozy_oval.png / .tres (Cozy patterned woven rug with fringes)
# 3. clipboard_wood_frame_9patch.png / .tres (Wooden clipboard with brass clip & parchment)
# 4. star_rating_track_5stars.png & star_rating_progress_5stars.png / .tres (5-star TextureProgressBar)
# 5. vintage_chest_shelf_9patch.png / .tres (Vintage wardrobe / chest drawer 9-patch)
# 6. Pixel sub-tab icons (all, clothes, hat, bow, acc, bed, bowl, rug, wall, plant)

const OUT_DIR = "res://assets/UI/CatUIPaid/slices/cozy_dress/"

func _init() -> void:
	print("[CozyDressGen] Generating Cozy Dress-up & Room Decor assets...")
	var global_dir = ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(global_dir)
	
	_gen_floor_wood_parquet()
	_gen_rug_woven_cozy_oval()
	_gen_clipboard_wood_frame()
	_gen_star_rating_textures()
	_gen_vintage_chest_shelf()
	_gen_subcat_icons()
	
	print("[CozyDressGen] ALL ASSETS GENERATED SUCCESSFULLY!")
	quit(0)

func _save_image_and_tres(img: Image, base_name: String) -> void:
	var png_path = OUT_DIR + base_name + ".png"
	var tres_path = OUT_DIR + base_name + ".tres"
	var global_png = ProjectSettings.globalize_path(png_path)
	var err = img.save_png(global_png)
	if err == OK:
		print("  [PNG] -> ", png_path)
	else:
		printerr("  [ERR PNG] -> ", err)
		
	var tex = ImageTexture.create_from_image(img)
	var r_err = ResourceSaver.save(tex, tres_path)
	if r_err == OK:
		print("  [TRES] -> ", tres_path)
	else:
		printerr("  [ERR TRES] -> ", r_err)

# 1. SÀN GỖ PIXEL (Warm Oak Parquet Wood Floor) - 180x150
func _gen_floor_wood_parquet() -> void:
	var w = 180
	var h = 150
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	
	var col_dark_seam = Color("#4A2E1B") # Rãnh gỗ
	var col_seam_shadow = Color("#3A2214")
	var plank_palette = [
		Color("#C48D58"), Color("#B8804B"), Color("#CE9762"),
		Color("#B07641"), Color("#C8925D"), Color("#BC8550")
	]
	var grain_light = Color("#D6A36E", 0.35)
	var grain_dark = Color("#8C582B", 0.30)
	
	# Tạo các ván gỗ ngang so le (plank height = 15px, plank width = 60px)
	var plank_h = 15
	var plank_w = 60
	
	for y in range(h):
		var row = y / plank_h
		var row_y = y % plank_h
		var row_offset = (row % 3) * 20
		
		for x in range(w):
			var col = (x + row_offset) / plank_w
			var plank_x = (x + row_offset) % plank_w
			
			# Viền rãnh ván gỗ
			if row_y == plank_h - 1:
				img.set_pixel(x, y, col_dark_seam)
			elif row_y == plank_h - 2:
				img.set_pixel(x, y, col_seam_shadow)
			elif plank_x == 0:
				img.set_pixel(x, y, col_dark_seam)
			else:
				# Màu nền ván gỗ
				var base_idx = (row * 7 + col * 13) % plank_palette.size()
				var c = plank_palette[base_idx]
				
				# Vân gỗ nhẹ nhàng (Wood grain)
				var grain_wave = sin(float(x) * 0.18 + float(row) * 1.5) * 4.0
				if int(row_y + grain_wave) % 6 == 0:
					c = c.lerp(grain_light, 0.4)
				elif int(row_y + grain_wave) % 7 == 3:
					c = c.lerp(grain_dark, 0.4)
				
				# Ánh sáng nhẹ ở đỉnh mỗi ván
				if row_y == 0:
					c = c.lightened(0.12)
					
				img.set_pixel(x, y, c)
				
	_save_image_and_tres(img, "floor_wood_parquet")

# 2. THẢM TRẢI SÀN DỆT HỌA TIẾT ẤM CÚNG (Cozy Woven Bohemian Rug) - 150x80
func _gen_rug_woven_cozy_oval() -> void:
	var w = 150
	var h = 80
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	
	var cx = float(w) / 2.0
	var cy = float(h) / 2.0
	var rx = 70.0
	var ry = 35.0
	
	var col_fringe = Color("#F4EDE2") # Tua rua dệt màu kem
	var col_fringe_dark = Color("#C9BCAC")
	var col_border = Color("#8B3A2B") # Đỏ mộc đun boho
	var col_accent = Color("#D4913B") # Vàng mù tạt
	var col_teal = Color("#3B706E")   # Xanh ngọc cổ điển
	var col_cream = Color("#FFF8EC")  # Nền dệt ấm
	var col_shadow = Color(0.18, 0.12, 0.08, 0.35)
	
	for y in range(h):
		for x in range(w):
			var dx = (float(x) - cx + 0.5) / rx
			var dy = (float(y) - cy + 0.5) / ry
			var dist = sqrt(dx * dx + dy * dy)
			
			if dist <= 1.05 and dist > 1.0:
				# Bóng đổ nhẹ dưới thảm
				if dy > 0.1:
					img.set_pixel(x, y, col_shadow)
				else:
					img.set_pixel(x, y, Color(0, 0, 0, 0))
			elif dist <= 1.0 and dist > 0.93:
				# Tua rua / viền mép ngoài dệt
				var fringe_pattern = (x + y) % 3
				if fringe_pattern == 0:
					img.set_pixel(x, y, col_fringe)
				elif fringe_pattern == 1:
					img.set_pixel(x, y, col_fringe_dark)
				else:
					img.set_pixel(x, y, col_border)
			elif dist <= 0.93 and dist > 0.82:
				# Dải thổ cẩm đỏ booc-đô
				img.set_pixel(x, y, col_border)
			elif dist <= 0.82 and dist > 0.72:
				# Họa tiết zic-zac vàng mù tạt
				var zig = (int(x * 0.4) + int(y * 0.4)) % 2
				img.set_pixel(x, y, col_accent if zig == 0 else col_cream)
			elif dist <= 0.72 and dist > 0.60:
				# Vòng tròn xanh teal cổ điển
				img.set_pixel(x, y, col_teal)
			elif dist <= 0.60:
				# Lòng thảm dệt họa tiết dấu chân mèo / kim cương
				var d_center = sqrt(dx * dx * 2.0 + dy * dy * 2.0)
				if d_center < 0.22:
					# Họa tiết kim cương tâm
					img.set_pixel(x, y, col_border)
				elif d_center < 0.30:
					img.set_pixel(x, y, col_accent)
				else:
					var weave = (x + y) % 2
					img.set_pixel(x, y, col_cream if weave == 0 else Color("#F9F1E2"))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				
	_save_image_and_tres(img, "rug_woven_cozy_oval")

# 3. BẢNG GHI CHÚ GỖ KẸP GIẤY CLIPBOARD (Wooden Clipboard 9-patch) - 48x48
func _gen_clipboard_wood_frame() -> void:
	var size = 48
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	
	var col_wood_border = Color("#3A2012")
	var col_wood_inner = Color("#6A4226")
	var col_wood_bevel = Color("#8C5B36")
	var col_paper_border = Color("#D8C8B4")
	var col_paper_fill = Color("#FFFDF8") # Giấy da kem sáng
	var col_clip_brass = Color("#E6AF3A")
	var col_clip_shadow = Color("#7D5514")
	
	for y in range(size):
		for x in range(size):
			# Khung gỗ bo góc ngoài
			var is_border = (x == 0 or x == size - 1 or y == 0 or y == size - 1)
			var is_corner = (x <= 1 and y <= 1) or (x >= size - 2 and y <= 1) or (x <= 1 and y >= size - 2) or (x >= size - 2 and y >= size - 2)
			
			if is_corner and (x == 0 or x == size - 1) and (y == 0 or y == size - 1):
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
				
			if is_border:
				img.set_pixel(x, y, col_wood_border)
			elif x <= 4 or x >= size - 5 or y <= 5 or y >= size - 5:
				# Phần bệ gỗ của clipboard
				if y == 1 or x == 1:
					img.set_pixel(x, y, col_wood_bevel)
				else:
					img.set_pixel(x, y, col_wood_inner)
			elif x == 5 or x == size - 6 or y == 6 or y == size - 6:
				img.set_pixel(x, y, col_paper_border)
			else:
				img.set_pixel(x, y, col_paper_fill)
				
	# Kẹp kim loại đồng thau (brass clip) ở đỉnh giữa clipboard (x từ 17 tới 30, y từ 0 tới 5)
	for y in range(6):
		for x in range(17, 31):
			if y == 0 or x == 17 or x == 30:
				img.set_pixel(x, y, col_wood_border)
			elif y == 5:
				img.set_pixel(x, y, col_clip_shadow)
			elif y == 1:
				img.set_pixel(x, y, Color("#FFE27D")) # Highlight ánh kim
			else:
				img.set_pixel(x, y, col_clip_brass)
				
	_save_image_and_tres(img, "clipboard_wood_frame_9patch")

# 4. THANH SAO ĐÁNH GIÁ (5 Golden Pixel Stars TextureProgressBar)
# Size: 80x16 (mỗi ngôi sao 16x16)
func _gen_star_rating_textures() -> void:
	var w = 80
	var h = 16
	var img_under = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var img_progress = Image.create(w, h, false, Image.FORMAT_RGBA8)
	
	# Ma trận 16x16 của 1 pixel star
	# 0 = trans, 1 = outline, 2 = fill, 3 = shine/bevel, 4 = shadow
	var star_map = [
		[0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,1,3,1,0,0,0,0,0,0,0],
		[0,0,0,0,0,0,1,3,1,0,0,0,0,0,0,0],
		[0,0,0,0,0,1,3,2,3,1,0,0,0,0,0,0],
		[1,1,1,1,1,1,3,2,2,1,1,1,1,1,1,0],
		[0,1,3,3,2,2,2,2,2,2,2,2,4,1,0,0],
		[0,0,1,3,2,2,2,2,2,2,2,4,1,0,0,0],
		[0,0,0,1,3,2,2,2,2,2,4,1,0,0,0,0],
		[0,0,0,1,3,2,2,2,2,2,4,1,0,0,0,0],
		[0,0,1,3,2,2,2,2,2,2,2,4,1,0,0,0],
		[0,1,3,2,1,1,2,2,2,1,1,2,4,1,0,0],
		[0,1,3,1,0,0,1,2,1,0,0,1,4,1,0,0],
		[1,3,1,0,0,0,1,2,1,0,0,0,1,4,1,0],
		[1,2,1,0,0,0,1,4,1,0,0,0,1,4,1,0],
		[1,1,0,0,0,0,0,1,0,0,0,0,0,1,1,0],
		[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	]
	
	# Bảng màu cho Progress (Vàng Kim Rực Rỡ)
	var col_p_out = Color("#4D2B05")
	var col_p_fill = Color("#FFAA00")
	var col_p_shine = Color("#FFF380")
	var col_p_shad = Color("#C77300")
	
	# Bảng màu cho Under (Gỗ / Xám Mờ)
	var col_u_out = Color("#4A3728")
	var col_u_fill = Color("#8C7663")
	var col_u_shine = Color("#A89481")
	var col_u_shad = Color("#6B5645")
	
	for star_idx in range(5):
		var offset_x = star_idx * 16
		for y in range(16):
			for x in range(16):
				var px = offset_x + x
				var v = star_map[y][x]
				
				# Progress
				if v == 1: img_progress.set_pixel(px, y, col_p_out)
				elif v == 2: img_progress.set_pixel(px, y, col_p_fill)
				elif v == 3: img_progress.set_pixel(px, y, col_p_shine)
				elif v == 4: img_progress.set_pixel(px, y, col_p_shad)
				else: img_progress.set_pixel(px, y, Color(0, 0, 0, 0))
				
				# Under
				if v == 1: img_under.set_pixel(px, y, col_u_out)
				elif v == 2: img_under.set_pixel(px, y, col_u_fill)
				elif v == 3: img_under.set_pixel(px, y, col_u_shine)
				elif v == 4: img_under.set_pixel(px, y, col_u_shad)
				else: img_under.set_pixel(px, y, Color(0, 0, 0, 0))
				
	_save_image_and_tres(img_under, "star_rating_track_5stars")
	_save_image_and_tres(img_progress, "star_rating_progress_5stars")

# 5. KHUNG RƯƠNG ĐỒ / KỆ TỦ GỖ VINTAGE (Vintage Wardrobe Chest 9-patch) - 40x40
func _gen_vintage_chest_shelf() -> void:
	var size = 40
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	
	var col_dark_iron = Color("#2A1A10") # Khung đinh sắt / rãnh tối
	var col_brass_rivet = Color("#D9A443") # Đinh tán đồng
	var col_wood_rim = Color("#5C371E")
	var col_wood_main = Color("#824F2B")
	var col_inner_bg = Color("#F8F2E8") # Ngăn tủ sáng bên trong
	
	for y in range(size):
		for x in range(size):
			var is_edge = (x == 0 or x == size - 1 or y == 0 or y == size - 1)
			var is_rim = (x <= 3 or x >= size - 4 or y <= 3 or y >= size - 4)
			
			if is_edge:
				img.set_pixel(x, y, col_dark_iron)
			elif is_rim:
				# 4 góc đinh tán đồng
				var is_corner_rivet = ((x == 2 or x == size - 3) and (y == 2 or y == size - 3))
				if is_corner_rivet:
					img.set_pixel(x, y, col_brass_rivet)
				elif x == 1 or y == 1:
					img.set_pixel(x, y, col_wood_main.lightened(0.15))
				else:
					img.set_pixel(x, y, col_wood_main)
			elif x == 4 or x == size - 5 or y == 4 or y == size - 5:
				img.set_pixel(x, y, Color("#4A2E1A"))
			else:
				img.set_pixel(x, y, col_inner_bg)
				
	_save_image_and_tres(img, "vintage_chest_shelf_9patch")

# 6. BỘ ICON PIXEL SUB-TABS TRANG PHỤC & DECOR (16x16)
func _gen_subcat_icons() -> void:
	# A. Quần Áo (Sweater / Hoodie)
	_draw_16x16_icon("icon_subcat_clothes", [
		[0,0,0,1,1,0,0,1,1,0,0,0],
		[0,0,1,2,2,1,1,2,2,1,0,0],
		[0,1,2,2,2,2,2,2,2,2,1,0],
		[1,2,3,2,2,2,2,2,2,3,2,1],
		[1,2,1,2,2,2,2,2,2,1,2,1],
		[1,1,1,2,2,2,2,2,2,1,1,1],
		[0,0,1,2,2,2,2,2,2,1,0,0],
		[0,0,1,2,2,2,2,2,2,1,0,0],
		[0,0,1,4,4,4,4,4,4,1,0,0],
		[0,0,0,1,1,1,1,1,1,0,0,0]
	], Color("#2A1A10"), Color("#C85A32"), Color("#E07850"), Color("#A03C1A"))

	# B. Mũ & Nón (Beret / Cap)
	_draw_16x16_icon("icon_subcat_hat", [
		[0,0,0,0,1,1,0,0,0,0,0,0],
		[0,0,1,1,2,2,1,1,0,0,0,0],
		[0,1,2,2,2,2,2,2,1,0,0,0],
		[1,3,2,2,2,2,2,2,2,1,0,0],
		[1,2,2,2,2,2,2,2,2,1,0,0],
		[1,1,1,1,1,1,1,1,1,1,1,1],
		[0,0,1,4,4,4,4,4,4,1,0,0],
		[0,0,0,1,1,1,1,1,1,0,0,0]
	], Color("#221812"), Color("#3F68A0"), Color("#6591D1"), Color("#274570"))

	# C. Nơ & Khăn (Bow ribbon)
	_draw_16x16_icon("icon_subcat_bow", [
		[1,1,0,0,0,0,0,0,1,1,0,0],
		[1,2,1,0,0,0,0,1,2,1,0,0],
		[1,2,2,1,1,1,1,2,2,1,0,0],
		[1,2,2,1,3,3,1,2,2,1,0,0],
		[0,1,2,1,3,3,1,2,1,0,0,0],
		[0,1,1,1,1,1,1,1,1,0,0,0],
		[0,1,2,1,0,0,1,2,1,0,0,0],
		[1,2,1,0,0,0,0,1,2,1,0,0]
	], Color("#3A1212"), Color("#D93845"), Color("#FF6B78"), Color("#991C26"))

	# D. Phụ Kiện (Glasses / Backpack)
	_draw_16x16_icon("icon_subcat_acc", [
		[0,1,1,1,0,0,0,1,1,1,0,0],
		[1,3,2,3,1,1,1,3,2,3,1,0],
		[1,2,2,2,1,1,1,2,2,2,1,0],
		[1,3,2,3,1,0,1,3,2,3,1,0],
		[0,1,1,1,0,0,0,1,1,1,0,0]
	], Color("#1E1E1E"), Color("#E0C040"), Color("#FFF090"), Color("#9E8010"))

	# E. Tất Cả (Sparkles)
	_draw_16x16_icon("icon_subcat_all", [
		[0,0,0,0,0,1,0,0,0,0,0,0],
		[0,0,0,0,1,3,1,0,0,0,0,0],
		[0,0,1,1,2,3,2,1,1,0,0,0],
		[0,1,2,2,2,3,2,2,2,1,0,0],
		[1,3,3,3,3,3,3,3,3,3,1,0],
		[0,1,2,2,2,3,2,2,2,1,0,0],
		[0,0,1,1,2,3,2,1,1,0,0,0],
		[0,0,0,0,1,3,1,0,0,0,0,0],
		[0,0,0,0,0,1,0,0,0,0,0,0]
	], Color("#4D3200"), Color("#FFB703"), Color("#FFF5B8"), Color("#D48B00"))

	# F. Đệm Ngủ (Bed)
	_draw_16x16_icon("icon_subcat_bed", [
		[0,0,1,1,1,1,1,1,0,0,0,0],
		[0,1,3,3,3,3,3,3,1,0,0,0],
		[1,3,2,2,2,2,2,2,3,1,0,0],
		[1,2,2,2,2,2,2,2,2,1,0,0],
		[1,4,4,4,4,4,4,4,4,1,0,0],
		[0,1,1,1,1,1,1,1,1,0,0,0]
	], Color("#3A1A2A"), Color("#C75D8C"), Color("#EFA0C3"), Color("#8A355E"))

	# G. Thảm Sàn (Rug)
	_draw_16x16_icon("icon_subcat_rug", [
		[1,0,1,0,1,0,1,0,1,0,1,0],
		[1,1,1,1,1,1,1,1,1,1,1,1],
		[1,3,2,3,2,3,2,3,2,3,4,1],
		[1,2,3,2,3,2,3,2,3,2,4,1],
		[1,1,1,1,1,1,1,1,1,1,1,1],
		[1,0,1,0,1,0,1,0,1,0,1,0]
	], Color("#352212"), Color("#D9822B"), Color("#FFB86B"), Color("#8C4E11"))

	# H. Tranh Tường (Wall art)
	_draw_16x16_icon("icon_subcat_wall", [
		[1,1,1,1,1,1,1,1,1,1,0,0],
		[1,3,3,3,3,3,3,3,3,1,0,0],
		[1,3,2,2,2,2,2,2,3,1,0,0],
		[1,3,2,4,2,2,4,2,3,1,0,0],
		[1,3,2,4,4,4,4,2,3,1,0,0],
		[1,3,3,3,3,3,3,3,3,1,0,0],
		[1,1,1,1,1,1,1,1,1,1,0,0]
	], Color("#3A2510"), Color("#4A7A55"), Color("#C89D66"), Color("#78B888"))

	# I. Cây Cảnh (Plant)
	_draw_16x16_icon("icon_subcat_plant", [
		[0,0,0,1,1,0,0,0,0,0,0,0],
		[0,1,1,2,2,1,1,0,0,0,0,0],
		[1,2,2,2,2,2,2,1,0,0,0,0],
		[0,1,2,1,1,2,1,0,0,0,0,0],
		[0,0,1,1,1,1,0,0,0,0,0,0],
		[0,0,1,3,3,1,0,0,0,0,0,0],
		[0,0,1,3,3,1,0,0,0,0,0,0],
		[0,0,0,1,1,0,0,0,0,0,0,0]
	], Color("#1E2D1A"), Color("#3A8E3F"), Color("#C26D38"), Color("#5CB862"))

func _draw_16x16_icon(name: String, grid: Array, c1: Color, c2: Color, c3: Color, c4: Color) -> void:
	var h = 16
	var w = 16
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var gh = grid.size()
	var gw = grid[0].size()
	var off_y = (h - gh) / 2
	var off_x = (w - gw) / 2
	
	for y in range(gh):
		for x in range(gw):
			var v = grid[y][x]
			var py = off_y + y
			var px = off_x + x
			if v == 1: img.set_pixel(px, py, c1)
			elif v == 2: img.set_pixel(px, py, c2)
			elif v == 3: img.set_pixel(px, py, c3)
			elif v == 4: img.set_pixel(px, py, c4)
			else: img.set_pixel(px, py, Color(0, 0, 0, 0))
			
	_save_image_and_tres(img, name)
