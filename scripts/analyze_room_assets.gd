@tool
extends SceneTree

func _init() -> void:
	print("\n--- ANALYZING ROOMS & FURNITURE ASSETS ---")
	for i in range(1, 16):
		var p = "res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Rooms/Room%d.png" % i
		var img = Image.new()
		if img.load(ProjectSettings.globalize_path(p)) == OK:
			print("Room%d: %dx%d" % [i, img.get_width(), img.get_height()])
			
	var decor_path = "res://assets/cats/CatMegaBundle/CatMegaBundle/CatItems/Decorations/CatRoomDecorations.png"
	var img_decor = Image.new()
	if img_decor.load(ProjectSettings.globalize_path(decor_path)) == OK:
		print("Decorations sheet: %dx%d" % [img_decor.get_width(), img_decor.get_height()])
		
	var ui_path = "res://assets/UI/CatUIPaid/CatUIPaid/catUI.png"
	var img_ui = Image.new()
	if img_ui.load(ProjectSettings.globalize_path(ui_path)) == OK:
		print("CatUI sheet: %dx%d" % [img_ui.get_width(), img_ui.get_height()])
		
	quit()
