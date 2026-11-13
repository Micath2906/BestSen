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

# GP-ED-03 & Task 5: Tủ Gỗ 3 Ngăn + DraggableItem Cá Khô + Flash Sale Trà Sữa + Safe Failure
const DraggableItemScript = preload("res://scripts/minigames/DraggableItem.gd")
const JuicyButtonScript = preload("res://scripts/ui/JuicyButton.gd")
const TEX_CHEST_SHELF: Texture2D = preload("res://assets/UI/CatUIPaid/slices/cozy_dress/vintage_chest_shelf_9patch.tres")
const TEX_ESSENTIAL_BOWL: Texture2D = preload("res://assets/UI/CatUIPaid/slices/toffee_hud/icon_food_bowl_16x16.tres")
const TEX_WANTS_YARN: Texture2D = preload("res://assets/UI/CatUIPaid/slices/icon_toy_yarn_ball.png")
const TEX_MONEY_BAG: Texture2D = preload("res://assets/UI/CatUIPaid/slices/pixel_atlas_icons/icon_money_bag.tres")
const TEX_WAX_SEAL: Texture2D = preload("res://assets/UI/CatUIPaid/slices/cozy_achievements/wax_seal_royal_gold.tres")
const TEX_EMPTY_BOWL: Texture2D = preload("res://assets/UI/PetMobileGameAsset/PetMobileGameAsset/Bunnies/BunnyStuffs/FoodBowlEmpty.png")
const TEX_HUNGRY_CAT: Texture2D = preload("res://assets/UI/CatUIPaid/slices/cat_sleep_grey.png")
const COZY_DIALOG_SCN: PackedScene = preload("res://scenes/ui/CozyDialogBox.tscn")

@onready var jars_card: PanelContainer = $JarsCard
@onready var jars_vbox: VBoxContainer = $JarsCard/VBox
@onready var balance_status_row: HBoxContainer = $BalanceCard/VBox/StatusRow
@onready var survive_box: VBoxContainer = $JarsCard/VBox/SurviveBox
@onready var growth_box: VBoxContainer = $JarsCard/VBox/GrowthBox
@onready var emergency_box: VBoxContainer = $JarsCard/VBox/EmergencyBox

var data: Dictionary = {}
var total_budget: int = 90
var val_survive: int = 30
var val_growth: int = 30
var val_emergency: int = 30
var cat_anim: AnimatedSprite2D = null

var displayed_total: float = 90.0
var is_essentials_sealed: bool = false
var safe_failure_count: int = 0
var wax_seal_stamp: TextureRect = null
var bill_drawer_tray: HBoxContainer = null
var bill_chip_buttons: Array[Button] = []
var drag_bills_row: HBoxContainer = null
var drag_bill_items: Array[Control] = []
var jar_target_bars: Dictionary = {}
var flash_sale_bubble: Button = null
var flash_sale_timer: float = 0.0
var flash_sale_triggered: bool = false
var flash_sale_tempted_count: int = 0
var is_victory_transitioning: bool = false
var safe_fail_preview: PanelContainer = null
var empty_bowl_icon: TextureRect = null
var sleepy_cat_preview: TextureRect = null
var budget_cozy_dialog: Control = null

func _ready() -> void:
	btn_back.icon = preload("res://assets/UI/CatUIPaid/slices/icon_arrow_left.png")
	btn_back.pressed.connect(func(): emit_signal("back_requested"))
	btn_check_balance.pressed.connect(_on_check_balance_pressed)
	JuicyButtonScript.attach_juice(btn_check_balance, true)
	if btn_preset_gold:
		btn_preset_gold.pressed.connect(_apply_gold_preset)
		JuicyButtonScript.attach_juice(btn_preset_gold, true)
		
	slider_survive.value_changed.connect(func(v): _on_slider_changed("survive", int(v)))
	slider_growth.value_changed.connect(func(v): _on_slider_changed("growth", int(v)))
	slider_emergency.value_changed.connect(func(v): _on_slider_changed("emergency", int(v)))
	
	_setup_cat_mascot()
	_setup_gp_ed_03_ui()

