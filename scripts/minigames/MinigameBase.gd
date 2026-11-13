extends Control
class_name MinigameBase

## MinigameBase.gd - Kiến trúc nền tảng Finite State Machine (FSM) & chống kẹt input cho toàn bộ Minigame.
## Luồng trạng thái chuẩn: INTRO -> PLAYING -> EVALUATING -> FEEDBACK -> COMPLETED.

signal minigame_completed(sim_steps)
signal back_requested
signal state_changed(old_state: int, new_state: int)

enum State {
	INTRO = 0,
	PLAYING = 1,
	EVALUATING = 2,
	FEEDBACK = 3,
	COMPLETED = 4
}

@export var intro_duration: float = 1.6
@export var soft_time_limit: float = 45.0
@export var use_soft_timer: bool = true

var current_state: State = State.INTRO
var is_transitioning: bool = false
var time_remaining: float = 45.0
var active_drag_id: int = -1
var safe_failure_count: int = 0
var data: Dictionary = {}

var _intro_overlay: PanelContainer = null
var _intro_label: Label = null
var _intro_tween: Tween = null

func _ready() -> void:
	time_remaining = soft_time_limit
	mouse_filter = Control.MOUSE_FILTER_PASS
	_on_minigame_ready()

func _on_minigame_ready() -> void:
	pass

func _process(delta: float) -> void:
	if current_state == State.PLAYING and not is_transitioning and use_soft_timer:
		time_remaining = maxf(0.0, time_remaining - delta)
		_emit_hud_progress()
		_on_playing_process(delta)

func _on_playing_process(_delta: float) -> void:
	pass

func _emit_hud_progress() -> void:
	var gm := get_node_or_null("/root/GameManager")
	if gm and gm.has_signal("minigame_hud_updated"):
		var pct: float = clampf(1.0 - (time_remaining / maxf(1.0, soft_time_limit)), 0.0, 1.0)
		gm.minigame_hud_updated.emit(time_remaining, pct)

## Kiểm tra quyền nhận input để tránh spam click / double-trigger khi đang chuyển pha.
func can_accept_input() -> bool:
	return current_state == State.PLAYING and not is_transitioning

## Khóa đa chạm: chỉ cho phép 1 DraggableItem hoạt động tại một thời điểm.
func try_acquire_drag(item_id: int) -> bool:
	if not can_accept_input():
		return false
	if active_drag_id != -1 and active_drag_id != item_id:
		return false
	active_drag_id = item_id
	return true

func release_drag(item_id: int) -> void:
	if active_drag_id == item_id:
		active_drag_id = -1

func release_all_drags() -> void:
	active_drag_id = -1

## Chuyển trạng thái an toàn với cờ is_transitioning.
func transition_to(new_state: State, delay_unlock: float = 0.0) -> bool:
	if is_transitioning and new_state == current_state:
		return false
	var prev_state := current_state
	is_transitioning = true
	current_state = new_state

	if new_state != State.PLAYING:
		release_all_drags()

	emit_signal("state_changed", prev_state, new_state)
	_on_state_entered(prev_state, new_state)

	if delay_unlock > 0.0 and is_inside_tree():
		await get_tree().create_timer(delay_unlock).timeout
		if not is_inside_tree():
			return true
	is_transitioning = false
	return true

func _on_state_entered(_old_state: State, _new_state: State) -> void:
	pass

## Khởi động minigame: chạy INTRO ngắn rồi tự chuyển sang PLAYING.
func begin_minigame_loop(intro_text: String = "", custom_intro_sec: float = -1.0) -> void:
	var wait_sec := intro_duration if custom_intro_sec < 0.0 else custom_intro_sec
	time_remaining = soft_time_limit
	current_state = State.INTRO
	is_transitioning = true
	release_all_drags()

	if intro_text != "" and wait_sec > 0.05:
		_show_intro_banner(intro_text, wait_sec)

	if wait_sec > 0.0 and is_inside_tree():
		await get_tree().create_timer(wait_sec).timeout
		if not is_inside_tree():
			return

	_hide_intro_banner()
	is_transitioning = false
	await transition_to(State.PLAYING)

func _show_intro_banner(intro_text: String, duration_sec: float) -> void:
	if not is_instance_valid(_intro_overlay):
		_intro_overlay = PanelContainer.new()
		_intro_overlay.name = "FSMIntroBanner"
		_intro_overlay.z_index = 90
		_intro_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_intro_overlay.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		_intro_overlay.custom_minimum_size = Vector2(340, 76)
		_intro_overlay.offset_left = -170
		_intro_overlay.offset_right = 170
		_intro_overlay.offset_top = -38
		_intro_overlay.offset_bottom = 38
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color("#FDF6E3")
		sb.border_color = Color("#6D4C41")
		sb.set_border_width_all(3)
		sb.set_corner_radius_all(12)
		sb.content_margin_left = 14
		sb.content_margin_right = 14
		sb.content_margin_top = 10
		sb.content_margin_bottom = 10
		_intro_overlay.add_theme_stylebox_override("panel", sb)

		_intro_label = Label.new()
		_intro_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_intro_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_intro_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_intro_label.add_theme_color_override("font_color", Color("#3E2723"))
		_intro_label.add_theme_font_size_override("font_size", 14)
		_intro_overlay.add_child(_intro_label)
		add_child(_intro_overlay)

	_intro_label.text = intro_text
	_intro_overlay.visible = true
	_intro_overlay.modulate.a = 0.0
	if _intro_tween and _intro_tween.is_valid():
		_intro_tween.kill()
	_intro_tween = create_tween()
	_intro_tween.tween_property(_intro_overlay, "modulate:a", 1.0, 0.16)
	_intro_tween.tween_interval(maxf(0.2, duration_sec - 0.34))
	_intro_tween.tween_property(_intro_overlay, "modulate:a", 0.0, 0.18)

func _hide_intro_banner() -> void:
	if is_instance_valid(_intro_overlay):
		_intro_overlay.visible = false

## Chạy pha FEEDBACK rồi tự quay về PLAYING (hoặc không khóa chết nếu Safe Failure).
func run_safe_feedback(resume_delay: float = 0.75) -> void:
	safe_failure_count += 1
	await transition_to(State.FEEDBACK, resume_delay)
	if is_inside_tree() and current_state == State.FEEDBACK:
		await transition_to(State.PLAYING)

## Kết thúc thắng màn chơi: chuyển EVALUATING -> COMPLETED và phát minigame_completed.
func complete_minigame(wait_before_emit: float = 1.0, sim_steps_override = null) -> void:
	if current_state == State.COMPLETED or is_transitioning:
		return
	await transition_to(State.EVALUATING)
	await transition_to(State.COMPLETED)
	if wait_before_emit > 0.0 and is_inside_tree():
		await get_tree().create_timer(wait_before_emit).timeout
		if not is_inside_tree():
			return
	var steps = sim_steps_override if sim_steps_override != null else data.get("sim_steps", [])
	emit_signal("minigame_completed", steps)
