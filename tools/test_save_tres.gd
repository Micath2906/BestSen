extends SceneTree

func _init() -> void:
	var img = Image.load_from_file("assets/UI/CatUIPaid/slices/toffee_hud/hud_wood_parchment_9patch.png")
	var tex = ImageTexture.create_from_image(img)
	var err = ResourceSaver.save(tex, "res://assets/UI/CatUIPaid/slices/toffee_hud/hud_wood_parchment_9patch.tres")
	print("ResourceSaver result: ", err)
	
	var loaded = load("res://assets/UI/CatUIPaid/slices/toffee_hud/hud_wood_parchment_9patch.tres")
	print("Loaded res: ", loaded)
	quit()
