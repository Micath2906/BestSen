extends Control

# CatProfileHUD.gd - Bảng thông tin Mèo phong cách Pixel Art ToffeeCraft chuẩn GDD
# Gồm Khung Gỗ Giấy Da 9-Patch, Khung Tranh Treo Tường Pixel 32x32, Ruy Băng Huy Hiệu Level,
# TextureProgressBar Pixel Art Độ No & Dũng Cảm, Cuộn Giấy Da Tiền Cá Vàng & Sổ Nợ Nhấp Nháy,
# Nút Pause & Cửa Hàng Pixel Art Lún Nút.

signal open_avatar_picker_requested
signal pause_requested
signal open_shop_requested

enum HUDState {
	NORMAL,
	MINIGAME_ACTIVE
}

@onready var hud_container: NinePatchRect = $HUDContainer
@onready var mini_hud_panel: NinePatchRect = get_node_or_null("MiniHudPanel")
@onready var mini_timer_label: Label = get_node_or_null("MiniHudPanel/HBox/MiniTimerLabel")
@onready var mini_progress_bar: TextureProgressBar = get_node_or_null("MiniHudPanel/HBox/MiniProgressBar")
@onready var mini_progress_label: Label = get_node_or_null("MiniHudPanel/HBox/MiniProgressLabel")

@onready var btn_pause: BaseButton = $HUDContainer/HBox.get_node_or_null("BtnPause")
@onready var btn_shop: BaseButton = get_node_or_null("BtnShop") if has_node("BtnShop") else $HUDContainer/HBox/RightInfo/CoinRow.get_node_or_null("BtnShop")
@onready var avatar_frame_tex: Control = $HUDContainer/HBox.get_node_or_null("AvatarCol/AvatarBox/AvatarFrameTex") if $HUDContainer/HBox.has_node("AvatarCol/AvatarBox/AvatarFrameTex") else $HUDContainer/HBox.get_node_or_null("AvatarBox/AvatarFrameTex")
@onready var avatar_btn: TextureButton = $HUDContainer/HBox.get_node_or_null("AvatarCol/AvatarBox/AvatarButton") if $HUDContainer/HBox.has_node("AvatarCol/AvatarBox/AvatarButton") else $HUDContainer/HBox.get_node_or_null("AvatarBox/AvatarButton")
@onready var lbl_level: Label = $HUDContainer/HBox.get_node_or_null("AvatarCol/LevelBadge/LevelLabel") if $HUDContainer/HBox.has_node("AvatarCol/LevelBadge/LevelLabel") else $HUDContainer/HBox.get_node_or_null("AvatarCol/LevelBadge/HBox/LevelLabel")
@onready var star_icon: TextureRect = $HUDContainer/HBox.get_node_or_null("AvatarCol/LevelBadge/HBox/StarIcon")
@onready var lbl_cat_title: Label = $HUDContainer/HBox/RightInfo.get_node_or_null("TitleRow/CatTitle")

@onready var hunger_icon: TextureRect = $HUDContainer/HBox/RightInfo/BarsContainer/HungerRow.get_node_or_null("HungerIcon")
@onready var hunger_bar: Range = $HUDContainer/HBox/RightInfo/BarsContainer/HungerRow/HungerProgressBar
@onready var lbl_hunger_val: Label = $HUDContainer/HBox/RightInfo/BarsContainer/HungerRow.get_node_or_null("HungerValueLabel")

@onready var courage_icon: TextureRect = $HUDContainer/HBox/RightInfo/BarsContainer/CourageRow.get_node_or_null("CourageIcon")
@onready var courage_bar: Range = $HUDContainer/HBox/RightInfo/BarsContainer/CourageRow/CourageProgressBar
@onready var lbl_courage_val: Label = $HUDContainer/HBox/RightInfo/BarsContainer/CourageRow.get_node_or_null("CourageValueLabel")

@onready var mood_bar: Range = $HUDContainer/HBox/RightInfo/BarsContainer.get_node_or_null("MoodRow/MoodProgressBar")
@onready var lbl_mood_val: Label = $HUDContainer/HBox/RightInfo/BarsContainer.get_node_or_null("MoodRow/MoodValueLabel")

