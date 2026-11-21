extends RefCounted
class_name PixelPlaceholderFactory

## PixelPlaceholderFactory.gd
## Programmatic generator and cache for pixel art placeholder textures.
## Ensures that missing user/artist assets never break scenes, layout, or headless tests.

enum Category {
	CLOTHES = 0,
	DOCS = 1,
	MEDICINE = 2,
	TECH = 3,
	PROHIBITED = 4,
	DEFECT_SAFETY = 5,
	DEFAULT = 6,
	TRANSIT = 7,
	FINANCE_SCAM = 8,
	BUDGET_JAR = 9
}

static var _cache: Dictionary = {}

## Standard candidate asset directories to probe before generating placeholder
const SEARCH_PATHS: Array[String] = [
	"res://assets/sprites/minigames/packing/",
	"res://assets/sprites/minigames/inspection/",
	"res://assets/sprites/minigames/healthcare/",
	"res://assets/sprites/minigames/transit/",
	"res://assets/sprites/minigames/finance/",
	"res://assets/sprites/room_items/",
	"res://assets/sprites/items/",
	"res://assets/sprites/",
	"res://assets/furnitures/CatRoomPaid/CatRoomPaid/Rooms/"
]

## Category Color Profiles: [bg_color, border_dark, border_light, accent]
static func _get_category_palette(category: int) -> Array[Color]:
	match category:
		Category.CLOTHES:
			return [Color("#78909C"), Color("#37474F"), Color("#B0BEC5"), Color("#263238")]
		Category.DOCS:
			return [Color("#FFE082"), Color("#FF8F00"), Color("#FFF8E1"), Color("#E65100")]
		Category.MEDICINE:
			return [Color("#FFCDD2"), Color("#C62828"), Color("#FFFFFF"), Color("#B71C1C")]
		Category.TECH:
			return [Color("#80DEEA"), Color("#00838F"), Color("#E0F7FA"), Color("#006064")]
		Category.PROHIBITED:
			return [Color("#EF9A9A"), Color("#B71C1C"), Color("#FFCDD2"), Color("#D50000")]
		Category.DEFECT_SAFETY:
			return [Color("#FFF9C4"), Color("#F57F17"), Color("#FFFDE7"), Color("#E65100")]
		Category.TRANSIT:
			return [Color("#BBDEFB"), Color("#1565C0"), Color("#E3F2FD"), Color("#0D47A1")]
		Category.FINANCE_SCAM:
			return [Color("#FFCCBC"), Color("#BF360C"), Color("#FBE9E7"), Color("#D84315")]
		Category.BUDGET_JAR:
			return [Color("#C8E6C9"), Color("#2E7D32"), Color("#E8F5E9"), Color("#1B5E20")]
		_:
			return [Color("#FDF6E3"), Color("#6D4C41"), Color("#FFFFFF"), Color("#3E2723")]

## Main API: Retrieves real texture if present on disk, otherwise generates programmatic pixel placeholder
static func get_or_create(asset_id: String, size: Vector2i, category: int = Category.DEFAULT, label: String = "") -> Texture2D:
	var cache_key: String = "%s_%dx%d_%d" % [asset_id, size.x, size.y, category]
	if _cache.has(cache_key):
		return _cache[cache_key]

	# 1. Probe candidate disk paths for real asset
	for base_path in SEARCH_PATHS:
		var candidate_path := base_path + asset_id + ".png"
		if ResourceLoader.exists(candidate_path):
			var real_tex = load(candidate_path) as Texture2D
			if real_tex:
				_cache[cache_key] = real_tex
				return real_tex

	# 2. Programmatically generate crisp pixel placeholder ImageTexture
	var w: int = maxi(16, size.x)
	var h: int = maxi(16, size.y)
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)

	var palette := _get_category_palette(category)
	var bg_col: Color = palette[0]
	var dark_col: Color = palette[1]
	var light_col: Color = palette[2]
	var accent_col: Color = palette[3]

	img.fill(bg_col)

	# 2a. Draw 2px retro beveled pixel border
	for x in range(w):
		img.set_pixel(x, 0, dark_col)
		img.set_pixel(x, h - 1, dark_col)
	for y in range(h):
		img.set_pixel(0, y, dark_col)
		img.set_pixel(w - 1, y, dark_col)

	if w > 4 and h > 4:
		# Inner top & left highlight
		for x in range(1, w - 1):
			img.set_pixel(x, 1, light_col)
		for y in range(1, h - 1):
			img.set_pixel(1, y, light_col)
		# Inner bottom & right shadow
		for x in range(1, w - 1):
			img.set_pixel(x, h - 2, dark_col)
		for y in range(1, h - 1):
			img.set_pixel(w - 2, y, dark_col)

	# 2b. Draw category-specific center insignia
	_draw_category_insignia(img, w, h, category, accent_col)

	# 2c. Render short pixel text if label provided and space allows
	var display_text := label if label != "" else asset_id
	if w >= 24 and h >= 24 and display_text != "":
		_render_mini_bitmap_text(img, w, h, display_text.to_upper(), dark_col)

	var tex := ImageTexture.create_from_image(img)
	_cache[cache_key] = tex
	return tex

