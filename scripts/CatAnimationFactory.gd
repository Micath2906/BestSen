class_name CatAnimationFactory
extends RefCounted

# CatAnimationFactory.gd - Quản lý nạp và cache SpriteFrames cho 8 giống mèo từ Assets chính thức
# Sử dụng Image.load_from_file và ImageTexture để hoạt động độc lập và mượt mà 100%
# Frame size chuẩn: 32x32 pixels
# Hỗ trợ 7 animation mượt mà: idle, idle2, sit, sleep, run, jump, hurt

const BASE = "res://assets/cats/CatMegaBundle/CatMegaBundle/LittleKitties/"

const BREED_DATA = [
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
	},
	{
		"id": 8,
		"name": "Mèo Mochi",
		"idle": "res://assets/cats/CatMegaBundle/CatMegaBundle/Mochi/Sprites/Classical/Individual/Idle.png",
		"idle2": "res://assets/cats/CatMegaBundle/CatMegaBundle/Mochi/Sprites/Classical/Individual/Idle2.png",
		"sit": "res://assets/cats/CatMegaBundle/CatMegaBundle/Mochi/Sprites/Classical/Individual/LayDown.png",
		"sleep": "res://assets/cats/CatMegaBundle/CatMegaBundle/Mochi/Sprites/Classical/Individual/Sleep.png",
		"run": "res://assets/cats/CatMegaBundle/CatMegaBundle/Mochi/Sprites/Classical/Individual/Excited.png",
		"jump": "res://assets/cats/CatMegaBundle/CatMegaBundle/Mochi/Sprites/Classical/Individual/Surprised.png",
		"hurt": "res://assets/cats/CatMegaBundle/CatMegaBundle/Mochi/Sprites/Classical/Individual/Cry.png"
	},
	{
		"id": 9,
		"name": "Mèo Pochi",
		"idle": "res://assets/cats/CatMegaBundle/CatMegaBundle/Pochi/Sprites/Idle.png",
		"idle2": "res://assets/cats/CatMegaBundle/CatMegaBundle/Pochi/Sprites/Happy.png",
		"sit": "res://assets/cats/CatMegaBundle/CatMegaBundle/Pochi/Sprites/Chilling.png",
		"sleep": "res://assets/cats/CatMegaBundle/CatMegaBundle/Pochi/Sprites/Sleeping.png",
		"run": "res://assets/cats/CatMegaBundle/CatMegaBundle/Pochi/Sprites/Running.png",
		"jump": "res://assets/cats/CatMegaBundle/CatMegaBundle/Pochi/Sprites/Jump.png",
		"hurt": "res://assets/cats/CatMegaBundle/CatMegaBundle/Pochi/Sprites/Hurt.png"
	}
]

static var _frames_cache: Dictionary = {}

