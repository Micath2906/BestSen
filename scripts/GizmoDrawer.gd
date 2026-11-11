extends Node2D

const RADIUS = 68.0

func _draw() -> void:
	# 1. Vẽ ô highlight màu vàng chanh pastel dưới chân đồ vật
	var highlight_rect = Rect2(-36, -14, 72, 28)
	draw_rect(highlight_rect, Color(1.0, 0.95, 0.3, 0.35), true)
	draw_rect(highlight_rect, Color(1.0, 0.82, 0.1, 0.85), false, 2.0)
	
	# 2. Vẽ vòng tròn cung thanh mảnh bao quanh món đồ
	draw_arc(Vector2.ZERO, RADIUS, 0.0, TAU, 64, Color(1.0, 1.0, 1.0, 0.75), 2.0, true)
	
	# 3. Vẽ đường chỉ dẫn mờ tới các nút công cụ
	draw_line(Vector2(-RADIUS * 0.95, RADIUS * 0.3), Vector2(0, -RADIUS), Color(1.0, 1.0, 1.0, 0.4), 1.0)
	draw_line(Vector2(0, -RADIUS), Vector2(RADIUS * 0.95, RADIUS * 0.3), Color(1.0, 1.0, 1.0, 0.4), 1.0)
