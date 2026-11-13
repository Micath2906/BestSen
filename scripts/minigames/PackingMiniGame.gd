extends Control

# PackingMiniGame.gd - Gameplay "Ba Lô Sinh Tồn / Xếp Đồ Vào Giỏ" (Grid Inventory Tetris Puzzle)
# GP-ED-04: Bảng kẹp gỗ clipboard, checklist bảng bần đính đinh ghim đỏ, lưới Tetris 4x3 hỗ trợ xoay/kéo-thả & Safe Failure

signal minigame_completed(sim_steps)
signal back_requested

const DraggableItemScript = preload("res://scripts/minigames/DraggableItem.gd")
const JuicyButtonScript = preload("res://scripts/ui/JuicyButton.gd")
const TEX_CLIPBOARD: Texture2D = preload("res://assets/UI/CatUIPaid/slices/cozy_dress/clipboard_wood_frame_9patch.tres")
const STYLE_CORK_BOARD: StyleBox = preload("res://assets/UI/CatUIPaid/slices/cozy_achievements/cork_board_stylebox.tres")
const TEX_PIN_TACK: Texture2D = preload("res://assets/UI/CatUIPaid/slices/cozy_achievements/pin_tack_red.tres")
const TEX_MOCHI_YARN: Texture2D = preload("res://assets/UI/CatUIPaid/slices/icon_toy_yarn_ball.png")
const COZY_DIALOG_SCN: PackedScene = preload("res://scenes/ui/CozyDialogBox.tscn")

const TEX_ITEM_PEN: Texture2D = preload("res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_05_pen.tres")
const TEX_ITEM_KEY: Texture2D = preload("res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_06_key.tres")
const TEX_ITEM_CLIPBOARD: Texture2D = preload("res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_08_clipboard.tres")
const TEX_ITEM_THERMO: Texture2D = preload("res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_09_thermometer.tres")
const TEX_ITEM_PILL: Texture2D = preload("res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_10_pill.tres")
const TEX_ITEM_FIRST_AID: Texture2D = preload("res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_11_first_aid.tres")
const TEX_ITEM_THERMOS: Texture2D = preload("res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_12_thermos.tres")
const TEX_ITEM_COFFEE: Texture2D = preload("res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/loot_15_coffee.tres")

const GRID_COLS: int = 4
const GRID_ROWS: int = 3
var active_grid_rows: int = GRID_ROWS

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

# GP-ED-04 Tetris & Cork Checklist state
var checklist_cork_card: PanelContainer = null
var pin_tack_sprite: TextureRect = null
var checklist_vbox: VBoxContainer = null
var tetris_controls_row: HBoxContainer = null
var btn_rotate_item: Button = null
var btn_toggle_4x5: Button = null
var active_shape_lbl: Label = null
var tetris_grid_4x3: GridContainer = null
var tetris_grid_4x5: GridContainer = null
var ghost_hover_origin: Vector2i = Vector2i(-1, -1)
var mochi_yarn_in_backpack: bool = false
var mochi_mischief_timer: float = 0.0
var is_packing_completed: bool = false
var packing_cozy_dialog: Control = null

var is_item_rotated: bool = false
var selected_item: Dictionary = {}
var tetris_placements: Array = [] # [{"item": dict, "origin": Vector2i, "size": Vector2i, "rotated": bool}]
var safe_failure_count: int = 0
var _last_sync_signature: String = ""

func _ready() -> void:
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(func(): emit_signal("back_requested"))
	btn_pack_done.pressed.connect(_on_pack_done_pressed)
	JuicyButtonScript.attach_juice(btn_pack_done, true)
	_setup_cat_mascot()
	_setup_gp_ed_04_ui()

