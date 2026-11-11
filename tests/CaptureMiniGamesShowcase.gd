extends Node

# CaptureMiniGamesShowcase.gd - Chụp ảnh màn hình showcase 5 Dạng Gameplay Mini-Game

const ARTIFACT_DIR = "C:/Users/thaip/.gemini/antigravity/brain/c8fc8184-69d9-49e6-8f7d-9cd22d11477d"

func _ready() -> void:
	print("\n=== BẮT ĐẦU CHỤP ẢNH SHOWCASE 5 GAMEPLAY MINI-GAME ===")
	
	# 1. Chụp Gameplay 1: QTE (Bấm chuông xe buýt)
	var qte_scene = load("res://scenes/minigames/QteMiniGame.tscn")
	var qte = qte_scene.instantiate()
	add_child(qte)
	qte.load_minigame(GameManager.get_minigame_data(1))
	qte.progress = 0.68 # Đang trong vùng xanh an toàn
	await _wait_and_capture("screenshot_minigame_qte.png")
	qte.queue_free()
	await get_tree().process_frame
	
	# 2. Chụp Gameplay 2: Audit (Kính lúp soi hợp đồng trọ)
	var audit_scene = load("res://scenes/minigames/AuditMiniGame.tscn")
	var audit = audit_scene.instantiate()
	add_child(audit)
	audit.load_minigame(GameManager.get_minigame_data(5))
	# Cào trước 1 bẫy để thấy vết cào đỏ trực quan
	var dummy_btn = Button.new()
	var clauses = GameManager.get_minigame_data(5).get("clauses", [])
	for c in clauses:
		if c.get("is_red_flag", false):
			audit._on_clause_clicked(c, dummy_btn)
			break
	audit.feedback_panel.visible = false # Ẩn modal feedback để nhìn rõ trang hợp đồng
	await _wait_and_capture("screenshot_minigame_audit.png")
	audit.queue_free()
	await get_tree().process_frame
	
	# 3. Chụp Gameplay 3: Packing (Xếp ba lô y tế)
	var pack_scene = load("res://scenes/minigames/PackingMiniGame.tscn")
	var pack = pack_scene.instantiate()
	add_child(pack)
	pack.load_minigame(GameManager.get_minigame_data(10))
	var items = GameManager.get_minigame_data(10).get("items", [])
	if items.size() >= 3:
		pack._add_to_backpack(items[0])
		pack._add_to_backpack(items[1])
		pack._add_to_backpack(items[2])
	await _wait_and_capture("screenshot_minigame_packing.png")
	pack.queue_free()
	await get_tree().process_frame
	
	# 4. Chụp Gameplay 4: Budget (Cán cân 3 hũ tiền)
	var budget_scene = load("res://scenes/minigames/BudgetMiniGame.tscn")
	var budget = budget_scene.instantiate()
	add_child(budget)
	budget.load_minigame(GameManager.get_minigame_data(13))
	budget._apply_gold_preset() # Đạt trạng thái cân bằng tuyệt đẹp
	await _wait_and_capture("screenshot_minigame_budget.png")
	budget.queue_free()
	await get_tree().process_frame
	
	# 5. Chụp Gameplay 5: Dialogue (Đối đáp thợ sửa xe)
	var dia_scene = load("res://scenes/minigames/DialogueMiniGame.tscn")
	var dia = dia_scene.instantiate()
	add_child(dia)
	dia.load_minigame(GameManager.get_minigame_data(4))
	await _wait_and_capture("screenshot_minigame_dialogue.png")
	dia.queue_free()
	await get_tree().process_frame
	
	print("\n=== TOÀN BỘ 5 ẢNH SHOWCASE ĐÃ ĐƯỢC CHỤP THÀNH CÔNG! ===")
	get_tree().quit()

func _wait_and_capture(filename: String) -> void:
	for i in range(4):
		await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	var vp = get_viewport()
	if vp:
		var img = vp.get_texture().get_image()
		if img:
			# Lưu vào thư mục BestSen
			var path1 = "D:/BestSen/" + filename
			img.save_png(path1)
			# Lưu vào Artifact Directory
			var path2 = ARTIFACT_DIR + "/" + filename
			img.save_png(path2)
			print("  [CAPTURED] -> %s" % filename)
