extends SceneTree

func _init() -> void:
	var path = "assets/UI/CatUIPaid/CatUIPaid/catUI.png"
	var img = Image.load_from_file(path)
	# Check column x=300 from y=440 to 620
	print("Scanning column x=300 for panel_cat_ear_cream:")
	for y in range(440, 620):
		var c = img.get_pixel(300, y)
		if c.a > 0.05:
			# print first and last y
			pass
	# Let's inspect x=260..350, y=440..620
	var min_y = 9999
	var max_y = -1
	for y in range(440, 605):
		for x in range(260, 350):
			if img.get_pixel(x, y).a > 0.05:
				if y < min_y: min_y = y
				if y > max_y: max_y = y
	print("Cat Ear Cream Panel: min_y=", min_y, " max_y=", max_y)
	quit(0)