func _process(delta: float) -> void:
	var sig := _compute_sync_signature()
	if sig != _last_sync_signature:
		_last_sync_signature = sig
		_sync_gp_ed_04_state()
	if not is_packing_completed and not mochi_yarn_in_backpack and packed_items.size() >= 2:
		mochi_mischief_timer += delta
		if mochi_mischief_timer >= 6.0:
			spawn_mochi_mischief_toy()

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
	tetris_placements.clear()
	mochi_yarn_in_backpack = false
	mochi_mischief_timer = 0.0
	is_packing_completed = false
	ghost_hover_origin = Vector2i(-1, -1)
	available_items = data.get("items", []).duplicate()
	
	title_lbl.text = "🎒 " + data.get("title", "XẾP BA LÔ SINH TỒN")
	cat_speech.text = data.get("cat_prompt", "Chọn đúng đồ cần thiết xếp vào ba lô cho Boss nhé!")
	
	_render_backpack_slots()
	_render_table_items()
	_update_action_button()
	_refresh_tetris_grid_visuals()

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

	# Kiểm tra xem có bỏ quên chìa khóa (nếu đề bài có vật phẩm chìa khóa bắt buộc) hoặc ba lô trống không
	var forgot_key_item: Dictionary = {}
	for req in available_items:
		if req.get("is_required", false):
			var rid: String = str(req.get("id", "")).to_lower()
			var rname: String = str(req.get("name", "")).to_lower()
			if "key" in rid or "chìa khóa" in rname or "chia khoa" in rname:
				if not _is_item_packed(req):
					forgot_key_item = req
					break

	if mochi_yarn_in_backpack:
		_trigger_packing_safe_failure(
			"Hihi~ Mochi lén gửi Cuộn Len 🧶 vào góc ba lô nè! Bấm vào cuộn len trả lại cho Mochi rồi hẵng kéo khóa nhé!",
			false
		)
		return
	if packed_items.is_empty():
		_trigger_packing_safe_failure(
			"Hihi~ Ba lô vẫn trống trơn nè! Boss Mèo cười khúc khích chạy đi nhặt giúp Sen chùm chìa khóa & đồ cần thiết nhé! 🔑🐾",
			true
		)
	elif not wrong_item.is_empty():
		var humor_msg: String = wrong_item.get("humor", "Mang món này làm nặng ba lô quá Sen ơi!")
		cat_speech.text = "ÚI GIỜI ƠI! 😹 " + humor_msg
		_trigger_packing_safe_failure(
			"Hihi~ %s Boss Mèo chạy đi nhặt lại chìa khóa & giúp Sen cất bớt món nặng nha! 🔑🐾" % humor_msg,
			false
		)
	elif not forgot_key_item.is_empty():
		_trigger_packing_safe_failure(
			"Ơ kìa Sen quên mang %s rồi! Boss Mèo cười khúc khích chạy đi nhặt chìa khóa giúp Sen nè! 🔑🐾" % str(forgot_key_item.get("name", "Chìa khóa")),
			true
		)
	else:
		# Thành công rực rỡ! Âm thanh kéo khóa "Rẹt!" + Ba lô căng phồng nhẹ
		is_packing_completed = true
		SoundManager.play_card_pop()
		SoundManager.play_success()
		if SoundManager.has_method("vibrate"):
			SoundManager.vibrate(30)
		var bp := get_node_or_null("BackpackCard") as Control
		if bp:
			bp.pivot_offset = bp.size * 0.5
			var puff := create_tween()
			puff.tween_property(bp, "scale", Vector2(1.06, 0.96), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			puff.tween_property(bp, "scale", Vector2(1.02, 1.04), 0.12)
			puff.tween_property(bp, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		if cat_anim:
			cat_anim.play("jump")
			
		cat_speech.text = "🎒 RẸT! Kéo khóa hoàn hảo 10/10! " + data.get("success_msg", "Hành trang sẵn sàng! ✨")
		btn_pack_done.disabled = true
		btn_pack_done.text = "🎉 RẸT! HÀNH TRANG CHUẨN XÁC 10/10!"
		
		await get_tree().create_timer(1.2).timeout
		var sim_steps = data.get("sim_steps", [])
		emit_signal("minigame_completed", sim_steps)

# ==============================================================================
# GP-ED-04: GRID INVENTORY TETRIS, CORK CHECKLIST & SAFE FAILURE
# ==============================================================================

func _setup_gp_ed_04_ui() -> void:
	var backpack_card := get_node_or_null("BackpackCard") as PanelContainer
	if backpack_card:
		var clip_sb := StyleBoxTexture.new()
		clip_sb.texture = TEX_CLIPBOARD
		clip_sb.texture_margin_left = 12.0
		clip_sb.texture_margin_top = 12.0
		clip_sb.texture_margin_right = 12.0
		clip_sb.texture_margin_bottom = 12.0
		clip_sb.content_margin_left = 14.0
		clip_sb.content_margin_top = 14.0
		clip_sb.content_margin_right = 14.0
		clip_sb.content_margin_bottom = 14.0
		backpack_card.add_theme_stylebox_override("panel", clip_sb)

	var vbox := get_node_or_null("BackpackCard/VBox") as VBoxContainer
	if not vbox:
		return

	# 1. Checklist ghim trên bảng bần + đinh ghim đỏ
	checklist_cork_card = PanelContainer.new()
	checklist_cork_card.name = "ChecklistCorkCard"
	checklist_cork_card.add_theme_stylebox_override("panel", STYLE_CORK_BOARD.duplicate())

	var cork_vbox := VBoxContainer.new()
	cork_vbox.name = "CorkVBox"
	cork_vbox.add_theme_constant_override("separation", 4)
	checklist_cork_card.add_child(cork_vbox)

	var pin_hdr := HBoxContainer.new()
	pin_hdr.add_theme_constant_override("separation", 6)
	pin_tack_sprite = TextureRect.new()
	pin_tack_sprite.name = "PinTackSprite"
	pin_tack_sprite.texture = TEX_PIN_TACK
	pin_tack_sprite.custom_minimum_size = Vector2(20, 20)
	pin_tack_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pin_tack_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pin_hdr.add_child(pin_tack_sprite)

	var cork_title := Label.new()
	cork_title.text = "📌 CHECKLIST ĐỒ CẦN MANG (Ghim Bảng Bần)"
	cork_title.add_theme_font_size_override("font_size", 14)
	cork_title.add_theme_color_override("font_color", Color(0.28, 0.16, 0.08))
	pin_hdr.add_child(cork_title)
	cork_vbox.add_child(pin_hdr)

	checklist_vbox = VBoxContainer.new()
	checklist_vbox.name = "ChecklistVBox"
	checklist_vbox.add_theme_constant_override("separation", 2)
	cork_vbox.add_child(checklist_vbox)

	vbox.add_child(checklist_cork_card)
	vbox.move_child(checklist_cork_card, 0)

	# 2. Thanh điều khiển xoay khối Tetris 90 độ (touch target >= 56dp)
	tetris_controls_row = HBoxContainer.new()
	tetris_controls_row.name = "TetrisControlsRow"
	tetris_controls_row.add_theme_constant_override("separation", 10)

	btn_rotate_item = Button.new()
	btn_rotate_item.name = "BtnRotateItem"
	btn_rotate_item.text = "🔄 Xoay Món (90°)"
	btn_rotate_item.custom_minimum_size = Vector2(180, 56)
	btn_rotate_item.add_theme_font_size_override("font_size", 15)
	btn_rotate_item.pressed.connect(_on_rotate_item_pressed)
	tetris_controls_row.add_child(btn_rotate_item)
	JuicyButtonScript.attach_juice(btn_rotate_item, true)

	btn_toggle_4x5 = Button.new()
	btn_toggle_4x5.name = "BtnToggle4x5Grid"
	btn_toggle_4x5.text = "📐 Ngăn 4×5"
	btn_toggle_4x5.custom_minimum_size = Vector2(88, 56)
	btn_toggle_4x5.add_theme_font_size_override("font_size", 12)
	btn_toggle_4x5.pressed.connect(func(): enable_4x5_grid(active_grid_rows == 3))
	tetris_controls_row.add_child(btn_toggle_4x5)
	JuicyButtonScript.attach_juice(btn_toggle_4x5, true)

	active_shape_lbl = Label.new()
	active_shape_lbl.name = "ActiveShapeLabel"
	active_shape_lbl.text = "Góc xoay: Ngang (0°)"
	active_shape_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	active_shape_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	active_shape_lbl.add_theme_font_size_override("font_size", 14)
	active_shape_lbl.add_theme_color_override("font_color", Color(0.26, 0.18, 0.10))
	tetris_controls_row.add_child(active_shape_lbl)

	vbox.add_child(tetris_controls_row)

	# 3. Lưới Tetris 4x3 chuẩn (tương thích kiểm thử) & Lưới mở rộng 4x5
	tetris_grid_4x3 = _build_backpack_grid_container("TetrisGrid4x3", 3)
	vbox.add_child(tetris_grid_4x3)

	tetris_grid_4x5 = _build_backpack_grid_container("TetrisGrid4x5", 5)
	tetris_grid_4x5.visible = false
	vbox.add_child(tetris_grid_4x5)

	# 4. CozyDialogBox cho Safe Failure (Boss Mèo cười khúc khích + nhặt chìa khóa)
	packing_cozy_dialog = COZY_DIALOG_SCN.instantiate()
	packing_cozy_dialog.name = "PackingCozyDialog"
	packing_cozy_dialog.visible = false
	packing_cozy_dialog.z_index = 40
	packing_cozy_dialog.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	packing_cozy_dialog.offset_top = -170.0
	packing_cozy_dialog.offset_bottom = -20.0
	packing_cozy_dialog.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			packing_cozy_dialog.visible = false
	)
	add_child(packing_cozy_dialog)

func _on_rotate_item_pressed() -> void:
	is_item_rotated = not is_item_rotated
	if SoundManager.has_method("play_tap"):
		SoundManager.play_tap()
	if SoundManager.has_method("vibrate"):
		SoundManager.vibrate(15)
	_update_rotate_label()
	_refresh_table_item_footprints()
	_refresh_tetris_grid_visuals()

func _update_rotate_label() -> void:
	if not active_shape_lbl:
		return
	var rot_text := "Dọc (90°)" if is_item_rotated else "Ngang (0°)"
	if not selected_item.is_empty():
		var fp := get_item_footprint(selected_item, is_item_rotated)
		active_shape_lbl.text = "Góc: %s | %s (%dx%d)" % [
			rot_text,
			str(selected_item.get("name", "Vật phẩm")),
			fp.x,
			fp.y
		]
	else:
		active_shape_lbl.text = "Góc xoay: %s" % rot_text

func _compute_sync_signature() -> String:
	var packed_ids := []
	for it in packed_items:
		packed_ids.append(_item_key(it))
	var avail_ids := []
	for it in available_items:
		avail_ids.append(_item_key(it))
	var table_cnt := table_grid.get_child_count() if table_grid else 0
	return "%s|%s|%d|%d" % [
		",".join(packed_ids),
		",".join(avail_ids),
		table_cnt,
		tetris_placements.size()
	]

func _sync_gp_ed_04_state() -> void:
	# Prune placements whose item was removed from packed_items
	var kept: Array = []
	for p in tetris_placements:
		var pit: Dictionary = p.get("item", {})
		if _is_item_packed(pit):
			kept.append(p)
	tetris_placements = kept

	# Auto-place items present in packed_items without a Tetris slot yet
	for it in packed_items:
		if not _has_placement_for_item(it):
			_auto_place_item_in_grid(it)

	_rebuild_cork_checklist()
	_refresh_tetris_grid_visuals()
	_decorate_table_items()
	_update_rotate_label()

func _item_key(item: Dictionary) -> String:
	if item.has("id") and str(item["id"]) != "":
		return str(item["id"])
	return str(item.get("name", ""))

func _is_item_packed(item: Dictionary) -> bool:
	var k := _item_key(item)
	for it in packed_items:
		if _item_key(it) == k:
			return true
	return false

func _has_placement_for_item(item: Dictionary) -> bool:
	var k := _item_key(item)
	for p in tetris_placements:
		if _item_key(p.get("item", {})) == k:
			return true
	return false

func _build_backpack_grid_container(grid_name: String, rows_count: int) -> GridContainer:
	var grid := GridContainer.new()
	grid.name = grid_name
	grid.columns = GRID_COLS
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	for y in range(rows_count):
		for x in range(GRID_COLS):
			var cell_btn := Button.new()
			cell_btn.name = "Cell_%d_%d" % [x, y]
			cell_btn.custom_minimum_size = Vector2(62, 50 if rows_count > 3 else 56)
			cell_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			cell_btn.text = "·"
			cell_btn.expand_icon = true
			var origin := Vector2i(x, y)
			cell_btn.pressed.connect(func(): _on_tetris_cell_pressed(origin))
			cell_btn.mouse_entered.connect(func():
				ghost_hover_origin = origin
				_refresh_tetris_grid_visuals()
			)
			cell_btn.mouse_exited.connect(func():
				if ghost_hover_origin == origin:
					ghost_hover_origin = Vector2i(-1, -1)
					_refresh_tetris_grid_visuals()
			)
			cell_btn.gui_input.connect(func(ev: InputEvent):
				if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_RIGHT:
					_on_rotate_item_pressed()
				elif ev is InputEventScreenTouch and ev.pressed and ev.index >= 1:
					_on_rotate_item_pressed()
			)
			cell_btn.set_drag_forwarding(
				Callable(),
				func(_pos, drag_data):
					ghost_hover_origin = origin
					_refresh_tetris_grid_visuals()
					return _can_drop_on_cell(drag_data, origin),
				func(_pos, drag_data):
					ghost_hover_origin = Vector2i(-1, -1)
					_drop_on_cell(drag_data, origin)
			)
			grid.add_child(cell_btn)
	return grid

func enable_4x5_grid(enable: bool = true) -> void:
	active_grid_rows = 5 if enable else 3
	if tetris_grid_4x3:
		tetris_grid_4x3.visible = not enable
	if tetris_grid_4x5:
		tetris_grid_4x5.visible = enable
	if btn_toggle_4x5:
		btn_toggle_4x5.text = "📐 Ngăn 4×3" if enable else "📐 Ngăn 4×5"
	_refresh_tetris_grid_visuals()

func _active_grid_node() -> GridContainer:
	if active_grid_rows == 5 and tetris_grid_4x5:
		return tetris_grid_4x5
	return tetris_grid_4x3

func get_item_footprint(item: Dictionary, rotated: bool = false) -> Vector2i:
	var base := Vector2i(1, 1)
	if item.has("grid_size"):
		var raw = item["grid_size"]
		if raw is Vector2i:
			base = raw
		elif raw is Array and raw.size() >= 2:
			base = Vector2i(int(raw[0]), int(raw[1]))
	else:
		var k := _item_key(item).to_lower()
		var nm := str(item.get("name", "")).to_lower()
		if "bandage" in k or "băng" in nm or "first_aid" in k or "sơ cứu" in nm:
			base = Vector2i(2, 1)
		elif "oresol" in k or "thermos" in k or "nước" in nm or "bình" in nm:
			base = Vector2i(1, 2)
		elif "clipboard" in k or "hồ sơ" in nm or "blanket" in k or "chăn" in nm:
			base = Vector2i(2, 2)
		elif "pen" in k or "bút" in nm or "thước" in nm:
			base = Vector2i(2, 2)
	if rotated:
		return Vector2i(base.y, base.x)
	return base

func get_item_cells(item: Dictionary, rotated: bool = false) -> Array[Vector2i]:
	var k := _item_key(item).to_lower()
	var nm := str(item.get("name", "")).to_lower()
	if "pen" in k or "bút" in nm or "thước" in nm:
		if rotated:
			return [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)]
		return [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1)]
	var fp := get_item_footprint(item, rotated)
	var cells: Array[Vector2i] = []
	for dy in range(fp.y):
		for dx in range(fp.x):
			cells.append(Vector2i(dx, dy))
	return cells

