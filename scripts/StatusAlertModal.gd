extends Control

# StatusAlertModal.gd - Pop-up cảnh báo sức khỏe & tâm lý cho Mèo (Quá No, Quá Stress, v.v.)
# Thể hiện trực quan thay vì dòng chữ nối dài sau thanh phần trăm theo yêu cầu GDD

signal care_action_requested(action_type)

@onready var panel: PanelContainer = $CenterContainer/Panel
@onready var icon_label: Label = $CenterContainer/Panel/VBox/IconBox/IconLabel
@onready var title_label: Label = $CenterContainer/Panel/VBox/TitleLabel
@onready var stat_label: Label = $CenterContainer/Panel/VBox/StatLabel
@onready var desc_label: Label = $CenterContainer/Panel/VBox/DescBox/DescLabel
@onready var btn_action: Button = $CenterContainer/Panel/VBox/BtnAction
@onready var btn_close: Button = $CenterContainer/Panel/VBox/BtnClose

var current_alert_type: String = ""

func _ready() -> void:
	visible = false
	btn_close.pressed.connect(close)
	btn_action.pressed.connect(_on_action_pressed)

func open(alert_type: String = "too_full") -> void:
	current_alert_type = alert_type
	visible = true
	SoundManager.play_fail()
	
	match alert_type:
		"too_full", "overfed":
			icon_label.text = "🤢"
			title_label.text = "⚠️ CẢNH BÁO: MÈO QUÁ NO!"
			stat_label.text = "Độ No: 100/100 (No Căng Tròn Bụng)"
			stat_label.add_theme_color_override("font_color", Color(0.15, 0.65, 0.3))
			desc_label.text = "Boss Mèo đã no 100/100 rồi Sen ơi! Ăn quá nhiều lúc này sẽ bị khó tiêu, trào ngược và mệt mỏi. Hãy để Boss nghỉ ngơi hoặc đi dạo quanh phòng cho nhẹ bụng nhé!"
			btn_action.text = "🐾 Cho Boss Đi Dạo Tiêu Hóa"
			btn_action.visible = true
		"too_stressed", "stressed":
			icon_label.text = "😿"
			title_label.text = "⚠️ CẢNH BÁO: MÈO QUÁ STRESS!"
			stat_label.text = "Dũng Cảm: %d/100  ·  Tâm Trạng: %d/100" % [GameManager.courage, GameManager.mood]
			stat_label.add_theme_color_override("font_color", Color(0.85, 0.35, 0.1))
			desc_label.text = "Boss Mèo đang bị căng thẳng quá mức! Boss đang tự ti, sợ hãi và không muốn ra ngoài học kỹ năng sống. Hãy vuốt ve hoặc cho Boss chơi đồ chơi để giải tỏa stress ngay nhé!"
			btn_action.text = "💖 Vuốt Ve An Ủi Boss (+15 Mood)"
			btn_action.visible = true
		"fainted", "starving":
			icon_label.text = "😵"
			title_label.text = "🚨 CẢNH BÁO: MÈO HẠ ĐƯỜNG HUYẾT!"
			stat_label.text = "Độ No: 0/100 (Xỉu Vì Đói Lả)"
			stat_label.add_theme_color_override("font_color", Color(0.9, 0.15, 0.15))
			desc_label.text = "Mèo đã đói lả đến mức ngất xỉu rồi! Cần nạp năng lượng ngay lập tức để Boss tỉnh lại!"
			btn_action.text = "🥣 Cho Ăn Hạt Cấp Cứu (+15 No)"
			btn_action.visible = true
		_:
			icon_label.text = "🐾"
			title_label.text = "✨ THÔNG TIN SỨC KHỎE BOSS"
			stat_label.text = "No: %d/100 · Dũng: %d/100 · Mood: %d/100" % [GameManager.hunger, GameManager.courage, GameManager.mood]
			stat_label.add_theme_color_override("font_color", Color(0.35, 0.25, 0.18))
			desc_label.text = "Boss Mèo đang sinh hoạt bình thường. Duy trì các chỉ số trên mức 25 để mèo luôn hoạt bát và sẵn sàng học hỏi kỹ năng mới nhé Sen!"
			btn_action.visible = false

	# Hiệu ứng nảy popup mượt mà
	panel.scale = Vector2(0.85, 0.85)
	var tween = create_tween()
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func close() -> void:
	SoundManager.play_click()
	visible = false

func _on_action_pressed() -> void:
	match current_alert_type:
		"too_full", "overfed":
			GameManager.emit_signal("show_toast", "🐾 Mèo thong thả đi dạo quanh phòng tiêu hóa thức ăn!")
			emit_signal("care_action_requested", "walk")
		"too_stressed", "stressed":
			GameManager.update_stats(0, 0, +5, +15)
			SoundManager.play_purr()
			GameManager.emit_signal("show_toast", "💖 Sen đã vuốt ve vỗ về: +5 Dũng Cảm | +15 Tâm Trạng!")
			emit_signal("care_action_requested", "pet")
		"fainted", "starving":
			GameManager.feed_kibble()
			SoundManager.play_chomp()
			emit_signal("care_action_requested", "feed")
	close()
