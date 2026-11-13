extends Node2D

# IsometricRoomCanvas.gd - Vẽ Căn Phòng Trọ Sinh Viên Khép Kín Chuẩn True 2.5D Isometric Dimetric
# Phong cách Cozy Indie Game (Neko Atsume / Animal Crossing): Tường kem ấm, Sàn gỗ Parquet, Thảm len Bohemian, Cửa sổ pixel art & Tranh treo tường

const IsometricGrid = preload("res://scripts/IsometricGrid.gd")

@export var origin: Vector2 = Vector2(270.0, 436.0)
@export var wall_height: float = 175.0

var show_iso_grid: bool = false
var hovered_grid_cell: Vector2i = Vector2i(-1, -1)
var hovered_cell_valid: bool = true

var window_tex: Texture2D
var wall_art_tex: Texture2D
var room_bg_tex: Texture2D
var rug_boho_tex: Texture2D

func _ready() -> void:
	room_bg_tex = _load_texture("res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Rooms/Room1.png")
	if not room_bg_tex:
		room_bg_tex = _load_texture("res://assets/furnitures/CatRoomPaid/CatRoomPaid/Rooms/Room1.png")
	window_tex = _load_texture("res://assets/sprites/room_items/window_sky_white.png")
	wall_art_tex = _load_texture("res://assets/sprites/room_items/wall_cactus_poster.png")
	rug_boho_tex = preload("res://assets/UI/CatUIPaid/slices/cozy_dress/rug_woven_cozy_oval.tres")
	if not rug_boho_tex:
		rug_boho_tex = _load_texture("res://assets/sprites/room_items/rug_boho.png")
	GameManager.decor_changed.connect(func(_slot, _id): queue_redraw())

func _load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var t = load(path)
		if t: return t
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(path)
		if img:
			return ImageTexture.create_from_image(img)
	return null

func _draw() -> void:
	if room_bg_tex:
		# Vẽ phòng pixel-art chuẩn xịn từ CatRoomPaid
		var draw_pos = Vector2(origin.x - 256.0, origin.y - 199.0)
		draw_texture(room_bg_tex, draw_pos)
		_draw_wall_decorations()
		_draw_sunlight_beam()
		_draw_floor_rug()
	else:
		_draw_background_walls()
		_draw_wall_decorations()
		_draw_sunlight_beam()
		_draw_isometric_floor()
		_draw_floor_rug()
		_draw_door_and_window()
		_draw_baseboard_and_border()
	if show_iso_grid:
		_draw_decor_grid_overlay()

# 1. Vẽ 2 Bức tường hậu (Góc chiếu 3/4 Isometric)
func _draw_background_walls() -> void:
	var p_top_floor = origin
	var p_left_floor = IsometricGrid.grid_to_screen(Vector2(0, IsometricGrid.GRID_SIZE), origin)
	var p_right_floor = IsometricGrid.grid_to_screen(Vector2(IsometricGrid.GRID_SIZE, 0), origin)
	
	var p_top_wall = p_top_floor + Vector2(0, -wall_height)
	var p_left_wall = p_left_floor + Vector2(0, -wall_height)
	var p_right_wall = p_right_floor + Vector2(0, -wall_height)
	
	# Tường Tây Bắc (NW Wall - Bên trái): Tone kem trứng ấm áp
	var nw_wall_pts = PackedVector2Array([p_left_floor, p_left_wall, p_top_wall, p_top_floor])
	draw_colored_polygon(nw_wall_pts, Color(0.96, 0.94, 0.90, 1.0))
	
	# Hoa văn sọc dọc pastel tinh tế trên tường Tây Bắc
	for step in range(1, 8):
		var u_pos = float(step)
		var p_b = IsometricGrid.grid_to_screen(Vector2(0, u_pos), origin)
		var p_t = p_b + Vector2(0, -wall_height)
		draw_line(p_b, p_t, Color(0.91, 0.88, 0.83, 0.4), 1.0)
		
	# Viền nẹp chân tường gỗ Tây Bắc
	var nw_base_pts = PackedVector2Array([
		p_left_floor, 
		p_left_floor + Vector2(0, -14), 
		p_top_floor + Vector2(0, -14), 
		p_top_floor
	])
	draw_colored_polygon(nw_base_pts, Color(0.55, 0.38, 0.25, 1.0))
	draw_line(p_left_floor + Vector2(0, -14), p_top_floor + Vector2(0, -14), Color(0.38, 0.25, 0.15, 1.0), 1.5)
	
	# Tường Đông Bắc (NE Wall - Bên phải): Khuất sáng nhẹ, tone ấm cúng
	var ne_wall_pts = PackedVector2Array([p_top_floor, p_top_wall, p_right_wall, p_right_floor])
	draw_colored_polygon(ne_wall_pts, Color(0.91, 0.88, 0.83, 1.0))
	
	# Hoa văn tường Đông Bắc
	for step in range(1, 8):
		var u_pos = float(step)
		var p_b = IsometricGrid.grid_to_screen(Vector2(u_pos, 0), origin)
		var p_t = p_b + Vector2(0, -wall_height)
		draw_line(p_b, p_t, Color(0.85, 0.82, 0.77, 0.4), 1.0)
	
	# Viền nẹp chân tường gỗ Đông Bắc
	var ne_base_pts = PackedVector2Array([
		p_top_floor, 
		p_top_floor + Vector2(0, -14), 
		p_right_floor + Vector2(0, -14), 
		p_right_floor
	])
	draw_colored_polygon(ne_base_pts, Color(0.48, 0.33, 0.20, 1.0))
	draw_line(p_top_floor + Vector2(0, -14), p_right_floor + Vector2(0, -14), Color(0.32, 0.20, 0.12, 1.0), 1.5)
	
	# Góc giao giữa hai bức tường
	draw_line(p_top_wall, p_top_floor, Color(0.35, 0.25, 0.15, 0.8), 2.0)
	draw_line(p_left_wall, p_top_wall, Color(0.35, 0.25, 0.15, 0.9), 2.0)
	draw_line(p_top_wall, p_right_wall, Color(0.35, 0.25, 0.15, 0.9), 2.0)