func _occupied_map(ignore_key: String = "") -> Dictionary:
	var occ: Dictionary = {}
	for p in tetris_placements:
		var pit: Dictionary = p.get("item", {})
		var pk := _item_key(pit)
		if ignore_key != "" and pk == ignore_key:
			continue
		var ori: Vector2i = p.get("origin", Vector2i.ZERO)
		var rot: bool = bool(p.get("rotated", false))
		var pcells := get_item_cells(pit, rot)
		for rel in pcells:
			occ[ori + rel] = p
	return occ

func can_place_in_grid(item: Dictionary, origin: Vector2i, rotated: bool = false) -> bool:
	var cells := get_item_cells(item, rotated)
	var occ := _occupied_map(_item_key(item))
	for rel in cells:
		var c := origin + rel
		if c.x < 0 or c.y < 0 or c.x >= GRID_COLS or c.y >= active_grid_rows:
			return false
		if occ.has(c):
			return false
	return true

func place_item_at_cell(item: Dictionary, origin: Vector2i, rotated: bool = false) -> bool:
	if not _is_item_packed(item) and packed_items.size() >= max_slots:
		return false
	if not can_place_in_grid(item, origin, rotated):
		return false
	remove_item_from_grid(item, false)
	var fp := get_item_footprint(item, rotated)
	tetris_placements.append({
		"item": item,
		"origin": origin,
		"size": fp,
		"rotated": rotated
	})
	if not _is_item_packed(item):
		packed_items.append(item)
		_render_backpack_slots()
		_render_table_items()
		_update_action_button()
	if SoundManager.has_method("vibrate"):
		SoundManager.vibrate(15)
	_refresh_tetris_grid_visuals()
	_rebuild_cork_checklist()
	return true

