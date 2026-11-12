extends Control
class_name CozyDialogBox

# CozyDialogBox.gd - UI-03 Khung Hộp Thoại Giảng Dạy & Phản Hồi Tích Cực (Zero Lecture)
# Hỗ trợ Unicode tiếng Việt UTF-8, viền 1px #3d251e, typewriter 0.03s/ký tự,
# chạm màn hình để hiện tức thì, 9-patch tự co giãn và đuôi bong bóng trỏ đúng miệng mèo.

signal dialog_finished(dialog_id: String)
signal chunk_advanced(chunk_index: int)

const TYPE_CHAR_INTERVAL: float = 0.03
const MAX_CHUNK_CHARS: int = 60
const FONT_PIXEL = preload("res://assets/font/SVN-Retron 2000.ttf")
const SLEEP_BROWN_TEX = preload("res://assets/UI/CatUIPaid/slices/dialog_cat_sleep_brown.png")
const SLEEP_PINK_TEX = preload("res://assets/UI/CatUIPaid/slices/dialog_cat_sleep_pink.png")

const EMOTION_AVATARS = {
	"happy": "res://assets/sprites/avatars/avatar_1.png",
	"surprised": "res://assets/sprites/avatars/avatar_6.png",
	"curious": "res://assets/sprites/avatars/avatar_2.png",
	"thoughtful": "res://assets/sprites/avatars/avatar_3.png",
	"sad": "res://assets/sprites/avatars/avatar_5.png",
	"playful": "res://assets/sprites/avatars/avatar_9.png",
	"hungry": "res://assets/sprites/avatars/avatar_0.png"
}

@onready var sleep_decor: TextureRect = $SleepDecor
@onready var bubble_panel: NinePatchRect = $BubblePanel
@onready var tail_rect: TextureRect = $BubbleTail
@onready var portrait_rect: TextureRect = $BubblePanel/Margin/HBox/EmotionPortrait
@onready var dialog_label: Label = $BubblePanel/Margin/HBox/TextCol/DialogLabel
@onready var tip_label: Label = $BubblePanel/Margin/HBox/TextCol/TipLabel

var _chunks: Array[String] = []
var _chunk_idx: int = 0
var _current_dialog_id: String = ""
var _current_tip: String = ""
var _target_mouth_offset_x: float = 0.0
var _is_typing: bool = false
var _type_elapsed: float = 0.0
var _total_chars: int = 0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if dialog_label:
		dialog_label.add_theme_font_override("font", FONT_PIXEL)
		dialog_label.add_theme_color_override("font_outline_color", Color("#3d251e"))
		dialog_label.add_theme_constant_override("outline_size", 1)
	if tip_label:
		tip_label.visible = false
	_align_tail_to_mouth()

func _process(delta: float) -> void:
	if not _is_typing or not dialog_label:
		return
	_type_elapsed += delta
	var chars_to_show: int = int(_type_elapsed / TYPE_CHAR_INTERVAL)
	if chars_to_show >= _total_chars:
		_finish_typing_current_chunk()
	else:
		dialog_label.visible_characters = chars_to_show

func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		handle_tap()
		accept_event()
	elif event is InputEventScreenTouch and event.pressed:
		handle_tap()
		accept_event()

static func split_cozy_chunks(raw_text: String, max_chars: int = MAX_CHUNK_CHARS) -> Array[String]:
	var clean := raw_text.strip_edges()
	var result: Array[String] = []
	if clean.is_empty():
		return [""]
	if clean.length() <= max_chars:
		result.append(clean)
		return result
	var words := clean.split(" ", false)
	var current := ""
	for w in words:
		var candidate := w if current.is_empty() else (current + " " + w)
		if candidate.length() <= max_chars:
			current = candidate
		else:
			if not current.is_empty():
				result.append(current)
			current = w.substr(0, max_chars) if w.length() > max_chars else w
	if not current.is_empty():
		result.append(current)
	return result

