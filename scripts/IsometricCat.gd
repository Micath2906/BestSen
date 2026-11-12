extends Node2D

# IsometricCat.gd - Chú Mèo 4 Chân Trong Không Gian 2.5D Isometric (Lưới Dimetric 8x8)
# Tích hợp bộ Sprite Free Pack với chuyển động 8 hướng chân thực và biểu cảm phong phú
# Tự do di chuyển 8 hướng, có bóng đổ động, tương tác đệm ngủ, khay ăn, cây cào móng, hộp carton

const IsometricGrid = preload("res://scripts/IsometricGrid.gd")
const CatAnimationFactory = preload("res://scripts/CatAnimationFactory.gd")

enum State {
	IDLE,
	WALK,
	SCRATCH,
	SLEEP,
	EAT,
	DRINK,
	BOX,
	CHASE_TOY,
	FAINT,
	SCARED,
	DRAGGED
}

@export var origin: Vector2 = Vector2(270.0, 436.0)

signal cat_touched(zone_name)
signal reached_destination(state)

@onready var anim_sprite: AnimatedSprite2D = $Visual/AnimSprite
@onready var cat_idle_sprite: Sprite2D = $Visual/CatIdleSprite
@onready var cat_box_sprite: Sprite2D = $Visual/CatBoxSprite
@onready var shadow_node: Sprite2D = $Shadow
@onready var cat_touch_zone: Control = $Visual/CatTouchZone
@onready var bubble: Control = $Bubble
@onready var bubble_tail: TextureRect = $Bubble.get_node_or_null("BubbleTail")
@onready var dialogue_label: Label = $Bubble/Margin/DialogueLabel if $Bubble.has_node("Margin/DialogueLabel") else ($Bubble.get_node_or_null("DialogueLabel") as Label)

const COZY_TYPE_INTERVAL: float = 0.03
const COZY_MAX_CHARS: int = 60
const SLEEP_CREAM_TEX: Texture2D = preload("res://assets/UI/CatUIPaid/slices/cat_sleep_cream.png")

var cozy_sleep_sprite: Sprite2D = null
var cozy_sleep_mode: bool = false
var _last_pet_rub_msec: int = -1000

var current_state: State = State.IDLE
var grid_pos: Vector2 = Vector2(4.0, 4.0)
var target_grid_pos: Vector2 = Vector2(4.0, 4.0)
var move_speed_grid: float = 2.4 # Ô lưới mỗi giây

var jump_offset_y: float = 0.0
var walk_dir_screen: Vector2 = Vector2.ZERO
var last_facing_right: bool = true
var current_skin: String = "orange"

var thoughts: Array = [
	"Phòng trọ 2.5D ấm cúng quá Sen ơi! 🐾",
	"Chiếc đệm ngủ này êm như mây vậy đó! 🛋️",
	"Cây cào móng sisal mài vuốt siêu đã luôn! 🪵",
	"Đổ hạt vào khay cho Boss nạp năng lượng nhé! 🥣",
	"Chạm sàn thả cuộn len cho Boss bắt đi nào! 🧶",
	"Tự lập tuy vất vả nhưng có Sen là vui rồi! ✨"
]

var costume_overlay: Node2D
var hat_label: Label
var bow_label: Label
var acc_label: Label
var _bubble_tween: Tween = null
var _is_typing_dialogue: bool = false
var _type_elapsed: float = 0.0
var _dialogue_total_chars: int = 0

