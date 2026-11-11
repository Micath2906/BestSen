class_name IsometricGrid
extends RefCounted

# IsometricGrid.gd - Hệ thống toán học chuyển đổi hệ tọa độ 2.5D Dimetric (2:1 Ratio)
# Chuẩn True 2.5D Isometric Top-Down cho căn phòng trọ sinh viên hình thoi

const TILE_W: float = 56.0
const TILE_H: float = 28.0 # Tỷ lệ chuẩn 2:1 Dimetric
const GRID_SIZE: int = 8   # Phòng trọ hình thoi 8x8 ô lưới

# Chuyển đổi tọa độ lưới ô [u, v] sang tọa độ màn hình Pixel [x, y]
static func grid_to_screen(grid_pos: Vector2, origin: Vector2) -> Vector2:
	var sx = origin.x + (grid_pos.x - grid_pos.y) * (TILE_W * 0.5)
	var sy = origin.y + (grid_pos.x + grid_pos.y) * (TILE_H * 0.5)
	return Vector2(sx, sy)

# Chuyển đổi tọa độ màn hình Pixel [x, y] sang tọa độ lưới ô [u, v]
static func screen_to_grid(screen_pos: Vector2, origin: Vector2) -> Vector2:
	var rel = screen_pos - origin
	var u = (rel.x / (TILE_W * 0.5) + rel.y / (TILE_H * 0.5)) * 0.5
	var v = (rel.y / (TILE_H * 0.5) - rel.x / (TILE_W * 0.5)) * 0.5
	return Vector2(u, v)

# Giới hạn vị trí Mèo luôn nằm trọn trong căn phòng hình thoi khép kín
static func clamp_to_room(grid_pos: Vector2, margin: float = 0.8) -> Vector2:
	var max_val = float(GRID_SIZE) - margin
	return Vector2(
		clampf(grid_pos.x, margin, max_val),
		clampf(grid_pos.y, margin, max_val)
	)

# Kiểm tra một điểm pixel màn hình có nằm trong mặt sàn hình thoi hay không
static func is_point_inside_floor(screen_pos: Vector2, origin: Vector2, margin: float = 0.0) -> bool:
	var g = screen_to_grid(screen_pos, origin)
	return g.x >= margin and g.x <= (float(GRID_SIZE) - margin) and g.y >= margin and g.y <= (float(GRID_SIZE) - margin)

# Tính vector 8 hướng di chuyển trong không gian Isometric
static func get_iso_direction(from_grid: Vector2, to_grid: Vector2) -> Vector2:
	var diff = to_grid - from_grid
	if diff.length_squared() < 0.001:
		return Vector2.ZERO
	return diff.normalized()
