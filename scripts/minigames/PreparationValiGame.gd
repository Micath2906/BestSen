extends Control

# PreparationValiGame.gd - Game 1: Lời Dặn Dò Của Mẹ Khi Chuẩn Bị Lên Đại Học
# Gameplay 2 giai đoạn:
# Phase 1: Xếp đồ vào đúng vị trí trong Vali tân sinh viên (Vali Packing Puzzle)
# Phase 2: Game điền khuyết để dán nhãn đúng công dụng các loại thuốc sinh hoạt và ghi nhớ lưu ý của Mẹ

signal minigame_completed(sim_steps)
signal back_requested

# =========================================================================
# LỚP HỖ TRỢ NATIVE DRAG & DROP CHO PHASE 1 & PHASE 2
# =========================================================================
class DraggableValiItem extends PanelContainer:
	var item_data: Dictionary = {}
	var game_ref: Control = null
	var is_placed: bool = false
	
	func _get_drag_data(_at_position: Vector2) -> Variant:
		if is_placed or game_ref == null:
			return null
		SoundManager.play_card_pop()
		var preview = game_ref._create_drag_preview_for_item(item_data)
		set_drag_preview(preview)
		return {"type": "vali_item", "item": item_data}
		
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if not is_placed and game_ref != null:
				game_ref._on_item_tap_selected(item_data)

class DroppableSuitcaseSlot extends PanelContainer:
	var slot_data: Dictionary = {}
	var game_ref: Control = null
	var is_filled: bool = false
	
	func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
		if is_filled or game_ref == null:
			return false
		return data is Dictionary and data.get("type") == "vali_item"
		
	func _drop_data(_at_position: Vector2, data: Variant) -> void:
		if game_ref != null and data.has("item"):
			game_ref._attempt_pack_item_to_slot(data["item"], slot_data["slot_id"])
			
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if game_ref != null:
				if not game_ref.selected_item_for_pack.is_empty():
					game_ref._attempt_pack_item_to_slot(game_ref.selected_item_for_pack, slot_data["slot_id"])
				elif is_filled:
					game_ref._remove_item_from_slot(slot_data["slot_id"])

class DraggableMedLabel extends PanelContainer:
	var label_text: String = ""
	var game_ref: Control = null
	var is_used: bool = false
	
	func _get_drag_data(_at_position: Vector2) -> Variant:
		if is_used or game_ref == null:
			return null
		SoundManager.play_card_pop()
		var preview = game_ref._create_drag_preview_for_label(label_text)
		set_drag_preview(preview)
		return {"type": "med_label", "label": label_text}
		
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if not is_used and game_ref != null:
				game_ref._on_label_tap_selected(label_text)

class DroppableMedBlank extends PanelContainer:
	var med_id: String = ""
	var game_ref: Control = null
	var is_solved: bool = false
	
	func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
		if is_solved or game_ref == null:
			return false
		return data is Dictionary and data.get("type") == "med_label"
		
	func _drop_data(_at_position: Vector2, data: Variant) -> void:
		if game_ref != null and data.has("label"):
			game_ref._attempt_fill_label_to_medicine(data["label"], med_id)
			
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if game_ref != null:
				if game_ref.selected_label_for_fill != "":
					game_ref._attempt_fill_label_to_medicine(game_ref.selected_label_for_fill, med_id)
				elif is_solved:
					game_ref._remove_label_from_medicine(med_id)

# =========================================================================
# UI NODES
# =========================================================================
@onready var btn_back: Button = $Header/BtnBack
@onready var btn_guide: Button = $Header/BtnGuide
@onready var title_lbl: Label = $Header/TitleLabel
@onready var mother_speech: Label = $MascotSection/HBox/SpeechBubble/MotherSpeech
@onready var cat_avatar_anchor: Control = $MascotSection/HBox/CatAnchor
@onready var phase_pill_1: Label = $PhaseBar/HBox/Phase1Pill
@onready var phase_pill_2: Label = $PhaseBar/HBox/Phase2Pill

# Khu vực Phase 1: Xếp Vali
@onready var phase1_container: VBoxContainer = $ContentScroll/VBox/Phase1Section
@onready var suitcase_grid: GridContainer = $ContentScroll/VBox/Phase1Section/SuitcaseCard/VBox/SuitcaseGrid
@onready var vali_count_lbl: Label = $ContentScroll/VBox/Phase1Section/SuitcaseCard/VBox/HeaderHBox/ValiCountLabel
@onready var items_pool_grid: GridContainer = $ContentScroll/VBox/Phase1Section/ItemsPoolCard/VBox/ItemsGrid
@onready var btn_go_phase2: Button = $ContentScroll/VBox/Phase1Section/BtnGoPhase2

