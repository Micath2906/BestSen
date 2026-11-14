extends Control

# LessonView.gd - TRÒ CHƠI HỌC KỸ NĂNG: GHÉP HÌNH ẢNH VỚI THẺ HÀNH ĐỘNG (NATIVE DRAG & DROP GAME)
# Cơ chế Kéo Thả Chuẩn Native Godot 4 (_get_drag_data, _can_drop_data, _drop_data)
# Tuyệt đối không dùng nút nối hay cơ chế chắp vá. Trải nghiệm mượt mà, chuyên nghiệp.

signal back_requested
signal run_simulation_requested(lesson_id, user_sequence, is_correct)
signal open_story_mode_requested
signal open_handbook_requested

# =========================================================================
# LỚP NATIVE DRAG & DROP CHO THẺ TỪ NGỮ VÀ Ô CHẶNG HÌNH ẢNH
# =========================================================================
class DraggableCardControl extends PanelContainer:
	var card_data: Dictionary = {}
	var lesson_view: Control = null
	var is_matched: bool = false
	var is_selected_tap: bool = false
	
	func _get_drag_data(_at_position: Vector2) -> Variant:
		if is_matched or lesson_view == null:
			return null
		SoundManager.play_card_pop()
		var preview = lesson_view._create_drag_preview_for_card(card_data)
		set_drag_preview(preview)
		return card_data
		
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if not is_matched and lesson_view != null:
				lesson_view._on_card_tap_selected(card_data)

class DroppableSlotControl extends PanelContainer:
	var slot_index: int = 0
	var lesson_view: Control = null
	var is_matched: bool = false
	
	func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
		if is_matched or lesson_view == null:
			return false
		return data is Dictionary and data.has("step")
		
	func _drop_data(_at_position: Vector2, data: Variant) -> void:
		if lesson_view != null:
			lesson_view._attempt_match_card_to_slot(data, slot_index)
			
	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if lesson_view != null:
				if not lesson_view.selected_word_card.is_empty():
					lesson_view._attempt_match_card_to_slot(lesson_view.selected_word_card, slot_index)
					lesson_view.selected_word_card.clear()
					lesson_view._render_cards_pool()
				elif is_matched:
					lesson_view._remove_card_from_slot(slot_index)

# =========================================================================
# KHAI BÁO NODES & PRELOADS
# =========================================================================
@onready var title_label: Label = $Header/TitleLabel
@onready var context_label: Label = $Header/ContextLabel
@onready var slots_container: HBoxContainer = $SlotsSection/SlotsContainer
@onready var cards_pool_container: VBoxContainer = $CardsSection/ScrollContainer/CardsPoolContainer
@onready var btn_submit: Button = $ActionFooter/BtnSubmit
@onready var btn_reset: Button = $ActionFooter/BtnReset
@onready var btn_guide: Button = $Header/BtnGuide
@onready var btn_achievements: Button = $Header.get_node_or_null("BtnAchievements")
@onready var btn_story_mode: Button = $Header.get_node_or_null("BtnStoryMode")
@onready var btn_switch_to_minigame: Button = $Header.get_node_or_null("BtnSwitchToMinigame")
@onready var minigame_host: Control = get_node_or_null("MiniGameHost")
@onready var guide_modal: Control = $GuideModal
@onready var guide_content: Label = $GuideModal/ModalPanel/ModalVBox/ScrollContainer/GuideContent
@onready var cat_bubble: Label = $CatSection/CatBubbleLabel
@onready var btn_close_guide: Button = $GuideModal/ModalPanel/ModalVBox/BtnCloseGuide

const AchievementModalScene = preload("res://scenes/AchievementModal.tscn")
var achievement_modal: Control = null

const StoryLessonViewScene = preload("res://scenes/StoryLessonView.tscn")
var story_lesson_view: Control = null

const MINIGAME_SCENES = {
	"qte": preload("res://scenes/minigames/QteMiniGame.tscn"),
	"audit": preload("res://scenes/minigames/AuditMiniGame.tscn"),
	"packing": preload("res://scenes/minigames/PackingMiniGame.tscn"),
	"preparation_vali": preload("res://scenes/minigames/PreparationValiGame.tscn"),
	"hospital_choice": preload("res://scenes/minigames/HospitalChoiceGame.tscn"),
	"medicine_diagnosis": preload("res://scenes/minigames/SelfDiagnosisGame.tscn"),
	"budget": preload("res://scenes/minigames/BudgetMiniGame.tscn"),
	"dialogue": preload("res://scenes/minigames/DialogueMiniGame.tscn"),
	"bhyt_process": preload("res://scenes/minigames/HospitalBHYTProcessGame.tscn"),
	"rental_contract": preload("res://scenes/minigames/RentalContractGame.tscn"),
	"labor_rights": preload("res://scenes/minigames/LaborRightsGame.tscn"),
	"cyber_security": preload("res://scenes/minigames/CyberSecurityGame.tscn"),
	"traffic_safety": preload("res://scenes/minigames/TrafficSafetyGame.tscn"),
	"public_admin": preload("res://scenes/minigames/PublicAdminGame.tscn"),
	"personal_finance": preload("res://scenes/minigames/PersonalFinanceGame.tscn"),
	"time_management": preload("res://scenes/minigames/TimeManagementGame.tscn"),
	"communication_conflict": preload("res://scenes/minigames/CommunicationConflictGame.tscn"),
	"self_care_living": preload("res://scenes/minigames/SelfCareLivingGame.tscn"),
	"motorbike_maintenance": preload("res://scenes/minigames/MotorbikeMaintenanceGame.tscn"),
	"route_master": preload("res://scenes/minigames/RouteMasterMiniGame.tscn"),
	"checkin_rush": preload("res://scenes/minigames/CheckInRushGame.tscn"),
	"civilized_ride": preload("res://scenes/minigames/CivilizedRideGame.tscn"),
	"transit_simulation": preload("res://scenes/minigames/TransitSimulation.tscn")
}

