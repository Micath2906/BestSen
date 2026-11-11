extends Control

# MainMenu.gd - Điều phối màn hình Menu chính, Cài đặt, Thông tin và Chọn Mèo Khởi Tạo
# Luồng game: Mới vô là Main Menu (Play, Setting, Info) -> Play mở Chọn loài mèo, Đặt tên,... -> Vào Game (Main.tscn)

signal start_game_requested(cat_name, breed_id, room_name)

const CatAnimationFactory = preload("res://scripts/CatAnimationFactory.gd")

# Views & Modals
@onready var home_view: Control = $HomeView
@onready var cat_creation_view: Control = $CatCreationView
@onready var setting_modal: Control = $SettingModal
@onready var info_modal: Control = $InfoModal
@onready var confirm_reset_modal: Control = $ConfirmResetModal

# HomeView Elements
@onready var btn_play: Button = $HomeView/CenterVBox/ButtonsCard/VBox/BtnPlay
@onready var btn_continue: Button = $HomeView/CenterVBox/ButtonsCard/VBox.get_node_or_null("BtnContinue")
@onready var btn_setting: Button = $HomeView/CenterVBox/ButtonsCard/VBox/BtnSetting
@onready var btn_exit: Button = $HomeView/CenterVBox/ButtonsCard/VBox.get_node_or_null("BtnExit")
@onready var btn_info: Button = $HomeView/CenterVBox/ButtonsCard/VBox.get_node_or_null("BtnInfo")

# CatCreationView Elements
@onready var btn_back_from_creation: Button = $CatCreationView/Header/BtnBackMenu
@onready var btn_prev_breed: Button = $CatCreationView/Scroll/VBox/BreedBox/VBox/HBox/BtnPrevBreed
@onready var btn_next_breed: Button = $CatCreationView/Scroll/VBox/BreedBox/VBox/HBox/BtnNextBreed
@onready var breed_avatar: TextureRect = $CatCreationView/Scroll/VBox/BreedBox/VBox/HBox/AvatarCard/AvatarTex
@onready var breed_name_label: Label = $CatCreationView/Scroll/VBox/BreedBox/VBox/BreedNameLabel
@onready var breed_trait_label: Label = $CatCreationView/Scroll/VBox/BreedBox/VBox/TraitLabel
@onready var breed_desc_label: Label = $CatCreationView/Scroll/VBox/BreedBox/VBox/DescBox/DescLabel
@onready var edit_cat_name: LineEdit = $CatCreationView/Scroll/VBox/CatNameBox/VBox/HBox/EditCatName
@onready var btn_random_cat_name: Button = $CatCreationView/Scroll/VBox/CatNameBox/VBox/HBox/BtnRandomCatName
@onready var edit_room_name: LineEdit = $CatCreationView/Scroll/VBox/RoomNameBox/VBox/HBox/EditRoomName
@onready var btn_random_room_name: Button = $CatCreationView/Scroll/VBox/RoomNameBox/VBox/HBox/BtnRandomRoomName
@onready var edit_owner_name: LineEdit = $CatCreationView/Scroll/VBox/OwnerNameBox/VBox/EditOwnerName
@onready var btn_start_game: Button = $CatCreationView/Scroll/VBox/BtnStartGame

var mascot_anim_sprite: AnimatedSprite2D = null
var creation_anim_sprite: AnimatedSprite2D = null

# SettingModal Elements
@onready var slider_sfx: HSlider = $SettingModal/Panel/VBox/SFXBox/HBox/SliderSFX
@onready var lbl_sfx_val: Label = $SettingModal/Panel/VBox/SFXBox/HBox/LblSFXVal
@onready var btn_test_sfx: Button = $SettingModal/Panel/VBox/SFXBox/HBox/BtnTestSFX
@onready var slider_bgm: HSlider = $SettingModal/Panel/VBox/BGMBox/HBox/SliderBGM
@onready var lbl_bgm_val: Label = $SettingModal/Panel/VBox/BGMBox/HBox/LblBGMVal
@onready var check_haptic: CheckBox = $SettingModal/Panel/VBox/CheckHaptic
@onready var btn_reset_data: Button = $SettingModal/Panel/VBox/BtnResetData
@onready var btn_close_setting: Button = $SettingModal/Panel/VBox/BtnCloseSetting