# Khu vực Phase 2: Dán nhãn thuốc
@onready var phase2_container: VBoxContainer = $ContentScroll/VBox/Phase2Section
@onready var medicines_list_vbox: VBoxContainer = $ContentScroll/VBox/Phase2Section/MedBoxCard/VBox/MedicinesList
@onready var med_count_lbl: Label = $ContentScroll/VBox/Phase2Section/MedBoxCard/VBox/HeaderHBox/MedCountLabel
@onready var labels_pool_container: HFlowContainer = $ContentScroll/VBox/Phase2Section/LabelsPoolCard/VBox/LabelsHFlow
@onready var btn_finish_game: Button = $ContentScroll/VBox/Phase2Section/BtnFinishGame

# Modal Hướng dẫn / Cẩm nang của Mẹ
@onready var guide_modal: Control = $GuideModal
@onready var guide_text: Label = $GuideModal/ModalPanel/VBox/Scroll/GuideText
@onready var btn_close_guide: Button = $GuideModal/ModalPanel/VBox/BtnCloseGuide

# Modal Chiến Thắng
@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

var data: Dictionary = {}
var current_phase: int = 1

# Trạng thái Phase 1 (Xếp Vali)
var suitcase_slots: Array = []
var available_items: Array = []
var packed_slots: Dictionary = {} # slot_id -> item Dictionary
var selected_item_for_pack: Dictionary = {}

# Trạng thái Phase 2 (Dán nhãn thuốc)
var medicine_puzzles: Array = []
var puzzle_options: Array = []
var solved_medicines: Dictionary = {} # med_id -> label_text
var selected_label_for_fill: String = ""

var cat_anim: AnimatedSprite2D = null

func _ready() -> void:
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(func():
		SoundManager.play_click()
		emit_signal("back_requested")
	)
	btn_guide.pressed.connect(_open_guide)
	btn_close_guide.pressed.connect(func():
		SoundManager.play_click()
		guide_modal.visible = false
	)
	btn_go_phase2.pressed.connect(_switch_to_phase2)
	btn_finish_game.pressed.connect(_on_finish_game_pressed)
	btn_claim_reward.pressed.connect(_on_claim_reward_pressed)
	
	_setup_cat_mascot()
	
	# Mặc định nạp dữ liệu Lesson 1 nếu chưa load_minigame
	if data.is_empty():
		var mg_data = GameManager.get_minigame_data(1)
		if not mg_data.is_empty():
			load_minigame(mg_data)

func _setup_cat_mascot() -> void:
	if cat_anim == null and cat_avatar_anchor:
		cat_anim = AnimatedSprite2D.new()
		cat_anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		cat_anim.position = Vector2(28, 28)
		cat_anim.scale = Vector2(2.0, 2.0)
		cat_avatar_anchor.add_child(cat_anim)
		cat_anim.sprite_frames = CatAnimationFactory.get_sprite_frames(GameManager.selected_avatar_id)
		cat_anim.play("idle2")

func load_minigame(game_data: Dictionary) -> void:
	data = game_data
	title_lbl.text = "🎒 " + data.get("title", "LỜI DẶN DÒ CỦA MẸ").to_upper()
	
	# Nạp cấu hình Phase 1
	suitcase_slots = data.get("suitcase_slots", []).duplicate()
	available_items = data.get("available_items", []).duplicate()
	packed_slots.clear()
	selected_item_for_pack.clear()
	
	# Nạp cấu hình Phase 2
	medicine_puzzles = data.get("medicine_puzzles", []).duplicate()
	puzzle_options = data.get("puzzle_options", []).duplicate()
	solved_medicines.clear()
	selected_label_for_fill = ""
	
	_setup_guide_content()
	_set_phase(1)