func remove_item_from_grid(item: Dictionary, also_unpack: bool = true) -> void:
	var k := _item_key(item)
	if k == "mochi_yarn_toy":
		mochi_yarn_in_backpack = false
		SoundManager.play_meow(1.1)
		cat_speech.text = "Meow~ Cảm ơn Sen trả lại Cuộn Len cho Mochi nè! 🧶"
	var remaining: Array = []
	for p in tetris_placements:
		if _item_key(p.get("item", {})) != k:
			remaining.append(p)
	tetris_placements = remaining
	if also_unpack and _is_item_packed(item):
		for i in range(packed_items.size() - 1, -1, -1):
			if _item_key(packed_items[i]) == k:
				packed_items.remove_at(i)
		_render_backpack_slots()
		_render_table_items()
		_update_action_button()
	_refresh_tetris_grid_visuals()
	_rebuild_cork_checklist()

func _auto_place_item_in_grid(item: Dictionary) -> bool:
	var tries := [is_item_rotated, not is_item_rotated]
	for rot in tries:
		for y in range(active_grid_rows):
			for x in range(GRID_COLS):
				var origin := Vector2i(x, y)
				if can_place_in_grid(item, origin, rot):
					tetris_placements.append({
						"item": item,
						"origin": origin,
						"size": get_item_footprint(item, rot),
						"rotated": rot
					})
					return true
	return false

