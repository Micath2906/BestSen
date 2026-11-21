extends SceneTree

# Script tự động tạo toàn bộ Assets Pixel Art chất lượng cao cho cả 5 Task
# Đảm bảo phong cách Warm Toffee & Cozy Pixel, nói KHÔNG với các khối chữ nhật AI đơn điệu!

const BASE_DIR = "res://assets/sprites/"

func _init():
	print(">>> BẮT ĐẦU VẼ TOÀN BỘ ASSETS PIXEL ART CHO 5 TASKS <<<")
	_ensure_dirs()
	_generate_tetris_items()
	_generate_spot_difference_images()
	_generate_doctor_assets()
	_generate_budget_jars_assets()
	_generate_cozy_room_upgrades()
	print(">>> HOÀN THÀNH VẼ VÀ LƯU TOÀN BỘ ASSETS PIXEL ART! <<<")
	quit(0)

func _ensure_dirs():
	var dirs = [
		"res://assets/sprites/minigames/tetris/",
		"res://assets/sprites/minigames/spot_diff/",
		"res://assets/sprites/minigames/doctor/",
		"res://assets/sprites/minigames/budget/",
		"res://assets/sprites/room_decor/"
	]
	for d in dirs:
		var global_p = ProjectSettings.globalize_path(d)
		DirAccess.make_dir_recursive_absolute(global_p)