func _setup_guide_content() -> void:
	var g = "🌸 LỜI MẸ DẶN DÒ TÂN SINH VIÊN KHI LÊN ĐẠI HỌC 🌸\n\n"
	g += "1. XẾP VALI NGĂN NẮP (4 NGĂN THIẾT YẾU):\n"
	g += "  💊 Ngăn Thuốc & Y Tế: Để trên cùng hoặc túi phụ dễ lấy khi ốm khẩn cấp.\n"
	g += "  📁 Ngăn Hồ Sơ & Giấy Tờ: Giữ phẳng giấy báo nhập học, CCCD, thẻ BHYT.\n"
	g += "  👕 Ngăn Trang Phục: Cuộn tròn quần áo, khăn tắm và đồ dùng vệ sinh.\n"
	g += "  💻 Ngăn Thiết Bị Điện Tử: Ngăn chống sốc bảo vệ laptop và dây sạc.\n"
	g += "  🚫 Không mang đồ cồng kềnh vô ích: Gấu bông to, nồi lẩu khổng lồ, loa thùng...\n\n"
	g += "2. DÁN NHÃN THUỐC & LƯU Ý AN TOÀN:\n"
	for m in data.get("medicine_puzzles", []):
		g += "  • %s: %s\n    ➔ %s\n" % [m["med_name"], m["correct_label"], m["mother_advice"]]
	g += "\n💡 MẸO TỪ MẸ: Khi tự lập một mình, phòng bệnh hơn chữa bệnh. Ốm đau hãy uống đúng liều và nghỉ ngơi điều độ nhé con yêu!"
	guide_text.text = g

func _open_guide() -> void:
	SoundManager.play_click()
	guide_modal.visible = true

func _set_phase(p: int) -> void:
	current_phase = p
	if current_phase == 1:
		phase1_container.visible = true
		phase2_container.visible = false
		_highlight_phase_pill(phase_pill_1, true)
		_highlight_phase_pill(phase_pill_2, false)
		mother_speech.text = "Con sắp xa nhà lên đại học rồi, hãy xếp các đồ đạc cần thiết vào đúng 4 ngăn trong vali nhé con!"
		_render_suitcase_slots()
		_render_items_pool()
		_update_phase1_button()
	elif current_phase == 2:
		phase1_container.visible = false
		phase2_container.visible = true
		_highlight_phase_pill(phase_pill_1, false)
		_highlight_phase_pill(phase_pill_2, true)
		mother_speech.text = "Giỏi lắm! Giờ hãy mở Hộp Thuốc Của Mẹ, dán đúng nhãn công dụng và đọc kỹ lời dặn của Mẹ nhé!"
		_render_medicines_list()
		_render_labels_pool()
		_update_phase2_button()

func _highlight_phase_pill(pill: Label, is_active: bool) -> void:
	var s = StyleBoxFlat.new()
	s.set_corner_radius_all(12)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 4
	s.content_margin_bottom = 4
	if is_active:
		s.bg_color = Color(0.95, 0.55, 0.15, 1.0)
		s.border_color = Color(0.80, 0.40, 0.08, 1.0)
		s.set_border_width_all(2)
		pill.add_theme_color_override("font_color", Color(1, 1, 1))
	else:
		s.bg_color = Color(0.92, 0.90, 0.86, 0.6)
		s.border_color = Color(0.82, 0.78, 0.72, 1.0)
		s.set_border_width_all(1)
		pill.add_theme_color_override("font_color", Color(0.55, 0.50, 0.45))
	pill.add_theme_stylebox_override("normal", s)