func _process(delta: float) -> void:
	var target_total: float = float(val_survive + val_growth + val_emergency)
	if absf(displayed_total - target_total) > 0.05:
		displayed_total = lerpf(displayed_total, target_total, minf(1.0, delta * 12.0))
		_refresh_remaining_label_text(int(round(displayed_total)))
	elif absf(displayed_total - target_total) > 0.001:
		displayed_total = target_total
		_refresh_remaining_label_text(int(target_total))

	if not flash_sale_triggered and not is_victory_transitioning:
		flash_sale_timer += delta
		if flash_sale_timer >= 8.0:
			trigger_flash_sale_temptation()

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
	safe_failure_count = 0
	is_essentials_sealed = false
	flash_sale_timer = 0.0
	flash_sale_triggered = false
	flash_sale_tempted_count = 0
	is_victory_transitioning = false
	if btn_check_balance:
		btn_check_balance.disabled = false
		btn_check_balance.text = "⚖️ KIỂM TRA CÂN ĐỐI"
	if safe_fail_preview:
		safe_fail_preview.visible = false
	if budget_cozy_dialog:
		budget_cozy_dialog.visible = false
	if flash_sale_bubble:
		flash_sale_bubble.visible = false
	
	title_lbl.text = "⚖️ " + data.get("title", "CÂN BẰNG 3 HŨ TIỀN")
	cat_speech.text = data.get("cat_prompt", "Phân bổ cá vào 3 hũ theo tỷ lệ vàng giúp Boss nhé!")
	
	# Khởi đầu phân bổ đều
	val_survive = int(total_budget * 0.33)
	val_growth = int(total_budget * 0.33)
	val_emergency = total_budget - val_survive - val_growth
	displayed_total = float(val_survive + val_growth + val_emergency)
	
	slider_survive.max_value = total_budget
	slider_growth.max_value = total_budget
	slider_emergency.max_value = total_budget
	
	_update_sliders_ui()
	_update_scale_visual()

func _on_slider_changed(jar_key: String, new_val: int) -> void:
	if safe_fail_preview and safe_fail_preview.visible:
		safe_fail_preview.visible = false
	match jar_key:
		"survive": val_survive = clampi(new_val, 0, total_budget)
		"growth": val_growth = clampi(new_val, 0, total_budget)
		"emergency": val_emergency = clampi(new_val, 0, total_budget)
		
	_update_sliders_ui()
	_update_scale_visual()

func _refresh_remaining_label_text(shown_total: int) -> void:
	var diff = total_budget - shown_total
	if diff == 0:
		lbl_remaining_fish.text = "Tổng: %d/%d 🐟 (Đã chia đủ 100%%) ✨" % [shown_total, total_budget]
		lbl_remaining_fish.add_theme_color_override("font_color", Color(0.2, 0.7, 0.35))
	elif diff > 0:
		lbl_remaining_fish.text = "Còn dư chưa chia: %d 🐟" % diff
		lbl_remaining_fish.add_theme_color_override("font_color", Color(0.85, 0.45, 0.1))
	else:
		lbl_remaining_fish.text = "Vượt quá ngân sách: +%d 🐟! Giảm bớt lại!" % abs(diff)
		lbl_remaining_fish.add_theme_color_override("font_color", Color(0.85, 0.2, 0.2))

func _update_sliders_ui() -> void:
	slider_survive.set_value_no_signal(val_survive)
	lbl_survive_val.text = "%d 🐟" % val_survive
	
	slider_growth.set_value_no_signal(val_growth)
	lbl_growth_val.text = "%d 🐟" % val_growth
	
	slider_emergency.set_value_no_signal(val_emergency)
	lbl_emergency_val.text = "%d 🐟" % val_emergency
	
	var total_allocated = val_survive + val_growth + val_emergency
	_refresh_remaining_label_text(total_allocated)
	_update_jar_target_gauges()
	_update_wax_seal_stamp()

