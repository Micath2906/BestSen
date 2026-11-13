extends TextureButton
class_name JuicyButton

## JuicyButton.gd - Nút TextureButton có phản hồi xúc giác vi mô (micro-juice):
## - button_down: thu nhỏ 0.92x trong 0.06s.
## - button_up: bật nảy 1.05x rồi hồi về 1.0x trong 0.12s kèm tiếng click gỗ ấm.

@export var play_wood_sfx: bool = true

var _juice_tween: Tween = null

func _ready() -> void:
	pivot_offset = size * 0.5
	resized.connect(func(): pivot_offset = size * 0.5)
	button_down.connect(_on_juice_down)
	button_up.connect(_on_juice_up)

func _on_juice_down() -> void:
	pivot_offset = size * 0.5
	if _juice_tween and _juice_tween.is_valid():
		_juice_tween.kill()
	_juice_tween = create_tween()
	_juice_tween.tween_property(self, "scale", Vector2(0.92, 0.92), 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_juice_up() -> void:
	pivot_offset = size * 0.5
	if _juice_tween and _juice_tween.is_valid():
		_juice_tween.kill()
	_juice_tween = create_tween()
	_juice_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.06).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_juice_tween.tween_property(self, "scale", Vector2.ONE, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if play_wood_sfx:
		var sm := get_node_or_null("/root/SoundManager")
		if sm and sm.has_method("play_wooden_pop"):
			sm.play_wooden_pop()

## Gắn hiệu ứng JuicyButton cho bất kỳ BaseButton nào hiện có (giữ nguyên node type trong .tscn).
static func attach_juice(btn: BaseButton, with_wood_sfx: bool = true) -> void:
	if not is_instance_valid(btn) or btn.has_meta("_juicy_attached"):
		return
	btn.set_meta("_juicy_attached", true)
	btn.pivot_offset = btn.size * 0.5
	btn.resized.connect(func():
		if is_instance_valid(btn):
			btn.pivot_offset = btn.size * 0.5
	)
	btn.button_down.connect(func():
		if not is_instance_valid(btn) or btn.disabled:
			return
		btn.pivot_offset = btn.size * 0.5
		var tw := btn.create_tween()
		tw.tween_property(btn, "scale", Vector2(0.92, 0.92), 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	btn.button_up.connect(func():
		if not is_instance_valid(btn) or btn.disabled:
			return
		btn.pivot_offset = btn.size * 0.5
		var tw := btn.create_tween()
		tw.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.06).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(btn, "scale", Vector2.ONE, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		if with_wood_sfx:
			var sm := btn.get_node_or_null("/root/SoundManager")
			if sm and sm.has_method("play_wooden_pop"):
				sm.play_wooden_pop()
	)
