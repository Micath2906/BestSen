extends Node

# TestEmptyCushionBed.gd
# Kiểm tra: Mèo Pochi ngủ đã được xóa khỏi phòng trọ, chỉ chừa lại cái đệm ngủ (cushion_bed) trống trải sạch đẹp.

func _ready() -> void:
	print("--- TEST ĐỆM NGỦ TRỐNG SẠCH ĐẸP ---")
	call_deferred("_start_test")

func _start_test() -> void:
	var main_scene = load("res://scenes/Main.tscn")
	var main = main_scene.instantiate()
	add_child(main)
	
	await get_tree().create_timer(0.4).timeout
	
	var room = main.current_view_node
	var comp_cat = room.get_node_or_null("YSortEntities/CompanionCat")
	var cushion_bed = room.get_node_or_null("YSortEntities/CushionBed")
	
	if comp_cat == null:
		print("  [PASS] Mèo ngủ đã được xóa hoàn toàn khỏi phòng!")
	else:
		printerr("  [FAIL] CompanionCat vẫn còn trong phòng!")
		
	if cushion_bed != null and cushion_bed.visible:
		print("  [PASS] Đệm ngủ (CushionBed) hiện diện đầy đủ tại vị trí: ", cushion_bed.position)
	else:
		printerr("  [FAIL] Không tìm thấy CushionBed!")
		
	var img = get_viewport().get_texture().get_image()
	var out_path = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d/screenshot_verified_empty_cushion_bed.png"
	img.save_png(out_path)
	print("  [SAVED SCREENSHOT] -> ", out_path)
	
	await get_tree().create_timer(0.2).timeout
	print("--- TEST HOÀN TẤT THÀNH CÔNG ---")
	get_tree().quit()
