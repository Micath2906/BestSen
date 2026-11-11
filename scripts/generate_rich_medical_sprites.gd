@tool
extends SceneTree

# generate_rich_medical_sprites.gd - Sinh hình minh họa pixel art 160x100 sắc nét cho Lesson 2 & 3

func _init() -> void:
	print("Generating high-quality 160x100 pixel art illustrations...")
	_generate_lesson2_art()
	_generate_lesson3_art()
	print("All illustrations generated successfully!")
	quit()

# Helper vẽ hình chữ nhật
func draw_rect_fill(img: Image, x0: int, y0: int, w: int, h: int, col: Color) -> void:
	for x in range(x0, x0 + w):
		for y in range(y0, y0 + h):
			if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				img.set_pixel(x, y, col)

func draw_circle_fill(img: Image, cx: int, cy: int, r: int, col: Color) -> void:
	for x in range(cx - r, cx + r + 1):
		for y in range(cy - r, cy + r + 1):
			if (Vector2(x - cx, y - cy).length() <= r) and x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				img.set_pixel(x, y, col)

# Helper vẽ mèo con pixel art
func draw_cat(img: Image, cx: int, cy: int, body_col: Color, ear_col: Color) -> void:
	# Body
	draw_rect_fill(img, cx - 12, cy - 8, 24, 26, body_col)
	# Head
	draw_rect_fill(img, cx - 14, cy - 24, 28, 20, body_col)
	# Ears
	draw_rect_fill(img, cx - 14, cy - 30, 8, 8, ear_col)
	draw_rect_fill(img, cx + 6, cy - 30, 8, 8, ear_col)
	draw_rect_fill(img, cx - 12, cy - 28, 4, 4, Color(1.0, 0.7, 0.7))
	draw_rect_fill(img, cx + 8, cy - 28, 4, 4, Color(1.0, 0.7, 0.7))
	# Eyes
	draw_rect_fill(img, cx - 9, cy - 16, 4, 4, Color(0.15, 0.15, 0.15))
	draw_rect_fill(img, cx + 5, cy - 16, 4, 4, Color(0.15, 0.15, 0.15))
	draw_rect_fill(img, cx - 8, cy - 17, 2, 2, Color(1, 1, 1))
	draw_rect_fill(img, cx + 6, cy - 17, 2, 2, Color(1, 1, 1))
	# Nose & Mouth
	draw_rect_fill(img, cx - 2, cy - 11, 4, 3, Color(0.95, 0.45, 0.5))
	# Whiskers
	draw_rect_fill(img, cx - 19, cy - 13, 5, 1, Color(0.4, 0.3, 0.2))
	draw_rect_fill(img, cx - 19, cy - 10, 5, 1, Color(0.4, 0.3, 0.2))
	draw_rect_fill(img, cx + 14, cy - 13, 5, 1, Color(0.4, 0.3, 0.2))
	draw_rect_fill(img, cx + 14, cy - 10, 5, 1, Color(0.4, 0.3, 0.2))