# 2. Vẽ Tranh Treo Tường & Trang Trí Tường
func _draw_wall_decorations() -> void:
	# Cửa sổ ngắm bầu trời trên tường Đông Bắc (Bên phải)
	if window_tex:
		var win_pos = IsometricGrid.grid_to_screen(Vector2(4.2, 0.0), origin) + Vector2(-29, -135)
		draw_texture(window_tex, win_pos)
		
	var wall_id = GameManager.equipped_decor.get("wall", "d_wall_anime_poster")
	if wall_id == "d_wall_fairylights":
		# Dây đèn đom đóm fairy lights lung linh
		var start_p = IsometricGrid.grid_to_screen(Vector2(0, 0.5), origin) + Vector2(0, -wall_height + 25)
		var mid_p = IsometricGrid.grid_to_screen(Vector2(0, 4.0), origin) + Vector2(0, -wall_height + 40)
		var end_p = IsometricGrid.grid_to_screen(Vector2(0, 7.5), origin) + Vector2(0, -wall_height + 25)
		draw_line(start_p, mid_p, Color(0.4, 0.35, 0.25, 0.7), 1.5)
		draw_line(mid_p, end_p, Color(0.4, 0.35, 0.25, 0.7), 1.5)
		for t in [0.1, 0.25, 0.4, 0.55, 0.7, 0.85, 0.95]:
			var bp = start_p.lerp(mid_p, t * 2.0) if t < 0.5 else mid_p.lerp(end_p, (t - 0.5) * 2.0)
			draw_circle(bp, 4.0, Color(1.0, 0.95, 0.6, 0.9))
			draw_circle(bp, 7.0, Color(1.0, 0.85, 0.3, 0.35))
	elif wall_art_tex:
		# Treo tranh Cactus Canvas trên tường Tây Bắc (Bên trái)
		var art_pos = IsometricGrid.grid_to_screen(Vector2(0, 2.2), origin) + Vector2(-11, -125)
		draw_texture(wall_art_tex, art_pos)

# 3. Vẽ Vệt Nắng Chiếu Từ Cửa Sổ Xuống Sàn
func _draw_sunlight_beam() -> void:
	var sun_top_left = IsometricGrid.grid_to_screen(Vector2(2.8, 0.0), origin) + Vector2(0, -85)
	var sun_top_right = IsometricGrid.grid_to_screen(Vector2(5.5, 0.0), origin) + Vector2(0, -85)
	var sun_floor_1 = IsometricGrid.grid_to_screen(Vector2(2.2, 3.8), origin)
	var sun_floor_2 = IsometricGrid.grid_to_screen(Vector2(5.2, 5.2), origin)
	
	var sun_pts = PackedVector2Array([sun_top_left, sun_top_right, sun_floor_2, sun_floor_1])
	draw_colored_polygon(sun_pts, Color(1.0, 0.95, 0.72, 0.18))

