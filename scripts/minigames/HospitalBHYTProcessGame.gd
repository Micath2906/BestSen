extends Control

# HospitalBHYTProcessGame.gd - Game Kéo Thả Đi Khám BHYT Theo Từng Bước Đúng Quy Trình (Lesson 10)
# Gameplay 2 giai đoạn:
# Phase 1: Chuẩn bị 4 giấy tờ BHYT cốt lõi vào Túi Hồ Sơ (Tránh mang đồ bẫy)
# Phase 2: Kéo thả đi khám BHYT theo 6 bước đúng quy trình bệnh viện (Từ bốc số đến quầy dược)

signal minigame_completed(sim_steps)
signal back_requested

const JuicyButtonScript = preload("res://scripts/ui/JuicyButton.gd")

# UI Nodes
@onready var btn_back: Button = $Header/BtnBack
@onready var btn_guide: Button = $Header/BtnGuide
@onready var title_lbl: Label = $Header/TitleLabel

# Phase Banner
@onready var phase_banner: PanelContainer = $PhaseBanner
@onready var phase_badge_lbl: Label = $PhaseBanner/HBox/PhaseBadgeLabel
@onready var phase_status_lbl: Label = $PhaseBanner/HBox/PhaseStatusLabel

# Scroll container
@onready var content_scroll: ScrollContainer = $ContentScroll
@onready var vbox_container: VBoxContainer = $ContentScroll/VBox

# Phase 1: Xếp túi hồ sơ
@onready var phase1_container: VBoxContainer = $ContentScroll/VBox/Phase1Container
@onready var doc_folder_slots: HBoxContainer = $ContentScroll/VBox/Phase1Container/FolderFrame/SlotsHBox
@onready var doc_pool_container: HFlowContainer = $ContentScroll/VBox/Phase1Container/DocPoolContainer
@onready var btn_go_phase2: Button = $ContentScroll/VBox/Phase1Container/BtnGoPhase2

# Phase 2: 6 Bước quy trình khám BHYT
@onready var phase2_container: VBoxContainer = $ContentScroll/VBox/Phase2Container
@onready var hospital_steps_vbox: VBoxContainer = $ContentScroll/VBox/Phase2Container/HospitalStepsVBox
@onready var action_cards_pool: Container = $ContentScroll/VBox/Phase2Container/ActionCardsPool
@onready var btn_finish_bhyt: Button = $ContentScroll/VBox/Phase2Container/BtnFinishBHYT

# Mascot
@onready var cat_speech_lbl: Label = $MascotSection/HBox/SpeechBubble/CatSpeechLabel

# Modals
@onready var guide_modal: Control = $GuideModal
@onready var guide_content_lbl: Label = $GuideModal/ModalPanel/VBox/Scroll/GuideContent
@onready var btn_close_guide: Button = $GuideModal/ModalPanel/VBox/BtnCloseGuide

@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue_lbl: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

var bhyt_polaroid_card: PanelContainer = null

# Dữ liệu 4 giấy tờ Phase 1
const REQUIRED_DOCS = [
	{"id": "doc_cccd", "name": "CCCD Gắn Chip", "icon": "🪪", "desc": "Quét mã BHYT điện tử", "is_required": true},
	{"id": "doc_bhyt", "name": "Thẻ BHYT / VssID", "icon": "🎫", "desc": "Giảm 80-100% viện phí", "is_required": true},
	{"id": "doc_book", "name": "Sổ Khám Bệnh & Bút", "icon": "📒", "desc": "Bác sĩ ghi bệnh án", "is_required": true},
	{"id": "doc_cash", "name": "Tiền Lẻ & Thẻ ATM", "icon": "💵", "desc": "Gửi xe & viện phí chênh lệch", "is_required": true},
]