func _update_wax_seal_stamp() -> void:
	var target_jars = data.get("target_jars", {})
	var s_min: int = int(target_jars.get("survive", {}).get("min", int(total_budget * 0.48)))
	var should_seal: bool = val_survive >= s_min and val_survive <= total_budget
	if should_seal != is_essentials_sealed:
		is_essentials_sealed = should_seal
		if wax_seal_stamp:
			wax_seal_stamp.visible = should_seal
			if should_seal:
				wax_seal_stamp.pivot_offset = wax_seal_stamp.size * 0.5
				wax_seal_stamp.scale = Vector2(1.6, 1.6)
				var tw := create_tween()
				tw.tween_property(wax_seal_stamp, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				SoundManager.play_wooden_pop()
				SoundManager.vibrate(30)

func _update_scale_visual() -> void:
	var target_jars = data.get("target_jars", {})
	var t_surv = target_jars.get("survive", {}).get("target", 45)
	var t_grow = target_jars.get("growth", {}).get("target", 27)
	var t_emg = target_jars.get("emergency", {}).get("target", 18)
	
	# Tính độ lệch cán cân
	var surv_dev = float(val_survive - t_surv) / float(maxi(1, total_budget))
	var grow_dev = float(val_growth - t_grow) / float(maxi(1, total_budget))
	var emg_dev = float(val_emergency - t_emg) / float(maxi(1, total_budget))
	
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

	if GameManager and GameManager.has_signal("minigame_hud_updated"):
		var t_ok: float = 1.0 if is_balanced else clampf(1.0 - absf(tilt), 0.1, 0.9)
		GameManager.minigame_hud_updated.emit(90.0, t_ok)

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
	if safe_fail_preview:
		safe_fail_preview.visible = false
	var target_jars = data.get("target_jars", {})
	val_survive = target_jars.get("survive", {}).get("target", 45)
	val_growth = target_jars.get("growth", {}).get("target", 27)
	val_emergency = target_jars.get("emergency", {}).get("target", 18)
	_update_sliders_ui()
	_update_scale_visual()
	cat_speech.text = "Đã chỉnh về tỷ lệ vàng 50% - 30% - 20%! Bấm kiểm tra ngay nào Sen! ✨"

func drop_bill_into_jar(jar_key: String, amount: int) -> void:
	if safe_fail_preview:
		safe_fail_preview.visible = false
	var room_left: int = maxi(0, total_budget - (val_survive + val_growth + val_emergency))
	var add_amt: int = clampi(amount, 0, total_budget)
	if add_amt > room_left:
		var need_trim: int = add_amt - room_left
		var keys_other: Array[String] = []
		for k in ["growth", "emergency", "survive"]:
			if k != jar_key:
				keys_other.append(k)
		for k in keys_other:
			if need_trim <= 0:
				break
			match k:
				"survive":
					var take := mini(need_trim, val_survive)
					val_survive -= take
					need_trim -= take
				"growth":
					var take := mini(need_trim, val_growth)
					val_growth -= take
					need_trim -= take
				"emergency":
					var take := mini(need_trim, val_emergency)
					val_emergency -= take
					need_trim -= take
	match jar_key:
		"survive": val_survive = clampi(val_survive + add_amt, 0, total_budget)
		"growth": val_growth = clampi(val_growth + add_amt, 0, total_budget)
		"emergency": val_emergency = clampi(val_emergency + add_amt, 0, total_budget)
	SoundManager.play_currency()
	SoundManager.vibrate(15)
	_update_sliders_ui()
	_update_scale_visual()

func _show_safe_failure_preview(headline: String, tip_text: String) -> void:
	safe_failure_count += 1
	SoundManager.play_fail()
	SoundManager.vibrate(15)
	if safe_fail_preview:
		safe_fail_preview.visible = true
		safe_fail_preview.modulate = Color(1, 1, 1, 0)
		var tw := create_tween()
		tw.tween_property(safe_fail_preview, "modulate", Color(1, 1, 1, 1), 0.2)
	if budget_cozy_dialog and is_instance_valid(budget_cozy_dialog) and budget_cozy_dialog.has_method("show_dialog"):
		budget_cozy_dialog.show_dialog(headline, "sad", tip_text)

func _on_check_balance_pressed() -> void:
	var total_allocated = val_survive + val_growth + val_emergency
	if total_allocated != total_budget:
		var diff = total_budget - total_allocated
		var msg := ""
		if diff > 0:
			msg = "Chưa chia hết cá kìa Sen! Còn %d con cá chưa vào hũ!" % diff
		else:
			msg = "Chia vượt ngân sách %d cá rồi! Rút bớt lại nhé!" % abs(diff)
		cat_speech.text = msg
		_show_safe_failure_preview("Ngân sách tháng chưa khớp %d Cá Khô nè!" % total_budget, "Hãy kéo thanh hoặc thả tờ tiền vào 3 ngăn tủ gỗ sao cho đủ 100% nhé.")
		return
		
	if not _is_balanced_state():
		if val_survive < 40:
			cat_speech.text = "Bát cơm của Mochi sắp trống rồi, ưu tiên phần Thiết Yếu trước nhé Sen!"
			_show_safe_failure_preview("Bát cơm của Mochi sắp trống rồi, ưu tiên phần Thiết Yếu trước nhé Sen!", "Phủ kín Tiền Trọ & Cơm Nước (50% Thiết Yếu) trước để nhận Con Dấu Sáp Vàng Hoàng Gia nhé.")
		elif val_emergency < 10:
			cat_speech.text = "RỦI RO QUÁ! ⚠️ " + data.get("danger_low_emergency", "Không có tiền cấp cứu!")
			_show_safe_failure_preview("Nguy hiểm! Quỹ Tiết Kiệm 20% đang gần như trống không!", "Hãy trích 20% vào ngăn Tiết Kiệm để luôn sẵn sàng khi ốm đau hoặc hư xe.")
		else:
			cat_speech.text = "CÁN CÂN SỤP ĐỔ! 💥 " + data.get("danger_over_growth", "Dồn tiền ăn chơi quá mức!")
			_show_safe_failure_preview("Cán cân bị lệch sang Mong Muốn mua sắm mất rồi!", "Giữ cân bằng 50% Thiết yếu - 30% Mong muốn - 20% Tiết kiệm nhé.")
	else:
		if is_victory_transitioning:
			return
		is_victory_transitioning = true
		if safe_fail_preview:
			safe_fail_preview.visible = false
		if flash_sale_bubble:
			flash_sale_bubble.visible = false
		SoundManager.play_success()
		SoundManager.vibrate(35)
		if cat_anim:
			cat_anim.play("jump")
		cat_speech.text = data.get("success_msg", "⚖️ CÁN CÂN THĂNG BẰNG HOÀN HẢO! Boss an tâm ăn no cả tháng! ✨")
		btn_check_balance.disabled = true
		btn_check_balance.text = "🎉 THĂNG BẰNG XUẤT SẮC 10/10!"
		
		await get_tree().create_timer(1.2).timeout
		var sim_steps = data.get("sim_steps", [])
		emit_signal("minigame_completed", sim_steps)

func _setup_gp_ed_03_ui() -> void:
	if scale_needle:
		scale_needle.pivot_offset = Vector2(0, 0)
	if jars_card and TEX_CHEST_SHELF:
		var chest_sb := StyleBoxTexture.new()
		chest_sb.texture = TEX_CHEST_SHELF
		chest_sb.texture_margin_left = 10.0
		chest_sb.texture_margin_top = 10.0
		chest_sb.texture_margin_right = 10.0
		chest_sb.texture_margin_bottom = 10.0
		chest_sb.content_margin_left = 14.0
		chest_sb.content_margin_top = 12.0
		chest_sb.content_margin_right = 14.0
		chest_sb.content_margin_bottom = 12.0
		jars_card.add_theme_stylebox_override("panel", chest_sb)

	if balance_status_row:
		wax_seal_stamp = TextureRect.new()
		wax_seal_stamp.name = "WaxSealStamp"
		wax_seal_stamp.texture = TEX_WAX_SEAL
		wax_seal_stamp.custom_minimum_size = Vector2(36, 36)
		wax_seal_stamp.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		wax_seal_stamp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		wax_seal_stamp.visible = false
		wax_seal_stamp.tooltip_text = "Con Dấu Sáp Vàng: Đã bảo chứng Tiền Trọ & Cơm Nước!"
		balance_status_row.add_child(wax_seal_stamp)

	if jars_vbox:
		jars_vbox.add_theme_constant_override("separation", 6)
		bill_drawer_tray = HBoxContainer.new()
		bill_drawer_tray.name = "BillDrawerTray"
		bill_drawer_tray.add_theme_constant_override("separation", 6)
		jars_vbox.add_child(bill_drawer_tray)
		jars_vbox.move_child(bill_drawer_tray, 0)

		var bill_defs := [
			{"id": "bill_rent", "label": "🏠 +15 Sống còn", "jar": "survive", "amt": 15},
			{"id": "bill_growth", "label": "📚 +10 Học tập", "jar": "growth", "amt": 10},
			{"id": "bill_emg", "label": "🔒 +5 Khẩn cấp", "jar": "emergency", "amt": 5}
		]
		for bd in bill_defs:
			var chip := Button.new()
			chip.name = bd["id"]
			chip.text = bd["label"]
			chip.icon = TEX_MONEY_BAG
			chip.expand_icon = true
			chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			chip.custom_minimum_size = Vector2(96, 34)
			chip.add_theme_font_size_override("font_size", 10)
			var jar_target: String = bd["jar"]
			var bill_amt: int = bd["amt"]
			chip.pressed.connect(func(): drop_bill_into_jar(jar_target, bill_amt))
			chip.set_drag_forwarding(
				func(_pos: Vector2):
					var p := TextureRect.new()
					p.texture = TEX_MONEY_BAG
					p.custom_minimum_size = Vector2(28, 28)
					chip.set_drag_preview(p)
					return {"type": "budget_bill", "amount": bill_amt, "default_jar": jar_target},
				func(_pos: Vector2, _d): return false,
				func(_pos: Vector2, _d): pass
			)
			bill_drawer_tray.add_child(chip)
			bill_chip_buttons.append(chip)
			JuicyButtonScript.attach_juice(chip, true)

	var drawer_map := {
		"survive": survive_box,
		"growth": growth_box,
		"emergency": emergency_box
	}
	var drawer_meta := {
		"survive": {"icon": TEX_ESSENTIAL_BOWL, "pct": 0.50, "lbl": "50% Thiết Yếu"},
		"growth": {"icon": TEX_WANTS_YARN, "pct": 0.30, "lbl": "30% Mong Muốn"},
		"emergency": {"icon": TEX_MONEY_BAG, "pct": 0.20, "lbl": "20% Tiết Kiệm"}
	}
	for jk in drawer_map.keys():
		var box: VBoxContainer = drawer_map[jk]
		if box:
			var key_copy: String = jk
			box.set_drag_forwarding(
				func(_pos: Vector2): return null,
				func(_pos: Vector2, d): return d is Dictionary and d.get("type", "") == "budget_bill",
				func(_pos: Vector2, d): drop_bill_into_jar(key_copy, int(d.get("amount", 10)))
			)
			# Target Marker Gauge + Icon cho từng ngăn tủ
			var meta: Dictionary = drawer_meta[jk]
			var meta_row := HBoxContainer.new()
			meta_row.add_theme_constant_override("separation", 6)
			box.add_child(meta_row)
			var cat_icon := TextureRect.new()
			cat_icon.texture = meta["icon"]
			cat_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			cat_icon.custom_minimum_size = Vector2(18, 18)
			cat_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			cat_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			meta_row.add_child(cat_icon)
			var gauge_wrap := Control.new()
			gauge_wrap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			gauge_wrap.custom_minimum_size = Vector2(100, 12)
			meta_row.add_child(gauge_wrap)
			var bar := ProgressBar.new()
			bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			bar.max_value = 100.0
			bar.show_percentage = false
			gauge_wrap.add_child(bar)
			var marker := ColorRect.new()
			marker.color = Color(0.95, 0.72, 0.15, 0.95)
			marker.size = Vector2(3, 12)
			marker.anchor_left = float(meta["pct"])
			marker.anchor_right = float(meta["pct"])
			marker.offset_left = -1.5
			marker.offset_right = 1.5
			marker.offset_top = 0.0
			marker.offset_bottom = 12.0
			gauge_wrap.add_child(marker)
			var badge_lbl := Label.new()
			badge_lbl.text = meta["lbl"]
			badge_lbl.add_theme_font_size_override("font_size", 10)
			badge_lbl.add_theme_color_override("font_color", Color(0.427, 0.298, 0.255, 1.0))
			meta_row.add_child(badge_lbl)
			jar_target_bars[jk] = bar

	# Vật phẩm tiền / cá khô DraggableItem chạm kéo thả trực tiếp vào 3 ngăn
	if jars_vbox:
		drag_bills_row = HBoxContainer.new()
		drag_bills_row.name = "DragBillsRow"
		drag_bills_row.add_theme_constant_override("separation", 8)
		jars_vbox.add_child(drag_bills_row)
		jars_vbox.move_child(drag_bills_row, 1)
		var drop_zones: Array = [survive_box, growth_box, emergency_box]
		for amt in [5, 10, 20]:
			var drag_bill := DraggableItemScript.new()
			drag_bill.name = "DragBill_%d" % amt
			drag_bill.custom_minimum_size = Vector2(88, 34)
			drag_bill.size = Vector2(88, 34)
			drag_bill.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			drag_bill.item_data = {"type": "budget_bill", "amount": amt}
			drag_bill.valid_drop_zones = drop_zones
			var pill := PanelContainer.new()
			pill.mouse_filter = Control.MOUSE_FILTER_IGNORE
			pill.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			var psb := StyleBoxFlat.new()
			psb.bg_color = Color(0.99, 0.96, 0.89, 1.0)
			psb.border_color = Color(0.427, 0.298, 0.255, 1.0)
			psb.set_border_width_all(2)
			psb.set_corner_radius_all(8)
			pill.add_theme_stylebox_override("panel", psb)
			drag_bill.add_child(pill)
			var ph := HBoxContainer.new()
			ph.mouse_filter = Control.MOUSE_FILTER_IGNORE
			ph.alignment = BoxContainer.ALIGNMENT_CENTER
			pill.add_child(ph)
			var ic := TextureRect.new()
			ic.texture = TEX_MONEY_BAG
			ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
			ic.custom_minimum_size = Vector2(18, 18)
			ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			ph.add_child(ic)
			var lb := Label.new()
			lb.text = "Kéo +%d 🐟" % amt
			lb.mouse_filter = Control.MOUSE_FILTER_IGNORE
			lb.add_theme_font_size_override("font_size", 10)
			lb.add_theme_color_override("font_color", Color(0.243, 0.153, 0.137, 1.0))
			ph.add_child(lb)
			var bill_amt: int = amt
			drag_bill.dropped_in_zone.connect(func(_it, zone):
				if zone == survive_box:
					drop_bill_into_jar("survive", bill_amt)
				elif zone == growth_box:
					drop_bill_into_jar("growth", bill_amt)
				elif zone == emergency_box:
					drop_bill_into_jar("emergency", bill_amt)
			)
			drag_bills_row.add_child(drag_bill)
			drag_bill_items.append(drag_bill)

	# Bong bóng cám dỗ Flash Sale 50% Trà Sữa
	flash_sale_bubble = Button.new()
	flash_sale_bubble.name = "FlashSaleBubble"
	flash_sale_bubble.text = "🧋 FLASH SALE 50% TRÀ SỮA! Chạm mua ngay!"
	flash_sale_bubble.visible = false
	flash_sale_bubble.z_index = 38
	flash_sale_bubble.custom_minimum_size = Vector2(280, 44)
	flash_sale_bubble.position = Vector2(36, 130)
	var fs_sb := StyleBoxFlat.new()
	fs_sb.bg_color = Color(1.0, 0.90, 0.92, 0.97)
	fs_sb.border_color = Color(0.85, 0.30, 0.42, 1.0)
	fs_sb.set_border_width_all(2)
	fs_sb.set_corner_radius_all(18)
	flash_sale_bubble.add_theme_stylebox_override("panel", fs_sb)
	flash_sale_bubble.add_theme_stylebox_override("normal", fs_sb)
	flash_sale_bubble.add_theme_color_override("font_color", Color(0.35, 0.10, 0.16, 1.0))
	flash_sale_bubble.pressed.connect(_on_flash_sale_temptation_clicked)
	add_child(flash_sale_bubble)
	JuicyButtonScript.attach_juice(flash_sale_bubble, true)

	safe_fail_preview = PanelContainer.new()
	safe_fail_preview.name = "BudgetSafeFailPreview"
	safe_fail_preview.visible = false
	safe_fail_preview.z_index = 35
	safe_fail_preview.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	safe_fail_preview.offset_left = 14
	safe_fail_preview.offset_right = -14
	safe_fail_preview.offset_top = -250
	safe_fail_preview.offset_bottom = -112
	var sf_style := StyleBoxFlat.new()
	sf_style.bg_color = Color(0.99, 0.95, 0.88, 0.97)
	sf_style.border_color = Color(0.68, 0.42, 0.28, 1.0)
	sf_style.set_border_width_all(2)
	sf_style.set_corner_radius_all(12)
	sf_style.content_margin_left = 10
	sf_style.content_margin_right = 10
	sf_style.content_margin_top = 8
	sf_style.content_margin_bottom = 8
	safe_fail_preview.add_theme_stylebox_override("panel", sf_style)
	safe_fail_preview.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			safe_fail_preview.visible = false
	)
	add_child(safe_fail_preview)

	var sf_hbox := HBoxContainer.new()
	sf_hbox.add_theme_constant_override("separation", 10)
	safe_fail_preview.add_child(sf_hbox)

	var visuals_col := VBoxContainer.new()
	visuals_col.alignment = BoxContainer.ALIGNMENT_CENTER
	sf_hbox.add_child(visuals_col)

	sleepy_cat_preview = TextureRect.new()
	sleepy_cat_preview.name = "SleepyCatPreview"
	sleepy_cat_preview.texture = TEX_HUNGRY_CAT
	sleepy_cat_preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sleepy_cat_preview.custom_minimum_size = Vector2(48, 48)
	sleepy_cat_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sleepy_cat_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	visuals_col.add_child(sleepy_cat_preview)

	empty_bowl_icon = TextureRect.new()
	empty_bowl_icon.name = "EmptyBowlIcon"
	empty_bowl_icon.texture = TEX_EMPTY_BOWL
	empty_bowl_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	empty_bowl_icon.custom_minimum_size = Vector2(48, 24)
	empty_bowl_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	empty_bowl_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	visuals_col.add_child(empty_bowl_icon)

	budget_cozy_dialog = COZY_DIALOG_SCN.instantiate()
	budget_cozy_dialog.name = "BudgetCozyDialog"
	budget_cozy_dialog.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sf_hbox.add_child(budget_cozy_dialog)