# 4. Vẽ Sàn Gỗ Parquet Isometric 8x8 Lưới Ô Ấm Áp
func _draw_isometric_floor() -> void:
	var size = IsometricGrid.GRID_SIZE
	
	for u in range(size):
		for v in range(size):
			var p0 = IsometricGrid.grid_to_screen(Vector2(u, v), origin)
			var p1 = IsometricGrid.grid_to_screen(Vector2(u + 1, v), origin)
			var p2 = IsometricGrid.grid_to_screen(Vector2(u + 1, v + 1), origin)
			var p3 = IsometricGrid.grid_to_screen(Vector2(u, v + 1), origin)
			
			var tile_pts = PackedVector2Array([p0, p1, p2, p3])
			
			# Màu gỗ ấm áp đan xen tạo cảm giác thủ công
			var is_even = ((u + v) % 2 == 0)
			var tile_color: Color = Color(0.93, 0.87, 0.79, 1.0) if is_even else Color(0.89, 0.83, 0.74, 1.0)
			draw_colored_polygon(tile_pts, tile_color)
			
			# Viền từng viên gạch lát sàn
			draw_polyline(PackedVector2Array([p0, p1, p2, p3, p0]), Color(0.68, 0.58, 0.46, 0.45), 1.0)

# 5. Vẽ Thảm Sàn Isometric
func _draw_floor_rug() -> void:
	var rug_id = GameManager.equipped_decor.get("rugs", "d_rug_boho")
	if rug_id == "":
		return
	var rug_center = IsometricGrid.grid_to_screen(Vector2(1.8, 2.8), origin)
	var rug_rx = 52.0
	var rug_ry = 26.0
	
	if rug_id == "d_rug_paw_pink":
		# Thảm Bàn Chân Mèo Hồng Pastel
		var pad_pts = _make_iso_ellipse(rug_center, rug_rx, rug_ry, 32)
		draw_colored_polygon(pad_pts, Color(1.0, 0.86, 0.90, 0.95))
		draw_polyline(pad_pts, Color(0.92, 0.55, 0.68, 0.9), 1.5)
		
		# Đệm chính giữa màu hồng đào
		var main_bean = _make_iso_ellipse(rug_center, rug_rx * 0.55, rug_ry * 0.55, 24)
		draw_colored_polygon(main_bean, Color(0.95, 0.62, 0.75, 0.85))
		
		# 3 Ngón chân mèo nhỏ phía trên
		draw_colored_polygon(_make_iso_ellipse(rug_center + Vector2(-22, -10), 10.0, 6.0, 16), Color(0.95, 0.62, 0.75, 0.85))
		draw_colored_polygon(_make_iso_ellipse(rug_center + Vector2(0, -18), 11.0, 7.0, 16), Color(0.95, 0.62, 0.75, 0.85))
		draw_colored_polygon(_make_iso_ellipse(rug_center + Vector2(22, -10), 10.0, 6.0, 16), Color(0.95, 0.62, 0.75, 0.85))
	else:
		if rug_boho_tex:
			draw_texture_rect(rug_boho_tex, Rect2(rug_center - Vector2(55, 41), Vector2(110, 82)), false)
		else:
			# Thảm len Bohemian ấm áp
			var fringe_pts = _make_iso_ellipse(rug_center, rug_rx + 4.0, rug_ry + 2.0, 32)
			draw_colored_polygon(fringe_pts, Color(0.88, 0.78, 0.65, 0.6))
			
			var rug_pts = _make_iso_ellipse(rug_center, rug_rx, rug_ry, 32)
			draw_colored_polygon(rug_pts, Color(0.98, 0.93, 0.86, 0.95))
			draw_polyline(rug_pts, Color(0.78, 0.58, 0.42, 0.9), 1.5)
			
			var inner_rug = _make_iso_ellipse(rug_center, rug_rx * 0.72, rug_ry * 0.72, 24)
			draw_polyline(inner_rug, Color(0.85, 0.52, 0.38, 0.8), 1.5)
			
			draw_circle(rug_center, 4.0, Color(0.85, 0.52, 0.38, 0.7))
			draw_circle(rug_center + Vector2(-5, -3), 2.0, Color(0.85, 0.52, 0.38, 0.7))
			draw_circle(rug_center + Vector2(0, -6), 2.0, Color(0.85, 0.52, 0.38, 0.7))
			draw_circle(rug_center + Vector2(5, -3), 2.0, Color(0.85, 0.52, 0.38, 0.7))

