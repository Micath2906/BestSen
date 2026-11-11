extends Control

# RoomView.gd - Căn Nhà Trống Ban Đầu (2 Chén Ăn/Nước, Các Cửa, 1 Hộp Carton) & Mèo Tự Do Đi Lại

signal open_skill_tree_requested
signal open_lesson_requested(lesson_id)

enum CatState { IDLE, WALK, SLEEP, BOX, DRACULA, CHASE_TOY, EATING, DRINKING }

@onready var cat_anchor: Node2D = $RoomContainer/CatAnchor
@onready var anim_sprite: AnimatedSprite2D = $RoomContainer/CatAnchor/AnimSprite
@onready var cat_idle_sprite: Sprite2D = $RoomContainer/CatAnchor/CatIdleSprite
@onready var cat_box_sprite: Sprite2D = $RoomContainer/CatAnchor/CatBoxSprite
@onready var cat_drac_sprite: Sprite2D = $RoomContainer/CatAnchor/CatDraculaSprite

@onready var cat_touch_zone: Control = $RoomContainer/CatAnchor/CatTouchZone
@onready var floor_touch_zone: Control = $RoomContainer/FloorTouchZone
@onready var bubble: PanelContainer = $RoomContainer/CatAnchor/Bubble
@onready var dialogue_label: Label = $RoomContainer/CatAnchor/Bubble/DialogueLabel

# Các vật dụng trên sàn ban đầu
@onready var static_box: Sprite2D = $RoomContainer/CardboardBoxStatic
@onready var box_touch_zone: Control = $RoomContainer/CardboardBoxStatic/BoxTouchZone
@onready var food_bowl_node: Sprite2D = $RoomContainer/FoodBowlStatic
@onready var food_touch_zone: Control = $RoomContainer/FoodBowlStatic/FoodTouchZone
@onready var water_bowl_node: Sprite2D = $RoomContainer/WaterBowlStatic
@onready var water_touch_zone: Control = $RoomContainer/WaterBowlStatic/WaterTouchZone

@onready var toy_item: Node2D = $RoomContainer/ToyItem
@onready var toy_label: Label = $RoomContainer/ToyItem/ToyLabel

@onready var roam_timer: Timer = $RoamTimer
@onready var anim_timer: Timer = $AnimTimer

var current_state: CatState = CatState.IDLE
var target_walk_pos: Vector2 = Vector2(270, 440)
var walk_speed: float = 75.0
var idle_frame_index: int = 0
var box_frame_index: int = 0
var drac_frame_index: int = 0

var cat_thoughts: Array = [
	"Phòng trọ mới thuê tuy còn trống, nhưng có Sen là ấm áp rồi! 🐾",
	"Meo meo~ Khởi đầu tự lập từ con số 0, Boss không sợ đâu!",
	"Chiếc hộp carton này ngủ đã ghê luôn Sen ơi~ 📦",
	"Sen bấm vào chén ăn hoặc chén nước chăm sóc Boss nha! 🥣",
	"Chạm vào sàn nhà thả cuộn len cho Boss bắt đi nào! 🧶",
	"Tiết kiệm từng đồng tiền tiêu vặt, sau này sắm thêm đồ xịn cho phòng trọ!"
]

func _ready() -> void:
	_setup_sprite_frames()
	
	roam_timer.timeout.connect(_on_roam_timer_timeout)
	roam_timer.start(randf_range(3.5, 6.0))
	
	anim_timer.timeout.connect(_on_anim_timer_timeout)
	anim_timer.start(0.18)
	
	floor_touch_zone.gui_input.connect(_on_floor_input)
	cat_touch_zone.gui_input.connect(_on_cat_touch_input)
	box_touch_zone.gui_input.connect(_on_box_clicked)
	food_touch_zone.gui_input.connect(_on_food_bowl_clicked)
	water_touch_zone.gui_input.connect(_on_water_bowl_clicked)
	
	toy_item.visible = false
	bubble.visible = true
	
	set_state(CatState.IDLE)
	_show_random_thought()

