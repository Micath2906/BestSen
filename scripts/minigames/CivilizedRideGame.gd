extends Control

# CivilizedRideGame.gd - Minigame "Chuyến Đi Văn Minh" cho Best Sen
# Mô phỏng khoang toa tàu Metro Tuyến 1 / Xe buýt TP.HCM
# Góc nhìn Mặt Cắt Ngang (Cross-Section Cutaway View)
# Viewport: Mobile Responsive (390x844 & 540x960 9:16)

signal minigame_completed(sim_steps)
signal back_requested

# =========================================================================
# ENUM CÁC TÌNH HUỐNG VĂN MINH
# =========================================================================
enum SituationType {
	NONE = 0,
	PRIORITY_SEAT = 1,   # Nhường ghế ưu tiên cho Mèo Cụ
	BACKPACK_WAY = 2,    # Nhắc bạn Gấu chuyển ba lô ra trước ngực
	ANTI_THEFT_QTE = 3,  # Bắt quả tang Chuột Cống móc túi mèo ngủ gật
	STOP_BELL_TIMING = 4 # Căn nhịp bấm chuông xuống trạm (100m - 50m)
}

# =========================================================================
# KHAI BÁO NODES
# =========================================================================
@onready var clock_label: Label = $Header/HBox/TimerBox/VBox/ClockLabel
@onready var distance_label: Label = $Header/HBox/RouteBox/VBox/DistanceLabel
@onready var distance_bar: ProgressBar = $Header/HBox/RouteBox/VBox/DistanceBar
@onready var civic_label: Label = $Header/HBox/CivicBox/VBox/CivicLabel
@onready var civic_bar: ProgressBar = $Header/HBox/CivicBox/VBox/CivicBar
@onready var btn_back: Button = $Header/HBox/BtnBack

# Khoang tàu Cutaway View
@onready var cabin_viewport: Control = $CabinArea
@onready var window_backdrop: Control = $CabinArea/WindowBackdrop
@onready var cabin_draw_canvas: Control = $CabinArea/CabinCanvas

# Nút chuông Stop Bell & Timing Bar
@onready var bell_button: Button = $CabinArea/StopBellWidget/VBox/BtnBell
@onready var bell_light: ColorRect = $CabinArea/StopBellWidget/VBox/BellTopHBox/BellLight
@onready var timing_widget: Control = $CabinArea/StopBellWidget/VBox/TimingBarContainer
@onready var timing_zone_green: ColorRect = $CabinArea/StopBellWidget/VBox/TimingBarContainer/GreenZone
@onready var timing_indicator: ColorRect = $CabinArea/StopBellWidget/VBox/TimingBarContainer/Indicator

# Các nhân vật & hotspot tình huống
@onready var hotspot_dog: Button = $CabinArea/Hotspots/BtnDogSeat
@onready var hotspot_bear: Button = $CabinArea/Hotspots/BtnBearBackpack
@onready var hotspot_thief: Button = $CabinArea/Hotspots/BtnThiefHand

# Bong bóng tình huống & hướng dẫn
@onready var prompt_banner: PanelContainer = $PromptBanner
@onready var prompt_label: Label = $PromptBanner/HBox/PromptLabel
@onready var prompt_timer_bar: ProgressBar = $PromptBanner/HBox/PromptTimerBar

# Toast & Modals
@onready var toast_panel: PanelContainer = $ToastPanel
@onready var toast_label: Label = $ToastPanel/ToastLabel
@onready var toast_timer: Timer = $ToastTimer

@onready var victory_modal: Control = $VictoryModal
@onready var victory_text: Label = $VictoryModal/ModalPanel/VBox/Scroll/VictoryLabel
@onready var btn_claim_victory: Button = $VictoryModal/ModalPanel/VBox/BtnClaimVictory
@onready var btn_view_infographic: Button = $VictoryModal/ModalPanel/VBox/BtnViewInfographic

@onready var defeat_modal: Control = $DefeatModal
@onready var defeat_text: Label = $DefeatModal/ModalPanel/VBox/Scroll/DefeatLabel
@onready var btn_retry: Button = $DefeatModal/ModalPanel/VBox/BtnRetry

@onready var infographic_modal: Control = $InfographicModal
@onready var btn_close_info: Button = $InfographicModal/ModalPanel/VBox/BtnCloseInfo

# =========================================================================
# THÔNG SỐ VÀ TRẠNG THÁI GAMEPLAY
# =========================================================================
var total_time: float = 75.0
var time_left: float = 75.0
var is_game_active: bool = true

var total_distance_m: float = 600.0
var distance_remaining_m: float = 600.0
var train_speed_mps: float = 8.0 # 600m / 75s

var civic_points: int = 50 # Bắt đầu từ 50/100
const CIVIC_MIN_WIN: int = 70
const CIVIC_MAX_LOSS: int = 30

# State Machine tình huống
var current_situation: int = SituationType.NONE
var situation_timer: float = 0.0
var situation_timeout: float = 5.0
var active_situations_completed: int = 0
var scheduled_events: Array[Dictionary] = []

# Parallax background scrolling (Cửa sổ toa xe)
var window_scroll_x: float = 0.0
var cabin_sway_timer: float = 0.0