# =========================================================================
# PHASE 1: XẾP ĐỒ VÀO VALI (VALI PACKING PUZZLE)
# =========================================================================
func _render_suitcase_slots() -> void:
	for child in suitcase_grid.get_children():
		suitcase_grid.remove_child(child)
		child.queue_free()
		
	var filled_count = packed_slots.size()
	vali_count_lbl.text = "Đã xếp: %d/4 ngăn" % filled_count
	
	for slot_info in suitcase_slots:
		var slot_id = slot_info["slot_id"]
		var is_filled = packed_slots.has(slot_id)
		
		var slot_p = DroppableSuitcaseSlot.new()
		slot_p.slot_data = slot_info
		slot_p.game_ref = self
		slot_p.is_filled = is_filled
		slot_p.custom_minimum_size = Vector2(230, 96)
		slot_p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_p.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var s = StyleBoxFlat.new()
		s.set_corner_radius_all(12)
		s.content_margin_left = 10
		s.content_margin_right = 10
		s.content_margin_top = 8
		s.content_margin_bottom = 8
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 2)
		
		if is_filled:
			var it = packed_slots[slot_id]
			s.bg_color = Color.from_string(slot_info.get("color", "#FFF8E7"), Color(1, 0.98, 0.94))
			s.border_color = Color.from_string(slot_info.get("border_color", "#FFA726"), Color(0.9, 0.6, 0.2))
			s.set_border_width_all(2)
			
			var header_row = HBoxContainer.new()
			var ic = Label.new()
			ic.text = it.get("icon", "📦")
			ic.add_theme_font_size_override("font_size", 22)
			header_row.add_child(ic)
			
			var nm = Label.new()
			nm.text = it.get("name", "")
			nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			nm.add_theme_font_size_override("font_size", 12)
			nm.add_theme_color_override("font_color", Color(0.2, 0.15, 0.1))
			header_row.add_child(nm)
			
			var btn_del = Button.new()
			btn_del.text = "✖"
			btn_del.custom_minimum_size = Vector2(24, 24)
			btn_del.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			btn_del.pressed.connect(func(): _remove_item_from_slot(slot_id))
			header_row.add_child(btn_del)
			vbox.add_child(header_row)
			
			var desc = Label.new()
			desc.text = "✓ " + slot_info.get("name", "")
			desc.add_theme_font_size_override("font_size", 10)
			desc.add_theme_color_override("font_color", Color(0.15, 0.55, 0.25))
			vbox.add_child(desc)
		else:
			s.bg_color = Color(0.96, 0.94, 0.90, 0.7)
			s.border_color = Color(0.80, 0.75, 0.68, 1.0)
			s.set_border_width_all(2)
			
			var ic = Label.new()
			ic.text = slot_info.get("icon", "📦")
			ic.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			ic.add_theme_font_size_override("font_size", 20)
			vbox.add_child(ic)
			
			var title = Label.new()
			title.text = slot_info.get("name", "")
			title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			title.add_theme_font_size_override("font_size", 11)
			title.add_theme_color_override("font_color", Color(0.35, 0.30, 0.25))
			vbox.add_child(title)
			
			var prompt = Label.new()
			prompt.text = "[Kéo hoặc chạm đồ vào đây]"
			prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			prompt.add_theme_font_size_override("font_size", 9)
			prompt.add_theme_color_override("font_color", Color(0.65, 0.60, 0.55))
			vbox.add_child(prompt)
			
		slot_p.add_theme_stylebox_override("panel", s)
		slot_p.add_child(vbox)
		suitcase_grid.add_child(slot_p)

func _render_items_pool() -> void:
	for child in items_pool_grid.get_children():
		items_pool_grid.remove_child(child)
		child.queue_free()
		
	for it in available_items:
		var is_placed = false
		for s_id in packed_slots:
			if packed_slots[s_id]["id"] == it["id"]:
				is_placed = true
				break
				
		var item_card = DraggableValiItem.new()
		item_card.item_data = it
		item_card.game_ref = self
		item_card.is_placed = is_placed
		item_card.custom_minimum_size = Vector2(230, 68)
		item_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		item_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var s = StyleBoxFlat.new()
		s.set_corner_radius_all(10)
		s.content_margin_left = 8
		s.content_margin_right = 8
		s.content_margin_top = 6
		s.content_margin_bottom = 6
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 2)
		
		var is_selected = (not selected_item_for_pack.is_empty() and selected_item_for_pack["id"] == it["id"])
		
		if is_placed:
			s.bg_color = Color(0.92, 0.90, 0.88, 0.5)
			s.border_color = Color(0.80, 0.75, 0.70, 0.7)
			s.set_border_width_all(1)
		elif is_selected:
			s.bg_color = Color(1.0, 0.95, 0.85, 1.0)
			s.border_color = Color(0.95, 0.55, 0.15, 1.0)
			s.set_border_width_all(2)
		else:
			s.bg_color = Color(1.0, 1.0, 1.0, 0.95)
			s.border_color = Color(0.88, 0.80, 0.72, 1.0)
			s.set_border_width_all(1)
			s.border_width_bottom = 2
			
		var top_row = HBoxContainer.new()
		var ic = Label.new()
		ic.text = it.get("icon", "📦")
		ic.add_theme_font_size_override("font_size", 18)
		top_row.add_child(ic)
		
		var nm = Label.new()
		nm.text = it.get("name", "")
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nm.add_theme_font_size_override("font_size", 11)
		nm.add_theme_color_override("font_color", Color(0.2, 0.15, 0.1) if not is_placed else Color(0.6, 0.55, 0.5))
		top_row.add_child(nm)
		vbox.add_child(top_row)
		
		var desc = Label.new()
		desc.text = it.get("desc", "")
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.add_theme_font_size_override("font_size", 9)
		desc.add_theme_color_override("font_color", Color(0.45, 0.40, 0.35) if not is_placed else Color(0.65, 0.60, 0.55))
		vbox.add_child(desc)
		
		item_card.add_theme_stylebox_override("panel", s)
		item_card.add_child(vbox)
		items_pool_grid.add_child(item_card)

