extends Control

var step = 0
var decor_studio: Node = null

func _ready():
	var packed = load("res://scenes/RoomDecorStudioView.tscn")
	decor_studio = packed.instantiate()
	add_child(decor_studio)

func _process(_delta):
	step += 1
	if step == 8:
		# Chọn món đồ đầu tiên để kích hoạt Gizmo vòng tròn công cụ
		var layer = decor_studio.get_node("RoomViewportArea/RoomContainer/FurnitureLayer")
		if layer.get_child_count() > 0:
			var first_item = layer.get_child(0)
			decor_studio._select_item(first_item)
	elif step == 16:
		var img = get_viewport().get_texture().get_image()
		if img:
			img.save_png("res://screenshot_verified_decor_studio_ring.png")
			print("Saved screenshot_verified_decor_studio_ring.png")
		get_tree().quit()