## Draw iconic pixel shapes for quick visual category distinction
static func _draw_category_insignia(img: Image, w: int, h: int, category: int, col: Color) -> void:
	var cx: int = w / 2
	var cy: int = h / 2

	match category:
		Category.MEDICINE:
			# Red cross
			for i in range(-3, 4):
				if cx + i >= 0 and cx + i < w:
					img.set_pixel(cx + i, cy, col)
					img.set_pixel(cx + i, cy - 1, col)
				if cy + i >= 0 and cy + i < h:
					img.set_pixel(cx, cy + i, col)
					img.set_pixel(cx - 1, cy + i, col)
		Category.PROHIBITED:
			# Bold diagonal X
			for i in range(-4, 5):
				var px1: int = cx + i
				var py1: int = cy + i
				var px2: int = cx + i
				var py2: int = cy - i
				if px1 >= 2 and px1 < w - 2 and py1 >= 2 and py1 < h - 2:
					img.set_pixel(px1, py1, col)
				if px2 >= 2 and px2 < w - 2 and py2 >= 2 and py2 < h - 2:
					img.set_pixel(px2, py2, col)
		Category.TECH:
			# Square microchip / socket contacts
			for i in range(-3, 4):
				for j in range(-3, 4):
					if (abs(i) == 3 or abs(j) == 3) and (cx + i >= 2 and cx + i < w - 2 and cy + j >= 2 and cy + j < h - 2):
						img.set_pixel(cx + i, cy + j, col)
		Category.DEFECT_SAFETY:
			# Exclamation hazard mark
			for y in range(cy - 4, cy + 1):
				if cx >= 0 and cx < w and y >= 0 and y < h:
					img.set_pixel(cx, y, col)
					img.set_pixel(cx - 1, y, col)
			if cy + 3 < h - 2:
				img.set_pixel(cx, cy + 3, col)
				img.set_pixel(cx - 1, cy + 3, col)
		Category.TRANSIT:
			# Bus icon (box with wheels)
			for x in range(cx - 4, cx + 5):
				for y in range(cy - 3, cy + 2):
					if x >= 0 and x < w and y >= 0 and y < h:
						img.set_pixel(x, y, col)
			# Wheels
			if cy + 3 < h and cx - 2 >= 0 and cx + 2 < w:
				img.set_pixel(cx - 2, cy + 3, col)
				img.set_pixel(cx + 2, cy + 3, col)
		Category.FINANCE_SCAM:
			# Warning triangle
			for i in range(5):
				for x in range(cx - i, cx + i + 1):
					var y: int = cy - 2 + i
					if x >= 0 and x < w and y >= 0 and y < h:
						if i == 4 or x == cx - i or x == cx + i:
							img.set_pixel(x, y, col)
		Category.BUDGET_JAR:
			# Jar jar bottle outline
			for x in range(cx - 3, cx + 4):
				for y in range(cy - 4, cy + 5):
					if x >= 0 and x < w and y >= 0 and y < h:
						if y == cy - 4 or y == cy + 4 or x == cx - 3 or x == cx + 3:
							img.set_pixel(x, y, col)
		Category.DOCS:
			# Document folded corner rect
			for y in range(cy - 3, cy + 4):
				for x in range(cx - 3, cx + 4):
					if (abs(x - cx) == 3 or abs(y - cy) == 3) and x >= 2 and x < w - 2 and y >= 2 and y < h - 2:
						img.set_pixel(x, y, col)
		Category.CLOTHES:
			# Folded shirt collar V-notch
			for x in range(cx - 3, cx + 4):
				if cx >= 2 and cx < w - 2 and cy - 2 >= 2:
					img.set_pixel(x, cy - 2, col)
			for i in range(3):
				if cx - i >= 2 and cy - 2 + i < h - 2:
					img.set_pixel(cx - i, cy - 2 + i, col)
				if cx + i < w - 2 and cy - 2 + i < h - 2:
					img.set_pixel(cx + i, cy - 2 + i, col)

