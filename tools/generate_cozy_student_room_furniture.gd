extends SceneTree

# generate_cozy_student_room_furniture.gd
# Tự động vẽ và xuất 12 món đồ nội thất Pixel Art Cozy cho phòng trọ sinh viên Mèo Tự Lập

const OUT_DIR = "res://assets/sprites/room_decor/"

func _init():
	print(">>> BẮT ĐẦU VẼ 12 MÓN NỘI THẤT COZY PIXEL ART PHÒNG TRỌ SINH VIÊN <<<")
	var g_dir = ProjectSettings.globalize_path(OUT_DIR)
	DirAccess.make_dir_recursive_absolute(g_dir)

	_gen_study_desk()
	_gen_student_bed()
	_gen_wardrobe()
	_gen_wall_bookshelf()
	_gen_mini_pantry()
	_gen_sunlit_window()
	_gen_wall_clock()
	_gen_wall_calendar()
	_gen_fairy_lights()
	_gen_cat_tree()
	_gen_cozy_rug()
	_gen_dual_bowl()

	print(">>> HOÀN THÀNH VẼ TOÀN BỘ 12 NỘI THẤT PHÒNG TRỌ! <<<")
	quit(0)

# Helper: Draw filled rectangle
func _draw_rect(img: Image, x: int, y: int, w: int, h: int, col: Color) -> void:
	for ix in range(x, min(x + w, img.get_width())):
		for iy in range(y, min(y + h, img.get_height())):
			if ix >= 0 and iy >= 0:
				img.set_pixel(ix, iy, col)

# Helper: Draw rect with 1px border
func _draw_box(img: Image, x: int, y: int, w: int, h: int, fill_c: Color, border_c: Color) -> void:
	_draw_rect(img, x, y, w, h, fill_c)
	for ix in range(x, x + w):
		if ix >= 0 and ix < img.get_width():
			if y >= 0 and y < img.get_height(): img.set_pixel(ix, y, border_c)
			if y + h - 1 >= 0 and y + h - 1 < img.get_height(): img.set_pixel(ix, y + h - 1, border_c)
	for iy in range(y, y + h):
		if iy >= 0 and iy < img.get_height():
			if x >= 0 and x < img.get_width(): img.set_pixel(x, iy, border_c)
			if x + w - 1 >= 0 and x + w - 1 < img.get_width(): img.set_pixel(x + w - 1, iy, border_c)

func _save(img: Image, file_name: String) -> void:
	var path = OUT_DIR + file_name
	var g_path = ProjectSettings.globalize_path(path)
	img.save_png(g_path)
	print("  + Đã lưu: ", file_name, " (%dx%d)" % [img.get_width(), img.get_height()])