# DỮ LIỆU HÌNH ẢNH MINH HỌA & ASSETS CHO 16 BÀI HỌC KỸ NĂNG SỐNG
const LESSON_IMAGE_DATA = {
	1: [
		{"title": "Xếp đồ đúng ngăn Vali", "clue": "Phân loại 4 ngăn vali", "asset": "res://assets/sprites/skills/lesson_01_step_1.png", "icon": "📦"},
		{"title": "Dán nhãn công dụng thuốc", "clue": "Hộp thuốc sơ cứu", "asset": "res://assets/sprites/skills/lesson_01_step_2.png", "icon": "🏷️"},
		{"title": "Điền khuyết lời mẹ dặn", "clue": "Ghi nhớ cách dùng & lưu ý", "asset": "res://assets/sprites/skills/lesson_01_step_3.png", "icon": "📜"},
		{"title": "Khóa vali tự tin lên đường", "clue": "Hành trang sẵn sàng 100%", "asset": "res://assets/sprites/skills/lesson_01_step_4.png", "icon": "🎒"},
	],
	2: [
		{"title": "Khám triệu chứng bạn cùng phòng", "clue": "Đánh giá tình trạng", "asset": "res://assets/sprites/skills/lesson_02_step_1.png", "icon": "🤕"},
		{"title": "Xác định chuyên khoa điều trị", "clue": "Chọn khoa phù hợp", "asset": "res://assets/sprites/skills/lesson_02_step_2.png", "icon": "🩺"},
		{"title": "Chọn đúng bệnh viện chuyên sâu", "clue": "Bệnh viện tuyến đầu", "asset": "res://assets/sprites/skills/lesson_02_step_3.png", "icon": "🏥"},
		{"title": "Cấp cứu kịp thời đúng nơi", "clue": "Cứu chữa an toàn", "asset": "res://assets/sprites/skills/lesson_02_step_4.png", "icon": "🚑"},
	],
	3: [
		{"title": "Dùng dụng cụ đo chỉ số cơ thể", "clue": "Nhiệt kế điện tử 38.8 độ", "asset": "res://assets/sprites/skills/lesson_03_step_1.png", "icon": "🌡️"},
		{"title": "Lập bảng thống kê triệu chứng", "clue": "Bảng theo dõi chỉ số", "asset": "res://assets/sprites/skills/lesson_03_step_2.png", "icon": "📋"},
		{"title": "Chọn đúng thuốc đặc trị", "clue": "Uống đúng Paracetamol", "asset": "res://assets/sprites/skills/lesson_03_step_3.png", "icon": "💊"},
		{"title": "Hồi phục sức khỏe an toàn", "clue": "Hạ sốt thành công", "asset": "res://assets/sprites/skills/lesson_03_step_4.png", "icon": "✨"},
	],
	4: [
		{"title": "Dừng xe bật đèn báo", "clue": "Báo hiệu chết máy", "asset": "res://assets/sprites/skills/lesson_04_step_1.png", "icon": "🛑"},
		{"title": "Kiểm tra bugi & xăng", "clue": "Soi lỗi cơ bản", "asset": "res://assets/sprites/skills/lesson_04_step_2.png", "icon": "🔍"},
		{"title": "Gọi đội SOS sinh viên", "clue": "Tìm cứu trợ uy tín", "asset": "res://assets/sprites/skills/lesson_04_step_3.png", "icon": "📞"},
		{"title": "Giám sát sửa xe trực tiếp", "clue": "Tránh bị chặt chém", "asset": "res://assets/sprites/skills/lesson_04_step_4.png", "icon": "👀"},
	],
	5: [
		{"title": "Soi điều khoản cọc", "clue": "Đọc kỹ hợp đồng", "asset": "res://assets/sprites/skills/lesson_05_step_1.png", "icon": "📑"},
		{"title": "Chốt giá điện nước", "clue": "Ghi nhận công tơ", "asset": "res://assets/sprites/skills/lesson_05_step_2.png", "icon": "⚡"},
		{"title": "Chụp hiện trạng phòng", "clue": "Lưu bằng chứng bàn giao", "asset": "res://assets/sprites/skills/lesson_05_step_3.png", "icon": "📸"},
		{"title": "Ký giữ hợp đồng gốc", "clue": "Giữ căn cứ pháp lý", "asset": "res://assets/sprites/skills/lesson_05_step_4.png", "icon": "✍️"},
	],
	6: [
		{"title": "Kiểm tra chuồng cọp", "clue": "Khảo sát ban công", "asset": "res://assets/sprites/skills/lesson_06_step_1.png", "icon": "🚪"},
		{"title": "Soi kim bình cứu hỏa", "clue": "Kim ở vạch xanh", "asset": "res://assets/sprites/skills/lesson_06_step_2.png", "icon": "🧯"},
		{"title": "Định vị lối sân thượng", "clue": "Đường thoát hiểm thứ 2", "asset": "res://assets/sprites/skills/lesson_06_step_3.png", "icon": "🪜"},
		{"title": "Chuẩn bị khăn & đèn pin", "clue": "Vật phẩm sinh tồn", "asset": "res://assets/sprites/skills/lesson_06_step_4.png", "icon": "🔦"},
	],
	7: [
		{"title": "Lấy CCCD chủ trọ", "clue": "Thu thập hồ sơ", "asset": "res://assets/sprites/skills/lesson_07_step_1.png", "icon": "🪪"},
		{"title": "Đăng nhập VNeID mức 2", "clue": "Cổng DVC Quốc gia", "asset": "res://assets/sprites/skills/lesson_07_step_2.png", "icon": "📲"},
		{"title": "Tải ảnh hợp đồng trọ", "clue": "Tải chứng từ hợp lệ", "asset": "res://assets/sprites/skills/lesson_07_step_3.png", "icon": "📤"},
		{"title": "Lưu mã hồ sơ phê duyệt", "clue": "Theo dõi phê duyệt", "asset": "res://assets/sprites/skills/lesson_07_step_4.png", "icon": "✅"},
	],
	8: [
		{"title": "Họp phòng trà sữa", "clue": "Không khí cởi mở", "asset": "res://assets/sprites/skills/lesson_08_step_1.png", "icon": "🍵"},
		{"title": "Dán lịch trực nhật", "clue": "Trách nhiệm rõ ràng", "asset": "res://assets/sprites/skills/lesson_08_step_2.png", "icon": "🧹"},
		{"title": "Tạo app chia tiền quỹ", "clue": "Minh bạch tài chính", "asset": "res://assets/sprites/skills/lesson_08_step_3.png", "icon": "📊"},
		{"title": "Chốt giờ giới nghiêm", "clue": "Tôn trọng giấc ngủ", "asset": "res://assets/sprites/skills/lesson_08_step_4.png", "icon": "🌙"},
	],
	9: [
		{"title": "Kẹp nhiệt kế 38.5°C", "clue": "Đo đúng thân nhiệt", "asset": "res://assets/sprites/skills/lesson_09_step_1.png", "icon": "🌡️"},
		{"title": "Uống đúng liều Para", "clue": "10-15mg/kg cân nặng", "asset": "res://assets/sprites/skills/lesson_09_step_2.png", "icon": "💊"},
		{"title": "Lau khăn nước ấm", "clue": "Hạ nhiệt vật lý", "asset": "res://assets/sprites/skills/lesson_09_step_3.png", "icon": "💧"},
		{"title": "Uống từng ngụm Oresol", "clue": "Bù nước điện giải", "asset": "res://assets/sprites/skills/lesson_09_step_4.png", "icon": "🥤"},
	],
	10: [
		{"title": "Bốc số BHYT sớm", "clue": "Tránh chờ đợi lâu", "asset": "res://assets/sprites/skills/lesson_10_step_1.png", "icon": "🎟️"},
		{"title": "Xuất trình CCCD & BHYT", "clue": "Tiếp nhận hồ sơ", "asset": "res://assets/sprites/skills/lesson_10_step_2.png", "icon": "🪪"},
		{"title": "Vào gặp bác sĩ khám", "clue": "Khám và chẩn đoán", "asset": "res://assets/sprites/skills/lesson_10_step_3.png", "icon": "🩺"},
		{"title": "Lấy thuốc kho Dược BHYT", "clue": "Nhận thuốc chuẩn viện", "asset": "res://assets/sprites/skills/lesson_10_step_4.png", "icon": "💊"},
	],
	11: [
		{"title": "Xếp hạ sốt & nhiệt kế", "clue": "Xử lý cảm sốt", "asset": "res://assets/sprites/skills/lesson_11_step_1.png", "icon": "🩹"},
		{"title": "Bổ sung Berberin tiêu hóa", "clue": "Bảo vệ đường ruột", "asset": "res://assets/sprites/skills/lesson_11_step_2.png", "icon": "🧪"},
		{"title": "Chuẩn bị cồn đỏ & gạc", "clue": "Sát khuẩn vết thương", "asset": "res://assets/sprites/skills/lesson_11_step_3.png", "icon": "🩸"},
		{"title": "Dán nhãn hạn sử dụng", "clue": "Định kỳ kiểm tra", "asset": "res://assets/sprites/skills/lesson_11_step_4.png", "icon": "🏷️"},
	],
	12: [
		{"title": "Nói không với mì sống", "clue": "Bảo vệ dạ dày", "asset": "res://assets/sprites/skills/lesson_12_step_1.png", "icon": "🚫"},
		{"title": "Nấu sôi chần bỏ nước đầu", "clue": "Giảm dầu chiên", "asset": "res://assets/sprites/skills/lesson_12_step_2.png", "icon": "🍲"},
		{"title": "Thêm trứng & rau xanh", "clue": "Bổ sung dinh dưỡng", "asset": "res://assets/sprites/skills/lesson_12_step_3.png", "icon": "🥚"},
		{"title": "Ăn đúng giờ bảo vệ bao tử", "clue": "Nạp năng lượng học tập", "asset": "res://assets/sprites/skills/lesson_12_step_4.png", "icon": "🥗"},
	],
	13: [
		{"title": "Chia ngay 3 phần tiền", "clue": "Nhận tiền sinh hoạt", "asset": "res://assets/sprites/skills/lesson_13_step_1.png", "icon": "🪙"},
		{"title": "Khóa 50% tiền trọ & ăn", "clue": "Nhu cầu thiết yếu", "asset": "res://assets/sprites/skills/lesson_13_step_2.png", "icon": "🏠"},
		{"title": "Dành 30% học & phát triển", "clue": "Đầu tư bản thân", "asset": "res://assets/sprites/skills/lesson_13_step_3.png", "icon": "📚"},
		{"title": "Niêm phong 20% khẩn cấp", "clue": "Quỹ dự phòng an toàn", "asset": "res://assets/sprites/skills/lesson_13_step_4.png", "icon": "🔒"},
	],
	14: [
		{"title": "Soi lãi khủng phi lý", "clue": "Cảnh giác 300%", "asset": "res://assets/sprites/skills/lesson_14_step_1.png", "icon": "📉"},
		{"title": "Kiểm tra sản phẩm thật", "clue": "Hàng không rõ nguồn", "asset": "res://assets/sprites/skills/lesson_14_step_2.png", "icon": "📦"},
		{"title": "Cất chặt ví & CCCD", "clue": "Tuyệt đối không giao", "asset": "res://assets/sprites/skills/lesson_14_step_3.png", "icon": "🚫"},
		{"title": "Rời hội thảo dứt khoát", "clue": "Thoát bẫy tâm lý", "asset": "res://assets/sprites/skills/lesson_14_step_4.png", "icon": "🏃"},
	],
	15: [
		{"title": "Trình CV khớp lịch học", "clue": "Ưu tiên việc học", "asset": "res://assets/sprites/skills/lesson_15_step_1.png", "icon": "📄"},
		{"title": "Chốt lương giờ & ngày trả", "clue": "Rõ ràng minh bạch", "asset": "res://assets/sprites/skills/lesson_15_step_2.png", "icon": "💵"},
		{"title": "Từ chối nộp cọc & CCCD", "clue": "Bảo vệ quyền lợi", "asset": "res://assets/sprites/skills/lesson_15_step_3.png", "icon": "🛡️"},
		{"title": "Ký thỏa thuận trước ca", "clue": "Có căn cứ bảo vệ", "asset": "res://assets/sprites/skills/lesson_15_step_4.png", "icon": "🤝"},
	],
	16: [
		{"title": "Kích hoạt phanh 48 giờ", "clue": "Hạ nhiệt bốc đồng", "asset": "res://assets/sprites/skills/lesson_16_step_1.png", "icon": "⏳"},
		{"title": "Soi phí trễ hạn & phạt", "clue": "Tính lãi kép BNPL", "asset": "res://assets/sprites/skills/lesson_16_step_2.png", "icon": "🔍"},
		{"title": "Chỉ mua khi có tiền mặt", "clue": "Kỷ luật chi tiêu", "asset": "res://assets/sprites/skills/lesson_16_step_3.png", "icon": "🤔"},
		{"title": "Khóa hạn mức ví trả sau", "clue": "Cắt nguồn nợ nần", "asset": "res://assets/sprites/skills/lesson_16_step_4.png", "icon": "🔒"},
	]
}

