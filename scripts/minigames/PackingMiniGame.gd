extends Control

# PackingMiniGame.gd - Gameplay "Ba Lô Sinh Tồn / Xếp Đồ Vào Giỏ" (Inventory Packing Puzzle)
# Người chơi chọn lọc đúng 4 vật phẩm sinh tồn, tránh nhồi nhét đồ vô bổ khiến mèo gãy lưng

signal minigame_completed(sim_steps)
signal back_requested

@onready var title_lbl: Label = $Header/HeaderTitle
@onready var btn_back: Button = $Header/BtnBack
@onready var cat_speech: Label = $CatSection/HBox/CatSpeech
@onready var cat_anchor: Control = $CatSection/HBox/CatAnchor
@onready var backpack_grid: HBoxContainer = $BackpackCard/VBox/SlotsHBox
@onready var table_grid: GridContainer = $TableCard/VBox/Scroll/ItemsGrid
@onready var btn_pack_done: Button = $ActionFooter/BtnPackDone
@onready var slot_count_lbl: Label = $BackpackCard/VBox/HeaderRow/SlotCountLabel

var data: Dictionary = {}
var max_slots: int = 4
var packed_items: Array = [] # List of item dicts currently in backpack
var available_items: Array = []
var cat_anim: AnimatedSprite2D = null

func _ready() -> void:
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(func(): emit_signal("back_requested"))
	btn_pack_done.pressed.connect(_on_pack_done_pressed)
	_setup_cat_mascot()

func _setup_cat_mascot() -> void:
	if cat_anim == null and cat_anchor:
		cat_anim = AnimatedSprite2D.new()
		cat_anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		cat_anim.position = Vector2(30, 30)
		cat_anim.scale = Vector2(2.2, 2.2)
		cat_anchor.add_child(cat_anim)
		cat_anim.sprite_frames = CatAnimationFactory.get_sprite_frames(GameManager.selected_avatar_id)
		cat_anim.play("idle2")

func load_minigame(game_data: Dictionary) -> void:
	data = game_data
	max_slots = data.get("max_slots", 4)
	packed_items.clear()
	available_items = data.get("items", []).duplicate()
	
	title_lbl.text = "🎒 " + data.get("title", "XẾP BA LÔ SINH TỒN")
	cat_speech.text = data.get("cat_prompt", "Chọn đúng đồ cần thiết xếp vào ba lô cho Boss nhé!")
	
	_render_backpack_slots()
	_render_table_items()
	_update_action_button()

func _render_backpack_slots() -> void:
	for child in backpack_grid.get_children():
		backpack_grid.remove_child(child)
		child.queue_free()
		
	slot_count_lbl.text = "Ngăn chứa: %d/%d ô" % [packed_items.size(), max_slots]
	
	for i in range(max_slots):
		var slot_p = PanelContainer.new()
		slot_p.custom_minimum_size = Vector2(74, 74)
		slot_p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_p.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var s = StyleBoxFlat.new()
		s.set_corner_radius_all(10)
		s.content_margin_left = 4
		s.content_margin_right = 4
		s.content_margin_top = 4
		s.content_margin_bottom = 4
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 2)
		
		if i < packed_items.size():
			var it = packed_items[i]
			s.bg_color = Color(1.0, 0.96, 0.90, 1.0)
			s.border_color = Color(0.92, 0.60, 0.20, 1.0)
			s.set_border_width_all(2)
			
			var ic = Label.new()
			ic.text = it.get("icon", "📦")
			ic.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			ic.add_theme_font_size_override("font_size", 22)
			vbox.add_child(ic)
			
			var nm = Label.new()
			nm.text = it.get("name", "")
			nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			nm.add_theme_font_size_override("font_size", 9)
			nm.add_theme_color_override("font_color", Color(0.3, 0.2, 0.1))
			vbox.add_child(nm)
			
			slot_p.gui_input.connect(func(event):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					_remove_from_backpack(it)
			)
		else:
			s.bg_color = Color(0.95, 0.93, 0.90, 0.6)
			s.border_color = Color(0.82, 0.78, 0.72, 1.0)
			s.set_border_width_all(1)
			
			var empty_lbl = Label.new()
			empty_lbl.text = "Ô %d\n[Trống]" % (i + 1)
			empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			empty_lbl.add_theme_font_size_override("font_size", 10)
			empty_lbl.add_theme_color_override("font_color", Color(0.65, 0.60, 0.55))
			vbox.add_child(empty_lbl)
			
		slot_p.add_theme_stylebox_override("panel", s)
		slot_p.add_child(vbox)
		backpack_grid.add_child(slot_p)