# 1. BÀN HỌC SINH VIÊN + GHẾ + LAPTOP + ĐÈN HỌC + SÁCH + CỐC (180x140)
func _gen_study_desk() -> void:
	var img = Image.create(180, 140, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Ghế tựa học sinh (đặt lùi phía sau/dưới)
	_draw_box(img, 72, 75, 36, 40, Color("#DDA15E"), Color("#8D5B36")) # Tựa ghế
	for s_y in range(78, 110, 6):
		_draw_rect(img, 76, s_y, 28, 2, Color("#8D5B36")) # Nan gỗ tựa lưng
	_draw_rect(img, 70, 112, 40, 10, Color("#BC6C25")) # Đệm ghế
	_draw_rect(img, 74, 122, 6, 18, Color("#6F4525")) # Chân ghế trái
	_draw_rect(img, 100, 122, 6, 18, Color("#6F4525")) # Chân ghế phải

	# Mặt bàn gỗ sồi (Oak Wood Tabletop)
	_draw_box(img, 10, 48, 160, 24, Color("#D89D6A"), Color("#6F4525"))
	_draw_rect(img, 12, 50, 156, 4, Color("#F4A261")) # Highlight cạnh trên bàn
	_draw_rect(img, 12, 68, 156, 4, Color("#A76D42")) # Đổ bóng mép bàn

	# Hộc tủ bàn bên phải (Drawers)
	_draw_box(img, 126, 72, 40, 62, Color("#C68B59"), Color("#6F4525"))
	# Ngăn kéo 1
	_draw_box(img, 130, 76, 32, 16, Color("#D89D6A"), Color("#8D5B36"))
	_draw_rect(img, 144, 82, 4, 4, Color("#FFD166")) # Núm tay cầm đồng
	# Ngăn kéo 2
	_draw_box(img, 130, 96, 32, 16, Color("#D89D6A"), Color("#8D5B36"))
	_draw_rect(img, 144, 102, 4, 4, Color("#FFD166"))
	# Ngăn kéo 3
	_draw_box(img, 130, 116, 32, 16, Color("#D89D6A"), Color("#8D5B36"))
	_draw_rect(img, 144, 122, 4, 4, Color("#FFD166"))

	# Chân bàn bên trái
	_draw_box(img, 14, 72, 14, 62, Color("#A76D42"), Color("#6F4525"))
	_draw_box(img, 28, 72, 10, 62, Color("#8D5B36"), Color("#6F4525"))
	# Thanh giằng chân bàn
	_draw_rect(img, 24, 110, 102, 8, Color("#8D5B36"))

	# --- ĐỒ ĐẶT TRÊN MẶT BÀN ---
	# 1. Laptop sinh viên mở màn hình (Center)
	_draw_box(img, 68, 20, 44, 28, Color("#1D3557"), Color("#0D1B2A")) # Vỏ laptop
	_draw_box(img, 72, 23, 36, 22, Color("#457B9D"), Color("#1D3557")) # Màn hình bật sáng
	_draw_rect(img, 75, 26, 30, 2, Color("#A8DADC")) # Header trình duyệt/app
	_draw_rect(img, 75, 30, 22, 2, Color("#F1FAEE")) # Dòng code / bài giảng
	_draw_rect(img, 75, 34, 26, 2, Color("#F1FAEE"))
	_draw_rect(img, 75, 38, 18, 2, Color("#A8DADC"))
	# Bàn phím laptop đặt phẳng trên bàn
	_draw_box(img, 66, 48, 48, 6, Color("#415A77"), Color("#1B263B"))
	_draw_rect(img, 84, 50, 12, 2, Color("#E0E1DD")) # Spacebar

	# 2. Đèn bàn học uốn cong ấm áp (Bên phải bàn)
	_draw_rect(img, 140, 12, 16, 12, Color("#2A9D8F")) # Chụp đèn xanh vintage
	_draw_rect(img, 142, 14, 12, 8, Color("#E9C46A")) # Bóng đèn vàng phát sáng
	_draw_rect(img, 146, 24, 4, 24, Color("#264653")) # Cần đèn kim loại
	_draw_rect(img, 140, 46, 16, 4, Color("#264653")) # Đế đèn tròn
	# Vệt sáng đèn vàng rọi xuống bàn
	for ly in range(24, 48):
		var spread = int((ly - 24) * 0.7)
		for lx in range(148 - spread, 148 + spread):
			if lx >= 0 and lx < 180:
				var cur = img.get_pixel(lx, ly)
				img.set_pixel(lx, ly, cur.blend(Color(1.0, 0.95, 0.6, 0.25)))

	# 3. Chồng sách giáo trình đại học (Bên trái bàn)
	_draw_box(img, 24, 38, 30, 10, Color("#E63946"), Color("#9B2226")) # Sách đỏ dày
	_draw_rect(img, 26, 40, 24, 2, Color("#FFFDF9")) # Dòng gáy sách
	_draw_box(img, 26, 30, 26, 8, Color("#3A86FF"), Color("#1D3557")) # Sách xanh
	_draw_rect(img, 28, 32, 20, 2, Color("#FFFDF9"))
	_draw_box(img, 28, 24, 22, 6, Color("#FFB703"), Color("#D4A373")) # Sách vàng

	# 4. Ống cắm bút sinh viên
	_draw_box(img, 56, 36, 10, 14, Color("#E0E1DD"), Color("#778DA9")) # Cốc sứ trắng
	_draw_rect(img, 58, 26, 2, 10, Color("#E63946")) # Bút đỏ
	_draw_rect(img, 61, 24, 2, 12, Color("#3A86FF")) # Bút xanh
	_draw_rect(img, 64, 28, 2, 8, Color("#FFD166"))  # Bút chì vàng

	# 5. Cốc cà phê/trà nóng Mèo Sen
	_draw_box(img, 118, 40, 12, 10, Color("#FFFDF9"), Color("#D4A373"))
	_draw_rect(img, 128, 42, 3, 5, Color("#D4A373")) # Quai cốc
	_draw_rect(img, 120, 42, 8, 3, Color("#6F4525")) # Nước cà phê
	_draw_rect(img, 122, 36, 2, 3, Color(1, 1, 1, 0.6)) # Làn khói 1
	_draw_rect(img, 125, 33, 2, 4, Color(1, 1, 1, 0.5)) # Làn khói 2

	_save(img, "furniture_study_desk.png")

# 2. GIƯỜNG NGỦ NỆM SINH VIÊN ẤM CÚNG (160x120)
func _gen_student_bed() -> void:
	var img = Image.create(160, 120, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Khung thành giường gỗ sồi
	_draw_box(img, 10, 10, 140, 35, Color("#8D5B36"), Color("#5A3A22")) # Đầu giường (Headboard)
	for hy in range(14, 40, 5):
		_draw_rect(img, 14, hy, 132, 2, Color("#A76D42"))

	# Đệm bông trắng êm ái
	_draw_box(img, 14, 38, 132, 70, Color("#FFFDF9"), Color("#E2E8F0"))

	# Chăn bông ấm áp phủ giường (Quilt with Cozy Plaid Pattern)
	_draw_box(img, 14, 56, 132, 52, Color("#E76F51"), Color("#9C4221"))
	# Họa tiết ca-rô / sọc chăn ấm áp
	for qx in range(20, 140, 14):
		_draw_rect(img, qx, 58, 2, 48, Color("#F4A261"))
	for qy in range(62, 106, 10):
		_draw_rect(img, 16, qy, 128, 2, Color("#F4A261"))

	# Mép chăn lật gấp nếp ở ngực
	_draw_box(img, 14, 52, 132, 8, Color("#FFF3B0"), Color("#E9C46A"))

	# 2 Chiếc gối êm ái (Plush Pillows)
	_draw_box(img, 24, 28, 48, 22, Color("#FFFFFF"), Color("#CBD5E1"))
	_draw_rect(img, 26, 30, 44, 4, Color("#F8FAFC")) # Phồng gối
	_draw_box(img, 88, 28, 48, 22, Color("#FFFFFF"), Color("#CBD5E1"))
	_draw_rect(img, 90, 30, 44, 4, Color("#F8FAFC"))

	# Chú gấu bông nhỏ / gối ôm mèo ở giữa
	_draw_box(img, 68, 42, 24, 18, Color("#DDA15E"), Color("#8D5B36")) # Thân gấu
	_draw_rect(img, 72, 40, 4, 4, Color("#BC6C25")) # Tai trái
	_draw_rect(img, 84, 40, 4, 4, Color("#BC6C25")) # Tai phải
	_draw_rect(img, 76, 46, 8, 6, Color("#FFE8D6")) # Mõm
	_draw_rect(img, 79, 48, 2, 2, Color("#6F4525")) # Mũi gấu

	# Khung chân giường gỗ
	_draw_box(img, 10, 106, 140, 10, Color("#8D5B36"), Color("#5A3A22"))
	_draw_rect(img, 12, 114, 10, 6, Color("#5A3A22")) # Chân trái
	_draw_rect(img, 138, 114, 10, 6, Color("#5A3A22")) # Chân phải

	_save(img, "furniture_student_bed.png")

# 3. TỦ QUẦN ÁO & GIÁ TREO ĐỒ SINH VIÊN (105x170)
func _gen_wardrobe() -> void:
	var img = Image.create(105, 170, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Khung tủ gỗ thông (Wardrobe Main Body)
	_draw_box(img, 6, 8, 93, 156, Color("#C68B59"), Color("#5A3A22"))
	_draw_rect(img, 10, 12, 85, 4, Color("#D89D6A"))

	# Ngăn trên cùng (Top Hat/Bag Shelf)
	_draw_box(img, 10, 14, 85, 34, Color("#8D5B36"), Color("#5A3A22"))
	# Balo sinh viên vàng-cam đặt trên ngăn tủ
	_draw_box(img, 24, 20, 24, 24, Color("#FFB703"), Color("#D4A373"))
	_draw_rect(img, 30, 24, 12, 12, Color("#FB8500")) # Túi trước
	_draw_rect(img, 32, 16, 8, 4, Color("#8D5B36")) # Quai đeo balo
	# Mũ lưỡi trai sinh viên
	_draw_box(img, 58, 26, 22, 12, Color("#3A86FF"), Color("#1D3557"))
	_draw_rect(img, 54, 34, 12, 4, Color("#1D3557")) # Lưỡi trai

	# Khoang treo quần áo giữa (Open Hanging Rail)
	_draw_box(img, 10, 50, 85, 75, Color("#F4EDE2"), Color("#5A3A22"))
	_draw_rect(img, 12, 54, 81, 3, Color("#5A3A22")) # Thanh sắt treo đồ

	# Áo 1: Áo sơ mi trắng sinh viên
	_draw_box(img, 18, 57, 18, 42, Color("#FFFFFF"), Color("#CBD5E1"))
	_draw_rect(img, 24, 57, 6, 6, Color("#3B82F6")) # Cà vạt xanh nhỏ
	_draw_rect(img, 26, 64, 2, 28, Color("#94A3B8")) # Hàng khuy áo

	# Áo 2: Áo hoodie xanh navy ấm áp
	_draw_box(img, 42, 57, 24, 46, Color("#1D3557"), Color("#0D1B2A"))
	_draw_rect(img, 48, 59, 12, 10, Color("#457B9D")) # Mũ hoodie
	_draw_rect(img, 46, 76, 16, 12, Color("#457B9D")) # Túi bụng

	# Áo 3: Áo khoác len mùa đông vàng ấm
	_draw_box(img, 70, 57, 20, 48, Color("#E9C46A"), Color("#BC6C25"))
	for ay in range(63, 100, 6):
		_draw_rect(img, 72, ay, 16, 2, Color("#DDA15E"))

	# 2 Ngăn kéo dưới chân tủ (Bottom Drawers)
	_draw_box(img, 10, 128, 85, 16, Color("#D89D6A"), Color("#5A3A22"))
	_draw_rect(img, 48, 134, 8, 4, Color("#FFD166")) # Tay nắm ngăn 1
	_draw_box(img, 10, 146, 85, 16, Color("#D89D6A"), Color("#5A3A22"))
	_draw_rect(img, 48, 152, 8, 4, Color("#FFD166")) # Tay nắm ngăn 2

	# 2 Chân tủ
	_draw_rect(img, 12, 164, 10, 4, Color("#5A3A22"))
	_draw_rect(img, 83, 164, 10, 4, Color("#5A3A22"))

	_save(img, "furniture_wardrobe.png")

# 4. KỆ SÁCH TREO TƯỜNG ĐẦY SÁCH & CÂY SEN ĐÁ (150x55)
func _gen_wall_bookshelf() -> void:
	var img = Image.create(150, 55, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Tầng trên: Tấm gỗ
	_draw_box(img, 10, 8, 130, 8, Color("#D89D6A"), Color("#6F4525"))
	_draw_rect(img, 12, 10, 126, 2, Color("#F4A261"))
	# E-ke đỡ tầng trên
	_draw_rect(img, 16, 16, 6, 8, Color("#6F4525"))
	_draw_rect(img, 128, 16, 6, 8, Color("#6F4525"))

	# Sách tầng trên
	_draw_box(img, 20, -10 + 8, 8, 10, Color("#E63946"), Color("#9B2226"))
	_draw_box(img, 28, -12 + 8, 10, 12, Color("#3A86FF"), Color("#1D3557"))
	_draw_box(img, 38, -8 + 8, 8, 8, Color("#2A9D8F"), Color("#1D3557"))
	# Khung ảnh kỷ niệm nhỏ
	_draw_box(img, 68, -12 + 8, 16, 12, Color("#FFFDF9"), Color("#8D5B36"))
	_draw_rect(img, 72, -8 + 8, 8, 6, Color("#F4A261"))
	# Chậu cây sen đá nhỏ
	_draw_box(img, 106, -6 + 8, 12, 6, Color("#E07A5F"), Color("#8D5B36")) # Chậu đất nung
	_draw_rect(img, 108, -14 + 8, 8, 8, Color("#52B788")) # Cây xanh
	_draw_rect(img, 110, -12 + 8, 4, 4, Color("#74C69D"))

	# Tầng dưới: Tấm gỗ
	_draw_box(img, 10, 34, 130, 8, Color("#D89D6A"), Color("#6F4525"))
	_draw_rect(img, 12, 36, 126, 2, Color("#F4A261"))
	_draw_rect(img, 16, 42, 6, 8, Color("#6F4525"))
	_draw_rect(img, 128, 42, 6, 8, Color("#6F4525"))

	# Hàng sách tầng dưới (Nhiều sách)
	var colors = [Color("#E63946"), Color("#457B9D"), Color("#2A9D8F"), Color("#F4A261"), Color("#9C6644"), Color("#7209B7"), Color("#3F37C9")]
	var bx = 22
	for c in colors:
		var bh = 14 + (bx % 5)
		_draw_box(img, bx, 34 - bh, 8, bh, c, Color("#3D2614"))
		bx += 9

	_save(img, "furniture_wall_bookshelf.png")

# 5. TỦ LẠNH MINI + ẤM SIÊU TỐC + MÌ LY SINH VIÊN (80x120)
func _gen_mini_pantry() -> void:
	var img = Image.create(80, 120, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Tủ lạnh mini (Mini Fridge)
	_draw_box(img, 8, 42, 64, 72, Color("#F8FAFC"), Color("#64748B"))
	_draw_rect(img, 10, 44, 60, 4, Color("#FFFFFF")) # Bóng sáng nóc tủ
	# Cánh cửa tủ lạnh
	_draw_box(img, 12, 50, 56, 60, Color("#F1F5F9"), Color("#94A3B8"))
	_draw_rect(img, 58, 65, 4, 16, Color("#64748B")) # Tay nắm dọc
	# Nam châm gắn tủ lạnh (Magnet stickers: hình mèo & sticker quả cam)
	_draw_rect(img, 20, 56, 8, 8, Color("#FFB703")) # Sticker cam
	_draw_rect(img, 36, 68, 10, 12, Color("#E2E8F0")) # Note giấy ghi nhớ
	_draw_rect(img, 38, 72, 6, 2, Color("#3B82F6"))
	_draw_rect(img, 38, 76, 6, 2, Color("#3B82F6"))

	# 4 Chân tủ lạnh
	_draw_rect(img, 12, 114, 8, 4, Color("#334155"))
	_draw_rect(img, 60, 114, 8, 4, Color("#334155"))

	# --- ĐỒ TRÊN NÓC TỦ LẠNH ---
	# 1. Ấm đun siêu tốc inox (Electric Kettle)
	_draw_box(img, 16, 18, 22, 22, Color("#CBD5E1"), Color("#475569"))
	_draw_rect(img, 18, 14, 18, 4, Color("#334155")) # Nắp ấm đen
	_draw_rect(img, 12, 22, 4, 12, Color("#334155")) # Quai ấm
	_draw_rect(img, 37, 20, 3, 6, Color("#94A3B8"))  # Vòi rót
	_draw_rect(img, 34, 36, 3, 3, Color("#EF4444"))  # Đèn báo đỏ sáng

	# 2. Hộp mì tôm ly sinh viên (Cup Noodles)
	_draw_box(img, 46, 22, 14, 18, Color("#FF0054"), Color("#9E0038")) # Ly mì đỏ
	_draw_rect(img, 48, 20, 10, 3, Color("#FFD166")) # Nắp giấy hé mở
	_draw_rect(img, 48, 26, 10, 6, Color("#FFFDF9")) # Nhãn ly
	_draw_rect(img, 50, 28, 6, 2, Color("#FF0054"))
	# Đôi đũa tre cắm trên ly
	_draw_rect(img, 52, 12, 2, 10, Color("#C68B59"))
	_draw_rect(img, 55, 10, 2, 12, Color("#C68B59"))

	# 3. Cốc uống nước sứ xanh
	_draw_box(img, 64, 28, 8, 12, Color("#38BDF8"), Color("#0284C7"))
	_draw_rect(img, 72, 32, 2, 5, Color("#0284C7"))

	_save(img, "furniture_mini_pantry.png")

# 6. CỬA SỔ LỚN ĐÓN NẮNG BẦU TRỜI & RÈM CỬA (160x180)
func _gen_sunlit_window() -> void:
	var img = Image.create(160, 180, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Khung cửa sổ gỗ ngoài
	_draw_box(img, 14, 14, 132, 142, Color("#8D5B36"), Color("#5A3A22"))
	_draw_box(img, 20, 20, 120, 130, Color("#A76D42"), Color("#5A3A22"))

	# Bầu trời xanh mây trắng trong lành bên ngoài (Sky Gradient)
	for sy in range(24, 146):
		var ratio = float(sy - 24) / 122.0
		var sky_c = Color("#58A4B0").lerp(Color("#D8F3DC"), ratio * 0.8)
		for sx in range(24, 136):
			img.set_pixel(sx, sy, sky_c)

	# Mây trắng trôi bềnh bồng (Pixel Clouds)
	_draw_rect(img, 36, 48, 36, 12, Color("#FFFFFF"))
	_draw_rect(img, 42, 42, 24, 6, Color("#FFFFFF"))
	_draw_rect(img, 78, 70, 44, 14, Color("#FFFFFF"))
	_draw_rect(img, 86, 64, 28, 6, Color("#FFFFFF"))

	# Thanh nan chia ô cửa sổ hình chữ thập (+)
	_draw_rect(img, 77, 24, 6, 122, Color("#6F4525"))
	_draw_rect(img, 24, 82, 112, 6, Color("#6F4525"))

	# Rèm cửa voan vàng cam hai bên ấm cúng (Curtains)
	# Rèm bên trái
	_draw_box(img, 16, 14, 28, 120, Color("#FDE047"), Color("#D97706"))
	_draw_rect(img, 22, 18, 16, 112, Color("#FEF08A"))
	_draw_box(img, 18, 75, 26, 8, Color("#F97316"), Color("#C2410C")) # Nơ thắt rèm trái

	# Rèm bên phải
	_draw_box(img, 116, 14, 28, 120, Color("#FDE047"), Color("#D97706"))
	_draw_rect(img, 122, 18, 16, 112, Color("#FEF08A"))
	_draw_box(img, 116, 75, 26, 8, Color("#F97316"), Color("#C2410C")) # Nơ thắt rèm phải

	# Bậu cửa sổ gỗ dày (Window Sill)
	_draw_box(img, 10, 150, 140, 12, Color("#D89D6A"), Color("#5A3A22"))
	_draw_rect(img, 12, 152, 136, 3, Color("#F4A261"))

	# Chậu hoa nhỏ xinh xắn trên bậu cửa sổ
	_draw_box(img, 70, 142, 18, 10, Color("#FFFDF9"), Color("#8D5B36")) # Chậu sứ
	_draw_rect(img, 72, 134, 14, 8, Color("#22C55E")) # Lá cây
	_draw_rect(img, 76, 130, 6, 6, Color("#FF006E"))  # Bông hoa đỏ hồng
	_draw_rect(img, 78, 132, 2, 2, Color("#FFBE0B"))  # Nhụy vàng

	_save(img, "furniture_sunlit_window.png")

# 7. ĐỒNG HỒ TREO TƯỜNG GỖ TRÒN (36x36)
func _gen_wall_clock() -> void:
	var img = Image.create(36, 36, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Khung tròn gỗ
	_draw_box(img, 4, 4, 28, 28, Color("#8D5B36"), Color("#5A3A22"))
	_draw_box(img, 7, 7, 22, 22, Color("#FFFDF9"), Color("#A76D42"))
	# Vạch chia 12, 3, 6, 9 giờ
	img.set_pixel(18, 9, Color("#334155")) # 12h
	img.set_pixel(27, 18, Color("#334155")) # 3h
	img.set_pixel(18, 27, Color("#334155")) # 6h
	img.set_pixel(9, 18, Color("#334155"))  # 9h
	# Tâm đồng hồ
	img.set_pixel(18, 18, Color("#EF4444"))
	# Kim giờ chỉ 10h, kim phút chỉ 2h
	img.set_pixel(16, 15, Color("#0F172A"))
	img.set_pixel(15, 13, Color("#0F172A"))
	img.set_pixel(20, 16, Color("#0F172A"))
	img.set_pixel(22, 14, Color("#0F172A"))
	img.set_pixel(24, 12, Color("#0F172A"))

	_save(img, "furniture_wall_clock.png")

# 8. LỊCH TREO TƯỜNG THÁNG (40x48)
func _gen_wall_calendar() -> void:
	var img = Image.create(40, 48, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Thanh móc treo & đinh đỏ
	_draw_rect(img, 18, 2, 4, 4, Color("#DC2626"))
	_draw_rect(img, 8, 6, 24, 2, Color("#475569"))

	# Tờ lịch giấy trắng
	_draw_box(img, 4, 8, 32, 38, Color("#FFFDF9"), Color("#CBD5E1"))
	# Header tháng màu cam/đỏ
	_draw_rect(img, 6, 10, 28, 8, Color("#E11D48"))
	_draw_rect(img, 12, 12, 16, 4, Color("#FFFDF9")) # Chữ "THÁNG"

	# Lưới ngày (Calendar Days Grid)
	for gy in range(22, 42, 4):
		for gx in range(8, 32, 4):
			img.set_pixel(gx, gy, Color("#94A3B8"))
	# Đánh dấu sao đỏ ngày quan trọng (Ngày nộp tiền trọ / nhận học bổng)
	img.set_pixel(16, 30, Color("#E11D48"))
	img.set_pixel(17, 30, Color("#E11D48"))
	img.set_pixel(16, 31, Color("#E11D48"))

	_save(img, "furniture_wall_calendar.png")

# 9. DÂY CỜ ĐUÔI NHEO & ĐÈN ĐOM ĐÓM FAIRY LIGHTS (440x26)
func _gen_fairy_lights() -> void:
	var img = Image.create(440, 26, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Dây thừng mảnh uốn lượn hình sin nhẹ
	for x in range(10, 430):
		var y = int(6.0 + sin(float(x) / 32.0) * 4.0)
		img.set_pixel(x, y, Color("#6F4525"))

	# Các lá cờ đuôi nheo tam giác sắc màu + bóng đèn led lung linh
	var flag_colors = [Color("#FF595E"), Color("#FFCA3A"), Color("#8AC926"), Color("#1982C4"), Color("#6A4C93"), Color("#FF924C")]
	var f_idx = 0
	for x in range(24, 420, 24):
		var y = int(6.0 + sin(float(x) / 32.0) * 4.0)
		var col = flag_colors[f_idx % flag_colors.size()]
		# Lá cờ tam giác
		for fy in range(y + 1, y + 12):
			var w = 12 - (fy - (y + 1))
			if w > 0:
				for fx in range(x - int(w/2), x + int(w/2)):
					if fx >= 0 and fx < 440:
						img.set_pixel(fx, fy, col)
		# Bóng đèn led vàng lung linh giữa 2 cờ
		if x + 12 < 430:
			var ly = int(6.0 + sin(float(x + 12) / 32.0) * 4.0) + 2
			img.set_pixel(x + 12, ly, Color("#FFF066"))
			img.set_pixel(x + 12, ly + 1, Color("#FFBE0B"))
			img.set_pixel(x + 11, ly, Color(1, 1, 0.6, 0.5))
			img.set_pixel(x + 13, ly, Color(1, 1, 0.6, 0.5))
		f_idx += 1

	_save(img, "furniture_fairy_lights.png")

# 10. NHÀ CÂY MÈO & TRỤ CÀO MÓNG ĐA TẦNG (80x140)
func _gen_cat_tree() -> void:
	var img = Image.create(80, 140, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Đế chân tháp mèo (Base Platform)
	_draw_box(img, 10, 126, 60, 10, Color("#C68B59"), Color("#5A3A22"))
	_draw_rect(img, 12, 128, 56, 2, Color("#F4A261"))

	# Trụ cào móng quấn thừng sisal (Sisal Scratching Post - Bottom)
	_draw_box(img, 32, 80, 16, 46, Color("#DDA15E"), Color("#8D5B36"))
	for ry in range(82, 126, 3):
		_draw_rect(img, 33, ry, 14, 1, Color("#BC6C25")) # Vân thừng

	# Tầng giữa: Ngôi nhà mèo tròn có cửa tai mèo (Cat Condo)
	_draw_box(img, 16, 50, 48, 30, Color("#FDE047"), Color("#8D5B36"))
	_draw_rect(img, 18, 52, 44, 4, Color("#FEF08A"))
	# Cửa hang hình đầu mèo
	_draw_box(img, 30, 60, 20, 18, Color("#4A2E1B"), Color("#2E1C0C"))
	_draw_rect(img, 32, 58, 4, 3, Color("#4A2E1B")) # Tai trái
	_draw_rect(img, 44, 58, 4, 3, Color("#4A2E1B")) # Tai phải

	# Trụ cào móng tầng trên
	_draw_box(img, 34, 20, 12, 30, Color("#DDA15E"), Color("#8D5B36"))
	for ry in range(22, 50, 3):
		_draw_rect(img, 35, ry, 10, 1, Color("#BC6C25"))

	# Bệ ngắm cảnh cao nhất trên đỉnh (Top Observation Perch)
	_draw_box(img, 20, 10, 40, 10, Color("#FFFDF9"), Color("#8D5B36")) # Đệm êm
	_draw_rect(img, 22, 12, 36, 6, Color("#F1F5F9"))
	_draw_box(img, 18, 18, 44, 4, Color("#C68B59"), Color("#5A3A22")) # Khung gỗ dưới

	# Quả bóng bông đung đưa treo dưới bệ
	_draw_rect(img, 24, 20, 1, 14, Color("#6F4525")) # Sợi dây
	_draw_box(img, 21, 34, 7, 7, Color("#FF006E"), Color("#C2185B")) # Quả bóng len hồng

	_save(img, "furniture_cat_tree.png")

# 11. THẢM TRẢI SÀN BOHO HÌNH THOI LỚN SANG TRỌNG (260x120)
func _gen_cozy_rug() -> void:
	var img = Image.create(260, 120, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Viền ngoài thảm dệt ấm áp
	_draw_box(img, 10, 8, 240, 104, Color("#E76F51"), Color("#9C4221"))
	_draw_box(img, 16, 14, 228, 92, Color("#FFF8F0"), Color("#F4A261"))
	_draw_box(img, 22, 20, 216, 80, Color("#F4A261"), Color("#E76F51"))
	_draw_box(img, 28, 26, 204, 68, Color("#E9C46A"), Color("#D4A373"))
	_draw_box(img, 34, 32, 192, 56, Color("#2A9D8F"), Color("#1D3557"))

	# Hoa văn hình thoi dệt thổ cẩm ở trung tâm (Boho Diamonds)
	for d_center_x in [70, 130, 190]:
		var cy = 60
		for r in range(1, 18):
			for dx in range(-r, r + 1):
				var dy = (18 - r)
				var px = d_center_x + dx
				var py1 = cy - dy
				var py2 = cy + dy
				if px >= 0 and px < 260:
					if py1 >= 0 and py1 < 120: img.set_pixel(px, py1, Color("#FFFDF9"))
					if py2 >= 0 and py2 < 120: img.set_pixel(px, py2, Color("#FFFDF9"))
		# Tâm hoa văn
		_draw_rect(img, d_center_x - 4, cy - 4, 8, 8, Color("#FFB703"))

	# Tua rua viền thảm mềm mại ở 2 đầu (Tassels)
	for ty in range(10, 112, 6):
		_draw_rect(img, 4, ty, 6, 2, Color("#FFFDF9"))
		_draw_rect(img, 250, ty, 6, 2, Color("#FFFDF9"))

	_save(img, "furniture_cozy_rug.png")

# 12. KHAY ĂN UỐNG ĐÔI BẰNG SỨ (70x35)
func _gen_dual_bowl() -> void:
	var img = Image.create(70, 35, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Khay đế gỗ sồi
	_draw_box(img, 4, 12, 62, 18, Color("#D89D6A"), Color("#6F4525"))
	_draw_rect(img, 6, 14, 58, 2, Color("#F4A261"))

	# Chén trái: Hạt thức ăn ngon (Cat Kibble Bowl)
	_draw_box(img, 8, 6, 25, 20, Color("#FFFDF9"), Color("#94A3B8"))
	_draw_box(img, 10, 8, 21, 14, Color("#8D5B36"), Color("#5A3A22"))
	# Những viên hạt mèo giòn rụm
	for kx in range(12, 28, 4):
		for ky in range(10, 20, 3):
			img.set_pixel(kx, ky, Color("#DDA15E"))
			img.set_pixel(kx + 1, ky + 1, Color("#BC6C25"))

	# Chén phải: Nước sạch trong veo (Fresh Water Bowl)
	_draw_box(img, 37, 6, 25, 20, Color("#FFFDF9"), Color("#94A3B8"))
	_draw_box(img, 39, 8, 21, 14, Color("#38BDF8"), Color("#0284C7"))
	# Vệt sóng nước long lanh
	_draw_rect(img, 42, 11, 8, 2, Color("#E0F2FE"))
	_draw_rect(img, 45, 14, 10, 2, Color("#BAE6FD"))

	_save(img, "furniture_dual_bowl.png")
