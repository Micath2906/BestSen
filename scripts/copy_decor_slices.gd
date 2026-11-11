@tool
extends SceneTree

func _init() -> void:
	var out_dir = ProjectSettings.globalize_path("res://assets/sprites/room_items/")
	var src_dir = ProjectSettings.globalize_path("res://assets/sprites/room_decor_slices/")
	
	DirAccess.copy_absolute(src_dir + "decor_15_110x82_at_202_138.png", out_dir + "rug_boho.png")
	DirAccess.copy_absolute(src_dir + "decor_21_41x63_at_12_226.png", out_dir + "potted_monstera.png")
	DirAccess.copy_absolute(src_dir + "decor_1_61x95_at_19_1.png", out_dir + "window_curtains.png")
	print("Copied rug_boho.png, potted_monstera.png, window_curtains.png!")
	quit()
