extends Control

# CheckInRushGame.gd - Minigame "Check-in Thần Tốc" cho Best Sen
# Mô phỏng cổng soát vé Metro & Cửa trước xe buýt TP.HCM
# Góc nhìn 2.5D cận cảnh bàn soát vé / Cổng barrier AFC
# Hỗ trợ Viewport Mobile Responsive (390x844 & 540x960 9:16)

signal minigame_completed(sim_steps)
signal back_requested

# =========================================================================
# ENUM CÁC DẠNG HÀNH KHÁCH
# =========================================================================
enum PassengerType {
	RFID_CARD = 0,    # Thẻ cứng CCCD gắn chip / Thẻ Sinh Viên
	QR_APP = 1,       # Vé App số HURC Pass / MoMo (50% bị tối màn hình)
	BUS_CASH = 2,     # Trả tiền mặt vé xe bus 5.000đ (thối 20k hoặc 50k)
	BUS_WAVE_QTE = 3  # Mèo con vẫy đón xe buýt 08 từ xa (Quick Time Event)
}

# =========================================================================
# KHAI BÁO NODES
# =========================================================================
@onready var clock_label: Label = $Header/HBox/TimerBox/VBox/ClockLabel
@onready var time_bar: ProgressBar = $Header/HBox/TimerBox/VBox/TimeBar
@onready var count_label: Label = $Header/HBox/TargetBox/VBox/CountLabel
@onready var combo_badge: Label = $Header/HBox/ComboBadge
@onready var jam_badge: Label = $Header/HBox/JamBadge
@onready var btn_back: Button = $Header/HBox/BtnBack

# Khu vực quầy soát vé & Cổng Barrier
@onready var station_canvas: Control = $MainArea/StationCanvas
@onready var barrier_led_rect: ColorRect = $MainArea/BarrierSection/GateFrame/LedLight
@onready var barrier_lcd_label: Label = $MainArea/BarrierSection/GateFrame/LcdScreen/LcdLabel
@onready var barrier_arm_left: ColorRect = $MainArea/BarrierSection/GateFrame/ArmLeft
@onready var barrier_arm_right: ColorRect = $MainArea/BarrierSection/GateFrame/ArmRight

# Khách hàng & Hàng đợi
@onready var passenger_name_lbl: Label = $MainArea/PassengerSection/NameLabel
@onready var passenger_type_badge: Label = $MainArea/PassengerSection/TypeBadge
@onready var passenger_speech_lbl: Label = $MainArea/PassengerSection/Bubble/SpeechLabel
@onready var patience_bar: ProgressBar = $MainArea/PassengerSection/PatienceBar
@onready var cat_sprite_anchor: Control = $MainArea/PassengerSection/CatAnchor

# Các khu vực tương tác chuyên biệt (Interaction Widgets)
@onready var card_widget: PanelContainer = $Toolbox/CardWidget
@onready var btn_swipe_rfid: Button = $Toolbox/CardWidget/VBox/BtnSwipeRFID
@onready var btn_swipe_qr_wrong: Button = $Toolbox/CardWidget/VBox/BtnSwipeWrongQR

@onready var phone_widget: PanelContainer = $Toolbox/PhoneWidget
@onready var phone_brightness_slider: HSlider = $Toolbox/PhoneWidget/VBox/BrightnessSlider
@onready var phone_screen_rect: ColorRect = $Toolbox/PhoneWidget/VBox/PhoneBezel/Screen
@onready var phone_qr_lbl: Label = $Toolbox/PhoneWidget/VBox/PhoneBezel/Screen/QrCodeLabel
@onready var btn_scan_qr: Button = $Toolbox/PhoneWidget/VBox/BtnScanQR
@onready var btn_scan_rfid_wrong: Button = $Toolbox/PhoneWidget/VBox/BtnScanWrongRFID

@onready var cash_widget: PanelContainer = $Toolbox/CashWidget
@onready var cash_req_label: Label = $Toolbox/CashWidget/VBox/ReqLabel
@onready var cash_selected_label: Label = $Toolbox/CashWidget/VBox/SelectedLabel
@onready var btn_cash_10k: Button = $Toolbox/CashWidget/VBox/Grid/Btn10k
@onready var btn_cash_5k: Button = $Toolbox/CashWidget/VBox/Grid/Btn5k
@onready var btn_cash_2k: Button = $Toolbox/CashWidget/VBox/Grid/Btn2k
@onready var btn_cash_1k: Button = $Toolbox/CashWidget/VBox/Grid/Btn1k
@onready var btn_cash_clear: Button = $Toolbox/CashWidget/VBox/Actions/BtnClear
@onready var btn_cash_confirm: Button = $Toolbox/CashWidget/VBox/Actions/BtnConfirm

