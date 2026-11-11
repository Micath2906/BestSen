@tool
extends SceneTree

# generate_skill_assets.gd
# Tạo toàn bộ 64 pixel-art assets sắc nét (48x48) phục vụ Gamification cho 16 bài học Kỹ Năng Sống.

const ASSET_DIR = "res://assets/sprites/skills/"

func _init():
	print(">>> BẮT ĐẦU TẠO 64 PIXEL-ART ASSETS CHO CÁC BÀI HỌC KỸ NĂNG SỐNG <<<")
	var dir = DirAccess.open("res://assets/sprites/")
	if not dir.dir_exists("skills"):
		dir.make_dir("skills")
		
	for lesson_id in range(1, 17):
		for step_id in range(1, 5):
			var img = Image.create(48, 48, false, Image.FORMAT_RGBA8)
			_draw_asset_for_step(img, lesson_id, step_id)
			var filename = "lesson_%02d_step_%d.png" % [lesson_id, step_id]
			var path = ASSET_DIR + filename
			img.save_png(ProjectSettings.globalize_path(path))
			
	print(">>> ĐÃ TẠO XONG TOÀN BỘ 64 ASSETS TRONG res://assets/sprites/skills/ <<<")
	quit()

# -------------------------------------------------------------
# CÁC HÀM VẼ NGUYÊN THỦY PIXEL ART (HELPERS)
# -------------------------------------------------------------
func _p(img: Image, x: int, y: int, col: Color) -> void:
	if x >= 0 and x < 48 and y >= 0 and y < 48:
		# Alpha blending đơn giản
		var orig = img.get_pixel(x, y)
		if orig.a > 0.0 and col.a < 1.0:
			var blended = orig.lerp(col, col.a)
			blended.a = maxf(orig.a, col.a)
			img.set_pixel(x, y, blended)
		else:
			img.set_pixel(x, y, col)

func _rect(img: Image, x: int, y: int, w: int, h: int, col: Color) -> void:
	for dy in range(h):
		for dx in range(w):
			_p(img, x + dx, y + dy, col)

func _outline_rect(img: Image, x: int, y: int, w: int, h: int, col: Color) -> void:
	for dx in range(w):
		_p(img, x + dx, y, col)
		_p(img, x + dx, y + h - 1, col)
	for dy in range(h):
		_p(img, x, y + dy, col)
		_p(img, x + w - 1, y + dy, col)

func _circle(img: Image, cx: int, cy: int, r: int, col: Color) -> void:
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if dx*dx + dy*dy <= r*r:
				_p(img, cx + dx, cy + dy, col)

func _circle_outline(img: Image, cx: int, cy: int, r: int, col: Color) -> void:
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			var d2 = dx*dx + dy*dy
			if d2 <= r*r and d2 >= (r-1)*(r-1):
				_p(img, cx + dx, cy + dy, col)

func _line(img: Image, x1: int, y1: int, x2: int, y2: int, col: Color) -> void:
	var dx = absi(x2 - x1)
	var dy = -absi(y2 - y1)
	var sx = 1 if x1 < x2 else -1
	var sy = 1 if y1 < y2 else -1
	var err = dx + dy
	var x = x1
	var y = y1
	while true:
		_p(img, x, y, col)
		if x == x2 and y == y2: break
		var e2 = 2 * err
		if e2 >= dy:
			err += dy
			x += sx
		if e2 <= dx:
			err += dx
			y += sy

# Nền đĩa tròn mềm mại phong cách CatUI
func _draw_catui_disc(img: Image, base_col: Color, border_col: Color) -> void:
	_circle(img, 24, 24, 22, border_col)
	_circle(img, 24, 24, 20, base_col)
	# Highlight viền trên
	for dx in range(-16, 17):
		var y = 24 - int(sqrt(20*20 - dx*dx))
		_p(img, 24 + dx, y + 1, Color(1, 1, 1, 0.45))