# 6. Vẽ Cửa Ra Vào Phòng Trọ P.102 & Cửa Sổ Pixel-Art
func _draw_door_and_window() -> void:
	# Cửa chính phòng trọ (Trên tường Tây Bắc, u=0, v từ 2.4 đến 5.4)
	var d_bottom_1 = IsometricGrid.grid_to_screen(Vector2(0, 5.2), origin)
	var d_bottom_2 = IsometricGrid.grid_to_screen(Vector2(0, 2.4), origin)
	var door_h = 108.0
	var d_top_1 = d_bottom_1 + Vector2(0, -door_h)
	var d_top_2 = d_bottom_2 + Vector2(0, -door_h)
	
	# Khung bao cửa gỗ đậm
	var frame_pts = PackedVector2Array([
		d_bottom_1 + Vector2(-3, 0),
		d_top_1 + Vector2(-3, -4),
		d_top_2 + Vector2(3, -4),
		d_bottom_2 + Vector2(3, 0)
	])
	draw_colored_polygon(frame_pts, Color(0.35, 0.22, 0.14, 1.0))
	
	# Cánh cửa gỗ vân ấm
	var door_pts = PackedVector2Array([d_bottom_1, d_top_1, d_top_2, d_bottom_2])
	draw_colored_polygon(door_pts, Color(0.68, 0.48, 0.32, 1.0))
	draw_polyline(door_pts, Color(0.42, 0.28, 0.18, 1.0), 1.5)
	
	# Ô pano trên và dưới
	var p_mid_1 = d_bottom_1 + Vector2(0, -door_h * 0.48)
	var p_mid_2 = d_bottom_2 + Vector2(0, -door_h * 0.48)
	draw_line(p_mid_1, p_mid_2, Color(0.42, 0.28, 0.18, 1.0), 2.0)
	
	# Tay nắm tròn bằng đồng
	var handle_pos = (d_bottom_1 + d_bottom_2) * 0.5 + Vector2(8, -door_h * 0.45)
	draw_circle(handle_pos, 4.0, Color(0.95, 0.78, 0.25, 1.0))
	draw_circle(handle_pos, 2.0, Color(0.60, 0.45, 0.10, 1.0))
	
	# Biển số phòng sinh viên "P.102 🐾"
	var sign_center = (d_top_1 + d_top_2) * 0.5 + Vector2(0, -14)
	var sign_w = 46.0
	var sign_h = 16.0
	var sign_rect = Rect2(sign_center.x - sign_w * 0.5, sign_center.y - sign_h * 0.5, sign_w, sign_h)
	draw_rect(sign_rect, Color(0.24, 0.16, 0.10, 0.95), true)
	draw_rect(sign_rect, Color(0.95, 0.82, 0.45, 1.0), false, 1.5)
	draw_string(ThemeDB.fallback_font, sign_center + Vector2(-20, 4), "P.102 🐾", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(1.0, 0.92, 0.65))
	
	# Cửa sổ đón nắng pixel art trên tường Đông Bắc (v=0, u=3.8)
	if window_tex:
		var win_pos = IsometricGrid.grid_to_screen(Vector2(3.2, 0), origin) + Vector2(-15, -135)
		draw_texture_rect(window_tex, Rect2(win_pos, Vector2(55, 85)), false)
	else:
		# Fallback cửa sổ
		var w_bottom_1 = IsometricGrid.grid_to_screen(Vector2(2.5, 0), origin) + Vector2(0, -35)
		var w_bottom_2 = IsometricGrid.grid_to_screen(Vector2(5.5, 0), origin) + Vector2(0, -35)
		var w_top_1 = w_bottom_1 + Vector2(0, -80)
		var w_top_2 = w_bottom_2 + Vector2(0, -80)
		draw_colored_polygon(PackedVector2Array([w_bottom_1, w_top_1, w_top_2, w_bottom_2]), Color(0.70, 0.85, 0.95, 0.85))