const JUNK_DOCS = [
	{"id": "junk_bear", "name": "Gấu Bông Khổng Lồ", "icon": "🧸", "desc": "Chật ních túi hồ sơ", "is_required": false, "fail_msg": "Đi viện khám BHYT mang gấu bông 2 mét làm gì hả Sen! Bác sĩ mắng đó!"},
	{"id": "junk_pot", "name": "Bát Mì Tôm Cay", "icon": "🍜", "desc": "Đổ vỡ bẩn giấy tờ", "is_required": false, "fail_msg": "Mang bát mì tôm vào bệnh viện đổ tràn ra hồ sơ hỏng hết giấy tờ!"},
	{"id": "junk_racket", "name": "Vợt Cầu Lông", "icon": "🏸", "desc": "Cồng kềnh vướng víu", "is_required": false, "fail_msg": "Vào viện khám bệnh chứ có phải đi đánh giải cầu lông đâu Sen ơi!"}
]

# Dữ liệu 6 bước quy trình BHYT chuẩn tại bệnh viện
const BHYT_6_STEPS = [
	{
		"step": 1,
		"time": "7:00 Sáng",
		"location": "Cây Bốc Số Tự Động (Sảnh Tiếp Đón)",
		"icon": "🎟️",
		"action_title": "Bốc số thứ tự khu Khám BHYT",
		"desc": "Đến sớm bấm máy lấy số thứ tự tại khu vực tiếp nhận BHYT đúng tuyến",
		"error_hint": "Chưa bốc số thứ tự ở cây lấy số mà đã chen vào quầy là bị bảo vệ nhắc nhở đấy Sen!"
	},
	{
		"step": 2,
		"time": "7:15 Sáng",
		"location": "Quầy Tiếp Nhận & Đăng Ký",
		"icon": "🪪",
		"action_title": "Xuất trình CCCD & Thẻ BHYT lấy số phòng khám",
		"desc": "Trình CCCD gắn chip (hoặc app VssID) để nhân viên cấp số phòng khám chuyên khoa",
		"error_hint": "Chưa qua quầy tiếp đón làm thủ tục BHYT thì bác sĩ trong phòng khám không có bệnh án đâu!"
	},
	{
		"step": 3,
		"time": "7:30 Sáng",
		"location": "Phòng Khám Chuyên Khoa",
		"icon": "🩺",
		"action_title": "Vào gặp Bác sĩ khám lâm sàng & nhận chỉ định",
		"desc": "Ngồi chờ bảng điện tử gọi số, vào gặp bác sĩ nghe tim phổi và nhận phiếu xét nghiệm",
		"error_hint": "Bác sĩ chưa thăm khám và chỉ định mà tự ý đi làm xét nghiệm là sai quy trình bệnh viện!"
	},
	{
		"step": 4,
		"time": "8:00 Sáng",
		"location": "Khu Cận Lâm Sàng & Xét Nghiệm",
		"icon": "🧪",
		"action_title": "Thực hiện xét nghiệm máu & Chụp X-quang",
		"desc": "Lấy mẫu máu, nước tiểu hoặc chụp phim chẩn đoán hình ảnh theo chỉ định của bác sĩ",
		"error_hint": "Chưa làm xét nghiệm cận lâm sàng thì bác sĩ lấy căn cứ đâu để kết luận bệnh và kê đơn thuốc!"
	},
	{
		"step": 5,
		"time": "9:30 Sáng",
		"location": "Phòng Khám & Quầy Thu Viện Phí",
		"icon": "🧾",
		"action_title": "Bác sĩ đọc kết quả, kê toa & Đóng phí chênh lệch",
		"desc": "Mang kết quả về phòng bác sĩ nghe kết luận, nhận đơn thuốc và thanh toán phí chênh lệch BHYT",
		"error_hint": "Chưa thanh toán biên lai viện phí chênh lệch thì quầy Dược không được phép xuất thuốc!"
	},
	{
		"step": 6,
		"time": "10:00 Sáng",
		"location": "Quầy Dược BHYT Cấp Phát",
		"icon": "💊",
		"action_title": "Nộp đơn thuốc nhận bọc thuốc BHYT miễn phí",
		"desc": "Nộp đơn thuốc và biên lai tại kho Dược BHYT, kiểm tra đủ thuốc rồi mỉm cười ra về",
		"error_hint": "Khám bệnh xong mà quên qua Quầy Dược BHYT lấy thuốc thì phải tự bỏ tiền túi ra mua đắt đỏ!"
	}
]