const STEP_COLORS = {
	1: {"bg": Color(0.89, 0.95, 1.0), "border": Color(0.24, 0.64, 0.95), "text": Color(0.08, 0.42, 0.72), "badge": "CHẶNG 1"},
	2: {"bg": Color(1.0, 0.96, 0.88), "border": Color(0.96, 0.65, 0.22), "text": Color(0.78, 0.36, 0.05), "badge": "CHẶNG 2"},
	3: {"bg": Color(0.88, 0.96, 0.92), "border": Color(0.20, 0.72, 0.55), "text": Color(0.06, 0.48, 0.32), "badge": "CHẶNG 3"},
	4: {"bg": Color(0.98, 0.90, 0.94), "border": Color(0.90, 0.40, 0.62), "text": Color(0.74, 0.16, 0.38), "badge": "CHẶNG 4"},
}

var current_lesson_id: int = 1
var lesson_data: Dictionary = {}
var shuffled_cards: Array = []
var matched_slots: Dictionary = {} # slot_idx (0..3) -> card Dictionary
var selected_sequence: Array = [] # Danh sách thẻ để tương thích 100% với QA tests
var selected_word_card: Dictionary = {} # Cho cơ chế chạm 2 bước (Tap-to-Pair)
var current_mode: String = "cards"
var active_minigame_instance: Control = null

# Hệ thống Gamification & Rating
var mistakes_count: int = 0
var combo_count: int = 0

func _ready() -> void:
	_setup_custom_ui_styles()
	btn_guide.pressed.connect(_on_guide_pressed)
	btn_close_guide.pressed.connect(func():
		SoundManager.play_click()
		guide_modal.visible = false
	)
	
	# Khởi tạo Modal Thành Tựu
	achievement_modal = AchievementModalScene.instantiate()
	add_child(achievement_modal)
	if btn_achievements:
		btn_achievements.pressed.connect(func():
			SoundManager.play_click()
			if achievement_modal:
				achievement_modal.open()
		)
	if btn_story_mode:
		btn_story_mode.pressed.connect(func():
			SoundManager.play_click()
			_open_story_mode()
		)
	if btn_switch_to_minigame:
		btn_switch_to_minigame.pressed.connect(func():
			SoundManager.play_click()
			set_mode("minigame")
		)
	btn_reset.pressed.connect(_reset_selection)
	btn_submit.pressed.connect(_on_submit_pressed)
	$Header/BtnBack.pressed.connect(func(): emit_signal("back_requested"))

