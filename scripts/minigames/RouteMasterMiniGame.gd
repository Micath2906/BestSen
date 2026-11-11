extends Control

# RouteMasterMiniGame.gd - Minigame "Thổ Địa Lập Route" cho Best Sen
# Phong cách: 2D Flat Vector / Pixel Art tối giản kiểu mạch điện tử metro (Mini Metro / BusMap)
# Viewport: Responsive Mobile 540x960 (hỗ trợ hoàn hảo 390x844 và tỷ lệ 9:16)

signal minigame_completed(sim_steps)
signal back_requested

# =========================================================================
# KHAI BÁO NODES
# =========================================================================
@onready var map_canvas: Control = $MapArea/MapCanvas
@onready var clock_label: Label = $Header/HBox/TimerBox/VBox/ClockLabel
@onready var class_status_label: Label = $Header/HBox/TimerBox/VBox/ClassStatusLabel
@onready var time_bar: ProgressBar = $Header/HBox/TimerBox/VBox/TimeBar
@onready var fish_label: Label = $Header/HBox/FishWallet/VBox/FishLabel
@onready var transfer_cost_label: Label = $Header/HBox/FishWallet/VBox/CostLabel
@onready var btn_handbook: Button = $Header/HBox/BtnHandbook
@onready var btn_back: Button = $Header/HBox/BtnBack

@onready var toast_panel: PanelContainer = $ToastPanel
@onready var toast_label: Label = $ToastPanel/ToastLabel
@onready var toast_timer: Timer = $ToastTimer

@onready var bottom_hint_label: Label = $BottomBar/HBox/HintLabel
@onready var transfer_count_label: Label = $BottomBar/HBox/TransferBadge
@onready var speed_label: Label = $BottomBar/HBox/SpeedBadge

# Modals
@onready var handbook_modal: Control = $HandbookModal
@onready var btn_close_handbook: Button = $HandbookModal/ModalPanel/VBox/BtnCloseHandbook

@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_view_infographic: Button = $VictoryModal/ModalPanel/VBox/BtnViewInfographic
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

@onready var defeat_modal: Control = $DefeatModal
@onready var defeat_dialogue: Label = $DefeatModal/ModalPanel/VBox/Scroll/DefeatLabel
@onready var btn_retry: Button = $DefeatModal/ModalPanel/VBox/BtnRetry

@onready var infographic_modal: Control = $InfographicModal
@onready var btn_close_infographic: Button = $InfographicModal/ModalPanel/VBox/BtnCloseInfo
@onready var btn_save_infographic: Button = $InfographicModal/ModalPanel/VBox/BtnSaveInfo

