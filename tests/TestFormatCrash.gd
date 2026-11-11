extends SceneTree

func _init() -> void:
	var gm = load("res://scripts/GameManager.gd").new()
	gm._ready()
	var lesson_data = gm.lessons_data.get(1, {})
	print("Cards in lesson 1: ", lesson_data.get("cards", []).size())
	
	var guide_lines = lesson_data.get("guide", [])
	var guide_str = "📌 BÍ KÍP BỎ TÚI CỦA SINH VIÊN:\n\n"
	for line in guide_lines:
		guide_str += "  ✔ " + line + "\n"
	
	guide_str += "\n🐾 TRÌNH TỰ TỪ NGỮ DẠY MÈO (BƯỚC 1 ➔ 2 ➔ 3 ➔ 4):\n\n"
	var sorted_cards = lesson_data.get("cards", []).duplicate()
	sorted_cards.sort_custom(func(a, b): return a["step"] < b["step"])
	for c in sorted_cards:
		print("Formatting card: ", c)
		var s = "  %d️⃣ Bước %d: %s  [%s] ➔ %s\n" % [c["step"], c["step"], c["icon"], c.get("meow", ""), c["text"]]
		guide_str += s
	print("Guide str length: ", guide_str.length())
	quit(0)