func _create_drag_preview_for_item(item: Dictionary) -> Control:
	var prev = PanelContainer.new()
	prev.custom_minimum_size = Vector2(160, 48)
	var s = StyleBoxFlat.new()
	s.bg_color = Color(1.0, 0.95, 0.85, 0.95)
	s.border_color = Color(0.95, 0.55, 0.15, 1.0)
	s.set_border_width_all(2)
	s.set_corner_radius_all(10)
	prev.add_theme_stylebox_override("panel", s)
	
	var lbl = Label.new()
	lbl.text = "%s %s" % [item.get("icon", "📦"), item.get("name", "")]
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.2, 0.15, 0.1))
	prev.add_child(lbl)
	return prev

func _on_item_tap_selected(item: Dictionary) -> void:
	SoundManager.play_click()
	if not item.get("is_required", false):
		# Món đồ bẫy/thừa thãi -> Mẹ dặn dò hài hước
		SoundManager.play_fail()
		var humor_msg = item.get("humor", "Vali chật ních rồi con ơi, để ở nhà nhé!")
		mother_speech.text = "Ôi con ơi! 😵 " + humor_msg
		selected_item_for_pack.clear()
		_render_items_pool()
		return
		
	if not selected_item_for_pack.is_empty() and selected_item_for_pack["id"] == item["id"]:
		selected_item_for_pack.clear()
	else:
		selected_item_for_pack = item
		mother_speech.text = "Đã chọn [%s]! Bây giờ hãy chạm vào ngăn vali phù hợp nhé!" % item.get("name", "")
	_render_items_pool()

func _attempt_pack_item_to_slot(item: Dictionary, slot_id: String) -> void:
	if not item.get("is_required", false):
		SoundManager.play_fail()
		var humor_msg = item.get("humor", "Vali chật ních rồi con ơi, để ở nhà nhé!")
		mother_speech.text = "Khoan đã con ơi! 😵 " + humor_msg
		selected_item_for_pack.clear()
		_render_items_pool()
		return
		
	var target_slot = item.get("target_slot", "")
	if target_slot != slot_id:
		SoundManager.play_fail()
		mother_speech.text = "Nhầm ngăn rồi con ơi! '%s' phải xếp vào ngăn khác mới đúng vị trí và giữ an toàn!" % item.get("name", "")
		selected_item_for_pack.clear()
		_render_items_pool()
		return
		
	SoundManager.play_card_pop()
	packed_slots[slot_id] = item
	selected_item_for_pack.clear()
	mother_speech.text = "Tách! ✨ Đã xếp [%s] gọn gàng vào vali rồi nhé con!" % item.get("name", "")
	_render_suitcase_slots()
	_render_items_pool()
	_update_phase1_button()

func _remove_item_from_slot(slot_id: String) -> void:
	if packed_slots.has(slot_id):
		SoundManager.play_click()
		var it = packed_slots[slot_id]
		packed_slots.erase(slot_id)
		mother_speech.text = "Đã lấy [%s] ra khỏi vali! Hãy xếp lại cho chuẩn nhé!" % it.get("name", "")
		_render_suitcase_slots()
		_render_items_pool()
		_update_phase1_button()

func _update_phase1_button() -> void:
	if packed_slots.size() == 4:
		btn_go_phase2.disabled = false
		btn_go_phase2.text = "🔒 KHÓA VALI & TIẾP TỤC: DÁN NHÃN THUỐC CỦA MẸ ➔"
		btn_go_phase2.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		SoundManager.play_success()
		mother_speech.text = "🎉 Tuyệt vời! Vali 4 ngăn đã xếp ngăn nắp! Bây giờ hãy chuyển sang dán nhãn Hộp Thuốc Của Mẹ nhé!"
	else:
		btn_go_phase2.disabled = true
		btn_go_phase2.text = "🎒 CẦN XẾP ĐỦ 4 NGĂN VALI (%d/4)" % packed_slots.size()
		btn_go_phase2.add_theme_color_override("font_disabled_color", Color(0.38, 0.28, 0.20, 1.0))

