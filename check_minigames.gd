extends SceneTree

func _init():
	print("--- CHECKING MINIGAMES FOR ISSUES ---")
	var dir = DirAccess.open("res://scripts/minigames")
	if not dir:
		quit()
		return
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".gd"):
			var full_path = "res://scripts/minigames".path_join(file_name)
			_check_file(full_path)
		file_name = dir.get_next()
	quit()

func _check_file(path: String):
	var f = FileAccess.open(path, FileAccess.READ)
	if not f: return
	var txt = f.get_as_text()
	
	# Check 1: Answer leaked in slot text
	if "selected_step_card[\"title\"]" in txt or "selected_card[\"title\"]" in txt or "selected_card[\"name\"]" in txt:
		print("[ANSWER LEAK] in %s" % path)
		
	# Check 2: Matched style check (does it set green color or leave disabled default?)
	if "is_matched" in txt or "matched_pairs" in txt:
		if not "0.72" in txt and not "0.7" in txt and not "GREEN" in txt:
			print("[NO GREEN MATCH] in %s" % path)
			
	# Check 3: Check if shuffle is used
	if "MATCHING_PAIRS" in txt or "COLLISION_STEPS" in txt or "STEPS" in txt:
		if not ".shuffle()" in txt:
			print("[NO SHUFFLE] in %s" % path)
			
	# Check 4: Check if blue button or icon_arrow_left
	if "btn_back" in txt:
		if not "icon_arrow_left" in txt:
			print("[NO ARROW ICON] in %s" % path)