@onready var wave_widget: PanelContainer = $Toolbox/WaveWidget
@onready var wave_track: Control = $Toolbox/WaveWidget/VBox/RoadTrack
@onready var bus_sprite_label: Label = $Toolbox/WaveWidget/VBox/RoadTrack/BusLabel
@onready var yellow_stop_line: ColorRect = $Toolbox/WaveWidget/VBox/RoadTrack/YellowLine
@onready var sweet_spot_zone: ColorRect = $Toolbox/WaveWidget/VBox/RoadTrack/SweetSpot
@onready var btn_wave_hand: Button = $Toolbox/WaveWidget/VBox/BtnWaveHand

# Toast & Modals
@onready var toast_panel: PanelContainer = $ToastPanel
@onready var toast_label: Label = $ToastPanel/ToastLabel
@onready var toast_timer: Timer = $ToastTimer

@onready var victory_modal: Control = $VictoryModal
@onready var victory_text: Label = $VictoryModal/ModalPanel/VBox/Scroll/VictoryLabel
@onready var btn_claim_victory: Button = $VictoryModal/ModalPanel/VBox/BtnClaimVictory

@onready var defeat_modal: Control = $DefeatModal
@onready var defeat_text: Label = $DefeatModal/ModalPanel/VBox/Scroll/DefeatLabel
@onready var btn_retry: Button = $DefeatModal/ModalPanel/VBox/BtnRetry

# =========================================================================
# THÔNG SỐ VÀ TRẠNG THÁI GAMEPLAY
# =========================================================================
var total_time: float = 60.0
var time_left: float = 60.0
var is_game_active: bool = true

var target_passengers_to_win: int = 8
var processed_passengers: int = 0
var failed_passengers: int = 0 # Gate jam: 3 khách hỏng = Thua
var max_failed_allowed: int = 3

var combo_streak: int = 0
var is_fever_mode: bool = false
var fever_timer: float = 0.0

# Hàng đợi khách
var passenger_queue: Array[Dictionary] = []
var current_passenger: Dictionary = {}
var passenger_patience: float = 6.0
var current_patience_max: float = 6.0

# Trạng thái từng loại widget
var selected_change_cash: int = 0
var phone_brightness: float = 1.0 # 0.0 to 1.0
var is_phone_dimmed: bool = false

# Trạng thái Xe Buýt 08 QTE
var bus_pos_x: float = -60.0
var bus_speed: float = 240.0
var is_bus_driving: bool = false
var bus_stop_x: float = 230.0 # Vị trí vạch vàng dừng xe

# Visual Mascot Cat
var current_cat_anim: AnimatedSprite2D = null

# Cổng barrier tween
var is_barrier_open: bool = false
var barrier_open_timer: float = 0.0

# Chuyển cảnh giữa các hành khách
var is_passenger_transitioning: bool = false
var transition_timer: float = 0.0

func _ready() -> void:
	# Kết nối buttons
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(func():
		SoundManager.play_click()
		back_requested.emit()
	)
	
	btn_swipe_rfid.pressed.connect(_on_swipe_rfid_pressed)
	btn_swipe_qr_wrong.pressed.connect(_on_swipe_wrong_qr_pressed)
	
	btn_scan_qr.pressed.connect(_on_scan_qr_pressed)
	btn_scan_rfid_wrong.pressed.connect(_on_scan_wrong_rfid_pressed)
	phone_brightness_slider.value_changed.connect(_on_brightness_changed)
	
	btn_cash_10k.pressed.connect(func(): _add_cash(10000))
	btn_cash_5k.pressed.connect(func(): _add_cash(5000))
	btn_cash_2k.pressed.connect(func(): _add_cash(2000))
	btn_cash_1k.pressed.connect(func(): _add_cash(1000))
	btn_cash_clear.pressed.connect(_clear_cash)
	btn_cash_confirm.pressed.connect(_confirm_cash_change)
	
	btn_wave_hand.pressed.connect(_on_wave_hand_pressed)
	
	btn_claim_victory.pressed.connect(_on_claim_victory_pressed)
	btn_retry.pressed.connect(func():
		SoundManager.play_click()
		reset_game()
	)
	
	toast_timer.timeout.connect(func(): toast_panel.visible = false)
	toast_panel.visible = false
	victory_modal.visible = false
	defeat_modal.visible = false
	
	reset_game()

