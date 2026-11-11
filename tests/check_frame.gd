extends SceneTree

func _init() -> void:
	var img = Image.load_from_file("D:/BestSen/assets/UI/CatUIPaid/slices/avatar_frames/frame_cat_ear_beige.png")
	if img:
		print("Frame size: ", img.get_size())
		print("Center pixel: ", img.get_pixel(img.get_width()/2, img.get_height()/2))
		print("Pixel (20,20): ", img.get_pixel(20, 20))
	quit()