@onready var coin_box: Control = $HUDContainer/HBox/RightInfo/CoinRow/CoinPanel
@onready var lbl_fish_val: Label = $HUDContainer/HBox/RightInfo/CoinRow/CoinPanel/CoinHBox/FishLabel
@onready var lbl_debt_tag: Label = $HUDContainer/HBox/RightInfo/CoinRow/CoinPanel/CoinHBox.get_node_or_null("DebtLabel")
@onready var debt_icon: TextureRect = $HUDContainer/HBox/RightInfo/CoinRow/CoinPanel/CoinHBox.get_node_or_null("DebtIcon")

var avatar_textures: Array = []
var debt_tween: Tween
var current_hud_state: HUDState = HUDState.NORMAL
var _safe_top_inset: float = 0.0
var _hunger_bar_base_x: float = 0.0
var _hunger_base_cached: bool = false
var _hunger_jitter_phase: float = 0.0
var _icon_pulse_phase: float = 0.0
var _was_low_hunger: bool = false
var _last_low_hunger_meow_msec: int = -30000

func _ready() -> void:
	# Load 10 avatar textures
	for i in range(10):
		var tex = GameManager.load_texture("res://assets/sprites/avatars/avatar_%d.png" % i)
		if tex == null:
			tex = GameManager.load_texture("res://assets/sprites/avatars/framed_avatar_%d.png" % i)
		avatar_textures.append(tex)
		
	if star_icon:
		star_icon.texture = GameManager.load_texture("res://assets/UI/CatUIPaid/slices/icon_star.png")
		
	avatar_btn.pressed.connect(_on_avatar_pressed)
	
	if btn_pause:
		btn_pause.pivot_offset = btn_pause.custom_minimum_size / 2.0
		btn_pause.pressed.connect(func():
			SoundManager.play_click()
			var tw = create_tween()
			tw.tween_property(btn_pause, "scale", Vector2(0.9, 0.9), 0.05)
			tw.tween_property(btn_pause, "scale", Vector2(1.0, 1.0), 0.07)
			emit_signal("pause_requested")
		)
		
	if btn_shop:
		btn_shop.pivot_offset = btn_shop.custom_minimum_size / 2.0
		btn_shop.pressed.connect(func():
			SoundManager.play_click()
			var tween = create_tween()
			tween.tween_property(btn_shop, "scale", Vector2(0.9, 0.9), 0.05)
			tween.tween_property(btn_shop, "scale", Vector2(1.0, 1.0), 0.07)
			emit_signal("open_shop_requested")
		)
		
	GameManager.stats_changed.connect(update_hud)
	GameManager.avatar_changed.connect(_on_avatar_changed_cb)
	GameManager.avatar_frame_changed.connect(_on_avatar_frame_changed_cb)
	if GameManager.has_signal("minigame_hud_active"):
		GameManager.minigame_hud_active.connect(_on_minigame_hud_active)
	if GameManager.has_signal("minigame_hud_updated"):
		GameManager.minigame_hud_updated.connect(update_minigame_hud)
	
	# Kết nối sự kiện chạm thanh chỉ số để mở popup cảnh báo / thông tin chi tiết
	var hunger_row = $HUDContainer/HBox/RightInfo/BarsContainer.get_node_or_null("HungerRow")
	if hunger_row:
		hunger_row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		hunger_row.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				if GameManager.hunger >= 100:
					GameManager.emit_signal("show_status_alert", "too_full")
				elif GameManager.hunger <= 0:
					GameManager.emit_signal("show_status_alert", "fainted")
				else:
					GameManager.emit_signal("show_status_alert", "info")
		)
	
	var courage_row = $HUDContainer/HBox/RightInfo/BarsContainer.get_node_or_null("CourageRow")
	if courage_row:
		courage_row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		courage_row.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				if GameManager.courage <= 20:
					GameManager.emit_signal("show_status_alert", "too_stressed")
				else:
					GameManager.emit_signal("show_status_alert", "info")
		)
	
	if hunger_icon:
		hunger_icon.pivot_offset = Vector2(8, 8)
	if courage_icon:
		courage_icon.pivot_offset = Vector2(8, 8)
	call_deferred("_cache_bar_base_pos")
	set_hud_state(HUDState.NORMAL)
	update_avatar()
	update_hud()