# ==============================================================================
# 1. TETRIS INVENTORY ITEMS (Task 1: Mỗi ô lưới 32x32px)
# ==============================================================================
func _generate_tetris_items():
	print("--- Vẽ Tetris Items ---")
	# Grid cell texture (32x32)
	var cell = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	cell.fill(Color("#F3E9DA")) # Light felt background
	var border_c = Color("#CBB89D")
	var highlight_c = Color("#FFFDF9")
	var dark_c = Color("#B39E82")
	for x in range(32):
		cell.set_pixel(x, 0, highlight_c)
		cell.set_pixel(x, 31, dark_c)
	for y in range(32):
		cell.set_pixel(0, y, highlight_c)
		cell.set_pixel(31, y, dark_c)
	# Corner stitches
	cell.set_pixel(2, 2, border_c)
	cell.set_pixel(29, 2, border_c)
	cell.set_pixel(2, 29, border_c)
	cell.set_pixel(29, 29, border_c)
	_save_img(cell, "res://assets/sprites/minigames/tetris/grid_cell.png")

	# 1. Hoodie (2x2 cells = 64x64px)
	var hoodie = _create_shaded_block(64, 64, Color("#E07A5F"), Color("#C85A3F"), Color("#F4A261"), "🧥")
	_save_img(hoodie, "res://assets/sprites/minigames/tetris/tetris_hoodie_2x2.png")

	# 2. Jeans (1x3 cells = 32x96px)
	var jeans = _create_shaded_block(32, 96, Color("#3D5A80"), Color("#293241"), Color("#98C1D9"), "👖")
	_save_img(jeans, "res://assets/sprites/minigames/tetris/tetris_jeans_1x3.png")

	# 3. T-shirt (2x1 cells = 64x32px)
	var tshirt = _create_shaded_block(64, 32, Color("#81B29A"), Color("#608C75"), Color("#A8DADC"), "👕")
	_save_img(tshirt, "res://assets/sprites/minigames/tetris/tetris_tshirt_2x1.png")

	# 4. Towel (1x2 cells = 32x64px)
	var towel = _create_shaded_block(32, 64, Color("#F2CC8F"), Color("#D4A373"), Color("#FFE8D6"), "🧣")
	_save_img(towel, "res://assets/sprites/minigames/tetris/tetris_towel_1x2.png")

	# 5. Socks (1x1 cell = 32x32px)
	var socks = _create_shaded_block(32, 32, Color("#DDA15E"), Color("#BC6C25"), Color("#FEFAE0"), "🧦")
	_save_img(socks, "res://assets/sprites/minigames/tetris/tetris_socks_1x1.png")

	# 6. Winter Coat L-shape (64x64 with top-right missing)
	var coat_l = _create_l_shape(Color("#9C6644"), Color("#7F4F24"), Color("#B08968"))
	_save_img(coat_l, "res://assets/sprites/minigames/tetris/tetris_coat_L3.png")

	# Documents
	var doc_a4 = _create_shaded_block(64, 96, Color("#FAF0CA"), Color("#EE964B"), Color("#FFFFFF"), "📋")
	_save_img(doc_a4, "res://assets/sprites/minigames/tetris/tetris_doc_a4_2x3.png")

	var id_card = _create_shaded_block(32, 32, Color("#F4D35E"), Color("#EB5E28"), Color("#FFF3B0"), "💳")
	_save_img(id_card, "res://assets/sprites/minigames/tetris/tetris_id_card_1x1.png")

	var diploma = _create_shaded_block(64, 64, Color("#C1121F"), Color("#780000"), Color("#FDF0D5"), "📜")
	_save_img(diploma, "res://assets/sprites/minigames/tetris/tetris_diploma_2x2.png")

	var notebook = _create_shaded_block(32, 64, Color("#588157"), Color("#3A5A40"), Color("#A3B18A"), "📕")
	_save_img(notebook, "res://assets/sprites/minigames/tetris/tetris_notebook_1x2.png")

	var pen = _create_shaded_block(32, 32, Color("#3A86FF"), Color("#004E64"), Color("#70D6FF"), "🖊️")
	_save_img(pen, "res://assets/sprites/minigames/tetris/tetris_pen_1x1.png")

	# Medical
	var para500 = _create_shaded_block(64, 32, Color("#E63946"), Color("#D90429"), Color("#FFB703"), "💊")
	_save_img(para500, "res://assets/sprites/minigames/tetris/tetris_para500_2x1.png")

	var spray = _create_shaded_block(32, 64, Color("#457B9D"), Color("#1D3557"), Color("#A8DADC"), "🧴")
	_save_img(spray, "res://assets/sprites/minigames/tetris/tetris_spray_1x2.png")

	var oresol = _create_shaded_block(32, 32, Color("#FB8500"), Color("#FFB703"), Color("#FFE49E"), "🥤")
	_save_img(oresol, "res://assets/sprites/minigames/tetris/tetris_oresol_1x1.png")

	var urgo = _create_shaded_block(32, 32, Color("#FFB4A2"), Color("#E5989B"), Color("#FFCDB2"), "🩹")
	_save_img(urgo, "res://assets/sprites/minigames/tetris/tetris_urgo_1x1.png")

	var thermo = _create_shaded_block(32, 64, Color("#E0FBFC"), Color("#98C1D9"), Color("#EE6C4D"), "🌡️")
	_save_img(thermo, "res://assets/sprites/minigames/tetris/tetris_thermo_1x2.png")

	var gauze = _create_l_shape(Color("#FFFFFF"), Color("#E2E2E2"), Color("#FFF5EB"))
	_save_img(gauze, "res://assets/sprites/minigames/tetris/tetris_gauze_L3.png")

	# Tech
	var laptop = _create_shaded_block(96, 64, Color("#4A4E69"), Color("#22223B"), Color("#9A8C98"), "💻")
	_save_img(laptop, "res://assets/sprites/minigames/tetris/tetris_laptop_3x2.png")

	var mouse = _create_shaded_block(32, 32, Color("#6D6875"), Color("#3D3A45"), Color("#B5838D"), "🖱️")
	_save_img(mouse, "res://assets/sprites/minigames/tetris/tetris_mouse_1x1.png")

	var charger = _create_l_shape(Color("#FFB703"), Color("#FB8500"), Color("#FFE3A8"))
	_save_img(charger, "res://assets/sprites/minigames/tetris/tetris_charger_L3.png")

	var powerstrip = _create_shaded_block(32, 96, Color("#FFFFFF"), Color("#CED4DA"), Color("#FFD166"), "🔌")
	_save_img(powerstrip, "res://assets/sprites/minigames/tetris/tetris_powerstrip_1x3.png")

	var headphone = _create_shaded_block(32, 64, Color("#E76F51"), Color("#264653"), Color("#F4A261"), "🎧")
	_save_img(headphone, "res://assets/sprites/minigames/tetris/tetris_headphone_1x2.png")