func _setup_custom_ui_styles() -> void:
	# Nút Thoát
	var back_btn = $Header/BtnBack
	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color(0.96, 0.93, 0.89, 1.0)
	back_style.border_color = Color(0.82, 0.74, 0.66, 1.0)
	back_style.set_border_width_all(2)
	back_style.border_width_bottom = 3
	back_style.set_corner_radius_all(12)
	back_style.content_margin_left = 12
	back_style.content_margin_right = 12
	back_btn.add_theme_stylebox_override("normal", back_style)
	back_btn.add_theme_stylebox_override("hover", back_style)
	back_btn.add_theme_stylebox_override("pressed", back_style)
	back_btn.add_theme_color_override("font_color", Color(0.38, 0.26, 0.16, 1.0))
	back_btn.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	back_btn.text = " Thoát"

	# Nút Cẩm Nang Bỏ Túi
	var guide_style = StyleBoxFlat.new()
	guide_style.bg_color = Color(1.0, 0.95, 0.90, 1.0)
	guide_style.border_color = Color(0.92, 0.55, 0.25, 1.0)
	guide_style.set_border_width_all(2)
	guide_style.border_width_bottom = 3
	guide_style.set_corner_radius_all(14)
	guide_style.content_margin_left = 12
	guide_style.content_margin_right = 12
	btn_guide.add_theme_stylebox_override("normal", guide_style)
	btn_guide.add_theme_stylebox_override("hover", guide_style)
	btn_guide.add_theme_stylebox_override("pressed", guide_style)
	btn_guide.add_theme_color_override("font_color", Color(0.75, 0.32, 0.10, 1.0))
	btn_guide.text = "📖 Sổ Tay Bỏ Túi"

	# Nút Thành Tựu
	if btn_achievements:
		var achv_style = StyleBoxFlat.new()
		achv_style.bg_color = Color(1.0, 0.94, 0.85, 1.0)
		achv_style.border_color = Color(0.92, 0.65, 0.25, 1.0)
		achv_style.set_border_width_all(2)
		achv_style.border_width_bottom = 3
		achv_style.set_corner_radius_all(14)
		achv_style.content_margin_left = 10
		achv_style.content_margin_right = 10
		btn_achievements.add_theme_stylebox_override("normal", achv_style)
		btn_achievements.add_theme_stylebox_override("hover", achv_style)
		btn_achievements.add_theme_stylebox_override("pressed", achv_style)
		btn_achievements.add_theme_color_override("font_color", Color(0.85, 0.40, 0.08, 1.0))
		btn_achievements.text = "🏆 Thành Tựu"

	# Nút Chuyện Kể (Interactive Storytelling Adventure)
	if btn_story_mode:
		var story_style = StyleBoxFlat.new()
		story_style.bg_color = Color(1.0, 0.94, 0.88, 1.0)
		story_style.border_color = Color(0.95, 0.55, 0.20, 1.0)
		story_style.set_border_width_all(2)
		story_style.border_width_bottom = 3
		story_style.set_corner_radius_all(14)
		story_style.content_margin_left = 10
		story_style.content_margin_right = 10
		btn_story_mode.add_theme_stylebox_override("normal", story_style)
		btn_story_mode.add_theme_stylebox_override("hover", story_style)
		btn_story_mode.add_theme_stylebox_override("pressed", story_style)
		btn_story_mode.add_theme_color_override("font_color", Color(0.85, 0.38, 0.08, 1.0))
		btn_story_mode.text = "📜 Chuyện Kể"

	# Bóng thoại Boss Mèo
	var cat_sec = get_node_or_null("CatSection")
	if cat_sec:
		var bubble_style = StyleBoxFlat.new()
		bubble_style.bg_color = Color(1.0, 0.985, 0.94, 1.0)
		bubble_style.border_color = Color(0.88, 0.75, 0.60, 1.0)
		bubble_style.set_border_width_all(2)
		bubble_style.border_width_bottom = 3
		bubble_style.set_corner_radius_all(14)
		bubble_style.content_margin_left = 16
		bubble_style.content_margin_right = 16
		bubble_style.content_margin_top = 8
		bubble_style.content_margin_bottom = 8
		cat_sec.add_theme_stylebox_override("panel", bubble_style)
		cat_bubble.add_theme_color_override("font_color", Color(0.32, 0.20, 0.10, 1.0))

	# Tiêu đề khu vực Gamification
	var slots_title = get_node_or_null("SlotsSection/SlotsTitle")
	if slots_title:
		slots_title.text = "🎯 HÀNH TRÌNH TÌNH HUỐNG (Kéo thẻ hành động vào từng chặng):"
		slots_title.add_theme_color_override("font_color", Color(0.42, 0.30, 0.20, 1.0))
		slots_title.add_theme_font_size_override("font_size", 12)
		
	var cards_title = get_node_or_null("CardsSection/CardsTitle")
	if cards_title:
		cards_title.text = "🐾 KHO THẺ HÀNH ĐỘNG (Kéo thẻ thả vào hình hoặc chạm để đặt):"
		cards_title.add_theme_color_override("font_color", Color(0.42, 0.30, 0.20, 1.0))
		cards_title.add_theme_font_size_override("font_size", 12)

	# Nút Xếp Lại
	var reset_style = StyleBoxFlat.new()
	reset_style.bg_color = Color(0.95, 0.92, 0.88, 1.0)
	reset_style.border_color = Color(0.80, 0.72, 0.64, 1.0)
	reset_style.set_border_width_all(2)
	reset_style.border_width_bottom = 3
	reset_style.set_corner_radius_all(14)
	reset_style.content_margin_left = 14
	reset_style.content_margin_right = 14
	btn_reset.add_theme_stylebox_override("normal", reset_style)
	btn_reset.add_theme_stylebox_override("hover", reset_style)
	btn_reset.add_theme_stylebox_override("pressed", reset_style)
	btn_reset.add_theme_color_override("font_color", Color(0.42, 0.32, 0.22, 1.0))
	btn_reset.text = "🔄 Xếp Lại"

func load_lesson(lesson_id: int) -> void:
	current_lesson_id = lesson_id
	lesson_data = GameManager.lessons_data.get(lesson_id, {})
	mistakes_count = 0
	combo_count = 0
	
	title_label.text = "Bài %d: %s" % [lesson_id, lesson_data.get("title", "")]
	var reward_exp = 40
	var reward_fish = lesson_data.get("reward_fish", 30)
	context_label.text = "🎯 Thử thách Kỹ Năng • Thưởng: +%d EXP, +%s 💵" % [
		reward_exp, GameManager.format_currency(reward_fish)
	]
	
	# Chuẩn bị nội dung Sổ Tay Sinh Viên (Đảm bảo tương thích 100% với QA Tests)
	var guide_lines = lesson_data.get("guide", [])
	var guide_str = "📌 BÍ KÍP BỎ TÚI CỦA SINH VIÊN:\n\n"
	for line in guide_lines:
		guide_str += "  ✔ " + line + "\n"
	
	guide_str += "\n🐾 TRÌNH TỰ TỪ NGỮ DẠY MÈO (BƯỚC 1 ➔ 2 ➔ 3 ➔ 4):\n\n"
	var sorted_cards = lesson_data.get("cards", []).duplicate()
	sorted_cards.sort_custom(func(a, b): return a["step"] < b["step"])
	for c in sorted_cards:
		guide_str += "  %d️⃣ Bước %d: %s  [%s] ➔ %s\n" % [c["step"], c["step"], c["icon"], c.get("meow", ""), c["text"]]
		
	guide_str += "\n💡 MẸO TỪ BOSS: Quan sát 4 bức hình bên trên rồi kéo từng thẻ từ ngữ thả vào đúng ô hình tương ứng nhé Sen!"
	guide_content.text = guide_str
	guide_modal.visible = false
	
	# Xáo trộn thẻ bài từ ngữ
	var original_cards = lesson_data.get("cards", []).duplicate()
	shuffled_cards = original_cards.duplicate()
	shuffled_cards.shuffle()
	
	cat_bubble.text = "Meo meo! Sen hãy kéo các thẻ hành động bên dưới thả vào từng bức hình để hoàn thành '%s' nhé! 🐾" % lesson_data.get("title", "")
	_reset_selection()
	_setup_lesson_minigame(lesson_id)