func _exit_tree() -> void:
	if GameManager.stats_changed.is_connected(update_hud):
		GameManager.stats_changed.disconnect(update_hud)
	if GameManager.avatar_changed.is_connected(_on_avatar_changed_cb):
		GameManager.avatar_changed.disconnect(_on_avatar_changed_cb)
	if GameManager.avatar_frame_changed.is_connected(_on_avatar_frame_changed_cb):
		GameManager.avatar_frame_changed.disconnect(_on_avatar_frame_changed_cb)
	if GameManager.has_signal("minigame_hud_active") and GameManager.minigame_hud_active.is_connected(_on_minigame_hud_active):
		GameManager.minigame_hud_active.disconnect(_on_minigame_hud_active)
	if GameManager.has_signal("minigame_hud_updated") and GameManager.minigame_hud_updated.is_connected(update_minigame_hud):
		GameManager.minigame_hud_updated.disconnect(update_minigame_hud)

func _on_avatar_changed_cb(_id) -> void:
	update_avatar()

func _on_avatar_frame_changed_cb(_frame_id) -> void:
	_update_avatar_frame()

func _on_minigame_hud_active(active: bool) -> void:
	visible = true if active else visible
	set_hud_state(HUDState.MINIGAME_ACTIVE if active else HUDState.NORMAL)

func _cache_bar_base_pos() -> void:
	if hunger_bar:
		_hunger_bar_base_x = hunger_bar.position.x
		_hunger_base_cached = true

func _process(delta: float) -> void:
	if current_hud_state != HUDState.NORMAL or not visible:
		return
	
	_icon_pulse_phase += delta * 2.4
	if courage_icon:
		var c_s = 1.0 + 0.05 * sin(_icon_pulse_phase)
		courage_icon.scale = Vector2(c_s, c_s)
	
	if GameManager.hunger < 20:
		_hunger_jitter_phase += delta * TAU * 2.0 # Tần số 2 Hz chuẩn DoD UI-01
		if not _hunger_base_cached and hunger_bar:
			_hunger_bar_base_x = hunger_bar.position.x
			_hunger_base_cached = true
		if hunger_bar:
			hunger_bar.position.x = _hunger_bar_base_x + sin(_hunger_jitter_phase) * 2.0
		if hunger_icon:
			var h_s = 1.0 + 0.10 * absf(sin(_hunger_jitter_phase))
			hunger_icon.scale = Vector2(h_s, h_s)
		
		var now_msec = Time.get_ticks_msec()
		if not _was_low_hunger and (now_msec - _last_low_hunger_meow_msec >= 30000):
			_last_low_hunger_meow_msec = now_msec
			SoundManager.play_meow(1.05)
		_was_low_hunger = true
	else:
		if _was_low_hunger:
			_was_low_hunger = false
			if hunger_bar and _hunger_base_cached:
				hunger_bar.position.x = _hunger_bar_base_x
			if hunger_icon:
				hunger_icon.scale = Vector2.ONE

func set_hud_state(new_state: HUDState) -> void:
	current_hud_state = new_state
	if new_state == HUDState.MINIGAME_ACTIVE:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		if hud_container:
			hud_container.visible = false
		if btn_shop:
			btn_shop.visible = false
		if mini_hud_panel:
			mini_hud_panel.visible = true
	else:
		mouse_filter = Control.MOUSE_FILTER_PASS
		if hud_container:
			hud_container.visible = true
		if btn_shop:
			btn_shop.visible = true
		if mini_hud_panel:
			mini_hud_panel.visible = false

func update_minigame_hud(time_left_sec: float, progress_pct: float) -> void:
	var sec_i = maxi(0, int(ceil(time_left_sec)))
	var mins = int(sec_i / 60.0)
	var secs = sec_i % 60
	if mini_timer_label:
		mini_timer_label.text = "%02d:%02d" % [mins, secs]
	var pct = clampf(progress_pct, 0.0, 100.0)
	if mini_progress_bar:
		mini_progress_bar.value = pct
	if mini_progress_label:
		mini_progress_label.text = "%d%%" % int(round(pct))

