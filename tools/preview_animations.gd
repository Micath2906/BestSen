extends SceneTree

func _init() -> void:
	print("--- EXTRACTING & VERIFYING FREEPACK ANIMATIONS ---")
	var path_cat1 = "res://assets/Free pack/Free pack/cat 1.png"
	var img = Image.load_from_file(path_cat1)
	
	# Let's verify our key rows:
	var key_animations = {
		"idle_sit_down_right": [0, 4, 1], # row 0, col 4, 1 frame
		"idle_sit_down_left": [0, 5, 1],  # row 0, col 5, 1 frame
		"walk_down": [4, 0, 4],           # row 4, 4 frames
		"walk_up": [5, 0, 4],             # row 5, 4 frames
		"walk_right": [6, 0, 4],          # row 6, 4 frames
		"walk_left": [7, 0, 4],           # row 7, 4 frames
		"walk_down_left": [8, 0, 4],      # row 8, 4 frames
		"walk_down_right": [9, 0, 4],     # row 9, 4 frames
		"walk_up_right": [10, 0, 4],      # row 10, 4 frames
		"walk_up_left": [11, 0, 4],       # row 11, 4 frames
		"sleep_curled": [16, 0, 4],       # row 16, 4 frames
		"faint_sploot": [18, 0, 4],       # row 18, 4 frames
		"eat_down_right": [24, 0, 4],     # row 24, 4 frames
		"eat_down_left": [25, 0, 4],      # row 25, 4 frames
		"meow": [28, 0, 4],               # row 28, 4 frames
		"yawn": [32, 0, 4],               # row 32, 4 frames
		"wash": [36, 0, 4],               # row 36, 4 frames
		"scratch": [39, 0, 4],            # row 39, 4 frames
		"play_toy": [48, 0, 4],           # row 48, 4 frames
		"hind_legs": [53, 0, 4],          # row 53, 4 frames
	}
	
	# Create a preview composite image (160x320)
	var preview = Image.create(16 * 6, 16 * key_animations.size(), false, Image.FORMAT_RGBA8)
	var anim_idx = 0
	for anim_name in key_animations:
		var cfg = key_animations[anim_name]
		var row = cfg[0]
		var start_col = cfg[1]
		var count = cfg[2]
		for c in range(count):
			var src_rect = Rect2i((start_col + c) * 16, row * 16, 16, 16)
			preview.blit_rect(img, src_rect, Vector2i(c * 16, anim_idx * 16))
		anim_idx += 1
		
	preview.save_png("res://tests/freepack_animations_preview.png")
	print("Saved freepack_animations_preview.png with %d animations!" % key_animations.size())
	quit()
