extends Control

# PauseModal.gd - Menu tạm dừng trong game (Pause Menu)
# Hiển thị Setting (SFX, BGM, Haptic) và Back (Về Menu chính)

signal resume_requested
signal back_to_menu_requested

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

func _ready() -> void:
	visible = false
	
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
	
	check_haptic.button_pressed = SoundManager.haptic_enabled
	check_haptic.toggled.connect(func(pressed):
		SoundManager.set_haptic_enabled(pressed)
		if pressed:
			SoundManager.vibrate(40)
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

func open() -> void:
	# Cập nhật lại giá trị slider
	slider_sfx.value = SoundManager.sfx_volume * 100.0
	slider_bgm.value = SoundManager.bgm_volume * 100.0
	check_haptic.button_pressed = SoundManager.haptic_enabled
	
	visible = true
	panel.scale = Vector2(0.88, 0.88)
	var tw = create_tween()
	tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK)

func close() -> void:
	visible = false