# -------------------------------------------------------------
# VẼ 64 ASSETS ĐẶC TRƯNG TỪNG BÀI
# -------------------------------------------------------------
func _draw_asset_for_step(img: Image, lesson: int, step: int) -> void:
	var dark = Color(0.22, 0.16, 0.12, 1.0)
	var white = Color(1.0, 1.0, 1.0, 1.0)
	
	match lesson:
		1: # Tra cứu BusMap & Tìm tuyến xe
			match step:
				1: # Định vị vị trí hiện tại: Màn hình điện thoại & Ghim GPS tỏa sóng
					_draw_catui_disc(img, Color(0.88, 0.94, 1.0), Color(0.20, 0.60, 0.95))
					# Bản đồ nền xám nhạt với ô lưới đường phố
					_rect(img, 10, 10, 28, 28, Color(0.93, 0.94, 0.96))
					_outline_rect(img, 10, 10, 28, 28, dark)
					# Con đường xám cắt ngang
					_rect(img, 10, 22, 28, 5, Color(0.80, 0.82, 0.86))
					_rect(img, 22, 10, 5, 28, Color(0.80, 0.82, 0.86))
					# Vạch đứt tim đường vàng
					_line(img, 11, 24, 37, 24, Color(1.0, 0.85, 0.3))
					# Vòng tròn sóng định vị lan tỏa
					_circle_outline(img, 24, 24, 9, Color(0.2, 0.55, 0.95, 0.45))
					_circle_outline(img, 24, 24, 6, Color(0.2, 0.55, 0.95, 0.75))
					# Ghim định vị GPS đỏ (Pin)
					_circle(img, 24, 21, 5, Color(0.92, 0.20, 0.20))
					_circle_outline(img, 24, 21, 5, dark)
					_circle(img, 24, 20, 2, white)
					_p(img, 24, 26, dark)
					_p(img, 24, 27, Color(0.92, 0.20, 0.20))
					# Móng mèo dễ thương góc trên
					_circle(img, 34, 14, 3, Color(1.0, 0.95, 0.90))
					_circle_outline(img, 34, 14, 3, dark)
				2: # Chọn trạm muốn đến: Hồng tâm đích đến 🎯 & cờ trường học
					_draw_catui_disc(img, Color(1.0, 0.94, 0.88), Color(0.95, 0.60, 0.20))
					# Vòng ngoài hồng tâm
					_circle(img, 24, 24, 13, Color(0.95, 0.35, 0.25))
					_circle_outline(img, 24, 24, 13, dark)
					# Vòng trắng
					_circle(img, 24, 24, 9, white)
					_circle_outline(img, 24, 24, 9, dark)
					# Tâm đỏ mục tiêu
					_circle(img, 24, 24, 5, Color(0.95, 0.25, 0.25))
					_circle_outline(img, 24, 24, 5, dark)
					_circle(img, 24, 24, 2, Color(1.0, 0.85, 0.2)) # Điểm vàng chính giữa
					# Dấu tick xanh chuẩn xác góc dưới
					_circle(img, 33, 33, 6, Color(0.25, 0.78, 0.45))
					_circle_outline(img, 33, 33, 6, dark)
					_line(img, 30, 33, 32, 35, white)
					_line(img, 32, 35, 36, 30, white)
				3: # Xem cách đến & Lộ trình: Tuyến xe nối trạm xuất phát và trạm đích
					_draw_catui_disc(img, Color(0.90, 0.96, 0.92), Color(0.25, 0.75, 0.45))
					# Tấm bản đồ cuộn trắng ngà
					_rect(img, 10, 11, 28, 26, Color(0.97, 0.96, 0.92))
					_outline_rect(img, 10, 11, 28, 26, dark)
					# Điểm đón A (xanh lá)
					_circle(img, 16, 29, 3, Color(0.2, 0.7, 0.3))
					_circle_outline(img, 16, 29, 3, dark)
					# Điểm đích B (đỏ)
					_circle(img, 32, 17, 3, Color(0.9, 0.2, 0.2))
					_circle_outline(img, 32, 17, 3, dark)
					# Tuyến đường nối A -> khúc cua -> B
					_line(img, 16, 26, 16, 20, Color(0.2, 0.55, 0.9))
					_line(img, 16, 20, 26, 20, Color(0.2, 0.55, 0.9))
					_line(img, 26, 20, 32, 20, Color(0.2, 0.55, 0.9))
					# Biểu tượng xe buýt mini đang di chuyển trên tuyến
					_rect(img, 19, 17, 8, 6, Color(1.0, 0.85, 0.2))
					_outline_rect(img, 19, 17, 8, 6, dark)
					_circle(img, 21, 23, 1, dark)
					_circle(img, 25, 23, 1, dark)
				4: # Canh giờ xe cập bến: Đồng hồ ETA đếm lùi thời gian
					_draw_catui_disc(img, Color(1.0, 0.96, 0.88), Color(0.95, 0.65, 0.20))
					# Vỏ đồng hồ bấm giờ
					_circle(img, 24, 25, 14, Color(0.95, 0.92, 0.85))
					_circle_outline(img, 24, 25, 14, dark)
					# Nút bấm trên đỉnh
					_rect(img, 23, 8, 2, 4, dark)
					_rect(img, 21, 7, 6, 2, dark)
					# Mặt đồng hồ trắng
					_circle(img, 24, 25, 11, white)
					# Kim phút và kim giây đếm lùi
					_line(img, 24, 25, 24, 18, dark) # Kim dài
					_line(img, 24, 25, 30, 25, Color(0.9, 0.2, 0.2)) # Kim đỏ
					_p(img, 24, 25, dark)
					# Huy hiệu "ETA 3m" ở góc trên phải
					_rect(img, 28, 12, 10, 6, Color(0.2, 0.6, 0.95))
					_outline_rect(img, 28, 12, 10, 6, dark)
					_p(img, 30, 15, white)
					_p(img, 32, 14, white)
					_p(img, 34, 15, white)

		2: # Bắt xe buýt liên quận
			match step:
				1: # Vẫy xe từ xa: Xe buýt xanh đang tới & bàn tay vẫy
					_draw_catui_disc(img, Color(0.85, 0.94, 1.0), Color(0.35, 0.65, 0.95))
					# Thân xe buýt
					_rect(img, 12, 12, 24, 22, Color(0.20, 0.55, 0.90))
					_outline_rect(img, 12, 12, 24, 22, dark)
					# Bảng tuyến xe
					_rect(img, 16, 14, 16, 4, Color(0.1, 0.1, 0.1))
					_rect(img, 18, 15, 12, 2, Color(1.0, 0.85, 0.2)) # Chữ số 08 vàng
					# Kính chắn gió
					_rect(img, 14, 19, 20, 8, Color(0.75, 0.92, 1.0))
					_line(img, 24, 19, 24, 26, dark)
					# Đèn xe
					_circle(img, 15, 30, 2, Color(1.0, 0.90, 0.3))
					_circle(img, 33, 30, 2, Color(1.0, 0.90, 0.3))
					# Cản trước
					_rect(img, 14, 32, 20, 3, Color(0.3, 0.3, 0.3))
					# Bàn tay móng mèo vẫy ở góc trên phải
					_circle(img, 37, 13, 5, Color(1.0, 0.94, 0.88))
					_circle_outline(img, 37, 13, 5, dark)
					_circle(img, 37, 13, 2, Color(0.95, 0.55, 0.65)) # Móng hồng
					_line(img, 41, 7, 44, 4, Color(1.0, 0.8, 0.2)) # Tia vẫy
				2: # Cầm sẵn tiền lẻ: Tờ tiền xanh 5k & đồng xu
					_draw_catui_disc(img, Color(0.90, 0.98, 0.92), Color(0.25, 0.75, 0.45))
					# Tờ tiền 5.000đ màu xanh bạc hà
					_rect(img, 10, 16, 26, 16, Color(0.35, 0.78, 0.55))
					_outline_rect(img, 10, 16, 26, 16, dark)
					_circle(img, 23, 24, 4, Color(0.65, 0.90, 0.75))
					_rect(img, 12, 18, 4, 3, Color(0.85, 0.98, 0.90))
					_rect(img, 30, 27, 4, 3, Color(0.85, 0.98, 0.90))
					# Đồng xu vàng đè góc
					_circle(img, 32, 28, 7, Color(1.0, 0.80, 0.15))
					_circle_outline(img, 32, 28, 7, dark)
					_circle(img, 32, 28, 4, Color(1.0, 0.92, 0.45))
					_p(img, 32, 28, Color(0.7, 0.4, 0.0))
				3: # Ôm ba lô trước ngực: Ba lô cam & móng mèo ôm
					_draw_catui_disc(img, Color(1.0, 0.93, 0.88), Color(0.95, 0.55, 0.25))
					# Quai trên ba lô
					_rect(img, 20, 11, 8, 4, dark)
					# Thân ba lô cam
					_rect(img, 14, 15, 20, 22, Color(0.95, 0.45, 0.22))
					_outline_rect(img, 14, 15, 20, 22, dark)
					# Túi phụ trước ba lô
					_rect(img, 17, 24, 14, 11, Color(1.0, 0.72, 0.40))
					_outline_rect(img, 17, 24, 14, 11, dark)
					_circle(img, 24, 27, 2, Color(1.0, 0.9, 0.3)) # Khóa kéo
					# Hai tay móng mèo ôm hai bên
					_circle(img, 12, 23, 4, Color(1.0, 0.95, 0.90))
					_circle_outline(img, 12, 23, 4, dark)
					_circle(img, 36, 23, 4, Color(1.0, 0.95, 0.90))
					_circle_outline(img, 36, 23, 4, dark)
				4: # Bấm chuông trước 100m: Cột xe buýt vàng & nút chuông đỏ kêu Keng
					_draw_catui_disc(img, Color(1.0, 0.92, 0.94), Color(0.95, 0.35, 0.50))
					# Cột vịn xe buýt vàng
					_rect(img, 22, 6, 4, 36, Color(1.0, 0.80, 0.20))
					_outline_rect(img, 22, 6, 4, 36, dark)
					# Hộp nút chuông
					_rect(img, 17, 16, 14, 16, Color(1.0, 0.96, 0.90))
					_outline_rect(img, 17, 16, 14, 16, dark)
					# Nút tròn đỏ nổi
					_circle(img, 24, 24, 5, Color(0.92, 0.20, 0.20))
					_circle_outline(img, 24, 24, 5, dark)
					_circle(img, 23, 23, 2, Color(1.0, 0.6, 0.6)) # Highlight
					# Sóng âm chuông reo (Keng!)
					_circle_outline(img, 24, 24, 9, Color(1.0, 0.5, 0.2, 0.6))
					_circle_outline(img, 24, 24, 13, Color(1.0, 0.5, 0.2, 0.3))

		3: # Định vị GPS & Thoát bùng binh
			match step:
				1: # Tấp lề an toàn: Xe máy tấp sát vỉa hè
					_draw_catui_disc(img, Color(0.92, 0.95, 0.98), Color(0.3, 0.6, 0.9))
					# Vỉa hè đá xám
					_rect(img, 8, 30, 32, 8, Color(0.7, 0.7, 0.7))
					_line(img, 8, 30, 40, 30, Color(1.0, 0.8, 0.2)) # Vạch vàng
					# Xe máy nhỏ
					_circle(img, 16, 28, 4, dark)
					_circle(img, 28, 28, 4, dark)
					_line(img, 16, 28, 22, 20, Color(0.85, 0.2, 0.2))
					_line(img, 22, 20, 28, 28, Color(0.85, 0.2, 0.2))
					_rect(img, 20, 16, 6, 4, dark) # Tay lái
				2: # La bàn bản đồ
					_draw_catui_disc(img, Color(1.0, 0.96, 0.88), Color(0.9, 0.65, 0.2))
					_circle(img, 24, 24, 14, Color(0.95, 0.82, 0.35))
					_circle_outline(img, 24, 24, 14, dark)
					_circle(img, 24, 24, 11, white)
					# Kim la bàn xanh - đỏ
					_line(img, 24, 24, 24, 15, Color(0.9, 0.2, 0.2)) # Bắc đỏ
					_line(img, 24, 24, 24, 33, Color(0.2, 0.4, 0.8)) # Nam xanh
					_p(img, 24, 24, dark)
				3: # Đếm lối ra bùng binh
					_draw_catui_disc(img, Color(0.90, 0.98, 0.92), Color(0.2, 0.75, 0.45))
					_circle(img, 24, 24, 13, Color(0.6, 0.6, 0.6))
					_circle(img, 24, 24, 6, Color(0.2, 0.7, 0.3)) # Đảo xanh trung tâm
					# 4 nhánh rẽ
					_rect(img, 22, 6, 4, 6, Color(0.6, 0.6, 0.6))
					_rect(img, 22, 36, 4, 6, Color(0.6, 0.6, 0.6))
					_rect(img, 6, 22, 6, 4, Color(0.6, 0.6, 0.6))
					_rect(img, 36, 22, 6, 4, Color(0.6, 0.6, 0.6))
					_circle(img, 32, 16, 3, Color(1.0, 0.8, 0.1)) # Điểm rẽ
				4: # Xi-nhan thoát bùng binh
					_draw_catui_disc(img, Color(1.0, 0.94, 0.88), Color(0.95, 0.5, 0.2))
					# Mũ bảo hiểm & đèn xi nhan vàng rực
					_circle(img, 24, 24, 11, Color(0.2, 0.5, 0.8))
					_circle_outline(img, 24, 24, 11, dark)
					_rect(img, 20, 24, 12, 3, dark) # Kính chắn gió
					# Đèn xi-nhan phải nhấp nháy
					_circle(img, 36, 24, 5, Color(1.0, 0.85, 0.15))
					_line(img, 39, 21, 44, 18, Color(1.0, 0.8, 0.2))
					_line(img, 40, 24, 46, 24, Color(1.0, 0.8, 0.2))
					_line(img, 39, 27, 44, 30, Color(1.0, 0.8, 0.2))

		4: # Cứu hộ xe máy khi hỏng hóc
			match step:
				1: # Dừng xe bật đèn báo khẩn cấp
					_draw_catui_disc(img, Color(1.0, 0.92, 0.90), Color(0.9, 0.3, 0.2))
					# Tam giác cảnh báo đỏ
					_line(img, 24, 11, 13, 33, Color(0.9, 0.2, 0.2))
					_line(img, 24, 11, 35, 33, Color(0.9, 0.2, 0.2))
					_line(img, 13, 33, 35, 33, Color(0.9, 0.2, 0.2))
					_line(img, 24, 13, 16, 31, Color(1.0, 0.8, 0.2))
					_line(img, 24, 13, 32, 31, Color(1.0, 0.8, 0.2))
					_line(img, 16, 31, 32, 31, Color(1.0, 0.8, 0.2))
					_rect(img, 23, 20, 2, 6, dark) # Dấu chấm than
					_rect(img, 23, 28, 2, 2, dark)
				2: # Soi bugi & xăng
					_draw_catui_disc(img, Color(0.92, 0.95, 0.98), Color(0.4, 0.6, 0.8))
					# Cây bugi kim loại
					_rect(img, 22, 10, 4, 10, Color(0.9, 0.9, 0.9)) # Sứ trắng
					_rect(img, 20, 20, 8, 8, Color(0.6, 0.6, 0.6)) # Lục giác
					_rect(img, 22, 28, 4, 8, Color(0.4, 0.4, 0.4)) # Ren vặn
					_line(img, 24, 36, 26, 38, Color(0.2, 0.8, 1.0)) # Tia lửa điện xanh
				3: # Gọi đội SOS sinh viên
					_draw_catui_disc(img, Color(0.90, 0.98, 0.92), Color(0.2, 0.7, 0.35))
					# Điện thoại phát sóng cứu hộ
					_rect(img, 17, 12, 14, 24, Color(0.2, 0.2, 0.2))
					_outline_rect(img, 17, 12, 14, 24, dark)
					_rect(img, 19, 15, 10, 16, Color(0.2, 0.65, 0.35))
					# Chữ SOS trắng
					_circle_outline(img, 24, 24, 15, Color(0.2, 0.7, 0.35, 0.5))
					_circle_outline(img, 24, 24, 18, Color(0.2, 0.7, 0.35, 0.25))
				4: # Giám sát sửa xe trực tiếp
					_draw_catui_disc(img, Color(1.0, 0.96, 0.88), Color(0.9, 0.6, 0.15))
					# Cờ lê và mỏ lết bắt chéo
					_line(img, 14, 14, 34, 34, Color(0.65, 0.7, 0.75))
					_line(img, 14, 34, 34, 14, Color(0.65, 0.7, 0.75))
					_circle(img, 14, 14, 4, Color(0.65, 0.7, 0.75))
					_circle(img, 34, 14, 4, Color(0.65, 0.7, 0.75))
					_circle(img, 24, 24, 5, Color(1.0, 0.8, 0.2)) # Con mắt soi sáng

		5: # Soi hợp đồng thuê trọ
			match step:
				1: # Soi điều khoản cọc
					_draw_catui_disc(img, Color(0.96, 0.94, 0.90), Color(0.8, 0.55, 0.3))
					_rect(img, 14, 10, 20, 28, Color(0.98, 0.96, 0.92))
					_outline_rect(img, 14, 10, 20, 28, dark)
					_line(img, 17, 14, 27, 14, Color(0.8, 0.2, 0.2)) # Dòng cọc đỏ
					_line(img, 17, 18, 30, 18, dark)
					_line(img, 17, 22, 28, 22, dark)
					# Kính lúp soi
					_circle(img, 26, 26, 6, Color(0.85, 0.95, 1.0, 0.8))
					_circle_outline(img, 26, 26, 6, dark)
					_line(img, 31, 31, 37, 37, dark)
				2: # Chốt giá điện nước
					_draw_catui_disc(img, Color(0.92, 0.96, 1.0), Color(0.3, 0.6, 0.9))
					# Đồng hồ điện
					_circle(img, 24, 24, 13, Color(0.92, 0.92, 0.92))
					_circle_outline(img, 24, 24, 13, dark)
					_rect(img, 18, 17, 12, 6, Color(0.1, 0.1, 0.1))
					_line(img, 20, 20, 28, 20, Color(0.2, 0.9, 0.2)) # Số kWh xanh
					# Tia sét vàng
					_line(img, 24, 26, 22, 30, Color(1.0, 0.8, 0.1))
					_line(img, 22, 30, 26, 30, Color(1.0, 0.8, 0.1))
					_line(img, 26, 30, 23, 35, Color(1.0, 0.8, 0.1))
				3: # Chụp ảnh hiện trạng phòng
					_draw_catui_disc(img, Color(1.0, 0.94, 0.92), Color(0.9, 0.45, 0.35))
					_rect(img, 13, 15, 22, 18, Color(0.35, 0.38, 0.42))
					_outline_rect(img, 13, 15, 22, 18, dark)
					_circle(img, 24, 24, 6, Color(0.7, 0.85, 0.95))
					_circle_outline(img, 24, 24, 6, dark)
					_circle(img, 16, 18, 2, Color(1.0, 0.8, 0.2)) # Flash
					_rect(img, 28, 12, 4, 3, dark) # Nút chụp
				4: # Ký giữ hợp đồng gốc
					_draw_catui_disc(img, Color(0.92, 0.98, 0.94), Color(0.2, 0.75, 0.4))
					_rect(img, 13, 10, 22, 28, white)
					_outline_rect(img, 13, 10, 22, 28, dark)
					# Bút máy ký tên
					_line(img, 28, 12, 19, 28, Color(0.15, 0.35, 0.75))
					_circle(img, 26, 30, 3, Color(0.85, 0.2, 0.2)) # Con dấu đỏ
					_line(img, 16, 27, 23, 27, Color(0.15, 0.35, 0.75)) # Chữ ký

		6: # Khảo sát an toàn PCCC
			match step:
				1: # Kiểm tra chuồng cọp có cửa thoát
					_draw_catui_disc(img, Color(0.94, 0.94, 0.96), Color(0.5, 0.5, 0.6))
					# Khung lồng sắt
					_outline_rect(img, 12, 12, 24, 24, dark)
					_line(img, 18, 12, 18, 36, dark)
					_line(img, 24, 12, 24, 36, dark)
					_line(img, 30, 12, 30, 36, dark)
					# Cửa thoát hiểm mở hé & chìa khóa vàng
					_rect(img, 20, 20, 8, 10, Color(0.3, 0.8, 0.4, 0.5))
					_circle(img, 33, 26, 3, Color(1.0, 0.85, 0.2))
				2: # Soi kim bình cứu hỏa
					_draw_catui_disc(img, Color(1.0, 0.92, 0.90), Color(0.9, 0.25, 0.2))
					# Bình cứu hỏa đỏ
					_rect(img, 18, 18, 12, 20, Color(0.88, 0.2, 0.2))
					_outline_rect(img, 18, 18, 12, 20, dark)
					_rect(img, 21, 12, 6, 6, Color(0.3, 0.3, 0.3)) # Cò bóp
					# Đồng hồ áp suất tròn có vạch xanh
					_circle(img, 24, 24, 4, white)
					_p(img, 24, 24, Color(0.1, 0.8, 0.2)) # Kim ở vạch xanh an toàn
				3: # Định vị lối sân thượng
					_draw_catui_disc(img, Color(0.90, 0.98, 0.92), Color(0.2, 0.7, 0.35))
					# Cầu thang sắt thoát hiểm hướng lên
					_line(img, 16, 38, 30, 10, dark)
					_line(img, 22, 38, 36, 10, dark)
					for y_step in [14, 19, 24, 29, 34]:
						_line(img, y_step + 4, 48 - y_step, y_step + 9, 48 - y_step, Color(0.4, 0.5, 0.6))
					_circle(img, 32, 11, 4, Color(1.0, 0.9, 0.3)) # Cửa sáng trời
				4: # Chuẩn bị khăn & đèn pin
					_draw_catui_disc(img, Color(1.0, 0.96, 0.88), Color(0.9, 0.65, 0.2))
					# Khăn ướt xanh
					_rect(img, 12, 22, 14, 12, Color(0.3, 0.65, 0.9))
					_outline_rect(img, 12, 22, 14, 12, dark)
					# Đèn pin vàng chiếu luồng sáng
					_rect(img, 24, 16, 12, 6, Color(0.95, 0.75, 0.2))
					_outline_rect(img, 24, 16, 12, 6, dark)
					_line(img, 36, 16, 44, 11, Color(1.0, 0.9, 0.4))
					_line(img, 36, 22, 44, 27, Color(1.0, 0.9, 0.4))

		7: # Đăng ký tạm trú VNeID
			match step:
				1: # Lấy CCCD chủ trọ
					_draw_catui_disc(img, Color(0.92, 0.96, 0.98), Color(0.3, 0.6, 0.85))
					_rect(img, 11, 14, 26, 18, Color(0.92, 0.96, 0.94))
					_outline_rect(img, 11, 14, 26, 18, dark)
					_rect(img, 14, 18, 5, 5, Color(1.0, 0.8, 0.2)) # Chip vàng
					_circle(img, 28, 22, 4, Color(0.7, 0.5, 0.3)) # Chân dung
				2: # Đăng nhập VNeID mức 2
					_draw_catui_disc(img, Color(0.88, 0.94, 1.0), Color(0.2, 0.55, 0.95))
					_rect(img, 15, 9, 18, 30, Color(0.15, 0.35, 0.75)) # Smartphone VNeID
					_outline_rect(img, 15, 9, 18, 30, dark)
					_circle(img, 24, 22, 6, Color(0.95, 0.8, 0.2)) # Khiên quốc huy
					_line(img, 22, 22, 24, 24, white)
					_line(img, 24, 24, 27, 20, white)
				3: # Tải ảnh hợp đồng trọ
					_draw_catui_disc(img, Color(0.94, 0.92, 0.98), Color(0.6, 0.35, 0.85))
					_rect(img, 14, 14, 20, 22, white)
					_outline_rect(img, 14, 14, 20, 22, dark)
					# Mũi tên xanh tải lên
					_line(img, 24, 18, 24, 28, Color(0.2, 0.7, 0.4))
					_line(img, 24, 18, 20, 22, Color(0.2, 0.7, 0.4))
					_line(img, 24, 18, 28, 22, Color(0.2, 0.7, 0.4))
				4: # Lưu mã hồ sơ phê duyệt
					_draw_catui_disc(img, Color(0.90, 0.98, 0.92), Color(0.2, 0.75, 0.35))
					_rect(img, 13, 13, 22, 22, white)
					_outline_rect(img, 13, 13, 22, 22, dark)
					# Mã QR xanh
					_rect(img, 16, 16, 5, 5, dark)
					_rect(img, 27, 16, 5, 5, dark)
					_rect(img, 16, 27, 5, 5, dark)
					_circle(img, 24, 24, 4, Color(0.2, 0.8, 0.35)) # Dấu duyệt

		8: # Thiết lập hiệp ước bạn cùng phòng
			match step:
				1: # Họp phòng trà sữa
					_draw_catui_disc(img, Color(1.0, 0.94, 0.92), Color(0.9, 0.5, 0.4))
					# 2 ly trà sữa chạm nhau
					_rect(img, 14, 18, 8, 14, Color(0.95, 0.85, 0.75))
					_rect(img, 26, 18, 8, 14, Color(0.85, 0.75, 0.90))
					_p(img, 18, 12, dark) # Ống hút
					_p(img, 30, 12, dark)
					_circle(img, 17, 28, 1, dark) # Trân châu
					_circle(img, 29, 28, 1, dark)
				2: # Dán lịch trực nhật
					_draw_catui_disc(img, Color(0.92, 0.96, 1.0), Color(0.3, 0.6, 0.85))
					_rect(img, 13, 11, 22, 26, white)
					_outline_rect(img, 13, 11, 22, 26, dark)
					_rect(img, 13, 11, 22, 6, Color(0.3, 0.6, 0.85)) # Bìa xanh
					_line(img, 16, 22, 28, 22, Color(0.2, 0.7, 0.3)) # Vạch check
					_line(img, 16, 28, 28, 28, Color(0.2, 0.7, 0.3))
				3: # Tạo app chia tiền quỹ
					_draw_catui_disc(img, Color(1.0, 0.96, 0.88), Color(0.9, 0.7, 0.2))
					_circle(img, 24, 24, 11, Color(0.95, 0.6, 0.7)) # Heo đất hồng
					_circle_outline(img, 24, 24, 11, dark)
					_circle(img, 24, 14, 4, Color(1.0, 0.85, 0.2)) # Đồng xu rơi
				4: # Chốt giờ giới nghiêm
					_draw_catui_disc(img, Color(0.90, 0.92, 0.98), Color(0.4, 0.4, 0.75))
					_circle(img, 24, 24, 13, Color(0.18, 0.2, 0.35))
					_circle_outline(img, 24, 24, 13, dark)
					_line(img, 24, 24, 24, 16, white) # 23h
					_line(img, 24, 24, 20, 24, white)
					_circle(img, 28, 18, 3, Color(1.0, 0.9, 0.4)) # Trăng khuyết

		9: # Sốt cấp tính & Cảm cúm
			match step:
				1: # Kẹp nhiệt kế 38.5°C
					_draw_catui_disc(img, Color(1.0, 0.92, 0.92), Color(0.95, 0.3, 0.3))
					_line(img, 14, 34, 34, 14, Color(0.9, 0.9, 0.9)) # Thân nhiệt kế
					_circle(img, 14, 34, 4, Color(0.9, 0.2, 0.2)) # Bầu thủy ngân đỏ
					_rect(img, 22, 20, 8, 5, white) # Màn hình LCD
					_p(img, 24, 22, Color(0.9, 0.1, 0.1))
				2: # Uống đúng liều Para
					_draw_catui_disc(img, Color(0.92, 0.98, 0.94), Color(0.2, 0.75, 0.4))
					_rect(img, 13, 14, 22, 20, Color(0.9, 0.95, 0.95))
					_outline_rect(img, 13, 14, 22, 20, dark)
					# 4 viên nén trắng
					_circle(img, 18, 19, 3, white)
					_circle(img, 30, 19, 3, white)
					_circle(img, 18, 29, 3, white)
					_circle(img, 30, 29, 3, Color(0.3, 0.6, 0.9))
				3: # Lau khăn nước ấm
					_draw_catui_disc(img, Color(0.92, 0.96, 1.0), Color(0.3, 0.65, 0.9))
					# Chậu nước xanh
					_rect(img, 12, 24, 24, 12, Color(0.4, 0.75, 0.95))
					_outline_rect(img, 12, 24, 24, 12, dark)
					# Khăn vắt mềm
					_rect(img, 16, 16, 16, 10, Color(1.0, 0.95, 0.85))
					_outline_rect(img, 16, 16, 16, 10, dark)
				4: # Uống từng ngụm Oresol
					_draw_catui_disc(img, Color(1.0, 0.96, 0.90), Color(0.95, 0.6, 0.2))
					_rect(img, 17, 16, 14, 20, Color(0.85, 0.95, 1.0, 0.8))
					_outline_rect(img, 17, 16, 14, 20, dark)
					_rect(img, 18, 24, 12, 11, Color(1.0, 0.8, 0.3, 0.7)) # Nước cam oresol
					_line(img, 24, 10, 28, 22, Color(0.9, 0.3, 0.3)) # Ống hút

		10: # Quy trình khám bệnh BHYT
			match step:
				1: # Bốc số BHYT sớm
					_draw_catui_disc(img, Color(0.92, 0.95, 0.98), Color(0.3, 0.55, 0.85))
					_rect(img, 14, 12, 20, 24, white)
					_outline_rect(img, 14, 12, 20, 24, dark)
					_rect(img, 17, 18, 14, 8, Color(0.9, 0.9, 0.9))
					_p(img, 24, 22, dark) # Số 08
				2: # Xuất trình CCCD & BHYT
					_draw_catui_disc(img, Color(0.90, 0.98, 0.94), Color(0.2, 0.7, 0.4))
					_rect(img, 11, 14, 20, 14, Color(0.3, 0.6, 0.85)) # BHYT xanh
					_rect(img, 17, 20, 20, 14, Color(0.95, 0.95, 0.9)) # CCCD vàng
					_circle(img, 21, 21, 3, Color(0.85, 0.2, 0.2)) # Chữ thập đỏ
				3: # Vào gặp bác sĩ khám
					_draw_catui_disc(img, Color(1.0, 0.94, 0.94), Color(0.9, 0.4, 0.4))
					# Ống nghe y tế
					_circle(img, 24, 30, 5, Color(0.65, 0.7, 0.75))
					_circle_outline(img, 24, 30, 5, dark)
					_line(img, 24, 25, 20, 16, dark)
					_line(img, 24, 25, 28, 16, dark)
				4: # Lấy thuốc kho Dược BHYT
					_draw_catui_disc(img, Color(0.94, 0.92, 0.98), Color(0.6, 0.35, 0.85))
					_rect(img, 14, 14, 20, 22, Color(0.96, 0.93, 0.85)) # Túi thuốc
					_outline_rect(img, 14, 14, 20, 22, dark)
					_rect(img, 21, 21, 6, 6, Color(0.2, 0.75, 0.35)) # Dấu cộng xanh

		11: # Tủ thuốc sinh viên chuẩn dược
			match step:
				1: # Xếp hạ sốt & nhiệt kế
					_draw_catui_disc(img, Color(1.0, 0.92, 0.92), Color(0.9, 0.35, 0.35))
					_rect(img, 12, 16, 24, 18, white) # Hộp thuốc
					_outline_rect(img, 12, 16, 24, 18, dark)
					_rect(img, 22, 19, 4, 12, Color(0.85, 0.2, 0.2))
					_rect(img, 18, 23, 12, 4, Color(0.85, 0.2, 0.2))
				2: # Bổ sung Berberin tiêu hóa
					_draw_catui_disc(img, Color(1.0, 0.96, 0.88), Color(0.95, 0.75, 0.2))
					_circle(img, 24, 24, 10, Color(1.0, 0.85, 0.15))
					_circle_outline(img, 24, 24, 10, dark)
					_p(img, 24, 24, Color(0.6, 0.4, 0.1))
				3: # Chuẩn bị cồn đỏ & gạc
					_draw_catui_disc(img, Color(0.96, 0.92, 0.94), Color(0.85, 0.3, 0.4))
					_rect(img, 15, 16, 9, 18, Color(0.75, 0.2, 0.15)) # Chai cồn đỏ
					_rect(img, 26, 20, 10, 14, white) # Cuộn gạc
					_outline_rect(img, 26, 20, 10, 14, dark)
				4: # Dán nhãn hạn sử dụng
					_draw_catui_disc(img, Color(0.92, 0.98, 0.94), Color(0.2, 0.7, 0.35))
					_rect(img, 12, 16, 24, 16, Color(1.0, 0.98, 0.8))
					_outline_rect(img, 12, 16, 24, 16, dark)
					_line(img, 15, 22, 33, 22, Color(0.1, 0.5, 0.2)) # HSD rõ ràng

		12: # Nấu ăn ngon bổ rẻ
			match step:
				1: # Nói không với mì sống
					_draw_catui_disc(img, Color(1.0, 0.92, 0.92), Color(0.9, 0.25, 0.25))
					_rect(img, 14, 16, 20, 16, Color(1.0, 0.85, 0.3)) # Vắt mì tôm
					_circle_outline(img, 24, 24, 13, Color(0.9, 0.15, 0.15)) # Vạch cấm đỏ
					_line(img, 15, 15, 33, 33, Color(0.9, 0.15, 0.15))
				2: # Nấu sôi chần bỏ nước đầu
					_draw_catui_disc(img, Color(0.92, 0.96, 1.0), Color(0.3, 0.6, 0.9))
					# Nồi inox luộc
					_rect(img, 14, 20, 20, 14, Color(0.7, 0.75, 0.8))
					_outline_rect(img, 14, 20, 20, 14, dark)
					_rect(img, 10, 22, 4, 3, dark) # Quai nồi
					_rect(img, 34, 22, 4, 3, dark)
					# Bong bóng sôi & hơi nước
					_circle(img, 20, 16, 2, Color(0.4, 0.8, 1.0))
					_circle(img, 28, 14, 2, Color(0.4, 0.8, 1.0))
				3: # Thêm trứng & rau xanh
					_draw_catui_disc(img, Color(0.90, 0.98, 0.92), Color(0.2, 0.75, 0.35))
					_circle(img, 20, 24, 6, white)
					_circle(img, 20, 24, 3, Color(1.0, 0.7, 0.1)) # Trứng ốp la
					_circle(img, 30, 22, 5, Color(0.25, 0.7, 0.3)) # Rau xanh
					_circle(img, 32, 28, 4, Color(0.35, 0.8, 0.4))
				4: # Bát ăn đủ chất
					_draw_catui_disc(img, Color(1.0, 0.95, 0.88), Color(0.9, 0.6, 0.2))
					_circle(img, 24, 26, 12, Color(0.95, 0.9, 0.8))
					_circle(img, 24, 25, 9, Color(0.98, 0.7, 0.3)) # Món ăn nóng hổi
					_line(img, 18, 12, 34, 18, dark) # Đôi đũa gỗ

		13: # Quy tắc 50-30-20
			match step:
				1: # Chia ngay 3 phần tiền
					_draw_catui_disc(img, Color(0.92, 0.96, 1.0), Color(0.3, 0.6, 0.9))
					# 3 lọ thủy tinh nhỏ
					_rect(img, 11, 20, 6, 12, Color(0.3, 0.7, 0.4))
					_rect(img, 21, 18, 6, 14, Color(0.3, 0.6, 0.9))
					_rect(img, 31, 22, 6, 10, Color(1.0, 0.8, 0.2))
				2: # Khóa 50% tiền trọ & ăn
					_draw_catui_disc(img, Color(0.90, 0.98, 0.92), Color(0.2, 0.75, 0.35))
					_rect(img, 14, 16, 20, 20, Color(0.3, 0.75, 0.45))
					_outline_rect(img, 14, 16, 20, 20, dark)
					_circle(img, 24, 26, 4, white) # Số 50%
				3: # Dành 30% học & phát triển
					_draw_catui_disc(img, Color(0.88, 0.94, 1.0), Color(0.2, 0.55, 0.9))
					_rect(img, 14, 16, 20, 20, Color(0.25, 0.6, 0.95))
					_outline_rect(img, 14, 16, 20, 20, dark)
					_line(img, 18, 26, 30, 26, white)
				4: # Niêm phong 20% khẩn cấp
					_draw_catui_disc(img, Color(1.0, 0.94, 0.88), Color(0.95, 0.65, 0.2))
					_rect(img, 15, 18, 18, 18, Color(1.0, 0.8, 0.2))
					_outline_rect(img, 15, 18, 18, 18, dark)
					_circle(img, 24, 27, 3, dark) # Ổ khóa niêm phong

		14: # Nhận diện bẫy đa cấp
			match step:
				1: # Soi lãi khủng phi lý
					_draw_catui_disc(img, Color(1.0, 0.92, 0.92), Color(0.9, 0.3, 0.3))
					_line(img, 14, 32, 22, 28, Color(0.8, 0.2, 0.2))
					_line(img, 22, 28, 34, 12, Color(0.8, 0.2, 0.2)) # Mũi tên ảo 300%
					_line(img, 34, 12, 30, 12, Color(0.8, 0.2, 0.2))
					_circle(img, 24, 24, 4, Color(1.0, 0.8, 0.2))
				2: # Kiểm tra sản phẩm thật
					_draw_catui_disc(img, Color(1.0, 0.96, 0.88), Color(0.9, 0.6, 0.2))
					_rect(img, 14, 16, 20, 18, Color(0.85, 0.75, 0.6))
					_outline_rect(img, 14, 16, 20, 18, dark)
					_p(img, 24, 25, dark) # Hộp rỗng dấu hỏi ?
				3: # Cất chặt ví & CCCD
					_draw_catui_disc(img, Color(0.92, 0.96, 0.98), Color(0.3, 0.6, 0.85))
					_rect(img, 13, 16, 22, 16, Color(0.4, 0.25, 0.15)) # Ví da
					_outline_rect(img, 13, 16, 22, 16, dark)
					_circle(img, 24, 24, 4, Color(1.0, 0.8, 0.2)) # Khóa chặt
				4: # Rời hội thảo dứt khoát
					_draw_catui_disc(img, Color(0.90, 0.98, 0.92), Color(0.2, 0.75, 0.35))
					# Cửa thoát hiểm xanh lá & người chạy
					_rect(img, 14, 12, 20, 24, Color(0.15, 0.7, 0.3))
					_outline_rect(img, 14, 12, 20, 24, dark)
					_circle(img, 24, 18, 3, white)
					_line(img, 24, 21, 24, 28, white)

		15: # Đi làm thêm không bị bùng lương
			match step:
				1: # Trình CV khớp lịch học
					_draw_catui_disc(img, Color(0.92, 0.96, 1.0), Color(0.3, 0.6, 0.9))
					_rect(img, 14, 10, 20, 28, white)
					_outline_rect(img, 14, 10, 20, 28, dark)
					_rect(img, 17, 14, 6, 6, Color(0.3, 0.6, 0.9)) # Ảnh chân dung
					_line(img, 17, 23, 30, 23, dark)
					_line(img, 17, 27, 28, 27, dark)
				2: # Chốt lương giờ & ngày trả
					_draw_catui_disc(img, Color(1.0, 0.96, 0.88), Color(0.95, 0.7, 0.2))
					_circle(img, 20, 24, 8, Color(1.0, 0.8, 0.2))
					_circle_outline(img, 20, 24, 8, dark)
					_circle(img, 28, 24, 7, Color(0.3, 0.75, 0.4))
				3: # Từ chối nộp cọc & CCCD
					_draw_catui_disc(img, Color(1.0, 0.92, 0.92), Color(0.9, 0.3, 0.3))
					# Khiên chắn bảo vệ
					_circle(img, 24, 24, 12, Color(0.2, 0.5, 0.8))
					_circle_outline(img, 24, 24, 12, dark)
					_line(img, 17, 17, 31, 31, Color(0.9, 0.15, 0.15)) # Chặn cọc
				4: # Ký thỏa thuận trước ca
					_draw_catui_disc(img, Color(0.90, 0.98, 0.92), Color(0.2, 0.75, 0.35))
					# Hai bàn tay bắt nhau
					_circle(img, 20, 24, 5, Color(1.0, 0.85, 0.75))
					_circle(img, 28, 24, 5, Color(0.9, 0.75, 0.65))
					_circle(img, 24, 15, 3, Color(1.0, 0.85, 0.2)) # Ngôi sao tin cậy

		16: # Kích hoạt phanh ví trả sau
			match step:
				1: # Kích hoạt phanh 48 giờ
					_draw_catui_disc(img, Color(0.92, 0.96, 1.0), Color(0.3, 0.6, 0.9))
					# Đồng hồ cát 48h
					_line(img, 16, 14, 32, 14, dark)
					_line(img, 16, 34, 32, 34, dark)
					_line(img, 16, 14, 32, 34, Color(0.3, 0.65, 0.95))
					_line(img, 32, 14, 16, 34, Color(0.3, 0.65, 0.95))
					_circle(img, 24, 24, 2, Color(1.0, 0.8, 0.2))
				2: # Soi phí trễ hạn & phạt
					_draw_catui_disc(img, Color(1.0, 0.92, 0.92), Color(0.9, 0.3, 0.3))
					_rect(img, 15, 14, 18, 22, Color(0.3, 0.3, 0.3)) # Máy tính
					_outline_rect(img, 15, 14, 18, 22, dark)
					_rect(img, 18, 17, 12, 6, Color(0.8, 0.9, 0.8))
					_p(img, 24, 20, Color(0.8, 0.1, 0.1)) # Phí phạt %
				3: # Chỉ mua khi có tiền mặt
					_draw_catui_disc(img, Color(0.90, 0.98, 0.92), Color(0.2, 0.75, 0.35))
					_rect(img, 12, 18, 24, 14, Color(0.35, 0.8, 0.5))
					_outline_rect(img, 12, 18, 24, 14, dark)
					_circle(img, 24, 25, 4, white)
				4: # Khóa hạn mức ví trả sau
					_draw_catui_disc(img, Color(0.88, 0.94, 1.0), Color(0.25, 0.5, 0.85))
					_rect(img, 12, 16, 24, 16, Color(0.35, 0.45, 0.65)) # Thẻ tín dụng
					_outline_rect(img, 12, 16, 24, 16, dark)
					# Khối băng đóng băng thẻ
					_circle(img, 24, 24, 7, Color(0.65, 0.9, 1.0, 0.75))
					_circle_outline(img, 24, 24, 7, Color(0.2, 0.6, 0.9))