# Animation states của nhân vật
var is_grandpa_seated: bool = false
var is_bear_backpack_front: bool = false
var is_thief_caught: bool = false
var is_bell_rung_correctly: bool = false

# Gesture swipe tracking (cho Tình huống 2 - Ba lô Gấu)
var swipe_start_pos: Vector2 = Vector2.ZERO
var is_swiping: bool = false

# GP-ED-02: 3 Ghế + Ghế Ưu Tiên Trái Tim + Vòng Chọn 360° & Safe Failure Phản Chiếu
const TEX_COURAGE_HEART: Texture2D = preload("res://assets/UI/CatUIPaid/slices/icon_courage_heart.png")
const TEX_ICON_CHECK: Texture2D = preload("res://assets/UI/CatUIPaid/slices/icon_check.png")
const TEX_ICON_CROSS: Texture2D = preload("res://assets/UI/CatUIPaid/slices/icon_cross.png")
const COZY_DIALOG_SCN: PackedScene = preload("res://scenes/ui/CozyDialogBox.tscn")

var choice_ring_360: Control = null
var btn_ring_yield: Button = null
var btn_ring_keep_sitting: Button = null
var ride_cozy_dialog: Control = null
var courage_bonus_earned: int = 0
var reflective_safe_fails: int = 0

func _ready() -> void:
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(func():
		SoundManager.play_click()
		back_requested.emit()
	)
	
	if cabin_draw_canvas:
		cabin_draw_canvas.draw.connect(_on_cabin_draw)
		
	hotspot_dog.pressed.connect(_on_dog_seat_clicked)
	hotspot_bear.pressed.connect(_on_bear_backpack_action)
	hotspot_thief.pressed.connect(_on_thief_hand_tapped)
	bell_button.pressed.connect(_on_stop_bell_pressed)
	
	btn_claim_victory.pressed.connect(_on_claim_victory_pressed)
	btn_view_infographic.pressed.connect(func():
		SoundManager.play_click()
		infographic_modal.visible = true
	)
	btn_close_info.pressed.connect(func():
		SoundManager.play_click()
		infographic_modal.visible = false
	)
	btn_retry.pressed.connect(func():
		SoundManager.play_click()
		reset_game()
	)
	
	toast_timer.timeout.connect(func(): toast_panel.visible = false)
	toast_panel.visible = false
	victory_modal.visible = false
	defeat_modal.visible = false
	infographic_modal.visible = false
	_setup_gp_ed_02_ui()
	
	reset_game()

func load_minigame(_game_data: Dictionary) -> void:
	reset_game()

func reset_game() -> void:
	is_game_active = true
	time_left = total_time
	distance_remaining_m = total_distance_m
	civic_points = 50
	active_situations_completed = 0
	
	current_situation = SituationType.NONE
	situation_timer = 0.0
	
	is_grandpa_seated = false
	is_bear_backpack_front = false
	is_thief_caught = false
	is_bell_rung_correctly = false
	courage_bonus_earned = 0
	reflective_safe_fails = 0
	if choice_ring_360:
		choice_ring_360.visible = false
	if ride_cozy_dialog:
		ride_cozy_dialog.visible = false
	
	window_scroll_x = 0.0
	cabin_sway_timer = 0.0
	
	timing_widget.visible = false
	bell_light.color = Color(0.3, 0.1, 0.1) # Chuông tắt
	prompt_banner.visible = false
	
	toast_panel.visible = false
	victory_modal.visible = false
	defeat_modal.visible = false
	infographic_modal.visible = false
	
	_hide_all_hotspots()
	_schedule_events()
	_update_header_ui()

# =========================================================================
# LẬP LỊCH CÁC SỰ KIỆN TRONG 75 GIÂY HÀNH TRÌNH
# =========================================================================
func _schedule_events() -> void:
	scheduled_events.clear()
	# Sự kiện 1: Nhường ghế ưu tiên (Xuất hiện lúc 10s)
	scheduled_events.append({
		"time": 65.0, # time_left <= 65s (t = 10s)
		"type": SituationType.PRIORITY_SEAT,
		"timeout": 5.0,
		"triggered": false
	})
	# Sự kiện 2: Ba lô cọ quẹt (Xuất hiện lúc 28s)
	scheduled_events.append({
		"time": 47.0, # time_left <= 47s (t = 28s)
		"type": SituationType.BACKPACK_WAY,
		"timeout": 6.0,
		"triggered": false
	})
	# Sự kiện 3: Bắt quả tang kẻ móc túi (Xuất hiện lúc 46s)
	scheduled_events.append({
		"time": 29.0, # time_left <= 29s (t = 46s)
		"type": SituationType.ANTI_THEFT_QTE,
		"timeout": 2.5,
		"triggered": false
	})
	# Sự kiện 4: Bấm chuông xuống trạm (Khi cách trạm <= 150m, khoảng t = 58s)
	scheduled_events.append({
		"time": 17.0, # time_left <= 17s (khoảng cách còn ~135m)
		"type": SituationType.STOP_BELL_TIMING,
		"timeout": 12.0,
		"triggered": false
	})