var minigame_data: Dictionary = {}
var current_phase: int = 1 # 1: Xếp hồ sơ, 2: 6 Bước quy trình

# State Phase 1
var packed_docs: Dictionary = {} # doc_id -> item data
var selected_doc_for_pack: Dictionary = {}

# State Phase 2
var solved_steps: Dictionary = {} # step_idx (1..6) -> step data
var selected_action_card: Dictionary = {}

func _ready() -> void:
	_setup_button_events()
	if guide_modal: guide_modal.visible = false
	if victory_modal: victory_modal.visible = false

func _setup_button_events() -> void:
	if btn_back:
		btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
		btn_back.pressed.connect(func():
			SoundManager.play_click()
			emit_signal("back_requested")
		)
		JuicyButtonScript.attach_juice(btn_back, true)
	if btn_guide:
		btn_guide.pressed.connect(_on_guide_pressed)
		JuicyButtonScript.attach_juice(btn_guide, true)
	if btn_close_guide:
		btn_close_guide.pressed.connect(func():
			SoundManager.play_click()
			guide_modal.visible = false
		)
		JuicyButtonScript.attach_juice(btn_close_guide, true)
	if btn_go_phase2:
		btn_go_phase2.pressed.connect(_switch_to_phase2)
		JuicyButtonScript.attach_juice(btn_go_phase2, true)
	if btn_finish_bhyt:
		btn_finish_bhyt.pressed.connect(_on_finish_bhyt_pressed)
		JuicyButtonScript.attach_juice(btn_finish_bhyt, true)
	if btn_claim_reward:
		btn_claim_reward.pressed.connect(_on_claim_reward_pressed)
		JuicyButtonScript.attach_juice(btn_claim_reward, true)

var shuffled_docs: Array = []
var shuffled_steps_pool: Array = []

func load_minigame(data: Dictionary) -> void:
	minigame_data = data
	title_lbl.text = "Khám BHYT Đúng Tuyến Từng Bước"
	current_phase = 1
	packed_docs.clear()
	solved_steps.clear()
	selected_doc_for_pack.clear()
	selected_action_card = {}
	
	# Xáo trộn giấy tờ và các bước hành động
	var all_docs = REQUIRED_DOCS.duplicate()
	all_docs.append_array(JUNK_DOCS)
	all_docs.shuffle()
	shuffled_docs = all_docs
	
	shuffled_steps_pool = BHYT_6_STEPS.duplicate()
	shuffled_steps_pool.shuffle()
	
	_render_phase1()

# =========================================================================
# PHASE 1: CHUẨN BỊ 4 GIẤY TỜ BHYT VÀO TÚI HỒ SƠ
# =========================================================================
func _render_phase1() -> void:
	current_phase = 1
	phase1_container.visible = true
	phase2_container.visible = false
	phase_badge_lbl.text = "GIAI ĐOẠN 1 / 2"
	phase_status_lbl.text = "📁 Chuẩn bị 4 giấy tờ BHYT cốt lõi vào Túi Hồ Sơ"
	cat_speech_lbl.text = "Meo meo! Đi khám BHYT lúc 7h sáng cần mang đúng 4 giấy tờ cốt lõi, đừng mang đồ linh tinh chật túi nhé Sen! 🐾"
	btn_go_phase2.disabled = true
	
	_render_phase1_slots()
	_render_phase1_doc_pool()