## Tiny 3x5 bitmap font renderer directly into Image
static func _render_mini_bitmap_text(img: Image, w: int, h: int, text: String, col: Color) -> void:
	# Keep only first 4-5 characters to fit
	var clean_text: String = ""
	for i in range(mini(text.length(), 5)):
		var c: String = text.substr(i, 1)
		if _GLYPHS_3X5.has(c):
			clean_text += c
		elif c == " ":
			clean_text += " "
		else:
			clean_text += "?"

	if clean_text.is_empty():
		return

	var char_w: int = 3
	var char_h: int = 5
	var spacing: int = 1
	var total_w: int = clean_text.length() * (char_w + spacing) - spacing
	var start_x: int = clampi((w - total_w) / 2, 2, w - total_w - 2)
	var start_y: int = h - char_h - 3

	if start_y < 3:
		start_y = 3

	for char_idx in range(clean_text.length()):
		var ch: String = clean_text.substr(char_idx, 1)
		if ch == " ":
			continue
		var rows: Array = _GLYPHS_3X5.get(ch, _GLYPHS_3X5["?"])
		var cx: int = start_x + char_idx * (char_w + spacing)
		for r in range(char_h):
			var row_val: int = rows[r]
			for c in range(char_w):
				if (row_val & (1 << (2 - c))) != 0:
					var px: int = cx + c
					var py: int = start_y + r
					if px >= 0 and px < w and py >= 0 and py < h:
						img.set_pixel(px, py, col)

## 3x5 font glyph definitions (3 bits wide per row: 4=left, 2=mid, 1=right)
const _GLYPHS_3X5: Dictionary = {
	"A": [2, 5, 7, 5, 5],
	"B": [6, 5, 6, 5, 6],
	"C": [3, 4, 4, 4, 3],
	"D": [6, 5, 5, 5, 6],
	"E": [7, 4, 6, 4, 7],
	"F": [7, 4, 6, 4, 4],
	"G": [3, 4, 5, 5, 3],
	"H": [5, 5, 7, 5, 5],
	"I": [7, 2, 2, 2, 7],
	"J": [1, 1, 1, 5, 2],
	"K": [5, 5, 6, 5, 5],
	"L": [4, 4, 4, 4, 7],
	"M": [5, 7, 5, 5, 5],
	"N": [6, 5, 5, 5, 5],
	"O": [2, 5, 5, 5, 2],
	"P": [6, 5, 6, 4, 4],
	"Q": [2, 5, 5, 6, 3],
	"R": [6, 5, 6, 5, 5],
	"S": [3, 4, 2, 1, 6],
	"T": [7, 2, 2, 2, 2],
	"U": [5, 5, 5, 5, 2],
	"V": [5, 5, 5, 5, 2],
	"W": [5, 5, 5, 7, 5],
	"X": [5, 5, 2, 5, 5],
	"Y": [5, 5, 2, 2, 2],
	"Z": [7, 1, 2, 4, 7],
	"0": [2, 5, 5, 5, 2],
	"1": [2, 6, 2, 2, 7],
	"2": [6, 1, 2, 4, 7],
	"3": [6, 1, 2, 1, 6],
	"4": [5, 5, 7, 1, 1],
	"5": [7, 4, 6, 1, 6],
	"6": [3, 4, 6, 5, 2],
	"7": [7, 1, 2, 2, 2],
	"8": [2, 5, 2, 5, 2],
	"9": [2, 5, 3, 1, 6],
	"-": [0, 0, 7, 0, 0],
	"+": [0, 2, 7, 2, 0],
	"/": [1, 1, 2, 4, 4],
	"!": [2, 2, 2, 0, 2],
	"?": [6, 1, 2, 0, 2]
}