func _update_jar_target_gauges() -> void:
	var denom: float = maxf(1.0, float(total_budget))
	if jar_target_bars.has("survive"):
		(jar_target_bars["survive"] as ProgressBar).value = clampf((float(val_survive) / denom) * 100.0, 0.0, 100.0)
	if jar_target_bars.has("growth"):
		(jar_target_bars["growth"] as ProgressBar).value = clampf((float(val_growth) / denom) * 100.0, 0.0, 100.0)
	if jar_target_bars.has("emergency"):
		(jar_target_bars["emergency"] as ProgressBar).value = clampf((float(val_emergency) / denom) * 100.0, 0.0, 100.0)

func trigger_flash_sale_temptation() -> void:
	flash_sale_triggered = true
	if not flash_sale_bubble:
		return
	flash_sale_bubble.visible = true
	flash_sale_bubble.position = Vector2(20.0, 130.0)
	var tw := create_tween()
	tw.tween_property(flash_sale_bubble, "position:x", 56.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(flash_sale_bubble, "position:x", 24.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_flash_sale_temptation_clicked() -> void:
	flash_sale_tempted_count += 1
	var steal: int = mini(10, val_emergency)
	if steal <= 0:
		steal = mini(10, val_survive)
		val_survive -= steal
	else:
		val_emergency -= steal
	val_growth += steal
	if flash_sale_bubble:
		flash_sale_bubble.visible = false
	SoundManager.play_error_chime()
	SoundManager.play_meow(0.85)
	if cat_anim and cat_anim.sprite_frames:
		if cat_anim.sprite_frames.has_animation("hurt"):
			cat_anim.play("hurt")
		elif cat_anim.sprite_frames.has_animation("sleep"):
			cat_anim.play("sleep")
	cat_speech.text = "Ôi trà sữa nữa hả Sen? Hụt quỹ tiết kiệm rồi! 😿"
	_update_sliders_ui()
	_update_scale_visual()
	_show_safe_failure_preview("Cám dỗ Flash Sale 50% Trà Sữa!", "Tiền từ quỹ Tiết Kiệm vừa trôi sang ngăn Mong Muốn rồi! Điều chỉnh lại nhé Sen.")
