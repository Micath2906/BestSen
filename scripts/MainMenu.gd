extends Control

# MainMenu.gd - Điều phối màn hình Menu chính, Cài đặt, Thông tin và Chọn Mèo Khởi Tạo
# Luồng game: Mới vô là Main Menu (Play, Setting, Info) -> Play mở Chọn loài mèo, Đặt tên,... -> Vào Game (Main.tscn)

signal start_game_requested(cat_name, breed_id, room_name)

const CatAnimationFactory = preload("res://scripts/CatAnimationFactory.gd")
const JuicyButton = preload("res://scripts/ui/JuicyButton.gd")
const MAIN_THEME = preload("res://assets/themes/MainTheme.tres")
const TEX_PARCHMENT_SCROLL = preload("res://assets/UI/CatUIPaid/slices/cozy_achievements/parchment_scroll_cert_9patch.tres")
const TEX_WAX_SEAL = preload("res://assets/UI/CatUIPaid/slices/cozy_achievements/wax_seal_royal_gold.tres")
const RANDOM_OWNER_NAMES = [
	"Sen Minh", "Sen Thảo", "Sen An", "Sen Linh", "Sen Khoa", "Sen Vy", "Sen Nam"
]

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
	"Trọ Nắng Ấm", "Gác Nhỏ Mochi", "Xóm Trọ Bình Yên", "Phòng Trọ Hạnh Phúc",
	"Góc Nhỏ Của Boss", "Căn Hộ Gác Lửng", "Tổ Ấm Sen & Mochi", "Trạm Dừng Thanh Xuân"
]

const SPEECH_QUOTES = [
	"Chào Sen! Sẵn sàng lên phố tự lập chưa meo? 🐾",
	"Hôm nay ăn hạt hay ăn pate đây Sen ơi? 🐟",
	"Tự lập không khó, có Boss ở đây rồi meow! ✨",
	"Nhớ đi đúng tuyến xe buýt kẻo lạc nha Sen! 🚌",
	"Đừng quẹt thẻ trả sau kẻo ăn mì 7 ngày nha! 💳"
]

var current_breed_idx: int = 8
var mascot_quote_idx: int = 0
var avatar_textures: Array = []

# Onboarding Diegetic UI refs
var mochi_bubble_panel: PanelContainer = null
var mochi_bubble_label: Label = null
var btn_random_owner_name: Button = null
var wax_seal_stamp_rect: TextureRect = null
var wax_glow_tween: Tween = null
var fade_curtain: ColorRect = null
var _is_stamping: bool = false

func _ready() -> void:
	theme = MAIN_THEME
	# Load danh sách ảnh avatar
	for i in range(10):
		var tex = GameManager.load_texture("res://assets/sprites/avatars/framed_avatar_%d.png" % i)
		avatar_textures.append(tex)
		
	# Mặc định tập trung vào Mochi (idx = 8) cho màn onboarding mới
	current_breed_idx = GameManager.selected_avatar_id if GameManager.has_completed_onboarding else 8
	_setup_home_view()
	_setup_creation_view()
	_setup_setting_modal()
	_setup_info_modal()
	_setup_fade_curtain()
	
	# Mở HomeView mặc định, ẩn các modal
	home_view.visible = true
	cat_creation_view.visible = false
	setting_modal.visible = false
	info_modal.visible = false
	confirm_reset_modal.visible = false

func _setup_fade_curtain() -> void:
	fade_curtain = ColorRect.new()
	fade_curtain.name = "FadeCurtain"
	fade_curtain.color = Color("#3E2723")
	fade_curtain.modulate.a = 0.0
	fade_curtain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_curtain.z_index = 120
	fade_curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fade_curtain)

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
	for b in [btn_play, btn_setting, btn_exit, btn_info]:
		if b:
			JuicyButton.attach_juice(b, true)

func _update_home_mascot() -> void:
	pass

func _cycle_mascot_quote() -> void:
	pass

func _animate_mascot_bounce() -> void:
	pass