# =========================================================================
# THÔNG SỐ ĐỒ THỊ TRẠM XE & TUYẾN ĐƯỜNG (GRAPH NODES)
# =========================================================================
var stations: Dictionary = {
	"ktx_b": {
		"id": "ktx_b",
		"name": "KTX Khu B (ĐHQG)",
		"pos": Vector2(430, 160),
		"type": "start",
		"line": "bus_start",
		"is_correct_dir": true,
		"neighbors": ["dhqg_in", "dhqg_out"]
	},
	"dhqg_in": {
		"id": "dhqg_in",
		"name": "Trạm ĐHQG [➔ Bến Thành]",
		"pos": Vector2(390, 235),
		"type": "bus_in",
		"line": "bus_08",
		"is_correct_dir": true,
		"neighbors": ["cho_thu_duc_in", "cho_thu_duc_out", "metro_suoi_tien"]
	},
	"dhqg_out": {
		"id": "dhqg_out",
		"name": "Trạm ĐHQG [⬅ BX Miền Tây]",
		"pos": Vector2(470, 235),
		"type": "bus_out",
		"line": "bus_08",
		"is_correct_dir": false,
		"neighbors": []
	},
	"metro_suoi_tien": {
		"id": "metro_suoi_tien",
		"name": "Ga Suối Tiên (Metro 1)",
		"pos": Vector2(330, 200),
		"type": "metro",
		"line": "metro_1",
		"is_correct_dir": true,
		"neighbors": ["metro_thu_duc"]
	},
	"cho_thu_duc_in": {
		"id": "cho_thu_duc_in",
		"name": "Chợ Thủ Đức [➔ Bến Thành]",
		"pos": Vector2(370, 355),
		"type": "bus_in",
		"line": "bus_08",
		"is_correct_dir": true,
		"neighbors": ["hang_xanh_in", "hang_xanh_out", "metro_thu_duc"]
	},
	"cho_thu_duc_out": {
		"id": "cho_thu_duc_out",
		"name": "Chợ Thủ Đức [⬅ BX Miền Tây]",
		"pos": Vector2(450, 355),
		"type": "bus_out",
		"line": "bus_08",
		"is_correct_dir": false,
		"neighbors": []
	},
	"metro_thu_duc": {
		"id": "metro_thu_duc",
		"name": "Ga Thủ Đức (Metro 1)",
		"pos": Vector2(265, 325),
		"type": "metro",
		"line": "metro_1",
		"is_correct_dir": true,
		"neighbors": ["metro_tan_cang"]
	},
	"hang_xanh_in": {
		"id": "hang_xanh_in",
		"name": "Ngã 4 Hàng Xanh [➔ Bến Thành]",
		"pos": Vector2(295, 510),
		"type": "bus_in",
		"line": "bus_08",
		"is_correct_dir": true,
		"neighbors": ["dinh_tien_hoang_in", "dinh_tien_hoang_out", "metro_tan_cang"]
	},
	"hang_xanh_out": {
		"id": "hang_xanh_out",
		"name": "Ngã 4 Hàng Xanh [⬅ BX Miền Tây]",
		"pos": Vector2(375, 510),
		"type": "bus_out",
		"line": "bus_08",
		"is_correct_dir": false,
		"neighbors": []
	},
	"metro_tan_cang": {
		"id": "metro_tan_cang",
		"name": "Ga Tân Cảng (Metro 1)",
		"pos": Vector2(195, 465),
		"type": "metro",
		"line": "metro_1",
		"is_correct_dir": true,
		"neighbors": ["metro_ba_son"]
	},
	"metro_ba_son": {
		"id": "metro_ba_son",
		"name": "Ga Ba Son (Metro 1)",
		"pos": Vector2(145, 575),
		"type": "metro",
		"line": "metro_1",
		"is_correct_dir": true,
		"neighbors": ["metro_nha_hat"]
	},
	"metro_nha_hat": {
		"id": "metro_nha_hat",
		"name": "Ga Nhà Hát TP (Metro 1)",
		"pos": Vector2(110, 655),
		"type": "metro",
		"line": "metro_1",
		"is_correct_dir": true,
		"neighbors": ["metro_ben_thanh", "goal_dai_hoc"]
	},
	"metro_ben_thanh": {
		"id": "metro_ben_thanh",
		"name": "Ga Bến Thành (Metro 1)",
		"pos": Vector2(80, 735),
		"type": "metro",
		"line": "metro_1",
		"is_correct_dir": true,
		"neighbors": ["goal_dai_hoc"]
	},
	"dinh_tien_hoang_in": {
		"id": "dinh_tien_hoang_in",
		"name": "Đinh Tiên Hoàng [➔ Bến Thành]",
		"pos": Vector2(220, 650),
		"type": "bus_in",
		"line": "bus_08",
		"is_correct_dir": true,
		"neighbors": ["goal_dai_hoc"]
	},
	"dinh_tien_hoang_out": {
		"id": "dinh_tien_hoang_out",
		"name": "Đinh Tiên Hoàng [⬅ BX Miền Tây]",
		"pos": Vector2(295, 650),
		"type": "bus_out",
		"line": "bus_08",
		"is_correct_dir": false,
		"neighbors": []
	},
	"goal_dai_hoc": {
		"id": "goal_dai_hoc",
		"name": "Cổng Trường Đại Học",
		"pos": Vector2(150, 765),
		"type": "goal",
		"line": "goal",
		"is_correct_dir": true,
		"neighbors": []
	}
}

# Tuyến Metro 1 cố định
const METRO_LINE_STATIONS = [
	"metro_suoi_tien",
	"metro_thu_duc",
	"metro_tan_cang",
	"metro_ba_son",
	"metro_nha_hat",
	"metro_ben_thanh"
]

# Tọa độ sông Sài Gòn
const RIVER_POINTS = [
	Vector2(490, 80),
	Vector2(380, 140),
	Vector2(290, 240),
	Vector2(230, 370),
	Vector2(165, 490),
	Vector2(115, 610),
	Vector2(45, 780),
	Vector2(10, 860)
]

# =========================================================================
# BIẾN TRẠNG THÁI GAMEPLAY
# =========================================================================
var total_time: float = 60.0
var time_left: float = 60.0
var elapsed_time: float = 0.0
var is_game_active: bool = true

var fish_wallet: int = 25
var transfer_count: int = 0
var max_transfers_allowed: int = 1

# Danh sách Node người chơi đã kết nối thành công
var connected_path: Array[String] = ["ktx_b"]

# Runner Mèo
var cat_pos: Vector2 = Vector2(430, 160)
var cat_segment_idx: int = 0
var cat_segment_progress: float = 0.0
var cat_base_speed: float = 60.0 # px/s
var cat_current_speed_mult: float = 1.0
var cat_is_waiting_metro: bool = false
var cat_metro_wait_remaining: float = 0.0

# Sự kiện động
var flood_pos: Vector2 = Vector2(370, 355) # Chợ Thủ Đức
var flood_radius: float = 46.0
var flood_active: bool = false

var traffic_pos: Vector2 = Vector2(295, 510) # Ngã 4 Hàng Xanh
var traffic_radius: float = 46.0
var traffic_active: bool = false

# Metro Headway (5s/chuyến)
var metro_headway_cycle: float = 5.0
var metro_cycle_timer: float = 0.0
var metro_train_station_idx: int = 0
var metro_train_progress: float = 0.0

# Điều khiển kéo đường nối (Touch / Pointer Drag & Drop)
var is_dragging: bool = false
var drag_from_node_id: String = ""
var drag_mouse_pos: Vector2 = Vector2.ZERO
var snapped_node_id: String = ""

# Double tap để cắt dây
var last_tap_time_msec: int = 0
var last_tap_node_id: String = ""