func _setup_lesson_minigame(lesson_id: int) -> void:
	if active_minigame_instance:
		active_minigame_instance.queue_free()
		active_minigame_instance = null
	if minigame_host:
		for child in minigame_host.get_children():
			minigame_host.remove_child(child)
			child.queue_free()
			
	if not GameManager.has_minigame(lesson_id):
		if btn_switch_to_minigame:
			btn_switch_to_minigame.visible = false
		set_mode("cards")
		return
		
	if btn_switch_to_minigame:
		btn_switch_to_minigame.visible = true
		
	var mg_data = GameManager.get_minigame_data(lesson_id)
	var mg_type = mg_data.get("type", "")
	if MINIGAME_SCENES.has(mg_type):
		var scn = MINIGAME_SCENES[mg_type]
		var mg_node = scn.instantiate()
		if minigame_host:
			minigame_host.add_child(mg_node)
		active_minigame_instance = mg_node
		mg_node.load_minigame(mg_data)
		mg_node.minigame_completed.connect(func(sim_steps):
			SoundManager.play_success()
			emit_signal("run_simulation_requested", lesson_id, sim_steps, true)
		)
		if mg_node.has_signal("back_requested"):
			mg_node.back_requested.connect(func():
				emit_signal("back_requested")
			)
		set_mode("minigame")
	else:
		set_mode("cards")

func set_mode(mode: String) -> void:
	current_mode = mode
	if mode == "minigame" and active_minigame_instance != null:
		if minigame_host:
			minigame_host.visible = true
		$CatSection.visible = false
		$SlotsSection.visible = false
		$CardsSection.visible = false
		$ActionFooter.visible = false
		$Header.visible = false
	else:
		if minigame_host:
			minigame_host.visible = false
		$CatSection.visible = true
		$SlotsSection.visible = true
		$CardsSection.visible = true
		$ActionFooter.visible = true
		$Header.visible = true

func _reset_selection() -> void:
	SoundManager.play_click()
	matched_slots.clear()
	selected_sequence.clear()
	selected_word_card.clear()
	_render_slots()
	_render_cards_pool()
	_update_submit_button()

func _open_story_mode() -> void:
	emit_signal("open_story_mode_requested")
	if not story_lesson_view:
		story_lesson_view = StoryLessonViewScene.instantiate()
		add_child(story_lesson_view)
		story_lesson_view.back_requested.connect(func():
			story_lesson_view.visible = false
		)
	var story = GameManager.get_story_by_lesson_id(current_lesson_id)
	if story.is_empty():
		story = GameManager.get_story_data("story_commute_bus_01")
	if not story.is_empty():
		story_lesson_view.load_story(story)
	story_lesson_view.visible = true

# =========================================================================
# 1. RENDER 4 KHUNG HÌNH ẢNH MINH HỌA (NATIVE DROP TARGETS)
# =========================================================================
func _render_slots() -> void:
	for child in slots_container.get_children():
		slots_container.remove_child(child)
		child.queue_free()
		
	var total_steps = lesson_data.get("cards", []).size()
	var img_info_list = LESSON_IMAGE_DATA.get(current_lesson_id, [])
	
	for i in range(total_steps):
		var step_num = i + 1
		var c_theme = STEP_COLORS.get(step_num, STEP_COLORS[1])
		var slot_idx = int(i)
		var is_matched = matched_slots.has(slot_idx)
		var matched_card = matched_slots.get(slot_idx, {})
		
		# Khung Card Hình Ảnh Native Drop
		var slot_panel = DroppableSlotControl.new()
		slot_panel.slot_index = slot_idx
		slot_panel.lesson_view = self
		slot_panel.is_matched = is_matched
		slot_panel.custom_minimum_size = Vector2(104, 148)
		slot_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var s_style = StyleBoxFlat.new()
		s_style.set_corner_radius_all(14)
		s_style.set_border_width_all(2)
		s_style.border_width_bottom = 3
		s_style.content_margin_left = 6
		s_style.content_margin_right = 6
		s_style.content_margin_top = 6
		s_style.content_margin_bottom = 6
		s_style.shadow_size = 4
		s_style.shadow_offset = Vector2(0, 2)
		
		if is_matched:
			s_style.bg_color = Color(0.95, 1.0, 0.96, 1.0)
			s_style.border_color = Color(0.20, 0.72, 0.40, 1.0) # Viền xanh ngọc khi đã nối đúng
			s_style.shadow_color = Color(0.1, 0.4, 0.2, 0.15)
		else:
			s_style.bg_color = Color(1.0, 0.99, 0.97, 1.0)
			s_style.border_color = c_theme["border"]
			s_style.shadow_color = Color(0.25, 0.15, 0.08, 0.10)
		slot_panel.add_theme_stylebox_override("panel", s_style)
		
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.add_theme_constant_override("separation", 3)
		
		# 1. Badge Tiêu Đề: [CHẶNG %d] + [✖ Gỡ nếu đã nối]
		var head_h = HBoxContainer.new()
		head_h.alignment = BoxContainer.ALIGNMENT_CENTER
		head_h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var badge_lbl = Label.new()
		badge_lbl.text = "CHẶNG %d" % step_num
		badge_lbl.add_theme_font_size_override("font_size", 10)
		badge_lbl.add_theme_color_override("font_color", c_theme["text"])
		badge_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		badge_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		head_h.add_child(badge_lbl)
		
		if is_matched:
			var unslot_btn = Button.new()
			unslot_btn.text = "✖"
			unslot_btn.add_theme_font_size_override("font_size", 10)
			unslot_btn.add_theme_color_override("font_color", Color(0.70, 0.35, 0.30))
			unslot_btn.flat = true
			unslot_btn.mouse_filter = Control.MOUSE_FILTER_STOP
			unslot_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			unslot_btn.pressed.connect(func(): _remove_card_from_slot(slot_idx))
			head_h.add_child(unslot_btn)
		vbox.add_child(head_h)
		
		# 2. Khung Tranh Minh Họa Trực Quan (Pixel Art Asset Frame - Kéo Thả Trực Tiếp Vào Hình)
		var img_frame = PanelContainer.new()
		img_frame.custom_minimum_size = Vector2(62, 62)
		img_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		img_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var if_style = StyleBoxFlat.new()
		if_style.bg_color = c_theme["bg"]
		if_style.border_color = c_theme["border"]
		if_style.set_border_width_all(2)
		if_style.set_corner_radius_all(12)
		if_style.shadow_color = Color(0, 0, 0, 0.08)
		if_style.shadow_size = 4
		img_frame.add_theme_stylebox_override("panel", if_style)
		
		var img_data = img_info_list[i] if i < img_info_list.size() else {}
		var asset_path = img_data.get("asset", "")
		if asset_path == "":
			asset_path = "res://assets/sprites/skills/lesson_%02d_step_%d.png" % [current_lesson_id, step_num]
		var tex = _get_texture_safe(asset_path)
		
		if tex:
			var tex_rect = TextureRect.new()
			tex_rect.texture = tex
			tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.custom_minimum_size = Vector2(50, 50)
			tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			tex_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
			img_frame.add_child(tex_rect)
		else:
			var icon_lbl = Label.new()
			icon_lbl.text = img_data.get("icon", "🎯")
			icon_lbl.add_theme_font_size_override("font_size", 24)
			icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			icon_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			img_frame.add_child(icon_lbl)
		vbox.add_child(img_frame)
		
		# 3. Tên Chặng (Caption & Clue)
		var caption_lbl = Label.new()
		var img_title = img_data.get("title", "Chặng %d" % step_num)
		caption_lbl.text = img_title
		caption_lbl.add_theme_font_size_override("font_size", 9)
		caption_lbl.add_theme_color_override("font_color", Color(0.35, 0.25, 0.15))
		caption_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		caption_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(caption_lbl)
		
		# 4. Khay Nhận Thẻ Hành Động (Drop Slot)
		var drop_slot = PanelContainer.new()
		drop_slot.custom_minimum_size = Vector2(0, 36)
		drop_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		drop_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var ds_style = StyleBoxFlat.new()
		ds_style.set_corner_radius_all(8)
		ds_style.content_margin_left = 4
		ds_style.content_margin_right = 4
		ds_style.content_margin_top = 2
		ds_style.content_margin_bottom = 2
		
		if is_matched:
			ds_style.bg_color = Color(0.85, 0.96, 0.88, 1.0)
			ds_style.border_color = Color(0.20, 0.72, 0.40, 1.0)
			ds_style.set_border_width_all(1)
			
			var matched_txt = _get_card_text(matched_card)
			if matched_txt.length() > 14:
				matched_txt = matched_txt.substr(0, 13) + ".."
			var res_lbl = Label.new()
			res_lbl.text = "✔ " + matched_txt
			res_lbl.add_theme_font_size_override("font_size", 8)
			res_lbl.add_theme_color_override("font_color", Color(0.12, 0.50, 0.24))
			res_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			res_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			res_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			drop_slot.add_child(res_lbl)
		else:
			ds_style.bg_color = Color(0.95, 0.93, 0.89, 0.7)
			ds_style.border_color = Color(0.80, 0.74, 0.66, 0.8)
			ds_style.set_border_width_all(1)
			
			var empty_lbl = Label.new()
			empty_lbl.text = "🐾 Thả vào hình"
			empty_lbl.add_theme_font_size_override("font_size", 8)
			empty_lbl.add_theme_color_override("font_color", Color(0.60, 0.52, 0.44))
			empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			empty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			empty_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
			drop_slot.add_child(empty_lbl)
			
		drop_slot.add_theme_stylebox_override("panel", ds_style)
		vbox.add_child(drop_slot)
		
		slot_panel.add_child(vbox)
		slots_container.add_child(slot_panel)

