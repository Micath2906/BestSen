extends SceneTree

# test_game.gd - Kiểm thử logic toàn diện
func _init():
	print("--- BẮT ĐẦU KIỂM THỬ GAME MÈO TỰ LẬP ---")
	var GameManager = load("res://scripts/GameManager.gd").new()
	var SoundManager = load("res://scripts/SoundManager.gd").new()
	root.add_child(GameManager)
	root.add_child(SoundManager)
	
	# 1. Kiểm tra 16 bài học
	var total_lessons = GameManager.lessons_data.size()
	print("[TEST 1] Tổng số bài học:", total_lessons)
	assert(total_lessons == 16, "Thiếu bài học, phải có 16 bài!")
	
	for id in range(1, 17):
		var lesson = GameManager.lessons_data[id]
		assert(lesson.has("title"), "Bài %d thiếu title" % id)
		assert(lesson.has("cards"), "Bài %d thiếu cards" % id)
		assert(lesson["cards"].size() == 4, "Bài %d phải có đúng 4 bước" % id)
		assert(lesson.has("guide"), "Bài %d thiếu cẩm nang cứu sen" % id)
		assert(lesson.has("cheat_sheet"), "Bài %d thiếu cheat sheet" % id)
	print("-> Đã kiểm tra 16 bài học hợp lệ 100%!")
	
	# 2. Kiểm tra các chỉ số ban đầu
	print("[TEST 2] Chỉ số ban đầu:")
	print("  - Cá Khô:", GameManager.fish)
	print("  - Độ No:", GameManager.hunger)
	print("  - Dũng Cảm:", GameManager.courage)
	assert(GameManager.fish == 90, "Cá khởi điểm phải là 90")
	assert(GameManager.hunger == 70, "Độ No khởi điểm là 70")
	assert(GameManager.courage == 80, "Dũng Cảm khởi điểm là 80")
	
	# 3. Kiểm tra tính năng Cho ăn & Kho thức ăn
	print("[TEST 3] Kiểm thử chăm sóc & Kho thức ăn:")
	var init_kibble = GameManager.get_food_count("kibble")
	GameManager.feed_kibble()
	print("  Sau ăn hạt: Kibble =", GameManager.get_food_count("kibble"), ", No =", GameManager.hunger)
	assert(GameManager.get_food_count("kibble") == init_kibble - 1, "Ăn hạt tiêu hao 1 bát từ kho")
	assert(GameManager.hunger == 85, "Ăn hạt tăng 15 no")
	
	var init_pate = GameManager.get_food_count("pate")
	GameManager.feed_pate()
	print("  Sau ăn pate: Pate =", GameManager.get_food_count("pate"), ", No =", GameManager.hunger, ", DC =", GameManager.courage)
	assert(GameManager.get_food_count("pate") == init_pate - 1, "Ăn pate tiêu hao 1 lon từ kho")
	assert(GameManager.hunger == 100, "Độ no tối đa 100")
	assert(GameManager.courage == 100, "Dũng cảm tối đa 100")
	
	# 4. Kiểm tra Sequence Puzzle & Hoàn thành bài 1
	print("[TEST 4] Kiểm thử hoàn thành bài 1:")
	var lesson1 = GameManager.lessons_data[1]
	GameManager.complete_lesson(1)
	print("  - Bài đã hoàn thành:", GameManager.completed_lessons)
	print("  - Bài đã mở khóa:", GameManager.unlocked_lessons)
	print("  - Kho chiến lợi phẩm:", GameManager.loot_collection.size())
	assert(1 in GameManager.completed_lessons, "Bài 1 phải được đánh dấu hoàn thành")
	assert(2 in GameManager.unlocked_lessons, "Bài 2 phải được mở khóa")
	assert(GameManager.loot_collection.size() >= 1, "Phải nhận được chiến lợi phẩm")
	
	print("--- TẤT CẢ KIỂM THỬ THÀNH CÔNG VƯỢT TRỘI! ---")
	quit(0)
