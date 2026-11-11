extends Control

@onready var main = $Main

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	
	# Chuyển sang tab Kỹ Năng (Map)
	main.switch_to_map()
	await get_tree().create_timer(0.6).timeout
	
	# 1. Chụp toàn cảnh Bản đồ Duolingo / Candy Crush (Level 1 Active với Token Mèo)
	var img1 = get_viewport().get_texture().get_image()
	img1.save_png("D:/BestSen/screenshot_saga_map_active.png")
	print("Captured: screenshot_saga_map_active.png")
	
	# 2. Mở Level Preview Modal (Bấm vào Level 1)
	var skill_tree = main.current_view_node
	if skill_tree and skill_tree.has_method("_on_level_node_clicked"):
		skill_tree._on_level_node_clicked(1)
		await get_tree().create_timer(0.4).timeout
		var img2 = get_viewport().get_texture().get_image()
		img2.save_png("D:/BestSen/screenshot_saga_map_preview.png")
		print("Captured: screenshot_saga_map_preview.png")
		skill_tree.level_preview_modal.visible = false
		await get_tree().create_timer(0.2).timeout
		
	# 3. Giả lập hoàn thành Bài 1 & 2 để thấy nodes vàng 3 sao ⭐⭐⭐ và cuộn xuống
	GameManager.completed_lessons.append(1)
	GameManager.completed_lessons.append(2)
	skill_tree.refresh_list()
	await get_tree().create_timer(0.3).timeout
	var img3 = get_viewport().get_texture().get_image()
	img3.save_png("D:/BestSen/screenshot_saga_map_mastered.png")
	print("Captured: screenshot_saga_map_mastered.png")
	
	# Trả lại trạng thái ban đầu
	GameManager.completed_lessons.clear()
	print("ALL SAGA MAP CAPTURES COMPLETED!")
	get_tree().quit()