# HÀM TRÍCH XUẤT THÔNG TIN THẺ LINH HOẠT & AN TOÀN TRÁNH BỊ RỖNG DỮ LIỆU
func _get_card_text(card: Dictionary) -> String:
	var t = card.get("text", "")
	if t != "": return t
	var cl = card.get("card_label", "")
	if cl != "": return cl
	var ti = card.get("title", "")
	if ti != "": return ti
	var d = card.get("description", "")
	if d != "": return d
	return "Hành động %d" % card.get("step", 1)

func _get_card_meow(card: Dictionary) -> String:
	var m = card.get("meow", "")
	if m != "": return m
	var cs = card.get("cat_sound", "")
	if cs != "": return cs
	return "Meo meo!"

func _get_card_icon(card: Dictionary) -> String:
	var ic = card.get("icon", "")
	if ic != "": return ic
	var ai = card.get("action_icon", "")
	if ai != "": return ai
	return "🐾"

# =========================================================================
# 2. RENDER KHO TỪ NGỮ HÀNH ĐỘNG (NATIVE DRAGGABLE CARDS POOL)
# =========================================================================
func _render_cards_pool() -> void:
	var scroll_parent = cards_pool_container.get_parent()
	if scroll_parent is ScrollContainer:
		scroll_parent.scroll_vertical = 0
		scroll_parent.scroll_horizontal = 0
		scroll_parent.mouse_filter = Control.MOUSE_FILTER_PASS
		
	for child in cards_pool_container.get_children():
		cards_pool_container.remove_child(child)
		child.queue_free()
		
	for card in shuffled_cards:
		var is_matched = false
		var matched_in_slot = -1
		for slot_k in matched_slots.keys():
			if int(matched_slots[slot_k].get("step")) == int(card.get("step")):
				is_matched = true
				matched_in_slot = int(slot_k) + 1
				break
				
		var card_step = card.get("step", card.get("order", 1))
		var c_theme = STEP_COLORS.get(card_step, STEP_COLORS[1])
		var is_selected_tap = (not selected_word_card.is_empty() and selected_word_card.get("step") == card_step)
		
		# Thẻ hành động Draggable Native Card
		var card_panel = DraggableCardControl.new()
		card_panel.card_data = card
		card_panel.lesson_view = self
		card_panel.is_matched = is_matched
		card_panel.is_selected_tap = is_selected_tap
		card_panel.custom_minimum_size = Vector2(0, 56)
		card_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if not is_matched else Control.CURSOR_ARROW
		
		var c_style = StyleBoxFlat.new()
		c_style.set_corner_radius_all(14)
		c_style.content_margin_left = 12
		c_style.content_margin_right = 12
		c_style.content_margin_top = 6
		c_style.content_margin_bottom = 6
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		
		# Cột 1: Thumbnail Asset Hành Động
		var icon_badge = PanelContainer.new()
		icon_badge.custom_minimum_size = Vector2(40, 40)
		icon_badge.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var ib_style = StyleBoxFlat.new()
		ib_style.bg_color = c_theme["bg"]
		ib_style.border_color = c_theme["border"]
		ib_style.set_border_width_all(2)
		ib_style.set_corner_radius_all(10)
		icon_badge.add_theme_stylebox_override("panel", ib_style)
		
		var card_asset = "res://assets/sprites/skills/lesson_%02d_step_%d.png" % [current_lesson_id, card_step]
		var card_tex = _get_texture_safe(card_asset)
		if card_tex:
			var tex_rect = TextureRect.new()
			tex_rect.texture = card_tex
			tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			tex_rect.custom_minimum_size = Vector2(32, 32)
			tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			tex_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			icon_badge.add_child(tex_rect)
		else:
			var icon_lbl = Label.new()
			icon_lbl.text = _get_card_icon(card)
			icon_lbl.add_theme_font_size_override("font_size", 18)
			icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			icon_badge.add_child(icon_lbl)
		
		# Cột 2: Nội dung từ ngữ hành động kỹ năng sống
		var v_info = VBoxContainer.new()
		v_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v_info.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		v_info.add_theme_constant_override("separation", 2)
		
		var meow_pill = Label.new()
		meow_pill.text = "🐾 [%s]" % _get_card_meow(card)
		meow_pill.add_theme_font_size_override("font_size", 10)
		meow_pill.add_theme_color_override("font_color", c_theme["text"])
		
		var text_lbl = Label.new()
		text_lbl.text = _get_card_text(card)
		text_lbl.add_theme_font_size_override("font_size", 12)
		text_lbl.add_theme_color_override("font_color", Color(0.24, 0.16, 0.10))
		text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		v_info.add_child(meow_pill)
		v_info.add_child(text_lbl)
		
		# Cột 3: Tag Grip kéo thả hiện đại (LOẠI BỎ HOÀN TOÀN NÚT NỐI KHÔNG CHUYÊN NGHIỆP!)
		var badge_pill = PanelContainer.new()
		badge_pill.custom_minimum_size = Vector2(88, 32)
		badge_pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var pill_style = StyleBoxFlat.new()
		pill_style.set_corner_radius_all(12)
		pill_style.content_margin_left = 6
		pill_style.content_margin_right = 6
		
		var pill_lbl = Label.new()
		pill_lbl.add_theme_font_size_override("font_size", 10)
		pill_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		pill_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		if is_matched:
			c_style.bg_color = Color(0.93, 0.91, 0.88, 0.6)
			c_style.border_color = Color(0.80, 0.76, 0.72, 0.5)
			c_style.set_border_width_all(1)
			
			pill_style.bg_color = Color(0.88, 0.95, 0.90, 1.0)
			pill_style.border_color = Color(0.30, 0.75, 0.45, 0.8)
			pill_style.set_border_width_all(1)
			pill_lbl.text = "✔ Chặng %d" % matched_in_slot
			pill_lbl.add_theme_color_override("font_color", Color(0.15, 0.55, 0.28))
		elif is_selected_tap:
			c_style.bg_color = Color(1.0, 0.97, 0.88, 1.0)
			c_style.border_color = Color(0.95, 0.60, 0.15, 1.0)
			c_style.set_border_width_all(2)
			c_style.shadow_color = Color(0.95, 0.60, 0.15, 0.25)
			c_style.shadow_size = 6
			
			pill_style.bg_color = Color(0.95, 0.60, 0.15, 1.0)
			pill_style.border_color = Color(0.80, 0.45, 0.10, 1.0)
			pill_lbl.text = "Chạm Chặng"
			pill_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
		else:
			c_style.bg_color = Color(1.0, 0.99, 0.97, 1.0)
			c_style.border_color = Color(0.88, 0.80, 0.70, 1.0)
			c_style.set_border_width_all(1)
			c_style.border_width_bottom = 2
			c_style.shadow_color = Color(0.2, 0.15, 0.1, 0.06)
			c_style.shadow_size = 4
			c_style.shadow_offset = Vector2(0, 2)
			
			pill_style.bg_color = Color(0.96, 0.93, 0.88, 1.0)
			pill_style.border_color = Color(0.85, 0.75, 0.65, 1.0)
			pill_style.set_border_width_all(1)
			pill_lbl.text = "⠿ Kéo thả"
			pill_lbl.add_theme_color_override("font_color", Color(0.50, 0.38, 0.25))
			
		badge_pill.add_theme_stylebox_override("panel", pill_style)
		badge_pill.add_child(pill_lbl)
		
		card_panel.add_theme_stylebox_override("panel", c_style)
		hbox.add_child(icon_badge)
		hbox.add_child(v_info)
		hbox.add_child(badge_pill)
		card_panel.add_child(hbox)
		cards_pool_container.add_child(card_panel)