func load_minigame(_game_data: Dictionary) -> void:
	reset_game()

func reset_game() -> void:
	is_game_active = true
	time_left = total_time
	processed_passengers = 0
	failed_passengers = 0
	combo_streak = 0
	is_fever_mode = false
	fever_timer = 0.0
	
	is_barrier_open = false
	barrier_open_timer = 0.0
	_set_barrier_visual(false, "SẴN SÀNG QUÉT VÉ")
	
	toast_panel.visible = false
	victory_modal.visible = false
	defeat_modal.visible = false
	
	_generate_passenger_queue()
	_load_next_passenger()
	_update_header_ui()

# =========================================================================
# KHỞI TẠO HÀNG ĐỢI HÀNH KHÁCH ĐA DẠNG
# =========================================================================
func _generate_passenger_queue() -> void:
	passenger_queue.clear()
	
	# Tạo danh sách khách mẫu luân phiên cả 4 loại thử thách
	var templates = [
		{
			"name": "Mèo Tuxedo SV",
			"breed_id": 4,
			"type": PassengerType.RFID_CARD,
			"dialogue": "Cho mình quẹt thẻ sinh viên Metro Tuyến 1 nhé Sen!",
			"badge": "💳 Thẻ Cứng RFID"
		},
		{
			"name": "Mèo Tam Thể Xóm Trọ",
			"breed_id": 2,
			"type": PassengerType.QR_APP,
			"dialogue": "Mình dùng app MoMo/HURC Pass quét mã QR nha!",
			"badge": "📱 Vé Điện Tử QR",
			"force_dim": true
		},
		{
			"name": "Mèo Vàng Háu Ăn",
			"breed_id": 1,
			"type": PassengerType.BUS_CASH,
			"dialogue": "Vé bus 5.000đ, mình đưa tờ 20.000đ nè!",
			"cash_given": 20000,
			"fare": 5000,
			"change": 15000,
			"badge": "💵 Tiền Mặt (20k)"
		},
		{
			"name": "Mèo Mướp Cam Vẫy Xe",
			"breed_id": 0,
			"type": PassengerType.BUS_WAVE_QTE,
			"dialogue": "Xe buýt 08 đang lao tới kìa! Bấm ✋ vẫy xe giúp mình!",
			"badge": "🚌 Vẫy Xe Buýt 08"
		},
		{
			"name": "Mèo Mochi Nơ Hồng",
			"breed_id": 8,
			"type": PassengerType.QR_APP,
			"dialogue": "Màn hình mình hơi tối, Sen kéo sáng giùm nhé!",
			"badge": "📱 Vé Điện Tử QR",
			"force_dim": true
		},
		{
			"name": "Mèo Pochi Đốm Vàng",
			"breed_id": 9,
			"type": PassengerType.RFID_CARD,
			"dialogue": "CCCD gắn chip của mình tích hợp vé tháng rồi!",
			"badge": "💳 Thẻ Cứng RFID"
		},
		{
			"name": "Mèo Xám Cẩn Thận",
			"breed_id": 3,
			"type": PassengerType.BUS_CASH,
			"dialogue": "Sáng nay hết tiền lẻ, mình gửi tờ 50.000đ vé 5k nha!",
			"cash_given": 50000,
			"fare": 5000,
			"change": 45000,
			"badge": "💵 Tiền Mặt (50k)"
		},
		{
			"name": "Mèo Đen Ninja Siêu Tốc",
			"breed_id": 6,
			"type": PassengerType.BUS_WAVE_QTE,
			"dialogue": "Tuyến 08 sắp vụt qua trạm! Canh chuẩn vạch vàng nhé!",
			"badge": "🚌 Vẫy Xe Buýt 08"
		},
		{
			"name": "Mèo Tuyết Trắng",
			"breed_id": 5,
			"type": PassengerType.RFID_CARD,
			"dialogue": "Thẻ thư viện kiêm vé bus của mình đây ạ!",
			"badge": "💳 Thẻ Cứng RFID"
		},
		{
			"name": "Mèo Xiêm Khởi Nghiệp",
			"breed_id": 7,
			"type": PassengerType.BUS_CASH,
			"dialogue": "Thối giùm mình 15.000đ tiền thừa nha Sen!",
			"cash_given": 20000,
			"fare": 5000,
			"change": 15000,
			"badge": "💵 Tiền Mặt (20k)"
		}
	]
	
	for t in templates:
		passenger_queue.append(t.duplicate(true))