# --- CAT CREATION VIEW (HỢP ĐỒNG THUÊ TRỌ & NHẬN NUÔI MOCHI - DIEGETIC ONBOARDING) ---
func _setup_creation_view() -> void:
	# 1. Nền bàn gỗ ấm + tờ hợp đồng giấy da 9-patch parchment_scroll_cert_9patch
	var wood_bg := ColorRect.new()
	wood_bg.name = "WoodDeskBackdrop"
	wood_bg.color = Color("#5C3A21")
	wood_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wood_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cat_creation_view.add_child(wood_bg)
	cat_creation_view.move_child(wood_bg, 0)

	var scroll_ctrl := cat_creation_view.get_node_or_null("Scroll") as ScrollContainer
	if scroll_ctrl and TEX_PARCHMENT_SCROLL:
		var sheet_sb := StyleBoxTexture.new()
		sheet_sb.texture = TEX_PARCHMENT_SCROLL
		sheet_sb.texture_margin_left = 18.0
		sheet_sb.texture_margin_top = 18.0
		sheet_sb.texture_margin_right = 18.0
		sheet_sb.texture_margin_bottom = 18.0
		sheet_sb.content_margin_left = 14.0
		sheet_sb.content_margin_top = 14.0
		sheet_sb.content_margin_right = 14.0
		sheet_sb.content_margin_bottom = 14.0
		scroll_ctrl.add_theme_stylebox_override("panel", sheet_sb)

	var header_title := cat_creation_view.get_node_or_null("Header/Title") as Label
	if header_title:
		header_title.text = "📜 HỢP ĐỒNG THUÊ TRỌ & NHẬN NUÔI MOCHI"

	# Ẩn mũi tên đổi giống khi tập trung vào Mochi (vẫn giữ node trong scene tree)
	if btn_prev_breed:
		btn_prev_breed.visible = false
	if btn_next_breed:
		btn_next_breed.visible = false

	# 2. Mochi sống động bên góc tờ hợp đồng + tương tác chạm nói "Meow! Sen tên gì thế?"
	var avatar_card := $CatCreationView/Scroll/VBox/BreedBox/VBox/HBox/AvatarCard
	if creation_anim_sprite == null:
		creation_anim_sprite = AnimatedSprite2D.new()
		creation_anim_sprite.name = "CreationAnimSprite"
		creation_anim_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		creation_anim_sprite.position = Vector2(65, 72)
		creation_anim_sprite.scale = Vector2(3.8, 3.8)
		avatar_card.add_child(creation_anim_sprite)
		breed_avatar.self_modulate.a = 0.0

	avatar_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	avatar_card.gui_input.connect(func(ev: InputEvent):
		var touched: bool = (ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT) or (ev is InputEventScreenTouch and ev.pressed)
		if touched:
			_on_mochi_onboarding_tapped()
	)

	var breed_vbox := $CatCreationView/Scroll/VBox/BreedBox/VBox
	mochi_bubble_panel = PanelContainer.new()
	mochi_bubble_panel.name = "MochiSpeechBubble"
	var bub_sb := StyleBoxFlat.new()
	bub_sb.bg_color = Color("#FDF6E3")
	bub_sb.border_color = Color("#6D4C41")
	bub_sb.set_border_width_all(2)
	bub_sb.set_corner_radius_all(10)
	bub_sb.content_margin_left = 10
	bub_sb.content_margin_right = 10
	bub_sb.content_margin_top = 6
	bub_sb.content_margin_bottom = 6
	mochi_bubble_panel.add_theme_stylebox_override("panel", bub_sb)

	mochi_bubble_label = Label.new()
	mochi_bubble_label.name = "MochiBubbleLabel"
	mochi_bubble_label.text = "Meow! Sen tên gì thế? Chạm vào Mochi điền hợp đồng nha! 🐾"
	mochi_bubble_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mochi_bubble_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mochi_bubble_label.add_theme_color_override("font_color", Color("#3E2723"))
	mochi_bubble_label.add_theme_font_size_override("font_size", 13)
	mochi_bubble_panel.add_child(mochi_bubble_label)
	breed_vbox.add_child(mochi_bubble_panel)
	breed_vbox.move_child(mochi_bubble_panel, 0)

	# 3. Ô nhập kiểu dòng kẻ trên giấy + nút xúc xắc ngẫu nhiên cho cả Sen & Phòng Trọ
	var paper_line_sb := StyleBoxFlat.new()
	paper_line_sb.bg_color = Color(0.992, 0.965, 0.890, 0.55)
	paper_line_sb.border_color = Color("#6D4C41")
	paper_line_sb.border_width_bottom = 2
	paper_line_sb.content_margin_left = 8
	paper_line_sb.content_margin_right = 8
	paper_line_sb.content_margin_top = 6
	paper_line_sb.content_margin_bottom = 6
	for le in [edit_cat_name, edit_room_name, edit_owner_name]:
		if le:
			le.add_theme_stylebox_override("normal", paper_line_sb)
			le.add_theme_color_override("font_color", Color("#3E2723"))

	var owner_vbox := $CatCreationView/Scroll/VBox/OwnerNameBox/VBox
	if owner_vbox and edit_owner_name and btn_random_owner_name == null:
		var owner_row := HBoxContainer.new()
		owner_row.name = "OwnerInputHBox"
		owner_row.add_theme_constant_override("separation", 6)
		var idx_edit := edit_owner_name.get_index()
		owner_vbox.remove_child(edit_owner_name)
		edit_owner_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		owner_row.add_child(edit_owner_name)

		btn_random_owner_name = Button.new()
		btn_random_owner_name.name = "BtnRandomOwnerName"
		btn_random_owner_name.text = "🎲"
		btn_random_owner_name.custom_minimum_size = Vector2(46, 42)
		btn_random_owner_name.tooltip_text = "Gợi ý tên Sen dễ thương"
		JuicyButton.attach_juice(btn_random_owner_name, true)
		btn_random_owner_name.pressed.connect(func():
			edit_owner_name.text = RANDOM_OWNER_NAMES[randi() % RANDOM_OWNER_NAMES.size()]
			_update_wax_seal_glow()
		)
		owner_row.add_child(btn_random_owner_name)
		owner_vbox.add_child(owner_row)
		owner_vbox.move_child(owner_row, idx_edit)

	if btn_random_cat_name:
		btn_random_cat_name.text = "🎲"
		JuicyButton.attach_juice(btn_random_cat_name, true)
	if btn_random_room_name:
		btn_random_room_name.text = "🎲"
		JuicyButton.attach_juice(btn_random_room_name, true)

	btn_back_from_creation.pressed.connect(func():
		SoundManager.play_click()
		cat_creation_view.visible = false
		home_view.visible = true
	)
	
	btn_random_cat_name.pressed.connect(func():
		var rand_name = RANDOM_CAT_NAMES[randi() % RANDOM_CAT_NAMES.size()]
		edit_cat_name.text = rand_name
		if edit_room_name.text == "" or edit_room_name.text.begins_with("Phòng của "):
			edit_room_name.text = "Gác Nhỏ %s" % rand_name
		_update_wax_seal_glow()
	)
	
	btn_random_room_name.pressed.connect(func():
		var rand_room = RANDOM_ROOM_NAMES[randi() % RANDOM_ROOM_NAMES.size()]
		edit_room_name.text = rand_room
		_update_wax_seal_glow()
	)
	
	edit_cat_name.text_changed.connect(func(new_text):
		if edit_room_name.text == "" or edit_room_name.text.begins_with("Phòng của "):
			var boss_name = new_text.strip_edges()
			if boss_name != "":
				edit_room_name.text = "Gác Nhỏ %s" % boss_name
		_update_wax_seal_glow()
	)
	edit_room_name.text_changed.connect(func(_t): _update_wax_seal_glow())
	edit_owner_name.text_changed.connect(func(_t): _update_wax_seal_glow())

	# 4. Biến nút xác nhận thành Con Dấu Sáp Vàng Xúc Giác (Tactile Wax Seal Stamp)
	if btn_start_game:
		btn_start_game.custom_minimum_size = Vector2(0, 64)
		btn_start_game.text = "ĐÓNG DẤU XÁC NHẬN & NHẬN CHÌA KHÓA"
		btn_start_game.icon = TEX_WAX_SEAL
		btn_start_game.expand_icon = true
		wax_seal_stamp_rect = TextureRect.new()
		wax_seal_stamp_rect.name = "WaxSealStampOverlay"
		wax_seal_stamp_rect.texture = TEX_WAX_SEAL
		wax_seal_stamp_rect.custom_minimum_size = Vector2(46, 46)
		wax_seal_stamp_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		wax_seal_stamp_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		wax_seal_stamp_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wax_seal_stamp_rect.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
		wax_seal_stamp_rect.offset_left = -56
		wax_seal_stamp_rect.offset_right = -10
		wax_seal_stamp_rect.offset_top = -23
		wax_seal_stamp_rect.offset_bottom = 23
		wax_seal_stamp_rect.pivot_offset = Vector2(23, 23)
		btn_start_game.add_child(wax_seal_stamp_rect)
		btn_start_game.pressed.connect(_on_wax_seal_stamp_pressed)