# 7. Viền Chân Tường & Bo Viền Sàn Nhà
func _draw_baseboard_and_border() -> void:
	var p_top = origin
	var p_left = IsometricGrid.grid_to_screen(Vector2(0, IsometricGrid.GRID_SIZE), origin)
	var p_bottom = IsometricGrid.grid_to_screen(Vector2(IsometricGrid.GRID_SIZE, IsometricGrid.GRID_SIZE), origin)
	var p_right = IsometricGrid.grid_to_screen(Vector2(IsometricGrid.GRID_SIZE, 0), origin)
	
	var floor_thickness = 14.0
	
	# Mặt cắt bên trái
	var left_edge_pts = PackedVector2Array([
		p_left,
		p_bottom,
		p_bottom + Vector2(0, floor_thickness),
		p_left + Vector2(0, floor_thickness)
	])
	draw_colored_polygon(left_edge_pts, Color(0.52, 0.38, 0.25, 1.0))
	
	# Mặt cắt bên phải
	var right_edge_pts = PackedVector2Array([
		p_bottom,
		p_right,
		p_right + Vector2(0, floor_thickness),
		p_bottom + Vector2(0, floor_thickness)
	])
	draw_colored_polygon(right_edge_pts, Color(0.42, 0.30, 0.18, 1.0))
	
	# Đường chu vi bao quanh sàn
	draw_polyline(PackedVector2Array([p_top, p_left, p_bottom, p_right, p_top]), Color(0.32, 0.22, 0.12, 0.85), 2.0)
	draw_polyline(PackedVector2Array([p_left + Vector2(0, floor_thickness), p_bottom + Vector2(0, floor_thickness), p_right + Vector2(0, floor_thickness)]), Color(0.22, 0.14, 0.08, 0.95), 2.0)

func _make_iso_ellipse(center: Vector2, rx: float, ry: float, segments: int = 24) -> PackedVector2Array:
	var pts = PackedVector2Array()
	for i in range(segments):
		var theta = float(i) / float(segments) * TAU
		var x = center.x + cos(theta) * rx
		var y = center.y + sin(theta) * ry
		pts.append(Vector2(x, y))
	return pts

func set_decor_grid_visible(active: bool) -> void:
	show_iso_grid = active
	if not active:
		hovered_grid_cell = Vector2i(-1, -1)
	queue_redraw()

func set_grid_highlight(cell: Vector2i, is_valid: bool) -> void:
	hovered_grid_cell = cell
	hovered_cell_valid = is_valid
	queue_redraw()

func _draw_decor_grid_overlay() -> void:
	var n: int = IsometricGrid.GRID_SIZE
	for i in range(n + 1):
		var a1 = IsometricGrid.grid_to_screen(Vector2(float(i), 0.0), origin)
		var b1 = IsometricGrid.grid_to_screen(Vector2(float(i), float(n)), origin)
		draw_line(a1, b1, Color(1.0, 0.96, 0.85, 0.35), 1.0)
		var a2 = IsometricGrid.grid_to_screen(Vector2(0.0, float(i)), origin)
		var b2 = IsometricGrid.grid_to_screen(Vector2(float(n), float(i)), origin)
		draw_line(a2, b2, Color(1.0, 0.96, 0.85, 0.35), 1.0)

	if hovered_grid_cell.x >= 0 and hovered_grid_cell.y >= 0:
		var u: float = float(hovered_grid_cell.x)
		var v: float = float(hovered_grid_cell.y)
		var p0 = IsometricGrid.grid_to_screen(Vector2(u, v), origin)
		var p1 = IsometricGrid.grid_to_screen(Vector2(u + 1.0, v), origin)
		var p2 = IsometricGrid.grid_to_screen(Vector2(u + 1.0, v + 1.0), origin)
		var p3 = IsometricGrid.grid_to_screen(Vector2(u, v + 1.0), origin)
		var fill_col: Color = Color(0.22, 0.85, 0.38, 0.45) if hovered_cell_valid else Color(0.96, 0.52, 0.14, 0.50)
		var edge_col: Color = Color(0.12, 0.62, 0.25, 0.95) if hovered_cell_valid else Color(0.90, 0.32, 0.05, 0.95)
		draw_colored_polygon(PackedVector2Array([p0, p1, p2, p3]), fill_col)
		draw_polyline(PackedVector2Array([p0, p1, p2, p3, p0]), edge_col, 2.0)
