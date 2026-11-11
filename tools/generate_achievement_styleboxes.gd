@tool
extends SceneTree

func _init():
	print("--- GENERATING STYLEBOXES FOR ACHIEVEMENT BOARD ---")
	var base_dir = "res://assets/UI/CatUIPaid/slices/cozy_achievements/"
	
	# Cork Board StyleBox
	var cb_tex = ResourceLoader.load(base_dir + "cork_board_9patch.tres")
	if cb_tex:
		var sb = StyleBoxTexture.new()
		sb.texture = cb_tex
		sb.texture_margin_left = 16
		sb.texture_margin_right = 16
		sb.texture_margin_top = 16
		sb.texture_margin_bottom = 16
		sb.content_margin_left = 18
		sb.content_margin_right = 18
		sb.content_margin_top = 18
		sb.content_margin_bottom = 18
		ResourceSaver.save(sb, base_dir + "cork_board_stylebox.tres")
		print("Saved cork_board_stylebox.tres")
		
	# Scroll StyleBox
	var sc_tex = ResourceLoader.load(base_dir + "parchment_scroll_cert_9patch.tres")
	if sc_tex:
		var sb = StyleBoxTexture.new()
		sb.texture = sc_tex
		sb.texture_margin_left = 18
		sb.texture_margin_right = 18
		sb.texture_margin_top = 18
		sb.texture_margin_bottom = 18
		sb.content_margin_left = 22
		sb.content_margin_right = 22
		sb.content_margin_top = 22
		sb.content_margin_bottom = 22
		ResourceSaver.save(sb, base_dir + "parchment_scroll_stylebox.tres")
		print("Saved parchment_scroll_stylebox.tres")
		
	# Polaroid StyleBox
	var po_tex = ResourceLoader.load(base_dir + "polaroid_card_9patch.tres")
	if po_tex:
		var sb = StyleBoxTexture.new()
		sb.texture = po_tex
		sb.texture_margin_left = 8
		sb.texture_margin_right = 8
		sb.texture_margin_top = 8
		sb.texture_margin_bottom = 14
		sb.content_margin_left = 6
		sb.content_margin_right = 6
		sb.content_margin_top = 8
		sb.content_margin_bottom = 8
		ResourceSaver.save(sb, base_dir + "polaroid_card_stylebox.tres")
		print("Saved polaroid_card_stylebox.tres")
		
	quit(0)
