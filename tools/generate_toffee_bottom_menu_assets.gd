extends SceneTree

func _init() -> void:
	print("--- GENERATING TOFFEECRAFT BOTTOM PAW MENU PIXEL ART ASSETS (.png & .tres) ---")
	var out_dir = "assets/UI/CatUIPaid/slices/toffee_bottom_menu/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out_dir))
	
	# =========================================================================
	# 1. DOCK PANEL: RUSTIC WOODEN SHELF (48x48 9-Patch)
	# =========================================================================
	var dock_shelf = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	dock_shelf.fill(Color("#5A361F")) # Rich wood base
	
	var c_timber_dark = Color("#221208")
	var c_wood_hi = Color("#A87246")
	var c_wood_mid = Color("#6B4226")
	var c_wood_low = Color("#452614")
	var c_plank_groove = Color("#30180B")
	var c_gold_rivet = Color("#E6B13C")
	var c_gold_rivet_sh = Color("#8A5C14")
	
	# Wood grain & plank grooves
	for y in range(48):
		for x in range(48):
			if y in [14, 15, 30, 31]:
				dock_shelf.set_pixel(x, y, c_plank_groove)
			elif y in [16, 32]:
				dock_shelf.set_pixel(x, y, c_wood_hi)
			elif (x + y * 2) % 17 == 0:
				dock_shelf.set_pixel(x, y, c_wood_low)
			elif (x * 3 + y) % 23 == 0:
				dock_shelf.set_pixel(x, y, c_wood_hi)
				
	# Top and Bottom thick shelf trim
	for x in range(48):
		dock_shelf.set_pixel(x, 0, c_timber_dark)
		dock_shelf.set_pixel(x, 1, c_wood_hi)
		dock_shelf.set_pixel(x, 2, c_wood_hi)
		dock_shelf.set_pixel(x, 3, c_timber_dark)
		dock_shelf.set_pixel(x, 46, c_timber_dark)
		dock_shelf.set_pixel(x, 47, c_timber_dark)
	for y in range(48):
		dock_shelf.set_pixel(0, y, c_timber_dark)
		dock_shelf.set_pixel(1, y, c_wood_hi)
		dock_shelf.set_pixel(46, y, c_wood_low)
		dock_shelf.set_pixel(47, y, c_timber_dark)
		
	# Corner brass rivets
	for pt in [Vector2i(4, 5), Vector2i(43, 5), Vector2i(4, 42), Vector2i(43, 42)]:
		dock_shelf.set_pixel(pt.x, pt.y, c_gold_rivet)
		dock_shelf.set_pixel(pt.x + 1, pt.y, c_gold_rivet)
		dock_shelf.set_pixel(pt.x, pt.y + 1, c_gold_rivet_sh)
		dock_shelf.set_pixel(pt.x + 1, pt.y + 1, c_gold_rivet_sh)
		
	_save_both(dock_shelf, out_dir + "dock_wood_shelf_9patch")

	# =========================================================================
	# 2. SUBDRAWER: RETRO WOODEN DRAWER CABINET (48x48 9-Patch)
	# =========================================================================
	var drawer = Image.create(48, 48, false, Image.FORMAT_RGBA8)
	drawer.fill(Color("#FAF5EA")) # Warm parchment/felt interior
	
	# Inner velvet shadow
	for x in range(6, 42):
		drawer.set_pixel(x, 6, Color("#D9CCA8"))
		drawer.set_pixel(x, 7, Color("#EAE0C8"))
	for y in range(6, 42):
		drawer.set_pixel(6, y, Color("#D9CCA8"))
		drawer.set_pixel(7, y, Color("#EAE0C8"))
		
	# Outer polished walnut cabinet border
	for x in range(48):
		for y in range(4): drawer.set_pixel(x, y, c_wood_mid)
		for y in range(44, 48): drawer.set_pixel(x, y, c_wood_mid)
	for y in range(48):
		for x in range(4): drawer.set_pixel(x, y, c_wood_mid)
		for x in range(44, 48): drawer.set_pixel(x, y, c_wood_mid)
		
	for x in range(48):
		drawer.set_pixel(x, 0, c_timber_dark)
		drawer.set_pixel(x, 1, c_wood_hi)
		drawer.set_pixel(x, 4, c_timber_dark)
		drawer.set_pixel(x, 43, c_timber_dark)
		drawer.set_pixel(x, 47, c_timber_dark)
	for y in range(48):
		drawer.set_pixel(0, y, c_timber_dark)
		drawer.set_pixel(1, y, c_wood_hi)
		drawer.set_pixel(4, y, c_timber_dark)
		drawer.set_pixel(43, y, c_timber_dark)
		drawer.set_pixel(47, y, c_timber_dark)
		
	# Brass drawer handle in top middle (for decorative retro drawer look)
	for x in range(20, 28):
		drawer.set_pixel(x, 2, c_gold_rivet)
		drawer.set_pixel(x, 3, c_gold_rivet_sh)
		
	# Rounded transparent corners
	drawer.set_pixel(0, 0, Color(0,0,0,0))
	drawer.set_pixel(47, 0, Color(0,0,0,0))
	drawer.set_pixel(0, 47, Color(0,0,0,0))
	drawer.set_pixel(47, 47, Color(0,0,0,0))
	drawer.set_pixel(1, 1, c_timber_dark)
	drawer.set_pixel(46, 1, c_timber_dark)
	drawer.set_pixel(1, 46, c_timber_dark)
	drawer.set_pixel(46, 46, c_timber_dark)
	_save_both(drawer, out_dir + "subdrawer_retro_wood_9patch")

	# =========================================================================
	# 3. ITEM SLOT: 32x32 INSET RECESSED SLOT (9-Patch)
	# =========================================================================
	var slot = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	slot.fill(Color("#F2E8D5")) # Warm inset parchment pocket
	
	# Recessed drop shadow on top & left
	for x in range(3, 29):
		slot.set_pixel(x, 3, Color("#BFB094"))
		slot.set_pixel(x, 4, Color("#D9CCB4"))
	for y in range(3, 29):
		slot.set_pixel(3, y, Color("#BFB094"))
		slot.set_pixel(4, y, Color("#D9CCB4"))
		
	# Inset frame border
	for x in range(32):
		for y in range(3): slot.set_pixel(x, y, c_wood_mid)
		for y in range(29, 32): slot.set_pixel(x, y, c_wood_mid)
	for y in range(32):
		for x in range(3): slot.set_pixel(x, y, c_wood_mid)
		for x in range(29, 32): slot.set_pixel(x, y, c_wood_mid)
		
	for x in range(32):
		slot.set_pixel(x, 0, c_timber_dark)
		slot.set_pixel(x, 1, c_wood_hi)
		slot.set_pixel(x, 2, c_timber_dark)
		slot.set_pixel(x, 31, c_timber_dark)
	for y in range(32):
		slot.set_pixel(0, y, c_timber_dark)
		slot.set_pixel(1, y, c_wood_hi)
		slot.set_pixel(2, y, c_timber_dark)
		slot.set_pixel(31, y, c_timber_dark)
		
	# Corner rivets
	for cp in [Vector2i(1,1), Vector2i(30,1), Vector2i(1,30), Vector2i(30,30)]:
		slot.set_pixel(cp.x, cp.y, c_gold_rivet)
		
	slot.set_pixel(0, 0, Color(0,0,0,0))
	slot.set_pixel(31, 0, Color(0,0,0,0))
	slot.set_pixel(0, 31, Color(0,0,0,0))
	slot.set_pixel(31, 31, Color(0,0,0,0))
	_save_both(slot, out_dir + "item_slot_32x32_9patch")

	# =========================================================================
	# 4. BUTTON BASE: NORMAL & PRESSED DOCK BUTTON (36x36 9-Patch)
	# =========================================================================
	var btn_norm = Image.create(36, 36, false, Image.FORMAT_RGBA8)
	btn_norm.fill(Color("#7A4D2E")) # Warm wood button face
	var btn_press = Image.create(36, 36, false, Image.FORMAT_RGBA8)
	btn_press.fill(Color("#54321A")) # Dark sunken wood face
	
	for x in range(36):
		btn_norm.set_pixel(x, 0, c_timber_dark)
		btn_norm.set_pixel(x, 1, c_wood_hi)
		btn_norm.set_pixel(x, 2, c_wood_hi)
		btn_norm.set_pixel(x, 34, c_timber_dark)
		btn_norm.set_pixel(x, 35, c_timber_dark)
		
		btn_press.set_pixel(x, 0, c_timber_dark)
		btn_press.set_pixel(x, 1, c_timber_dark)
		btn_press.set_pixel(x, 2, Color("#3A2010"))
		btn_press.set_pixel(x, 35, c_timber_dark)
	for y in range(36):
		btn_norm.set_pixel(0, y, c_timber_dark)
		btn_norm.set_pixel(1, y, c_wood_hi)
		btn_norm.set_pixel(34, y, c_wood_low)
		btn_norm.set_pixel(35, y, c_timber_dark)
		
		btn_press.set_pixel(0, y, c_timber_dark)
		btn_press.set_pixel(1, y, Color("#3A2010"))
		btn_press.set_pixel(34, y, c_wood_hi)
		btn_press.set_pixel(35, y, c_timber_dark)
		
	btn_norm.set_pixel(0, 0, Color(0,0,0,0))
	btn_norm.set_pixel(35, 0, Color(0,0,0,0))
	btn_norm.set_pixel(0, 35, Color(0,0,0,0))
	btn_norm.set_pixel(35, 35, Color(0,0,0,0))
	btn_press.set_pixel(0, 0, Color(0,0,0,0))
	btn_press.set_pixel(35, 0, Color(0,0,0,0))
	btn_press.set_pixel(0, 35, Color(0,0,0,0))
	btn_press.set_pixel(35, 35, Color(0,0,0,0))
	_save_both(btn_norm, out_dir + "btn_dock_normal")
	_save_both(btn_press, out_dir + "btn_dock_pressed")

	# =========================================================================
	# 5. PAW INDICATOR: PIXEL FOOTPRINT (14x12)
	# =========================================================================
	var paw = Image.create(14, 12, false, Image.FORMAT_RGBA8)
	paw.fill(Color(0,0,0,0))
	var c_paw_gold = Color("#FFDA66")
	var c_paw_mid = Color("#F0B830")
	var c_paw_dark = Color("#4D260C")
	
	# Main heel pad (center bottom: x=4..9, y=6..10)
	var heel_map = [
		"  xxxx  ",
		" xxxxxx ",
		"xxxxxxxx",
		"xxxxxxxx",
		" xxxxxx "
	]
	for row in range(heel_map.size()):
		var line = heel_map[row]
		for col in range(line.length()):
			if line[col] == 'x':
				var px = 3 + col
				var py = 6 + row
				paw.set_pixel(px, py, c_paw_gold)
				
	# 4 Toe Beans
	# Toe 1 (far left)
	paw.set_pixel(2, 3, c_paw_gold); paw.set_pixel(3, 3, c_paw_gold)
	paw.set_pixel(2, 4, c_paw_gold); paw.set_pixel(3, 4, c_paw_mid)
	# Toe 2 (center left)
	paw.set_pixel(5, 1, c_paw_gold); paw.set_pixel(6, 1, c_paw_gold)
	paw.set_pixel(5, 2, c_paw_gold); paw.set_pixel(6, 2, c_paw_mid)
	# Toe 3 (center right)
	paw.set_pixel(8, 1, c_paw_gold); paw.set_pixel(9, 1, c_paw_gold)
	paw.set_pixel(8, 2, c_paw_gold); paw.set_pixel(9, 2, c_paw_mid)
	# Toe 4 (far right)
	paw.set_pixel(11, 3, c_paw_gold); paw.set_pixel(12, 3, c_paw_gold)
	paw.set_pixel(11, 4, c_paw_gold); paw.set_pixel(12, 4, c_paw_mid)
	
	# Draw outline around paw pixels
	var paw_outline = paw.duplicate()
	for y in range(12):
		for x in range(14):
			if paw.get_pixel(x, y).a > 0.1:
				for dy in [-1, 0, 1]:
					for dx in [-1, 0, 1]:
						var nx = x + dx
						var ny = y + dy
						if nx >= 0 and nx < 14 and ny >= 0 and ny < 12:
							if paw.get_pixel(nx, ny).a == 0:
								paw_outline.set_pixel(nx, ny, c_paw_dark)
	for y in range(12):
		for x in range(14):
			if paw.get_pixel(x, y).a > 0.1:
				paw_outline.set_pixel(x, y, paw.get_pixel(x, y))
	_save_both(paw_outline, out_dir + "paw_indicator_selected")

	# =========================================================================
	# 6. 5 NAVIGATION ICONS (24x24 Pixel Art)
	# =========================================================================
	
	# --- ICON 1: NHÀ GỖ (Cozy Wooden Cottage) ---
	var ic_home = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	ic_home.fill(Color(0,0,0,0))
	var c_roof = Color("#C44E32")
	var c_roof_hi = Color("#E87558")
	var c_wall = Color("#A86A3E")
	var c_wall_sh = Color("#784522")
	var c_door = Color("#2C150A")
	var c_light = Color("#FFE875")
	var c_out = Color("#281308")
	
	# Pitched roof (triangle)
	for r in range(8):
		var w = r * 2 + 2
		var start_x = 11 - r
		for x in range(start_x, start_x + w):
			ic_home.set_pixel(x, 3 + r, c_roof)
		ic_home.set_pixel(start_x, 3 + r, c_roof_hi)
		ic_home.set_pixel(start_x + w - 1, 3 + r, c_out)
	for x in range(3, 21): ic_home.set_pixel(x, 11, c_out) # Eaves
	
	# Chimney on right
	for y in range(3, 8):
		ic_home.set_pixel(17, y, Color("#695B55"))
		ic_home.set_pixel(18, y, Color("#8A7A72"))
		ic_home.set_pixel(19, y, c_out)
		
	# Cottage walls
	for y in range(12, 22):
		for x in range(5, 19):
			ic_home.set_pixel(x, y, c_wall)
		ic_home.set_pixel(5, y, c_out)
		ic_home.set_pixel(18, y, c_out)
	for x in range(5, 19): ic_home.set_pixel(x, 21, c_out)
	
	# Arched door with warm light
	for y in range(15, 21):
		for x in range(10, 14):
			ic_home.set_pixel(x, y, c_light if y < 19 else c_door)
		ic_home.set_pixel(9, y, c_out)
		ic_home.set_pixel(14, y, c_out)
	for x in range(10, 14): ic_home.set_pixel(x, 14, c_out)
	_save_both(ic_home, out_dir + "icon_nav_home_24x24")

	# --- ICON 2: BÁT CÁ (Cat Fish Bowl with Whole Fish) ---
	var ic_food = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	ic_food.fill(Color(0,0,0,0))
	var c_bowl = Color("#4EA8DE")
	var c_bowl_hi = Color("#82CBFA")
	var c_bowl_sh = Color("#226294")
	var c_fish_body = Color("#48A9A6")
	var c_fish_belly = Color("#F4F4F6")
	var c_fish_orange = Color("#F38D3A")
	
	# Ceramic bowl base (y=12..21)
	for y in range(13, 21):
		var inset = (y - 13) / 2
		for x in range(4 + inset, 20 - inset):
			ic_food.set_pixel(x, y, c_bowl)
		ic_food.set_pixel(4 + inset, y, c_out)
		ic_food.set_pixel(19 - inset, y, c_out)
	for x in range(5, 19): ic_food.set_pixel(x, 13, c_bowl_hi)
	for x in range(7, 17): ic_food.set_pixel(x, 20, c_out)
	
	# Fish lying in bowl (tilted mackerel)
	for x in range(6, 17):
		ic_food.set_pixel(x, 11, c_fish_body)
		ic_food.set_pixel(x, 12, c_fish_belly)
	# Tail fin sticking out left
	ic_food.set_pixel(4, 9, c_fish_orange)
	ic_food.set_pixel(5, 10, c_fish_orange)
	ic_food.set_pixel(4, 11, c_fish_orange)
	# Fish eye on right
	ic_food.set_pixel(15, 11, c_out)
	ic_food.set_pixel(14, 11, Color("#FFFFFF"))
	# Steam curls above bowl
	ic_food.set_pixel(9, 6, Color(1,1,1,0.7)); ic_food.set_pixel(10, 5, Color(1,1,1,0.7))
	ic_food.set_pixel(14, 7, Color(1,1,1,0.7)); ic_food.set_pixel(15, 6, Color(1,1,1,0.7))
	_save_both(ic_food, out_dir + "icon_nav_food_24x24")

	# --- ICON 3: CUỘN LEN (Playful Yarn Ball with Curly String) ---
	var ic_play = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	ic_play.fill(Color(0,0,0,0))
	var c_yarn = Color("#E65C40")
	var c_yarn_hi = Color("#FA8A73")
	var c_yarn_sh = Color("#A83018")
	var c_yarn_strand = Color("#FFBDAD")
	
	# Round ball (radius ~7 centered at (11, 11))
	for y in range(4, 19):
		for x in range(4, 19):
			var dist = (Vector2(x, y) - Vector2(11, 11)).length()
			if dist <= 7.0:
				ic_play.set_pixel(x, y, c_yarn)
			if dist <= 7.0 and dist >= 6.0:
				ic_play.set_pixel(x, y, c_out)
				
	# Crossed woven yarn strands
	for i in range(10):
		ic_play.set_pixel(7 + i, 8 + (i % 3), c_yarn_strand)
		ic_play.set_pixel(6 + (i % 4), 6 + i, c_yarn_sh)
		ic_play.set_pixel(10 + (i % 3), 6 + i, c_yarn_hi)
		
	# Loose unraveling string to bottom right
	ic_play.set_pixel(16, 17, c_yarn)
	ic_play.set_pixel(18, 18, c_yarn)
	ic_play.set_pixel(20, 18, c_yarn_hi)
	ic_play.set_pixel(21, 19, c_yarn)
	ic_play.set_pixel(22, 18, c_yarn)
	_save_both(ic_play, out_dir + "icon_nav_play_24x24")

	# --- ICON 4: CUỐN SÁCH BÌA DA (Leather-Bound Skill Tome) ---
	var ic_learn = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	ic_learn.fill(Color(0,0,0,0))
	var c_leather = Color("#824927")
	var c_leather_hi = Color("#B26D40")
	var c_leather_sh = Color("#4D260F")
	var c_pages = Color("#F5EADB")
	var c_pages_sh = Color("#C9BCAB")
	var c_ribbon = Color("#D9383A")
	
	# Book cover (open or thick volume)
	for y in range(4, 20):
		for x in range(5, 19):
			ic_learn.set_pixel(x, y, c_leather)
		ic_learn.set_pixel(5, y, c_out)
		ic_learn.set_pixel(18, y, c_out)
	for x in range(5, 19):
		ic_learn.set_pixel(x, 4, c_out)
		ic_learn.set_pixel(x, 19, c_out)
		
	# Paper pages edge on right
	for y in range(5, 19):
		ic_learn.set_pixel(16, y, c_pages)
		ic_learn.set_pixel(17, y, c_pages_sh)
		
	# Golden corner brackets
	for pt in [Vector2i(6,5), Vector2i(7,5), Vector2i(6,6), Vector2i(6,17), Vector2i(6,18), Vector2i(7,18)]:
		ic_learn.set_pixel(pt.x, pt.y, c_gold_rivet)
		
	# Red bookmark ribbon hanging out bottom
	for y in range(14, 23):
		ic_learn.set_pixel(11, y, c_ribbon)
		ic_learn.set_pixel(12, y, c_ribbon)
	ic_learn.set_pixel(11, 22, Color(0,0,0,0)) # V-cut swallowtail
	_save_both(ic_learn, out_dir + "icon_nav_learn_24x24")

	# --- ICON 5: CẨM NANG CỨU NGUY (Survival & Life Handbook) ---
	var ic_hb = Image.create(24, 24, false, Image.FORMAT_RGBA8)
	ic_hb.fill(Color(0,0,0,0))
	var c_hb_cover = Color("#C84630")
	var c_hb_hi = Color("#E86852")
	var c_hb_cross = Color("#FFFFFF")
	
	for y in range(4, 20):
		for x in range(5, 19):
			ic_hb.set_pixel(x, y, c_hb_cover)
		ic_hb.set_pixel(5, y, c_out)
		ic_hb.set_pixel(18, y, c_out)
	for x in range(5, 19):
		ic_hb.set_pixel(x, 4, c_out)
		ic_hb.set_pixel(x, 19, c_out)
		ic_hb.set_pixel(x, 5, c_hb_hi)
		
	# White emergency rescue cross in center
	for y in range(8, 15):
		ic_hb.set_pixel(11, y, c_hb_cross)
		ic_hb.set_pixel(12, y, c_hb_cross)
	for x in range(8, 15):
		ic_hb.set_pixel(x, 11, c_hb_cross)
		ic_hb.set_pixel(x, 12, c_hb_cross)
		
	# Golden corner rivets
	for pt in [Vector2i(6,5), Vector2i(17,5), Vector2i(6,18), Vector2i(17,18)]:
		ic_hb.set_pixel(pt.x, pt.y, c_gold_rivet)
	_save_both(ic_hb, out_dir + "icon_nav_handbook_24x24")

	# =========================================================================
	# 7. DRAWER CLOSE BUTTON (22x22 Normal & Pressed)
	# =========================================================================
	var close_norm = Image.create(22, 22, false, Image.FORMAT_RGBA8)
	close_norm.fill(Color("#8A4A28"))
	var close_press = Image.create(22, 22, false, Image.FORMAT_RGBA8)
	close_press.fill(Color("#5E2E14"))
	
	for x in range(22):
		close_norm.set_pixel(x, 0, c_timber_dark)
		close_norm.set_pixel(x, 1, c_wood_hi)
		close_norm.set_pixel(x, 21, c_timber_dark)
		close_press.set_pixel(x, 0, c_timber_dark)
		close_press.set_pixel(x, 21, c_timber_dark)
	for y in range(22):
		close_norm.set_pixel(0, y, c_timber_dark)
		close_norm.set_pixel(1, y, c_wood_hi)
		close_norm.set_pixel(21, y, c_timber_dark)
		close_press.set_pixel(0, y, c_timber_dark)
		close_press.set_pixel(21, y, c_timber_dark)
		
	for i in range(8):
		close_norm.set_pixel(7 + i, 7 + i, Color("#FFF0D4"))
		close_norm.set_pixel(14 - i, 7 + i, Color("#FFF0D4"))
		close_press.set_pixel(7 + i, 8 + i, Color("#E0C49B"))
		close_press.set_pixel(14 - i, 8 + i, Color("#E0C49B"))
		
	close_norm.set_pixel(0, 0, Color(0,0,0,0)); close_norm.set_pixel(21, 0, Color(0,0,0,0))
	close_norm.set_pixel(0, 21, Color(0,0,0,0)); close_norm.set_pixel(21, 21, Color(0,0,0,0))
	close_press.set_pixel(0, 0, Color(0,0,0,0)); close_press.set_pixel(21, 0, Color(0,0,0,0))
	close_press.set_pixel(0, 21, Color(0,0,0,0)); close_press.set_pixel(21, 21, Color(0,0,0,0))
	_save_both(close_norm, out_dir + "btn_drawer_close_normal")
	_save_both(close_press, out_dir + "btn_drawer_close_pressed")

	print("--- ALL BOTTOM PAW MENU ASSETS SUCCESSFULLY GENERATED! ---")
	quit()

func _save_both(img: Image, base_path: String) -> void:
	img.save_png(base_path + ".png")
	var tex = ImageTexture.create_from_image(img)
	ResourceSaver.save(tex, "res://" + base_path + ".tres")
	print("  Saved: %s (.png & .tres)" % base_path.get_file())
