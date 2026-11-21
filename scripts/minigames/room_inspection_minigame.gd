extends "res://scripts/minigames/MinigameBase.gd"

const PixelPlaceholderFactory = preload("res://scripts/utils/PixelPlaceholderFactory.gd")

## room_inspection_minigame.gd
## Standalone 2.5D Room Inspection & Detective Audit Minigame.
## Features: 2.5D Room View (512x512), 5 Pulsing Hotspots, Magnifier Lens Overlay,
## Safety Score Gauge, 5-point Checklist, Handover Verdict Submission,
## and complete standalone execution capability.

const FONT_PATH = "res://assets/font/SVN-Retron 2000.ttf"
const ROOM_BG_PATH = "res://assets/furnitures/CatRoomPaid/CatRoomPaid/Rooms/Room1.png"

# 5 Core Hotspots Data
const HOTSPOTS_DATA: Array[Dictionary] = [
	{
		"id": "tap_leak",
		"title": "Vòi Nước Bồn Rửa",
		"short_name": "Vòi Rỉ Nước",
		"icon": "🚰",
		"pos_normalized": Vector2(0.72, 0.58), # Relative to 2.5D room stage
		"defect_asset": "inspect_leaking_tap",
		"defect_category": PixelPlaceholderFactory.Category.DEFECT_SAFETY,
		"defect_size": Vector2i(48, 48),
		"defect_desc": "Van cao su vòi nước bị mòn, rò rỉ 1 giọt/2 giây.",
		"danger_tip": "⚠️ THẤT THOÁT TIỀN NƯỚC: Mất khoảng 3-5m³ nước mỗi tháng, làm hóa đơn đội thêm 150.000đ - 250.000đ vô lý!",
		"legal_tip": "⚖️ QUYỀN LỢI: Yêu cầu chủ trọ thay ron cao su hoặc thay cụm van mới trước ngày nhận phòng.",
		"checklist_label": "1. Vòi nước không rò rỉ"
	},
	{
		"id": "ceiling_stain",
		"title": "Mảng Ố Dột Trần Nhà",
		"short_name": "Ố Trần Dột",
		"icon": "🏠",
		"pos_normalized": Vector2(0.46, 0.28),
		"defect_asset": "inspect_water_leak_ceiling",
		"defect_category": PixelPlaceholderFactory.Category.DEFECT_SAFETY,
		"defect_size": Vector2i(64, 48),
		"defect_desc": "Trần thạch cao bị loang ố vàng sẫm, dấu hiệu ngấm nước từ sàn trên.",
		"danger_tip": "⚠️ NGUY HIỂM NGẬP DỘT: Khi mùa mưa bão lớn, nước sẽ nhỏ giọt trực tiếp xuống giường ngủ và hỏng laptop!",
		"legal_tip": "⚖️ QUYỀN LỢI: Chụp ảnh hiện trường, cam kết bằng văn bản nếu dột thì chủ nhà bồi thường tài sản.",
		"checklist_label": "2. Trần nhà khô ráo không thấm dột"
	},
	{
		"id": "door_lock",
		"title": "Ổ Khóa Cửa Chính",
		"short_name": "Khóa Lỏng Ốc",
		"icon": "🚪",
		"pos_normalized": Vector2(0.24, 0.62),
		"defect_asset": "inspect_broken_lock",
		"defect_category": PixelPlaceholderFactory.Category.DEFECT_SAFETY,
		"defect_size": Vector2i(48, 48),
		"defect_desc": "Tay gạt cửa bị xệ 30 độ, đinh ốc giữ ổ khóa bị lỏng toét.",
		"danger_tip": "⚠️ NGUY CƠ MẤT TRỘM: Kẻ gian có thể dùng tuốc-nơ-vít bẩy chốt khóa trong vòng 10 giây!",
		"legal_tip": "⚖️ QUYỀN LỢI: Bắt buộc chủ trọ thay ổ khóa mới nguyên tem hoặc xin phép tự lắp thêm khóa móc phụ.",
		"checklist_label": "3. Cửa chính then khóa an toàn"
	},
	{
		"id": "window_grill",
		"title": "Then Cửa Sổ & Chuồng Cọp",
		"short_name": "Chuồng Cọp Hàn Kín",
		"icon": "🪟",
		"pos_normalized": Vector2(0.78, 0.35),
		"defect_asset": "inspect_locked_grill",
		"defect_category": PixelPlaceholderFactory.Category.DEFECT_SAFETY,
		"defect_size": Vector2i(64, 64),
		"defect_desc": "Khung sắt chuồng cọp hàn kín 100%, không có ô cửa thoát hiểm.",
		"danger_tip": "⚠️ VI PHẠM PCCC CỰC KỲ NGUY HIỂM: Nếu hành lang bị khói độc, người trong phòng hoàn toàn mắc kẹt!",
		"legal_tip": "⚖️ QUY CHUẨN PHÁP LÝ: Nghị định PCCC bắt buộc chuồng cọp phải có cửa mở thoát nạn có chìa khóa sẵn.",
		"checklist_label": "4. Ban công/cửa sổ có lối thoát hiểm PCCC"
	},
	{
		"id": "meter_leak",
		"title": "Công Tơ Điện Riêng",
		"short_name": "Công Tơ Quay Lén",
		"icon": "⚡",
		"pos_normalized": Vector2(0.18, 0.38),
		"defect_asset": "inspect_burned_socket",
		"defect_category": PixelPlaceholderFactory.Category.DEFECT_SAFETY,
		"defect_size": Vector2i(48, 48),
		"defect_desc": "Aptomat tổng đã gạt OFF nhưng đĩa nhôm công tơ điện vẫn quay từ từ.",
		"danger_tip": "⚠️ BẪY CÂU TRỘM / RÒ RỈ ĐIỆN: Đường dây âm tường bị rò hoặc bị phòng khác câu trộm điện sinh hoạt!",
		"legal_tip": "⚖️ QUYỀN LỢI: Yêu cầu thợ điện kiểm tra triệt để trước khi ký chốt số điện ban đầu.",
		"checklist_label": "5. Công tơ điện đứng yên khi ngắt cầu dao"
	}
]