func show_dialogue(text: String, duration: float = 4.0) -> void:
	if not bubble or not dialogue_label:
		return
	var clean_text: String = text.strip_edges()
	if clean_text.length() > COZY_MAX_CHARS:
		clean_text = clean_text.substr(0, COZY_MAX_CHARS - 1).strip_edges() + "…"
	dialogue_label.text = clean_text
	_dialogue_total_chars = clean_text.length()
	_type_elapsed = 0.0
	_is_typing_dialogue = _dialogue_total_chars > 0
	dialogue_label.visible_characters = 0 if _is_typing_dialogue else -1
	_resize_and_align_bubble(clean_text)
	bubble.visible = true
	bubble.modulate.a = 1.0
	bubble.scale = Vector2(0.85, 0.85)
	bubble.pivot_offset = Vector2(bubble.size.x / 2.0, bubble.size.y)
	var pop_tw = create_tween()
	pop_tw.tween_property(bubble, "scale", Vector2(1.0, 1.0), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	if _bubble_tween and _bubble_tween.is_valid():
		_bubble_tween.kill()
	if duration > 0.0:
		_bubble_tween = create_tween()
		_bubble_tween.tween_interval(duration)
		_bubble_tween.tween_property(bubble, "modulate:a", 0.0, 0.4)
		_bubble_tween.tween_callback(func():
			if bubble:
				bubble.visible = false
		)

func reveal_dialogue_instantly() -> void:
	_is_typing_dialogue = false
	if dialogue_label:
		dialogue_label.visible_characters = -1

func _resize_and_align_bubble(text: String) -> void:
	if not bubble:
		return
	var width: float = clampf(90.0 + float(mini(text.length(), 32)) * 4.2, 148.0, 236.0)
	var half_w: float = width * 0.5
	var est_height: float = 54.0 if text.length() > 26 else 40.0
	bubble.offset_left = -half_w
	bubble.offset_right = half_w
	bubble.offset_top = -46.0 - est_height
	bubble.offset_bottom = -46.0
	_align_bubble_tail(width)

func _align_bubble_tail(bubble_width: float = -1.0) -> void:
	if not bubble_tail or not bubble:
		return
	var w: float = bubble_width if bubble_width > 0.0 else bubble.size.x
	var mouth_offset: float = 10.0 if last_facing_right else -10.0
	var tail_x: float = clampf((w * 0.5) + mouth_offset - 6.0, 14.0, maxf(18.0, w - 26.0))
	bubble_tail.offset_left = tail_x - (w * 0.5)
	bubble_tail.offset_right = bubble_tail.offset_left + 12.0

func _on_bubble_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _is_typing_dialogue:
			reveal_dialogue_instantly()
		else:
			hide_dialogue()

func hide_dialogue() -> void:
	_is_typing_dialogue = false
	if _bubble_tween and _bubble_tween.is_valid():
		_bubble_tween.kill()
	if bubble:
		bubble.visible = false

func _ready() -> void:
	_setup_sprite_frames(GameManager.selected_avatar_id)
	_setup_cozy_sleep_sprite()
	_setup_costume_overlay()
	_update_screen_position()
	set_state(State.IDLE)
	_show_random_thought()
	
	if cat_touch_zone:
		cat_touch_zone.gui_input.connect(_on_touch_zone_gui_input)
	if bubble:
		bubble.gui_input.connect(_on_bubble_gui_input)
		
	GameManager.costume_changed.connect(func(_slot, _id): update_costume_overlay())
	GameManager.avatar_changed.connect(func(new_id): _setup_sprite_frames(new_id))
	update_costume_overlay()

func _on_touch_zone_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var touch_y = event.position.y - (cat_touch_zone.size.y / 2.0)
		handle_touch(touch_y)

func _setup_costume_overlay() -> void:
	costume_overlay = Node2D.new()
	costume_overlay.name = "CostumeOverlay"
	$Visual.add_child(costume_overlay)
	
	hat_label = Label.new()
	hat_label.position = Vector2(-10, -48)
	hat_label.add_theme_font_size_override("font_size", 16)
	costume_overlay.add_child(hat_label)
	
	bow_label = Label.new()
	bow_label.position = Vector2(-8, -26)
	bow_label.add_theme_font_size_override("font_size", 13)
	costume_overlay.add_child(bow_label)
	
	acc_label = Label.new()
	acc_label.position = Vector2(10, -36)
	acc_label.add_theme_font_size_override("font_size", 13)
	costume_overlay.add_child(acc_label)

func update_costume_overlay() -> void:
	if not costume_overlay:
		return
	# Giữ mèo chuẩn Pixel Art sạch đẹp, không dán nhãn emoji lơ lửng trên đầu
	if hat_label:
		hat_label.visible = false
	if bow_label:
		bow_label.visible = false
	if acc_label:
		acc_label.visible = false

func _load_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var t = load(path)
		if t: return t
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(path)
		if img:
			return ImageTexture.create_from_image(img)
	return null

## Cài đặt SpriteFrames từ CatAnimationFactory chuẩn 8 giống mèo với animation sống động
func _setup_sprite_frames(breed_arg = 0) -> void:
	var breed_id: int = 0
	if typeof(breed_arg) == TYPE_INT:
		breed_id = breed_arg
	else:
		breed_id = GameManager.selected_avatar_id
	var sf = CatAnimationFactory.get_sprite_frames(breed_id)
	anim_sprite.sprite_frames = sf
	if breed_id == 9:
		anim_sprite.scale = Vector2(1.1, 1.1)
		anim_sprite.position = Vector2(0, -26)
	else:
		anim_sprite.scale = Vector2(2.2, 2.2)
		anim_sprite.position = Vector2(0, -26)
	anim_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_state(current_state)

## Đổi màu lông mèo (orange: Mèo vàng mướp, charcoal: Mèo xám tro, white: Mèo trắng)
func set_skin(skin_name: String) -> void:
	current_skin = skin_name
	var b_id = 0
	if skin_name == "charcoal": b_id = 3
	elif skin_name == "white": b_id = 5
	_setup_sprite_frames(b_id)

func _process(delta: float) -> void:
	if _is_typing_dialogue and dialogue_label:
		_type_elapsed += delta
		var target_chars: int = mini(_dialogue_total_chars, int(floor(_type_elapsed / COZY_TYPE_INTERVAL)) + 1)
		if dialogue_label.visible_characters != target_chars:
			dialogue_label.visible_characters = target_chars
		if target_chars >= _dialogue_total_chars:
			reveal_dialogue_instantly()

	# Đồng bộ trạng thái ngất xỉu hoặc hồi phục
	if GameManager.hunger <= 0 and current_state != State.FAINT:
		set_state(State.FAINT)
	elif GameManager.hunger > 0 and current_state == State.FAINT:
		set_state(State.IDLE)
		
	if current_state == State.WALK or current_state == State.CHASE_TOY:
		var dist = grid_pos.distance_to(target_grid_pos)
		if dist > 0.06:
			var dir = (target_grid_pos - grid_pos).normalized()
			grid_pos += dir * move_speed_grid * delta
			
			# Hướng di chuyển trên màn hình
			var screen_dir = (IsometricGrid.grid_to_screen(target_grid_pos, origin) - IsometricGrid.grid_to_screen(grid_pos, origin)).normalized()
			var prev_facing: bool = last_facing_right
			if screen_dir.x > 0.05:
				last_facing_right = true
				anim_sprite.flip_h = false
			elif screen_dir.x < -0.05:
				last_facing_right = false
				anim_sprite.flip_h = true
			if last_facing_right != prev_facing and bubble and bubble.visible:
				_align_bubble_tail()
				
			var walk_anim = "run"
			if anim_sprite.animation != walk_anim:
				anim_sprite.play(walk_anim)
		else:
			grid_pos = target_grid_pos
			_on_reached_target()
			
	_update_screen_position()

## Xác định animation đi bộ chuẩn 8 hướng Isometric
func _get_walk_anim_for_dir(dir: Vector2) -> String:
	var angle_deg = rad_to_deg(dir.angle())
	if angle_deg < 0:
		angle_deg += 360.0
		
	# 8 Octants tương ứng 8 hướng không gian 2.5D
	if angle_deg >= 22.5 and angle_deg < 67.5:
		last_facing_right = true
		return "walk_dr"
	elif angle_deg >= 67.5 and angle_deg < 112.5:
		return "walk_down"
	elif angle_deg >= 112.5 and angle_deg < 157.5:
		last_facing_right = false
		return "walk_dl"
	elif angle_deg >= 157.5 and angle_deg < 202.5:
		last_facing_right = false
		return "walk_left"
	elif angle_deg >= 202.5 and angle_deg < 247.5:
		last_facing_right = false
		return "walk_ul"
	elif angle_deg >= 247.5 and angle_deg < 292.5:
		return "walk_up"
	elif angle_deg >= 292.5 and angle_deg < 337.5:
		last_facing_right = true
		return "walk_ur"
	else:
		last_facing_right = true
		return "walk_right"

func _update_screen_position() -> void:
	if current_state != State.DRAGGED:
		position = IsometricGrid.grid_to_screen(grid_pos, origin)
	$Visual.position.y = jump_offset_y
	# Bóng đổ luôn nằm cố định trên mặt sàn, co giãn khi nhảy
	var shadow_scale = clampf(1.0 + (jump_offset_y / 60.0), 0.4, 1.0)
	shadow_node.scale = Vector2(shadow_scale, shadow_scale)

func walk_to_grid(target_u_v: Vector2, then_state: State = State.IDLE) -> void:
	target_grid_pos = IsometricGrid.clamp_to_room(target_u_v, 0.8)
	next_state_on_arrive = then_state
	set_state(State.WALK)

var next_state_on_arrive: State = State.IDLE

func _on_reached_target() -> void:
	var dest_state = next_state_on_arrive
	next_state_on_arrive = State.IDLE
	set_state(dest_state)
	emit_signal("reached_destination", dest_state)

func set_state(new_state: State) -> void:
	current_state = new_state
	jump_offset_y = 0.0
	cat_idle_sprite.rotation_degrees = 0.0
	
	anim_sprite.visible = true
	cat_idle_sprite.visible = false
	cat_box_sprite.visible = false
	if cozy_sleep_sprite:
		cozy_sleep_sprite.visible = false
	
	match current_state:
		State.IDLE:
			var idle_choices = ["idle", "idle2"]
			if anim_sprite.sprite_frames:
				if anim_sprite.sprite_frames.has_animation("idle_blink"): idle_choices.append("idle_blink")
				if anim_sprite.sprite_frames.has_animation("tail_wag"): idle_choices.append("tail_wag")
				if anim_sprite.sprite_frames.has_animation("lick_paw"): idle_choices.append("lick_paw")
			var idle_anim = idle_choices[randi() % idle_choices.size()]
			anim_sprite.play(idle_anim)
			anim_sprite.flip_h = not last_facing_right
		State.WALK:
			anim_sprite.play("run")
			anim_sprite.flip_h = not last_facing_right
			move_speed_grid = 2.4
		State.CHASE_TOY:
			anim_sprite.play("run")
			anim_sprite.flip_h = not last_facing_right
			move_speed_grid = 4.2 # Chạy nước rút vồ đồ chơi
		State.SLEEP:
			if cozy_sleep_mode and cozy_sleep_sprite:
				anim_sprite.visible = false
				cozy_sleep_sprite.visible = true
			else:
				if cozy_sleep_sprite:
					cozy_sleep_sprite.visible = false
				anim_sprite.play("sleep")
				anim_sprite.flip_h = not last_facing_right
			show_dialogue("Khò khò... Zzz... Đệm êm quá! 💤", 3.5)
		State.SCRATCH:
			anim_sprite.play("scratch")
			anim_sprite.flip_h = not last_facing_right
			show_dialogue("Cào cào... Mài móng vuốt kim cương! 🪵✨", 3.5)
			_play_scratch_animation()
		State.EAT:
			anim_sprite.play("eat")
			anim_sprite.flip_h = not last_facing_right
			show_dialogue("Nhai nhồm nhoàm... Nom nom nom! 🍗", 3.5)
		State.DRINK:
			anim_sprite.play("drink")
			anim_sprite.flip_h = not last_facing_right
			show_dialogue("Uống nước mát lành... Slurp slurp! 💧", 3.5)
		State.BOX:
			if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("sleep_in_box"):
				anim_sprite.visible = true
				cat_box_sprite.visible = false
				anim_sprite.play("sleep_in_box")
			else:
				anim_sprite.visible = false
				cat_box_sprite.visible = true
			show_dialogue("Trốn trong hộp carton này không ai tìm ra Boss đâu! 📦", 4.0)
		State.FAINT:
			anim_sprite.play("faint")
			show_dialogue("😵 Xỉu... Hạ đường huyết rồi... Đói lả không thể đứng dậy... 🚑", 0.0)
		State.SCARED:
			anim_sprite.visible = false
			cat_box_sprite.visible = true
			show_dialogue("😿 Thành phố đáng sợ quá... Boss tự ti không dám ra đường học skill đâu! 🚪", 4.0)
		State.DRAGGED:
			anim_sprite.play("paw_toy")
			anim_sprite.flip_h = not last_facing_right
			show_dialogue("Meo! Sen bế Boss đi đâu thế? 🐾", 3.0)

var is_dragged: bool = false
var drag_anim_tween: Tween = null

func start_drag() -> void:
	is_dragged = true
	jump_offset_y = -20.0
	set_state(State.DRAGGED)
	SoundManager.play_meow(1.2)
	
	if drag_anim_tween and drag_anim_tween.is_valid():
		drag_anim_tween.kill()
	drag_anim_tween = create_tween().set_loops()
	drag_anim_tween.tween_property($Visual, "rotation_degrees", 6.0, 0.22).set_trans(Tween.TRANS_SINE)
	drag_anim_tween.tween_property($Visual, "rotation_degrees", -6.0, 0.22).set_trans(Tween.TRANS_SINE)

func end_drag() -> void:
	is_dragged = false
	if drag_anim_tween and drag_anim_tween.is_valid():
		drag_anim_tween.kill()
	$Visual.rotation_degrees = 0.0
	
	var tw = create_tween()
	tw.tween_property(self, "jump_offset_y", 0.0, 0.12).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property($Visual, "scale", Vector2(1.25, 0.8), 0.12)
	tw.tween_property($Visual, "scale", Vector2(1.0, 1.0), 0.09)

func _play_scratch_animation() -> void:
	var tween = create_tween()
	tween.tween_property($Visual, "position:x", 3.0, 0.08)
	tween.tween_property($Visual, "position:x", -3.0, 0.08)
	tween.tween_property($Visual, "position:x", 2.0, 0.08)
	tween.tween_property($Visual, "position:x", 0.0, 0.08)

func _show_random_thought() -> void:
	if GameManager.hunger <= 0:
		show_dialogue("😵 Xỉu... Hạ đường huyết rồi... Cần cấp cứu gấp! 🚑", 0.0)
		return
	if GameManager.hunger < 25:
		show_dialogue("😿 Đói meo râu rồi Sen ơi... Bụng kêu ùng ục nè! 🥣", 4.0)
		return
	if GameManager.courage <= 15:
		show_dialogue("😿 Thành phố đáng sợ quá... Boss tự ti không dám bước ra đường học đâu! 🚪", 4.0)
		return
	if GameManager.hunger >= 100:
		show_dialogue("🤢 No căng tròn bụng rồi Sen ơi! Đi lăn chứ đi bộ không nổi! 🫄", 4.0)
		return
	show_dialogue(thoughts[randi() % thoughts.size()], 4.0)

# Tương tác chạm Talking Tom trực tiếp trên thân mèo
func handle_touch(touch_y_relative: float) -> void:
	if GameManager.hunger <= 0:
		SoundManager.play_fail()
		show_dialogue("😵 Boss đang xỉu vì hạ đường huyết! Hãy cho ăn cấp cứu nhé Sen! 🥣", 4.0)
		return
		
	# Haptic feedback rung nhẹ phản hồi cảm ứng
	if OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		Input.vibrate_handheld(40)
		
	# Hiệu ứng nảy Squash & Stretch
	_play_squash_and_stretch()
	
	# Hiệu ứng tim bay pixel art khi nựng mèo
	_spawn_floating_hearts(randi_range(2, 3))
		
	if touch_y_relative < -15.0:
		# Vuốt đầu / tai -> Mèo liếm vuốt grooming (lick_paw / wash)
		SoundManager.play_purr()
		GameManager.update_stats(0, 0, +2, +5)
		show_dialogue("Purr purr~ Vuốt ve đã quá Sen ơi! 😻", 3.5)
		if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("lick_paw"):
			anim_sprite.play("lick_paw")
		else:
			anim_sprite.play("wash")
		get_tree().create_timer(1.2).timeout.connect(func():
			if current_state == State.IDLE:
				anim_sprite.play("idle" if last_facing_right else "idle_left")
		)
	elif touch_y_relative < 10.0:
		# Chọc bụng cù lét -> Mèo vẫy đuôi hào hứng (tail_wag / paw_toy)
		SoundManager.play_giggle()
		GameManager.update_stats(0, 0, 0, +8)
		show_dialogue("Hi hi! Nhột quá Sen ơi! Đừng cù lét Boss mà! 😹", 3.5)
		if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("tail_wag"):
			anim_sprite.play("tail_wag")
		else:
			anim_sprite.play("paw_toy")
		get_tree().create_timer(1.0).timeout.connect(func():
			if current_state == State.IDLE:
				anim_sprite.play("idle" if last_facing_right else "idle_left")
		)
	else:
		# Chọc chân móng vuốt -> Mèo nháy mắt / đứng 2 chân nảy người
		SoundManager.play_bounce()
		show_dialogue("Boing! Ai cho đụng vào bàn chân ngọc ngà của Boss! 😼", 3.5)
		if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("idle_blink") and randf() < 0.5:
			anim_sprite.play("idle_blink")
		else:
			anim_sprite.play("celebrate")
		_jump_reaction(22.0)
		get_tree().create_timer(1.0).timeout.connect(func():
			if current_state == State.IDLE:
				anim_sprite.play("idle" if last_facing_right else "idle_left")
		)

func _play_squash_and_stretch() -> void:
	var tw = create_tween()
	tw.tween_property($Visual, "scale", Vector2(1.15, 0.85), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property($Visual, "scale", Vector2(0.92, 1.08), 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property($Visual, "scale", Vector2(1.0, 1.0), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _spawn_floating_hearts(count: int = 2) -> void:
	var heart_tex = preload("res://assets/UI/CatUIPaid/slices/heart_particle_pixel.tres")
	for i in range(count):
		var heart = Sprite2D.new()
		heart.texture = heart_tex
		heart.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		heart.position = Vector2(randf_range(-14.0, 14.0), -35.0 + randf_range(-6.0, 4.0))
		heart.scale = Vector2(0.6, 0.6)
		heart.modulate.a = 0.95
		add_child(heart)
		
		var tw = create_tween()
		var target_y = heart.position.y - randf_range(28.0, 45.0)
		var drift_x = heart.position.x + randf_range(-18.0, 18.0)
		var rot = randf_range(-0.35, 0.35)
		
		tw.parallel().tween_property(heart, "position:y", target_y, 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(heart, "position:x", drift_x, 0.65).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property(heart, "rotation", rot, 0.65)
		tw.parallel().tween_property(heart, "scale", Vector2(1.15, 1.15), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(heart, "scale", Vector2(0.4, 0.4), 0.4)
		tw.parallel().tween_property(heart, "modulate:a", 0.0, 0.4)
		tw.tween_callback(heart.queue_free)

func play_idle_blink() -> void:
	if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("idle_blink"):
		anim_sprite.play("idle_blink")

func play_tail_wag() -> void:
	if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("tail_wag"):
		anim_sprite.play("tail_wag")

func play_lick_paw() -> void:
	if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("lick_paw"):
		anim_sprite.play("lick_paw")

func play_sleep_in_box() -> void:
	if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("sleep_in_box"):
		anim_sprite.play("sleep_in_box")

func _bounce_reaction(scale_target: Vector2) -> void:
	var tween = create_tween()
	tween.tween_property($Visual, "scale", scale_target, 0.09)
	tween.tween_property($Visual, "scale", Vector2(1.0, 1.0), 0.09)

func _jump_reaction(height: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "jump_offset_y", -height, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "jump_offset_y", 0.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _setup_cozy_sleep_sprite() -> void:
	if cozy_sleep_sprite and is_instance_valid(cozy_sleep_sprite):
		return
	cozy_sleep_sprite = Sprite2D.new()
	cozy_sleep_sprite.name = "CozySleepCreamSprite"
	cozy_sleep_sprite.texture = SLEEP_CREAM_TEX
	cozy_sleep_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	cozy_sleep_sprite.scale = Vector2(1.4, 1.4)
	cozy_sleep_sprite.position = Vector2(0, -14)
	cozy_sleep_sprite.visible = false
	$Visual.add_child(cozy_sleep_sprite)

func set_cozy_sleep_mode(enabled: bool) -> void:
	cozy_sleep_mode = enabled
	GameManager.is_offline_auto_sleeping = enabled
	if cozy_sleep_sprite:
		cozy_sleep_sprite.visible = enabled
	if enabled:
		set_state(State.SLEEP)
		show_dialogue("Ngủ tiết kiệm sức chờ Sen về nè~ Zzz", 4.0)
	else:
		if current_state == State.SLEEP:
			set_state(State.IDLE)

func pet_rub(_touch_y_relative: float = -12.0) -> void:
	var now_msec: int = Time.get_ticks_msec()
	if now_msec - _last_pet_rub_msec < 300:
		return
	_last_pet_rub_msec = now_msec
	if cozy_sleep_mode:
		set_cozy_sleep_mode(false)
	SoundManager.play_purr()
	_play_squash_and_stretch()
	_spawn_floating_hearts(2)
	GameManager.update_stats(0, 0, +1, +2)
	show_dialogue("Purr~ Vuốt ve thích quá Sen ơi!", 2.5)