# =========================================================================
# NẠP HÀNH KHÁCH TIẾP THEO
# =========================================================================
func _load_next_passenger() -> void:
	if passenger_queue.is_empty():
		_generate_passenger_queue()
		
	current_passenger = passenger_queue.pop_front()
	current_patience_max = 6.0
	passenger_patience = current_patience_max
	
	passenger_name_lbl.text = current_passenger.get("name", "Hành khách Mèo")
	passenger_type_badge.text = current_passenger.get("badge", "Vé Soát")
	passenger_speech_lbl.text = current_passenger.get("dialogue", "Sen ơi xử lý vé giùm mình!")
	
	_setup_cat_visual(current_passenger.get("breed_id", 0))
	_switch_toolbox(current_passenger.get("type", PassengerType.RFID_CARD))
	
	_set_barrier_visual(false, "VUI LÒNG CHECK-IN")

func _setup_cat_visual(breed_id: int) -> void:
	if current_cat_anim == null and cat_sprite_anchor:
		current_cat_anim = AnimatedSprite2D.new()
		current_cat_anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		current_cat_anim.position = Vector2(40, 40)
		current_cat_anim.scale = Vector2(2.5, 2.5)
		cat_sprite_anchor.add_child(current_cat_anim)
		
	if current_cat_anim:
		current_cat_anim.sprite_frames = CatAnimationFactory.get_sprite_frames(breed_id)
		current_cat_anim.play("idle")

func _switch_toolbox(p_type: int) -> void:
	card_widget.visible = (p_type == PassengerType.RFID_CARD)
	phone_widget.visible = (p_type == PassengerType.QR_APP)
	cash_widget.visible = (p_type == PassengerType.BUS_CASH)
	wave_widget.visible = (p_type == PassengerType.BUS_WAVE_QTE)
	
	match p_type:
		PassengerType.RFID_CARD:
			pass
		PassengerType.QR_APP:
			# 50% tỉ lệ khách bị tối màn hình
			var should_dim = current_passenger.get("force_dim", randf() < 0.5)
			if should_dim:
				phone_brightness = 0.22 # Tối thui
				is_phone_dimmed = true
			else:
				phone_brightness = 0.90 # Sáng rõ
				is_phone_dimmed = false
			phone_brightness_slider.value = phone_brightness * 100.0
			_update_phone_visual()
			
		PassengerType.BUS_CASH:
			selected_change_cash = 0
			var c_given = current_passenger.get("cash_given", 20000)
			var c_fare = current_passenger.get("fare", 5000)
			var c_need = current_passenger.get("change", 15000)
			cash_req_label.text = "Khách đưa: %sđ | Vé: %sđ ➔ Cần thối: %sđ" % [
				_format_money(c_given), _format_money(c_fare), _format_money(c_need)
			]
			_update_cash_ui()
			
		PassengerType.BUS_WAVE_QTE:
			bus_pos_x = -70.0
			is_bus_driving = true
			btn_wave_hand.disabled = false
			bus_sprite_label.position.x = bus_pos_x