func spawn_mochi_mischief_toy() -> bool:
	if mochi_yarn_in_backpack:
		return true
	var yarn_item := {
		"id": "mochi_yarn_toy",
		"name": "Cuộn Len",
		"icon": "🧶",
		"is_required": false,
		"is_mochi_toy": true
	}
	var occ := _occupied_map()
	for y in range(active_grid_rows - 1, -1, -1):
		for x in range(GRID_COLS - 1, -1, -1):
			var c := Vector2i(x, y)
			if not occ.has(c):
				tetris_placements.append({
					"item": yarn_item,
					"origin": c,
					"size": Vector2i(1, 1),
					"rotated": false
				})
				mochi_yarn_in_backpack = true
				SoundManager.play_giggle()
				cat_speech.text = "Hihi~ Mochi lén nhét Cuộn Len 🧶 vào góc ba lô rồi nè!"
				_refresh_tetris_grid_visuals()
				return true
	return false

func _on_tetris_cell_pressed(origin: Vector2i) -> void:
	var occ := _occupied_map()
	if occ.has(origin):
		var placement: Dictionary = occ[origin]
		remove_item_from_grid(placement.get("item", {}), true)
		return
	if not selected_item.is_empty():
		place_item_at_cell(selected_item, origin, is_item_rotated)