# =========================================================================
# 3. TẠO DRAG PREVIEW NATIVE GIAO DIỆN XINH XẮN THEO CHUỘT
# =========================================================================
func _create_drag_preview_for_card(card: Dictionary) -> Control:
	var preview = PanelContainer.new()
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.z_index = 100
	preview.custom_minimum_size = Vector2(190, 52)
	
	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color(1.0, 0.985, 0.94, 0.95)
	p_style.border_color = Color(0.96, 0.60, 0.18, 1.0)
	p_style.set_border_width_all(2)
	p_style.set_corner_radius_all(14)
	p_style.shadow_color = Color(0.2, 0.1, 0.05, 0.30)
	p_style.shadow_size = 10
	p_style.shadow_offset = Vector2(0, 4)
	p_style.content_margin_left = 10
	p_style.content_margin_right = 10
	preview.add_theme_stylebox_override("panel", p_style)
	
	var h = HBoxContainer.new()
	h.alignment = BoxContainer.ALIGNMENT_CENTER
	h.add_theme_constant_override("separation", 8)
	
	var card_step = card.get("order", card.get("step", 1))
	var card_asset = "res://assets/sprites/skills/lesson_%02d_step_%d.png" % [current_lesson_id, card_step]
	var card_tex = _get_texture_safe(card_asset)
	if card_tex:
		var tr = TextureRect.new()
		tr.texture = card_tex
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.custom_minimum_size = Vector2(30, 30)
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		h.add_child(tr)
	else:
		var icon_l = Label.new()
		icon_l.text = _get_card_icon(card)
		icon_l.add_theme_font_size_override("font_size", 18)
		h.add_child(icon_l)
		
	var v = VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	var meow_l = Label.new()
	meow_l.text = "🐾 " + _get_card_meow(card)
	meow_l.add_theme_font_size_override("font_size", 10)
	meow_l.add_theme_color_override("font_color", Color(0.85, 0.40, 0.10))
	v.add_child(meow_l)
	
	var title_l = Label.new()
	var short_txt = _get_card_text(card)
	if short_txt.length() > 18: short_txt = short_txt.substr(0, 17) + ".."
	title_l.text = short_txt
	title_l.add_theme_font_size_override("font_size", 11)
	title_l.add_theme_color_override("font_color", Color(0.24, 0.16, 0.10))
	v.add_child(title_l)
	
	h.add_child(v)
	preview.add_child(h)
	preview.position = -Vector2(95, 26)
	return preview

# =========================================================================
# 4. CƠ CHẾ NỐI VÀ KIỂM TRA ĐÚNG/SAI (MATCHING ENGINE)
# =========================================================================
func _on_card_tap_selected(card: Dictionary) -> void:
	SoundManager.play_click()
	if not selected_word_card.is_empty() and selected_word_card.get("step") == card.get("step"):
		selected_word_card.clear()
		cat_bubble.text = "Meo meo! Đã bỏ chọn thẻ. Sen hãy chạm hoặc kéo thả thẻ khác nhé!"
	else:
		selected_word_card = card
		var meow_str = _get_card_meow(card)
		var text_str = _get_card_text(card)
		cat_bubble.text = "🐾 [%s - %s] đang chọn! Bây giờ chạm vào ô hình ảnh tương ứng nhé Sen!" % [meow_str, text_str]
	_render_cards_pool()