func _setup_sprite_frames() -> void:
	var sf = SpriteFrames.new()
	
	# Walk frames (4)
	sf.add_animation("walk")
	sf.set_animation_speed("walk", 7.0)
	for i in range(4):
		sf.add_frame("walk", load("res://assets/sprites/cats/cat_walk_%d.png" % i))
		
	# Sleep frames (4)
	sf.add_animation("sleep")
	sf.set_animation_speed("sleep", 2.0)
	for i in range(4):
		sf.add_frame("sleep", load("res://assets/sprites/cats/cat_sleep_%d.png" % i))
		
	anim_sprite.sprite_frames = sf

func _process(delta: float) -> void:
	if current_state == CatState.WALK or current_state == CatState.CHASE_TOY:
		var dist = cat_anchor.position.distance_to(target_walk_pos)
		if dist > 6.0:
			var dir = (target_walk_pos - cat_anchor.position).normalized()
			cat_anchor.position += dir * walk_speed * delta
			anim_sprite.flip_h = (dir.x < 0)
			cat_idle_sprite.flip_h = (dir.x < 0)
		else:
			cat_anchor.position = target_walk_pos
			if current_state == CatState.CHASE_TOY:
				_on_reached_toy()
			else:
				set_state(CatState.IDLE)

func set_state(new_state: CatState) -> void:
	current_state = new_state
	
	anim_sprite.visible = false
	cat_idle_sprite.visible = false
	cat_box_sprite.visible = false
	cat_drac_sprite.visible = false
	
	# Nếu mèo đang ở trong hộp, ẩn hộp tĩnh trên sàn đi
	static_box.visible = (new_state != CatState.BOX)
	
	match new_state:
		CatState.IDLE:
			cat_idle_sprite.visible = true
			walk_speed = 70.0
		CatState.WALK:
			anim_sprite.visible = true
			anim_sprite.play("walk")
			walk_speed = 75.0
		CatState.CHASE_TOY:
			anim_sprite.visible = true
			anim_sprite.play("walk")
			walk_speed = 135.0
		CatState.SLEEP:
			anim_sprite.visible = true
			anim_sprite.play("sleep")
			dialogue_label.text = "Khò khò... Zzz... 💤"
		CatState.BOX:
			cat_anchor.position = static_box.position
			cat_box_sprite.visible = true
			dialogue_label.text = "Hộp carton trốn tìm êm nhất trần đời! 📦"
			SoundManager.play_purr()
		CatState.DRACULA:
			cat_drac_sprite.visible = true
			dialogue_label.text = "Bá tước Mèo Dracula siêu ngầu! 🧛‍♂️✨"
			SoundManager.play_bounce()
		CatState.EATING:
			cat_idle_sprite.visible = true
			dialogue_label.text = "Nhai nhồm nhoàm... Nom nom nom! 🍗✨"
		CatState.DRINKING:
			cat_idle_sprite.visible = true
			dialogue_label.text = "Uống nước mát lành... Slurp slurp! 💧✨"

func _on_anim_timer_timeout() -> void:
	if current_state == CatState.IDLE or current_state == CatState.EATING or current_state == CatState.DRINKING:
		idle_frame_index = (idle_frame_index + 1) % 10
		cat_idle_sprite.frame = idle_frame_index
	elif current_state == CatState.BOX:
		box_frame_index = (box_frame_index + 1) % 4
		cat_box_sprite.frame = box_frame_index
	elif current_state == CatState.DRACULA:
		drac_frame_index = (drac_frame_index + 1) % 6
		cat_drac_sprite.frame = drac_frame_index

func _on_roam_timer_timeout() -> void:
	if current_state == CatState.CHASE_TOY or current_state == CatState.EATING or current_state == CatState.DRINKING:
		roam_timer.start(3.0)
		return
		
	var roll = randf()
	if roll < 0.45:
		# Đi dạo quanh sàn nhà
		var next_x = randf_range(90.0, 450.0)
		var next_y = randf_range(390.0, 520.0)
		target_walk_pos = Vector2(next_x, next_y)
		set_state(CatState.WALK)
		_show_random_thought()
	elif roll < 0.65:
		set_state(CatState.IDLE)
	elif roll < 0.82:
		# Chui vào hộp carton
		set_state(CatState.BOX)
	else:
		# Nằm ngủ
		set_state(CatState.SLEEP)
		
	roam_timer.start(randf_range(4.0, 8.0))

