extends SceneTree

func _init() -> void:
	var path = "assets/furnitures/PetMobileGameAsset/PetMobileGameAsset/Furnitures,Playgrounds,Toys.png"
	var img = Image.load_from_file(path)
	
	# Beds are in column x=0..240, from y=450 to 720
	# Let's crop x=0..120, y=470..560
	var b1 = img.get_region(Rect2i(0, 465, 115, 80))
	b1.save_png("assets/sprites/room_items/mobile/test_bed_crop1.png")
	
	var b2 = img.get_region(Rect2i(0, 545, 115, 80))
	b2.save_png("assets/sprites/room_items/mobile/test_bed_crop2.png")
	
	print("Saved test crops")
	quit(0)