func _on_mochi_onboarding_tapped() -> void:
	SoundManager.play_meow(1.22)
	if SoundManager.has_method("vibrate_tap"):
		SoundManager.vibrate_tap()
	if mochi_bubble_label:
		mochi_bubble_label.text = "Meow! Sen tên gì thế? Ghi tên rồi đóng dấu sáp vàng nhé! 💖"
	if creation_anim_sprite:
		if creation_anim_sprite.sprite_frames and creation_anim_sprite.sprite_frames.has_animation("jump"):
			creation_anim_sprite.play("jump")
			get_tree().create_timer(0.6).timeout.connect(func():
				if is_instance_valid(creation_anim_sprite):
					creation_anim_sprite.play("idle2")
			)
		var base_pos := creation_anim_sprite.position
		var tw := create_tween()
		tw.tween_property(creation_anim_sprite, "scale", Vector2(4.2, 3.4), 0.08)
		tw.tween_property(creation_anim_sprite, "position:y", base_pos.y - 10.0, 0.12).set_trans(Tween.TRANS_BACK)
		tw.tween_property(creation_anim_sprite, "scale", Vector2(3.8, 3.8), 0.10)
		tw.tween_property(creation_anim_sprite, "position:y", base_pos.y, 0.12)

func _update_wax_seal_glow() -> void:
	if not btn_start_game:
		return
	var ready_to_stamp := edit_owner_name.text.strip_edges() != "" and edit_room_name.text.strip_edges() != ""
	if ready_to_stamp:
		if wax_glow_tween == null or not wax_glow_tween.is_valid():
			wax_glow_tween = create_tween().set_loops()
			wax_glow_tween.tween_property(btn_start_game, "modulate", Color(1.08, 1.04, 0.88, 1.0), 0.55)
			wax_glow_tween.tween_property(btn_start_game, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.55)
	else:
		if wax_glow_tween and wax_glow_tween.is_valid():
			wax_glow_tween.kill()
		btn_start_game.modulate = Color(0.92, 0.90, 0.86, 1.0)