# InfoModal Elements
@onready var btn_close_info: Button = $InfoModal/Panel/VBox/BtnCloseInfo

# Reset Confirmation
@onready var btn_confirm_reset: Button = $ConfirmResetModal/Panel/VBox/HBox/BtnConfirmYes
@onready var btn_cancel_reset: Button = $ConfirmResetModal/Panel/VBox/HBox/BtnConfirmNo

# Danh sách tên mèo ngẫu nhiên đậm chất sinh viên
const RANDOM_CAT_NAMES = [
	"Bánh Bao", "Mướp Béo", "Đậu Phộng", "Cà Phê", "Mochi", "Bơ Béo",
	"Hảo Hảo", "Cơm Tấm", "Nem Chua", "Trà Đào", "Xíu Mại", "Bánh Tiêu",
	"Hột Vịt", "Bắp Rang", "Khoai Môn", "Súp Lơ", "Su Kem", "Gạo Lứt",
	"Ba Gác", "Bé Bự", "Tiểu Hắc", "Bông Gòn", "Pate Cưng", "Lạc Lạc"
]

const RANDOM_ROOM_NAMES = [
	"Xóm Trọ Bình Yên", "Phòng Trọ Hạnh Phúc", "Góc Nhỏ Của Boss",
	"Căn Hộ Gác Lửng", "Ký Túc Xá Vui Nhộn", "Lâu Đài Boss Cào",
	"Tổ Ấm Sen & Boss", "Trọ Nghèo Nhưng Sang", "Trạm Dừng Thanh Xuân"
]

const SPEECH_QUOTES = [
	"Chào Sen! Sẵn sàng lên phố tự lập chưa meo? 🐾",
	"Hôm nay ăn hạt hay ăn pate đây Sen ơi? 🐟",
	"Tự lập không khó, có Boss ở đây rồi meow! ✨",
	"Nhớ đi đúng tuyến xe buýt kẻo lạc nha Sen! 🚌",
	"Đừng quẹt thẻ trả sau kẻo ăn mì 7 ngày nha! 💳"
]

var current_breed_idx: int = 0
var mascot_quote_idx: int = 0
var avatar_textures: Array = []

func _ready() -> void:
	# Load danh sách ảnh avatar
	for i in range(10):
		var tex = GameManager.load_texture("res://assets/sprites/avatars/framed_avatar_%d.png" % i)
		avatar_textures.append(tex)
		
	# Khởi tạo trạng thái ban đầu
	current_breed_idx = GameManager.selected_avatar_id
	_setup_home_view()
	_setup_creation_view()
	_setup_setting_modal()
	_setup_info_modal()
	
	# Mở HomeView mặc định, ẩn các modal
	home_view.visible = true
	cat_creation_view.visible = false
	setting_modal.visible = false
	info_modal.visible = false
	confirm_reset_modal.visible = false

# --- HOME VIEW SETUP & EVENTS ---
func _setup_home_view() -> void:
	# Nút Play: Nếu đã có nhân vật mèo thì vào thẳng phòng, nếu mới chơi thì mở màn hình khởi tạo (Tắt âm thanh khi ấn chơi ngay)
	btn_play.pressed.connect(func():
		if GameManager.has_completed_onboarding:
			_go_to_game_scene()
		else:
			_open_cat_creation()
	)
	
	if btn_continue:
		btn_continue.visible = false
		
	btn_setting.pressed.connect(func():
		SoundManager.play_click()
		_open_setting_modal()
	)
	
	if btn_exit:
		btn_exit.pressed.connect(func():
			SoundManager.play_click()
			get_tree().quit()
		)
		
	if btn_info:
		btn_info.pressed.connect(func():
			SoundManager.play_click()
			_open_info_modal()
		)