# Helper to create cozy pixel block with bevel border and inner depth
func _create_shaded_block(w: int, h: int, main_c: Color, dark_c: Color, light_c: Color, _tag: String) -> Image:
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var outline_c = dark_c.darkened(0.35)
	
	# Fill base
	for y in range(h):
		for x in range(w):
			img.set_pixel(x, y, main_c)
			
	# Border outlines
	for x in range(w):
		img.set_pixel(x, 0, outline_c)
		img.set_pixel(x, 1, light_c)
		img.set_pixel(x, h - 2, dark_c)
		img.set_pixel(x, h - 1, outline_c)
	for y in range(h):
		img.set_pixel(0, y, outline_c)
		img.set_pixel(1, y, light_c)
		img.set_pixel(w - 2, y, dark_c)
		img.set_pixel(w - 1, y, outline_c)
		
	# Subtle inner grid pattern
	for y in range(4, h - 4, 8):
		for x in range(4, w - 4, 8):
			img.set_pixel(x, y, light_c.lerp(main_c, 0.5))
			
	return img

func _create_l_shape(main_c: Color, dark_c: Color, light_c: Color) -> Image:
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var outline_c = dark_c.darkened(0.35)
	# 3 blocks of 32x32: bottom-left (0..31, 32..63), top-left (0..31, 0..31), bottom-right (32..63, 32..63)
	for y in range(64):
		for x in range(64):
			if x >= 32 and y < 32:
				img.set_pixel(x, y, Color(0, 0, 0, 0)) # Empty quadrant
			else:
				img.set_pixel(x, y, main_c)
				
	# Shading and borders on filled regions
	for x in range(32):
		img.set_pixel(x, 0, outline_c)
		img.set_pixel(x, 1, light_c)
	for x in range(32, 64):
		img.set_pixel(x, 32, outline_c)
		img.set_pixel(x, 33, light_c)
	for x in range(64):
		img.set_pixel(x, 62, dark_c)
		img.set_pixel(x, 63, outline_c)
		
	for y in range(64):
		img.set_pixel(0, y, outline_c)
		img.set_pixel(1, y, light_c)
	for y in range(32, 64):
		img.set_pixel(62, y, dark_c)
		img.set_pixel(63, y, outline_c)
	for y in range(32):
		img.set_pixel(31, y, outline_c)
		img.set_pixel(30, y, dark_c)
		
	return img

# ==============================================================================
# 2. SPOT THE DIFFERENCE IMAGES (Task 2: Phòng trọ, Công tơ, Hợp đồng)
# ==============================================================================
func _generate_spot_difference_images():
	print("--- Vẽ Spot the Difference Scenes ---")
	var W = 460
	var H = 220
	
	# MÀN 1: CĂN PHÒNG TRỌ (ẢNH MẪU VS ẢNH THỰC TẾ)
	var img_ad = Image.create(W, H, false, Image.FORMAT_RGBA8)
	var img_real = Image.create(W, H, false, Image.FORMAT_RGBA8)
	_draw_base_room(img_ad, true)
	_draw_base_room(img_real, false)
	_save_img(img_ad, "res://assets/sprites/minigames/spot_diff/room_ad_clean.png")
	_save_img(img_real, "res://assets/sprites/minigames/spot_diff/room_real_traps.png")
	
	# MÀN 2: CÔNG TƠ ĐIỆN & ĐỒNG HỒ NƯỚC (CHUẨN VS GIAN LẬN)
	var img_meter_ok = Image.create(W, H, false, Image.FORMAT_RGBA8)
	var img_meter_bad = Image.create(W, H, false, Image.FORMAT_RGBA8)
	_draw_base_meter(img_meter_ok, true)
	_draw_base_meter(img_meter_bad, false)
	_save_img(img_meter_ok, "res://assets/sprites/minigames/spot_diff/meter_normal.png")
	_save_img(img_meter_bad, "res://assets/sprites/minigames/spot_diff/meter_tampered.png")
	
	# MÀN 3: HỢP ĐỒNG THUÊ TRỌ (CHUẨN VS BẪY ĐIỀU KHOẢN)
	var img_contract_ok = Image.create(W, H, false, Image.FORMAT_RGBA8)
	var img_contract_trap = Image.create(W, H, false, Image.FORMAT_RGBA8)
	_draw_base_contract(img_contract_ok, true)
	_draw_base_contract(img_contract_trap, false)
	_save_img(img_contract_ok, "res://assets/sprites/minigames/spot_diff/contract_fair.png")
	_save_img(img_contract_trap, "res://assets/sprites/minigames/spot_diff/contract_traps.png")

