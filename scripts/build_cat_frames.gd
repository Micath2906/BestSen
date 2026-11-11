@tool
extends SceneTree

# build_cat_frames.gd
# Tự động hóa trích xuất và tạo SpriteFrames cho 8 loài mèo từ assets mới:
# 0: TigerCat (Mèo Mướp Cam)
# 1: BrownCat (Mèo Vàng Thông Thái)
# 2: ThreeColor (Mèo Tam Thể Xóm Trọ)
# 3: BlackCat (Mèo Đen Ninja)
# 4: BatmanCat (Mèo Tuxedo Quý Tộc)
# 5: WhiteCat (Mèo Tuyết Trắng 2 Màu Mắt)
# 6: Siamese (Mèo Xiêm Khởi Nghiệp)
# 7: CatClassical (Mèo Cổ Điển)

const BASE = "res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/"

const BREEDS = [
	{
		"id": 0,
		"name": "Mèo Mướp Cam",
		"idle": BASE + "TigerCatPaid/PNG/IdleCatt.png",
		"idle2": BASE + "TigerCatPaid/PNG/Idle2Catt.png",
		"sit": BASE + "TigerCatPaid/PNG/Sittingg.png",
		"sleep": BASE + "TigerCatPaid/PNG/SleepCatt.png",
		"run": BASE + "TigerCatPaid/PNG/RunCatt.png",
		"jump": BASE + "TigerCatPaid/PNG/JumpCattt.png",
		"hurt": BASE + "TigerCatPaid/PNG/HurtCattt.png"
	},
	{
		"id": 1,
		"name": "Mèo Vàng Thông Thái",
		"idle": BASE + "BrownCat/IdleCattt.png",
		"idle2": BASE + "BrownCat/Idle2Cattt.png",
		"sit": BASE + "BrownCat/Sittinggg.png",
		"sleep": BASE + "BrownCat/SleepCattt.png",
		"run": BASE + "BrownCat/RunCattt.png",
		"jump": BASE + "BrownCat/JumpCatttt.png",
		"hurt": BASE + "BrownCat/HurtCatttt.png"
	},
	{
		"id": 2,
		"name": "Mèo Tam Thể Xóm Trọ",
		"idle": BASE + "ThreeColorPaid/IdleCatt.png",
		"idle2": BASE + "ThreeColorPaid/Idle2Catt.png",
		"sit": BASE + "ThreeColorPaid/Sittingg.png",
		"sleep": BASE + "ThreeColorPaid/SleepCatt.png",
		"run": BASE + "ThreeColorPaid/RunCatt.png",
		"jump": BASE + "ThreeColorPaid/JumpCattt.png",
		"hurt": BASE + "ThreeColorPaid/HurtCattt.png"
	},
	{
		"id": 3,
		"name": "Mèo Đen Ninja",
		"idle": BASE + "BlackCat/PNG/IdleCatb.png",
		"idle2": BASE + "BlackCat/PNG/Idle2Catb.png",
		"sit": BASE + "BlackCat/PNG/Sittingb.png",
		"sleep": BASE + "BlackCat/PNG/SleepCatb.png",
		"run": BASE + "BlackCat/PNG/RunCatb.png",
		"jump": BASE + "BlackCat/PNG/JumpCabt.png",
		"hurt": BASE + "BlackCat/PNG/HurtCatb.png"
	},
	{
		"id": 4,
		"name": "Mèo Tuxedo Quý Tộc",
		"idle": BASE + "BatmanCatPaid/BlackMask/IdleCatt.png",
		"idle2": BASE + "BatmanCatPaid/BlackMask/IdleCatt.png",
		"sit": BASE + "BatmanCatPaid/BlackMask/Sittingg.png",
		"sleep": BASE + "BatmanCatPaid/BlackMask/SleepCatt.png",
		"run": BASE + "BatmanCatPaid/BlackMask/RunCatt.png",
		"jump": BASE + "BatmanCatPaid/BlackMask/JumpCattt.png",
		"hurt": BASE + "BatmanCatPaid/BlackMask/HurtCattt.png"
	},
	{
		"id": 5,
		"name": "Mèo Tuyết Trắng",
		"idle": BASE + "White-DifferentEyes/IdleCatttt.png",
		"idle2": BASE + "White-DifferentEyes/Idle2Catttt.png",
		"sit": BASE + "White-DifferentEyes/Sittingggg.png",
		"sleep": BASE + "White-DifferentEyes/SleepCatttt.png",
		"run": BASE + "White-DifferentEyes/RunCatttt.png",
		"jump": BASE + "White-DifferentEyes/JumpCattttt.png",
		"hurt": BASE + "White-DifferentEyes/HurtCattttt.png"
	},
	{
		"id": 6,
		"name": "Mèo Xiêm Khởi Nghiệp",
		"idle": BASE + "Siamese/PNG/IdleCattt.png",
		"idle2": BASE + "Siamese/PNG/Idle2Cattt.png",
		"sit": BASE + "Siamese/PNG/Sittinggg.png",
		"sleep": BASE + "Siamese/PNG/SleepCattt.png",
		"run": BASE + "Siamese/PNG/RunCattt.png",
		"jump": BASE + "Siamese/PNG/JumpCatttt.png",
		"hurt": BASE + "Siamese/PNG/HurtCatttt.png"
	},
	{
		"id": 7,
		"name": "Mèo Cổ Điển",
		"idle": BASE + "CatClassical/BlueCollar/IdleCat.png",
		"idle2": BASE + "CatClassical/BlueCollar/Idle2Cat.png",
		"sit": BASE + "CatClassical/BlueCollar/Sitting.png",
		"sleep": BASE + "CatClassical/BlueCollar/SleepCat.png",
		"run": BASE + "CatClassical/BlueCollar/RunCat.png",
		"jump": BASE + "CatClassical/BlueCollar/JumpCat.png",
		"hurt": BASE + "CatClassical/BlueCollar/HurtCat.png"
	}
]

