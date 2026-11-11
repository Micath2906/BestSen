extends SceneTree

func _init() -> void:
	print("--- TESTING GODOT AUDIO CLIP LOADING ---")
	var clips_to_test = [
		"res://assets/sounds/clips/clip_01.wav", # UI Click
		"res://assets/sounds/clips/clip_03.wav", # UI Pop
		"res://assets/sounds/clips/clip_09.wav", # Fail short
		"res://assets/sounds/clips/clip_19.wav", # Meow cheerful ("Méo meo!")
		"res://assets/sounds/clips/clip_22.wav", # Fail ("Ngoao..")
		"res://assets/sounds/clips/clip_29.wav", # Meow inquisitive ("Meo-o?")
		"res://assets/sounds/clips/clip_31.wav", # Meow ("Meoo~")
		"res://assets/sounds/clips/clip_35.wav", # Whine fail ("Ngoaooo..")
		"res://assets/sounds/clips/clip_44.wav", # Purr
		"res://assets/sounds/clips/clip_45.wav", # Success fanfare
	]
	
	var all_ok = true
	for path in clips_to_test:
		var stream = load(path)
		if stream:
			print("LOADED OK: ", path, " | Length: ", stream.get_length(), "s | Type: ", stream.get_class())
		else:
			print("FAILED TO LOAD: ", path)
			all_ok = false
			
	if all_ok:
		print("SUCCESS: All sample clips loaded cleanly into Godot!")
	else:
		print("ERROR: Some clips failed to load!")
	quit()
