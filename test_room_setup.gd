extends SceneTree
func _init():
	var scene = load("res://scenes/IsometricRoomView.tscn").instantiate()
	var root = Control.new()
	root.size = Vector2(540, 960)
	root.add_child(scene)
	# Check companion cat visibility
	var comp = scene.get_node("YSortEntities/CompanionCat")
	var bed = scene.get_node("YSortEntities/CushionBed")
	var cat = scene.get_node("YSortEntities/IsoCat")
	print("Bed pos: ", bed.position, " z_index: ", bed.z_index)
	print("Comp pos: ", comp.position, " z_index: ", comp.z_index, " state: ", comp.current_state, " anim_visible: ", comp.anim_sprite.visible, " anim: ", comp.anim_sprite.animation)
	print("Cat pos: ", cat.position, " state: ", cat.current_state)
	quit(0)