func _can_drop_on_cell(drag_data, origin: Vector2i) -> bool:
	if not (drag_data is Dictionary) or not drag_data.has("item"):
		return false
	return can_place_in_grid(drag_data["item"], origin, is_item_rotated)

func _drop_on_cell(drag_data, origin: Vector2i) -> void:
	if not (drag_data is Dictionary) or not drag_data.has("item"):
		return
	var item: Dictionary = drag_data["item"]
	selected_item = item
	place_item_at_cell(item, origin, is_item_rotated)

func _rebuild_cork_checklist() -> void:
	if not checklist_vbox:
		return
	for ch in checklist_vbox.get_children():
		ch.queue_free()

	for it in available_items:
		if not it.get("is_required", false):
			continue
		var done := _is_item_packed(it)
		var fp := get_item_footprint(it, is_item_rotated)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)

		var ico := TextureRect.new()
		ico.texture = _get_item_pixel_texture(it)
		ico.custom_minimum_size = Vector2(20, 20)
		ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(ico)

		var lbl := Label.new()
		lbl.text = "%s %s (%dx%d)" % [
			"[✅]" if done else "[ ]",
			str(it.get("name", "Vật phẩm")),
			fp.x,
			fp.y
		]
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.add_theme_color_override(
			"font_color",
			Color(0.10, 0.48, 0.22) if done else Color(0.28, 0.18, 0.10)
		)
		row.add_child(lbl)
		checklist_vbox.add_child(row)