static func get_sprite_frames(breed_id: int) -> SpriteFrames:
	if breed_id < 0 or breed_id >= BREED_DATA.size():
		breed_id = 0
		
	if _frames_cache.has(breed_id):
		return _frames_cache[breed_id]
		
	var data = BREED_DATA[breed_id]
	var sf = SpriteFrames.new()
	
	_add_anim_from_sheet(sf, "idle", data["idle"], 6.0, true)
	_add_anim_from_sheet(sf, "idle2", data["idle2"], 7.0, true)
	_add_anim_from_sheet(sf, "sit", data["sit"], 4.0, true)
	_add_anim_from_sheet(sf, "sleep", data["sleep"], 3.0, true)
	_add_anim_from_sheet(sf, "run", data["run"], 10.0, true)
	_add_anim_from_sheet(sf, "jump", data["jump"], 12.0, false)
	_add_anim_from_sheet(sf, "hurt", data["hurt"], 8.0, false)
	
	# Các animation chuẩn ToffeeCraft Cat Pack theo yêu cầu:
	# 1. idle_blink: Mèo thở nhẹ nhàng và chớp mắt
	_add_anim_from_sheet(sf, "idle_blink", data["idle"], 5.0, true)
	
	# 2. tail_wag: Vẫy đuôi tít mù (7 frame đầu của idle2 / sitting)
	_add_anim_sub_sheet(sf, "tail_wag", data["idle2"], 0, 7, 6.0, true)
	
	# 3. lick_paw: Nâng chân liếm vuốt chuốt lông (7 frame sau của idle2)
	_add_anim_sub_sheet(sf, "lick_paw", data["idle2"], 7, 7, 6.0, true)
	
	# 4. sleep_in_box: Nằm ngủ ấm áp cuộn tròn trong hộp carton
	var box_path = "res://assets/cats/CatMegaBundle/CatMegaBundle/Mochi/Sprites/Classical/Individual/Box1.png"
	_add_anim_from_sheet(sf, "sleep_in_box", box_path, 3.5, true)
	
	# Alias các animation tương thích ngược với hệ thống phòng 2.5D Isometric
	_copy_anim(sf, "run", "walk")
	_copy_anim(sf, "run", "walk_dr")
	_copy_anim(sf, "run", "walk_dl")
	_copy_anim(sf, "run", "walk_ur")
	_copy_anim(sf, "run", "walk_ul")
	_copy_anim(sf, "run", "walk_down")
	_copy_anim(sf, "run", "walk_up")
	_copy_anim(sf, "run", "walk_right")
	_copy_anim(sf, "run", "walk_left")
	
	_copy_anim(sf, "idle_blink", "idle_left")
	_copy_anim(sf, "lick_paw", "eat")
	_copy_anim(sf, "lick_paw", "drink")
	_copy_anim(sf, "lick_paw", "wash")
	_copy_anim(sf, "jump", "scratch")
	_copy_anim(sf, "jump", "paw_toy")
	_copy_anim(sf, "jump", "celebrate")
	_copy_anim(sf, "hurt", "faint")
	_copy_anim(sf, "tail_wag", "meow")
	
	_frames_cache[breed_id] = sf
	return sf

static func _copy_anim(sf: SpriteFrames, src_name: String, target_name: String) -> void:
	if not sf.has_animation(src_name):
		return
	if sf.has_animation(target_name):
		sf.remove_animation(target_name)
	sf.add_animation(target_name)
	sf.set_animation_speed(target_name, sf.get_animation_speed(src_name))
	sf.set_animation_loop(target_name, sf.get_animation_loop(src_name))
	var count = sf.get_frame_count(src_name)
	for i in range(count):
		sf.add_frame(target_name, sf.get_frame_texture(src_name, i))

static func _add_anim_from_sheet(sf: SpriteFrames, anim_name: String, path: String, speed: float, loop: bool) -> void:
	if sf.has_animation(anim_name):
		sf.remove_animation(anim_name)
	sf.add_animation(anim_name)
	sf.set_animation_speed(anim_name, speed)
	sf.set_animation_loop(anim_name, loop)
	
	var global_path = ProjectSettings.globalize_path(path)
	var img = Image.new()
	var err = img.load(global_path)
	if err != OK:
		return
		
	var w = img.get_width()
	var h = img.get_height()
	var frame_size = h
	if frame_size <= 0:
		frame_size = 32
	var frame_count = w / frame_size
	if frame_count <= 0:
		frame_count = 1
		
	var tex = ImageTexture.create_from_image(img)
	for i in range(frame_count):
		var atlas = AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2(i * frame_size, 0, frame_size, frame_size)
		sf.add_frame(anim_name, atlas)

static func _add_anim_sub_sheet(sf: SpriteFrames, anim_name: String, path: String, start_frame: int, count: int, speed: float, loop: bool) -> void:
	if sf.has_animation(anim_name):
		sf.remove_animation(anim_name)
	sf.add_animation(anim_name)
	sf.set_animation_speed(anim_name, speed)
	sf.set_animation_loop(anim_name, loop)
	
	var global_path = ProjectSettings.globalize_path(path)
	var img = Image.new()
	var err = img.load(global_path)
	if err != OK:
		return
		
	var w = img.get_width()
	var h = img.get_height()
	var frame_size = h
	if frame_size <= 0:
		frame_size = 32
	var total_frames = w / frame_size
	if total_frames <= 0:
		total_frames = 1
		
	var tex = ImageTexture.create_from_image(img)
	var actual_count = min(count, total_frames - start_frame)
	if actual_count <= 0:
		actual_count = total_frames
		start_frame = 0
		
	for i in range(actual_count):
		var atlas = AtlasTexture.new()
		atlas.atlas = tex
		atlas.region = Rect2((start_frame + i) * frame_size, 0, frame_size, frame_size)
		sf.add_frame(anim_name, atlas)