func _attempt_match_card_to_slot(card: Dictionary, target_slot_idx: int) -> bool:
	selected_word_card.clear()
	var expected_step: int = int(target_slot_idx) + 1
	var card_step: int = int(card.get("step", -1))
	
	if card_step == expected_step:
		# GHÉP ĐÚNG HOÀN TOÀN
		matched_slots[int(target_slot_idx)] = card
		_rebuild_selected_sequence()
		combo_count += 1
		SoundManager.play_success()
		SoundManager.play_purr()
		
		var img_info_list = LESSON_IMAGE_DATA.get(current_lesson_id, [])
		var img_title = img_info_list[target_slot_idx]["title"] if target_slot_idx < img_info_list.size() else ("Chặng %d" % expected_step)
		
		if matched_slots.size() >= lesson_data.get("cards", []).size():
			var stars_str = "⭐⭐⭐" if mistakes_count == 0 else ("⭐⭐" if mistakes_count <= 2 else "⭐")
			cat_bubble.text = "Meooo~! Tuyệt cú mèo! Sen đã hoàn thành xuất sắc 4/4 chặng! (%s) 🎉" % stars_str
		elif combo_count >= 2:
			cat_bubble.text = "🔥 COMBO x%d! Meooo~! Quá chuẩn xác! Ghép đúng Chặng %d: '%s' rồi nè! 🐾" % [combo_count, expected_step, img_title]
		else:
			cat_bubble.text = "Meooo~! Tuyệt vời! Sen đã ghép đúng Chặng %d: '%s' rồi nè! 🐾" % [expected_step, img_title]
			
		_render_slots()
		_spawn_match_sparkles(target_slot_idx)
		_render_cards_pool()
		_update_submit_button()
		return true
	else:
		# GHÉP SAI HÌNH
		mistakes_count += 1
		combo_count = 0
		SoundManager.play_fail()
		
		var img_info_list = LESSON_IMAGE_DATA.get(current_lesson_id, [])
		var target_title = img_info_list[target_slot_idx]["title"] if target_slot_idx < img_info_list.size() else ("Chặng %d" % expected_step)
		var err_hint = card.get("error_hint", "")
		if err_hint != "":
			cat_bubble.text = "Ngoao.. Chặng %d là [%s]! %s Thử lại nhé! 🐾" % [expected_step, target_title, err_hint]
		else:
			cat_bubble.text = "Ngoao.. Sen ơi chặng này là [%s] chứ không phải hành động này rồi! Thử lại nha! 🐾" % target_title
		
		_render_slots()
		_shake_slot(target_slot_idx)
		_render_cards_pool()
		_update_submit_button()
		return false

func _remove_card_from_slot(slot_idx: int) -> void:
	var idx = int(slot_idx)
	if matched_slots.has(idx):
		SoundManager.play_card_cancel()
		matched_slots.erase(idx)
		_rebuild_selected_sequence()
		cat_bubble.text = "Meo meo! Đã gỡ thẻ ra khỏi Chặng %d. Kéo thẻ khác vào nhé Sen!" % (idx + 1)
		_render_slots()
		_render_cards_pool()
		_update_submit_button()

func _rebuild_selected_sequence() -> void:
	selected_sequence.clear()
	var total_steps: int = int(lesson_data.get("cards", []).size())
	for i in range(total_steps):
		if matched_slots.has(i):
			selected_sequence.append(matched_slots[i])

# Hỗ trợ tương thích 100% với QA test gọi _pick_card
func _pick_card(card: Dictionary) -> void:
	var step_idx: int = int(card.get("step", 1)) - 1
	matched_slots[step_idx] = card
	_rebuild_selected_sequence()
	SoundManager.play_card_pop()
	cat_bubble.text = "🐾 \"%s\" ➔ Đã ghép vào Chặng %d!" % [_get_card_meow(card), step_idx + 1]
	_render_slots()
	_render_cards_pool()
	_update_submit_button()

# =========================================================================
# 5. HIỆU ỨNG TƯƠNG TÁC (ANIMATION & POLISH)
# =========================================================================
func _shake_slot(slot_idx: int) -> void:
	var children = slots_container.get_children()
	if slot_idx < children.size():
		var node = children[slot_idx]
		var orig_x = node.position.x
		var tw = create_tween()
		tw.tween_property(node, "position:x", orig_x - 6.0, 0.05)
		tw.tween_property(node, "position:x", orig_x + 6.0, 0.05)
		tw.tween_property(node, "position:x", orig_x - 3.0, 0.04)
		tw.tween_property(node, "position:x", orig_x, 0.04)

func _spawn_match_sparkles(slot_idx: int) -> void:
	var children = slots_container.get_children()
	if slot_idx < children.size():
		var node = children[slot_idx]
		var tw = create_tween()
		tw.tween_property(node, "scale", Vector2(1.08, 1.08), 0.12).set_trans(Tween.TRANS_BACK)
		tw.tween_property(node, "scale", Vector2(1.0, 1.0), 0.12)

func _update_submit_button() -> void:
	var total_needed = lesson_data.get("cards", []).size()
	var is_ready = (matched_slots.size() >= total_needed)
	btn_submit.disabled = not is_ready
	
	var s = StyleBoxFlat.new()
	s.set_corner_radius_all(14)
	s.set_border_width_all(2)
	s.border_width_bottom = 3
	s.content_margin_left = 16
	s.content_margin_right = 16
	
	var stars_str = "⭐⭐⭐" if mistakes_count == 0 else ("⭐⭐" if mistakes_count <= 2 else "⭐")
	
	if is_ready:
		s.bg_color = Color(0.20, 0.72, 0.40, 1.0)
		s.border_color = Color(0.12, 0.50, 0.25, 1.0)
		s.shadow_color = Color(0.20, 0.72, 0.40, 0.35)
		s.shadow_size = 6
		s.shadow_offset = Vector2(0, 2)
		btn_submit.text = "🎬 HOÀN THÀNH • CHẠY MÔ PHỎNG NGAY! %s" % stars_str
		btn_submit.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		btn_submit.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 1))
	else:
		s.bg_color = Color(0.92, 0.89, 0.84, 1.0)
		s.border_color = Color(0.80, 0.74, 0.66, 1.0)
		btn_submit.text = "🐾 Còn thiếu (%d/%d chặng) • %s" % [matched_slots.size(), total_needed, stars_str]
		var disabled_txt = Color(0.38, 0.28, 0.20, 1.0)
		btn_submit.add_theme_color_override("font_color", disabled_txt)
		btn_submit.add_theme_color_override("font_disabled_color", disabled_txt)
		
	btn_submit.add_theme_stylebox_override("normal", s)
	btn_submit.add_theme_stylebox_override("hover", s)
	btn_submit.add_theme_stylebox_override("disabled", s)

func _on_guide_pressed() -> void:
	SoundManager.play_click()
	emit_signal("open_handbook_requested")
	guide_modal.visible = true

func _on_submit_pressed() -> void:
	SoundManager.play_click()
	
	var expected_steps = lesson_data.get("cards", []).size()
	var is_correct = true
	
	if selected_sequence.size() < expected_steps:
		is_correct = false
	else:
		for i in range(selected_sequence.size()):
			if selected_sequence[i]["step"] != i + 1:
				is_correct = false
				break
				
	if is_correct:
		SoundManager.play_success()
		cat_bubble.text = "Meooo~! Tuyệt cú mèo! Sen dạy Boss chuẩn không cần chỉnh! 🐾"
		GameManager.complete_lesson(current_lesson_id)
	else:
		SoundManager.play_fail()
		var first_wrong = selected_sequence[0] if selected_sequence.size() > 0 else {}
		cat_bubble.text = "Ngoao.. Sen ơi, nhầm bước rồi nè! " + first_wrong.get("error_hint", "Xem lại sổ tay bỏ túi nha!")
		
	emit_signal("run_simulation_requested", current_lesson_id, selected_sequence, is_correct)

# Hàm nạp texture an toàn hỗ trợ cả runtime Image fallback
func _get_texture_safe(path: String) -> Texture2D:
	if path == "":
		return null
	if ResourceLoader.exists(path):
		return load(path)
	if FileAccess.file_exists(path):
		var img = Image.new()
		if img.load(path) == OK:
			return ImageTexture.create_from_image(img)
	return null
