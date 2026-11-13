extends Control
class_name DraggableItem

## DraggableItem.gd - Vật phẩm kéo-thả tối ưu cho cảm ứng & chuột:
## - Mở rộng vùng nhận diện chạm +20% quanh hình ảnh thật.
## - Nâng z_index = 100, phóng to 1.12x và tạo bóng đổ khi nhấc lên.
## - Thả sai vùng sẽ bật đàn hồi (TRANS_ELASTIC) về home_position.
## - Khóa đa chạm (chỉ cho phép kéo 1 vật phẩm tại một thời điểm).

signal drag_started(item: DraggableItem)
signal drag_moved(item: DraggableItem, global_center: Vector2)
signal dropped_in_zone(item: DraggableItem, zone: Control)
signal dropped_outside(item: DraggableItem)
signal secondary_tap_rotate(item: DraggableItem)

@export var touch_padding_ratio: float = 0.20
@export var drag_scale: float = 1.12
@export var item_data: Dictionary = {}

var home_position: Vector2 = Vector2.ZERO
var valid_drop_zones: Array = []
var owner_minigame: Node = null
var is_dragging: bool = false
var drag_locked: bool = false

var _active_pointer_idx: int = -2 # -2 = idle, -1 = mouse, >=0 = touch finger
var _drag_offset: Vector2 = Vector2.ZERO
var _base_z_index: int = 0
var _active_tween: Tween = null
var _shadow_node: Panel = null
var _hit_expander: Control = null

static var _global_active_item_id: int = -1

func _ready() -> void:
	_base_z_index = z_index
	home_position = position
	pivot_offset = size * 0.5
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_sync_touch_hit_area)
	_ensure_shadow_and_hit_area()

func _exit_tree() -> void:
	if _global_active_item_id == get_instance_id():
		_global_active_item_id = -1

func _ensure_shadow_and_hit_area() -> void:
	if not is_instance_valid(_shadow_node):
		_shadow_node = Panel.new()
		_shadow_node.name = "DragShadow"
		_shadow_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_shadow_node.show_behind_parent = true
		_shadow_node.visible = false
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.18, 0.10, 0.05, 0.32)
		sb.set_corner_radius_all(12)
		_shadow_node.add_theme_stylebox_override("panel", sb)
		add_child(_shadow_node)

	if not is_instance_valid(_hit_expander):
		_hit_expander = Control.new()
		_hit_expander.name = "TouchHitMargin"
		_hit_expander.mouse_filter = Control.MOUSE_FILTER_PASS
		_hit_expander.gui_input.connect(_gui_input)
		add_child(_hit_expander)

	_sync_touch_hit_area()

func _sync_touch_hit_area() -> void:
	pivot_offset = size * 0.5
	if is_instance_valid(_shadow_node):
		_shadow_node.position = Vector2(4.0, 10.0)
		_shadow_node.size = size
	if is_instance_valid(_hit_expander):
		var pad_x := maxf(8.0, size.x * touch_padding_ratio)
		var pad_y := maxf(8.0, size.y * touch_padding_ratio)
		_hit_expander.position = Vector2(-pad_x, -pad_y)
		_hit_expander.size = size + Vector2(pad_x * 2.0, pad_y * 2.0)

## Kiểm tra điểm chạm có nằm trong hitbox mở rộng (+20%) không.
func is_point_in_touch_bounds(local_pt: Vector2) -> bool:
	var pad_x := maxf(8.0, size.x * touch_padding_ratio)
	var pad_y := maxf(8.0, size.y * touch_padding_ratio)
	var expanded := Rect2(Vector2(-pad_x, -pad_y), size + Vector2(pad_x * 2.0, pad_y * 2.0))
	return expanded.has_point(local_pt)

func set_home_position(pos: Vector2) -> void:
	home_position = pos
	if not is_dragging:
		position = pos

func _can_start_drag() -> bool:
	if drag_locked or is_dragging or not visible:
		return false
	if owner_minigame and owner_minigame.has_method("try_acquire_drag"):
		return owner_minigame.try_acquire_drag(get_instance_id())
	if _global_active_item_id != -1 and _global_active_item_id != get_instance_id():
		return false
	_global_active_item_id = get_instance_id()
	return true