func _draw_base_room(img: Image, is_clean: bool):
	var W = img.get_width()
	var H = img.get_height()
	# Walls (warm cream / teal pastel)
	var wall_c = Color("#E9EDC9")
	var floor_c = Color("#D4A373")
	var baseboard_c = Color("#CCD5AE")
	
	for y in range(H):
		for x in range(W):
			if y < H - 60:
				img.set_pixel(x, y, wall_c)
			else:
				img.set_pixel(x, y, floor_c)
	# Baseboard line
	for x in range(W):
		for by in range(H - 64, H - 60):
			img.set_pixel(x, by, baseboard_c)
			
	# Sink / Vòi nước (left side: x: 30..90, y: 110..170)
	_draw_rect(img, 30, 120, 60, 45, Color("#E29578")) # Sink cabinet
	_draw_rect(img, 35, 110, 50, 12, Color("#EDF6F9")) # Ceramic basin
	# Tap
	var tap_col = Color("#83C5BE") if is_clean else Color("#E76F51") # rusted if bad
	_draw_rect(img, 56, 92, 8, 18, tap_col)
	_draw_rect(img, 50, 92, 14, 6, tap_col)
	if not is_clean:
		# Water drop leaking! (Lỗi 1: Vòi rỉ nước)
		_draw_rect(img, 53, 102, 3, 5, Color("#0077B6"))
		_draw_rect(img, 52, 112, 6, 3, Color("#90E0EF")) # puddle
		
	# Ceiling / Trần nhà (top side: x: 120..220, y: 10..40)
	if not is_clean:
		# Mảng ố vàng nứt dột (Lỗi 2)
		var stain_c = Color("#BC6C25")
		_draw_rect(img, 130, 15, 65, 20, stain_c)
		_draw_rect(img, 140, 35, 45, 10, stain_c.lightened(0.2))
		# Crack line
		for i in range(30):
			img.set_pixel(145 + i, 22 + (i % 3), Color("#283618"))
			
	# Cửa chính & Then khóa (center: x: 230..300, y: 40..160)
	_draw_rect(img, 230, 40, 70, 120, Color("#A3704C")) # Door frame
	_draw_rect(img, 236, 46, 58, 114, Color("#8B5E3C")) # Wood panel
	if is_clean:
		_draw_rect(img, 285, 100, 6, 12, Color("#FFD166")) # Solid gold lock
	else:
		# Ổ khóa bung ốc lệch vẹo (Lỗi 3)
		_draw_rect(img, 283, 102, 8, 10, Color("#D90429"))
		_draw_rect(img, 285, 114, 3, 4, Color("#2B2D42")) # dangling screw
		
	# Cửa sổ & Chuồng cọp (right: x: 330..430, y: 30..110)
	_draw_rect(img, 330, 30, 100, 80, Color("#FFFDF9")) # Window frame
	_draw_rect(img, 336, 36, 88, 68, Color("#CAF0F8")) # Glass
	if is_clean:
		# Chuồng cọp CÓ CỬA THOÁT HIỂM PCCC
		_draw_rect(img, 370, 45, 25, 50, Color("#2A9D8F")) # Green emergency door
		_draw_rect(img, 380, 65, 4, 8, Color("#E9C46A")) # Handle
	else:
		# Chuồng cọp BÍT KÍN SONG SẮT NGUY HIỂM (Lỗi 4)
		for bar_x in range(340, 430, 12):
			_draw_rect(img, bar_x, 36, 4, 68, Color("#6C757D"))
			
	# Ổ cắm điện hở dây (Lỗi 5)
	if is_clean:
		_draw_rect(img, 180, 120, 14, 18, Color("#FFFFFF")) # Clean white plug cover
		_draw_rect(img, 184, 124, 2, 4, Color("#495057"))
		_draw_rect(img, 188, 124, 2, 4, Color("#495057"))
	else:
		_draw_rect(img, 180, 120, 16, 18, Color("#495057"))
		# Exposed copper spark wires!
		img.set_pixel(182, 116, Color("#D90429"))
		img.set_pixel(183, 115, Color("#E76F51"))
		img.set_pixel(190, 116, Color("#E9C46A"))
		img.set_pixel(191, 115, Color("#F4A261"))