func _switch_to_phase2() -> void:
	SoundManager.play_click()
	_set_phase(2)

# =========================================================================
# PHASE 2: DÁN NHÃN THUỐC & ĐIỀN KHUYẾT LỜI MẸ DẶN
# =========================================================================
func _render_medicines_list() -> void:
	for child in medicines_list_vbox.get_children():
		medicines_list_vbox.remove_child(child)
		child.queue_free()
		
	var solved_count = solved_medicines.size()
	med_count_lbl.text = "Đã dán nhãn: %d/5 loại thuốc" % solved_count
	
	for med in medicine_puzzles:
		var med_id = med["id"]
		var is_solved = solved_medicines.has(med_id)
		
		var med_panel = PanelContainer.new()
		med_panel.custom_minimum_size = Vector2(0, 110 if is_solved else 78)
		med_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var s = StyleBoxFlat.new()
		s.set_corner_radius_all(12)
		s.content_margin_left = 12
		s.content_margin_right = 12
		s.content_margin_top = 8
		s.content_margin_bottom = 8
		
		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 4)
		
		# Hàng 1: Icon + Tên thuốc + Phân loại
		var top_row = HBoxContainer.new()
		var ic = Label.new()
		ic.text = med.get("icon", "💊")
		ic.add_theme_font_size_override("font_size", 22)
		top_row.add_child(ic)
		
		var name_lbl = Label.new()
		name_lbl.text = "%s (%s)" % [med.get("med_name", ""), med.get("med_type", "")]
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_font_size_override("font_size", 12)
		name_lbl.add_theme_color_override("font_color", Color(0.25, 0.18, 0.12))
		top_row.add_child(name_lbl)
		
		if is_solved:
			var badge = Label.new()
			badge.text = "✓ ĐÃ DÁN NHÃN"
			badge.add_theme_font_size_override("font_size", 10)
			badge.add_theme_color_override("font_color", Color(0.12, 0.60, 0.25))
			top_row.add_child(badge)
		vbox.add_child(top_row)
		
		# Hàng 2: Ô điền khuyết nhãn công dụng (Droppable)
		var label_row = HBoxContainer.new()
		var prompt_prefix = Label.new()
		prompt_prefix.text = "Công dụng: "
		prompt_prefix.add_theme_font_size_override("font_size", 11)
		prompt_prefix.add_theme_color_override("font_color", Color(0.40, 0.35, 0.30))
		label_row.add_child(prompt_prefix)
		
		var blank_slot = DroppableMedBlank.new()
		blank_slot.med_id = med_id
		blank_slot.game_ref = self
		blank_slot.is_solved = is_solved
		blank_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		blank_slot.custom_minimum_size = Vector2(0, 32)
		blank_slot.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var blank_style = StyleBoxFlat.new()
		blank_style.set_corner_radius_all(8)
		blank_style.content_margin_left = 8
		blank_style.content_margin_right = 8
		blank_style.content_margin_top = 4
		blank_style.content_margin_bottom = 4
		
		var blank_lbl = Label.new()
		blank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		blank_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		blank_lbl.add_theme_font_size_override("font_size", 11)
		
		if is_solved:
			s.bg_color = Color(0.93, 0.98, 0.94, 1.0)
			s.border_color = Color(0.20, 0.72, 0.38, 1.0)
			s.set_border_width_all(2)
			
			blank_style.bg_color = Color(0.20, 0.72, 0.38, 1.0)
			blank_style.border_color = Color(0.12, 0.50, 0.22, 1.0)
			blank_style.set_border_width_all(2)
			blank_lbl.text = "✔ 🏷️ " + solved_medicines[med_id]
			blank_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		else:
			s.bg_color = Color(1.0, 1.0, 1.0, 0.95)
			s.border_color = Color(0.88, 0.82, 0.75, 1.0)
			s.set_border_width_all(1)
			
			blank_style.bg_color = Color(1.0, 0.96, 0.90, 1.0)
			blank_style.border_color = Color(0.95, 0.60, 0.20, 1.0)
			blank_style.set_border_width_all(1)
			blank_lbl.text = "..... [ Ô TRỐNG: Kéo hoặc chạm nhãn vào đây ] ....."
			blank_lbl.add_theme_color_override("font_color", Color(0.80, 0.45, 0.10))
			
		blank_slot.add_theme_stylebox_override("panel", blank_style)
		blank_slot.add_child(blank_lbl)
		label_row.add_child(blank_slot)
		vbox.add_child(label_row)
		
		# Hàng 3: Lời Mẹ dặn dò & Lưu ý an toàn (Chỉ hiện khi đã dán nhãn đúng)
		if is_solved:
			var advice_box = PanelContainer.new()
			var adv_style = StyleBoxFlat.new()
			adv_style.bg_color = Color(1.0, 0.98, 0.92, 1.0)
			adv_style.border_color = Color(0.92, 0.75, 0.45, 1.0)
			adv_style.set_border_width_all(1)
			adv_style.set_corner_radius_all(8)
			adv_style.content_margin_left = 8
			adv_style.content_margin_right = 8
			adv_style.content_margin_top = 6
			adv_style.content_margin_bottom = 6
			advice_box.add_theme_stylebox_override("panel", adv_style)
			
			var adv_vbox = VBoxContainer.new()
			var adv_lbl = Label.new()
			adv_lbl.text = "💡 Lời Mẹ dặn: " + med.get("mother_advice", "")
			adv_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			adv_lbl.add_theme_font_size_override("font_size", 10)
			adv_lbl.add_theme_color_override("font_color", Color(0.40, 0.25, 0.10))
			adv_vbox.add_child(adv_lbl)
			
			var warn_lbl = Label.new()
			warn_lbl.text = med.get("warning_tag", "")
			warn_lbl.add_theme_font_size_override("font_size", 9)
			warn_lbl.add_theme_color_override("font_color", Color(0.85, 0.30, 0.15))
			adv_vbox.add_child(warn_lbl)
			
			advice_box.add_child(adv_vbox)
			vbox.add_child(advice_box)
			
		med_panel.add_theme_stylebox_override("panel", s)
		med_panel.add_child(vbox)
		medicines_list_vbox.add_child(med_panel)