# =========================================================================
# VÒNG LẶP CHÍNH _PROCESS (TIME & STATE)
# =========================================================================
func _process(delta: float) -> void:
	if not is_game_active:
		return
		
	# Đếm ngược tổng thời gian chơi (60s)
	time_left = maxf(0.0, time_left - delta)
	if time_left <= 0.0:
		_trigger_defeat("Hết 60 giây mà chưa hoàn thành mục tiêu 8 hành khách!")
		return
		
	# Xử lý chuyển tiếp hành khách
	if is_passenger_transitioning:
		transition_timer -= delta
		if transition_timer <= 0.0:
			is_passenger_transitioning = false
			if processed_passengers < target_passengers_to_win and failed_passengers < max_failed_allowed:
				_load_next_passenger()
	else:
		# Đếm ngược sự kiên nhẫn của khách hiện tại (6s)
		passenger_patience -= delta
		patience_bar.value = (passenger_patience / current_patience_max) * 100.0
		
		if passenger_patience <= 2.0:
			patience_bar.modulate = Color(1.0, 0.3, 0.2) # Nhấp nháy đỏ
		else:
			patience_bar.modulate = Color(0.2, 0.8, 0.4) # Xanh bình thường
			
		if passenger_patience <= 0.0:
			_on_passenger_impatient_lost()
		
	# Xử lý xe buýt chạy cho loại 4
	if wave_widget.visible and is_bus_driving:
		bus_pos_x += bus_speed * delta
		bus_sprite_label.position.x = bus_pos_x
		if bus_pos_x > 380.0:
			# Xe đã chạy vụt qua mất
			_on_wave_missed()
			
	# Xử lý đóng lại barrier
	if is_barrier_open:
		barrier_open_timer -= delta
		if barrier_open_timer <= 0.0:
			is_barrier_open = false
			_set_barrier_visual(false, "VUI LÒNG CHECK-IN")
			
	# Fever Mode Timer
	if is_fever_mode:
		fever_timer -= delta
		if fever_timer <= 0.0:
			is_fever_mode = false
			
	_update_header_ui()

# =========================================================================
# XỬ LÝ LOẠI 1: THẺ CỨNG (RFID CARD)
# =========================================================================
func _on_swipe_rfid_pressed() -> void:
	if not is_game_active: return
	
	if current_passenger.get("type") == PassengerType.RFID_CARD:
		SoundManager.play_card_pop()
		SoundManager.vibrate(30)
		_set_barrier_visual(true, "CCCD: HỢP LỆ! - 0 VNĐ")
		trigger_toast("✅ Quẹt RFID chuẩn xác! Mời khách bước qua!", false)
		_complete_current_passenger()
	else:
		_penalize_mistake("Sai thao tác quét RFID cho loại khách này!", 1.5)

func _on_swipe_wrong_qr_pressed() -> void:
	# Kéo nhầm thẻ cứng vào máy quét QR quang học
	SoundManager.play_fail()
	SoundManager.vibrate(60)
	_set_barrier_visual(false, "LỖI: SAI ĐẦU ĐỌC! (DÙNG RFID)")
	_penalize_mistake("⚠️ Nhầm đầu đọc! Thẻ cứng phải quẹt vào Đầu đọc RFID!", 2.0)

# =========================================================================
# XỬ LÝ LOẠI 2: MÃ QR TRÊN APP (QR APP SCANNER)
# =========================================================================
func _on_brightness_changed(val: float) -> void:
	phone_brightness = val / 100.0
	_update_phone_visual()

func _update_phone_visual() -> void:
	phone_screen_rect.color = Color(phone_brightness, phone_brightness, phone_brightness, 1.0)
	if phone_brightness < 0.70:
		phone_qr_lbl.modulate = Color(0.2, 0.2, 0.2, 0.3)
		phone_qr_lbl.text = "🔳 (QR MỜ CĂM)"
	else:
		phone_qr_lbl.modulate = Color(0.0, 0.0, 0.0, 1.0)
		phone_qr_lbl.text = "📱 [MÃ QR SẴN SÀNG]"

func _on_scan_qr_pressed() -> void:
	if not is_game_active: return
	
	if current_passenger.get("type") != PassengerType.QR_APP:
		_penalize_mistake("Khách này không dùng mã QR!", 1.5)
		return
		
	if phone_brightness < 0.70:
		SoundManager.play_fail()
		SoundManager.vibrate(50)
		_set_barrier_visual(false, "LỖI: MÀN HÌNH TỐI, KHÔNG ĐỌC ĐƯỢC QR!")
		trigger_toast("⚠️ Màn hình quá tối (<70%)! Kéo thanh trượt để tăng sáng màn hình!", true)
		passenger_patience = maxf(0.5, passenger_patience - 1.5)
		return
		
	# Đủ sáng và quét đúng máy QR
	SoundManager.play_success()
	SoundManager.vibrate(40)
	_set_barrier_visual(true, "HURC PASS: ĐÃ QUÉT QR TING TING!")
	trigger_toast("✨ Quét QR thành công! Cổng barrier mở!", false)
	_complete_current_passenger()