func _generate_lesson2_art() -> void:
	# =========================================================================
	# 1. Ca 1: Ngã cầu thang gãy chân
	# =========================================================================
	var img1 = Image.create(160, 100, false, Image.FORMAT_RGBA8)
	# Tường phòng trọ màu kem pastel
	draw_rect_fill(img1, 0, 0, 160, 70, Color(0.96, 0.92, 0.85))
	# Sàn gỗ gạch
	draw_rect_fill(img1, 0, 70, 160, 30, Color(0.78, 0.65, 0.52))
	for y in range(70, 100, 8):
		draw_rect_fill(img1, 0, y, 160, 1, Color(0.68, 0.55, 0.42))
	# Bậc thang gác xép bên trái
	for i in range(5):
		draw_rect_fill(img1, 0, 20 + i * 10, 35 - i * 5, 8, Color(0.55, 0.42, 0.30))
	# Lan can tay vịn
	draw_rect_fill(img1, 30, 10, 3, 60, Color(0.45, 0.32, 0.22))
	# Mèo Mướp ngã ngồi bệt ôm chân
	draw_cat(img1, 85, 65, Color(0.95, 0.65, 0.30), Color(0.85, 0.45, 0.15))
	# Chân sưng vù băng bó trắng + túi chườm đá xanh
	draw_rect_fill(img1, 100, 68, 22, 14, Color(0.95, 0.95, 0.95))
	draw_rect_fill(img1, 104, 60, 16, 12, Color(0.35, 0.75, 0.95)) # Ice pack
	# Giọt nước mắt khóc đau
	draw_circle_fill(img1, 74, 52, 2, Color(0.3, 0.7, 0.95))
	draw_circle_fill(img1, 96, 52, 2, Color(0.3, 0.7, 0.95))
	# Dấu chấm than cảnh báo
	draw_rect_fill(img1, 126, 25, 6, 18, Color(0.95, 0.2, 0.2))
	draw_rect_fill(img1, 126, 48, 6, 6, Color(0.95, 0.2, 0.2))
	# Banner chữ nhỏ
	draw_rect_fill(img1, 40, 6, 80, 14, Color(0.2, 0.5, 0.85))
	img1.save_png("res://assets/sprites/skills/lesson_02_step_1.png")

	# =========================================================================
	# 2. Ca 2: Sốt xuất huyết 39.5°C
	# =========================================================================
	var img2 = Image.create(160, 100, false, Image.FORMAT_RGBA8)
	# Tường phòng ngủ
	draw_rect_fill(img2, 0, 0, 160, 65, Color(0.92, 0.94, 0.96))
	# Cửa sổ đêm
	draw_rect_fill(img2, 110, 10, 40, 45, Color(0.25, 0.35, 0.55))
	draw_circle_fill(img2, 138, 24, 7, Color(1.0, 0.95, 0.6)) # Moon
	# Giường nệm trắng
	draw_rect_fill(img2, 15, 50, 130, 45, Color(0.85, 0.88, 0.92))
	draw_rect_fill(img2, 20, 54, 120, 38, Color(1.0, 1.0, 1.0))
	# Gối đầu
	draw_rect_fill(img2, 25, 56, 35, 20, Color(0.95, 0.95, 0.98))
	# Mèo Vàng nằm sốt li bì
	draw_cat(img2, 45, 68, Color(0.96, 0.75, 0.35), Color(0.88, 0.58, 0.2))
	# Khăn đắp trán
	draw_rect_fill(img2, 33, 42, 24, 6, Color(0.4, 0.8, 0.9))
	# Hai má ửng đỏ sốt cao
	draw_circle_fill(img2, 36, 55, 3, Color(0.95, 0.3, 0.3, 0.8))
	draw_circle_fill(img2, 54, 55, 3, Color(0.95, 0.3, 0.3, 0.8))
	# Chấm ban đỏ xuất huyết trên cánh tay
	for p in [Vector2(65, 68), Vector2(72, 65), Vector2(78, 70), Vector2(85, 66), Vector2(90, 72)]:
		draw_circle_fill(img2, int(p.x), int(p.y), 2, Color(0.9, 0.15, 0.15))
	# Nhiệt kế điện tử báo 39.5°C
	draw_rect_fill(img2, 95, 18, 55, 24, Color(0.15, 0.20, 0.28))
	draw_rect_fill(img2, 97, 20, 51, 20, Color(0.1, 0.12, 0.15))
	# Đèn đỏ báo 39.5
	draw_circle_fill(img2, 105, 30, 4, Color(0.95, 0.2, 0.2))
	img2.save_png("res://assets/sprites/skills/lesson_02_step_2.png")

	# =========================================================================
	# 3. Ca 3: Bỏng hóa chất mắt trong nhà vệ sinh
	# =========================================================================
	var img3 = Image.create(160, 100, false, Image.FORMAT_RGBA8)
	# Tường gạch men trắng xanh nhạt
	draw_rect_fill(img3, 0, 0, 160, 75, Color(0.88, 0.95, 0.96))
	for x in range(0, 160, 16):
		draw_rect_fill(img3, x, 0, 1, 75, Color(0.78, 0.88, 0.90))
	for y in range(0, 75, 16):
		draw_rect_fill(img3, 0, y, 160, 1, Color(0.78, 0.88, 0.90))
	# Sàn nhà vệ sinh
	draw_rect_fill(img3, 0, 75, 160, 25, Color(0.65, 0.75, 0.80))
	# Vòi xả nước cấp cứu bên trái
	draw_rect_fill(img3, 20, 25, 8, 30, Color(0.7, 0.75, 0.8))
	draw_rect_fill(img3, 20, 25, 25, 8, Color(0.7, 0.75, 0.8))
	# Tia nước sạch phun xối xả
	for s in range(5):
		draw_rect_fill(img3, 40 + s * 3, 33 + s * 6, 4, 12, Color(0.3, 0.75, 0.95))
	# Mèo Mun đen ôm mắt
	draw_cat(img3, 85, 68, Color(0.25, 0.25, 0.28), Color(0.15, 0.15, 0.18))
	# Mắt trái bị bỏng đỏ ngầu
	draw_rect_fill(img3, 76, 52, 6, 6, Color(0.95, 0.2, 0.2))
	draw_circle_fill(img3, 72, 62, 3, Color(0.3, 0.7, 0.95)) # Giọt nước mắt
	# Chai hóa chất đổ nghiêng bên phải
	draw_rect_fill(img3, 120, 72, 22, 10, Color(0.95, 0.55, 0.15))
	draw_rect_fill(img3, 114, 74, 8, 6, Color(0.8, 0.3, 0.1))
	draw_rect_fill(img3, 100, 78, 14, 4, Color(0.4, 0.85, 0.3)) # Nước tẩy chảy
	img3.save_png("res://assets/sprites/skills/lesson_02_step_3.png")

	# =========================================================================
	# 4. Bước 4: Hồi phục & Xe cấp cứu bệnh viện
	# =========================================================================
	var img4 = Image.create(160, 100, false, Image.FORMAT_RGBA8)
	# Bầu trời xanh ban ngày
	draw_rect_fill(img4, 0, 0, 160, 65, Color(0.70, 0.88, 0.98))
	# Bệnh viện lớn phía sau
	draw_rect_fill(img4, 15, 10, 130, 55, Color(0.96, 0.96, 0.98))
	# Chữ thập đỏ trên đỉnh viện
	draw_rect_fill(img4, 76, 14, 8, 18, Color(0.9, 0.2, 0.2))
	draw_rect_fill(img4, 71, 19, 18, 8, Color(0.9, 0.2, 0.2))
	# Hàng cửa sổ bệnh viện
	for r in range(2):
		for c in range(5):
			draw_rect_fill(img4, 25 + c * 22, 36 + r * 12, 14, 8, Color(0.4, 0.7, 0.9))
	# Mặt đường
	draw_rect_fill(img4, 0, 65, 160, 35, Color(0.55, 0.58, 0.62))
	# Xe cứu thương 115 bên trái
	draw_rect_fill(img4, 10, 60, 48, 22, Color(1, 1, 1))
	draw_rect_fill(img4, 10, 70, 48, 4, Color(0.9, 0.2, 0.2)) # Sọc đỏ
	draw_circle_fill(img4, 20, 82, 5, Color(0.2, 0.2, 0.2))
	draw_circle_fill(img4, 46, 82, 5, Color(0.2, 0.2, 0.2))
	# Còi xe chớp xanh đỏ
	draw_rect_fill(img4, 28, 56, 5, 4, Color(0.95, 0.2, 0.2))
	draw_rect_fill(img4, 34, 56, 5, 4, Color(0.2, 0.5, 0.95))
	# Hai chú mèo vui mừng khỏe mạnh bên phải
	draw_cat(img4, 90, 78, Color(0.95, 0.65, 0.30), Color(0.85, 0.45, 0.15))
	draw_cat(img4, 125, 78, Color(0.45, 0.70, 0.95), Color(0.25, 0.50, 0.85))
	# Trái tim & Dấu tích thành công
	draw_circle_fill(img4, 107, 48, 4, Color(0.95, 0.35, 0.45))
	img4.save_png("res://assets/sprites/skills/lesson_02_step_4.png")

