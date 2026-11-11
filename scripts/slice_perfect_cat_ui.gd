extends SceneTree

func _init() -> void:
	var path = "assets/UI/CatUIPaid/CatUIPaid/catUI.png"
	var img = Image.load_from_file(path)
	var out_dir = "assets/UI/CatUIPaid/slices/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	
	# 1. Four Cat-Ear Panels (85x115)
	_save(img, Rect2i(263, 454, 85, 115), out_dir + "panel_cat_ear_cream.png")
	_save(img, Rect2i(358, 454, 85, 115), out_dir + "panel_cat_ear_beige.png")
	_save(img, Rect2i(263, 581, 85, 115), out_dir + "panel_cat_ear_pink.png")
	_save(img, Rect2i(358, 581, 85, 115), out_dir + "panel_cat_ear_blue.png")
	
	# 2. Sitting Cat PLAY Buttons (163x58)
	_save(img, Rect2i(229, 819, 163, 58), out_dir + "btn_cat_play_tan.png")
	_save(img, Rect2i(228, 884, 163, 58), out_dir + "btn_cat_play_brown.png")
	
	# 3. Modal Popups with OK Button (96x61)
	_save(img, Rect2i(0, 818, 96, 61), out_dir + "modal_popup_pink.png")
	_save(img, Rect2i(112, 818, 96, 61), out_dir + "modal_popup_beige.png")
	_save(img, Rect2i(0, 882, 96, 61), out_dir + "modal_popup_blue.png")
	_save(img, Rect2i(112, 881, 96, 61), out_dir + "modal_popup_mint.png")
	
	# 4. Sleeping Cat Dialogs (75x43)
	_save(img, Rect2i(165, 5, 75, 43), out_dir + "dialog_cat_sleep_orange.png")
	_save(img, Rect2i(245, 5, 75, 43), out_dir + "dialog_cat_sleep_brown.png")
	_save(img, Rect2i(165, 53, 75, 43), out_dir + "dialog_cat_sleep_pink.png")
	_save(img, Rect2i(245, 53, 75, 43), out_dir + "dialog_cat_sleep_blue.png")
	
	# 5. Sleeping Cats (43x32)
	_save(img, Rect2i(419, 811, 43, 32), out_dir + "cat_sleep_grey.png")
	_save(img, Rect2i(466, 811, 43, 32), out_dir + "cat_sleep_cream.png")
	_save(img, Rect2i(419, 856, 43, 32), out_dir + "cat_sleep_white.png")
	_save(img, Rect2i(466, 856, 43, 32), out_dir + "cat_sleep_orange.png")
	
	# 6. Cat Paw Icons & Buttons (x=325..512, y=150..190)
	_save(img, Rect2i(334, 153, 36, 32), out_dir + "icon_paw_lg_1.png")
	_save(img, Rect2i(384, 153, 36, 32), out_dir + "icon_paw_lg_2.png")
	_save(img, Rect2i(433, 153, 36, 32), out_dir + "icon_paw_lg_3.png")
	_save(img, Rect2i(483, 153, 36, 32), out_dir + "icon_paw_lg_4.png")
	
	# 7. Directional Arrow Badges (48x24)
	_save(img, Rect2i(272, 708, 48, 24), out_dir + "btn_arrow_right_grey.png")
	_save(img, Rect2i(336, 708, 48, 24), out_dir + "btn_arrow_right_cream.png")
	_save(img, Rect2i(400, 708, 48, 24), out_dir + "btn_arrow_right_pink.png")
	_save(img, Rect2i(272, 740, 48, 24), out_dir + "btn_arrow_right_brown.png")
	
	# 8. Pill Buttons (around x=0..230, y=775..840)
	_save(img, Rect2i(0, 808, 46, 20), out_dir + "btn_pill_dark.png")
	_save(img, Rect2i(54, 808, 46, 20), out_dir + "btn_pill_pink.png")
	_save(img, Rect2i(126, 808, 46, 20), out_dir + "btn_pill_cream.png")
	_save(img, Rect2i(54, 840, 46, 20), out_dir + "btn_pill_peach.png")
	
	# 9. Small Icons: House, Pause, Sound, Gear, etc.
	_save(img, Rect2i(1, 488, 12, 12), out_dir + "icon_home.png")
	_save(img, Rect2i(14, 488, 12, 12), out_dir + "icon_sound.png")
	_save(img, Rect2i(27, 488, 12, 12), out_dir + "icon_sound_off.png")
	_save(img, Rect2i(40, 488, 12, 12), out_dir + "icon_pause.png")
	_save(img, Rect2i(14, 504, 12, 12), out_dir + "icon_gear.png")
	_save(img, Rect2i(64, 472, 12, 12), out_dir + "icon_check.png")
	_save(img, Rect2i(77, 472, 12, 12), out_dir + "icon_cross.png")
	_save(img, Rect2i(39, 472, 12, 12), out_dir + "icon_heart.png")
	_save(img, Rect2i(52, 472, 12, 12), out_dir + "icon_star.png")
	_save(img, Rect2i(27, 472, 12, 12), out_dir + "icon_coin.png")
	_save(img, Rect2i(465, 204, 30, 15), out_dir + "icon_fishbone_blue.png")
	
	# 10. Slider Track & Knob
	_save(img, Rect2i(448, 475, 60, 16), out_dir + "slider_track_brown.png")
	_save(img, Rect2i(448, 490, 60, 16), out_dir + "slider_track_blue.png")
	_save(img, Rect2i(448, 540, 60, 16), out_dir + "slider_track_pink.png")
	_save(img, Rect2i(450, 475, 14, 14), out_dir + "slider_knob_wood.png")
	
	# 11. Rounded 9-patch frame (28x28)
	_save(img, Rect2i(0, 270, 28, 28), out_dir + "frame_rounded_cream.png")
	_save(img, Rect2i(30, 270, 28, 28), out_dir + "frame_rounded_sand.png")
	_save(img, Rect2i(0, 375, 28, 28), out_dir + "frame_rounded_dark.png")
	_save(img, Rect2i(130, 375, 28, 28), out_dir + "frame_rounded_pink.png")
	
	print("ALL PERFECT CAT UI ASSETS SLICED!")
	quit(0)

func _save(src: Image, rect: Rect2i, path: String) -> void:
	var sub = src.get_region(rect)
	sub.save_png(path)
	print("  Saved: %s (%dx%d)" % [path.get_file(), rect.size.x, rect.size.y])