func _on_scan_wrong_rfid_pressed() -> void:
	# Đưa điện thoại vào máy RFID
	SoundManager.play_fail()
	SoundManager.vibrate(60)
	_set_barrier_visual(false, "LỖI: MÁY RFID KHÔNG ĐỌC ĐƯỢC QR!")
	_penalize_mistake("⚠️ Điện thoại có mã QR phải đưa vào Máy Quét Quang Học QR!", 2.0)

# =========================================================================
# XỬ LÝ LOẠI 3: TIỀN MẶT XE BUÝT (BUS CASH)
# =========================================================================
func _add_cash(amount: int) -> void:
	SoundManager.play_card_pop()
	selected_change_cash += amount
	_update_cash_ui()

func _clear_cash() -> void:
	SoundManager.play_card_cancel()
	selected_change_cash = 0
	_update_cash_ui()

func _update_cash_ui() -> void:
	cash_selected_label.text = "Đã chọn thối: %s VNĐ" % _format_money(selected_change_cash)
	var need = current_passenger.get("change", 15000)
	if selected_change_cash == need:
		cash_selected_label.add_theme_color_override("font_color", Color(0.15, 0.7, 0.25))
	elif selected_change_cash > need:
		cash_selected_label.add_theme_color_override("font_color", Color(0.9, 0.25, 0.2))
	else:
		cash_selected_label.add_theme_color_override("font_color", Color(0.3, 0.2, 0.1))

func _confirm_cash_change() -> void:
	if not is_game_active: return
	if current_passenger.get("type") != PassengerType.BUS_CASH: return
	
	var need = current_passenger.get("change", 15000)
	if selected_change_cash == need:
		SoundManager.play_success()
		SoundManager.vibrate(35)
		_set_barrier_visual(true, "TIỀN MẶT: ĐÃ THỐI ĐỦ %sĐ" % _format_money(need))
		trigger_toast("💵 Thối tiền chuẩn xác! Khách vui vẻ bước lên xe!", false)
		_complete_current_passenger()
	else:
		SoundManager.play_fail()
		SoundManager.vibrate(70)
		_set_barrier_visual(false, "LỖI: THỐI SAI TIỀN THỪA!")
		_penalize_mistake("Bác tài càu nhàu: 'Thối nhầm rồi Sen ơi!' (Cần %sđ, Sen chọn %sđ)" % [
			_format_money(need), _format_money(selected_change_cash)
		], 1.5)
		selected_change_cash = 0
		_update_cash_ui()

# =========================================================================
# XỬ LÝ LOẠI 4: VẪY XE BUÝT 08 TỪ XA (BUS WAVE QTE)
# =========================================================================
func _on_wave_hand_pressed() -> void:
	if not is_game_active or is_passenger_transitioning: return
	if not is_bus_driving: return
	
	# Vạch vàng dừng xe tại bus_stop_x = 230.0
	# Sweet spot: khoảng cách đầu xe cách vạch vàng 30px đến 65px (tức là x từ 165 đến 200)
	var dist_to_line = bus_stop_x - bus_sprite_label.position.x
	
	if dist_to_line >= 25.0 and dist_to_line <= 75.0:
		# BẤM TRÚNG SWEET SPOT!
		is_bus_driving = false
		btn_wave_hand.disabled = true
		SoundManager.play_success()
		SoundManager.vibrate(40)
		_set_barrier_visual(true, "XE BUÝT 08: PHANH KÍTTT DỪNG ĐÓN!")
		trigger_toast("✋ Vẫy tay dứt khoát! Xe buýt 08 đã dừng đón Mèo con!", false)
		_complete_current_passenger()
	elif dist_to_line > 75.0:
		# Vẫy quá sớm
		SoundManager.play_fail()
		_penalize_mistake("Vẫy xe quá sớm! Xe buýt còn ở xa chưa nhìn thấy!", 1.2)
	else:
		# Vẫy quá muộn (sát vạch hoặc quá vạch)
		SoundManager.play_fail()
		_penalize_mistake("Vẫy xe quá trễ! Xe buýt không kịp phanh!", 1.5)

func _on_wave_missed() -> void:
	is_bus_driving = false
	btn_wave_hand.disabled = true
	SoundManager.play_fail()
	SoundManager.vibrate(80)
	_set_barrier_visual(false, "XE BUÝT 08: ĐÃ VỤT QUA MẤT!")
	trigger_toast("💨 Xe buýt 08 lao qua mất kèm khói bụi mù mịt!", true)
	_on_passenger_impatient_lost()

