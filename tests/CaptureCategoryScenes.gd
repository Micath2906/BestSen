extends Node

# CaptureCategoryScenes.gd - Chụp ảnh kiểm chứng 4 Scene Danh Mục Kỹ Năng Sống

const ARTIFACT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d"

var categories = [
	{"path": "res://scenes/categories/CategoryMobility.tscn", "file": "screenshot_category_mobility.png"},
	{"path": "res://scenes/categories/CategoryHousingLegal.tscn", "file": "screenshot_category_housing_legal.png"},
	{"path": "res://scenes/categories/CategoryHealthMedical.tscn", "file": "screenshot_category_health_medical.png"},
	{"path": "res://scenes/categories/CategoryFinanceCareer.tscn", "file": "screenshot_category_finance_career.png"},
]

var cur_idx = 0
var current_node: Node = null

func _ready() -> void:
	print("--- BẮT ĐẦU CHỤP ẢNH 4 SCENE DANH MỤC ---")
	_capture_next()

func _capture_next() -> void:
	if cur_idx >= categories.size():
		print("--- HOÀN TẤT CHỤP ẢNH TẤT CẢ 4 DANH MỤC ---")
		get_tree().quit(0)
		return
		
	if current_node:
		current_node.queue_free()
		current_node = null
		
	var cat_info = categories[cur_idx]
	var scn = load(cat_info["path"])
	current_node = scn.instantiate()
	add_child(current_node)
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	
	var img = get_viewport().get_texture().get_image()
	var out_path = ARTIFACT_DIR + "/" + cat_info["file"]
	var err = img.save_png(out_path)
	if err == OK:
		print("Đã lưu ảnh: %s" % out_path)
	else:
		print("Lỗi lưu ảnh: %d" % err)
		
	cur_idx += 1
	_capture_next()
