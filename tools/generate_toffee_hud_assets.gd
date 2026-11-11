extends SceneTree

func _init() -> void:
	print("--- GENERATING TOFFEECRAFT PIXEL ART HUD ASSETS (.png & .tres) ---")
	var out_dir = "assets/UI/CatUIPaid/slices/toffee_hud/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	
	var path_fish = "assets/cats/CatMegaBundle/CatMegaBundle/CatItems/CatToys/fish.png"
	var img_fish = Image.load_from_file(path_fish)
	
	# 1. HUD CONTAINER: 9-PATCH WOOD & PARCHMENT FRAME (48x48)
	var hud_frame = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	hud_frame.fill(Color("#FAF6EB"))
	var c_border_dark = Color("#321E0F")
	var c_wood_mid = Color("#6B4226")
	var c_wood_light = Color("#9C6942")
	var c_parchment_shadow = Color("#EBE2D0")
	var c_inner_groove = Color("#D6C8B2")
	
	for x in range(6, 42):
		hud_frame.set_pixel(x, 6, c_inner_groove)
		hud_frame.set_pixel(x, 7, c_parchment_shadow)
	for y in range(6, 42):
		hud_frame.set_pixel(6, y, c_inner_groove)
		hud_frame.set_pixel(7, y, c_parchment_shadow)
		
	for x in range(48):
		for y in range(4): hud_frame.set_pixel(x, y, c_wood_mid)
		for y in range(44, 48): hud_frame.set_pixel(x, y, c_wood_mid)
	for y in range(48):
		for x in range(4): hud_frame.set_pixel(x, y, c_wood_mid)
		for x in range(44, 48): hud_frame.set_pixel(x, y, c_wood_mid)
			
	for x in range(48):
		hud_frame.set_pixel(x, 0, c_border_dark)
		hud_frame.set_pixel(x, 47, c_border_dark)
		hud_frame.set_pixel(x, 1, c_wood_light)
		hud_frame.set_pixel(x, 4, c_border_dark)
		hud_frame.set_pixel(x, 43, c_border_dark)
	for y in range(48):
		hud_frame.set_pixel(0, y, c_border_dark)
		hud_frame.set_pixel(47, y, c_border_dark)
		hud_frame.set_pixel(1, y, c_wood_light)
		hud_frame.set_pixel(4, y, c_border_dark)
		hud_frame.set_pixel(43, y, c_border_dark)
		
	hud_frame.set_pixel(0, 0, Color(0,0,0,0))
	hud_frame.set_pixel(47, 0, Color(0,0,0,0))
	hud_frame.set_pixel(0, 47, Color(0,0,0,0))
	hud_frame.set_pixel(47, 47, Color(0,0,0,0))
	hud_frame.set_pixel(1, 1, c_border_dark)
	hud_frame.set_pixel(46, 1, c_border_dark)
	hud_frame.set_pixel(1, 46, c_border_dark)
	hud_frame.set_pixel(46, 46, c_border_dark)
	for cp in [Vector2i(2,2), Vector2i(45,2), Vector2i(2,45), Vector2i(45,45)]:
		hud_frame.set_pixel(cp.x, cp.y, Color("#E2AC3E"))
	_save_both(hud_frame, out_dir + "hud_wood_parchment_9patch")

	# 2. AVATAR WALL PICTURE FRAME (36x36 9-Patch)
	var pic_frame = Image.create(36, 36, false, Image.FORMAT_RGBA8)
	pic_frame.fill(Color(0,0,0,0))
	var c_frame_wood = Color("#5E3920")
	var c_frame_hi = Color("#B87B4B")
	var c_frame_sh = Color("#2D170B")
	
	for x in range(36):
		for y in range(2, 6): pic_frame.set_pixel(x, y, c_frame_wood)
		for y in range(30, 35): pic_frame.set_pixel(x, y, c_frame_wood)
	for y in range(2, 35):
		for x in range(0, 5): pic_frame.set_pixel(x, y, c_frame_wood)
		for x in range(31, 36): pic_frame.set_pixel(x, y, c_frame_wood)
		
	pic_frame.set_pixel(16, 0, Color("#C49A32"))
	pic_frame.set_pixel(17, 0, Color("#EAC04E"))
	pic_frame.set_pixel(18, 0, Color("#EAC04E"))
	pic_frame.set_pixel(19, 0, Color("#C49A32"))
	pic_frame.set_pixel(15, 1, c_frame_sh)
	pic_frame.set_pixel(20, 1, c_frame_sh)
	pic_frame.set_pixel(16, 1, Color(0,0,0,0))
	pic_frame.set_pixel(17, 1, Color(0,0,0,0))
	pic_frame.set_pixel(18, 1, Color(0,0,0,0))
	pic_frame.set_pixel(19, 1, Color(0,0,0,0))
	
	for x in range(36):
		pic_frame.set_pixel(x, 2, c_frame_sh)
		pic_frame.set_pixel(x, 3, c_frame_hi)
		pic_frame.set_pixel(x, 6, c_frame_sh)
		pic_frame.set_pixel(x, 29, c_frame_sh)
		pic_frame.set_pixel(x, 34, c_frame_sh)
	for y in range(2, 35):
		pic_frame.set_pixel(0, y, c_frame_sh)
		pic_frame.set_pixel(1, y, c_frame_hi)
		pic_frame.set_pixel(5, y, c_frame_sh)
		pic_frame.set_pixel(30, y, c_frame_sh)
		pic_frame.set_pixel(35, y, c_frame_sh)
		
	pic_frame.set_pixel(0, 2, Color(0,0,0,0))
	pic_frame.set_pixel(35, 2, Color(0,0,0,0))
	pic_frame.set_pixel(0, 34, Color(0,0,0,0))
	pic_frame.set_pixel(35, 34, Color(0,0,0,0))
	_save_both(pic_frame, out_dir + "avatar_picture_frame_32x32")

	# 3. LEVEL RIBBON / BADGE (56x20 9-Patch)
	var ribbon = Image.create(56, 20, false, Image.FORMAT_RGBA8)
	ribbon.fill(Color(0,0,0,0))
	var c_rib_dark = Color("#7A1C12")
	var c_rib_mid = Color("#C63B2C")
	var c_rib_hi = Color("#E55A49")
	var c_gold_border = Color("#A06E18")
	var c_gold_bg = Color("#FDE79C")
	var c_gold_hi = Color("#FFF3C9")
	var c_gold_sh = Color("#DDB058")
	
	for y in range(3, 17):
		for x in range(10, 46): ribbon.set_pixel(x, y, c_gold_bg)
	for x in range(10, 46):
		ribbon.set_pixel(x, 2, c_gold_border)
		ribbon.set_pixel(x, 3, c_gold_hi)
		ribbon.set_pixel(x, 16, c_gold_sh)
		ribbon.set_pixel(x, 17, c_gold_border)
	for y in range(2, 18):
		ribbon.set_pixel(10, y, c_gold_border)
		ribbon.set_pixel(11, y, c_gold_hi)
		ribbon.set_pixel(44, y, c_gold_sh)
		ribbon.set_pixel(45, y, c_gold_border)
		
	for y in range(4, 16):
		for x in range(1, 10): ribbon.set_pixel(x, y, c_rib_mid)
		for x in range(46, 55): ribbon.set_pixel(x, y, c_rib_mid)
	for x in range(1, 10):
		ribbon.set_pixel(x, 4, c_rib_hi)
		ribbon.set_pixel(x, 15, c_rib_dark)
	for x in range(46, 55):
		ribbon.set_pixel(x, 4, c_rib_hi)
		ribbon.set_pixel(x, 15, c_rib_dark)
	for y in range(7, 13):
		ribbon.set_pixel(1, y, Color(0,0,0,0))
		ribbon.set_pixel(54, y, Color(0,0,0,0))
	ribbon.set_pixel(2, 9, Color(0,0,0,0))
	ribbon.set_pixel(2, 10, Color(0,0,0,0))
	ribbon.set_pixel(53, 9, Color(0,0,0,0))
	ribbon.set_pixel(53, 10, Color(0,0,0,0))
	
	var star_pixels = [
		Vector2i(15, 6),
		Vector2i(14, 7), Vector2i(15, 7), Vector2i(16, 7),
		Vector2i(13, 8), Vector2i(14, 8), Vector2i(15, 8), Vector2i(16, 8), Vector2i(17, 8),
		Vector2i(14, 9), Vector2i(15, 9), Vector2i(16, 9),
		Vector2i(14, 10), Vector2i(16, 10)
	]
	for sp in star_pixels: ribbon.set_pixel(sp.x, sp.y, Color("#A06410"))
	ribbon.set_pixel(15, 8, Color("#FFFAC8"))
	_save_both(ribbon, out_dir + "level_ribbon_badge")

	# 4. PROGRESS BARS
	var bar_under = Image.create(24, 12, false, Image.FORMAT_RGBA8)
	var c_track_bg = Color("#E6DDCE")
	var c_track_shadow = Color("#B8A994")
	var c_track_dark = Color("#452A18")
	bar_under.fill(c_track_bg)
	for x in range(24):
		bar_under.set_pixel(x, 0, c_track_dark)
		bar_under.set_pixel(x, 1, c_track_shadow)
		bar_under.set_pixel(x, 11, c_track_dark)
	for y in range(12):
		bar_under.set_pixel(0, y, c_track_dark)
		bar_under.set_pixel(1, y, c_track_shadow)
		bar_under.set_pixel(23, y, c_track_dark)
	_save_both(bar_under, out_dir + "bar_track_under")

	var bar_over = Image.create(24, 12, false, Image.FORMAT_RGBA8)
	bar_over.fill(Color(0,0,0,0))
	var c_frame_bevel = Color("#9C6840")
	var c_frame_top_hi = Color("#DDB686")
	for x in range(24):
		bar_over.set_pixel(x, 0, c_track_dark)
		bar_over.set_pixel(x, 1, c_frame_top_hi)
		bar_over.set_pixel(x, 10, c_frame_bevel)
		bar_over.set_pixel(x, 11, c_track_dark)
	for y in range(12):
		bar_over.set_pixel(0, y, c_track_dark)
		bar_over.set_pixel(1, y, c_frame_top_hi)
		bar_over.set_pixel(22, y, c_frame_bevel)
		bar_over.set_pixel(23, y, c_track_dark)
	bar_over.set_pixel(0, 0, Color(0,0,0,0))
	bar_over.set_pixel(23, 0, Color(0,0,0,0))
	bar_over.set_pixel(0, 11, Color(0,0,0,0))
	bar_over.set_pixel(23, 11, Color(0,0,0,0))
	_save_both(bar_over, out_dir + "bar_frame_over")

	var bar_hunger = Image.create(16, 10, false, Image.FORMAT_RGBA8)
	var c_red_hi = Color("#F8846E")
	var c_red_mid = Color("#E04634")
	var c_red_sh = Color("#A82416")
	bar_hunger.fill(c_red_mid)
	for x in range(16):
		bar_hunger.set_pixel(x, 0, c_red_hi)
		bar_hunger.set_pixel(x, 1, c_red_hi)
		bar_hunger.set_pixel(x, 8, c_red_sh)
		bar_hunger.set_pixel(x, 9, c_red_sh)
	_save_both(bar_hunger, out_dir + "bar_progress_hunger")

	var bar_courage = Image.create(16, 10, false, Image.FORMAT_RGBA8)
	var c_cyan_hi = Color("#78DCF2")
	var c_cyan_mid = Color("#32A2BE")
	var c_cyan_sh = Color("#165E74")
	bar_courage.fill(c_cyan_mid)
	for x in range(16):
		bar_courage.set_pixel(x, 0, c_cyan_hi)
		bar_courage.set_pixel(x, 1, c_cyan_hi)
		bar_courage.set_pixel(x, 8, c_cyan_sh)
		bar_courage.set_pixel(x, 9, c_cyan_sh)
	_save_both(bar_courage, out_dir + "bar_progress_courage")

	# 5. CRISP PIXEL 16x16 ICONS: BOWL & HEART
	var bowl_16 = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	bowl_16.fill(Color(0,0,0,0))
	var c_bowl_out = Color("#3B2213")
	var c_bowl_body = Color("#E27542")
	var c_bowl_hi = Color("#F89A6A")
	var c_bowl_sh = Color("#B34C20")
	var c_food_dark = Color("#6A3D18")
	var c_food_mid = Color("#9A602C")
	var c_food_hi = Color("#C48548")
	
	for x in range(5, 11): bowl_16.set_pixel(x, 3, c_food_mid)
	for x in range(4, 12): bowl_16.set_pixel(x, 4, c_food_hi)
	for x in range(3, 13): bowl_16.set_pixel(x, 5, c_food_mid)
	for x in range(3, 13): bowl_16.set_pixel(x, 6, c_food_dark)
	bowl_16.set_pixel(5, 2, c_bowl_out)
	bowl_16.set_pixel(6, 2, c_bowl_out)
	bowl_16.set_pixel(9, 2, c_bowl_out)
	bowl_16.set_pixel(10, 2, c_bowl_out)
	bowl_16.set_pixel(4, 3, c_bowl_out)
	bowl_16.set_pixel(11, 3, c_bowl_out)
	
	for y in range(7, 13):
		var x_start = 2 + (y - 7) / 2
		var x_end = 13 - (y - 7) / 2
		for x in range(x_start, x_end + 1): bowl_16.set_pixel(x, y, c_bowl_body)
		bowl_16.set_pixel(x_start, y, c_bowl_out)
		bowl_16.set_pixel(x_end, y, c_bowl_out)
	for x in range(3, 13): bowl_16.set_pixel(x, 7, c_bowl_hi)
	for y in range(8, 12):
		bowl_16.set_pixel(3 + (y-8)/2, y, c_bowl_hi)
		bowl_16.set_pixel(12 - (y-8)/2, y, c_bowl_sh)
	for x in range(4, 12): bowl_16.set_pixel(x, 13, c_bowl_out)
	bowl_16.set_pixel(7, 10, Color("#F8D888"))
	bowl_16.set_pixel(8, 10, Color("#F8D888"))
	bowl_16.set_pixel(9, 9, Color("#D8B050"))
	bowl_16.set_pixel(9, 11, Color("#D8B050"))
	_save_both(bowl_16, out_dir + "icon_food_bowl_16x16")

	# Heart
	var heart_16 = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	heart_16.fill(Color(0,0,0,0))
	var c_h_out = Color("#112D3A")
	var c_h_body = Color("#32A8C8")
	var c_h_hi = Color("#74E0F8")
	var c_h_sh = Color("#1A6680")
	var c_h_glint = Color("#FFFFFF")
	
	for y in range(2, 14):
		var span = []
		if y == 2: span = [Vector2i(3,5), Vector2i(10,12)]
		elif y == 3: span = [Vector2i(2,6), Vector2i(9,13)]
		elif y == 4: span = [Vector2i(1,14)]
		elif y == 5: span = [Vector2i(1,14)]
		elif y == 6: span = [Vector2i(2,13)]
		elif y == 7: span = [Vector2i(3,12)]
		elif y == 8: span = [Vector2i(4,11)]
		elif y == 9: span = [Vector2i(5,10)]
		elif y == 10: span = [Vector2i(6,9)]
		elif y == 11: span = [Vector2i(7,8)]
		elif y == 12: span = [Vector2i(7,8)]
		elif y == 13: span = [Vector2i(7,8)]
		for sp in span:
			for x in range(sp.x, sp.y + 1): heart_16.set_pixel(x, y, c_h_body)
				
	for y in range(6, 13):
		for x in range(8, 14):
			if heart_16.get_pixel(x, y).a > 0: heart_16.set_pixel(x, y, c_h_sh)
	for y in range(3, 7):
		for x in range(2, 6):
			if heart_16.get_pixel(x, y).a > 0: heart_16.set_pixel(x, y, c_h_hi)
	heart_16.set_pixel(4, 3, c_h_glint)
	heart_16.set_pixel(3, 4, c_h_glint)
	
	var heart_outline = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	heart_outline.fill(Color(0,0,0,0))
	for y in range(16):
		for x in range(16):
			if heart_16.get_pixel(x, y).a > 0.5:
				heart_outline.set_pixel(x, y, heart_16.get_pixel(x, y))
			else:
				var is_nbr = false
				for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
					var nx = x + d.x
					var ny = y + d.y
					if nx >= 0 and nx < 16 and ny >= 0 and ny < 16:
						if heart_16.get_pixel(nx, ny).a > 0.5:
							is_nbr = true
							break
				if is_nbr: heart_outline.set_pixel(x, y, c_h_out)
	_save_both(heart_outline, out_dir + "icon_heart_16x16")

	# 6. PARCHMENT SCROLL PANEL, GOLD FISH, RED DEBT ICON
	var scroll_panel = Image.create(32, 22, false, Image.FORMAT_RGBA8)
	scroll_panel.fill(Color(0,0,0,0))
	var c_sc_paper = Color("#FAF3DC")
	var c_sc_roll = Color("#DEC698")
	var c_sc_hi = Color("#FFF9ED")
	var c_sc_out = Color("#4A2E16")
	var c_sc_crease = Color("#C4A878")
	
	for y in range(2, 20):
		for x in range(3, 29): scroll_panel.set_pixel(x, y, c_sc_paper)
	for x in range(3, 29):
		scroll_panel.set_pixel(x, 1, c_sc_out)
		scroll_panel.set_pixel(x, 2, c_sc_hi)
		scroll_panel.set_pixel(x, 19, c_sc_crease)
		scroll_panel.set_pixel(x, 20, c_sc_out)
		
	for y in range(0, 22):
		scroll_panel.set_pixel(1, y, c_sc_roll)
		scroll_panel.set_pixel(2, y, c_sc_paper)
		scroll_panel.set_pixel(29, y, c_sc_paper)
		scroll_panel.set_pixel(30, y, c_sc_roll)
		scroll_panel.set_pixel(0, y, c_sc_out)
		scroll_panel.set_pixel(31, y, c_sc_out)
	scroll_panel.set_pixel(1, 0, c_sc_out)
	scroll_panel.set_pixel(2, 0, c_sc_out)
	scroll_panel.set_pixel(29, 0, c_sc_out)
	scroll_panel.set_pixel(30, 0, c_sc_out)
	scroll_panel.set_pixel(1, 21, c_sc_out)
	scroll_panel.set_pixel(2, 21, c_sc_out)
	scroll_panel.set_pixel(29, 21, c_sc_out)
	scroll_panel.set_pixel(30, 21, c_sc_out)
	_save_both(scroll_panel, out_dir + "scroll_panel_coin_9patch")

	# Gold fish
	var gold_fish = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	gold_fish.fill(Color(0,0,0,0))
	if img_fish:
		gold_fish.blit_rect(img_fish, Rect2i(16, 16, 16, 16), Vector2i(0, 0))
	_save_both(gold_fish, out_dir + "icon_fish_gold_16x16")

	# Red debt bill
	var debt_icon = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	debt_icon.fill(Color(0,0,0,0))
	var c_d_out = Color("#4D1212")
	var c_d_paper = Color("#FFEBEB")
	var c_d_red = Color("#D92828")
	var c_d_red_hi = Color("#FF5858")
	var c_d_text = Color("#8A2020")
	
	for y in range(2, 14):
		for x in range(3, 13): debt_icon.set_pixel(x, y, c_d_paper)
	for x in range(3, 13):
		debt_icon.set_pixel(x, 1, c_d_out)
		debt_icon.set_pixel(x, 14, c_d_out)
	for y in range(1, 15):
		debt_icon.set_pixel(2, y, c_d_out)
		debt_icon.set_pixel(13, y, c_d_out)
		
	debt_icon.set_pixel(12, 1, Color(0,0,0,0))
	debt_icon.set_pixel(13, 1, Color(0,0,0,0))
	debt_icon.set_pixel(13, 2, Color(0,0,0,0))
	debt_icon.set_pixel(11, 2, c_d_out)
	debt_icon.set_pixel(12, 3, c_d_out)
	
	for x in range(4, 9): debt_icon.set_pixel(x, 4, c_d_text)
	for x in range(4, 11): debt_icon.set_pixel(x, 6, c_d_text)
	for x in range(4, 8): debt_icon.set_pixel(x, 8, c_d_text)
	
	for y in range(10, 13):
		for x in range(9, 12): debt_icon.set_pixel(x, y, c_d_red)
	debt_icon.set_pixel(10, 9, c_d_red_hi)
	debt_icon.set_pixel(10, 13, c_d_out)
	debt_icon.set_pixel(8, 11, c_d_out)
	debt_icon.set_pixel(12, 11, c_d_out)
	debt_icon.set_pixel(10, 10, Color("#FFFFFF"))
	debt_icon.set_pixel(10, 12, Color("#FFFFFF"))
	_save_both(debt_icon, out_dir + "icon_debt_bill_16x16")

	# 7. PIXEL BUTTONS: PAUSE & SHOP
	var btn_pause_norm = Image.create(26, 26, false, Image.FORMAT_RGBA8)
	var btn_pause_press = Image.create(26, 26, false, Image.FORMAT_RGBA8)
	var c_btn_bg = Color("#FAF3E6")
	var c_btn_hi = Color("#FFFBF2")
	var c_btn_mid = Color("#E6D4BE")
	var c_btn_sh = Color("#A88A6E")
	var c_btn_out = Color("#472E1E")
	var c_btn_symbol = Color("#472E1E")
	
	btn_pause_norm.fill(c_btn_bg)
	btn_pause_press.fill(c_btn_mid)
	for x in range(26):
		btn_pause_norm.set_pixel(x, 0, c_btn_out)
		btn_pause_norm.set_pixel(x, 1, c_btn_hi)
		btn_pause_norm.set_pixel(x, 24, c_btn_sh)
		btn_pause_norm.set_pixel(x, 25, c_btn_out)
	for y in range(26):
		btn_pause_norm.set_pixel(0, y, c_btn_out)
		btn_pause_norm.set_pixel(1, y, c_btn_hi)
		btn_pause_norm.set_pixel(24, y, c_btn_sh)
		btn_pause_norm.set_pixel(25, y, c_btn_out)
		
	for x in range(26):
		btn_pause_press.set_pixel(x, 0, c_btn_out)
		btn_pause_press.set_pixel(x, 1, c_btn_sh)
		btn_pause_press.set_pixel(x, 25, c_btn_out)
	for y in range(26):
		btn_pause_press.set_pixel(0, y, c_btn_out)
		btn_pause_press.set_pixel(1, y, c_btn_sh)
		btn_pause_press.set_pixel(25, y, c_btn_out)
		
	for img in [btn_pause_norm, btn_pause_press]:
		img.set_pixel(0, 0, Color(0,0,0,0))
		img.set_pixel(25, 0, Color(0,0,0,0))
		img.set_pixel(0, 25, Color(0,0,0,0))
		img.set_pixel(25, 25, Color(0,0,0,0))
		
	for y in range(7, 18):
		for x in range(8, 11): btn_pause_norm.set_pixel(x, y, c_btn_symbol)
		for x in range(15, 18): btn_pause_norm.set_pixel(x, y, c_btn_symbol)
	for y in range(8, 19):
		for x in range(8, 11): btn_pause_press.set_pixel(x, y, c_btn_symbol)
		for x in range(15, 18): btn_pause_press.set_pixel(x, y, c_btn_symbol)
	_save_both(btn_pause_norm, out_dir + "btn_pause_normal")
	_save_both(btn_pause_press, out_dir + "btn_pause_pressed")

	# Shop Button (28x28)
	var btn_shop_norm = Image.create(28, 28, false, Image.FORMAT_RGBA8)
	var btn_shop_press = Image.create(28, 28, false, Image.FORMAT_RGBA8)
	var c_shop_accent = Color("#E87A38")
	var c_shop_awning = Color("#F8A458")
	
	btn_shop_norm.fill(c_btn_bg)
	btn_shop_press.fill(c_btn_mid)
	for x in range(28):
		btn_shop_norm.set_pixel(x, 0, c_btn_out)
		btn_shop_norm.set_pixel(x, 1, c_btn_hi)
		btn_shop_norm.set_pixel(x, 26, c_btn_sh)
		btn_shop_norm.set_pixel(x, 27, c_btn_out)
	for y in range(28):
		btn_shop_norm.set_pixel(0, y, c_btn_out)
		btn_shop_norm.set_pixel(1, y, c_btn_hi)
		btn_shop_norm.set_pixel(26, y, c_btn_sh)
		btn_shop_norm.set_pixel(27, y, c_btn_out)
		
	for x in range(28):
		btn_shop_press.set_pixel(x, 0, c_btn_out)
		btn_shop_press.set_pixel(x, 1, c_btn_sh)
		btn_shop_press.set_pixel(x, 27, c_btn_out)
	for y in range(28):
		btn_shop_press.set_pixel(0, y, c_btn_out)
		btn_shop_press.set_pixel(1, y, c_btn_sh)
		btn_shop_press.set_pixel(27, y, c_btn_out)
		
	for img in [btn_shop_norm, btn_shop_press]:
		img.set_pixel(0, 0, Color(0,0,0,0))
		img.set_pixel(27, 0, Color(0,0,0,0))
		img.set_pixel(0, 27, Color(0,0,0,0))
		img.set_pixel(27, 27, Color(0,0,0,0))
		
	var _draw_shop_icon = func(target: Image, offset_y: int):
		for x in range(6, 22):
			target.set_pixel(x, 6 + offset_y, c_btn_out)
			var is_stripe = (x / 2) % 2 == 0
			target.set_pixel(x, 7 + offset_y, c_shop_accent if is_stripe else c_shop_awning)
			target.set_pixel(x, 8 + offset_y, c_shop_accent if is_stripe else c_shop_awning)
			target.set_pixel(x, 9 + offset_y, c_shop_accent if is_stripe else c_shop_awning)
			target.set_pixel(x, 10 + offset_y, c_btn_out)
		for x in range(6, 22, 2):
			target.set_pixel(x, 11 + offset_y, c_shop_accent)
			target.set_pixel(x + 1, 11 + offset_y, c_btn_out)
		for y in range(12, 19):
			target.set_pixel(7, y + offset_y, c_btn_out)
			target.set_pixel(20, y + offset_y, c_btn_out)
			for x in range(8, 20): target.set_pixel(x, y + offset_y, Color("#DFCBAC"))
		for x in range(7, 21):
			target.set_pixel(x, 15 + offset_y, c_btn_out)
			target.set_pixel(x, 16 + offset_y, Color("#A06E38"))
		for x in range(7, 21): target.set_pixel(x, 19 + offset_y, c_btn_out)
			
	_draw_shop_icon.call(btn_shop_norm, 0)
	_draw_shop_icon.call(btn_shop_press, 1)
	_save_both(btn_shop_norm, out_dir + "btn_shop_normal")
	_save_both(btn_shop_press, out_dir + "btn_shop_pressed")
	
	print("ALL ASSETS SAVED BOTH AS .PNG AND .TRES!")
	quit()

func _save_both(img: Image, base_path: String) -> void:
	img.save_png(base_path + ".png")
	var tex = ImageTexture.create_from_image(img)
	ResourceSaver.save(tex, "res://" + base_path + ".tres")
	print("  Saved: %s (.png & .tres)" % base_path.get_file())