func _update_home_mascot() -> void:
	pass

func _cycle_mascot_quote() -> void:
	pass

func _animate_mascot_bounce() -> void:
	pass

# --- CAT CREATION VIEW (CHỌN LOÀI MÈO & ĐẶT TÊN) ---
func _setup_creation_view() -> void:
	var avatar_card = $CatCreationView/Scroll/VBox/BreedBox/VBox/HBox/AvatarCard
	if creation_anim_sprite == null:
		creation_anim_sprite = AnimatedSprite2D.new()
		creation_anim_sprite.name = "CreationAnimSprite"
		creation_anim_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		creation_anim_sprite.position = Vector2(65, 72)
		creation_anim_sprite.scale = Vector2(3.8, 3.8)
		avatar_card.add_child(creation_anim_sprite)
		breed_avatar.self_modulate.a = 0.0

	btn_back_from_creation.pressed.connect(func():
		SoundManager.play_click()
		cat_creation_view.visible = false
		home_view.visible = true
	)
	
	btn_prev_breed.pressed.connect(func():
		SoundManager.play_card_pop()
		current_breed_idx = (current_breed_idx - 1 + GameManager.avatar_list.size()) % GameManager.avatar_list.size()
		_update_breed_display()
	)
	
	btn_next_breed.pressed.connect(func():
		SoundManager.play_card_pop()
		current_breed_idx = (current_breed_idx + 1) % GameManager.avatar_list.size()
		_update_breed_display()
	)
	
	btn_random_cat_name.pressed.connect(func():
		SoundManager.play_click()
		var rand_name = RANDOM_CAT_NAMES[randi() % RANDOM_CAT_NAMES.size()]
		edit_cat_name.text = rand_name
		if edit_room_name.text == "" or edit_room_name.text.begins_with("Phòng của "):
			edit_room_name.text = "Phòng của %s" % rand_name
	)
	
	btn_random_room_name.pressed.connect(func():
		SoundManager.play_click()
		var rand_room = RANDOM_ROOM_NAMES[randi() % RANDOM_ROOM_NAMES.size()]
		edit_room_name.text = rand_room
	)
	
	edit_cat_name.text_changed.connect(func(new_text):
		if edit_room_name.text == "" or edit_room_name.text.begins_with("Phòng của "):
			var boss_name = new_text.strip_edges()
			if boss_name != "":
				edit_room_name.text = "Phòng của %s" % boss_name
	)
	
	btn_start_game.pressed.connect(_on_confirm_start_game)

func _open_cat_creation() -> void:
	# Điền trước dữ liệu đã có hoặc mặc định
	current_breed_idx = GameManager.selected_avatar_id
	var current_name = GameManager.custom_cat_name
	if current_name == "":
		current_name = GameManager.avatar_list[current_breed_idx]["name"]
	edit_cat_name.text = current_name
	
	var current_room = GameManager.custom_room_name
	if current_room == "":
		current_room = "Phòng của %s" % current_name
	edit_room_name.text = current_room
	
	edit_owner_name.text = GameManager.get_owner_name()
	
	_update_breed_display()
	
	home_view.visible = false
	cat_creation_view.visible = true
	SoundManager.play_meow(1.15)

