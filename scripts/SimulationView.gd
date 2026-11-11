extends Control

# SimulationView.gd - Giai đoạn 2 & 3: Thả Ra Ngoài Đời (Simulation & Safe Failure) và Phần Thưởng

signal retry_lesson_requested(lesson_id)
signal continue_to_room_requested

@onready var sim_title: Label = $Panel/SimTitle
@onready var step_desc_label: Label = $Panel/StepDescLabel
@onready var result_dialog: PanelContainer = $Panel/ResultDialog
@onready var result_title: Label = $Panel/ResultDialog/VBox/ResultTitle
@onready var result_body: Label = $Panel/ResultDialog/VBox/ResultBody
@onready var loot_panel: PanelContainer = $Panel/ResultDialog/VBox/LootPanel
@onready var loot_label: Label = $Panel/ResultDialog/VBox/LootPanel/LootLabel
@onready var cheat_sheet_label: Label = $Panel/ResultDialog/VBox/CheatSheetPanel/CheatSheetLabel
@onready var btn_action_primary: Button = $Panel/ResultDialog/VBox/HBoxBtns/BtnPrimary
@onready var btn_action_secondary: Button = $Panel/ResultDialog/VBox/HBoxBtns/BtnSecondary
@onready var cat_sim_sprite: Sprite2D = $Panel/CatSimAnchor/CatSimSprite
@onready var anim_timer: Timer = $SimTimer

var current_lesson_id: int = 1
var is_correct: bool = false
var user_sequence: Array = []
var lesson_data: Dictionary = {}
var current_step_index: int = 0
var sprite_frame: int = 0

func _ready() -> void:
	anim_timer.timeout.connect(_on_sim_timer)
	btn_action_primary.pressed.connect(_on_primary_pressed)
	btn_action_secondary.pressed.connect(_on_secondary_pressed)

func start_simulation(lesson_id: int, sequence: Array, correct: bool) -> void:
	current_lesson_id = lesson_id
	user_sequence = sequence
	is_correct = correct
	lesson_data = GameManager.lessons_data.get(lesson_id, {})
	
	sim_title.text = "🎬 ĐANG MÔ PHỎNG: %s" % lesson_data.get("title", "")
	result_dialog.visible = false
	current_step_index = 0
	
	anim_timer.start(0.2)
	_run_next_sim_step()

func _on_sim_timer() -> void:
	sprite_frame = (sprite_frame + 1) % 10
	cat_sim_sprite.frame = sprite_frame

func _run_next_sim_step() -> void:
	if current_step_index < user_sequence.size():
		var card = user_sequence[current_step_index]
		step_desc_label.text = "Mèo đang làm: %s %s..." % [card["icon"], card["text"]]
		SoundManager.play_meow(0.9 + current_step_index * 0.1)
		current_step_index += 1
		await get_tree().create_timer(1.2).timeout
		if is_inside_tree() and anim_timer.is_stopped() == false:
			_run_next_sim_step()
	else:
		_finish_simulation()

func _finish_simulation() -> void:
	anim_timer.stop()
	result_dialog.visible = true
	
	if is_correct:
		SoundManager.play_success()
		result_title.text = "🎉 THÀNH CÔNG RỰC RỠ!"
		result_title.add_theme_color_override("font_color", Color(0.1, 0.65, 0.2))
		result_body.text = lesson_data.get("success_msg", "")
		
		# Kích hoạt phần thưởng thu hoạch
		var res = GameManager.complete_lesson(current_lesson_id)
		loot_panel.visible = true
		loot_label.text = "🎁 CHIẾN LỢI PHẨM THU HOẠCH:\n• Nhận: %s\n• Thưởng nóng: +%s tiền thưởng! 💵" % [
			lesson_data.get("loot_name", ""),
			GameManager.format_currency(lesson_data.get("reward_fish", 30))
		]
		cheat_sheet_label.text = "📜 THẺ BẢO BỐI SINH TỒN ĐỜI THỰC:\n%s" % lesson_data.get("cheat_sheet", "")
		
		btn_action_primary.text = "🏠 Về Phòng Trọ Thưởng Boss"
		btn_action_secondary.text = "🗺️ Tiếp Tục Bản Đồ Kỹ Năng"
		step_desc_label.text = "✨ Boss hoàn thành trót lọt, tự tin bước đi giữa phố!"
	else:
		SoundManager.play_fail()
		GameManager.update_stats(0, -3, -10) # Safe failure: chỉ trừ nhẹ 10 dũng cảm
		result_title.text = "😅 THỬ SAI AN TOÀN - QUÊ ĐỘ!"
		result_title.add_theme_color_override("font_color", Color(0.85, 0.4, 0.1))
		result_body.text = "%s\n\n💡 KHÔNG SAO CẢ! Ở ngoài đời thực có thể tốn tiền hay hoảng sợ, nhưng ở đây Sen và Mèo được thử sai thoải mái. Đọc lại cẩm nang rồi thử lại nhé!" % lesson_data.get("fail_msg", "")
		
		loot_panel.visible = false
		cheat_sheet_label.text = "📜 GỢI Ý CỨU SEN:\nXem lại thứ tự các bước trong cẩm nang để tránh bị 'quê độ' lần nữa nha!"
		
		btn_action_primary.text = "🔄 Dạy Lại Bài Này Ngay"
		btn_action_secondary.text = "🏠 Về Phòng Trọ Vỗ Về Boss"
		step_desc_label.text = "😿 Mèo bối rối chạy về phòng trọ (-10 Dũng Cảm)..."

func _on_primary_pressed() -> void:
	SoundManager.play_click()
	if is_correct:
		emit_signal("continue_to_room_requested")
	else:
		emit_signal("retry_lesson_requested", current_lesson_id)

func _on_secondary_pressed() -> void:
	SoundManager.play_click()
	emit_signal("continue_to_room_requested")