func _refresh_tetris_grid_visuals() -> void:
	var occ := _occupied_map()
	var ghost_cells: Dictionary = {}
	var ghost_valid: bool = false
	if ghost_hover_origin.x >= 0 and not selected_item.is_empty():
		ghost_valid = can_place_in_grid(selected_item, ghost_hover_origin, is_item_rotated)
		for rel in get_item_cells(selected_item, is_item_rotated):
			ghost_cells[ghost_hover_origin + rel] = true

	var grids := [[tetris_grid_4x3, 3], [tetris_grid_4x5, 5]]
	for entry in grids:
		var grid: GridContainer = entry[0]
		var rows_cnt: int = entry[1]
		if not grid:
			continue
		for y in range(rows_cnt):
			for x in range(GRID_COLS):
				var idx := y * GRID_COLS + x
				if idx >= grid.get_child_count():
					continue
				var cell_btn := grid.get_child(idx) as Button
				if not cell_btn:
					continue
				var pos := Vector2i(x, y)
				if ghost_cells.has(pos):
					cell_btn.modulate = Color(0.75, 1.0, 0.78) if ghost_valid else Color(1.0, 0.72, 0.45)
				elif occ.has(pos):
					var placement: Dictionary = occ[pos]
					var pit: Dictionary = placement.get("item", {})
					var is_origin: bool = placement.get("origin", Vector2i.ZERO) == pos
					var is_req := bool(pit.get("is_required", false))
					cell_btn.icon = _get_item_pixel_texture(pit) if is_origin else null
					cell_btn.text = str(pit.get("name", "")).substr(0, 6) if is_origin else "▪"
					cell_btn.modulate = Color(0.84, 1.0, 0.86) if is_req else Color(1.0, 0.88, 0.84)
				else:
					cell_btn.icon = null
					cell_btn.text = "·"
					cell_btn.modulate = Color(1.0, 1.0, 1.0)

