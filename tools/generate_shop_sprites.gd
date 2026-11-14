extends SceneTree

# generate_shop_sprites.gd - Script vẽ các sprite pixel art chất lượng cao cho Cửa Hàng Best Sen
# Chạy headless qua Godot 4.3: Godot_v4.3-stable_win64_console.exe --headless -s tools/generate_shop_sprites.gd

func _init() -> void:
	print(">>> Bắt đầu tạo bộ sprite pixel art cho Cửa Hàng Best Sen...")
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("res://assets/sprites/items"):
		dir.make_dir_recursive("res://assets/sprites/items")
		print("Đã tạo thư mục res://assets/sprites/items/")
		
	_generate_all_sprites()
	print(">>> Hoàn tất tạo toàn bộ sprite! Thoát...")
	quit(0)

func _set_p(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
		if c.a > 0.0:
			if c.a < 1.0:
				var bg = img.get_pixel(x, y)
				img.set_pixel(x, y, bg.blend(c))
			else:
				img.set_pixel(x, y, c)

func _rect(img: Image, x: int, y: int, w: int, h: int, c: Color) -> void:
	for dy in range(h):
		for dx in range(w):
			_set_p(img, x + dx, y + dy, c)

func _circle(img: Image, cx: int, cy: int, r: int, c: Color) -> void:
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if dx * dx + dy * dy <= r * r:
				_set_p(img, cx + dx, cy + dy, c)

func _generate_all_sprites() -> void:
	_draw_pate_tuna()
	_draw_pate_beef()
	_draw_treat_churu()
	_draw_treat_freeze_dry()
	_draw_catnip_grass()
	_draw_catnip_ball()
	_draw_hat_bunny()
	_draw_hat_helmet()
	_draw_scarf_volunteer()
	_draw_backpack_yellow()
	_draw_grad_robe()
	_draw_rug_paw()
	_draw_mini_fan()
	_draw_wand_feather()
	_draw_wand_mouse()
	_draw_ball_bell()
	_draw_scratch_mushroom()
	_draw_tunnel_spring()

# 1. Lon Pate Cá Ngừ Thạch (f_pate_tuna)
func _draw_pate_tuna() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_silver = Color(0.82, 0.85, 0.88)
	var c_rim = Color(0.60, 0.65, 0.70)
	var c_dark = Color(0.20, 0.25, 0.35)
	var c_blue_label = Color(0.18, 0.45, 0.85)
	var c_fish = Color(0.95, 0.75, 0.80)
	var c_gold_ring = Color(0.95, 0.75, 0.20)
	var c_shadow = Color(0.1, 0.1, 0.15, 0.3)
	
	# Bóng đổ
	_rect(img, 6, 26, 20, 3, c_shadow)
	
	# Thân lon hình trụ
	_rect(img, 6, 12, 20, 14, c_silver)
	_rect(img, 5, 13, 22, 12, c_silver)
	
	# Viền lon
	_rect(img, 6, 25, 20, 1, c_rim)
	_rect(img, 5, 12, 1, 13, c_dark)
	_rect(img, 26, 12, 1, 13, c_dark)
	
	# Nhãn màu xanh dương đậm ở giữa
	_rect(img, 6, 16, 20, 8, c_blue_label)
	# Họa tiết cá hồng trên nhãn
	_rect(img, 12, 19, 6, 2, c_fish)
	_rect(img, 18, 18, 2, 4, c_fish)
	_set_p(img, 13, 19, Color(0.2, 0.2, 0.3)) # mắt cá
	
	# Nắp lon oval
	_rect(img, 7, 10, 18, 3, c_silver)
	_rect(img, 6, 11, 20, 2, c_rim)
	# Khoen kéo nắp màu vàng
	_rect(img, 14, 9, 4, 3, c_gold_ring)
	_set_p(img, 15, 10, Color(0.2, 0.2, 0.2)) # lỗ khoen
	
	# Vệt sáng phản chiếu kim loại
	_rect(img, 8, 12, 2, 13, Color(1, 1, 1, 0.5))
	
	img.save_png("res://assets/sprites/items/f_pate_tuna.png")
	print("  -> Đã tạo f_pate_tuna.png")

# 2. Lon Pate Bò Hầm Thượng Hạng (f_pate_beef)
func _draw_pate_beef() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_gold_rim = Color(0.92, 0.75, 0.25)
	var c_red_label = Color(0.75, 0.18, 0.18)
	var c_dark_red = Color(0.50, 0.10, 0.10)
	var c_bone = Color(0.98, 0.95, 0.90)
	var c_dark = Color(0.25, 0.15, 0.15)
	var c_shadow = Color(0.1, 0.1, 0.15, 0.3)
	
	# Bóng đổ
	_rect(img, 6, 26, 20, 3, c_shadow)
	
	# Thân lon
	_rect(img, 6, 12, 20, 14, c_dark_red)
	_rect(img, 5, 13, 22, 12, c_dark_red)
	
	# Nhãn đỏ tươi
	_rect(img, 6, 15, 20, 9, c_red_label)
	# Hình khúc xương thịt bò trên nhãn
	_rect(img, 12, 19, 8, 2, c_bone)
	_rect(img, 11, 18, 2, 4, c_bone)
	_rect(img, 19, 18, 2, 4, c_bone)
	
	# Nắp vàng đồng quý tộc
	_rect(img, 6, 10, 20, 3, c_gold_rim)
	_rect(img, 14, 9, 4, 3, Color(1.0, 0.88, 0.4))
	_set_p(img, 15, 10, c_dark)
	
	# Viền & bóng kim loại
	_rect(img, 5, 12, 1, 13, c_dark)
	_rect(img, 26, 12, 1, 13, c_dark)
	_rect(img, 6, 25, 20, 1, c_gold_rim)
	_rect(img, 8, 12, 2, 13, Color(1, 1, 1, 0.45))
	
	img.save_png("res://assets/sprites/items/f_pate_beef.png")
	print("  -> Đã tạo f_pate_beef.png")

# 3. Súp Thưởng Churu Cá Hồi (f_treat_churu)
func _draw_treat_churu() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_pink = Color(0.95, 0.40, 0.55)
	var c_cream = Color(1.0, 0.94, 0.88)
	var c_salmon = Color(0.95, 0.55, 0.40)
	var c_dark = Color(0.35, 0.15, 0.20)
	
	# Tuýp nghiêng 45 độ
	for i in range(16):
		var x = 8 + i
		var y = 24 - i
		_rect(img, x, y, 5, 5, c_pink)
		_set_p(img, x, y, c_cream) # mép sáng
		_set_p(img, x + 4, y + 4, c_dark) # mép tối
		
	# Đáy tuýp dập răng cưa
	_rect(img, 6, 24, 4, 3, Color(0.8, 0.3, 0.4))
	
	# Miệng tuýp đã xé
	_rect(img, 23, 7, 3, 3, c_cream)
	# Giọt súp churu đùn ra thơm ngon
	_circle(img, 26, 6, 2, c_salmon)
	_set_p(img, 27, 5, Color(1, 1, 1, 0.8)) # ánh bóng giọt sốt
	
	# Chữ/Họa tiết trên thân tuýp
	_rect(img, 13, 16, 4, 2, c_cream)
	
	img.save_png("res://assets/sprites/items/f_treat_churu.png")
	print("  -> Đã tạo f_treat_churu.png")

# 4. Hũ Ức Gà Sấy Thăng Hoa (f_treat_freeze_dry)
func _draw_treat_freeze_dry() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_glass = Color(0.85, 0.94, 0.98, 0.6)
	var c_rim = Color(0.65, 0.80, 0.90)
	var c_cork = Color(0.72, 0.50, 0.30)
	var c_chicken = Color(0.96, 0.82, 0.45)
	var c_chicken_dark = Color(0.85, 0.68, 0.32)
	var c_string = Color(0.85, 0.35, 0.25)
	
	# Bóng đổ
	_rect(img, 8, 27, 16, 3, Color(0.1, 0.1, 0.15, 0.3))
	
	# Thân hũ thủy tinh
	_rect(img, 8, 12, 16, 15, c_glass)
	_rect(img, 7, 13, 18, 13, c_glass)
	
	# Các viên ức gà sấy vàng giòn bên trong
	_rect(img, 9, 18, 4, 4, c_chicken)
	_rect(img, 14, 19, 4, 4, c_chicken_dark)
	_rect(img, 19, 17, 4, 4, c_chicken)
	_rect(img, 11, 22, 5, 4, c_chicken_dark)
	_rect(img, 17, 22, 5, 4, c_chicken)
	
	# Cổ hũ & Nắp gỗ bần
	_rect(img, 10, 10, 12, 3, c_rim)
	_rect(img, 9, 7, 14, 4, c_cork)
	# Dây nơ đỏ thắt cổ hũ
	_rect(img, 9, 11, 14, 1, c_string)
	_rect(img, 14, 12, 3, 3, c_string)
	
	# Vệt bóng kính
	_rect(img, 9, 14, 2, 11, Color(1, 1, 1, 0.7))
	
	img.save_png("res://assets/sprites/items/f_treat_freeze_dry.png")
	print("  -> Đã tạo f_treat_freeze_dry.png")

# 5. Chậu Cỏ Lúa Mạch Tươi (f_catnip_grass)
func _draw_catnip_grass() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_pot = Color(0.85, 0.45, 0.28)
	var c_pot_dark = Color(0.65, 0.32, 0.18)
	var c_soil = Color(0.35, 0.22, 0.15)
	var c_grass1 = Color(0.35, 0.78, 0.25)
	var c_grass2 = Color(0.52, 0.88, 0.32)
	var c_dew = Color(0.85, 0.95, 1.0, 0.8)
	
	# Bóng đổ
	_rect(img, 8, 27, 16, 3, Color(0.1, 0.1, 0.15, 0.3))
	
	# Chậu đất nung
	_rect(img, 9, 18, 14, 9, c_pot)
	_rect(img, 10, 26, 12, 1, c_pot_dark)
	_rect(img, 8, 16, 16, 3, c_pot_dark) # miệng chậu
	_rect(img, 10, 16, 12, 2, c_soil) # đất
	
	# Bụi cỏ lúa mạch vươn cao
	for i in range(7):
		var gx = 10 + i * 2
		var gh = 8 + (i % 3) * 2
		for y in range(gh):
			var col = c_grass1 if (i % 2 == 0) else c_grass2
			_set_p(img, gx + (1 if y > gh - 3 else 0), 16 - y, col)
			
	# Giọt sương mai đọng trên ngọn cỏ
	_set_p(img, 12, 7, c_dew)
	_set_p(img, 18, 6, c_dew)
	
	img.save_png("res://assets/sprites/items/f_catnip_grass.png")
	print("  -> Đã tạo f_catnip_grass.png")

# 6. Quả Lăn Bạc Hà Xoay 360 (f_catnip_ball)
func _draw_catnip_ball() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_case = Color(0.45, 0.85, 0.75) # đế tai mèo xanh mint
	var c_case_dark = Color(0.30, 0.65, 0.55)
	var c_ball = Color(0.42, 0.55, 0.22) # viên bạc hà tròn
	var c_ball_dark = Color(0.30, 0.40, 0.15)
	var c_ball_light = Color(0.55, 0.68, 0.30)
	
	# Đế dán tường tai mèo
	_circle(img, 16, 16, 11, c_case)
	_circle(img, 16, 16, 10, c_case_dark)
	# Tai mèo trên đế
	_rect(img, 8, 6, 4, 5, c_case)
	_rect(img, 20, 6, 4, 5, c_case)
	_set_p(img, 9, 5, c_case)
	_set_p(img, 22, 5, c_case)
	
	# Viên catnip tròn xoay ở giữa
	_circle(img, 16, 16, 7, c_ball)
	_circle(img, 15, 15, 6, c_ball_light)
	_rect(img, 17, 18, 3, 3, c_ball_dark) # góc đổ bóng
	
	img.save_png("res://assets/sprites/items/f_catnip_ball.png")
	print("  -> Đã tạo f_catnip_ball.png")

# 7. Mũ Len Tai Thỏ Lắc Lư (c_hat_bunny)
func _draw_hat_bunny() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_wool = Color(0.96, 0.95, 0.92)
	var c_wool_dark = Color(0.82, 0.80, 0.78)
	var c_pink = Color(0.95, 0.70, 0.75)
	var c_knit_line = Color(0.75, 0.72, 0.70)
	
	# Thân mũ len tròn
	_circle(img, 16, 20, 8, c_wool)
	_rect(img, 9, 23, 15, 3, c_wool_dark) # gấu mũ gấp nếp
	
	# 2 Tai thỏ dài ngộ nghĩnh
	# Tai trái
	_rect(img, 10, 6, 4, 11, c_wool)
	_rect(img, 11, 7, 2, 9, c_pink) # lòng tai hồng
	_set_p(img, 11, 5, c_wool)
	_set_p(img, 12, 5, c_wool)
	
	# Tai phải hơi cụp
	_rect(img, 18, 7, 4, 10, c_wool)
	_rect(img, 19, 8, 2, 8, c_pink)
	_set_p(img, 19, 6, c_wool)
	_set_p(img, 20, 6, c_wool)
	
	# Quả bông len nhỏ
	_circle(img, 16, 13, 2, c_wool)
	
	img.save_png("res://assets/sprites/items/c_hat_bunny.png")
	print("  -> Đã tạo c_hat_bunny.png")

# 8. Nón Bảo Hiểm Xe Máy Mini (c_hat_helmet)
func _draw_hat_helmet() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_red = Color(0.90, 0.22, 0.22)
	var c_red_dark = Color(0.65, 0.12, 0.12)
	var c_visor = Color(0.15, 0.20, 0.25, 0.85)
	var c_strap = Color(0.2, 0.2, 0.2)
	var c_star = Color(0.98, 0.85, 0.20)
	
	# Vòm nón bảo hiểm nửa đầu
	_circle(img, 16, 16, 10, c_red)
	_rect(img, 6, 18, 20, 4, c_red_dark)
	
	# Kính chắn gió đen bóng phía trước
	_rect(img, 7, 18, 18, 5, c_visor)
	_rect(img, 9, 19, 6, 1, Color(1, 1, 1, 0.7)) # vệt bóng kính
	
	# Ngôi sao vàng / Huy hiệu sinh viên ở giữa trán
	_rect(img, 15, 12, 3, 3, c_star)
	
	# Quai cài nón
	_rect(img, 8, 22, 1, 6, c_strap)
	_rect(img, 23, 22, 1, 6, c_strap)
	_rect(img, 9, 27, 14, 1, c_strap)
	
	# Ánh sáng vòm nón
	_rect(img, 11, 9, 8, 2, Color(1, 1, 1, 0.5))
	
	img.save_png("res://assets/sprites/items/c_hat_helmet.png")
	print("  -> Đã tạo c_hat_helmet.png")

# 9. Khăn Rằn Sinh Viên Tình Nguyện (c_scarf_volunteer)
func _draw_scarf_volunteer() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_blue = Color(0.15, 0.45, 0.85)
	var c_white = Color(0.96, 0.96, 0.96)
	var c_dark = Color(0.10, 0.25, 0.55)
	
	# Khăn quấn cổ hình tam giác rủ xuống
	for y in range(12):
		var w = 22 - y * 2
		var x = 5 + y
		for dx in range(w):
			var is_check = ((x + dx) / 2 + y / 2) % 2 == 0
			_set_p(img, x + dx, 10 + y, c_blue if is_check else c_white)
			
	# Nút thắt giữa cổ
	_rect(img, 14, 9, 4, 4, c_dark)
	# Tua rua mép khăn
	for x in range(6, 26, 2):
		_set_p(img, x, 22, c_white)
		
	img.save_png("res://assets/sprites/items/c_scarf_volunteer.png")
	print("  -> Đã tạo c_scarf_volunteer.png")

# 10. Ba Lô Cóc Sinh Viên (c_backpack_yellow)
func _draw_backpack_yellow() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_yellow = Color(0.96, 0.78, 0.20)
	var c_yellow_dark = Color(0.80, 0.60, 0.12)
	var c_brown = Color(0.45, 0.28, 0.18)
	var c_pocket = Color(0.90, 0.70, 0.15)
	var c_zipper = Color(0.3, 0.3, 0.3)
	
	# Quai xách trên
	_rect(img, 13, 5, 6, 2, c_brown)
	
	# Thân ba lô
	_rect(img, 7, 7, 18, 19, c_yellow)
	_rect(img, 6, 9, 20, 16, c_yellow)
	_rect(img, 6, 23, 20, 3, c_yellow_dark)
	
	# Ngăn phụ phía trước
	_rect(img, 9, 15, 14, 9, c_pocket)
	_rect(img, 9, 15, 14, 1, c_zipper) # khóa kéo
	
	# Hai dây đai da nâu vintage
	_rect(img, 10, 8, 2, 7, c_brown)
	_rect(img, 20, 8, 2, 7, c_brown)
	
	# Móc khóa mèo nhỏ
	_circle(img, 24, 17, 2, Color(1, 1, 1))
	
	img.save_png("res://assets/sprites/items/c_backpack_yellow.png")
	print("  -> Đã tạo c_backpack_yellow.png")

# 11. Áo Cử Nhân Tốt Nghiệp (c_grad_robe)
func _draw_grad_robe() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_robe = Color(0.18, 0.18, 0.28) # xanh tím than học viện
	var c_lapel = Color(0.85, 0.20, 0.25) # vạt nhung đỏ
	var c_gold = Color(0.95, 0.80, 0.25) # viền vàng
	var c_white = Color(1.0, 1.0, 1.0)
	
	# Thân áo thụng tốt nghiệp
	_rect(img, 8, 9, 16, 18, c_robe)
	_rect(img, 6, 12, 20, 14, c_robe)
	
	# Vạt nhung đỏ trang trọng chữ V
	for y in range(12):
		_rect(img, 14 - y / 3, 10 + y, 2, 1, c_lapel)
		_rect(img, 17 + y / 3, 10 + y, 2, 1, c_lapel)
		
	# Cổ sơ mi trắng bên trong
	_rect(img, 14, 7, 4, 3, c_white)
	
	# Dải tua rua vàng danh dự
	_rect(img, 13, 11, 1, 11, c_gold)
	_rect(img, 18, 11, 1, 11, c_gold)
	
	img.save_png("res://assets/sprites/items/c_grad_robe.png")
	print("  -> Đã tạo c_grad_robe.png")

# 12. Thảm Dấu Chân Mèo (d_rug_paw)
func _draw_rug_paw() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_rug = Color(0.96, 0.94, 0.88)
	var c_rug_border = Color(0.85, 0.80, 0.72)
	var c_pink_pad = Color(0.95, 0.65, 0.72)
	var c_pink_dark = Color(0.85, 0.52, 0.60)
	
	# Thảm bầu dục lớn
	_circle(img, 16, 16, 13, c_rug)
	_circle(img, 16, 16, 12, c_rug)
	
	# Đệm chân mèo lớn ở giữa
	_circle(img, 16, 18, 5, c_pink_pad)
	_set_p(img, 16, 21, c_pink_dark)
	
	# 4 đệm ngón chân nhỏ
	_circle(img, 10, 12, 2, c_pink_pad)
	_circle(img, 14, 9, 2, c_pink_pad)
	_circle(img, 18, 9, 2, c_pink_pad)
	_circle(img, 22, 12, 2, c_pink_pad)
	
	img.save_png("res://assets/sprites/items/d_rug_paw.png")
	print("  -> Đã tạo d_rug_paw.png")

# 13. Quạt Gió Mini Để Bàn (d_mini_fan)
func _draw_mini_fan() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_blue = Color(0.40, 0.75, 0.90)
	var c_white = Color(1.0, 1.0, 1.0)
	var c_dark = Color(0.20, 0.45, 0.60)
	var c_blade = Color(0.85, 0.92, 0.98)
	
	# Chân đế quạt oval
	_rect(img, 10, 27, 12, 3, c_dark)
	_set_p(img, 16, 28, Color(0.9, 0.3, 0.3)) # nút bấm đỏ
	
	# Cổ quạt
	_rect(img, 15, 20, 2, 7, c_white)
	
	# Lồng quạt tròn
	_circle(img, 16, 12, 8, c_blue)
	_circle(img, 16, 12, 7, c_dark)
	
	# 3 Cánh quạt màu trắng xoay
	_rect(img, 15, 6, 2, 6, c_blade)
	_rect(img, 11, 14, 5, 2, c_blade)
	_rect(img, 17, 14, 5, 2, c_blade)
	# Tâm quạt
	_circle(img, 16, 12, 2, c_blue)
	
	img.save_png("res://assets/sprites/items/d_mini_fan.png")
	print("  -> Đã tạo d_mini_fan.png")

# 14. Cần Câu Lông Vũ Chuông Keng (t_wand_feather)
func _draw_wand_feather() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_stick = Color(0.80, 0.60, 0.40) # que gỗ
	var c_string = Color(0.2, 0.2, 0.2)
	var c_feather1 = Color(0.95, 0.45, 0.60) # lông hồng
	var c_feather2 = Color(0.35, 0.75, 0.90) # lông xanh
	var c_feather3 = Color(0.95, 0.85, 0.30) # lông vàng
	var c_bell = Color(0.95, 0.78, 0.15)
	
	# Que gỗ chéo
	for i in range(16):
		_set_p(img, 4 + i, 28 - i, c_stick)
		_set_p(img, 5 + i, 28 - i, c_stick)
		
	# Dây cước uốn cong
	_set_p(img, 20, 12, c_string)
	_set_p(img, 21, 14, c_string)
	_set_p(img, 22, 17, c_string)
	
	# Quả chuông nhỏ
	_circle(img, 22, 18, 2, c_bell)
	
	# Chùm 3 sợi lông vũ xòe ra
	_rect(img, 23, 19, 6, 3, c_feather1)
	_rect(img, 22, 21, 5, 4, c_feather2)
	_rect(img, 24, 23, 5, 3, c_feather3)
	
	img.save_png("res://assets/sprites/items/t_wand_feather.png")
	print("  -> Đã tạo t_wand_feather.png")

# 15. Cần Câu Chuột Bông Nháy Đèn (t_wand_mouse)
func _draw_wand_mouse() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_stick = Color(0.30, 0.65, 0.85)
	var c_string = Color(0.3, 0.3, 0.3)
	var c_mouse = Color(0.65, 0.65, 0.70)
	var c_pink = Color(0.95, 0.65, 0.72)
	
	# Cần câu
	for i in range(14):
		_set_p(img, 4 + i, 28 - i, c_stick)
		
	# Dây
	_set_p(img, 18, 14, c_string)
	_set_p(img, 19, 17, c_string)
	_set_p(img, 20, 20, c_string)
	
	# Chú chuột bông xám
	_circle(img, 21, 22, 4, c_mouse)
	_set_p(img, 18, 20, c_pink) # tai hồng
	_set_p(img, 21, 19, c_pink)
	_set_p(img, 17, 23, Color(0.1, 0.1, 0.1)) # mũi đen
	_set_p(img, 19, 22, Color(0.95, 0.2, 0.2)) # mắt đỏ nháy đèn
	
	# Đuôi chuột uốn éo
	_set_p(img, 25, 22, c_pink)
	_set_p(img, 26, 23, c_pink)
	_set_p(img, 27, 22, c_pink)
	
	img.save_png("res://assets/sprites/items/t_wand_mouse.png")
	print("  -> Đã tạo t_wand_mouse.png")

# 16. Bóng Chuông Lục Lạc Rộn Rã (t_ball_bell)
func _draw_ball_bell() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_ball1 = Color(0.95, 0.50, 0.15)
	var c_ball2 = Color(0.98, 0.94, 0.85)
	var c_bell = Color(0.96, 0.80, 0.20)
	var c_dark = Color(0.2, 0.15, 0.1)
	
	# Quả bóng rỗng đan nan
	_circle(img, 16, 16, 9, c_ball1)
	_circle(img, 16, 16, 7, c_dark) # bên trong
	
	# Nan bóng sọc kem
	_rect(img, 10, 15, 12, 2, c_ball2)
	_rect(img, 15, 10, 2, 12, c_ball2)
	
	# Quả chuông đồng lắc leng keng ở tâm
	_circle(img, 16, 16, 3, c_bell)
	_set_p(img, 16, 17, Color(0.2, 0.2, 0.2))
	
	img.save_png("res://assets/sprites/items/t_ball_bell.png")
	print("  -> Đã tạo t_ball_bell.png")

# 17. Cây Cào Nấm Đỏ Cổ Tích (t_scratch_mushroom)
func _draw_scratch_mushroom() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_moss = Color(0.35, 0.70, 0.30)
	var c_sisal = Color(0.85, 0.75, 0.55)
	var c_sisal_dark = Color(0.68, 0.58, 0.40)
	var c_cap = Color(0.90, 0.22, 0.22)
	var c_dot = Color(1.0, 1.0, 1.0)
	
	# Đế thảm rêu xanh
	_circle(img, 16, 26, 9, c_moss)
	_rect(img, 8, 27, 16, 2, Color(0.2, 0.45, 0.15))
	
	# Thân cây cuộn dây thừng sisal
	_rect(img, 13, 13, 6, 14, c_sisal)
	for y in range(13, 27, 2):
		_rect(img, 13, y, 6, 1, c_sisal_dark) # vân dây thừng
		
	# Mũ nấm đỏ tròn xoe
	_circle(img, 16, 11, 8, c_cap)
	_rect(img, 8, 12, 16, 3, c_cap)
	
	# Đốm trắng cổ tích
	_circle(img, 13, 8, 2, c_dot)
	_circle(img, 19, 9, 2, c_dot)
	_circle(img, 16, 12, 2, c_dot)
	_set_p(img, 10, 12, c_dot)
	_set_p(img, 22, 12, c_dot)
	
	img.save_png("res://assets/sprites/items/t_scratch_mushroom.png")
	print("  -> Đã tạo t_scratch_mushroom.png")

# 18. Ống Chui Lò Xo Gấp Gọn (t_tunnel_spring)
func _draw_tunnel_spring() -> void:
	var img = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var c_purple = Color(0.68, 0.50, 0.85)
	var c_purple_dark = Color(0.48, 0.32, 0.65)
	var c_inside = Color(0.25, 0.15, 0.35)
	var c_wire = Color(0.95, 0.85, 0.40) # lò xo vàng
	
	# Vòm ống chui nghiêng 3D
	_rect(img, 6, 11, 20, 14, c_purple)
	
	# Miệng ống chui mở tròn
	_circle(img, 9, 18, 6, c_inside)
	_circle(img, 9, 18, 7, c_purple_dark)
	
	# Các vòng lò xo vàng nổi gờ
	_rect(img, 14, 11, 1, 14, c_wire)
	_rect(img, 19, 11, 1, 14, c_wire)
	_rect(img, 24, 11, 1, 14, c_wire)
	
	# Lỗ ngó đầu (peek-a-boo hole) ở giữa ống
	_circle(img, 18, 14, 3, c_inside)
	
	img.save_png("res://assets/sprites/items/t_tunnel_spring.png")
	print("  -> Đã tạo t_tunnel_spring.png")