func _update_breed_display() -> void:
	if creation_anim_sprite:
		creation_anim_sprite.sprite_frames = CatAnimationFactory.get_sprite_frames(current_breed_idx)
		creation_anim_sprite.play("idle2")
		var card = $CatCreationView/Scroll/VBox/BreedBox/VBox/HBox/AvatarCard
		card.pivot_offset = card.size * 0.5
		var tw = create_tween()
		card.scale = Vector2(0.92, 0.92)
		tw.tween_property(card, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	elif current_breed_idx >= 0 and current_breed_idx < avatar_textures.size():
		breed_avatar.texture = avatar_textures[current_breed_idx]
	
	var av_data = GameManager.avatar_list[current_breed_idx]
	breed_name_label.text = "🐾 %s (%d/%d)" % [av_data["name"], current_breed_idx + 1, GameManager.avatar_list.size()]
	
	# Mô tả tính cách đặc trưng của từng giống loài
	match current_breed_idx:
		0: # Mèo Mướp Cam
			breed_trait_label.text = "⚡ Năng động • Háu ăn • Thích khám phá"
			breed_desc_label.text = "Biểu tượng của sự tháo vát và tinh nghịch. Luôn tràn trề năng lượng cho các chuyến xe buýt khám phá thành phố!"
		1: # Mèo Vàng Thông Thái
			breed_trait_label.text = "🎓 Chăm chỉ • Giỏi chi tiêu • Thích đọc sách"
			breed_desc_label.text = "Tay hòm chìa khóa đại tài. Nhớ như in bí kíp chia 6 chiếc lọ tài chính và săn sale không bao giờ hớ!"
		2: # Mèo Tam Thể Xóm Trọ
			breed_trait_label.text = "🏘️ Thổ địa ngõ hẻm • Thân thiện • Khéo léo"
			breed_desc_label.text = "Quen mặt khắp cả khu trọ sinh viên, biết hết quán ăn ngon bổ rẻ và luôn có bác chủ trọ thương mến!"
		3: # Mèo Xám Tro
			breed_trait_label.text = "🛡️ Cẩn thận • Trầm tĩnh • Kỷ luật cao"
			breed_desc_label.text = "Không bao giờ quên khóa cửa phòng trọ, soi hợp đồng thuê phòng kỹ lưỡng từng con số và dấu chấm câu!"
		4: # Mèo Tuxedo Quý Tộc
			breed_trait_label.text = "🎩 Đĩnh đạc • Tự tin • Giao tiếp xuất sắc"
			breed_desc_label.text = "Bộ vest lông đen trắng phong độ. Tự tin bước vào mọi vòng phỏng vấn part-time mà không chút rụt rè!"
		5: # Mèo Tuyết Trắng
			breed_trait_label.text = "❄️ Ngây thơ • Đáng yêu • Lan tỏa năng lượng"
			breed_desc_label.text = "Bé ngoan xóm trọ được mọi người cưng chiều, có tài xoa dịu stress sau những kỳ thi học phần căng thẳng!"
		6: # Mèo Đen Ninja
			breed_trait_label.text = "🥷 Nhanh nhẹn • Phản xạ cao • Không ngại khó"
			breed_desc_label.text = "Bắt xe buýt chen chúc giờ cao điểm thoăn thoắt, xử lý tình huống khẩn cấp nhanh như chớp!"
		7: # Mèo Xiêm Khởi Nghiệp
			breed_trait_label.text = "💼 Tự lập sớm • Ý chí cao • Tháo vát"
			breed_desc_label.text = "Bản lĩnh tân sinh viên thế hệ mới, tự kiếm cá khô đàng hoàng và xây dựng góc nhỏ ấm cúng của riêng mình!"
		8: # Mèo Mochi
			breed_trait_label.text = "🎀 Điệu đà • Mắt 2 màu • Ngọt ngào"
			breed_desc_label.text = "Bạch miêu quý phái với nơ hồng đáng yêu, luôn mang lại niềm vui và bình yên cho góc phòng trọ nhỏ."
		9: # Mèo Pochi
			breed_trait_label.text = "🌟 Lạc quan • Nhanh trí • Bạn đồng hành số 1"
			breed_desc_label.text = "Chú mèo vàng tích cực, không bao giờ nản chí trước khó khăn đầu đời sinh viên, luôn sát cánh cùng Sen!"

func _on_confirm_start_game() -> void:
	# Tắt âm thanh khi ấn chơi ngay
	
	# Lưu cấu hình vào GameManager
	var final_cat_name = edit_cat_name.text.strip_edges()
	if final_cat_name == "":
		final_cat_name = GameManager.avatar_list[current_breed_idx]["name"]
		
	var final_room_name = edit_room_name.text.strip_edges()
	if final_room_name == "":
		final_room_name = "Phòng của %s" % final_cat_name
		
	var final_owner_name = edit_owner_name.text.strip_edges()
	if final_owner_name == "":
		final_owner_name = "Tân Sinh Viên"
		
	GameManager.selected_avatar_id = current_breed_idx
	GameManager.set_cat_name(final_cat_name)
	GameManager.set_room_name(final_room_name)
	GameManager.set_owner_name(final_owner_name)
	GameManager.has_completed_onboarding = true
	GameManager.save_game()
	
	if start_game_requested.get_connections().size() > 0:
		emit_signal("start_game_requested", final_cat_name, current_breed_idx, final_room_name)
	else:
		_go_to_game_scene()

func _go_to_game_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

# --- SETTING MODAL ---
func _setup_setting_modal() -> void:
	var bgm_icon = $SettingModal.get_node_or_null("Panel/VBox/BGMBox/BGMHeader/BGMIcon")
	if bgm_icon:
		bgm_icon.texture = GameManager.load_texture("res://assets/UI/CatUIPaid/slices/icon_music.png")
	
	slider_sfx.value = SoundManager.sfx_volume * 100.0
	lbl_sfx_val.text = "%d%%" % int(slider_sfx.value)
	slider_sfx.value_changed.connect(func(val):
		SoundManager.set_sfx_volume(val / 100.0)
		lbl_sfx_val.text = "%d%%" % int(val)
	)
	
	btn_test_sfx.pressed.connect(func():
		SoundManager.play_meow(1.1)
	)
	
	slider_bgm.value = SoundManager.bgm_volume * 100.0
	lbl_bgm_val.text = "%d%%" % int(slider_bgm.value)
	slider_bgm.value_changed.connect(func(val):
		SoundManager.set_bgm_volume(val / 100.0)
		lbl_bgm_val.text = "%d%%" % int(val)
	)
	
	check_haptic.button_pressed = SoundManager.haptic_enabled
	check_haptic.toggled.connect(func(pressed):
		SoundManager.set_haptic_enabled(pressed)
		if pressed:
			SoundManager.vibrate(50)
	)
	
	btn_reset_data.pressed.connect(func():
		SoundManager.play_fail()
		confirm_reset_modal.visible = true
	)
	
	btn_close_setting.pressed.connect(func():
		SoundManager.play_click()
		setting_modal.visible = false
	)
	
	btn_cancel_reset.pressed.connect(func():
		SoundManager.play_click()
		confirm_reset_modal.visible = false
	)
	
	btn_confirm_reset.pressed.connect(func():
		SoundManager.play_click()
		GameManager.reset_save_data()
		confirm_reset_modal.visible = false
		setting_modal.visible = false
		_setup_home_view()
		GameManager.emit_signal("show_toast", "Đã đặt lại dữ liệu! Sẵn sàng tạo mèo mới! 🐾")
	)

func _open_setting_modal() -> void:
	setting_modal.visible = true
	var p = $SettingModal/Panel
	p.scale = Vector2(0.9, 0.9)
	var tw = create_tween()
	tw.tween_property(p, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK)

func _close_setting_modal() -> void:
	setting_modal.visible = false

# --- INFO MODAL ---
func _setup_info_modal() -> void:
	btn_close_info.pressed.connect(func():
		SoundManager.play_click()
		info_modal.visible = false
	)

func _open_info_modal() -> void:
	info_modal.visible = true
	var p = $InfoModal/Panel
	p.scale = Vector2(0.9, 0.9)
	var tw = create_tween()
	tw.tween_property(p, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK)
