extends SceneTree

func _init() -> void:
	var img = Image.load_from_file("assets/furnitures/CatRoomPaid/CatRoomPaid/Rooms/Room1.png")
	# Top corner of floor: (256, 199)
	# Bottom corner: along x=256, find where floor ends
	for y in range(410, 460):
		var c = img.get_pixel(256, y)
		if c.a > 0.1:
			print("x=256, y=", y, " c=", c.to_html(false))
	# Left corner of floor: along y=... find leftmost x
	# Right corner of floor: find rightmost x
	var min_x = 999
	var min_xy = Vector2.ZERO
	var max_x = -1
	var max_xy = Vector2.ZERO
	for y in range(199, 450):
		for x in range(img.get_width()):
			var c = img.get_pixel(x, y)
			if c.a > 0.1:
				if x < min_x:
					min_x = x
					min_xy = Vector2(x, y)
				if x > max_x:
					max_x = x
					max_xy = Vector2(x, y)
	print("Left corner: ", min_xy, " Right corner: ", max_xy)
	quit(0)