# Hiệu ứng Rung (Haptic Shake)
var shake_intensity: float = 0.0
var shake_timer: float = 0.0
var original_canvas_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	if map_canvas:
		original_canvas_pos = map_canvas.position
		map_canvas.gui_input.connect(_on_canvas_gui_input)
		map_canvas.draw.connect(_on_canvas_draw)
	
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(func():
		SoundManager.play_click()
		emit_signal("back_requested")
	)
	
	btn_handbook.pressed.connect(func():
		SoundManager.play_click()
		handbook_modal.visible = true
	)
	
	btn_close_handbook.pressed.connect(func():
		SoundManager.play_click()
		handbook_modal.visible = false
	)
	
	btn_retry.pressed.connect(func():
		SoundManager.play_click()
		reset_game()
	)
	
	btn_claim_reward.pressed.connect(_on_claim_reward_pressed)
	
	btn_view_infographic.pressed.connect(func():
		SoundManager.play_click()
		infographic_modal.visible = true
	)
	
	btn_close_infographic.pressed.connect(func():
		SoundManager.play_click()
		infographic_modal.visible = false
	)
	
	btn_save_infographic.pressed.connect(func():
		SoundManager.play_success()
		trigger_toast("Đã lưu Infographic Sơ Đồ Tuyến vào máy Sen!", false)
	)
	
	toast_timer.timeout.connect(func(): toast_panel.visible = false)
	toast_panel.visible = false
	handbook_modal.visible = false
	victory_modal.visible = false
	defeat_modal.visible = false
	infographic_modal.visible = false
	
	reset_game()

func _on_claim_reward_pressed() -> void:
	SoundManager.play_success()
	if GameManager.has_method("update_stats"):
		GameManager.update_stats(25, 0, 0, 0)
	elif "fish" in GameManager:
		GameManager.fish += 25
	if "badges" in GameManager and not ("Thổ Địa Tuyến 08" in GameManager.badges):
		GameManager.badges.append("Thổ Địa Tuyến 08")
	print(">>> RouteMasterMiniGame: Emitting minigame_completed with rewards")
	minigame_completed.emit([
		{"icon": "🗺️", "text": "Lập Route KTX Khu B về Trường"},
		{"icon": "🚇", "text": "Chuyển tiếp Metro Ga Thủ Đức vượt ngập"},
		{"icon": "🎓", "text": "Cập bến giảng đường đúng giờ"}
	])

func load_minigame(_game_data: Dictionary) -> void:
	reset_game()

func reset_game() -> void:
	is_game_active = true
	time_left = total_time
	elapsed_time = 0.0
	fish_wallet = 25
	transfer_count = 0
	
	connected_path = ["ktx_b"]
	cat_pos = stations["ktx_b"]["pos"]
	cat_segment_idx = 0
	cat_segment_progress = 0.0
	cat_current_speed_mult = 1.0
	cat_is_waiting_metro = false
	cat_metro_wait_remaining = 0.0
	
	flood_active = false
	traffic_active = false
	metro_cycle_timer = 0.0
	
	is_dragging = false
	drag_from_node_id = ""
	snapped_node_id = ""
	
	toast_panel.visible = false
	victory_modal.visible = false
	defeat_modal.visible = false
	infographic_modal.visible = false
	
	_update_header_ui()
	if map_canvas:
		map_canvas.queue_redraw()

func _process(delta: float) -> void:
	if not is_game_active:
		return
		
	elapsed_time += delta
	time_left = maxf(0.0, time_left - delta)
	
	# Xử lý chu kỳ nhịp tàu Metro (5s/chuyến)
	metro_cycle_timer += delta
	if metro_cycle_timer >= metro_headway_cycle:
		metro_cycle_timer -= metro_headway_cycle
		
	# Xử lý sự kiện ngập nước tại giây 15
	if elapsed_time >= 15.0 and not flood_active:
		flood_active = true
		trigger_toast("🌊 Chợ Thủ Đức ngập sâu! Xe buýt chạy như rùa bò! Hãy chuyển sang Metro!", true)
		SoundManager.play_meow(0.9)
		trigger_shake(5.0, 0.25)
		
	# Xử lý sự kiện kẹt xe tại giây 30
	if elapsed_time >= 30.0 and not traffic_active:
		traffic_active = true
		trigger_toast("🚨 Ngã 4 Hàng Xanh kẹt xe cứng ngắc! Nguy cơ trễ thi! Hãy cắt dây sang Metro!", true)
		SoundManager.play_meow(0.85)
		trigger_shake(8.0, 0.35)
		
	# Xử lý màn hình rung (Haptic Shake)
	if shake_timer > 0.0:
		shake_timer -= delta
		var offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		if map_canvas:
			map_canvas.position = original_canvas_pos + offset
		if shake_timer <= 0.0 and map_canvas:
			map_canvas.position = original_canvas_pos
			
	# Di chuyển chú Mèo Runner
	_update_cat_movement(delta)
	
	# Cập nhật Header & UI
	_update_header_ui()
	
	# Kiểm tra điều kiện Thua (Hết giờ)
	if time_left <= 0.0 and is_game_active:
		_trigger_defeat("Hết 60 giây mà chưa tới được cổng trường! Mèo ngồi bệt khóc rụng lông ở vỉa hè...")
		
	if map_canvas:
		map_canvas.queue_redraw()