func _render_phase1_slots() -> void:
	for child in doc_folder_slots.get_children():
		child.queue_free()
		
	for i in range(4):
		var slot_panel = PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(105, 120)
		slot_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(10)
		style.set_border_width_all(2)
		
		var filled_key = packed_docs.keys()[i] if i < packed_docs.size() else null
		if filled_key:
			var it = packed_docs[filled_key]
			style.bg_color = Color(0.92, 0.98, 0.94, 1.0)
			style.border_color = Color(0.2, 0.75, 0.4, 1.0)
			slot_panel.add_theme_stylebox_override("panel", style)
			
			var vbox = VBoxContainer.new()
			vbox.alignment = BoxContainer.ALIGNMENT_CENTER
			var icon_lbl = Label.new()
			icon_lbl.text = it.get("icon", "📄")
			icon_lbl.add_theme_font_size_override("font_size", 28)
			icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			vbox.add_child(icon_lbl)
			
			var name_lbl = Label.new()
			name_lbl.text = it.get("name", "")
			name_lbl.add_theme_font_size_override("font_size", 10)
			name_lbl.add_theme_color_override("font_color", Color(0.15, 0.5, 0.25, 1.0))
			name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			vbox.add_child(name_lbl)
			
			var unpick_btn = Button.new()
			unpick_btn.text = "✖ Bỏ ra"
			unpick_btn.add_theme_font_size_override("font_size", 9)
			unpick_btn.pressed.connect(func(): _remove_doc_from_folder(it["id"]))
			JuicyButtonScript.attach_juice(unpick_btn, true)
			vbox.add_child(unpick_btn)
			
			slot_panel.add_child(vbox)
		else:
			style.bg_color = Color(1.0, 0.99, 0.96, 0.9)
			style.border_color = Color(0.85, 0.78, 0.7, 1.0)
			slot_panel.add_theme_stylebox_override("panel", style)
			
			var vbox = VBoxContainer.new()
			vbox.alignment = BoxContainer.ALIGNMENT_CENTER
			var num_lbl = Label.new()
			num_lbl.text = "Ô %d" % (i + 1)
			num_lbl.add_theme_font_size_override("font_size", 13)
			num_lbl.add_theme_color_override("font_color", Color(0.65, 0.55, 0.45, 1.0))
			num_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			vbox.add_child(num_lbl)
			
			var hint_lbl = Label.new()
			hint_lbl.text = "(Chạm giấy tờ\nđể xếp vào)"
			hint_lbl.add_theme_font_size_override("font_size", 9)
			hint_lbl.add_theme_color_override("font_color", Color(0.65, 0.55, 0.45, 1.0))
			hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			vbox.add_child(hint_lbl)
			
			slot_panel.add_child(vbox)
			
		doc_folder_slots.add_child(slot_panel)

func _render_phase1_doc_pool() -> void:
	for child in doc_pool_container.get_children():
		child.queue_free()
		
	if shuffled_docs.is_empty():
		var all_docs = REQUIRED_DOCS.duplicate()
		all_docs.append_array(JUNK_DOCS)
		all_docs.shuffle()
		shuffled_docs = all_docs
	
	for it in shuffled_docs:
		if packed_docs.has(it["id"]):
			continue
			
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 48)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(1.0, 0.99, 0.97, 1.0)
		style.border_color = Color(0.88, 0.78, 0.66, 1.0)
		style.set_border_width_all(2)
		style.border_width_bottom = 3
		style.set_corner_radius_all(10)
		style.content_margin_left = 8
		style.content_margin_right = 8
		btn.add_theme_stylebox_override("normal", style)
		
		var style_hover = style.duplicate()
		style_hover.bg_color = Color(0.95, 0.98, 1.0, 1.0)
		style_hover.border_color = Color(0.2, 0.6, 0.9, 1.0)
		btn.add_theme_stylebox_override("hover", style_hover)
		
		btn.text = "%s %s" % [it.get("icon", "📄"), it.get("name", "")]
		btn.add_theme_color_override("font_color", Color(0.25, 0.2, 0.15, 1.0))
		btn.add_theme_font_size_override("font_size", 11)
		
		btn.pressed.connect(func(): _attempt_pack_doc(it))
		JuicyButtonScript.attach_juice(btn, true)
		doc_pool_container.add_child(btn)