func _render_labels_pool() -> void:
	for child in labels_pool_container.get_children():
		labels_pool_container.remove_child(child)
		child.queue_free()
		
	for opt in puzzle_options:
		var is_used = false
		for m_id in solved_medicines:
			if solved_medicines[m_id] == opt:
				is_used = true
				break
				
		var label_card = DraggableMedLabel.new()
		label_card.label_text = opt
		label_card.game_ref = self
		label_card.is_used = is_used
		label_card.custom_minimum_size = Vector2(160, 38)
		label_card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var s = StyleBoxFlat.new()
		s.set_corner_radius_all(10)
		s.content_margin_left = 10
		s.content_margin_right = 10
		s.content_margin_top = 6
		s.content_margin_bottom = 6
		
		var is_selected = (selected_label_for_fill == opt)
		
		if is_used:
			s.bg_color = Color(0.92, 0.90, 0.88, 0.5)
			s.border_color = Color(0.80, 0.75, 0.70, 0.7)
			s.set_border_width_all(1)
		elif is_selected:
			s.bg_color = Color(1.0, 0.95, 0.85, 1.0)
			s.border_color = Color(0.95, 0.55, 0.15, 1.0)
			s.set_border_width_all(2)
		else:
			s.bg_color = Color(1.0, 1.0, 1.0, 0.95)
			s.border_color = Color(0.85, 0.75, 0.65, 1.0)
			s.set_border_width_all(1)
			s.border_width_bottom = 2
			
		var lbl = Label.new()
		lbl.text = "🏷️ " + opt
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 10)
		lbl.add_theme_color_override("font_color", Color(0.25, 0.18, 0.12) if not is_used else Color(0.6, 0.55, 0.5))
		label_card.add_theme_stylebox_override("panel", s)
		label_card.add_child(lbl)
		labels_pool_container.add_child(label_card)

func _create_drag_preview_for_label(lbl_text: String) -> Control:
	var prev = PanelContainer.new()
	prev.custom_minimum_size = Vector2(150, 36)
	var s = StyleBoxFlat.new()
	s.bg_color = Color(1.0, 0.95, 0.85, 0.95)
	s.border_color = Color(0.95, 0.55, 0.15, 1.0)
	s.set_border_width_all(2)
	s.set_corner_radius_all(10)
	prev.add_theme_stylebox_override("panel", s)
	
	var lbl = Label.new()
	lbl.text = "🏷️ " + lbl_text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.add_theme_color_override("font_color", Color(0.2, 0.15, 0.1))
	prev.add_child(lbl)
	return prev