# State variables
var inspected_hotspots: Dictionary = {} # id -> true
var safety_score: int = 100
var active_hotspot_id: String = ""

# UI Node References
@onready var btn_back: Button = $HeaderBar/HBox/BtnBack
@onready var btn_info: Button = $HeaderBar/HBox/BtnInfo
@onready var lbl_speech: Label = $MainLayout/SpeechSection/CatBubble/LblSpeech
@onready var lbl_score: Label = $MainLayout/ScoreSection/VBox/HBoxScore/LblScoreValue
@onready var lbl_defect_count: Label = $MainLayout/ScoreSection/VBox/HBoxScore/LblDefectCount
@onready var bar_safety: ProgressBar = $MainLayout/ScoreSection/VBox/SafetyBar
@onready var room_viewport: TextureRect = $MainLayout/StageSection/RoomCard/RoomTextureRect
@onready var hotspots_layer: Control = $MainLayout/StageSection/RoomCard/HotspotsLayer
@onready var checklist_container: VBoxContainer = $MainLayout/ChecklistSection/ScrollChecklist/ChecklistVBox
@onready var modal_magnifier: PanelContainer = $MagnifierModal
@onready var modal_verdict: PanelContainer = $VerdictModal
@onready var modal_result: PanelContainer = $ResultModal
@onready var btn_open_verdict: Button = $MainLayout/BottomActionSection/BtnSubmitVerdict

func _ready() -> void:
	super._ready()
	_setup_ui_bindings()
	_setup_room_texture()
	_create_hotspot_buttons()
	_build_checklist_ui()
	_update_safety_display()
	
	if data.is_empty():
		data = {
			"lesson_id": 5,
			"title": "Thám Tử Khảo Sát Hiện Trạng Phòng Trọ",
			"hotspots": HOTSPOTS_DATA
		}
	
	begin_minigame_loop("🔍 Hãy dùng kính lúp soi đủ 5 vị trí nghi vấn trong phòng trọ!")

func _setup_ui_bindings() -> void:
	btn_back.pressed.connect(_on_back_pressed)
	btn_info.pressed.connect(_on_info_pressed)
	btn_open_verdict.pressed.connect(_on_open_verdict_pressed)
	
	modal_magnifier.visible = false
	modal_verdict.visible = false
	modal_result.visible = false
	
	var btn_mag_close = modal_magnifier.find_child("BtnCloseMagnifier", true, false)
	if btn_mag_close:
		btn_mag_close.pressed.connect(_on_magnifier_close_pressed)

	var btn_v_repair = modal_verdict.find_child("BtnVerdictRepair", true, false)
	if btn_v_repair:
		btn_v_repair.pressed.connect(func(): _submit_verdict("repair"))
	var btn_v_reject = modal_verdict.find_child("BtnVerdictReject", true, false)
	if btn_v_reject:
		btn_v_reject.pressed.connect(func(): _submit_verdict("reject"))
	var btn_v_sign = modal_verdict.find_child("BtnVerdictSignBlind", true, false)
	if btn_v_sign:
		btn_v_sign.pressed.connect(func(): _submit_verdict("sign_blind"))
		
	var btn_res_replay = modal_result.find_child("BtnReplay", true, false)
	if btn_res_replay:
		btn_res_replay.pressed.connect(func(): get_tree().reload_current_scene())
	var btn_res_menu = modal_result.find_child("BtnMenu", true, false)
	if btn_res_menu:
		btn_res_menu.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))

