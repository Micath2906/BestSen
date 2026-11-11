extends SceneTree

func _init() -> void:
	# 1. Tạo icon_star.png (14x14 pixel art ngôi sao vàng viền nâu gỗ)
	var star_img = Image.create(14, 14, false, Image.FORMAT_RGBA8)
	var c_border = Color("#4a3319")
	var c_gold_bright = Color("#ffeb3b")
	var c_gold = Color("#fbc02d")
	var c_gold_dark = Color("#f57f17")
	
	# Pixel art 14x14 star
	var star_map = [
		"..............",
		"......XX......",
		"......YY......",
		".....XYYX.....",
		"....XXYYYYXX..",
		"..XXYYYYYYYYX.",
		"XXYYYYYYYYYYX.",
		"..XXYYYYYYYYX.",
		"...XYYYYYYYX..",
		"..XYYYXXYYYX..",
		"..XYYX..XYYX..",
		".XYYX....XYYX.",
		".XX........XX.",
		".............."
	]
	
	for y in range(14):
		var row = star_map[y]
		for x in range(14):
			var ch = row[x]
			if ch == 'X':
				star_img.set_pixel(x, y, c_border)
			elif ch == 'Y':
				if y <= 5:
					star_img.set_pixel(x, y, c_gold_bright)
				elif y <= 8:
					star_img.set_pixel(x, y, c_gold)
				else:
					star_img.set_pixel(x, y, c_gold_dark)
	
	star_img.save_png("D:/BestSen/assets/UI/CatUIPaid/slices/icon_star.png")
	print("Đã tạo icon_star.png 14x14 vàng óng chuẩn pixel!")
	
	# 2. Tạo icon_music.png (14x14 pixel art nốt nhạc đôi viền nâu gỗ cho BGM)
	var music_img = Image.create(14, 14, false, Image.FORMAT_RGBA8)
	var c_dark = Color("#4a3319")
	var c_note = Color("#795548")
	
	var note_map = [
		"..............",
		"...XXXXXXXXX..",
		"...XXXXXXXXX..",
		"...XX....XX...",
		"...XX....XX...",
		"...XX....XX...",
		"...XX....XX...",
		".XXXX...XXXX..",
		"XXXXXX.XXXXXX.",
		"XXXXXX.XXXXXX.",
		".XXXX...XXXX..",
		"..............",
		"..............",
		".............."
	]
	
	for y in range(14):
		var row = note_map[y]
		for x in range(14):
			var ch = row[x]
			if ch == 'X':
				music_img.set_pixel(x, y, c_dark)
	
	music_img.save_png("D:/BestSen/assets/UI/CatUIPaid/slices/icon_music.png")
	print("Đã tạo icon_music.png 14x14 nốt nhạc cho BGM!")
	quit()