# =========================================================================
# CÁC HÀM XỬ LÝ CHUNG & HOÀN THÀNH KHÁCH
# =========================================================================
func _complete_current_passenger() -> void:
	processed_passengers += 1
	combo_streak += 1
	
	# Kích hoạt Fever Mode khi combo >= 3
	if combo_streak >= 3:
		if not is_fever_mode:
			trigger_toast("🔥 FEVER MODE KÍCH HOẠT! Tốc độ mở cổng x1.5 & Nhân đôi Cá Khô!", false)
			SoundManager.play_meow(1.3)
		is_fever_mode = true
		fever_timer = 8.0
		
	# Mở cổng barrier
	var open_duration = 0.4 if is_fever_mode else 0.6
	barrier_open_timer = open_duration
	is_barrier_open = true
	_set_barrier_visual(true, "MỜI QUA CỔNG! (COMBO x%d)" % combo_streak)
	
	if current_cat_anim:
		current_cat_anim.play("run")
		
	# Kiểm tra điều kiện Thắng
	if processed_passengers >= target_passengers_to_win:
		_trigger_victory()
		return
		
	is_passenger_transitioning = true
	transition_timer = 0.45

func _on_passenger_impatient_lost() -> void:
	failed_passengers += 1
	combo_streak = 0
	is_fever_mode = false
	SoundManager.play_fail()
	SoundManager.vibrate(90)
	
	trigger_toast("😿 Khách hết kiên nhẫn bỏ đi! (Hỏng cổng: %d/%d)" % [failed_passengers, max_failed_allowed], true)
	
	if current_cat_anim:
		current_cat_anim.play("hurt")
		
	if failed_passengers >= max_failed_allowed:
		_trigger_defeat("Cổng soát vé kẹt cứng (Gate Jam)! Quá 3 hành khách bực mình bỏ đi!")
		return
		
	is_passenger_transitioning = true
	transition_timer = 0.5

func _penalize_mistake(reason: String, patience_drop: float) -> void:
	combo_streak = 0
	is_fever_mode = false
	passenger_patience = maxf(0.5, passenger_patience - patience_drop)
	trigger_toast("⚠️ %s (-%.1fs)" % [reason, patience_drop], true)

func _set_barrier_visual(is_open: bool, lcd_text: String) -> void:
	barrier_lcd_label.text = lcd_text
	if is_open:
		barrier_led_rect.color = Color(0.2, 0.9, 0.3, 1.0) # Đèn XANH
		barrier_arm_left.scale.y = 0.2 # Co lại mở ra
		barrier_arm_right.scale.y = 0.2
	else:
		barrier_led_rect.color = Color(0.9, 0.25, 0.2, 1.0) # Đèn ĐỎ
		barrier_arm_left.scale.y = 1.0 # Chắn ngang
		barrier_arm_right.scale.y = 1.0

func _update_header_ui() -> void:
	clock_label.text = "⏱️ %ds" % int(ceil(time_left))
	time_bar.value = (time_left / total_time) * 100.0
	count_label.text = "Khách: %d/%d" % [processed_passengers, target_passengers_to_win]
	
	if is_fever_mode:
		combo_badge.text = "🔥 FEVER x%d!" % combo_streak
		combo_badge.add_theme_color_override("font_color", Color(1.0, 0.45, 0.05))
	elif combo_streak > 1:
		combo_badge.text = "⚡ Combo: %d" % combo_streak
		combo_badge.add_theme_color_override("font_color", Color(0.2, 0.65, 0.9))
	else:
		combo_badge.text = "Combo: 0"
		combo_badge.add_theme_color_override("font_color", Color(0.45, 0.4, 0.35))
		
	jam_badge.text = "Kẹt cổng: %d/%d ⚠️" % [failed_passengers, max_failed_allowed]
	if failed_passengers >= 2:
		jam_badge.add_theme_color_override("font_color", Color(0.95, 0.2, 0.2))
	else:
		jam_badge.add_theme_color_override("font_color", Color(0.5, 0.35, 0.2))