func _setup_room_texture() -> void:
	if ResourceLoader.exists(ROOM_BG_PATH):
		var bg_tex = load(ROOM_BG_PATH) as Texture2D
		if bg_tex:
			room_viewport.texture = bg_tex
	else:
		# Fallback to placeholder if room asset missing
		room_viewport.texture = PixelPlaceholderFactory.get_or_create(
			"Room1",
			Vector2i(512, 512),
			PixelPlaceholderFactory.Category.DEFAULT,
			"PHÒNG 2.5D"
		)
	room_viewport.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

## Create 5 interactive pulsing Hotspot nodes over the 2.5D room stage
func _create_hotspot_buttons() -> void:
	for ch in hotspots_layer.get_children():
		ch.queue_free()

	for hotspot in HOTSPOTS_DATA:
		var hs_id: String = hotspot["id"]
		var btn := Button.new()
		btn.name = "BtnHotspot_" + hs_id
		btn.custom_minimum_size = Vector2(40, 40)
		btn.text = hotspot["icon"]
		btn.tooltip_text = hotspot["title"]
		
		# Styling: round retro button with pulsing outline
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(1, 0.95, 0.8, 0.85)
		sb.border_color = Color("#F28C1F")
		sb.set_border_width_all(2)
		sb.set_corner_radius_all(20)
		btn.add_theme_stylebox_override("normal", sb)
		btn.add_theme_font_size_override("font_size", 14)
		
		# Position normalized to stage size
		var pos_norm: Vector2 = hotspot["pos_normalized"]
		btn.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		btn.anchor_left = pos_norm.x
		btn.anchor_top = pos_norm.y
		btn.anchor_right = pos_norm.x
		btn.anchor_bottom = pos_norm.y
		btn.offset_left = -20
		btn.offset_top = -20
		btn.offset_right = 20
		btn.offset_bottom = 20

		btn.pressed.connect(func(): _on_hotspot_clicked(hotspot))
		hotspots_layer.add_child(btn)

## Build 5-point checklist UI
func _build_checklist_ui() -> void:
	for ch in checklist_container.get_children():
		ch.queue_free()

	for hotspot in HOTSPOTS_DATA:
		var hs_id: String = hotspot["id"]
		var hbox := HBoxContainer.new()
		hbox.name = "CheckRow_" + hs_id
		
		var chk := CheckBox.new()
		chk.name = "Chk_" + hs_id
		chk.text = hotspot["checklist_label"]
		chk.disabled = true # Checked only when inspected
		chk.add_theme_font_size_override("font_size", 10)
		chk.add_theme_color_override("font_color", Color("#3E2723"))
		hbox.add_child(chk)
		
		checklist_container.add_child(hbox)

func _on_hotspot_clicked(hotspot: Dictionary) -> void:
	if not can_accept_input():
		return
		
	active_hotspot_id = hotspot["id"]
	_show_magnifier_lens(hotspot)

## Display Magnifier Lens modal
func _show_magnifier_lens(hotspot: Dictionary) -> void:
	modal_magnifier.visible = true
	var lbl_title = modal_magnifier.find_child("LblMagTitle", true, false)
	var tex_defect = modal_magnifier.find_child("TexMagDefect", true, false)
	var lbl_desc = modal_magnifier.find_child("LblMagDesc", true, false)
	var lbl_danger = modal_magnifier.find_child("LblMagDanger", true, false)
	var lbl_legal = modal_magnifier.find_child("LblMagLegal", true, false)
	
	if lbl_title:
		lbl_title.text = "🔍 SOI CHI TIẾT: " + hotspot["title"].to_upper()
	if lbl_desc:
		lbl_desc.text = hotspot["defect_desc"]
	if lbl_danger:
		lbl_danger.text = hotspot["danger_tip"]
	if lbl_legal:
		lbl_legal.text = hotspot["legal_tip"]
		
	if tex_defect:
		tex_defect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tex_defect.texture = PixelPlaceholderFactory.get_or_create(
			hotspot["defect_asset"],
			hotspot["defect_size"],
			hotspot["defect_category"],
			hotspot["short_name"]
		)