# =========================================================================
# VÒNG LẶP CHÍNH _PROCESS (DI CHUYỂN, PARALLAX, TIMERS)
# =========================================================================
func _process(delta: float) -> void:
	if not is_game_active:
		return
		
	time_left = maxf(0.0, time_left - delta)
	distance_remaining_m = maxf(0.0, distance_remaining_m - train_speed_mps * delta)
	
	# Parallax scrolling qua cửa sổ toa xe
	window_scroll_x += 160.0 * delta
	if window_scroll_x >= 400.0:
		window_scroll_x -= 400.0
		
	cabin_sway_timer += delta * 2.0
	
	# Kiểm tra lịch kích hoạt sự kiện
	for ev in scheduled_events:
		if not ev["triggered"] and time_left <= ev["time"]:
			ev["triggered"] = true
			_trigger_situation(ev["type"], ev["timeout"])
			break
			
	# Đếm ngược sự kiện đang diễn ra
	if current_situation != SituationType.NONE:
		situation_timer -= delta
		prompt_timer_bar.value = (situation_timer / situation_timeout) * 100.0
		
		# Cập nhật thanh timing trượt cho tình huống bấm chuông
		if current_situation == SituationType.STOP_BELL_TIMING:
			_update_timing_bar_indicator()
			
		if situation_timer <= 0.0:
			_on_situation_timeout()
			
	# Kiểm tra điều kiện Thua do Điểm Văn Minh < 30
	if civic_points < CIVIC_MAX_LOSS:
		_trigger_defeat("Điểm Văn Minh tụt dưới 30! Bác tài và mọi người mời Sen xuống xe ở trạm kế tiếp để học lại quy tắc!")
		return
		
	# Kiểm tra khi xe tới trạm cuối (khoảng cách = 0 hoặc hết 75s)
	if distance_remaining_m <= 0.0 or time_left <= 0.0:
		if civic_points >= CIVIC_MIN_WIN:
			_trigger_victory()
		else:
			_trigger_defeat("Đã tới trạm cuối nhưng Điểm Văn Minh chỉ đạt %d/100 (Cần tối thiểu 70 điểm để đạt chuẩn)!" % civic_points)
		return
		
	_update_header_ui()
	if cabin_draw_canvas:
		cabin_draw_canvas.queue_redraw()

# =========================================================================
# KÍCH HOẠT VÀ QUẢN LÝ TÌNH HUỐNG
# =========================================================================
func _trigger_situation(sit_type: int, timeout_duration: float) -> void:
	current_situation = sit_type
	situation_timeout = timeout_duration
	situation_timer = timeout_duration
	prompt_banner.visible = true
	prompt_timer_bar.value = 100.0
	
	_hide_all_hotspots()
	
	match sit_type:
		SituationType.PRIORITY_SEAT:
			SoundManager.play_meow(0.9)
			prompt_label.text = "🧓 TÌNH HUỐNG 1: Mèo Cụ bước lên! Chọn trong Vòng 360° hoặc Tap bạn Chó để nhường ghế!"
			hotspot_dog.visible = true
			if choice_ring_360:
				choice_ring_360.visible = true
			trigger_toast("🧓 Mèo Cụ chống gậy cần ghế ngồi! Hãy nhắc nhường ghế ưu tiên!", false)
			
		SituationType.BACKPACK_WAY:
			SoundManager.play_card_pop()
			prompt_label.text = "🎒 TÌNH HUỐNG 2: Ba lô của Gấu cọ vào người khác! Vuốt / Tap vào ba lô để chuyển ra trước ngực!"
			hotspot_bear.visible = true
			trigger_toast("🎒 Ba lô cọ quẹt lối đi! Hãy chuyển ba lô ra trước ngực!", false)
			
		SituationType.ANTI_THEFT_QTE:
			SoundManager.play_meow(1.2)
			prompt_label.text = "🚨 TÌNH HUỐNG 3: Bắt quả tang kẻ móc túi! Tap NGAY vào bàn tay Chuột Cống trong 2.5s!"
			hotspot_thief.visible = true
			trigger_toast("🚨 Báo động: Chuột cống đang lén thò tay móc túi Mèo ngủ gật!", true)
			
		SituationType.STOP_BELL_TIMING:
			prompt_label.text = "🔔 TÌNH HUỐNG 4: Sắp tới trạm! Canh kim chạy vào VÙNG XANH (100m - 50m) rồi bấm chuông đỏ!"
			timing_widget.visible = true
			bell_light.color = Color(1.0, 0.4, 0.4) # Chuông nhấp nháy đỏ
			trigger_toast("🔔 Chuẩn bị xuống trạm: Canh đúng VÙNG XANH rồi bấm chuông đỏ!", false)

func _hide_all_hotspots() -> void:
	hotspot_dog.visible = false
	hotspot_bear.visible = false
	hotspot_thief.visible = false
	if choice_ring_360:
		choice_ring_360.visible = false

# =========================================================================
# XỬ LÝ TƯƠNG TÁC TỪNG TÌNH HUỐNG
# =========================================================================
# 1. Nhường ghế ưu tiên (+15 Điểm Văn Minh & +15 Dũng Cảm)
func _on_dog_seat_clicked() -> void:
	_yield_priority_seat()

