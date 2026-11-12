extends Control

# PauseModal.gd - Menu tạm dừng & Tùy chỉnh Âm Thanh / Rung (SYS-02)
# Hỗ trợ Toggle/Slider độc lập cho BGM, SFX, Haptic trên nền khung modal_popup_beige.png

signal resume_requested
signal back_to_menu_requested

const TEX_MODAL_BEIGE: Texture2D = preload("res://assets/UI/CatUIPaid/slices/modal_popup_beige.png")

@onready var dim_overlay: ColorRect = $DimOverlay
@onready var panel: PanelContainer = $Panel
@onready var slider_sfx: HSlider = $Panel/VBox/SFXBox/HBox/SliderSFX
@onready var lbl_sfx_val: Label = $Panel/VBox/SFXBox/HBox/LblSFXVal
@onready var btn_test_sfx: Button = $Panel/VBox/SFXBox/HBox.get_node_or_null("BtnTestSFX")
@onready var slider_bgm: HSlider = $Panel/VBox/BGMBox/HBox/SliderBGM
@onready var lbl_bgm_val: Label = $Panel/VBox/BGMBox/HBox/LblBGMVal
@onready var check_haptic: CheckBox = $Panel/VBox/CheckHaptic
@onready var btn_resume: Button = $Panel/VBox/BtnResume
@onready var btn_back_menu: Button = $Panel/VBox/BtnBackMenu

var check_sfx: CheckBox = null
var check_bgm: CheckBox = null

func _ready() -> void:
	visible = false
	_apply_beige_popup_skin()
	_setup_audio_toggles()
	
	var bgm_icon = $Panel.get_node_or_null("VBox/BGMBox/BGMHeader/BGMIcon")
	if bgm_icon:
		bgm_icon.texture = GameManager.load_texture("res://assets/UI/CatUIPaid/slices/icon_music.png")
	
	# Đồng bộ cài đặt âm thanh hiện tại
	slider_sfx.value = SoundManager.sfx_volume * 100.0
	lbl_sfx_val.text = "%d%%" % int(slider_sfx.value)
	slider_sfx.value_changed.connect(func(val):
		SoundManager.set_sfx_volume(val / 100.0)
		lbl_sfx_val.text = "%d%%" % int(val)
	)
	slider_sfx.drag_ended.connect(func(_changed): GameManager.save_game())
	
	if btn_test_sfx:
		btn_test_sfx.pressed.connect(func():
			SoundManager.play_meow(1.1)
		)
	
	slider_bgm.value = SoundManager.bgm_volume * 100.0
	lbl_bgm_val.text = "%d%%" % int(slider_bgm.value)
	slider_bgm.value_changed.connect(func(val):
		SoundManager.set_bgm_volume(val / 100.0)
		lbl_bgm_val.text = "%d%%" % int(val)
	)
	slider_bgm.drag_ended.connect(func(_changed): GameManager.save_game())
	
	check_haptic.custom_minimum_size.y = maxf(check_haptic.custom_minimum_size.y, 40.0)
	check_haptic.button_pressed = SoundManager.haptic_enabled
	check_haptic.toggled.connect(func(pressed):
		SoundManager.set_haptic_enabled(pressed)
		if pressed:
			SoundManager.vibrate_confirm()
		GameManager.save_game()
	)
	
	btn_resume.pressed.connect(func():
		SoundManager.play_click()
		close()
		emit_signal("resume_requested")
	)
	
	btn_back_menu.pressed.connect(func():
		SoundManager.play_click()
		close()
		emit_signal("back_to_menu_requested")
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)
	
	dim_overlay.gui_input.connect(func(ev):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			close()
	)

func _apply_beige_popup_skin() -> void:
	if not panel or not TEX_MODAL_BEIGE:
		return
	var sb := StyleBoxTexture.new()
	sb.texture = TEX_MODAL_BEIGE
	sb.texture_margin_left = 16.0
	sb.texture_margin_top = 16.0
	sb.texture_margin_right = 16.0
	sb.texture_margin_bottom = 16.0
	sb.content_margin_left = 22.0
	sb.content_margin_top = 20.0
	sb.content_margin_right = 22.0
	sb.content_margin_bottom = 20.0
	panel.add_theme_stylebox_override("panel", sb)

func _setup_audio_toggles() -> void:
	var sfx_hdr := get_node_or_null("Panel/VBox/SFXBox/SFXHeader") as HBoxContainer
	if sfx_hdr:
		check_sfx = CheckBox.new()
		check_sfx.name = "CheckSFX"
		check_sfx.text = "Bật SFX"
		check_sfx.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		check_sfx.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		check_sfx.custom_minimum_size = Vector2(96, 36)
		check_sfx.add_theme_font_size_override("font_size", 11)
		check_sfx.add_theme_color_override("font_color", Color(0.35, 0.25, 0.18, 1))
		check_sfx.add_theme_color_override("font_pressed_color", Color(0.25, 0.18, 0.12, 1))
		check_sfx.button_pressed = SoundManager.sfx_enabled
		check_sfx.toggled.connect(func(pressed: bool):
			SoundManager.set_sfx_enabled(pressed)
			if pressed:
				SoundManager.play_click()
			GameManager.save_game()
		)
		sfx_hdr.add_child(check_sfx)

	var bgm_hdr := get_node_or_null("Panel/VBox/BGMBox/BGMHeader") as HBoxContainer
	if bgm_hdr:
		check_bgm = CheckBox.new()
		check_bgm.name = "CheckBGM"
		check_bgm.text = "Bật BGM"
		check_bgm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		check_bgm.alignment = HORIZONTAL_ALIGNMENT_RIGHT
		check_bgm.custom_minimum_size = Vector2(96, 36)
		check_bgm.add_theme_font_size_override("font_size", 11)
		check_bgm.add_theme_color_override("font_color", Color(0.35, 0.25, 0.18, 1))
		check_bgm.add_theme_color_override("font_pressed_color", Color(0.25, 0.18, 0.12, 1))
		check_bgm.button_pressed = SoundManager.bgm_enabled
		check_bgm.toggled.connect(func(pressed: bool):
			SoundManager.set_bgm_enabled(pressed)
			SoundManager.vibrate_tap()
			GameManager.save_game()
		)
		bgm_hdr.add_child(check_bgm)

func open() -> void:
	# Cập nhật lại giá trị slider & toggles
	slider_sfx.value = SoundManager.sfx_volume * 100.0
	slider_bgm.value = SoundManager.bgm_volume * 100.0
	if check_sfx:
		check_sfx.set_pressed_no_signal(SoundManager.sfx_enabled)
	if check_bgm:
		check_bgm.set_pressed_no_signal(SoundManager.bgm_enabled)
	check_haptic.set_pressed_no_signal(SoundManager.haptic_enabled)
	
	visible = true
	panel.scale = Vector2(0.88, 0.88)
	var tw = create_tween()
	tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK)

func close() -> void:
	visible = false
