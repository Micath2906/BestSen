extends SceneTree

func _init() -> void:
	var font = load("res://assets/font/SVN-Retron 2000.ttf")
	print("Load test: ", font)
	if font:
		print("Font loaded successfully via load()!")
		print("Font name: ", font.font_name)
		print("Has Vietnamese 'Tiếng Việt': ", font.has_char("ệ".unicode_at(0)))
	quit()
