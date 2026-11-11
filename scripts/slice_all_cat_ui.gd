extends SceneTree

# Detailed detector for elements in catUI.png
func _init() -> void:
	var path = "assets/UI/CatUIPaid/CatUIPaid/catUI.png"
	var img = Image.load_from_file(path)
	var out_dir = "assets/UI/CatUIPaid/slices/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	
	print("--- SLICING CAT UI ASSETS ---")
	
	# 1. Big Cat-Ear Panels (around y=470..700)
	# Cream Cat Panel: x=262, y=472, w=84, h=125
	_slice_trimmed(img, Rect2i(260, 470, 90, 130), out_dir + "panel_cat_ear_cream.png")
	# Beige Cat Panel: x=355, y=470, w=90, h=130
	_slice_trimmed(img, Rect2i(355, 470, 90, 130), out_dir + "panel_cat_ear_beige.png")
	# Pink Cat Panel: x=260, y=608, w=90, h=130
	_slice_trimmed(img, Rect2i(260, 608, 90, 130), out_dir + "panel_cat_ear_pink.png")
	# Blue Cat Panel: x=355, y=608, w=90, h=130
	_slice_trimmed(img, Rect2i(355, 608, 90, 130), out_dir + "panel_cat_ear_blue.png")
	
	# 2. Sitting Cat PLAY Button (bottom center y=860..944)
	# Tan cat play: x=228, y=862, w=168, h=66
	_slice_trimmed(img, Rect2i(225, 860, 172, 70), out_dir + "btn_cat_play_tan.png")
	# Brown cat play: x=228, y=928, w=168, h=66
	_slice_trimmed(img, Rect2i(225, 928, 172, 70), out_dir + "btn_cat_play_brown.png")
	
	# 3. Modal Popup with OK button (bottom left)
	# Pink modal with OK: x=0, y=860, w=100, h=72
	_slice_trimmed(img, Rect2i(0, 860, 100, 72), out_dir + "modal_popup_pink.png")
	# Beige modal with OK: x=110, y=860, w=100, h=72
	_slice_trimmed(img, Rect2i(110, 860, 100, 72), out_dir + "modal_popup_beige.png")
	# Blue modal with OK: x=0, y=930, w=100, h=72
	_slice_trimmed(img, Rect2i(0, 930, 100, 72), out_dir + "modal_popup_blue.png")
	# Blue/green modal with OK: x=110, y=930, w=100, h=72
	_slice_trimmed(img, Rect2i(110, 930, 100, 72), out_dir + "modal_popup_mint.png")
	
	# 4. Dialog Box with Sleeping Cat & YES / NO buttons (top y=4..190)
	# Orange sleeping cat: x=165, y=4, w=76, h=50
	_slice_trimmed(img, Rect2i(165, 4, 76, 50), out_dir + "dialog_cat_sleep_orange.png")
	# Pink sleeping cat: x=165, y=55, w=76, h=50
	_slice_trimmed(img, Rect2i(165, 55, 76, 50), out_dir + "dialog_cat_sleep_pink.png")
	# Blue sleeping cat: x=245, y=55, w=76, h=50
	_slice_trimmed(img, Rect2i(245, 55, 76, 50), out_dir + "dialog_cat_sleep_blue.png")
	
	# 5. Top-Left Cat Ear Header Bars (y=0..130)
	# Cat ear header bar 1: x=0, y=0, w=160, h=36
	_slice_trimmed(img, Rect2i(0, 0, 160, 36), out_dir + "hud_header_cat_ear_beige.png")
	# Cat ear header bar blue: x=0, y=98, w=160, h=36
	_slice_trimmed(img, Rect2i(0, 98, 160, 36), out_dir + "hud_header_cat_ear_blue.png")
	
	# 6. Sliders (middle right y=470..590, x=446..512)
	# Slider track brown: x=448, y=475, w=60, h=16
	_slice_trimmed(img, Rect2i(448, 475, 60, 16), out_dir + "slider_track_brown.png")
	# Slider track blue: x=448, y=490, w=60, h=16
	_slice_trimmed(img, Rect2i(448, 490, 60, 16), out_dir + "slider_track_blue.png")
	# Slider track pink: x=448, y=540, w=60, h=16
	_slice_trimmed(img, Rect2i(448, 540, 60, 16), out_dir + "slider_track_pink.png")
	# Slider knob / grabber: x=450, y=475, w=16, h=16
	_slice_trimmed(img, Rect2i(450, 475, 14, 14), out_dir + "slider_knob_wood.png")
	
	# 7. Paw Buttons (around x=325..512, y=150..200)
	_slice_trimmed(img, Rect2i(325, 150, 40, 38), out_dir + "icon_paw_lg_1.png")
	_slice_trimmed(img, Rect2i(374, 150, 40, 38), out_dir + "icon_paw_lg_2.png")
	_slice_trimmed(img, Rect2i(424, 150, 40, 38), out_dir + "icon_paw_lg_3.png")
	_slice_trimmed(img, Rect2i(472, 150, 40, 38), out_dir + "icon_paw_lg_4.png")
	
	# 8. Square Paw Buttons (x=205..255, y=640..695)
	_slice_trimmed(img, Rect2i(206, 642, 18, 18), out_dir + "btn_paw_sq_cream.png")
	_slice_trimmed(img, Rect2i(224, 642, 18, 18), out_dir + "btn_paw_sq_tan.png")
	_slice_trimmed(img, Rect2i(242, 642, 18, 18), out_dir + "btn_paw_sq_dark.png")
	_slice_trimmed(img, Rect2i(206, 660, 18, 18), out_dir + "btn_paw_sq_pressed.png")
	
	# 9. Fish Bones & Currency (x=465..512, y=200..270)
	_slice_trimmed(img, Rect2i(465, 204, 30, 15), out_dir + "icon_fishbone_blue.png")
	_slice_trimmed(img, Rect2i(465, 220, 30, 15), out_dir + "icon_fishbone_dark.png")
	_slice_trimmed(img, Rect2i(465, 252, 30, 15), out_dir + "icon_fishbone_green.png")
	
	# 10. Small Icons (x=0..120, y=470..620)
	# Row 1: +, ?, $, heart, star, check, x, home, sound, mute, pause, gear, play
	_slice_trimmed(img, Rect2i(0, 472, 14, 14), out_dir + "icon_plus.png")
	_slice_trimmed(img, Rect2i(13, 472, 14, 14), out_dir + "icon_question.png")
	_slice_trimmed(img, Rect2i(26, 472, 14, 14), out_dir + "icon_coin_dollar.png")
	_slice_trimmed(img, Rect2i(38, 472, 14, 14), out_dir + "icon_heart.png")
	_slice_trimmed(img, Rect2i(50, 472, 14, 14), out_dir + "icon_star.png")
	_slice_trimmed(img, Rect2i(63, 472, 14, 14), out_dir + "icon_check.png")
	_slice_trimmed(img, Rect2i(76, 472, 14, 14), out_dir + "icon_cross.png")
	_slice_trimmed(img, Rect2i(0, 488, 14, 14), out_dir + "icon_home.png")
	_slice_trimmed(img, Rect2i(13, 488, 14, 14), out_dir + "icon_sound.png")
	_slice_trimmed(img, Rect2i(26, 488, 14, 14), out_dir + "icon_sound_off.png")
	_slice_trimmed(img, Rect2i(38, 488, 14, 14), out_dir + "icon_pause.png")
	_slice_trimmed(img, Rect2i(0, 504, 14, 14), out_dir + "icon_minus.png")
	_slice_trimmed(img, Rect2i(13, 504, 14, 14), out_dir + "icon_gear.png")
	_slice_trimmed(img, Rect2i(26, 504, 14, 14), out_dir + "icon_arrow_right.png")
	_slice_trimmed(img, Rect2i(38, 504, 14, 14), out_dir + "icon_arrow_left.png")
	
	# 11. Sleeping Cats (bottom right x=415..512, y=855..944)
	_slice_trimmed(img, Rect2i(415, 855, 45, 36), out_dir + "cat_sleep_grey.png")
	_slice_trimmed(img, Rect2i(465, 855, 45, 36), out_dir + "cat_sleep_cream.png")
	_slice_trimmed(img, Rect2i(415, 895, 45, 36), out_dir + "cat_sleep_white.png")
	_slice_trimmed(img, Rect2i(465, 895, 45, 36), out_dir + "cat_sleep_orange.png")
	
	# 12. Pill Buttons (around x=0..230, y=775..860)
	_slice_trimmed(img, Rect2i(0, 776, 46, 20), out_dir + "btn_pill_blue.png")
	_slice_trimmed(img, Rect2i(54, 776, 46, 20), out_dir + "btn_pill_cyan.png")
	_slice_trimmed(img, Rect2i(126, 776, 46, 20), out_dir + "btn_pill_brown.png")
	_slice_trimmed(img, Rect2i(182, 776, 46, 20), out_dir + "btn_pill_tan.png")
	_slice_trimmed(img, Rect2i(0, 808, 46, 20), out_dir + "btn_pill_dark.png")
	_slice_trimmed(img, Rect2i(54, 808, 46, 20), out_dir + "btn_pill_pink.png")
	_slice_trimmed(img, Rect2i(126, 808, 46, 20), out_dir + "btn_pill_cream.png")
	_slice_trimmed(img, Rect2i(0, 840, 46, 20), out_dir + "btn_pill_light_pink.png")
	_slice_trimmed(img, Rect2i(54, 840, 46, 20), out_dir + "btn_pill_peach.png")
	
	# 13. Directional Arrow Badges (x=270..512, y=745..840)
	_slice_trimmed(img, Rect2i(270, 748, 54, 26), out_dir + "btn_arrow_right_grey.png")
	_slice_trimmed(img, Rect2i(330, 748, 54, 26), out_dir + "btn_arrow_right_cream.png")
	_slice_trimmed(img, Rect2i(395, 748, 54, 26), out_dir + "btn_arrow_right_pink.png")
	_slice_trimmed(img, Rect2i(270, 785, 54, 26), out_dir + "btn_arrow_right_brown.png")
	_slice_trimmed(img, Rect2i(270, 818, 54, 26), out_dir + "btn_arrow_right_dark.png")
	
	# 14. Cat Chat Bubbles (x=210..245, y=700..755)
	_slice_trimmed(img, Rect2i(210, 700, 36, 26), out_dir + "speech_bubble_tan.png")
	_slice_trimmed(img, Rect2i(210, 730, 36, 26), out_dir + "speech_bubble_blue.png")
	
	# 15. Rounded Cards for lists (9-patchable) (x=0..120, y=270..360)
	_slice_trimmed(img, Rect2i(0, 270, 28, 28), out_dir + "frame_rounded_cream.png")
	_slice_trimmed(img, Rect2i(30, 270, 28, 28), out_dir + "frame_rounded_sand.png")
	_slice_trimmed(img, Rect2i(0, 375, 28, 28), out_dir + "frame_rounded_dark.png")
	_slice_trimmed(img, Rect2i(130, 375, 28, 28), out_dir + "frame_rounded_pink.png")
	
	print("--- FINISHED SLICING ALL CAT UI ASSETS! ---")
	quit(0)

func _slice_trimmed(src: Image, rect: Rect2i, out_path: String) -> void:
	# Clamp rect inside src
	var clamped = rect.intersection(Rect2i(0, 0, src.get_width(), src.get_height()))
	if clamped.size.x <= 0 or clamped.size.y <= 0:
		return
	var sub = src.get_region(clamped)
	var used = _get_used_rect(sub)
	if used.size.x > 0 and used.size.y > 0:
		var trimmed = sub.get_region(used)
		trimmed.save_png(out_path)
		print("  -> %s (%dx%d)" % [out_path.get_file(), used.size.x, used.size.y])
	else:
		sub.save_png(out_path)
		print("  -> %s untrimmed (%dx%d)" % [out_path.get_file(), clamped.size.x, clamped.size.y])

func _get_used_rect(img: Image) -> Rect2i:
	var min_x = img.get_width()
	var min_y = img.get_height()
	var max_x = -1
	var max_y = -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a > 0.05:
				if x < min_x: min_x = x
				if y < min_y: min_y = y
				if x > max_x: max_x = x
				if y > max_y: max_y = y
	if max_x < min_x or max_y < min_y:
		return Rect2i(0, 0, 0, 0)
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