func _yield_priority_seat() -> void:
	if current_situation != SituationType.PRIORITY_SEAT: return
	
	SoundManager.play_success()
	SoundManager.vibrate(35)
	is_grandpa_seated = true
	hotspot_dog.visible = false
	if choice_ring_360:
		choice_ring_360.visible = false
	civic_points = mini(100, civic_points + 15)
	courage_bonus_earned += 15
	if GameManager and GameManager.has_method("update_stats"):
		GameManager.update_stats(0, 0, 15, 5)
	active_situations_completed += 1
	
	trigger_toast("💖 Đứng dậy nhường chỗ! +15 Dũng Cảm | +15 Điểm Văn Minh!", false)
	_complete_situation()

func _on_keep_sitting_reflective_choice() -> void:
	if current_situation != SituationType.PRIORITY_SEAT:
		return
	# Reflective Safe Failure: Không kết thúc thua thô bạo, nhẹ nhàng phản chiếu để học viên suy ngẫm & thử lại
	reflective_safe_fails += 1
	SoundManager.play_fail()
	SoundManager.vibrate(15)
	if btn_ring_keep_sitting:
		var tw := create_tween()
		tw.tween_property(btn_ring_keep_sitting, "scale", Vector2(0.88, 0.88), 0.08)
		tw.tween_property(btn_ring_keep_sitting, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if ride_cozy_dialog and is_instance_valid(ride_cozy_dialog) and ride_cozy_dialog.has_method("show_dialog"):
		ride_cozy_dialog.show_dialog(
			"Tàu rung lắc khiến Mèo Cụ đứng hơi chênh vênh... Thử nhường ghế nhé!",
			"sad",
			"Nhường ghế ưu tiên thể hiện lòng nhân ái & văn minh nơi công cộng (+15 Dũng Cảm)."
		)
		get_tree().create_timer(3.2).timeout.connect(func():
			if is_instance_valid(ride_cozy_dialog):
				ride_cozy_dialog.visible = false
		)

# 2. Quy tắc ba lô lối đi
func _on_bear_backpack_action() -> void:
	if current_situation != SituationType.BACKPACK_WAY: return
	
	SoundManager.play_card_pop()
	SoundManager.vibrate(30)
	is_bear_backpack_front = true
	hotspot_bear.visible = false
	civic_points = mini(100, civic_points + 10)
	active_situations_completed += 1
	
	trigger_toast("🎒 Bạn Gấu đã ôm ba lô trước ngực! Lối đi thông thoáng! (+10 Điểm)", false)
	_complete_situation()

# 3. Bắt quả tang kẻ móc túi QTE
func _on_thief_hand_tapped() -> void:
	if current_situation != SituationType.ANTI_THEFT_QTE: return
	
	SoundManager.play_success()
	SoundManager.vibrate(50)
	is_thief_caught = true
	hotspot_thief.visible = false
	civic_points = mini(100, civic_points + 20)
	active_situations_completed += 1
	
	trigger_toast("🛡️ Vỗ tay bắt quả tang! Kẻ gian giật mình rụt tay lại! (+20 Điểm)", false)
	_complete_situation()

# 4. Bấm chuông Stop Bell
func _on_stop_bell_pressed() -> void:
	if current_situation != SituationType.STOP_BELL_TIMING:
		# Bấm vu vơ khi chưa tới cự ly
		SoundManager.play_fail()
		trigger_toast("⚠️ Chưa tới cự ly chuẩn bị xuống trạm! Không nghịch chuông nhé Sen!", true)
		return
		
	# Kiểm tra cự ly khoảng cách
	# Vùng chuẩn xác (Xanh): distance_remaining_m từ 50m đến 110m
	if distance_remaining_m >= 45.0 and distance_remaining_m <= 115.0:
		SoundManager.play_success()
		SoundManager.vibrate(40)
		is_bell_rung_correctly = true
		bell_light.color = Color(0.2, 0.9, 0.3) # Đèn XANH sáng
		civic_points = mini(100, civic_points + 25)
		active_situations_completed += 1
		timing_widget.visible = false
		trigger_toast("🔔 Chuông reng 'KENG KENG'! Xe tắp lề đón khách êm ái! (+25 Điểm)", false)
		_complete_situation()
	elif distance_remaining_m > 115.0:
		# Bấm quá sớm
		SoundManager.play_fail()
		civic_points = maxi(0, civic_points - 15)
		trigger_toast("⚠️ Bấm chuông quá sớm (>150m)! Bác tài phanh gấp giật mình! (-15 Điểm)", true)
	else:
		# Bấm quá trễ (< 45m)
		SoundManager.play_fail()
		civic_points = maxi(0, civic_points - 15)
		trigger_toast("⚠️ Bấm chuông quá trễ (<30m)! Xe bị lố trạm dừng! (-15 Điểm)", true)

func _update_timing_bar_indicator() -> void:
	# Cự ly còn từ 160m xuống 20m (tổng biên độ 140m)
	# Thanh timing bar rộng 120px
	var track_w = 120.0
	var ratio = 1.0 - clampf((distance_remaining_m - 20.0) / 140.0, 0.0, 1.0)
	timing_indicator.position.x = ratio * (track_w - timing_indicator.size.x)

# =========================================================================
# XỬ LÝ HẾT THỜI GIAN TÌNH HUỐNG (TIMEOUT / TRỪ ĐIỂM)
# =========================================================================
func _on_situation_timeout() -> void:
	SoundManager.play_fail()
	SoundManager.vibrate(80)
	
	match current_situation:
		SituationType.PRIORITY_SEAT:
			civic_points = maxi(0, civic_points - 20)
			trigger_toast("😿 Quá 5s: Tàu vào cua, Mèo Cụ loạng choạng suýt ngã! (-20 Điểm)", true)
			
		SituationType.BACKPACK_WAY:
			civic_points = maxi(0, civic_points - 15)
			trigger_toast("😿 Ba lô của Gấu va quẹt làm đổ đồ của người đứng sau! (-15 Điểm)", true)
			
		SituationType.ANTI_THEFT_QTE:
			civic_points = maxi(0, civic_points - 20)
			trigger_toast("🚨 Kẻ gian đã móc trộm ví thành công! Mèo ngủ gật hốt hoảng! (-20 Điểm)", true)
			
		SituationType.STOP_BELL_TIMING:
			civic_points = maxi(0, civic_points - 20)
			timing_widget.visible = false
			trigger_toast("😿 Quên bấm chuông báo dừng! Xe chạy thẳng qua trạm kế tiếp! (-20 Điểm)", true)
			
	_complete_situation()

func _complete_situation() -> void:
	current_situation = SituationType.NONE
	prompt_banner.visible = false
	_hide_all_hotspots()
	_update_header_ui()

# =========================================================================
# VẼ ĐỒ THỊ KHOANG TÀU CUTAWAY VIEW
# =========================================================================
func _on_cabin_draw() -> void:
	var sz = cabin_draw_canvas.size
	if sz.x <= 0 or sz.y <= 0: return
	
	# Rung lắc toa xe nhẹ nhàng theo sin(cabin_sway_timer)
	var sway_x: float = sin(cabin_sway_timer) * 2.5
	
	# 1. Cột vịn inox thẳng đứng & Thanh giằng ngang
	var pole_color = Color(0.88, 0.91, 0.95, 0.95)
	var pole_shade = Color(0.60, 0.65, 0.72, 1.0)
	
	# Thanh ngang treo tay nắm
	cabin_draw_canvas.draw_line(Vector2(16 + sway_x * 0.5, 95), Vector2(sz.x - 16 + sway_x * 0.5, 95), pole_shade, 6.0)
	cabin_draw_canvas.draw_line(Vector2(16 + sway_x * 0.5, 95), Vector2(sz.x - 16 + sway_x * 0.5, 95), pole_color, 4.0)
	
	# Tính toán layout 3 ghế (1 Ghế Ưu Tiên + 2 Ghế Tiêu Chuẩn) + Lối đi linh hoạt
	var pad: float = 10.0
	var aisle_w: float = clampf(sz.x * 0.21, 74.0, 108.0)
	var seats_total_w: float = sz.x - pad * 2.0 - aisle_w - 8.0
	var seat_w: float = clampf((seats_total_w - 12.0) / 3.0, 62.0, 120.0)
	var prio_rect = Rect2(pad + sway_x, sz.y - 125, seat_w, 85)
	var norm_rect_1 = Rect2(prio_rect.end.x + 6.0, sz.y - 125, seat_w, 85)
	var norm_rect_2 = Rect2(norm_rect_1.end.x + 6.0, sz.y - 125, seat_w, 85)
	var aisle_x: float = norm_rect_2.end.x + 8.0
	
	# Cột inox dọc định hình không gian toa xe
	var pole_x_coords = [prio_rect.position.x + 3.0, prio_rect.end.x + 3.0, norm_rect_2.end.x + 3.0, sz.x - 16.0 + sway_x]
	for px in pole_x_coords:
		cabin_draw_canvas.draw_line(Vector2(px, 95), Vector2(px, sz.y - 30), pole_shade, 8.0)
		cabin_draw_canvas.draw_line(Vector2(px, 95), Vector2(px, sz.y - 30), pole_color, 5.0)
		
	# 2. Tay nắm vòng tròn treo (Strap Handles) lắc theo quán tính toa xe
	var handles_count = maxi(4, int((sz.x - 40.0) / 60.0))
	var handle_spacing = (sz.x - 60.0) / float(handles_count - 1)
	for i in range(handles_count):
		var hx = 30.0 + i * handle_spacing
		var strap_tip_x = hx + sway_x * 1.4
		cabin_draw_canvas.draw_line(Vector2(hx, 95), Vector2(strap_tip_x, 130), Color(0.25, 0.25, 0.3), 2.5)
		cabin_draw_canvas.draw_arc(Vector2(strap_tip_x, 142), 12.0, 0, TAU, 16, Color(0.98, 0.82, 0.15), 3.0)
		
	# 3. Ghế 1: Ghế Ưu Tiên Màu Cam + Huy hiệu Trái Tim Dũng Cảm
	cabin_draw_canvas.draw_rect(prio_rect, Color(0.95, 0.45, 0.12), true)
	cabin_draw_canvas.draw_rect(prio_rect, Color(0.80, 0.32, 0.06), false, 2.5)
	var prio_badge_rect = Rect2(prio_rect.position.x + 2, prio_rect.position.y - 24, prio_rect.size.x - 4, 18)
	cabin_draw_canvas.draw_rect(prio_badge_rect, Color(1.0, 0.94, 0.88), true)
	cabin_draw_canvas.draw_rect(prio_badge_rect, Color(0.92, 0.42, 0.10), false, 1.5)
	if TEX_COURAGE_HEART:
		cabin_draw_canvas.draw_texture_rect(TEX_COURAGE_HEART, Rect2(prio_badge_rect.position.x + 4, prio_badge_rect.position.y + 2, 14, 14), false)
	cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(prio_badge_rect.position.x + 21, prio_badge_rect.position.y + 13), "ƯU TIÊN", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.75, 0.25, 0.05))
	
	# Ghế 2 & Ghế 3: 2 Ghế Thường Màu Xanh Lam Metro
	for n_idx in range(2):
		var nrect: Rect2 = norm_rect_1 if n_idx == 0 else norm_rect_2
		cabin_draw_canvas.draw_rect(nrect, Color(0.18, 0.48, 0.88), true)
		cabin_draw_canvas.draw_rect(nrect, Color(0.10, 0.32, 0.65), false, 2.5)
		var norm_badge_rect = Rect2(nrect.position.x + 2, nrect.position.y - 24, nrect.size.x - 4, 18)
		cabin_draw_canvas.draw_rect(norm_badge_rect, Color(0.90, 0.95, 1.0), true)
		cabin_draw_canvas.draw_rect(norm_badge_rect, Color(0.18, 0.45, 0.85), false, 1.5)
		var b_title := "GHẾ THƯỜNG %d" % (n_idx + 1)
		cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(norm_badge_rect.position.x + 5, norm_badge_rect.position.y + 13), b_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.10, 0.30, 0.65))
	
	# 4. Trạng thái hành khách trên 3 ghế & lối đi
	# Ghế 1 (Ưu tiên)
	if is_grandpa_seated:
		cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(prio_rect.position.x + 5, prio_rect.position.y + 34), "🐱 Mèo Cụ ✨", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(1, 1, 1))
		cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(prio_rect.position.x + 5, prio_rect.position.y + 54), "💖 Cảm ơn!", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(1, 0.95, 0.85))
	else:
		cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(prio_rect.position.x + 5, prio_rect.position.y + 34), "🐶 Cún Ngồi", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(1, 1, 1))
		cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(prio_rect.position.x + 5, prio_rect.position.y + 54), "🎧 Nghe nhạc", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(1, 0.92, 0.82))
		# Mèo Cụ đứng chống gậy bên cạnh (cảnh báo cần nhường)
		var alert_stand_rect = Rect2(prio_rect.position.x, prio_rect.position.y - 56, prio_rect.size.x + 28.0, 24)
		cabin_draw_canvas.draw_rect(alert_stand_rect, Color(0.98, 0.90, 0.88), true)
		cabin_draw_canvas.draw_rect(alert_stand_rect, Color(0.85, 0.25, 0.15), false, 1.5)
		cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(alert_stand_rect.position.x + 4, alert_stand_rect.position.y + 16), "👴 Mèo Cụ Chống Gậy!", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.85, 0.20, 0.10))
		
	# Ghế 2 (Tiêu chuẩn 1 - Mèo SV Ngủ Gật)
	cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(norm_rect_1.position.x + 5, norm_rect_1.position.y + 34), "😸 SV Ngủ 💤", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(1, 1, 1))
	cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(norm_rect_1.position.x + 5, norm_rect_1.position.y + 54), "🎒 Giữ ví!", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.85, 0.95, 1.0))
	
	# Ghế 3 (Tiêu chuẩn 2 - Bạn Đọc Sách)
	cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(norm_rect_2.position.x + 5, norm_rect_2.position.y + 34), "🦊 Bạn Đọc", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(1, 1, 1))
	cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(norm_rect_2.position.x + 5, norm_rect_2.position.y + 54), "📖 Trật tự", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.85, 0.95, 1.0))
	
	# Lối đi & hành khách đứng (Gấu & Chuột móc túi)
	if is_bear_backpack_front:
		var bear_rect = Rect2(aisle_x, sz.y - 125, sz.x - aisle_x - 6.0, 36)
		cabin_draw_canvas.draw_rect(bear_rect, Color(0.92, 0.98, 0.94), true)
		cabin_draw_canvas.draw_rect(bear_rect, Color(0.20, 0.65, 0.35), false, 1.5)
		cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(bear_rect.position.x + 4, bear_rect.position.y + 22), "🐻 Ôm Balo ✅", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.15, 0.55, 0.25))
	else:
		var bear_rect = Rect2(aisle_x, sz.y - 125, sz.x - aisle_x - 6.0, 36)
		cabin_draw_canvas.draw_rect(bear_rect, Color(1.0, 0.95, 0.88), true)
		cabin_draw_canvas.draw_rect(bear_rect, Color(0.90, 0.45, 0.10), false, 1.5)
		cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(bear_rect.position.x + 4, bear_rect.position.y + 22), "🐻 Balo Cọ ⚠️", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.85, 0.35, 0.05))
		
	if current_situation == SituationType.ANTI_THEFT_QTE:
		var thief_rect = Rect2(aisle_x, sz.y - 75, sz.x - aisle_x - 6.0, 36)
		if is_thief_caught:
			cabin_draw_canvas.draw_rect(thief_rect, Color(0.92, 0.98, 0.94), true)
			cabin_draw_canvas.draw_rect(thief_rect, Color(0.20, 0.70, 0.30), false, 1.5)
			cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(thief_rect.position.x + 4, thief_rect.position.y + 22), "🐭 Rụt Tay 🛡️", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.15, 0.60, 0.25))
		else:
			cabin_draw_canvas.draw_rect(thief_rect, Color(1.0, 0.88, 0.88), true)
			cabin_draw_canvas.draw_rect(thief_rect, Color(0.90, 0.15, 0.15), false, 1.5)
			cabin_draw_canvas.draw_string(ThemeDB.fallback_font, Vector2(thief_rect.position.x + 4, thief_rect.position.y + 22), "🐀 Móc Túi 🚨", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.85, 0.15, 0.15))