func _attempt_pack_doc(doc: Dictionary) -> void:
	if not doc.get("is_required", false):
		SoundManager.play_card_pop()
		cat_speech_lbl.text = "ÚI GIỜI ƠI! %s 💡 Lời khuyên Mochi: Bệnh viện buổi sáng rất đông, hãy mang túi hồ sơ y tế nhỏ gọn để di chuyển thuận lợi nhé Sen! 🐾" % doc.get("fail_msg", "Đồ thừa không cần mang!")
		return
		
	if packed_docs.size() >= 4:
		cat_speech_lbl.text = "Túi hồ sơ đã đủ 4 ô giấy tờ rồi Sen ơi! Bấm Tiếp Tục để sang bệnh viện nào!"
		return
		
	SoundManager.play_success()
	packed_docs[doc["id"]] = doc
	_render_phase1_slots()
	_render_phase1_doc_pool()
	
	if packed_docs.size() == 4:
		btn_go_phase2.disabled = false
		cat_speech_lbl.text = "Xuất sắc! Đã chuẩn bị đầy đủ 4 giấy tờ BHYT! Bấm Tiếp Tục để bước vào Bệnh Viện khám bệnh nào! ✨"

func _remove_doc_from_folder(doc_id: String) -> void:
	if packed_docs.has(doc_id):
		SoundManager.play_card_pop()
		packed_docs.erase(doc_id)
		btn_go_phase2.disabled = true
		_render_phase1_slots()
		_render_phase1_doc_pool()

func _switch_to_phase2() -> void:
	SoundManager.play_click()
	current_phase = 2
	phase1_container.visible = false
	phase2_container.visible = true
	phase_badge_lbl.text = "GIAI ĐOẠN 2 / 2"
	phase_status_lbl.text = "🏥 Kéo thả 6 bước khám bệnh BHYT đúng chuẩn quy trình"
	cat_speech_lbl.text = "Đã tới bệnh viện lúc 7h sáng! Sen hãy kéo các thẻ hành động bên dưới vào đúng thứ tự 6 Chặng Quy Trình nhé! 🐾"
	btn_finish_bhyt.disabled = true
	if content_scroll:
		content_scroll.scroll_vertical = 0
		
	_render_phase2_hospital_steps()
	_render_phase2_action_pool()

# =========================================================================
# PHASE 2: KÉO THẢ 6 BƯỚC QUY TRÌNH KHÁM BHYT TẠI BỆNH VIỆN
# =========================================================================
func _render_phase2_hospital_steps() -> void:
	for child in hospital_steps_vbox.get_children():
		child.queue_free()
		
	for step_info in BHYT_6_STEPS:
		var s_idx = step_info["step"]
		var is_solved = solved_steps.has(s_idx)
		
		var step_card = PanelContainer.new()
		step_card.custom_minimum_size = Vector2(0, 76)
		
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(12)
		style.set_border_width_all(2)
		style.border_width_bottom = 3
		style.content_margin_left = 12
		style.content_margin_right = 12
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		
		if is_solved:
			style.bg_color = Color(0.93, 0.98, 0.94, 1.0)
			style.border_color = Color(0.25, 0.72, 0.42, 1.0)
		else:
			style.bg_color = Color(1.0, 0.99, 0.97, 1.0)
			style.border_color = Color(0.88, 0.78, 0.66, 1.0)
		step_card.add_theme_stylebox_override("panel", style)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		
		# Badge số bước
		var badge_panel = PanelContainer.new()
		badge_panel.custom_minimum_size = Vector2(50, 48)
		var b_style = StyleBoxFlat.new()
		b_style.set_corner_radius_all(8)
		b_style.bg_color = Color(0.2, 0.55, 0.85, 1.0) if not is_solved else Color(0.2, 0.7, 0.35, 1.0)
		badge_panel.add_theme_stylebox_override("panel", b_style)
		
		var b_vbox = VBoxContainer.new()
		b_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		var b_num = Label.new()
		b_num.text = "BƯỚC %d" % s_idx
		b_num.add_theme_font_size_override("font_size", 9)
		b_num.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		b_num.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b_vbox.add_child(b_num)
		
		var b_time = Label.new()
		b_time.text = step_info["time"]
		b_time.add_theme_font_size_override("font_size", 8)
		b_time.add_theme_color_override("font_color", Color(0.9, 0.95, 1, 0.9))
		b_time.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b_vbox.add_child(b_time)
		badge_panel.add_child(b_vbox)
		hbox.add_child(badge_panel)
		
		# Vùng nội dung quy trình
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		
		var loc_lbl = Label.new()
		loc_lbl.text = "📍 Địa điểm: %s" % step_info["location"]
		loc_lbl.add_theme_font_size_override("font_size", 10)
		loc_lbl.add_theme_color_override("font_color", Color(0.45, 0.35, 0.25, 1.0))
		info_vbox.add_child(loc_lbl)
		
		if is_solved:
			var action_lbl = Label.new()
			action_lbl.text = "✔ %s %s" % [step_info["icon"], step_info["action_title"]]
			action_lbl.add_theme_font_size_override("font_size", 11)
			action_lbl.add_theme_color_override("font_color", Color(0.15, 0.55, 0.25, 1.0))
			action_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			info_vbox.add_child(action_lbl)
		else:
			var slot_btn = Button.new()
			slot_btn.custom_minimum_size = Vector2(0, 46)
			slot_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			slot_btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			slot_btn.add_theme_font_size_override("font_size", 11)
			var slot_sb = StyleBoxFlat.new()
			slot_sb.set_corner_radius_all(8)
			slot_sb.set_border_width_all(1)
			slot_sb.border_color = Color(0.85, 0.75, 0.65, 1.0)
			slot_sb.bg_color = Color(0.97, 0.95, 0.92, 1.0)
			slot_sb.content_margin_left = 10
			slot_sb.content_margin_right = 10
			slot_btn.add_theme_stylebox_override("normal", slot_sb)
			
			if selected_action_card.is_empty():
				slot_btn.text = "❓ [Ô Trống Bước %d: Chạm thẻ hành động để đặt]" % s_idx
				slot_btn.add_theme_color_override("font_color", Color(0.55, 0.45, 0.35, 1.0))
			else:
				slot_btn.text = "👉 Chạm vào đây để đặt vào Bước %d" % s_idx
				slot_btn.add_theme_color_override("font_color", Color(0.1, 0.45, 0.85, 1.0))
				
			slot_btn.pressed.connect(func(): _on_slot_pressed(s_idx))
			JuicyButtonScript.attach_juice(slot_btn, true)
			info_vbox.add_child(slot_btn)
			
		hbox.add_child(info_vbox)
		step_card.add_child(hbox)
		hospital_steps_vbox.add_child(step_card)