func _release_drag_lock() -> void:
	if owner_minigame and owner_minigame.has_method("release_drag"):
		owner_minigame.release_drag(get_instance_id())
	if _global_active_item_id == get_instance_id():
		_global_active_item_id = -1

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if is_dragging and event.index != _active_pointer_idx:
				# Ngón tay thứ 2 chạm trong lúc đang kéo -> phát tín hiệu xoay 90°
				emit_signal("secondary_tap_rotate", self)
				accept_event()
				return
			if _can_start_drag():
				on_drag_start(event.index, event.position)
				accept_event()
		elif is_dragging and event.index == _active_pointer_idx:
			on_drag_end()
			accept_event()
	elif event is InputEventScreenDrag:
		if is_dragging and event.index == _active_pointer_idx:
			_move_by_delta(event.relative)
			accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _can_start_drag():
				on_drag_start(-1, event.position)
				accept_event()
		elif is_dragging and _active_pointer_idx == -1:
			on_drag_end()
			accept_event()
	elif event is InputEventMouseMotion and is_dragging and _active_pointer_idx == -1:
		_move_by_delta(event.relative)
		accept_event()

func _input(event: InputEvent) -> void:
	if not is_dragging:
		return
	if event is InputEventScreenTouch:
		if event.pressed and event.index != _active_pointer_idx:
			emit_signal("secondary_tap_rotate", self)
		elif not event.pressed and event.index == _active_pointer_idx:
			on_drag_end()
	elif event is InputEventScreenDrag and event.index == _active_pointer_idx:
		_move_by_delta(event.relative)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed and _active_pointer_idx == -1:
		on_drag_end()
	elif event is InputEventMouseMotion and _active_pointer_idx == -1:
		_move_by_delta(event.relative)

func _move_by_delta(delta_vec: Vector2) -> void:
	position += delta_vec
	emit_signal("drag_moved", self, global_position + size * 0.5)

func on_drag_start(pointer_idx: int = -1, local_grab: Vector2 = Vector2.ZERO) -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	is_dragging = true
	_active_pointer_idx = pointer_idx
	_drag_offset = local_grab
	_base_z_index = z_index
	z_index = 100
	pivot_offset = size * 0.5

	if is_instance_valid(_shadow_node):
		_shadow_node.visible = true

	var tw := create_tween()
	_active_tween = tw
	tw.tween_property(self, "scale", Vector2(drag_scale, drag_scale), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	var sm := get_node_or_null("/root/SoundManager")
	if sm and sm.has_method("vibrate_tap"):
		sm.vibrate_tap()
	emit_signal("drag_started", self)

func on_drag_end() -> void:
	if not is_dragging:
		return
	is_dragging = false
	_active_pointer_idx = -2
	_release_drag_lock()

	if is_instance_valid(_shadow_node):
		_shadow_node.visible = false

	var matched_zone := find_matching_drop_zone()
	if matched_zone:
		z_index = _base_z_index
		var tw := create_tween()
		_active_tween = tw
		tw.tween_property(self, "scale", Vector2.ONE, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		emit_signal("dropped_in_zone", self, matched_zone)
	else:
		snap_back_elastic()
		emit_signal("dropped_outside", self)

func find_matching_drop_zone() -> Control:
	var item_center := global_position + size * 0.5
	var candidates: Array = valid_drop_zones.duplicate()
	if candidates.is_empty() and is_inside_tree():
		for node in get_tree().get_nodes_in_group("DropZone"):
			if node is Control:
				candidates.append(node)
	for zone in candidates:
		if is_instance_valid(zone) and zone.visible and zone.get_global_rect().has_point(item_center):
			return zone
	return null

## Đưa vật phẩm bật đàn hồi mượt về vị trí ban đầu khi thả trượt vùng hợp lệ.
func snap_back_elastic() -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	z_index = _base_z_index
	var tw := create_tween().set_parallel(true)
	_active_tween = tw
	tw.tween_property(self, "position", home_position, 0.36).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