# =========================================================================
# CẬP NHẬT HEADER & UI
# =========================================================================
func _update_header_ui() -> void:
	clock_label.text = "⏱️ %ds" % int(ceil(time_left))
	
	var route_progress: float = clampf(1.0 - (distance_remaining_m / total_distance_m), 0.0, 1.0)
	distance_label.text = "🏁 Còn %dm đến Trạm Đích" % int(ceil(distance_remaining_m))
	distance_bar.value = route_progress * 100.0
	
	civic_label.text = "Văn Minh: %d/100" % civic_points
	civic_bar.value = civic_points
	
	if GameManager and GameManager.has_signal("minigame_hud_updated"):
		GameManager.minigame_hud_updated.emit(time_left, route_progress)
	
	if civic_points >= CIVIC_MIN_WIN:
		civic_label.add_theme_color_override("font_color", Color(0.15, 0.65, 0.3))
	elif civic_points < CIVIC_MAX_LOSS:
		civic_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	else:
		civic_label.add_theme_color_override("font_color", Color(0.85, 0.45, 0.05))

# =========================================================================
# THẮNG / THUA & REWARDS
# =========================================================================
func _trigger_victory() -> void:
	if not is_game_active: return
	is_game_active = false
	SoundManager.play_success()
	
	var msg = "• Điểm Văn Minh chung cuộc: %d/100 (Đạt chuẩn >= 70)\n" % civic_points
	msg += "• Tình huống xử lý thành công: %d/4\n" % active_situations_completed
	msg += "• Đã bảo vệ an toàn cho Mèo Cụ, giữ gìn trật tự lối đi và ngăn chặn kẻ gian!\n\n"
	msg += "💡 THÔNG ĐIỆP BỎ TÚI:\n"
	msg += "Văn hóa đi tàu điện Metro & xe buýt văn minh bắt đầu từ những hành động nhỏ nhất của mỗi sinh viên chúng mình!"
	
	victory_text.text = msg
	victory_modal.visible = true