func _draw_base_meter(img: Image, is_clean: bool):
	var W = img.get_width()
	var H = img.get_height()
	img.fill(Color("#264653")) # Dark workshop wall
	
	# Electric meter box (Left: x: 40..200, y: 20..200)
	_draw_rect(img, 50, 30, 140, 160, Color("#E9C46A"))
	_draw_rect(img, 60, 40, 120, 140, Color("#F4A261"))
	# Glass dial
	_draw_rect(img, 75, 55, 90, 60, Color("#E0FBFC"))
	# Dial wheel
	var dial_col = Color("#2A9D8F") if is_clean else Color("#E76F51")
	_draw_rect(img, 85, 75, 70, 20, dial_col)
	if not is_clean:
		# Spinning motion lines (Đĩa quay lén khi tắt điện)
		for lx in range(90, 150, 8):
			_draw_rect(img, lx, 70, 2, 30, Color("#C1121F"))
	# Breaker switch
	_draw_rect(img, 105, 130, 30, 40, Color("#1D3557"))
	_draw_rect(img, 115, 140, 10, 20, Color("#E63946")) # Breaker in OFF position
	
	# Water meter (Right: x: 260..410, y: 40..180)
	_draw_rect(img, 270, 45, 130, 130, Color("#457B9D")) # Round pipe body
	_draw_rect(img, 285, 60, 100, 100, Color("#FFFFFF")) # Dial face
	# Needle
	if is_clean:
		_draw_rect(img, 332, 75, 6, 40, Color("#1D3557")) # Still needle
	else:
		_draw_rect(img, 332, 75, 40, 6, Color("#E63946")) # Fast spinning needle
		# Water drop leaking on pipe
		_draw_rect(img, 390, 110, 6, 12, Color("#00B4D8"))
	# Lead seal (Niêm chì)
	if is_clean:
		_draw_rect(img, 260, 105, 12, 12, Color("#CED4DA")) # Intact lead seal
	else:
		_draw_rect(img, 258, 102, 14, 8, Color("#F94144")) # Broken tampered seal!

func _draw_base_contract(img: Image, is_clean: bool):
	var W = img.get_width()
	var H = img.get_height()
	img.fill(Color("#3D405B"))
	# Parchment paper
	_draw_rect(img, 60, 15, 340, 190, Color("#F4F1DE"))
	_draw_rect(img, 66, 20, 328, 180, Color("#FFFDF9"))
	# Header title lines
	_draw_rect(img, 120, 28, 220, 8, Color("#3D405B"))
	_draw_rect(img, 150, 40, 160, 5, Color("#81B29A"))
	
	# Contract clause rows
	var rows = [
		{"y": 60, "len": 280, "trap": false},
		{"y": 80, "len": 260, "trap": not is_clean, "note": "Điện 5000đ/số"},
		{"y": 105, "len": 270, "trap": false},
		{"y": 125, "len": 250, "trap": not is_clean, "note": "Tự ý vào phòng"},
		{"y": 150, "len": 260, "trap": not is_clean, "note": "Mất cọc 100%"},
		{"y": 175, "len": 180, "trap": false}
	]
	for r in rows:
		var col = Color("#E07A5F") if r.trap else Color("#495057")
		_draw_rect(img, 85, r.y, r.len, 6, col)
		if r.trap:
			# Highlight yellow marker / red underline
			_draw_rect(img, 85, r.y - 2, r.len, 10, Color(0.9, 0.2, 0.2, 0.35))
			_draw_rect(img, 85, r.y + 7, r.len, 2, Color("#D90429"))