func _decorate_table_items() -> void:
	if not table_grid:
		return
	for ch in table_grid.get_children():
		if not (ch is Control):
			continue
		var ctrl := ch as Control
		ctrl.custom_minimum_size.y = maxf(ctrl.custom_minimum_size.y, 56.0)
		if ctrl.has_meta("gp_ed_04_decorated"):
			continue
		ctrl.set_meta("gp_ed_04_decorated", true)
		var matched_item := _match_item_for_table_child(ctrl)
		if matched_item.is_empty():
			continue
		var tex := _get_item_pixel_texture(matched_item)
		if ctrl is Button:
			var b := ctrl as Button
			b.icon = tex
			b.expand_icon = true
			b.pressed.connect(func():
				selected_item = matched_item
				_update_rotate_label()
			)
		ctrl.set_drag_forwarding(
			func(_pos):
				selected_item = matched_item
				_update_rotate_label()
				var preview := TextureRect.new()
				preview.texture = tex
				preview.custom_minimum_size = Vector2(40, 40)
				preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				set_drag_preview(preview)
				return {"item": matched_item, "rotated": is_item_rotated},
			Callable(),
			Callable()
		)

func _refresh_table_item_footprints() -> void:
	_rebuild_cork_checklist()

func _match_item_for_table_child(ctrl: Control) -> Dictionary:
	var txt := ""
	if ctrl is Button:
		txt = (ctrl as Button).text.to_lower()
	else:
		for sub in ctrl.find_children("*", "Label", true, false):
			txt += " " + (sub as Label).text.to_lower()
	for it in available_items:
		var nm := str(it.get("name", "")).to_lower()
		if nm != "" and nm in txt:
			return it
	return {}

func _get_item_pixel_texture(item: Dictionary) -> Texture2D:
	var k := _item_key(item).to_lower()
	var nm := str(item.get("name", "")).to_lower()
	if k == "mochi_yarn_toy" or "cuộn len" in nm:
		return TEX_MOCHI_YARN
	if "pen" in k or "bút" in nm or "thước" in nm:
		return TEX_ITEM_PEN
	if "key" in k or "chìa" in nm or "chia" in nm:
		return TEX_ITEM_KEY
	if "bandage" in k or "first_aid" in k or "băng" in nm or "sơ cứu" in nm:
		return TEX_ITEM_FIRST_AID
	if "oresol" in k or "thermos" in k or "nước" in nm or "bình" in nm:
		return TEX_ITEM_THERMOS
	if "thermo" in k or "nhiệt" in nm:
		return TEX_ITEM_THERMO
	if "coffee" in k or "cafe" in k or "trà" in nm:
		return TEX_ITEM_COFFEE
	if "para" in k or "berberin" in k or "thuốc" in nm or "viên" in nm:
		return TEX_ITEM_PILL
	return TEX_ITEM_CLIPBOARD

func _trigger_packing_safe_failure(dialog_msg: String, _forgot_key: bool) -> void:
	safe_failure_count += 1
	if SoundManager.has_method("play_giggle"):
		SoundManager.play_giggle()
	if cat_anchor:
		var tw := create_tween()
		tw.tween_property(cat_anchor, "rotation", 0.2, 0.15).set_trans(Tween.TRANS_SINE)
		tw.tween_property(cat_anchor, "rotation", -0.2, 0.15).set_trans(Tween.TRANS_SINE)
		tw.tween_property(cat_anchor, "rotation", 0.0, 0.15).set_trans(Tween.TRANS_SINE)
	if packing_cozy_dialog and packing_cozy_dialog.has_method("show_dialog"):
		packing_cozy_dialog.show_dialog(
			dialog_msg,
			"playful",
			"Gợi ý Boss Mèo: Bấm Xoay Món (90°) hoặc bỏ đồ thừa ra ngoài nhé!"
		)