func _init() -> void:
	print("\n--- BẮT ĐẦU TẠO ANIMATION & AVATAR CHO 8 GIỐNG MÈO ---")
	var av_dir = ProjectSettings.globalize_path("res://assets/sprites/avatars/")
	DirAccess.make_dir_recursive_absolute(av_dir)
	
	for b in BREEDS:
		var b_id = b["id"]
		var b_name = b["name"]
		print("\n* Xử lý giống mèo %d: %s" % [b_id, b_name])
		
		# 1. Trích xuất Avatar chân dung từ frame ngồi (Sitting) hoặc Idle
		_generate_avatar(b, av_dir)
		
	quit()

func _generate_avatar(b: Dictionary, av_dir: String) -> void:
	var path = b["sit"]
	var img = Image.new()
	var err = img.load(ProjectSettings.globalize_path(path))
	if err != OK:
		path = b["idle"]
		err = img.load(ProjectSettings.globalize_path(path))
		
	if err == OK:
		# Lấy frame 0 (kích thước 32x32)
		var frame0 = Image.create(32, 32, false, Image.FORMAT_RGBA8)
		frame0.blit_rect(img, Rect2i(0, 0, 32, 32), Vector2i.ZERO)
		
		# Tạo Avatar tròn viền kem pastel 48x48
		var av_size = 48
		var av_img = Image.create(av_size, av_size, false, Image.FORMAT_RGBA8)
		av_img.fill(Color(0, 0, 0, 0)) # Trong suốt
		
		var center = Vector2(av_size / 2.0, av_size / 2.0)
		var radius = (av_size / 2.0) - 2.0
		
		# Vẽ nền tròn ấm áp màu kem/pastel
		for y in range(av_size):
			for x in range(av_size):
				var dist = center.distance_to(Vector2(x, y))
				if dist <= radius:
					if dist > radius - 2.0:
						# Viền caramel
						av_img.set_pixel(x, y, Color(0.85, 0.65, 0.35, 1.0))
					elif dist > radius - 3.5:
						# Viền vàng ấm
						av_img.set_pixel(x, y, Color(1.0, 0.95, 0.85, 1.0))
					else:
						# Nền kem pastel mềm
						av_img.set_pixel(x, y, Color(0.98, 0.96, 0.92, 1.0))
						
		# Vẽ mèo 32x32 vào chính giữa avatar (tâm tại 8, 8)
		for fy in range(32):
			for fx in range(32):
				var px = frame0.get_pixel(fx, fy)
				if px.a > 0.1:
					var target_x = fx + 8
					var target_y = fy + 8
					if target_x < av_size and target_y < av_size:
						av_img.set_pixel(target_x, target_y, px)
						
		var out_unframed = av_dir + "avatar_%d.png" % b["id"]
		var out_framed = av_dir + "framed_avatar_%d.png" % b["id"]
		frame0.save_png(out_unframed)
		av_img.save_png(out_framed)
		print("  -> Đã lưu avatar_%d.png (32x32) & framed_avatar_%d.png (48x48 tròn viền kem)!" % [b["id"], b["id"]])
	else:
		print("  -> LỖI: Không tải được ảnh ngồi cho giống mèo:", b["name"])