func _draw_rect(img: Image, rx: int, ry: int, rw: int, rh: int, c: Color):
	for y in range(ry, ry + rh):
		for x in range(rx, rx + rw):
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				img.set_pixel(x, y, c)

# ==============================================================================
# 3. DOCTOR SIMULATION ASSETS (Task 3: Giường bệnh Mèo, Dụng cụ y tế)
# ==============================================================================
func _generate_doctor_assets():
	print("--- Vẽ Doctor Simulation Assets ---")
	# 1. Cat patient shivering in hospital bed (128x128)
	var bed_fever = Image.create(128, 128, false, Image.FORMAT_RGBA8)
	_draw_patient_cat(bed_fever, true)
	_save_img(bed_fever, "res://assets/sprites/minigames/doctor/cat_patient_fever.png")

	var bed_cured = Image.create(128, 128, false, Image.FORMAT_RGBA8)
	_draw_patient_cat(bed_cured, false)
	_save_img(bed_cured, "res://assets/sprites/minigames/doctor/cat_patient_cured.png")

	# 2. Thermometer (32x32)
	var thermo = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	thermo.fill(Color(0, 0, 0, 0))
	_draw_rect(thermo, 8, 4, 16, 24, Color("#FFFFFF"))
	_draw_rect(thermo, 10, 6, 12, 10, Color("#1D3557")) # LCD screen
	_draw_rect(thermo, 12, 8, 8, 6, Color("#E63946"))   # Red digits 39.2
	_draw_rect(thermo, 12, 20, 8, 8, Color("#CED4DA"))   # Probe
	_save_img(thermo, "res://assets/sprites/minigames/doctor/tool_thermometer.png")

	# 3. Warm Towel in Basin (48x48)
	var basin = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	basin.fill(Color(0, 0, 0, 0))
	_draw_rect(basin, 4, 18, 40, 22, Color("#8D5B36"))  # Wood basin
	_draw_rect(basin, 8, 14, 32, 12, Color("#A8DADC"))  # Warm water 37C
	_draw_rect(basin, 12, 8, 24, 16, Color("#FFFDF9"))  # Fluffy folded towel
	_draw_rect(basin, 16, 12, 16, 8, Color("#F4A261"))  # Soft warm stripe
	# Steam vapor lines
	basin.set_pixel(18, 4, Color("#EDF6F9"))
	basin.set_pixel(28, 2, Color("#EDF6F9"))
	_save_img(basin, "res://assets/sprites/minigames/doctor/tool_warm_towel.png")

	# 4. Ice Pack (Bẫy nguy hiểm) (32x32)
	var ice = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	ice.fill(Color(0, 0, 0, 0))
	_draw_rect(ice, 6, 6, 20, 20, Color("#48CAE4"))
	_draw_rect(ice, 10, 10, 12, 12, Color("#ADE8F4"))
	# Red diagonal prohibition slash!
	for i in range(24):
		ice.set_pixel(4 + i, 4 + i, Color("#D90429"))
		ice.set_pixel(4 + i, 5 + i, Color("#D90429"))
	_save_img(ice, "res://assets/sprites/minigames/doctor/tool_ice_pack_trap.png")

	# 5. Paracetamol 500mg Blister (48x32)
	var para = Image.create(48, 32, false, Image.FORMAT_RGBA8)
	para.fill(Color(0, 0, 0, 0))
	_draw_rect(para, 4, 4, 40, 24, Color("#CED4DA")) # Foil blister
	# 4 capsules
	for cx in [8, 16, 24, 32]:
		_draw_rect(para, cx, 8, 6, 8, Color("#E63946"))  # Red top
		_draw_rect(para, cx, 16, 6, 8, Color("#FFB703")) # Yellow bottom
	_save_img(para, "res://assets/sprites/minigames/doctor/tool_para_500.png")

	# 6. Oresol Glass (32x48)
	var oresol_cup = Image.create(32, 48, false, Image.FORMAT_RGBA8)
	oresol_cup.fill(Color(0, 0, 0, 0))
	_draw_rect(oresol_cup, 6, 8, 20, 36, Color("#CAF0F8")) # Glass
	_draw_rect(oresol_cup, 8, 14, 16, 28, Color("#FB8500")) # Orange electrolyte liquid
	_draw_rect(oresol_cup, 18, 2, 4, 42, Color("#FFFDF9")) # Straw
	_save_img(oresol_cup, "res://assets/sprites/minigames/doctor/tool_oresol_cup.png")