# =========================================================================
# CƠ CHẾ DI CHUYỂN CỦA MÈO RUNNER
# =========================================================================
func _update_cat_movement(delta: float) -> void:
	if cat_segment_idx >= connected_path.size() - 1:
		# Mèo đang đứng ở Node cuối cùng của đường đã nối
		var last_node_id = connected_path[connected_path.size() - 1]
		if last_node_id == "goal_dai_hoc" and is_game_active:
			_trigger_victory()
		return
		
	var from_id = connected_path[cat_segment_idx]
	var to_id = connected_path[cat_segment_idx + 1]
	var from_node = stations[from_id]
	var to_node = stations[to_id]
	
	var p_start = from_node["pos"]
	var p_end = to_node["pos"]
	var segment_len = p_start.distance_to(p_end)
	
	# Kiểm tra nếu đang vào ga Metro (cần đợi tàu nếu lỡ chuyến)
	if from_node["type"] == "metro" and to_node["type"] == "metro":
		# Di chuyển bằng Metro trên cao (tốc độ x2.5, miễn nhiễm ngập & kẹt xe)
		cat_current_speed_mult = 2.5
	else:
		# Di chuyển bằng xe Bus
		cat_current_speed_mult = 1.0
		# Kiểm tra nếu vị trí hiện tại đang nằm trong vùng ngập nước
		if flood_active and cat_pos.distance_to(flood_pos) < flood_radius:
			cat_current_speed_mult = 0.3 # Giảm 70% tốc độ
		# Kiểm tra nếu vị trí hiện tại đang nằm trong vùng kẹt xe
		elif traffic_active and cat_pos.distance_to(traffic_pos) < traffic_radius:
			cat_current_speed_mult = 0.1 # Giảm 90% tốc độ (kẹt cứng ngắc)
			
	# Xử lý nhịp chờ tàu Metro (Headway ETA)
	if to_node["type"] == "metro" and from_node["type"] != "metro":
		# Mèo vừa từ Bus bước vào Ga Metro: Kiểm tra nhịp tàu
		if not cat_is_waiting_metro:
			# Cửa sổ tàu đang đỗ tại ga: 0.0s đến 1.5s trong chu kỳ 5s
			var train_in_station = (metro_cycle_timer <= 1.5)
			if not train_in_station:
				cat_is_waiting_metro = true
				cat_metro_wait_remaining = metro_headway_cycle - metro_cycle_timer
				trigger_toast("🚇 Vừa lỡ chuyến Metro! Đang chờ nhịp tàu kế tiếp (5s/chuyến)...", false)
				return
				
	if cat_is_waiting_metro:
		cat_metro_wait_remaining -= delta
		if cat_metro_wait_remaining <= 0.0:
			cat_is_waiting_metro = false
			trigger_toast("🚇 Tàu Metro đã cập ga! Mèo phóng thẳng trên cao!", false)
			SoundManager.play_meow(1.3)
		else:
			return # Đang đứng đợi tàu
			
	if segment_len > 0.001:
		var step_dist = cat_base_speed * cat_current_speed_mult * delta
		cat_segment_progress += step_dist / segment_len
		cat_pos = p_start.lerp(p_end, clampf(cat_segment_progress, 0.0, 1.0))
		
		if cat_segment_progress >= 1.0:
			# Đã đến Node tiếp theo
			cat_segment_idx += 1
			cat_segment_progress = 0.0
			cat_pos = p_end
			SoundManager.play_card_pop()
			
			if to_id == "goal_dai_hoc" and is_game_active:
				_trigger_victory()

# =========================================================================
# CƠ CHẾ INPUT: DRAG & DROP, SNAP RADIUS, DIRECTIONAL CONSTRAINT
# =========================================================================
func _on_canvas_gui_input(event: InputEvent) -> void:
	if not is_game_active:
		return
		
	if event is InputEventMouseButton:
		var m_pos = event.position
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Kiểm tra Double-Tap vào Node để "Cắt dây" (Disconnect)
				var now = Time.get_ticks_msec()
				var clicked_node_id = _find_node_at_pos(m_pos, 35.0)
				
				if clicked_node_id != "" and clicked_node_id == last_tap_node_id and (now - last_tap_time_msec) < 350:
					# Double-tap detected!
					_on_node_double_tapped(clicked_node_id)
					last_tap_node_id = ""
					last_tap_time_msec = 0
					return
					
				last_tap_time_msec = now
				last_tap_node_id = clicked_node_id
				
				# Bắt đầu kéo từ Node cuối cùng hiện tại hoặc Node được nhấp vào
				var active_end_node_id = connected_path[connected_path.size() - 1]
				if clicked_node_id != "" and clicked_node_id == active_end_node_id:
					is_dragging = true
					drag_from_node_id = clicked_node_id
					drag_mouse_pos = m_pos
					snapped_node_id = ""
				elif clicked_node_id == "":
					# Hoặc bắt đầu kéo từ Node cuối cùng nếu chạm gần nó
					var end_pos = stations[active_end_node_id]["pos"]
					if m_pos.distance_to(end_pos) < 40.0:
						is_dragging = true
						drag_from_node_id = active_end_node_id
						drag_mouse_pos = m_pos
						snapped_node_id = ""
						
			else:
				# Nhả chuột / ngón tay -> Chốt nối đoạn đường
				if is_dragging:
					_finish_drag_connection()
				is_dragging = false
				drag_from_node_id = ""
				snapped_node_id = ""
				map_canvas.queue_redraw()
				
	elif event is InputEventMouseMotion and is_dragging:
		drag_mouse_pos = event.position
		# Tự động hít (Snap Radius < 30px)
		snapped_node_id = ""
		var from_node = stations.get(drag_from_node_id, {})
		var valid_neighbors: Array = from_node.get("neighbors", [])
		
		var best_dist = 30.0
		for n_id in valid_neighbors:
			var n_pos = stations[n_id]["pos"]
			var d = drag_mouse_pos.distance_to(n_pos)
			if d < best_dist:
				best_dist = d
				snapped_node_id = n_id
				drag_mouse_pos = n_pos # Snap chính xác vào tâm
				
		map_canvas.queue_redraw()

