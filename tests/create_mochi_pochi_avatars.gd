extends SceneTree

func _init() -> void:
	# 1. Tạo avatar_8.png (Mochi - Bạch miêu mắt 2 màu dị tật từ White-DifferentEyes/Sittingggg.png)
	var mochi_full = Image.load_from_file("D:/BestSen/assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/White-DifferentEyes/Sittingggg.png")
	var mochi_frame0 = mochi_full.get_region(Rect2i(0, 0, 32, 32))
	var m_rect = mochi_frame0.get_used_rect() # (4, 11, 23, 21)
	var mochi_cropped = mochi_frame0.get_region(m_rect)
	
	# Tạo canvas 32x32 trong suốt, căn giữa Mochi
	var mochi_av = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var ox = int((32 - m_rect.size.x) / 2.0)
	var oy = int((32 - m_rect.size.y) / 2.0) + 2 # dịch xuống 2px cho nằm gọn đáy khung
	mochi_av.blit_rect(mochi_cropped, Rect2i(0, 0, m_rect.size.x, m_rect.size.y), Vector2i(ox, oy))
	mochi_av.save_png("D:/BestSen/assets/sprites/avatars/avatar_8.png")
	print("Đã tạo avatar_8.png (Mochi) chuẩn pixel!")
	
	# 2. Tạo avatar_9.png (Pochi - Mèo đốm từ Pochi/Sprites/Idle.png)
	var pochi_full = Image.load_from_file("D:/BestSen/assets/cats/CatMegaBundle/CatMegaBundle/Pochi/Sprites/Idle.png")
	var pochi_frame0 = pochi_full.get_region(Rect2i(0, 0, 64, 64))
	var p_rect = pochi_frame0.get_used_rect() # (0, 19, 51, 45)
	var pochi_cropped = pochi_frame0.get_region(p_rect)
	
	# Scale Pochi xuống để tỉ lệ vừa khít 32x32
	var p_w = 26
	var p_h = int(float(p_rect.size.y) / p_rect.size.x * p_w)
	pochi_cropped.resize(p_w, p_h, Image.INTERPOLATE_NEAREST)
	
	var pochi_av = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var px = int((32 - p_w) / 2.0)
	var py = int((32 - p_h) / 2.0) + 2
	pochi_av.blit_rect(pochi_cropped, Rect2i(0, 0, p_w, p_h), Vector2i(px, py))
	pochi_av.save_png("D:/BestSen/assets/sprites/avatars/avatar_9.png")
	print("Đã tạo avatar_9.png (Pochi) chuẩn pixel!")
	
	quit()