func _render_phase2_action_pool() -> void:
	for child in action_cards_pool.get_children():
		child.queue_free()
		
	if shuffled_steps_pool.is_empty():
		shuffled_steps_pool = BHYT_6_STEPS.duplicate()
		shuffled_steps_pool.shuffle()
		
	for step_info in shuffled_steps_pool:
		var s_idx = step_info["step"]
		if solved_steps.has(s_idx):
			continue
			
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 46)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		var is_selected = (not selected_action_card.is_empty() and selected_action_card["step"] == s_idx)
		
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(10)
		style.set_border_width_all(2)
		style.content_margin_left = 10
		style.content_margin_right = 10
		
		if is_selected:
			style.bg_color = Color(0.9, 0.95, 1.0, 1.0)
			style.border_color = Color(0.15, 0.55, 0.95, 1.0)
		else:
			style.bg_color = Color(1.0, 0.99, 0.97, 1.0)
			style.border_color = Color(0.88, 0.78, 0.66, 1.0)
		btn.add_theme_stylebox_override("normal", style)
		
		btn.text = "%s %s" % [step_info["icon"], step_info["action_title"]]
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", Color(0.2, 0.18, 0.15, 1.0))
		
		btn.pressed.connect(func(): _on_action_card_tapped(step_info))
		JuicyButtonScript.attach_juice(btn, true)
		action_cards_pool.add_child(btn)

func _on_action_card_tapped(step_info: Dictionary) -> void:
	SoundManager.play_card_pop()
	if not selected_action_card.is_empty() and selected_action_card["step"] == step_info["step"]:
		selected_action_card = {}
		cat_speech_lbl.text = "Đã bỏ chọn thẻ. Chọn thẻ hành động rồi bấm vào ô chặng tương ứng nhé Sen!"
	else:
		selected_action_card = step_info.duplicate()
		cat_speech_lbl.text = "Đã chọn: '%s'. Hãy bấm vào Ô Trống Bước đúng thứ tự để đặt vào nhé!" % step_info["action_title"]
		
	_render_phase2_hospital_steps()
	_render_phase2_action_pool()