func _draw_patient_cat(img: Image, has_fever: bool):
	img.fill(Color(0, 0, 0, 0))
	# Bed frame
	_draw_rect(img, 10, 50, 108, 65, Color("#8D5B36"))
	_draw_rect(img, 16, 56, 96, 54, Color("#FFFDF9")) # Mattress
	
	# Pillow
	_draw_rect(img, 20, 36, 40, 24, Color("#E9ECEF"))
	
	# Cat head
	var cat_c = Color("#E0A96D")
	_draw_rect(img, 28, 28, 28, 24, cat_c)
	# Ears
	_draw_rect(img, 28, 20, 8, 8, cat_c)
	_draw_rect(img, 48, 20, 8, 8, cat_c)
	
	# Eyes & expression
	if has_fever:
		# Slanted weak eyes (sleeping sick)
		_draw_rect(img, 32, 38, 6, 2, Color("#4A2E1B"))
		_draw_rect(img, 46, 38, 6, 2, Color("#4A2E1B"))
		# Fever flushed pink cheeks!
		_draw_rect(img, 30, 42, 6, 4, Color("#FF4D6D"))
		_draw_rect(img, 48, 42, 6, 4, Color("#FF4D6D"))
		# Sweat drops
		img.set_pixel(24, 26, Color("#00B4D8"))
		img.set_pixel(23, 28, Color("#90E0EF"))
	else:
		# Happy twinkling eyes!
		_draw_rect(img, 32, 36, 6, 6, Color("#4A2E1B"))
		_draw_rect(img, 46, 36, 6, 6, Color("#4A2E1B"))
		img.set_pixel(34, 38, Color("#FFFFFF"))
		img.set_pixel(48, 38, Color("#FFFFFF"))
		
	# Blanket covering body
	var blanket_c = Color("#81B29A") if not has_fever else Color("#E07A5F")
	_draw_rect(img, 44, 46, 70, 58, blanket_c)
	_draw_rect(img, 44, 42, 70, 6, Color("#FFFDF9")) # Folded hem