func _show_random_thought() -> void:
	var idx = randi() % cat_thoughts.size()
	dialogue_label.text = cat_thoughts[idx]

# --- TƯƠNG TÁC CHẠM ĐỒ VẬT TRÊN SÀN ---
func _on_box_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		set_state(CatState.BOX)
		_spawn_floating_text("📦 Trốn tìm!", Color(0.9, 0.6, 0.2))

func _on_food_bowl_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		feed_cat("kibble")

func _on_water_bowl_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		drink_water()

func drink_water() -> void:
	target_walk_pos = water_bowl_node.position + Vector2(-35.0, -10.0)
	set_state(CatState.WALK)
	
	var tween = create_tween()
	tween.tween_interval(0.6)
	tween.finished.connect(func():
		set_state(CatState.DRINKING)
		SoundManager.play_purr()
		GameManager.update_stats(0, 0, +5, +5)
		_spawn_floating_text("💧 +5 Dũng Cảm | ✨ +5 Mood", Color(0.2, 0.6, 0.9))
		
		var t2 = create_tween()
		t2.tween_interval(1.5)
		t2.finished.connect(func(): set_state(CatState.IDLE))
	)

# --- TƯƠNG TÁC CHẠM SÀN NHÀ (THẢ ĐỒ CHƠI) ---
func _on_floor_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos = event.position
		if click_pos.y >= 360.0 and click_pos.y <= 620.0:
			_spawn_toy_and_chase(click_pos)

func _spawn_toy_and_chase(target_pos: Vector2) -> void:
	toy_item.position = target_pos
	toy_item.visible = true
	toy_item.scale = Vector2(0.5, 0.5)
	
	var toys = ["🧶", "🔴", "🎾", "🐟"]
	toy_label.text = toys[randi() % toys.size()]
	
	var tween = create_tween()
	tween.tween_property(toy_item, "scale", Vector2(1.2, 1.2), 0.12)
	tween.tween_property(toy_item, "scale", Vector2(1.0, 1.0), 0.08)
	
	SoundManager.play_meow(1.5)
	dialogue_label.text = "Ồ! Đồ chơi kìa! Boss bắt đây! Meo meo! ✨"
	
	target_walk_pos = target_pos
	set_state(CatState.CHASE_TOY)

