extends Control

# BudgetMiniGame.gd - Gameplay "Giữ Thăng Bằng Cân Đối 3 Hũ Tiền" (Balancing Scale / Budget Allocator)
# Người chơi phân bổ 90 Cá Khô vào 3 hũ Sống còn (50%), Phát triển (30%), Khẩn cấp (20%)

signal minigame_completed(sim_steps)
signal back_requested

@onready var title_lbl: Label = $Header/HeaderTitle
@onready var btn_back: Button = $Header/BtnBack
@onready var cat_speech: Label = $CatSection/HBox/CatSpeech
@onready var cat_anchor: Control = $CatSection/HBox/CatAnchor

@onready var lbl_remaining_fish: Label = $BalanceCard/VBox/StatusRow/RemainingFishLabel
@onready var scale_needle: Control = $BalanceCard/VBox/ScaleContainer/NeedleAnchor
@onready var balance_status_lbl: Label = $BalanceCard/VBox/ScaleContainer/BalanceStatusLabel

@onready var slider_survive: HSlider = $JarsCard/VBox/SurviveBox/HBox/SliderSurvive
@onready var lbl_survive_val: Label = $JarsCard/VBox/SurviveBox/HBox/ValSurvive
@onready var slider_growth: HSlider = $JarsCard/VBox/GrowthBox/HBox/SliderGrowth
@onready var lbl_growth_val: Label = $JarsCard/VBox/GrowthBox/HBox/ValGrowth
@onready var slider_emergency: HSlider = $JarsCard/VBox/EmergencyBox/HBox/SliderEmergency
@onready var lbl_emergency_val: Label = $JarsCard/VBox/EmergencyBox/HBox/ValEmergency

@onready var btn_check_balance: Button = $ActionFooter/BtnCheckBalance
@onready var btn_preset_gold: Button = $ActionFooter/BtnPresetGold

var data: Dictionary = {}
var total_budget: int = 90
var val_survive: int = 30
var val_growth: int = 30
var val_emergency: int = 30
var cat_anim: AnimatedSprite2D = null

func _ready() -> void:
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(func(): emit_signal("back_requested"))
	btn_check_balance.pressed.connect(_on_check_balance_pressed)
	if btn_preset_gold:
		btn_preset_gold.pressed.connect(_apply_gold_preset)
		
	slider_survive.value_changed.connect(func(v): _on_slider_changed("survive", int(v)))
	slider_growth.value_changed.connect(func(v): _on_slider_changed("growth", int(v)))
	slider_emergency.value_changed.connect(func(v): _on_slider_changed("emergency", int(v)))
	
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
	total_budget = data.get("total_budget", 90)
	
	title_lbl.text = "⚖️ " + data.get("title", "CÂN BẰNG 3 HŨ TIỀN")
	cat_speech.text = data.get("cat_prompt", "Phân bổ cá vào 3 hũ theo tỷ lệ vàng giúp Boss nhé!")
	
	# Khởi đầu phân bổ đều
	val_survive = int(total_budget * 0.33)
	val_growth = int(total_budget * 0.33)
	val_emergency = total_budget - val_survive - val_growth
	
	slider_survive.max_value = total_budget
	slider_growth.max_value = total_budget
	slider_emergency.max_value = total_budget
	
	_update_sliders_ui()
	_update_scale_visual()

func _on_slider_changed(jar_key: String, new_val: int) -> void:
	match jar_key:
		"survive": val_survive = new_val
		"growth": val_growth = new_val
		"emergency": val_emergency = new_val
		
	_update_sliders_ui()
	_update_scale_visual()

func _update_sliders_ui() -> void:
	slider_survive.value = val_survive
	lbl_survive_val.text = "%d 🐟" % val_survive
	
	slider_growth.value = val_growth
	lbl_growth_val.text = "%d 🐟" % val_growth
	
	slider_emergency.value = val_emergency
	lbl_emergency_val.text = "%d 🐟" % val_emergency
	
	var total_allocated = val_survive + val_growth + val_emergency
	var diff = total_budget - total_allocated
	if diff == 0:
		lbl_remaining_fish.text = "Tổng: %d/%d 🐟 (Đã chia đủ 100%%) ✨" % [total_allocated, total_budget]
		lbl_remaining_fish.add_theme_color_override("font_color", Color(0.2, 0.7, 0.35))
	elif diff > 0:
		lbl_remaining_fish.text = "Còn dư chưa chia: %d 🐟" % diff
		lbl_remaining_fish.add_theme_color_override("font_color", Color(0.85, 0.45, 0.1))
	else:
		lbl_remaining_fish.text = "Vượt quá ngân sách: +%d 🐟! Giảm bớt lại!" % abs(diff)
		lbl_remaining_fish.add_theme_color_override("font_color", Color(0.85, 0.2, 0.2))