func _on_label_tap_selected(lbl_text: String) -> void:
	SoundManager.play_click()
	if selected_label_for_fill == lbl_text:
		selected_label_for_fill = ""
	else:
		selected_label_for_fill = lbl_text
		mother_speech.text = "Đã chọn nhãn [%s]! Bây giờ hãy chạm vào lọ thuốc phù hợp để dán nhé!" % lbl_text
	_render_labels_pool()

func _attempt_fill_label_to_medicine(lbl_text: String, med_id: String) -> void:
	var med_target: Dictionary = {}
	for m in medicine_puzzles:
		if m["id"] == med_id:
			med_target = m
			break
			
	if med_target.is_empty():
		return
		
	var correct_label = med_target.get("correct_label", "")
	if lbl_text != correct_label:
		SoundManager.play_fail()
		mother_speech.text = "Chưa đúng rồi con ơi! '%s' không phải công dụng của thuốc '%s'. Đọc kỹ lại công dụng nhé!" % [lbl_text, med_target.get("med_name", "")]
		selected_label_for_fill = ""
		_render_labels_pool()
		return
		
	SoundManager.play_card_pop()
	solved_medicines[med_id] = lbl_text
	selected_label_for_fill = ""
	mother_speech.text = "Méo-tick! ✨ Đúng rồi! Mẹ dặn: %s" % med_target.get("mother_advice", "")
	_render_medicines_list()
	_render_labels_pool()
	_update_phase2_button()

func _remove_label_from_medicine(med_id: String) -> void:
	if solved_medicines.has(med_id):
		SoundManager.play_click()
		var lbl = solved_medicines[med_id]
		solved_medicines.erase(med_id)
		mother_speech.text = "Đã gỡ nhãn [%s]! Hãy dán lại cho chuẩn nhé con!" % lbl
		_render_medicines_list()
		_render_labels_pool()
		_update_phase2_button()

func _update_phase2_button() -> void:
	if solved_medicines.size() == 5:
		btn_finish_game.disabled = false
		btn_finish_game.text = "🎉 HOÀN THÀNH HÀNH TRANG LÊN ĐẠI HỌC!"
		btn_finish_game.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		SoundManager.play_success()
		if cat_anim:
			cat_anim.play("jump")
		mother_speech.text = "Mẹ xúc động quá! Con của Mẹ đã sẵn sàng và biết cách tự lập chăm sóc bản thân rồi! ✨"
	else:
		btn_finish_game.disabled = true
		btn_finish_game.text = "🏷️ CẦN DÁN ĐỦ 5 NHÃN THUỐC (%d/5)" % solved_medicines.size()
		btn_finish_game.add_theme_color_override("font_disabled_color", Color(0.38, 0.28, 0.20, 1.0))

# =========================================================================
# KẾT THÚC & PHẦN THƯỞNG
# =========================================================================
func _on_finish_game_pressed() -> void:
	SoundManager.play_success()
	var victory_msg = "Mẹ âu yếm ôm chặt xoa đầu Mèo con:\n\n"
	victory_msg += "'Con yêu của Mẹ, hành trang lên đại học đã tươm tất rồi! Con đã biết xếp đồ ngăn nắp và ghi nhớ công dụng từng loại thuốc để tự chăm sóc khi trái gió trở trời.\n\n"
	victory_msg += "Hãy tự tin bước vào giảng đường Đại học, rèn luyện bản lĩnh và sống thật hạnh phúc nhé con! Mẹ luôn dõi theo và tự hào về con!'"
	victory_dialogue.text = victory_msg
	victory_modal.visible = true

func _on_claim_reward_pressed() -> void:
	print(">>> PreparationValiGame: _on_claim_reward_pressed called!")
	SoundManager.play_success()
	if victory_modal:
		victory_modal.visible = false
	
	# Hoàn thành bài học 1 trong GameManager
	if GameManager:
		GameManager.complete_lesson(1)
	
	var sim_steps = data.get("sim_steps", [
		{"icon": "📦", "text": "Xếp đồ vào đúng 4 ngăn Vali"},
		{"icon": "🏷️", "text": "Dán nhãn công dụng thuốc thiết yếu"},
		{"icon": "📜", "text": "Điền khuyết ghi nhớ lưu ý của mẹ"},
		{"icon": "🎒", "text": "Khóa vali hành trang tự lập lên đường"}
	])
	print(">>> PreparationValiGame: Emitting minigame_completed with %d steps" % sim_steps.size())
	minigame_completed.emit(sim_steps)