func _on_slot_pressed(target_step_idx: int) -> void:
	if selected_action_card.is_empty():
		cat_speech_lbl.text = "Sen hãy chạm chọn một Thẻ Hành Động ở danh sách bên dưới trước nhé!"
		return
		
	if selected_action_card["step"] == target_step_idx:
		SoundManager.play_success()
		solved_steps[target_step_idx] = selected_action_card
		selected_action_card = {}
		cat_speech_lbl.text = "Chính xác! Bước %d đã hoàn thành chuẩn quy trình y tế! Tiếp tục các bước còn lại nào!" % target_step_idx
		_render_phase2_hospital_steps()
		_render_phase2_action_pool()
		
		if solved_steps.size() == 6:
			btn_finish_bhyt.disabled = false
			cat_speech_lbl.text = "🎉 XUẤT SẮC! Hoàn thành trọn vẹn 6 bước khám bệnh BHYT đúng tuyến! Bấm Hoàn Thành để nhận thuốc và phần thưởng nào! ✨"
	else:
		SoundManager.play_card_pop()
		var step_data = BHYT_6_STEPS[target_step_idx - 1]
		cat_speech_lbl.text = "SAI RỒI SEN ƠI! %s" % step_data.get("error_hint", "Thao tác này chưa đúng thứ tự quy trình bệnh viện!")

func _build_bhyt_polaroid_prescription() -> void:
	if bhyt_polaroid_card and is_instance_valid(bhyt_polaroid_card):
		bhyt_polaroid_card.queue_free()
		
	bhyt_polaroid_card = PanelContainer.new()
	bhyt_polaroid_card.name = "BhytPolaroidPrescription"
	bhyt_polaroid_card.custom_minimum_size = Vector2(0, 110)
	
	var sb = load("res://assets/UI/CatUIPaid/slices/cozy_achievements/parchment_scroll_stylebox.tres")
	if sb:
		bhyt_polaroid_card.add_theme_stylebox_override("panel", sb)
	else:
		var flat = StyleBoxFlat.new()
		flat.bg_color = Color(0.95, 0.98, 0.95, 1.0)
		flat.border_color = Color(0.2, 0.65, 0.35, 1.0)
		flat.set_border_width_all(2)
		flat.set_corner_radius_all(10)
		bhyt_polaroid_card.add_theme_stylebox_override("panel", flat)
		
	var v = VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 4)
	
	var owner_name = GameManager.owner_name if "owner_name" in GameManager and GameManager.owner_name != "" else "Sen Khỏe Mạnh"
	var room_name = GameManager.room_name if "room_name" in GameManager and GameManager.room_name != "" else "Phòng Trọ Số 1"
	
	var h_top = Label.new()
	h_top.text = "🏥 SỔ KHÁM BỆNH BHYT: ĐÃ THẤU HIỂU QUY TRÌNH"
	h_top.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h_top.add_theme_font_size_override("font_size", 11)
	h_top.add_theme_color_override("font_color", Color(0.12, 0.45, 0.22, 1.0))
	v.add_child(h_top)
	
	var desc = Label.new()
	desc.text = "Bệnh nhân: %s • Địa chỉ: %s\nHoàn tất 6 chặng khám BHYT đúng tuyến • Hưởng 80-100%% quyền lợi!" % [owner_name, room_name]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 9)
	desc.add_theme_color_override("font_color", Color(0.25, 0.35, 0.25, 1.0))
	v.add_child(desc)
	
	bhyt_polaroid_card.add_child(v)
	
	var vbox = victory_modal.get_node_or_null("ModalPanel/VBox")
	if vbox:
		var scroll = vbox.get_node_or_null("Scroll")
		if scroll:
			vbox.add_child(bhyt_polaroid_card)
			vbox.move_child(bhyt_polaroid_card, scroll.get_index())
		else:
			vbox.add_child(bhyt_polaroid_card)