func _update_scale_visual() -> void:
	var target_jars = data.get("target_jars", {})
	var t_surv = target_jars.get("survive", {}).get("target", 45)
	var t_grow = target_jars.get("growth", {}).get("target", 27)
	var t_emg = target_jars.get("emergency", {}).get("target", 18)
	
	# Tính độ lệch cán cân
	# Nghiêng sang trái (thiếu sống còn) hoặc nghiêng sang phải (ăn chơi quá đà)
	var surv_dev = float(val_survive - t_surv) / float(total_budget)
	var grow_dev = float(val_growth - t_grow) / float(total_budget)
	var emg_dev = float(val_emergency - t_emg) / float(total_budget)
	
	var tilt = (grow_dev - surv_dev * 0.5 - emg_dev * 0.5) * 1.5
	tilt = clamp(tilt, -0.6, 0.6)
	
	var tw = create_tween()
	tw.tween_property(scale_needle, "rotation", tilt, 0.15)
	
	var is_balanced = _is_balanced_state()
	if is_balanced:
		balance_status_lbl.text = "✨ CÁN CÂN THĂNG BẰNG AN TOÀN ✨"
		balance_status_lbl.add_theme_color_override("font_color", Color(0.2, 0.72, 0.35))
		btn_check_balance.disabled = false
	else:
		if tilt > 0.2:
			balance_status_lbl.text = "⚠️ LỆCH: Dồn quá nhiều tiền vào mua sắm/chơi bời!"
			balance_status_lbl.add_theme_color_override("font_color", Color(0.85, 0.4, 0.1))
		elif tilt < -0.2:
			balance_status_lbl.text = "⚠️ LỆCH: Cắt xén quá mức tiền sống còn & trọ!"
			balance_status_lbl.add_theme_color_override("font_color", Color(0.85, 0.4, 0.1))
		else:
			balance_status_lbl.text = "⏳ Chưa đạt tỷ lệ vàng 50% - 30% - 20%"
			balance_status_lbl.add_theme_color_override("font_color", Color(0.6, 0.5, 0.4))
		btn_check_balance.disabled = false

func _is_balanced_state() -> bool:
	var total_allocated = val_survive + val_growth + val_emergency
	if total_allocated != total_budget:
		return false
		
	var target_jars = data.get("target_jars", {})
	var s_min = target_jars.get("survive", {}).get("min", 43)
	var s_max = target_jars.get("survive", {}).get("max", 47)
	var g_min = target_jars.get("growth", {}).get("min", 25)
	var g_max = target_jars.get("growth", {}).get("max", 29)
	var e_min = target_jars.get("emergency", {}).get("min", 16)
	var e_max = target_jars.get("emergency", {}).get("max", 20)
	
	return (val_survive >= s_min and val_survive <= s_max and
			val_growth >= g_min and val_growth <= g_max and
			val_emergency >= e_min and val_emergency <= e_max)

func _apply_gold_preset() -> void:
	SoundManager.play_click()
	var target_jars = data.get("target_jars", {})
	val_survive = target_jars.get("survive", {}).get("target", 45)
	val_growth = target_jars.get("growth", {}).get("target", 27)
	val_emergency = target_jars.get("emergency", {}).get("target", 18)
	_update_sliders_ui()
	_update_scale_visual()
	cat_speech.text = "Đã chỉnh về tỷ lệ vàng 50% - 30% - 20%! Bấm kiểm tra ngay nào Sen! ✨"

func _on_check_balance_pressed() -> void:
	var total_allocated = val_survive + val_growth + val_emergency
	if total_allocated != total_budget:
		SoundManager.play_fail()
		var diff = total_budget - total_allocated
		if diff > 0:
			cat_speech.text = "Chưa chia hết cá kìa Sen! Còn %d con cá chưa vào hũ!" % diff
		else:
			cat_speech.text = "Chia vượt ngân sách %d cá rồi! Rút bớt lại nhé!" % abs(diff)
		return
		
	if not _is_balanced_state():
		SoundManager.play_fail()
		if val_survive < 40:
			cat_speech.text = "ÚI ĐÓI QUÁ! 😵 " + data.get("danger_low_survive", "Thiếu tiền ăn ở rồi!")
		elif val_emergency < 10:
			cat_speech.text = "RỦI RO QUÁ! ⚠️ " + data.get("danger_low_emergency", "Không có tiền cấp cứu!")
		else:
			cat_speech.text = "CÁN CÂN SỤP ĐỔ! 💥 " + data.get("danger_over_growth", "Dồn tiền ăn chơi quá mức!")
	else:
		SoundManager.play_success()
		if cat_anim:
			cat_anim.play("jump")
		cat_speech.text = data.get("success_msg", "⚖️ CÁN CÂN THĂNG BẰNG HOÀN HẢO! Boss an tâm ăn no cả tháng! ✨")
		btn_check_balance.disabled = true
		btn_check_balance.text = "🎉 THĂNG BẰNG XUẤT SẮC 10/10!"
		
		await get_tree().create_timer(1.2).timeout
		var sim_steps = data.get("sim_steps", [])
		emit_signal("minigame_completed", sim_steps)
