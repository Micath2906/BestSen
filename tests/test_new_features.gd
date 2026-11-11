extends Node

func _ready():
	print("--- KIỂM THỬ TÍNH NĂNG MỚI: HUD MÈO, MENU PAW & ANIMATIONS ---")
	
	# 1. Test 8 Avatars in GameManager
	print("[TEST 1] Kiểm tra danh sách 8 Avatar Mèo:")
	assert(GameManager.avatar_list.size() == 8, "Cần có 8 avatar mèo!")
	for i in range(8):
		var av = GameManager.avatar_list[i]
		print("  - Avatar ", i, ": ", av["name"])
		var tex = load("res://assets/sprites/avatars/framed_avatar_%d.png" % i)
		assert(tex != null, "Thiếu framed_avatar_%d.png!" % i)
	
	# Test đổi avatar
	GameManager.set_avatar(3)
	assert(GameManager.selected_avatar_id == 3, "Đổi avatar thất bại!")
	print("-> Đổi avatar thành công: ", GameManager.avatar_list[3]["name"])
	
	# 2. Test Paw Textures
	print("[TEST 2] Kiểm tra 9 Paw Textures:")
	for i in range(9):
		var paw_tex = load("res://assets/sprites/ui/paw_%d.png" % i)
		assert(paw_tex != null, "Thiếu paw_%d.png!" % i)
	print("-> Đầy đủ 9 Paw Textures!")
	
	# 3. Test RoomView Instantiation & Cat States
	print("[TEST 3] Kiểm tra khởi tạo RoomView & Hoạt ảnh:")
	var room_scene = load("res://scenes/RoomView.tscn")
	var room = room_scene.instantiate()
	add_child(room)
	
	# Verify states
	room.set_state(room.CatState.WALK)
	assert(room.current_state == room.CatState.WALK, "Lỗi state WALK")
	assert(room.anim_sprite.visible == true, "AnimSprite phải hiện khi WALK")
	
	room.set_state(room.CatState.SLEEP)
	assert(room.current_state == room.CatState.SLEEP, "Lỗi state SLEEP")
	
	room.set_state(room.CatState.BOX)
	assert(room.cat_box_sprite.visible == true, "CatBoxSprite phải hiện khi BOX")
	
	room.set_state(room.CatState.DRACULA)
	assert(room.cat_drac_sprite.visible == true, "CatDraculaSprite phải hiện khi DRACULA")
	
	# Test cho ăn từ menu
	var old_no = GameManager.hunger
	room.feed_cat("kibble")
	assert(GameManager.hunger > old_no, "Ăn hạt phải tăng Độ No")
	print("-> Cho mèo ăn thành công, Độ No tăng lên: ", GameManager.hunger)
	
	room.queue_free()
	
	# 4. Test Main Scene with HUD and Dock
	print("[TEST 4] Kiểm tra Main Scene chứa đầy đủ HUD & Menu Dock:")
	var main_scene = load("res://scenes/Main.tscn")
	var main_node = main_scene.instantiate()
	add_child(main_node)
	
	assert(main_node.has_node("CatProfileHUD"), "Main phải có CatProfileHUD!")
	assert(main_node.has_node("BottomPawMenu"), "Main phải có BottomPawMenu!")
	assert(main_node.has_node("AvatarPickerModal"), "Main phải có AvatarPickerModal!")
	print("-> Main Scene tích hợp đầy đủ CatProfileHUD, BottomPawMenu & AvatarPickerModal!")
	
	main_node.queue_free()
	
	print("--- TẤT CẢ TÍNH NĂNG MỚI ĐÃ ĐƯỢC KIỂM THỬ THÀNH CÔNG 100%! ---")
	get_tree().quit()
