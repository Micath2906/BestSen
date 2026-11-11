extends Control

# QteMiniGame.gd - Gameplay "Mèo Phản Xạ Nhanh" (Timing / Quick Time Event - QTE)
# Người chơi canh đúng lúc xe buýt tiến vào Vùng Xanh (cách trạm 100m-50m) để nhấn nút Bấm Chuông Keng!

signal minigame_completed(sim_steps)
signal back_requested

@onready var title_lbl: Label = $Header/HeaderTitle
@onready var btn_back: Button = $Header/BtnBack
@onready var cat_speech: Label = $CatSection/HBox/CatSpeech
@onready var cat_anchor: Control = $CatSection/HBox/CatAnchor

@onready var track_bar: Control = $TrackCard/VBox/RouteTrack
@onready var vehicle_icon: Label = $TrackCard/VBox/RouteTrack/VehicleLabel
@onready var green_zone: ColorRect = $TrackCard/VBox/RouteTrack/GreenZone
@onready var stop_marker: Label = $TrackCard/VBox/RouteTrack/StopMarker
@onready var distance_lbl: Label = $TrackCard/VBox/DistanceLabel

@onready var btn_qte_action: Button = $ActionFooter/BtnQteAction
@onready var btn_restart: Button = $ActionFooter/BtnRestart

var data: Dictionary = {}
var progress: float = 0.0 # 0.0 to 1.0
var target_speed: float = 0.6
var zone_start: float = 0.58
var zone_end: float = 0.82
var is_running: bool = false
var cat_anim: AnimatedSprite2D = null

func _ready() -> void:
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(func(): emit_signal("back_requested"))
	btn_qte_action.pressed.connect(_on_action_pressed)
	btn_restart.pressed.connect(_restart_qte)
	btn_restart.visible = false
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
	target_speed = data.get("target_speed", 0.6)
	zone_start = data.get("zone_start", 0.58)
	zone_end = data.get("zone_end", 0.82)
	
	title_lbl.text = "⏱️ " + data.get("title", "MÈO PHẢN XẠ NHANH")
	cat_speech.text = data.get("cat_prompt", "Chuẩn bị ngón tay canh bấm chuông đúng trạm nhé Sen!")
	stop_marker.text = "🏁 " + data.get("stop_name", "Trạm Dừng")
	
	if data.get("lesson_id", 1) == 3:
		vehicle_icon.text = "🏍️"
		btn_qte_action.text = "🏍️ BẬT XI-NHAN RẼ LỐI RA THỨ 3!"
	else:
		vehicle_icon.text = "🚌"
		btn_qte_action.text = "🔔 BẤM CHUÔNG KENG (CÁCH 100M)!"
		
	_setup_zones()
	_restart_qte()

func _setup_zones() -> void:
	await get_tree().process_frame
	var track_w = track_bar.size.x
	if track_w <= 0:
		track_w = 340.0
	var z_x = track_w * zone_start
	var z_w = track_w * (zone_end - zone_start)
	green_zone.position.x = z_x
	green_zone.size.x = z_w

func _restart_qte() -> void:
	progress = 0.0
	is_running = true
	btn_qte_action.disabled = false
	btn_restart.visible = false
	cat_speech.text = data.get("cat_prompt", "Xe đang chạy... Sẵn sàng canh đúng VÙNG XANH nhé!")

func _process(delta: float) -> void:
	if not is_running:
		return
		
	progress += delta * (target_speed * 0.4)
	if progress > 1.05:
		# Xe đã chạy quá trạm mà chưa bấm
		_on_missed_stop()
		return
		
	var track_w = track_bar.size.x
	vehicle_icon.position.x = track_w * progress - 16.0
	
	# Cập nhật hiển thị khoảng cách mô phỏng
	var dist_m = int((1.0 - progress) * 300)
	dist_m = max(dist_m, 0)
	if progress < zone_start:
		distance_lbl.text = "Khoảng cách trạm: %dm (Chưa tới vùng an toàn ⚠️)" % dist_m
		distance_lbl.add_theme_color_override("font_color", Color(0.65, 0.55, 0.45))
	elif progress <= zone_end:
		distance_lbl.text = "✨ VÙNG AN TOÀN: %dm (BẤM NGAY BÂY GIỜ!) ✨" % dist_m
		distance_lbl.add_theme_color_override("font_color", Color(0.15, 0.75, 0.35))
	else:
		distance_lbl.text = "Khoảng cách trạm: %dm (Sát trạm quá nguy hiểm! ⚠️)" % dist_m
		distance_lbl.add_theme_color_override("font_color", Color(0.85, 0.3, 0.2))

func _on_action_pressed() -> void:
	if not is_running:
		return
	is_running = false
	
	if progress < zone_start:
		# Bấm quá sớm
		SoundManager.play_fail()
		cat_speech.text = data.get("early_msg", "Chưa tới trạm đã bấm chuông rồi Sen ơi! Bác tài càu nhàu kìa!")
		btn_qte_action.disabled = true
		btn_restart.visible = true
	elif progress <= zone_end:
		# Hoàn hảo! Vùng xanh an toàn
		SoundManager.play_success()
		if cat_anim:
			cat_anim.play("jump")
			
		cat_speech.text = data.get("success_msg", "🔔 KENG KENG! Xuống trạm chuẩn xác 100%!")
		btn_qte_action.disabled = true
		btn_qte_action.text = "🎉 PHẢN XẠ HOÀN HẢO 10/10!"
		
		await get_tree().create_timer(1.2).timeout
		var sim_steps = data.get("sim_steps", [])
		emit_signal("minigame_completed", sim_steps)
	else:
		# Bấm quá muộn
		_on_missed_stop()

func _on_missed_stop() -> void:
	is_running = false
	SoundManager.play_fail()
	cat_speech.text = data.get("late_msg", "Xe phóng vèo qua trạm mất rồi! Mèo phải cuốc bộ mỏi chân!")
	btn_qte_action.disabled = true
	btn_restart.visible = true