func apply_safe_area_top(top_inset: float) -> void:
	_safe_top_inset = maxf(0.0, top_inset)
	offset_top = 4.0 + _safe_top_inset

func update_avatar() -> void:
	var id = GameManager.selected_avatar_id
	if id >= 0 and id < avatar_textures.size() and avatar_textures[id] != null:
		avatar_btn.texture_normal = avatar_textures[id]
	if lbl_cat_title and id >= 0 and id < GameManager.avatar_list.size():
		lbl_cat_title.text = GameManager.get_cat_name()
	_update_avatar_frame()

func _update_avatar_frame() -> void:
	if avatar_frame_tex:
		avatar_frame_tex.texture = preload("res://assets/UI/CatUIPaid/slices/toffee_hud/avatar_picture_frame_32x32.tres")

func update_hud() -> void:
	# 0. Cập nhật Cấp Độ Mèo
	if lbl_level:
		lbl_level.text = "Cấp %d" % GameManager.cat_mastery_level
	
	# 1. Cập nhật Độ No (Hunger)
	if hunger_bar:
		hunger_bar.value = GameManager.hunger
	if lbl_hunger_val:
		lbl_hunger_val.text = "%d/100" % GameManager.hunger
		if GameManager.hunger >= 100:
			lbl_hunger_val.add_theme_color_override("font_color", Color(0.12, 0.65, 0.25))
		elif GameManager.hunger < 25:
			lbl_hunger_val.add_theme_color_override("font_color", Color(0.95, 0.25, 0.15))
		else:
			lbl_hunger_val.add_theme_color_override("font_color", Color(0.24, 0.16, 0.10))
	
	# 2. Cập nhật Dũng Cảm (Courage)
	if courage_bar:
		courage_bar.value = GameManager.courage
	if lbl_courage_val:
		lbl_courage_val.text = "%d/100" % GameManager.courage
		if GameManager.courage <= 15:
			lbl_courage_val.add_theme_color_override("font_color", Color(0.85, 0.15, 0.45))
		elif GameManager.courage < 25:
			lbl_courage_val.add_theme_color_override("font_color", Color(0.85, 0.45, 0.1))
		else:
			lbl_courage_val.add_theme_color_override("font_color", Color(0.12, 0.28, 0.36))
	
	# 3. Cập nhật Tâm Trạng (nếu có)
	if mood_bar:
		mood_bar.value = GameManager.mood
	if lbl_mood_val:
		lbl_mood_val.text = "%d/100" % GameManager.mood
		
	# 4. Cập nhật Tiền Cá Vàng
	if lbl_fish_val:
		lbl_fish_val.text = "%d" % GameManager.fish
		if GameManager.fish < 15:
			lbl_fish_val.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
		else:
			lbl_fish_val.add_theme_color_override("font_color", Color(0.20, 0.14, 0.08))
		
	# 5. Cập nhật Nợ BNPL & Icon Sổ Nợ / Hóa Đơn Nhấp Nháy Bằng Tween
	if GameManager.debt_amount > 0:
		if lbl_debt_tag:
			lbl_debt_tag.visible = true
			lbl_debt_tag.text = "Nợ %d" % GameManager.debt_amount
		if debt_icon:
			debt_icon.visible = true
			if debt_tween == null or not debt_tween.is_valid():
				debt_tween = create_tween().set_loops()
				debt_tween.tween_property(debt_icon, "modulate:a", 0.35, 0.5)
				debt_tween.tween_property(debt_icon, "modulate:a", 1.0, 0.5)
	else:
		if lbl_debt_tag:
			lbl_debt_tag.visible = false
		if debt_icon:
			debt_icon.visible = false
			if debt_tween and debt_tween.is_valid():
				debt_tween.kill()
			debt_icon.modulate.a = 1.0

func _on_avatar_pressed() -> void:
	# Squish effect on click
	var tween = create_tween()
	tween.tween_property(avatar_btn, "scale", Vector2(0.9, 0.9), 0.08)
	tween.tween_property(avatar_btn, "scale", Vector2(1.0, 1.0), 0.08)
	SoundManager.play_meow(1.2)
	emit_signal("open_avatar_picker_requested")