func _find_node_at_pos(pos: Vector2, radius: float = 30.0) -> String:
	var closest_id = ""
	var min_d = radius
	for id in stations.keys():
		var d = pos.distance_to(stations[id]["pos"])
		if d < min_d:
			min_d = d
			closest_id = id
	return closest_id

func _finish_drag_connection() -> void:
	if snapped_node_id == "" or drag_from_node_id == "":
		return
		
	var target_node = stations[snapped_node_id]
	
	# 1. KIỂM TRA CHIỀU DI CHUYỂN (Directional Constraint)
	if not target_node["is_correct_dir"]:
		# Người chơi kéo nhầm vào Node Trạm Sai (hướng BX Miền Tây)
		trigger_toast("⚠️ Đi ngược hướng rồi Sen ơi! Chuyến này trễ thi mất!", true)
		trigger_shake(8.0, 0.3)
		SoundManager.play_fail()
		SoundManager.vibrate(80)
		return
		
	# 2. KIỂM TRA ĐIỀU KIỆN CHUYỂN TUYẾN (Transfer)
	var from_node = stations[drag_from_node_id]
	var is_transfer = false
	if from_node["type"] != target_node["type"] and (from_node["type"] == "bus_in" and target_node["type"] == "metro"):
		is_transfer = true
		
	if is_transfer:
		if fish_wallet < 5:
			trigger_toast("😿 Không đủ Cá Khô để đổi tuyến Metro (-5 Cá Khô)! Hãy tìm đường khác!", true)
			SoundManager.play_fail()
			return
		fish_wallet -= 5
		transfer_count += 1
		trigger_toast("🎫 Đã chuyển sang Ga Metro Tuyến 1! (-5 Cá Khô) Phóng trên cao cực nhanh!", false)
		SoundManager.play_card_pop()
		SoundManager.vibrate(40)
	else:
		SoundManager.play_click()
		
	# 3. THÊM NODE VÀO LỘ TRÌNH
	if not (snapped_node_id in connected_path):
		connected_path.append(snapped_node_id)
		
	map_canvas.queue_redraw()

# =========================================================================
# CƠ CHẾ DOUBLE-TAP CẮT DÂY (DISCONNECT & TRANSFER)
# =========================================================================
func _on_node_double_tapped(node_id: String) -> void:
	var idx = connected_path.find(node_id)
	if idx == -1:
		return
		
	# Không cho cắt phần đường Mèo đã đi qua
	if idx < cat_segment_idx:
		trigger_toast("Mèo đã vượt qua trạm này rồi, không thể cắt dây ở phía sau!", true)
		return
		
	# Cắt bỏ toàn bộ các trạm phía sau node_id
	if idx < connected_path.size() - 1:
		connected_path = connected_path.slice(0, idx + 1)
		trigger_toast("✂️ Đã cắt dây từ '%s'! Hãy kéo nhánh mới sang Ga Metro trên cao!" % stations[node_id]["name"], false)
		SoundManager.play_cancel()
		SoundManager.vibrate(50)
		map_canvas.queue_redraw()