# =========================================================================
# THẮNG / THUA & REWARDS
# =========================================================================
func _trigger_victory() -> void:
	if not is_game_active: return
	is_game_active = false
	SoundManager.play_success()
	
	var msg = "🎉 XUẤT SẮC! CỔNG SOÁT VÉ THÔNG THOÁNG TOÀN TUYẾN!\n\n"
	msg += "• Đã xử lý chuẩn xác: %d/%d hành khách\n" % [processed_passengers, target_passengers_to_win]
	msg += "• Thời gian còn lại: %d giây\n" % int(time_left)
	msg += "• Chuỗi Combo cao nhất: %d\n\n" % combo_streak
	msg += "💡 BÀI HỌC SOÁT VÉ SINH VIÊN:\n"
	msg += "1. Thẻ cứng sinh viên & CCCD gắn chip luôn quẹt vào ĐẦU ĐỌC RFID.\n"
	msg += "2. Mở App vé số MoMo / HURC Pass thì nhớ tăng sáng màn hình (>70%) để máy quang học nhận diện.\n"
	msg += "3. Lên xe buýt nhớ chuẩn bị sẵn tiền lẻ 5k hoặc tính nhanh tiền thối để không làm ùn tắc cửa xe!"
	
	victory_text.text = msg
	victory_modal.visible = true

func _trigger_defeat(reason: String) -> void:
	if not is_game_active: return
	is_game_active = false
	SoundManager.play_fail()
	
	var msg = "😿 CỔNG SOÁT VÉ BỊ KẸT CỨNG (GATE JAM)!\n\n"
	msg += "%s\n\n" % reason
	msg += "💡 MẸO TỰ LẬP DÀNH CHO SEN:\n"
	msg += "• Chú ý biểu tượng trên tay khách để chọn đúng công cụ.\n"
	msg += "• Khách đưa QR tối: Kéo thanh trượt sáng trước khi quét.\n"
	msg += "• Xe buýt 08: Canh đầu xe vào gần vạch vàng (cách 30-60px) rồi mới nhấn ✋ vẫy xe!"
	
	defeat_text.text = msg
	defeat_modal.visible = true

func _on_claim_victory_pressed() -> void:
	SoundManager.play_success()
	var fish_reward = 30
	if is_fever_mode:
		fish_reward = 50
		
	if GameManager.has_method("update_stats"):
		GameManager.update_stats(fish_reward, 0, 0, 0)
	elif "fish" in GameManager:
		GameManager.fish += fish_reward
		
	if "badges" in GameManager and not ("Soát Vé Siêu Tốc" in GameManager.badges):
		GameManager.badges.append("Soát Vé Siêu Tốc")
		
	minigame_completed.emit([
		{"icon": "💳", "text": "Quẹt thẻ CCCD/Thẻ SV qua cổng RFID"},
		{"icon": "📱", "text": "Tăng sáng quét vé QR HURC Pass"},
		{"icon": "💵", "text": "Toán tiền thối vé xe buýt chuẩn xác"},
		{"icon": "✋", "text": "Vẫy xe buýt 08 đúng điểm dừng"}
	])

# =========================================================================
# UTILITIES
# =========================================================================
func trigger_toast(msg: String, is_danger: bool = false) -> void:
	toast_label.text = msg
	if is_danger:
		toast_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.85))
		var s = StyleBoxFlat.new()
		s.bg_color = Color(0.85, 0.25, 0.20, 0.95)
		s.border_color = Color(0.70, 0.15, 0.10, 1.0)
		s.set_border_width_all(2)
		s.set_corner_radius_all(10)
		s.content_margin_left = 14
		s.content_margin_right = 14
		s.content_margin_top = 8
		s.content_margin_bottom = 8
		toast_panel.add_theme_stylebox_override("panel", s)
	else:
		toast_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
		var s = StyleBoxFlat.new()
		s.bg_color = Color(0.18, 0.45, 0.65, 0.95)
		s.border_color = Color(0.10, 0.32, 0.50, 1.0)
		s.set_border_width_all(2)
		s.set_corner_radius_all(10)
		s.content_margin_left = 14
		s.content_margin_right = 14
		s.content_margin_top = 8
		s.content_margin_bottom = 8
		toast_panel.add_theme_stylebox_override("panel", s)
		
	toast_panel.visible = true
	toast_timer.start(2.5)

func _format_money(amount: int) -> String:
	var s = str(amount)
	var res = ""
	var cnt = 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		cnt += 1
		if cnt % 3 == 0 and i > 0:
			res = "." + res
	return res