func _render_table_items() -> void:
	for child in table_grid.get_children():
		table_grid.remove_child(child)
		child.queue_free()
		
	for it in available_items:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 58)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		var is_packed = false
		for p in packed_items:
			if p["id"] == it["id"]:
				is_packed = true
				break
				
		btn.text = " %s %s\n   %s" % [it.get("icon", "📦"), it.get("name", ""), it.get("desc", "")]
		btn.add_theme_font_size_override("font_size", 10)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		var b_style = StyleBoxFlat.new()
		b_style.set_corner_radius_all(10)
		b_style.content_margin_left = 8
		b_style.content_margin_right = 8
		b_style.content_margin_top = 4
		b_style.content_margin_bottom = 4
		
		if is_packed:
			b_style.bg_color = Color(0.92, 0.90, 0.88, 0.5)
			b_style.border_color = Color(0.75, 0.70, 0.65, 0.8)
			b_style.set_border_width_all(1)
			btn.disabled = true
			btn.add_theme_color_override("font_color", Color(0.6, 0.55, 0.5))
		else:
			b_style.bg_color = Color(1, 1, 1, 0.95)
			b_style.border_color = Color(0.85, 0.78, 0.70, 1)
			b_style.set_border_width_all(1)
			b_style.border_width_bottom = 2
			btn.disabled = false
			btn.add_theme_color_override("font_color", Color(0.25, 0.18, 0.12))
			btn.pressed.connect(func(): _add_to_backpack(it))
			
		btn.add_theme_stylebox_override("normal", b_style)
		btn.add_theme_stylebox_override("disabled", b_style)
		btn.add_theme_stylebox_override("hover", b_style)
		table_grid.add_child(btn)

func _add_to_backpack(item: Dictionary) -> void:
	if packed_items.size() >= max_slots:
		SoundManager.play_fail()
		cat_speech.text = "Ba lô đầy rồi Sen ơi! Chạm vào món trên ba lô để bỏ bớt ra nhé!"
		return
		
	SoundManager.play_card_pop()
	packed_items.append(item)
	cat_speech.text = "Đã nhét [%s] vào ba lô! 🎒" % item.get("name", "")
	_render_backpack_slots()
	_render_table_items()
	_update_action_button()

func _remove_from_backpack(item: Dictionary) -> void:
	SoundManager.play_click()
	packed_items.erase(item)
	cat_speech.text = "Đã lấy [%s] ra khỏi ba lô! ✨" % item.get("name", "")
	_render_backpack_slots()
	_render_table_items()
	_update_action_button()

func _update_action_button() -> void:
	if packed_items.size() == max_slots:
		btn_pack_done.disabled = false
		btn_pack_done.text = "🎒 ĐEO BA LÔ LÊN ĐƯỜNG KIỂM TRA! (4/4)"
	else:
		btn_pack_done.disabled = true
		btn_pack_done.text = "🎒 CẦN XẾP ĐỦ 4 MÓN VÀO BA LÔ (%d/4)" % packed_items.size()

func _on_pack_done_pressed() -> void:
	# Kiểm tra xem có món sai không
	var wrong_item: Dictionary = {}
	for it in packed_items:
		if not it.get("is_required", false):
			wrong_item = it
			break
			
	if not wrong_item.is_empty():
		# Thất bại hài hước: Mèo bị ngã chổng vó do mang đồ linh tinh
		SoundManager.play_fail()
		var tw = create_tween()
		if cat_anchor:
			tw.tween_property(cat_anchor, "rotation", 1.5, 0.25).set_trans(Tween.TRANS_BACK)
			tw.tween_property(cat_anchor, "rotation", 0.0, 0.35).set_delay(1.5)
			
		var humor_msg = wrong_item.get("humor", "Mang món này làm nặng ba lô quá Sen ơi!")
		cat_speech.text = "ÚI GIỜI ƠI! 😵 " + humor_msg
	else:
		# Thành công rực rỡ!
		SoundManager.play_success()
		if cat_anim:
			cat_anim.play("jump")
			
		cat_speech.text = data.get("success_msg", "🎒 Ba lô chuẩn y tế 10 điểm! Mèo lên đường tự tin! ✨")
		btn_pack_done.disabled = true
		btn_pack_done.text = "🎉 HÀNH TRANG CHUẨN XÁC 10/10!"
		
		await get_tree().create_timer(1.2).timeout
		var sim_steps = data.get("sim_steps", [])
		emit_signal("minigame_completed", sim_steps)