func _on_magnifier_close_pressed() -> void:
	modal_magnifier.visible = false
	if active_hotspot_id != "" and not inspected_hotspots.has(active_hotspot_id):
		inspected_hotspots[active_hotspot_id] = true
		_mark_hotspot_inspected(active_hotspot_id)
		_update_safety_display()
		
		var remaining: int = HOTSPOTS_DATA.size() - inspected_hotspots.size()
		if remaining > 0:
			lbl_speech.text = "✓ Đã ghi nhận lỗi! Còn %d vị trí nữa cần soi kỹ." % remaining
		else:
			lbl_speech.text = "🎉 Đã phát hiện toàn bộ 5 rủi ro! Hãy bấm 'Nghiệm Thu' để đưa ra phán quyết."
			btn_open_verdict.modulate = Color(1.1, 1.1, 0.9)

func _mark_hotspot_inspected(hs_id: String) -> void:
	# Update hotspot button visual
	var btn = hotspots_layer.find_child("BtnHotspot_" + hs_id, true, false)
	if btn:
		btn.text = "✓"
		btn.modulate = Color(0.4, 0.9, 0.5)
		
	# Update checklist checkbox
	var chk = checklist_container.find_child("Chk_" + hs_id, true, false)
	if chk:
		chk.button_pressed = true
		chk.text += " (Đã phát hiện lỗi)"
		chk.add_theme_color_override("font_color", Color("#D94132"))

func _update_safety_display() -> void:
	var count: int = inspected_hotspots.size()
	# Each defect identified docks safety score from 100 towards real safety rating (e.g. 40/100)
	safety_score = maxi(40, 100 - count * 12)
	lbl_score.text = "Điểm An Toàn: %d/100" % safety_score
	lbl_defect_count.text = "Đã soi: %d / 5 lỗi" % count
	bar_safety.value = safety_score

func _on_open_verdict_pressed() -> void:
	if not can_accept_input():
		return
	modal_verdict.visible = true

## Process real-world legal verdict selection
func _submit_verdict(choice: String) -> void:
	modal_verdict.visible = false
	
	match choice:
		"repair":
			# Best choice: demand repairs before deposit
			_trigger_verdict_result(
				"🎉 QUYẾT ĐỊNH XUẤT SẮC!",
				Color("#40B86B"),
				"Bạn đã lập biên bản hiện trạng chi tiết và yêu cầu chủ nhà sửa chữa xong mới chuyển tiền cọc.\n✓ Không lo mất tiền oan!\n✓ Bảo vệ quyền lợi pháp lý 100%!"
			)
		"reject":
			# Safe choice: reject due to lethal fire hazards
			_trigger_verdict_result(
				"🛡️ BẢO VỆ TÍNH MẠNG THÀNH CÔNG!",
				Color("#5B9BD5"),
				"Bạn đã dứt khoát từ chối thuê căn phòng này vì chuồng cọp hàn kín vi phạm nghiêm trọng an toàn PCCC.\nTốt hơn hết là tìm căn phòng có lối thoát nạn an toàn!"
			)
		"sign_blind":
			# Safe Failure triggered
			safe_failure_count += 1
			_trigger_verdict_result(
				"⚠️ BẪY THỬ SAI: KÝ LIỀU NHẬN PHÒNG",
				Color("#D94132"),
				"Chỉ sau 2 tuần ở: Vòi nước rỉ làm hóa đơn tăng 200k, mưa to dột ướt laptop, và phòng bị mất trộm vì khóa lỏng!\n👉 BÀI HỌC: Đừng bao giờ nhận phòng khi chưa lập biên bản hiện trạng!"
			)

func _trigger_verdict_result(title: String, col: Color, desc: String) -> void:
	modal_result.visible = true
	var lbl_title = modal_result.find_child("LblResultTitle", true, false)
	var lbl_desc = modal_result.find_child("LblResultDesc", true, false)
	if lbl_title:
		lbl_title.text = title
		lbl_title.add_theme_color_override("font_color", col)
	if lbl_desc:
		lbl_desc.text = desc
	complete_minigame(0.1, {
		"inspected_count": inspected_hotspots.size(),
		"final_safety_score": safety_score,
		"safe_failures": safe_failure_count
	})

func _on_back_pressed() -> void:
	if not back_requested.get_connections().is_empty():
		emit_signal("back_requested")
	else:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_info_pressed() -> void:
	lbl_speech.text = "💡 Chạm vào các vòng tròn nhấp nháy trên phòng trọ để soi lỗi kỹ thuật và rủi ro pháp lý!"
