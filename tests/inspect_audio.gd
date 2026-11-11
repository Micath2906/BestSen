extends SceneTree

func _init() -> void:
	print("--- INSPECTING AUDIO FILE VIA AUDIOSTREAMMP3 ---")
	var path = "res://assets/sounds/Cute_Cat_UI_Sounds_Demo_Reel.mp3"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var stream = AudioStreamMP3.new()
		stream.data = file.get_buffer(file.get_length())
		print("Loaded stream data successfully!")
		print("Length in seconds:", stream.get_length())
	else:
		print("File not found at", path)
	quit()