func show_dialog_by_id(dialog_id: String, mouth_offset_x: float = 0.0, show_tip_note: bool = false) -> bool:
	var data: Dictionary = GameManager.get_cozy_dialog(dialog_id)
	if data.is_empty():
		return false
	show_dialog(
		str(data.get("text", "")),
		str(data.get("cat_emotion", "happy")),
		str(data.get("pedagogical_tip", "")) if show_tip_note else "",
		mouth_offset_x,
		dialog_id
	)
	return true

func show_dialog(text: String, emotion: String = "happy", pedagogical_tip: String = "", mouth_offset_x: float = 0.0, dialog_id: String = "") -> void:
	_current_dialog_id = dialog_id
	_current_tip = pedagogical_tip.strip_edges()
	_target_mouth_offset_x = mouth_offset_x
	_chunks = split_cozy_chunks(text, MAX_CHUNK_CHARS)
	_chunk_idx = 0
	visible = true
	modulate.a = 1.0
	_apply_emotion_visuals(emotion)
	if tip_label:
		tip_label.visible = not _current_tip.is_empty()
		tip_label.text = "💡 " + _current_tip if not _current_tip.is_empty() else ""
	_play_chunk(0)
	_pop_in_tween()

func handle_tap() -> void:
	if _is_typing:
		_finish_typing_current_chunk()
		return
	if _chunk_idx + 1 < _chunks.size():
		_chunk_idx += 1
		_play_chunk(_chunk_idx)
		emit_signal("chunk_advanced", _chunk_idx)
	else:
		emit_signal("dialog_finished", _current_dialog_id)

func reveal_immediately() -> void:
	_finish_typing_current_chunk()

func _play_chunk(idx: int) -> void:
	var line_text := _chunks[idx]
	_total_chars = line_text.length()
	_type_elapsed = 0.0
	_is_typing = (_total_chars > 0)
	if dialog_label:
		dialog_label.text = line_text
		dialog_label.visible_characters = 0 if _is_typing else -1
	_resize_bubble_to_fit(line_text)
	_align_tail_to_mouth()

func _finish_typing_current_chunk() -> void:
	_is_typing = false
	if dialog_label:
		dialog_label.visible_characters = -1

func _apply_emotion_visuals(emotion: String) -> void:
	if portrait_rect:
		var path: String = EMOTION_AVATARS.get(emotion, EMOTION_AVATARS["happy"])
		var tex = GameManager.load_texture(path)
		if tex:
			portrait_rect.texture = tex
			portrait_rect.visible = true
	if sleep_decor:
		sleep_decor.texture = SLEEP_PINK_TEX if (emotion == "happy" or emotion == "playful") else SLEEP_BROWN_TEX

func _resize_bubble_to_fit(line_text: String) -> void:
	var text_len: int = line_text.length()
	var target_w: float = clampf(140.0 + float(mini(text_len, 42)) * 4.4, 210.0, 360.0)
	var est_lines: int = 2 if text_len > 30 else 1
	if not _current_tip.is_empty():
		est_lines += 2
	var target_h: float = 54.0 + float(est_lines - 1) * 18.0
	custom_minimum_size = Vector2(target_w, target_h + 12.0)
	size = custom_minimum_size
	if bubble_panel:
		bubble_panel.size = Vector2(target_w, target_h)

func set_cat_mouth_offset_x(offset_x: float) -> void:
	_target_mouth_offset_x = offset_x
	_align_tail_to_mouth()

func _align_tail_to_mouth() -> void:
	if not tail_rect or not bubble_panel:
		return
	var bubble_w: float = maxf(bubble_panel.size.x, custom_minimum_size.x)
	var bubble_h: float = maxf(bubble_panel.size.y, 48.0)
	var desired_x: float = (bubble_w * 0.5) + _target_mouth_offset_x - (tail_rect.size.x * 0.5)
	tail_rect.position.x = clampf(desired_x, 16.0, bubble_w - 28.0)
	tail_rect.position.y = bubble_h - 3.0

func _pop_in_tween() -> void:
	scale = Vector2(0.90, 0.90)
	pivot_offset = Vector2(size.x * 0.5, size.y)
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2.ONE, 0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
