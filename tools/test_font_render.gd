extends SceneTree

func _init() -> void:
	var font = load("res://assets/font/SVN-Retron 2000.ttf")
	# Add system font fallback for emojis
	var sys_font = SystemFont.new()
	sys_font.font_names = PackedStringArray(["Segoe UI Emoji", "Noto Color Emoji", "Apple Color Emoji", "sans-serif"])
	font.fallbacks = [sys_font]
	
	var label = Label.new()
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", 16)
	label.text = "🐾 Bài 1: Bắt xe buýt liên quận (10 Cá 🐟) Tiếng Việt có dấu: ế, ắ, ừ, ợ"
	
	print("Label configured properly with font and emoji fallback!")
	quit()