func _on_finish_bhyt_pressed() -> void:
	SoundManager.play_success()
	var speech = "🎉 CHÚC MỪNG BẬC THẦY BHYT ĐÚNG TUYẾN!\n\n"
	speech += "Mèo con đã thực hiện chuẩn chỉ 100% quy trình 6 bước khám chữa bệnh BHYT tại Bệnh viện tuyến quận/huyện:\n\n"
	speech += "✔ Bước 1: 7:00 Bốc số thứ tự khu BHYT sớm.\n"
	speech += "✔ Bước 2: 7:15 Trình CCCD gắn chip nhận số phòng khám.\n"
	speech += "✔ Bước 3: 7:30 Vào phòng Bác sĩ khám lâm sàng.\n"
	speech += "✔ Bước 4: 8:00 Làm xét nghiệm máu & Chụp X-quang.\n"
	speech += "✔ Bước 5: 9:30 Nghe Bác sĩ đọc kết luận & Đóng phí viện chênh lệch.\n"
	speech += "✔ Bước 6: 10:00 Nộp đơn tại Quầy Dược nhận bọc thuốc BHYT miễn phí an toàn!\n\n"
	speech += "Không chen lấn, không đi nhầm khu dịch vụ, tiết kiệm tiền triệu viện phí cho sinh viên!\n\n"
	speech += "🎖️ Nhận danh hiệu 'Bậc Thầy BHYT Không Bị Mắng' & Mở khóa 'Vỉ Kẹo Ngậm C Bệnh Viện'!"
	victory_dialogue_lbl.text = speech
	_build_bhyt_polaroid_prescription()
	victory_modal.visible = true

func _on_claim_reward_pressed() -> void:
	SoundManager.play_click()
	victory_modal.visible = false
	GameManager.complete_lesson(10)
	var sim_steps = [
		{"icon": "🎟️", "text": "Bốc số BHYT sớm lúc 7h sáng"},
		{"icon": "🪪", "text": "Trình CCCD gắn chip lấy số phòng"},
		{"icon": "🩺", "text": "Khám bác sĩ chuyên khoa & xét nghiệm"},
		{"icon": "💊", "text": "Lấy thuốc kho Dược BHYT miễn phí"}
	]
	emit_signal("minigame_completed", sim_steps)

func _on_guide_pressed() -> void:
	SoundManager.play_click()
	var guide_str = "📌 CẨM NANG 6 BƯỚC ĐI KHÁM BHYT SINH VIÊN:\n\n"
	guide_str += "1. CHUẨN BỊ GIẤY TỜ BẮT BUỘC:\n"
	guide_str += "  • CCCD gắn chip (tích hợp dữ liệu BHYT quốc gia)\n"
	guide_str += "  • Thẻ BHYT giấy hoặc ứng dụng VssID trên điện thoại\n"
	guide_str += "  • Sổ khám bệnh sinh viên và tiền lẻ gửi xe (20.000đ)\n\n"
	guide_str += "2. QUY TRÌNH 6 BƯỚC TẠI BỆNH VIỆN:\n"
	guide_str += "  • Bước 1: 7:00 Lấy số thứ tự tại máy bốc số khu BHYT.\n"
	guide_str += "  • Bước 2: 7:15 Xuất trình CCCD lấy số phòng chuyên khoa.\n"
	guide_str += "  • Bước 3: 7:30 Vào phòng Bác sĩ khám lâm sàng.\n"
	guide_str += "  • Bước 4: 8:00 Làm xét nghiệm máu, chụp X-quang (nếu có chỉ định).\n"
	guide_str += "  • Bước 5: 9:30 Bác sĩ đọc kết luận, kê đơn & đóng viện phí chênh lệch.\n"
	guide_str += "  • Bước 6: 10:00 Nhận thuốc miễn phí tại Quầy Dược BHYT.\n\n"
	guide_str += "💡 MẸO VÀNG: Luôn đi sớm từ 7h sáng để tránh cảnh xếp hàng dài đến trưa!"
	guide_content_lbl.text = guide_str
	guide_modal.visible = true