# ==============================================================================
# 4. BUDGET JARS ASSETS (Task 4: 3 Hũ Ngân Sách 2.000.000đ)
# ==============================================================================
func _generate_budget_jars_assets():
	print("--- Vẽ 3 Hũ Ngân Sách Pixel ---")
	# Size: 80x110px each jar
	var jar_w = 80
	var jar_h = 110
	
	var jars = [
		{"name": "jar_essential.png", "col": Color("#2A9D8F"), "label": "50% THIẾT YẾU", "coins": 5},
		{"name": "jar_growth.png", "col": Color("#3A86FF"), "label": "30% PHÁT TRIỂN", "coins": 3},
		{"name": "jar_emergency.png", "col": Color("#E76F51"), "label": "20% KHẨN CẤP", "coins": 2}
	]
	
	for j in jars:
		var img = Image.create(jar_w, jar_h, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		
		# Wooden lid (Nắp gỗ)
		_draw_rect(img, 18, 6, 44, 12, Color("#8D5B36"))
		_draw_rect(img, 24, 2, 32, 6, Color("#A3704C"))
		
		# Glass jar body
		_draw_rect(img, 10, 20, 60, 84, Color("#EDF6F9"))
		# Glass highlights & borders
		for y in range(20, 104):
			img.set_pixel(10, y, Color("#BEE3DB"))
			img.set_pixel(11, y, Color("#FFFFFF"))
			img.set_pixel(69, y, Color("#89B0AE"))
		for x in range(10, 70):
			img.set_pixel(x, 103, Color("#89B0AE"))
			img.set_pixel(x, 104, Color("#555B6E"))
			
		# Golden coins inside
		for c_idx in range(j.coins):
			var cy = 90 - (c_idx * 12)
			_draw_rect(img, 18, cy, 44, 10, Color("#FFB703"))
			_draw_rect(img, 22, cy + 2, 36, 6, Color("#FFE49E"))
			
		# Label badge on front of jar
		_draw_rect(img, 14, 46, 52, 24, j.col)
		_draw_rect(img, 16, 48, 48, 20, Color("#FFFDF9"))
		_draw_rect(img, 20, 56, 40, 4, j.col) # colored strip on label
		
		_save_img(img, "res://assets/sprites/minigames/budget/" + j.name)

# ==============================================================================
# 5. COZY ROOM UPGRADES (Task 5: Xóa bỏ cảm giác AI trống trải, làm đẹp phòng)
# ==============================================================================
func _generate_cozy_room_upgrades():
	print("--- Vẽ Nội Thất Bàn Học & Thảm Decor Cozy ---")
	# 1. Bàn học sinh viên gỗ sồi ấm áp (96x64)
	var desk = Image.create(96, 64, false, Image.FORMAT_RGBA8)
	desk.fill(Color(0, 0, 0, 0))
	# Tabletop
	_draw_rect(desk, 6, 20, 84, 16, Color("#C68B59"))
	_draw_rect(desk, 8, 22, 80, 10, Color("#D89D6A"))
	# Wooden legs
	_draw_rect(desk, 12, 36, 10, 26, Color("#8D5B36"))
	_draw_rect(desk, 74, 36, 10, 26, Color("#8D5B36"))
	# Books on desk
	_draw_rect(desk, 16, 8, 14, 12, Color("#457B9D"))
	_draw_rect(desk, 18, 4, 12, 6, Color("#E63946"))
	# Cozy desk lamp with glowing shade!
	_draw_rect(desk, 64, 12, 16, 8, Color("#F4A261")) # Lamp shade
	_draw_rect(desk, 70, 4, 4, 8, Color("#264653"))   # Lamp stand
	_draw_rect(desk, 60, 18, 24, 6, Color(1, 0.9, 0.6, 0.6)) # Light glow
	_save_img(desk, "res://assets/sprites/room_decor/desk_study_pixel.png")

	# 2. Thảm dải thổ cẩm xinh xắn (120x60)
	var rug = Image.create(120, 60, false, Image.FORMAT_RGBA8)
	rug.fill(Color(0, 0, 0, 0))
	_draw_rect(rug, 4, 6, 112, 48, Color("#E76F51"))
	_draw_rect(rug, 10, 12, 100, 36, Color("#F4A261"))
	_draw_rect(rug, 16, 18, 88, 24, Color("#E9C46A"))
	# Fringe tassels on edges
	for fx in range(4, 116, 6):
		rug.set_pixel(fx, 4, Color("#FFFDF9"))
		rug.set_pixel(fx, 55, Color("#FFFDF9"))
	_save_img(rug, "res://assets/sprites/room_decor/rug_cozy_pixel.png")

func _save_img(img: Image, res_path: String):
	var global_path = ProjectSettings.globalize_path(res_path)
	img.save_png(global_path)
	print("  Saved: ", res_path)