func _generate_lesson3_art() -> void:
	# =========================================================================
	# 1. Ca 1: Sốt cao 38.9°C ban đêm
	# =========================================================================
	var img1 = Image.create(160, 100, false, Image.FORMAT_RGBA8)
	# Đêm tối phòng trọ
	draw_rect_fill(img1, 0, 0, 160, 70, Color(0.18, 0.22, 0.32))
	draw_rect_fill(img1, 0, 70, 160, 30, Color(0.45, 0.38, 0.32))
	# Đồng hồ chỉ 23:30
	draw_circle_fill(img1, 135, 25, 14, Color(0.95, 0.95, 0.95))
	draw_rect_fill(img1, 134, 16, 2, 9, Color(0.2, 0.2, 0.2))
	draw_rect_fill(img1, 135, 24, 7, 2, Color(0.2, 0.2, 0.2))
	# Mèo con trùm chăn sốt
	draw_cat(img1, 60, 68, Color(0.95, 0.70, 0.35), Color(0.85, 0.50, 0.2))
	draw_circle_fill(img1, 51, 55, 3, Color(0.95, 0.3, 0.3))
	draw_circle_fill(img1, 69, 55, 3, Color(0.95, 0.3, 0.3))
	# Nhiệt kế điện tử kẹp nách to rõ phát sáng
	draw_rect_fill(img1, 80, 52, 45, 12, Color(0.95, 0.95, 0.98))
	draw_rect_fill(img1, 125, 54, 12, 8, Color(0.7, 0.75, 0.8)) # Đầu dò kim loại
	draw_rect_fill(img1, 86, 54, 28, 8, Color(0.1, 0.15, 0.2))
	# Chữ số 38.9 đỏ rực
	draw_rect_fill(img1, 88, 56, 24, 4, Color(0.95, 0.2, 0.2))
	# Hộp cứu thương mở nắp bên cạnh
	draw_rect_fill(img1, 95, 72, 35, 20, Color(0.95, 0.95, 0.95))
	draw_rect_fill(img1, 109, 76, 6, 12, Color(0.9, 0.2, 0.2))
	draw_rect_fill(img1, 106, 79, 12, 6, Color(0.9, 0.2, 0.2))
	img1.save_png("res://assets/sprites/skills/lesson_03_step_1.png")

	# =========================================================================
	# 2. Ca 2: Đau bụng tiêu chảy sau ăn ốc
	# =========================================================================
	var img2 = Image.create(160, 100, false, Image.FORMAT_RGBA8)
	draw_rect_fill(img2, 0, 0, 160, 65, Color(0.95, 0.92, 0.86))
	draw_rect_fill(img2, 0, 65, 160, 35, Color(0.75, 0.62, 0.50))
	# Đĩa ốc luộc vỉa hè
	draw_circle_fill(img2, 125, 74, 16, Color(0.92, 0.92, 0.92))
	draw_circle_fill(img2, 122, 70, 4, Color(0.4, 0.3, 0.2))
	draw_circle_fill(img2, 128, 73, 4, Color(0.35, 0.25, 0.15))
	draw_circle_fill(img2, 120, 77, 4, Color(0.45, 0.35, 0.2))
	# Ly nước mía ớt đỏ
	draw_rect_fill(img2, 142, 58, 10, 18, Color(0.85, 0.92, 0.4))
	# Mèo ôm bụng quằn quại
	draw_cat(img2, 55, 68, Color(0.95, 0.70, 0.35), Color(0.85, 0.50, 0.2))
	# Hai tay ôm bụng
	draw_rect_fill(img2, 48, 68, 14, 5, Color(0.85, 0.50, 0.2))
	# Vòng xoáy đau bụng
	draw_circle_fill(img2, 55, 74, 6, Color(0.95, 0.4, 0.2, 0.6))
	# Cuốn sổ theo dõi tiêu hóa
	draw_rect_fill(img2, 85, 52, 24, 30, Color(0.2, 0.55, 0.85))
	draw_rect_fill(img2, 88, 55, 18, 24, Color(1, 1, 1))
	for l in range(4):
		draw_rect_fill(img2, 91, 59 + l * 5, 12, 2, Color(0.6, 0.6, 0.7))
	img2.save_png("res://assets/sprites/skills/lesson_03_step_2.png")

	# =========================================================================
	# 3. Ca 3: Mẩn ngứa mề đay do bụi trọ
	# =========================================================================
	var img3 = Image.create(160, 100, false, Image.FORMAT_RGBA8)
	# Gác xép bụi bặm
	draw_rect_fill(img3, 0, 0, 160, 68, Color(0.88, 0.84, 0.78))
	draw_rect_fill(img3, 0, 68, 160, 32, Color(0.68, 0.58, 0.48))
	# Mạng nhện & bụi bặm ở góc
	draw_rect_fill(img3, 130, 0, 30, 2, Color(0.7, 0.7, 0.7))
	draw_rect_fill(img3, 140, 2, 20, 2, Color(0.7, 0.7, 0.7))
	draw_rect_fill(img3, 150, 4, 10, 2, Color(0.7, 0.7, 0.7))
	# Cây chổi quét nhà
	draw_rect_fill(img3, 125, 35, 4, 45, Color(0.6, 0.4, 0.2))
	draw_rect_fill(img3, 120, 75, 14, 15, Color(0.85, 0.75, 0.3))
	# Mèo hắt xì 'Ắt-xì' & nổi mề đay
	draw_cat(img3, 60, 68, Color(0.95, 0.70, 0.35), Color(0.85, 0.50, 0.2))
	# Mũi đỏ hắt hơi
	draw_circle_fill(img3, 60, 58, 3, Color(0.95, 0.2, 0.2))
	# Mảng mề đay sẩn phù đỏ rực trên tay chân
	draw_circle_fill(img3, 40, 64, 4, Color(0.95, 0.25, 0.25))
	draw_circle_fill(img3, 44, 73, 3, Color(0.95, 0.25, 0.25))
	draw_circle_fill(img3, 76, 66, 4, Color(0.95, 0.25, 0.25))
	draw_circle_fill(img3, 80, 74, 3, Color(0.95, 0.25, 0.25))
	# Kính lúp soi da
	draw_circle_fill(img3, 98, 48, 12, Color(0.3, 0.6, 0.9))
	draw_circle_fill(img3, 98, 48, 9, Color(0.95, 0.98, 1.0))
	draw_circle_fill(img3, 98, 48, 4, Color(0.95, 0.25, 0.25)) # Nốt mề đay dưới kính lúp
	draw_rect_fill(img3, 106, 56, 10, 4, Color(0.2, 0.4, 0.6))
	img3.save_png("res://assets/sprites/skills/lesson_03_step_3.png")

	# =========================================================================
	# 4. Hồi phục khỏe khoắn & Uống đúng thuốc
	# =========================================================================
	var img4 = Image.create(160, 100, false, Image.FORMAT_RGBA8)
	# Phòng trọ sáng sủa rạng rỡ
	draw_rect_fill(img4, 0, 0, 160, 70, Color(0.94, 0.98, 0.94))
	draw_rect_fill(img4, 0, 70, 160, 30, Color(0.72, 0.82, 0.75))
	# Bàn học
	draw_rect_fill(img4, 80, 50, 75, 45, Color(0.85, 0.72, 0.58))
	# Ly nước Oresol bù điện giải
	draw_rect_fill(img4, 90, 42, 12, 18, Color(0.95, 0.85, 0.3))
	# Vỉ thuốc Paracetamol / Berberin bóc sẵn
	draw_rect_fill(img4, 110, 52, 22, 14, Color(0.95, 0.95, 0.98))
	draw_circle_fill(img4, 115, 58, 3, Color(0.2, 0.6, 0.9))
	draw_circle_fill(img4, 125, 58, 3, Color(0.9, 0.8, 0.2))
	# Mèo con hồng hào khỏe mạnh vươn vai
	draw_cat(img4, 45, 68, Color(0.95, 0.70, 0.35), Color(0.85, 0.50, 0.2))
	# Nụ cười tươi
	draw_circle_fill(img4, 40, 56, 2, Color(1, 0.6, 0.6))
	draw_circle_fill(img4, 50, 56, 2, Color(1, 0.6, 0.6))
	# Hào quang lấp lánh xung quanh
	for pt in [Vector2(20, 30), Vector2(70, 25), Vector2(15, 60), Vector2(50, 18)]:
		draw_rect_fill(img4, int(pt.x), int(pt.y), 3, 3, Color(1.0, 0.85, 0.2))
	img4.save_png("res://assets/sprites/skills/lesson_03_step_4.png")
