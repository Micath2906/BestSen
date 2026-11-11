extends SceneTree

func _init():
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	var center = Vector2(7.5, 7.5)
	var radius = 6.0
	
	for y in range(16):
		for x in range(16):
			var dist = Vector2(x + 0.5, y + 0.5).distance_to(center)
			if dist <= radius:
				# Highlight ở nửa trên
				if y < 7:
					img.set_pixel(x, y, Color(1.0, 1.0, 1.0, 1.0))
				elif dist > radius - 1.0:
					img.set_pixel(x, y, Color(0.82, 0.82, 0.84, 1.0)) # Viền nhẹ
				else:
					img.set_pixel(x, y, Color(0.92, 0.93, 0.94, 1.0)) # Thân tròn trắng bạc
			elif dist <= radius + 0.8:
				# Antialias viền ngoài
				var alpha = 1.0 - (dist - radius) / 0.8
				img.set_pixel(x, y, Color(0.5, 0.5, 0.5, alpha * 0.4))
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				
	img.save_png("res://assets/UI/slider_grabber_circle.png")
	print("Generated res://assets/UI/slider_grabber_circle.png successfully!")
	quit()