func _on_reached_toy() -> void:
	SoundManager.play_bounce()
	SoundManager.play_purr()
	
	var tween = create_tween()
	tween.tween_property(cat_anchor, "position:y", cat_anchor.position.y - 35.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(cat_anchor, "position:y", cat_anchor.position.y, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	var toy_tween = create_tween()
	toy_tween.tween_property(toy_item, "scale", Vector2(1.8, 1.8), 0.1)
	toy_tween.parallel().tween_property(toy_item, "modulate:a", 0.0, 0.12)
	toy_tween.finished.connect(func(): 
		toy_item.visible = false
		toy_item.modulate.a = 1.0
	)
	
	GameManager.update_stats(0, -1, +2, +10)
	_spawn_floating_text("💖 +2 Dũng | ✨ +10 Mood!", Color(1.0, 0.4, 0.7))
	dialogue_label.text = "Bắt được rồi nha! Boss cừ khôi số 1! 😹"
	set_state(CatState.IDLE)

# --- TƯƠNG TÁC CHO ĂN ---
func feed_cat(food_type: String) -> void:
	if food_type == "water":
		drink_water()
		return
		
	var success = false
	if food_type == "kibble":
		success = GameManager.feed_kibble()
	elif food_type == "pate":
		success = GameManager.feed_pate()
	elif food_type == "dry_fish":
		success = GameManager.feed_dry_fish()
		
	if not success:
		return
		
	# Mèo chạy lại gần chén thức ăn
	target_walk_pos = food_bowl_node.position + Vector2(-35.0, -10.0)
	set_state(CatState.WALK)
	
	var tween = create_tween()
	tween.tween_interval(0.6)
	tween.finished.connect(func():
		set_state(CatState.EATING)
		SoundManager.play_chomp()
		
		# Hiệu ứng nảy bát ăn
		var b_tween = create_tween()
		b_tween.tween_property(food_bowl_node, "scale", Vector2(2.8, 2.8), 0.1)
		b_tween.tween_property(food_bowl_node, "scale", Vector2(2.5, 2.5), 0.1)
		
		var eat_tween = create_tween()
		eat_tween.tween_interval(1.6)
		eat_tween.finished.connect(func():
			set_state(CatState.IDLE)
			SoundManager.play_purr()
			var msg = "+15 🍗"
			if food_type == "pate":
				msg = "+35 🍗 +25 💖"
			elif food_type == "dry_fish":
				msg = "+20 🍗 +20 ✨"
			_spawn_floating_text(msg, Color(0.2, 0.8, 0.3))
		)
	)

# --- TƯƠNG TÁC ĐỒ CHƠI ---
func play_activity(activity_type: String) -> void:
	match activity_type:
		"box":
			set_state(CatState.BOX)
			GameManager.play_cardboard()
		"feather":
			if GameManager.play_feather():
				SoundManager.play_bounce()
				_spawn_floating_text("+40 💖 Hưng Phấn!", Color(1.0, 0.5, 0.2))
				var tween = create_tween()
				tween.tween_property(cat_anchor, "position:y", cat_anchor.position.y - 45.0, 0.15)
				tween.tween_property(cat_anchor, "position:y", cat_anchor.position.y, 0.15)
		"pet":
			set_state(CatState.IDLE)
			GameManager.pet_cat()
			SoundManager.play_purr()
			_spawn_floating_text("💖 +5 Purr~", Color(1.0, 0.4, 0.8))
		"bnpl":
			GameManager.use_bnpl()
			SoundManager.play_meow(0.9)
			_spawn_floating_text("+30 💖 (Nợ 35 Cá!)", Color(0.9, 0.2, 0.2))

# --- TƯƠNG TÁC TRỰC TIẾP LÊN MÈO ---
func _on_cat_touch_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_y = event.position.y
		if local_y < 50.0:
			_handle_head_pet()
		elif local_y < 100.0:
			_handle_belly_poke()
		else:
			_handle_feet_poke()

func _handle_head_pet() -> void:
	SoundManager.play_purr()
	GameManager.update_stats(0, 0, +2, +5)
	_spawn_floating_text("💖 +2 Purr~ ✨ +5 Mood", Color(1.0, 0.35, 0.75))
	dialogue_label.text = "Purr purr~ Vuốt ve sướng quá Sen ơi! 😻"
	
	var tween = create_tween()
	tween.tween_property(cat_anchor, "scale", Vector2(1.08, 0.92), 0.1)
	tween.tween_property(cat_anchor, "scale", Vector2(1.0, 1.0), 0.1)

func _handle_belly_poke() -> void:
	SoundManager.play_giggle()
	GameManager.update_stats(0, 0, 0, +8)
	_spawn_floating_text("😹 Hi hi! ✨ +8 Mood", Color(1.0, 0.65, 0.15))
	dialogue_label.text = "Hi hi! Nhột quá đi Sen ơi! Đừng cù lét Boss mà! 😹"
	
	var tween = create_tween()
	tween.tween_property(cat_anchor, "scale", Vector2(0.85, 1.15), 0.08)
	tween.tween_property(cat_anchor, "scale", Vector2(1.1, 0.9), 0.08)
	tween.tween_property(cat_anchor, "scale", Vector2(1.0, 1.0), 0.1)

func _handle_feet_poke() -> void:
	SoundManager.play_bounce()
	_spawn_floating_text("✨ Boing!", Color(0.3, 0.7, 1.0))
	dialogue_label.text = "Méo! Ai cho chạm vào móng vuốt kim cương của Boss! 😼"
	
	var tween = create_tween()
	tween.tween_property(cat_anchor, "position:y", cat_anchor.position.y - 30.0, 0.1)
	tween.tween_property(cat_anchor, "position:y", cat_anchor.position.y, 0.1)

func _spawn_floating_text(txt: String, color: Color) -> void:
	var label = Label.new()
	label.text = txt
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 13)
	label.position = cat_anchor.position + Vector2(-30.0, -80.0)
	$RoomContainer.add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 45.0, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.finished.connect(func(): label.queue_free())
