extends Node

func _ready() -> void:
	var path = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/.user_uploaded/media_1793428813032_efb1132d.png"
	var img = Image.load_from_file(path)
	if img:
		print("USER SCREENSHOT SIZE: ", img.get_width(), " x ", img.get_height())
	else:
		print("FAILED TO LOAD IMAGE")
	get_tree().quit(0)