# =========================================================================
# VẼ ĐỒ THỊ BẢN ĐỒ FLAT VECTOR KIỂU MINI METRO
# =========================================================================
func _on_canvas_draw() -> void:
	# 1. Vẽ sông Sài Gòn (dải xanh pastel uốn cong)
	for i in range(RIVER_POINTS.size() - 1):
		map_canvas.draw_line(RIVER_POINTS[i], RIVER_POINTS[i+1], Color(0.72, 0.84, 0.94, 0.65), 32.0, true)
		map_canvas.draw_line(RIVER_POINTS[i], RIVER_POINTS[i+1], Color(0.60, 0.76, 0.90, 0.9), 4.0, true)
		
	# 2. Vẽ Tuyến Metro 1 Cố Định (Trục chính xanh dương đậm #0D47A1)
	for i in range(METRO_LINE_STATIONS.size() - 1):
		var p1 = stations[METRO_LINE_STATIONS[i]]["pos"]
		var p2 = stations[METRO_LINE_STATIONS[i+1]]["pos"]
		# Viền ngoài trắng
		map_canvas.draw_line(p1, p2, Color(1, 1, 1, 0.9), 12.0, true)
		# Lõi xanh dương Metro
		map_canvas.draw_line(p1, p2, Color(0.05, 0.28, 0.63, 1.0), 8.0, true)
		
	# 3. Vẽ các tuyến đường Bus nhánh (nét đứt vàng hổ phách)
	var bus_connections = [
		["ktx_b", "dhqg_in"],
		["dhqg_in", "cho_thu_duc_in"],
		["cho_thu_duc_in", "hang_xanh_in"],
		["hang_xanh_in", "dinh_tien_hoang_in"],
		["dinh_tien_hoang_in", "goal_dai_hoc"],
		["dhqg_in", "metro_suoi_tien"],
		["cho_thu_duc_in", "metro_thu_duc"],
		["hang_xanh_in", "metro_tan_cang"],
		["metro_ben_thanh", "goal_dai_hoc"]
	]
	for pair in bus_connections:
		var p1 = stations[pair[0]]["pos"]
		var p2 = stations[pair[1]]["pos"]
		_draw_dashed_line(p1, p2, Color(0.85, 0.70, 0.50, 0.4), 2.0, 6.0)
		
	# 4. Vẽ Vùng Ngập Nước (Flood Zone tại Chợ Thủ Đức)
	if flood_active:
		var pulse_wave = 1.0 + sin(elapsed_time * 4.0) * 0.08
		map_canvas.draw_circle(flood_pos, flood_radius * pulse_wave, Color(0.15, 0.77, 0.85, 0.35))
		map_canvas.draw_circle(flood_pos, flood_radius * 0.7, Color(0.15, 0.77, 0.85, 0.25))
		map_canvas.draw_arc(flood_pos, flood_radius * pulse_wave, 0, TAU, 32, Color(0.0, 0.65, 0.75, 0.8), 2.0)
		map_canvas.draw_string(ThemeDB.fallback_font, flood_pos + Vector2(-60, -32), "🌊 NGẬP NƯỚC (-70% V)", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.0, 0.45, 0.55))
		
	# 5. Vẽ Vùng Kẹt Xe (Traffic Jam tại Ngã 4 Hàng Xanh)
	if traffic_active:
		var pulse_jam = 1.0 + sin(elapsed_time * 5.0) * 0.08
		map_canvas.draw_circle(traffic_pos, traffic_radius * pulse_jam, Color(0.90, 0.22, 0.20, 0.40))
		map_canvas.draw_circle(traffic_pos, traffic_radius * 0.65, Color(0.90, 0.22, 0.20, 0.25))
		map_canvas.draw_arc(traffic_pos, traffic_radius * pulse_jam, 0, TAU, 32, Color(0.75, 0.12, 0.10, 0.85), 2.5)
		map_canvas.draw_string(ThemeDB.fallback_font, traffic_pos + Vector2(-60, -32), "🚨 KẸT CỨNG (-90% V)", HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.75, 0.12, 0.10))
		
	# 6. Vẽ Đường Nối Người Chơi Đã Chọn (Polyline Player Route)
	if connected_path.size() >= 2:
		for i in range(connected_path.size() - 1):
			var p1 = stations[connected_path[i]]["pos"]
			var p2 = stations[connected_path[i+1]]["pos"]
			var is_metro_seg = (stations[connected_path[i]]["type"] == "metro" and stations[connected_path[i+1]]["type"] == "metro")
			var route_col = Color(0.0, 0.85, 0.95, 0.95) if is_metro_seg else Color(1.0, 0.55, 0.0, 0.95)
			# Viền phát sáng
			map_canvas.draw_line(p1, p2, Color(1, 1, 1, 0.8), 8.0, true)
			map_canvas.draw_line(p1, p2, route_col, 5.0, true)
			
	# 7. Vẽ Preview Drag Line khi người chơi đang kéo
	if is_dragging and drag_from_node_id != "":
		var p_start = stations[drag_from_node_id]["pos"]
		var line_color = Color(1.0, 0.60, 0.0, 0.85)
		if snapped_node_id != "":
			if not stations[snapped_node_id]["is_correct_dir"]:
				line_color = Color(0.95, 0.2, 0.2, 0.9) # Đỏ cảnh báo đi sai chiều
			else:
				line_color = Color(0.2, 0.8, 0.3, 0.9) # Xanh lá nối đúng
		_draw_dashed_line(p_start, drag_mouse_pos, line_color, 4.0, 8.0)
		map_canvas.draw_circle(drag_mouse_pos, 8.0, line_color)
		
	# 8. Vẽ Đoàn Tàu Metro Tự Hành (Mini Metro Train)
	_draw_metro_train()
	
	# 9. Vẽ tất cả các Station Nodes
	for s_id in stations.keys():
		var node = stations[s_id]
		var pos = node["pos"]
		var n_type = node["type"]
		var is_in_path = (s_id in connected_path)
		
		match n_type:
			"start":
				# KTX Khu B (Icon Cờ Xanh)
				map_canvas.draw_circle(pos, 16.0, Color(0.18, 0.65, 0.35))
				map_canvas.draw_circle(pos, 13.0, Color(1, 1, 1))
				map_canvas.draw_circle(pos, 9.0, Color(0.18, 0.65, 0.35))
				map_canvas.draw_string(ThemeDB.fallback_font, pos + Vector2(-65, -20), "🚩 KTX KHU B", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color(0.15, 0.45, 0.25))
			"goal":
				# Cổng Trường ĐH
				map_canvas.draw_circle(pos, 18.0, Color(0.55, 0.20, 0.75))
				map_canvas.draw_circle(pos, 14.0, Color(1, 1, 1))
				map_canvas.draw_circle(pos, 10.0, Color(0.55, 0.20, 0.75))
				map_canvas.draw_string(ThemeDB.fallback_font, pos + Vector2(-60, 26), "🎓 CỔNG TRƯỜNG ĐH", HORIZONTAL_ALIGNMENT_CENTER, -1, 11, Color(0.40, 0.15, 0.55))
			"metro":
				# Ga Metro (Capsule trắng viền xanh)
				var cap_col = Color(0.05, 0.28, 0.63)
				map_canvas.draw_circle(pos, 13.0, cap_col)
				map_canvas.draw_circle(pos, 9.0, Color(1, 1, 1))
				map_canvas.draw_circle(pos, 5.0, cap_col if is_in_path else Color(0.7, 0.8, 0.9))
				map_canvas.draw_string(ThemeDB.fallback_font, pos + Vector2(-115, 3), node["name"], HORIZONTAL_ALIGNMENT_RIGHT, 105, 9, Color(0.05, 0.25, 0.55))
				
				# Vòng tròn ETA đếm nhịp tàu đến ga
				var eta_ratio = 1.0 - (metro_cycle_timer / metro_headway_cycle)
				map_canvas.draw_arc(pos, 17.0, 0, TAU * eta_ratio, 24, Color(0.2, 0.7, 1.0, 0.7), 2.0)
			"bus_in":
				# Trạm Bus Đúng Chiều (Vàng viền nâu, mũi tên ➔)
				var b_col = Color(0.95, 0.60, 0.10) if not is_in_path else Color(1.0, 0.45, 0.0)
				map_canvas.draw_circle(pos, 11.0, Color(0.45, 0.28, 0.10))
				map_canvas.draw_circle(pos, 9.0, b_col)
				map_canvas.draw_circle(pos, 4.0, Color(1, 1, 1))
				map_canvas.draw_string(ThemeDB.fallback_font, pos + Vector2(14, -8), node["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.35, 0.25, 0.15))
			"bus_out":
				# Trạm Bus Ngược Chiều (Đỏ cảnh báo ⬅)
				map_canvas.draw_circle(pos, 9.0, Color(0.65, 0.20, 0.20))
				map_canvas.draw_circle(pos, 7.0, Color(0.95, 0.35, 0.35))
				map_canvas.draw_circle(pos, 3.0, Color(1, 1, 1))
				map_canvas.draw_string(ThemeDB.fallback_font, pos + Vector2(12, 10), "⚠ Ngược Chiều", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color(0.85, 0.20, 0.20))
				
	# 10. Vẽ Chú Mèo Runner (Mascot)
	_draw_cat_mascot()

func _draw_dashed_line(p1: Vector2, p2: Vector2, col: Color, width: float, dash_len: float) -> void:
	var total_d = p1.distance_to(p2)
	if total_d < 0.01: return
	var dir = (p2 - p1).normalized()
	var curr = 0.0
	while curr < total_d:
		var start_p = p1 + dir * curr
		var end_p = p1 + dir * minf(curr + dash_len, total_d)
		map_canvas.draw_line(start_p, end_p, col, width)
		curr += dash_len * 2.0

func _draw_metro_train() -> void:
	# Tàu chạy tới chạy lui trên 6 ga Metro
	var num_segs = METRO_LINE_STATIONS.size() - 1
	var cycle_ratio = metro_cycle_timer / metro_headway_cycle
	var seg_f = cycle_ratio * float(num_segs)
	var seg_i = clampi(int(seg_f), 0, num_segs - 1)
	var seg_prog = seg_f - float(seg_i)
	
	var p1 = stations[METRO_LINE_STATIONS[seg_i]]["pos"]
	var p2 = stations[METRO_LINE_STATIONS[seg_i + 1]]["pos"]
	var train_pos = p1.lerp(p2, seg_prog)
	
	# Vẽ 3 toa tàu Metro Mini Flat Vector
	var dir = (p2 - p1).normalized()
	for i in range(3):
		var car_p = train_pos - dir * float(i * 14)
		map_canvas.draw_circle(car_p, 6.0, Color(0.05, 0.30, 0.70))
		map_canvas.draw_circle(car_p, 4.0, Color(0.9, 0.95, 1.0))

func _draw_cat_mascot() -> void:
	# Vẽ Avatar Mèo Con Pixel / Flat Vector di chuyển
	map_canvas.draw_circle(cat_pos, 14.0, Color(1, 0.85, 0.4))
	map_canvas.draw_circle(cat_pos, 11.0, Color(0.95, 0.55, 0.15)) # Lông cam
	# Tai mèo
	map_canvas.draw_colored_polygon([cat_pos + Vector2(-8, -10), cat_pos + Vector2(-3, -17), cat_pos + Vector2(0, -10)], Color(0.95, 0.55, 0.15))
	map_canvas.draw_colored_polygon([cat_pos + Vector2(8, -10), cat_pos + Vector2(3, -17), cat_pos + Vector2(0, -10)], Color(0.95, 0.55, 0.15))
	# Mắt mèo
	map_canvas.draw_circle(cat_pos + Vector2(-4, -1), 1.8, Color(0.2, 0.15, 0.1))
	map_canvas.draw_circle(cat_pos + Vector2(4, -1), 1.8, Color(0.2, 0.15, 0.1))
	# Mũi mèo
	map_canvas.draw_circle(cat_pos + Vector2(0, 3), 1.5, Color(0.9, 0.3, 0.4))
	
	# Bong bóng trạng thái trên đầu mèo
	if cat_is_waiting_metro:
		map_canvas.draw_string(ThemeDB.fallback_font, cat_pos + Vector2(-35, -24), "⏳ Đợi tàu %ds" % int(ceil(cat_metro_wait_remaining)), HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(0.05, 0.25, 0.6))
	elif flood_active and cat_pos.distance_to(flood_pos) < flood_radius:
		map_canvas.draw_string(ThemeDB.fallback_font, cat_pos + Vector2(-35, -24), "🏊 Bì bõm 30%", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(0.0, 0.45, 0.55))
	elif traffic_active and cat_pos.distance_to(traffic_pos) < traffic_radius:
		map_canvas.draw_string(ThemeDB.fallback_font, cat_pos + Vector2(-35, -24), "🚗 Kẹt cứng 10%", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(0.85, 0.15, 0.15))

# =========================================================================
# THẮNG / THUA & CẬP NHẬT UI
# =========================================================================
func _trigger_victory() -> void:
	if not is_game_active:
		return
	is_game_active = false
	SoundManager.play_success()
	
	var msg = "🎉 Mèo con bước xuống ga tàu mỉm cười tự tin, chuông trường vang rộn rã!\n\n"
	msg += "• Thời gian còn lại: %d giây (Kịp giờ vào lớp!)\n" % int(time_left)
	msg += "• Số lần đổi tuyến: %d/1 (Đạt chuẩn Thổ Địa Lập Route)\n" % transfer_count
	msg += "• Chi phí đổi tuyến: %d Cá Khô\n\n" % (transfer_count * 5)
	msg += "💡 BÀI HỌC SINH TỒN: Khi gặp mưa ngập ở Chợ Thủ Đức hoặc kẹt xe ở ngã tư Hàng Xanh, chuyển tiếp sang Ga Metro Tuyến 1 trên cao là giải pháp thông minh nhất của sinh viên!"
	victory_dialogue.text = msg
	victory_modal.visible = true

func _trigger_defeat(reason: String) -> void:
	if not is_game_active:
		return
	is_game_active = false
	SoundManager.play_fail()
	SoundManager.vibrate(100)
	
	var msg = "😿 %s\n\n" % reason
	msg += "Xe buýt bị chôn chân trong biển nước ngập hoặc điểm tắc đường quá lâu!\n\n"
	msg += "💡 MẸO TỰ LẬP DÀNH CHO SEN:\n"
	msg += "Hãy Double-tap vào trạm trước điểm ngập để 'Cắt dây', sau đó vẽ nhánh chuyển tiếp (Transfer) sang Ga Metro Suối Tiên hoặc Ga Thủ Đức để tàu cao tốc đưa Boss về trường đúng giờ nhé!"
	defeat_dialogue.text = msg
	defeat_modal.visible = true

func _update_header_ui() -> void:
	# 1. Đồng hồ
	clock_label.text = "⏱️ %ds" % int(ceil(time_left))
	time_bar.value = (time_left / total_time) * 100.0
	
	if time_left > 40.0:
		class_status_label.text = "Còn 45 phút vào lớp ⏰"
		class_status_label.add_theme_color_override("font_color", Color(0.2, 0.5, 0.25))
	elif time_left > 20.0:
		class_status_label.text = "Còn 20 phút - Nước ngập!"
		class_status_label.add_theme_color_override("font_color", Color(0.85, 0.50, 0.10))
	else:
		class_status_label.text = "Còn 5 phút - Sắp trễ thi!"
		class_status_label.add_theme_color_override("font_color", Color(0.90, 0.20, 0.15))
		
	# 2. Ví Cá Khô
	fish_label.text = "🐟 %d Cá Khô" % fish_wallet
	transfer_cost_label.text = "(-5 Cá Khô/đổi tuyến)"
	
	# 3. Badges dưới cùng
	transfer_count_label.text = "Chuyển tuyến: %d/%d" % [transfer_count, max_transfers_allowed]
	if transfer_count > max_transfers_allowed:
		transfer_count_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	else:
		transfer_count_label.add_theme_color_override("font_color", Color(0.2, 0.5, 0.25))
		
	var sp_pct = int(cat_current_speed_mult * 100.0)
	speed_label.text = "Tốc độ: %d%%" % sp_pct
	if sp_pct < 50:
		speed_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	elif sp_pct > 150:
		speed_label.add_theme_color_override("font_color", Color(0.1, 0.6, 0.8))
	else:
		speed_label.add_theme_color_override("font_color", Color(0.35, 0.25, 0.15))

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
	toast_timer.start(3.2)

func trigger_shake(intensity: float = 6.0, duration: float = 0.3) -> void:
	shake_intensity = intensity
	shake_timer = duration