func _on_wax_seal_stamp_pressed() -> void:
	if _is_stamping:
		return
	_is_stamping = true
	if SoundManager.has_method("play_confirm"):
		SoundManager.play_confirm()
	SoundManager.play_purr()
	if SoundManager.has_method("vibrate_confirm"):
		SoundManager.vibrate_confirm()

	if wax_seal_stamp_rect and is_inside_tree():
		var tw := create_tween()
		tw.tween_property(wax_seal_stamp_rect, "scale", Vector2(1.45, 1.45), 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(wax_seal_stamp_rect, "scale", Vector2(0.92, 0.92), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.tween_property(wax_seal_stamp_rect, "scale", Vector2.ONE, 0.08)

		# Camera/root shake nhẹ 2px
		var orig_pos := position
		var shake_tw := create_tween()
		shake_tw.tween_property(self, "position", orig_pos + Vector2(2.0, -2.0), 0.03)
		shake_tw.tween_property(self, "position", orig_pos + Vector2(-2.0, 2.0), 0.03)
		shake_tw.tween_property(self, "position", orig_pos, 0.04)

		_spawn_stamp_pixel_dust()
		await get_tree().create_timer(0.28).timeout

	_on_confirm_start_game()
	_is_stamping = false

func _spawn_stamp_pixel_dust() -> void:
	if not btn_start_game:
		return
	var origin := btn_start_game.global_position + btn_start_game.size * Vector2(0.85, 0.5)
	for i in range(8):
		var p := ColorRect.new()
		p.size = Vector2(5, 5)
		p.color = Color("#F5D76E") if i % 2 == 0 else Color("#FDF6E3")
		p.z_index = 110
		p.mouse_filter = Control.MOUSE_FILTER_IGNORE
		p.global_position = origin
		add_child(p)
		var ang := TAU * float(i) / 8.0
		var dest := origin + Vector2(cos(ang), sin(ang)) * randf_range(26.0, 48.0)
		var tw := create_tween().set_parallel(true)
		tw.tween_property(p, "global_position", dest, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(p, "modulate:a", 0.0, 0.28)
		tw.chain().tween_callback(p.queue_free)

func _open_cat_creation() -> void:
	# Tập trung vào Mochi mặc định (idx 8) nếu là tân thủ
	current_breed_idx = GameManager.selected_avatar_id if GameManager.has_completed_onboarding else 8
	var current_name = GameManager.custom_cat_name
	if current_name == "":
		current_name = "Mochi"
	edit_cat_name.text = current_name
	
	var current_room = GameManager.custom_room_name
	if current_room == "":
		current_room = "Gác Nhỏ Mochi"
	edit_room_name.text = current_room
	
	edit_owner_name.text = GameManager.get_owner_name()
	
	_update_breed_display()
	_update_wax_seal_glow()
	
	home_view.visible = false
	cat_creation_view.visible = true
	if edit_owner_name:
		edit_owner_name.call_deferred("grab_focus")
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
	if fade_curtain and is_inside_tree():
		var tw := create_tween()
		tw.tween_property(fade_curtain, "modulate:a", 1.0, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		await tw.finished
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
