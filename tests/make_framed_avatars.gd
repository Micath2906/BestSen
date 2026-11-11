extends SceneTree

func _init() -> void:
	var frame = Image.load_from_file("D:/BestSen/assets/UI/CatUIPaid/slices/avatar_frames/frame_cat_ear_beige.png")
	
	# composite for 8 and 9
	for id in [8, 9]:
		var comp = Image.create(32, 32, false, Image.FORMAT_RGBA8)
		comp.blit_rect(frame, Rect2i(0, 0, 32, 32), Vector2i.ZERO)
		var av = Image.load_from_file("D:/BestSen/assets/sprites/avatars/avatar_%d.png" % id)
		if av:
			# Cat in av is 32x32, scale down slightly to 26x26 so it sits neatly in the card
			var av_scaled = av.duplicate()
			av_scaled.resize(24, 24, Image.INTERPOLATE_NEAREST)
			comp.blit_rect_mask(av_scaled, av_scaled, Rect2i(0, 0, 24, 24), Vector2i(4, 7))
		comp.save_png("D:/BestSen/assets/sprites/avatars/framed_avatar_%d.png" % id)
		print("Đã tạo framed_avatar_%d.png!" % id)
	quit()