func _trigger_defeat(reason: String) -> void:
	if not is_game_active: return
	is_game_active = false
	SoundManager.play_fail()
	
	var msg = "%s\n\n" % reason
	msg += "• Điểm Văn Minh hiện tại: %d/100\n\n" % civic_points
	msg += "💡 MẸO TỰ LẬP DÀNH CHO SEN:\n"
	msg += "1. Nhường ghế cam ưu tiên cho người già, phụ nữ mang thai và trẻ nhỏ.\n"
	msg += "2. Đeo ba lô trước ngực khi lên xe đông để không cọ vào người khác.\n"
	msg += "3. Luôn cảnh giác bảo quản tư trang điện thoại, ví tiền.\n"
	msg += "4. Canh đúng cự ly 100m-50m trước trạm để bấm chuông đỏ!"
	
	defeat_text.text = msg
	defeat_modal.visible = true

func _on_claim_victory_pressed() -> void:
	SoundManager.play_success()
	
	if GameManager.has_method("update_stats"):
		GameManager.update_stats(35, 0, 0, 0)
	elif "fish" in GameManager:
		GameManager.fish += 35
		
	if "badges" in GameManager and not ("Công Dân Giao Thông Mẫu Mực" in GameManager.badges):
		GameManager.badges.append("Công Dân Giao Thông Mẫu Mực")
		
	minigame_completed.emit([
		{"icon": "🧓", "text": "Nhường ghế ưu tiên cho người cao tuổi"},
		{"icon": "🎒", "text": "Ôm ba lô trước ngực giữ lối đi thông thoáng"},
		{"icon": "🛡️", "text": "Cảnh giác tư trang phòng ngừa móc túi"},
		{"icon": "🔔", "text": "Bấm chuông dừng xe chuẩn xác cự ly 100m"}
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

# =========================================================================
# GP-ED-02: VÒNG CHỌN 360°, COZY DIALOG PHẢN CHIẾU & VÙNG CHẠM 56DP
# =========================================================================
func _setup_gp_ed_02_ui() -> void:
	for hs in [hotspot_dog, hotspot_bear, hotspot_thief]:
		if hs:
			hs.custom_minimum_size = Vector2(maxf(hs.custom_minimum_size.x, 56.0), maxf(hs.custom_minimum_size.y, 56.0))
			
	if cabin_viewport:
		choice_ring_360 = Control.new()
		choice_ring_360.name = "ChoiceRing360"
		choice_ring_360.visible = false
		choice_ring_360.z_index = 25
		choice_ring_360.custom_minimum_size = Vector2(260, 220)
		choice_ring_360.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		choice_ring_360.offset_left = -130
		choice_ring_360.offset_top = -110
		choice_ring_360.offset_right = 130
		choice_ring_360.offset_bottom = 110
		choice_ring_360.mouse_filter = Control.MOUSE_FILTER_STOP
		choice_ring_360.draw.connect(_on_choice_ring_draw)
		cabin_viewport.add_child(choice_ring_360)
		
		btn_ring_yield = Button.new()
		btn_ring_yield.name = "BtnYieldSeat"
		btn_ring_yield.text = "💖 Đứng Dậy Nhường"
		btn_ring_yield.custom_minimum_size = Vector2(204, 56)
		btn_ring_yield.position = Vector2(28, 36)
		btn_ring_yield.size = Vector2(204, 56)
		btn_ring_yield.add_theme_font_size_override("font_size", 14)
		btn_ring_yield.add_theme_color_override("font_color", Color.WHITE)
		btn_ring_yield.add_theme_stylebox_override("normal", _make_ring_btn_style(Color(0.18, 0.68, 0.36), Color(0.10, 0.45, 0.22)))
		btn_ring_yield.add_theme_stylebox_override("hover", _make_ring_btn_style(Color(0.22, 0.76, 0.42), Color(0.10, 0.50, 0.26)))
		btn_ring_yield.add_theme_stylebox_override("pressed", _make_ring_btn_style(Color(0.14, 0.54, 0.28), Color(0.08, 0.38, 0.18)))
		btn_ring_yield.pressed.connect(_yield_priority_seat)
		choice_ring_360.add_child(btn_ring_yield)
		
		btn_ring_keep_sitting = Button.new()
		btn_ring_keep_sitting.name = "BtnKeepSitting"
		btn_ring_keep_sitting.text = "😐 Tiếp Tục Ngồi"
		btn_ring_keep_sitting.custom_minimum_size = Vector2(204, 56)
		btn_ring_keep_sitting.position = Vector2(28, 128)
		btn_ring_keep_sitting.size = Vector2(204, 56)
		btn_ring_keep_sitting.add_theme_font_size_override("font_size", 14)
		btn_ring_keep_sitting.add_theme_color_override("font_color", Color(0.24, 0.18, 0.14))
		btn_ring_keep_sitting.add_theme_stylebox_override("normal", _make_ring_btn_style(Color(0.95, 0.90, 0.80), Color(0.65, 0.52, 0.40)))
		btn_ring_keep_sitting.add_theme_stylebox_override("hover", _make_ring_btn_style(Color(0.98, 0.94, 0.86), Color(0.65, 0.52, 0.40)))
		btn_ring_keep_sitting.add_theme_stylebox_override("pressed", _make_ring_btn_style(Color(0.86, 0.78, 0.66), Color(0.55, 0.44, 0.34)))
		btn_ring_keep_sitting.pressed.connect(_on_keep_sitting_reflective_choice)
		choice_ring_360.add_child(btn_ring_keep_sitting)
		
	if COZY_DIALOG_SCN:
		ride_cozy_dialog = COZY_DIALOG_SCN.instantiate()
		ride_cozy_dialog.name = "RideCozyDialog"
		ride_cozy_dialog.visible = false
		ride_cozy_dialog.z_index = 40
		ride_cozy_dialog.anchor_left = 0.04
		ride_cozy_dialog.anchor_right = 0.96
		ride_cozy_dialog.anchor_top = 0.68
		ride_cozy_dialog.anchor_bottom = 0.94
		ride_cozy_dialog.offset_left = 0
		ride_cozy_dialog.offset_right = 0
		ride_cozy_dialog.offset_top = 0
		ride_cozy_dialog.offset_bottom = 0
		add_child(ride_cozy_dialog)

func _on_choice_ring_draw() -> void:
	if not choice_ring_360:
		return
	var center := choice_ring_360.size * 0.5
	choice_ring_360.draw_circle(center, 102.0, Color(1.0, 0.96, 0.86, 0.32))
	choice_ring_360.draw_arc(center, 102.0, 0.0, TAU, 48, Color(0.95, 0.62, 0.18, 0.92), 4.0)
	choice_ring_360.draw_arc(center, 82.0, 0.0, TAU, 40, Color(0.28, 0.62, 0.92, 0.55), 2.5)

func _make_ring_btn_style(bg_col: Color, border_col: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg_col
	s.border_color = border_col
	s.set_border_width_all(3)
	s.set_corner_radius_all(28)
	s.content_margin_left = 14
	s.content_margin_right = 14
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s
