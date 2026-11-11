extends Node

func _ready() -> void:
	var font = load("res://assets/font/SVN-Retron 2000.ttf")
	var sys_font = SystemFont.new()
	sys_font.font_names = PackedStringArray(["Segoe UI Emoji", "Noto Color Emoji", "Apple Color Emoji", "sans-serif"])
	if font and font is FontFile:
		font.fallbacks = [sys_font]
	
	var canvas = Control.new()
	canvas.custom_minimum_size = Vector2(540, 300)
	add_child(canvas)
	
	var bg = ColorRect.new()
	bg.color = Color(0.96, 0.94, 0.91, 1.0)
	bg.custom_minimum_size = Vector2(540, 300)
	canvas.add_child(bg)
	
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(20, 20)
	vbox.size = Vector2(500, 260)
	vbox.add_theme_constant_override("separation", 10)
	canvas.add_child(vbox)
	
	var l1 = Label.new()
	l1.text = "🐾 BEST SEN - MÈO TỰ LẬP (Font SVN-Retron 2000)"
	l1.add_theme_font_override("font", font)
	l1.add_theme_font_size_override("font_size", 16)
	l1.add_theme_color_override("font_color", Color(0.85, 0.35, 0.1))
	vbox.add_child(l1)
	
	var l2 = Label.new()
	l2.text = "Bài 1: Bắt xe buýt liên quận - Vẫy xe từ xa 🚌"
	l2.add_theme_font_override("font", font)
	l2.add_theme_font_size_override("font_size", 14)
	l2.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))
	vbox.add_child(l2)
	
	var l3 = Label.new()
	l3.text = "Tiếng Việt đầy đủ dấu: Á, Ả, Ã, Ạ, Ắ, Ằ, Ẵ, Ặ, Ế, Ề, Ể, Ễ, Ệ, Ố, Ồ, Ổ, Ỗ, Ộ, Ứ, Ừ, Ử, Ữ, Ự"
	l3.add_theme_font_override("font", font)
	l3.add_theme_font_size_override("font_size", 11)
	l3.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35))
	vbox.add_child(l3)
	
	var btn = Button.new()
	btn.text = "🚀 BẮT ĐẦU DẠY MÈO NGAY! (15 Cá 🐟)"
	btn.add_theme_font_override("font", font)
	btn.add_theme_font_size_override("font_size", 14)
	btn.custom_minimum_size = Vector2(0, 48)
	var b_style = StyleBoxFlat.new()
	b_style.bg_color = Color(1.0, 0.55, 0.1)
	b_style.border_color = Color(0.85, 0.35, 0.05)
	b_style.set_border_width_all(2)
	b_style.set_corner_radius_all(14)
	btn.add_theme_stylebox_override("normal", b_style)
	vbox.add_child(btn)
	
	await get_tree().create_timer(0.3).timeout
	var img = get_viewport().get_texture().get_image()
	img.save_png("D:/BestSen/test_font_render.png")
	print("Saved D:/BestSen/test_font_render.png")
	get_tree().quit()
