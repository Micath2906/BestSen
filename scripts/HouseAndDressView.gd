extends Control

# HouseAndDressView.gd - Nhà Nhỏ & Tủ Đồ Ngôi Sao Cho Sen & Boss
# Phân thành 2 chế độ:
# 1. 👗 Tủ Đồ Thời Trang (Thay quần áo, thử đồ đa lớp, tính điểm Fashion Score, phối ngẫu nhiên)
# 2. 🏡 Trang Trí Nhà Cửa (Bài trí nội thất Isometric, thảm sàn, tranh tường, tính điểm Cozy Score)

signal back_to_room_requested
signal open_shop_requested

const CatAnimationFactory = preload("res://scripts/CatAnimationFactory.gd")

@onready var btn_back: Button = $TopBar/HBox/BtnBack
@onready var title_label: Label = $TopBar/HBox/TitleLabel
@onready var fish_balance_btn: Button = $TopBar/HBox/FishBalanceBtn

@onready var tab_dress_btn: Button = $ModeTabs/HBox/BtnTabDress
@onready var tab_decor_btn: Button = $ModeTabs/HBox/BtnTabDecor

# Container cho 2 chế độ
@onready var dress_mode_container: Control = $ContentContainer/DressModeContainer
@onready var decor_mode_container: Control = $ContentContainer/DecorModeContainer

# --- NODE CHẾ ĐỘ THỜI TRANG (DRESS MODE) ---
@onready var cat_stage_avatar: TextureRect = $ContentContainer/DressModeContainer/StageArea/HBox/StagePodium/CatAvatar
@onready var hat_rect: TextureRect = $ContentContainer/DressModeContainer/StageArea/HBox/StagePodium/HatRect
@onready var bow_rect: TextureRect = $ContentContainer/DressModeContainer/StageArea/HBox/StagePodium/BowRect
@onready var clothes_rect: TextureRect = $ContentContainer/DressModeContainer/StageArea/HBox/StagePodium/ClothesRect
@onready var acc_rect: TextureRect = $ContentContainer/DressModeContainer/StageArea/HBox/StagePodium/AccRect

var anim_stage_cat: AnimatedSprite2D = null

@onready var fashion_score_lbl: Label = $ContentContainer/DressModeContainer/StageArea/HBox/ScoreCard/VBox/ScoreHBox/FashionScoreLbl
@onready var fashion_title_lbl: Label = $ContentContainer/DressModeContainer/StageArea/HBox/ScoreCard/VBox/FashionTitleLbl
@onready var fashion_buff_lbl: Label = $ContentContainer/DressModeContainer/StageArea/HBox/ScoreCard/VBox/FashionBuffLbl
@onready var fashion_star_bar: TextureProgressBar = $ContentContainer/DressModeContainer/StageArea/HBox/ScoreCard/VBox/ScoreHBox/FashionStarBar if $ContentContainer/DressModeContainer/StageArea/HBox/ScoreCard/VBox/ScoreHBox.has_node("FashionStarBar") else null

@onready var btn_random_outfit: Button = $ContentContainer/DressModeContainer/ActionRow/BtnRandomOutfit
@onready var btn_unequip_all: Button = $ContentContainer/DressModeContainer/ActionRow/BtnUnequipAll
@onready var btn_save_outfit: Button = $ContentContainer/DressModeContainer/ActionRow/BtnSaveOutfit
@onready var btn_go_shop_dress: Button = $ContentContainer/DressModeContainer/ActionRow/BtnGoShop

@onready var dress_sub_tabs_container: HBoxContainer = $ContentContainer/DressModeContainer/Drawer/SubTabScroll/HBox
@onready var dress_items_grid: GridContainer = $ContentContainer/DressModeContainer/Drawer/ItemsScroll/Grid

# --- NODE CHẾ ĐỘ TRANG TRÍ (DECOR MODE) ---
@onready var cozy_score_lbl: Label = $ContentContainer/DecorModeContainer/RoomPreviewArea/VBox/ScoreCard/VBox/ScoreHBox/CozyScoreLbl
@onready var cozy_title_lbl: Label = $ContentContainer/DecorModeContainer/RoomPreviewArea/VBox/ScoreCard/VBox/CozyTitleLbl
@onready var cozy_buff_lbl: Label = $ContentContainer/DecorModeContainer/RoomPreviewArea/VBox/ScoreCard/VBox/CozyBuffLbl
@onready var cozy_star_bar: TextureProgressBar = $ContentContainer/DecorModeContainer/RoomPreviewArea/VBox/ScoreCard/VBox/ScoreHBox/CozyStarBar if $ContentContainer/DecorModeContainer/RoomPreviewArea/VBox/ScoreCard/VBox/ScoreHBox.has_node("CozyStarBar") else null

@onready var slot_bed_lbl: Label = $ContentContainer/DecorModeContainer/RoomPreviewArea/VBox/ShowcaseGrid/SlotBed/VBox/NameLbl
@onready var slot_bowl_lbl: Label = $ContentContainer/DecorModeContainer/RoomPreviewArea/VBox/ShowcaseGrid/SlotBowl/VBox/NameLbl
@onready var slot_rug_lbl: Label = $ContentContainer/DecorModeContainer/RoomPreviewArea/VBox/ShowcaseGrid/SlotRug/VBox/NameLbl
@onready var slot_wall_lbl: Label = $ContentContainer/DecorModeContainer/RoomPreviewArea/VBox/ShowcaseGrid/SlotWall/VBox/NameLbl
@onready var slot_plant_lbl: Label = $ContentContainer/DecorModeContainer/RoomPreviewArea/VBox/ShowcaseGrid/SlotPlant/VBox/NameLbl

@onready var btn_save_decor: Button = $ContentContainer/DecorModeContainer/ActionRow/BtnSaveDecor
@onready var btn_reset_decor: Button = $ContentContainer/DecorModeContainer/ActionRow/BtnResetDecor
@onready var btn_snapshot_decor: Button = $ContentContainer/DecorModeContainer/ActionRow/BtnSnapshot
@onready var btn_go_shop_decor: Button = $ContentContainer/DecorModeContainer/ActionRow/BtnGoShopDecor

@onready var decor_sub_tabs_container: HBoxContainer = $ContentContainer/DecorModeContainer/Drawer/SubTabScroll/HBox
@onready var decor_items_grid: GridContainer = $ContentContainer/DecorModeContainer/Drawer/ItemsScroll/Grid

# State
var current_mode: String = "dress" # "dress" hoặc "decor"
var current_dress_subcat: String = "all"
var current_decor_subcat: String = "all"

# Tạm thời lưu đồ đang thử trên sân khấu trước khi bấm "Lưu Trang Phục"
var preview_costumes: Dictionary = {}
var preview_decor: Dictionary = {}

func _ready() -> void:
	_init_preview_state()
	_setup_top_bar()
	_setup_mode_tabs()
	_setup_action_buttons()
	
	switch_mode("dress")
	_update_fish_balance()
	GameManager.stats_changed.connect(_update_fish_balance)
	GameManager.costume_changed.connect(func(_s, _i): _sync_from_game_manager())
	GameManager.decor_changed.connect(func(_s, _i): _sync_from_game_manager())

func _init_preview_state() -> void:
	preview_costumes = GameManager.equipped_costumes.duplicate()
	preview_decor = GameManager.equipped_decor.duplicate()

func _sync_from_game_manager() -> void:
	preview_costumes = GameManager.equipped_costumes.duplicate()
	preview_decor = GameManager.equipped_decor.duplicate()
	_render_stage_cat()
	_render_room_preview()
	_render_dress_items()
	_render_decor_items()

func _update_fish_balance() -> void:
	fish_balance_btn.text = "💵 %s" % GameManager.format_currency(GameManager.fish)

func _setup_top_bar() -> void:
	btn_back.pressed.connect(func():
		SoundManager.play_click()
		emit_signal("back_to_room_requested")
	)
	fish_balance_btn.pressed.connect(func():
		SoundManager.play_click()
		emit_signal("open_shop_requested")
	)

func _setup_mode_tabs() -> void:
	tab_dress_btn.pressed.connect(func(): switch_mode("dress"))
	tab_decor_btn.pressed.connect(func(): switch_mode("decor"))

func switch_mode(mode: String) -> void:
	SoundManager.play_click()
	current_mode = mode
	
	var active_style = StyleBoxFlat.new()
	active_style.set_corner_radius_all(12)
	active_style.set_border_width_all(2)
	active_style.border_width_bottom = 3
	active_style.content_margin_top = 6
	active_style.content_margin_bottom = 6
	
	var inactive_style = active_style.duplicate()
	
	if mode == "dress":
		active_style.bg_color = Color(0.70, 0.53, 0.92, 1.0) # Tím pastel mộng mơ
		active_style.border_color = Color(0.48, 0.32, 0.70, 1.0)
		tab_dress_btn.add_theme_stylebox_override("normal", active_style)
		tab_dress_btn.add_theme_color_override("font_color", Color.WHITE)
		
		inactive_style.bg_color = Color(0.96, 0.93, 0.88, 1.0)
		inactive_style.border_color = Color(0.80, 0.72, 0.64, 1.0)
		tab_decor_btn.add_theme_stylebox_override("normal", inactive_style)
		tab_decor_btn.add_theme_color_override("font_color", Color(0.4, 0.3, 0.2))
		
		dress_mode_container.visible = true
		decor_mode_container.visible = false
		title_label.text = "👗 TỦ ĐỒ NGÔI SAO SEN & BOSS"
		
		_build_dress_sub_tabs()
		_render_stage_cat()
		_render_dress_items()
	else:
		active_style.bg_color = Color(0.97, 0.50, 0.0, 1.0) # Cam ấm áp
		active_style.border_color = Color(0.75, 0.35, 0.0, 1.0)
		tab_decor_btn.add_theme_stylebox_override("normal", active_style)
		tab_decor_btn.add_theme_color_override("font_color", Color.WHITE)
		
		inactive_style.bg_color = Color(0.96, 0.93, 0.88, 1.0)
		inactive_style.border_color = Color(0.80, 0.72, 0.64, 1.0)
		tab_dress_btn.add_theme_stylebox_override("normal", inactive_style)
		tab_dress_btn.add_theme_color_override("font_color", Color(0.4, 0.3, 0.2))
		
		dress_mode_container.visible = false
		decor_mode_container.visible = true
		title_label.text = "🏡 BÀI TRÍ NHÀ NHỎ PHÒNG TRỌ"
		
		_build_decor_sub_tabs()
		_render_room_preview()
		_render_decor_items()

func _setup_action_buttons() -> void:
	# Thao tác thời trang
	btn_random_outfit.pressed.connect(_on_randomize_outfit)
	btn_unequip_all.pressed.connect(_on_unequip_all_outfits)
	btn_save_outfit.pressed.connect(_on_save_outfit)
	btn_go_shop_dress.pressed.connect(func(): emit_signal("open_shop_requested"))
	
	# Thao tác trang trí
	btn_save_decor.pressed.connect(_on_save_decor)
	btn_reset_decor.pressed.connect(_on_reset_decor)
	btn_snapshot_decor.pressed.connect(_on_snapshot_room)
	btn_go_shop_decor.pressed.connect(func(): emit_signal("open_shop_requested"))

# ==============================================================================
# PHẦN 1: CHẾ ĐỘ THAY QUẦN ÁO CHO MÈO (CAT DRESSING ROOM)
# ==============================================================================

func _build_dress_sub_tabs() -> void:
	for child in dress_sub_tabs_container.get_children():
		dress_sub_tabs_container.remove_child(child)
		child.queue_free()
		
	var sub_list = [
		{"id": "all", "name": "Tất Cả", "icon_res": "res://assets/UI/CatUIPaid/slices/cozy_dress/icon_subcat_all.tres"},
		{"id": "clothes", "name": "Quần Áo", "icon_res": "res://assets/UI/CatUIPaid/slices/cozy_dress/icon_subcat_clothes.tres"},
		{"id": "hats", "name": "Mũ & Nón", "icon_res": "res://assets/UI/CatUIPaid/slices/cozy_dress/icon_subcat_hat.tres"},
		{"id": "bows", "name": "Nơ & Khăn", "icon_res": "res://assets/UI/CatUIPaid/slices/cozy_dress/icon_subcat_bow.tres"},
		{"id": "accessories", "name": "Phụ Kiện", "icon_res": "res://assets/UI/CatUIPaid/slices/cozy_dress/icon_subcat_acc.tres"}
	]
	
	for sub in sub_list:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 32)
		var icon_path = sub.get("icon_res", "")
		if icon_path != "" and (ResourceLoader.exists(icon_path) or FileAccess.file_exists(icon_path)):
			btn.icon = load(icon_path)
			btn.expand_icon = false
			btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text = " " + sub["name"]
		btn.add_theme_font_size_override("font_size", 11)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.pressed.connect(func():
			SoundManager.play_click()
			current_dress_subcat = sub["id"]
			_style_sub_tabs(dress_sub_tabs_container, current_dress_subcat, sub_list)
			_render_dress_items()
		)
		dress_sub_tabs_container.add_child(btn)
		
	_style_sub_tabs(dress_sub_tabs_container, current_dress_subcat, sub_list)

func _style_sub_tabs(container: Container, active_id: String, sub_list: Array) -> void:
	var children = container.get_children()
	var n = mini(children.size(), sub_list.size())
	for i in range(n):
		var btn: Button = children[i]
		var is_active = (sub_list[i]["id"] == active_id)
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(10)
		style.set_border_width_all(1)
		style.border_width_bottom = 2
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 4
		style.content_margin_bottom = 4
		if is_active:
			style.bg_color = Color("#422716")
			style.border_color = Color("#D9A443")
			btn.add_theme_color_override("font_color", Color("#FFF8EC"))
		else:
			style.bg_color = Color("#FFFDF8")
			style.border_color = Color("#D8C5B0")
			btn.add_theme_color_override("font_color", Color("#4A301D"))
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)

func _render_stage_cat() -> void:
	if anim_stage_cat == null:
		anim_stage_cat = AnimatedSprite2D.new()
		anim_stage_cat.name = "AnimStageCat"
		anim_stage_cat.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		anim_stage_cat.position = Vector2(55, 55)
		anim_stage_cat.scale = Vector2(3.6, 3.6)
		cat_stage_avatar.add_child(anim_stage_cat)
		cat_stage_avatar.self_modulate.a = 0.0

	var cur_avatar_id = GameManager.selected_avatar_id
	anim_stage_cat.sprite_frames = CatAnimationFactory.get_sprite_frames(cur_avatar_id)
	if not anim_stage_cat.is_playing() or anim_stage_cat.animation != "jump":
		anim_stage_cat.play("idle2")
		
	# Cập nhật phụ kiện pixel-art trên sân khấu
	var hat_id = preview_costumes.get("hats", "")
	if hat_id != "":
		var path = GameManager.get_costume_sprite_path(hat_id)
		if path != "" and (ResourceLoader.exists(path) or FileAccess.file_exists(path)):
			hat_rect.texture = load(path)
			hat_rect.visible = true
		else:
			hat_rect.visible = false
	else:
		hat_rect.visible = false
		
	var bow_id = preview_costumes.get("bows", "")
	if bow_id != "":
		var path = GameManager.get_costume_sprite_path(bow_id)
		if path != "" and (ResourceLoader.exists(path) or FileAccess.file_exists(path)):
			bow_rect.texture = load(path)
			bow_rect.visible = true
		else:
			bow_rect.visible = false
	else:
		bow_rect.visible = false
		
	var clothes_id = preview_costumes.get("clothes", "")
	if clothes_id != "":
		var path = GameManager.get_costume_sprite_path(clothes_id)
		if path != "" and (ResourceLoader.exists(path) or FileAccess.file_exists(path)):
			clothes_rect.texture = load(path)
			clothes_rect.visible = true
		else:
			clothes_rect.visible = false
	else:
		clothes_rect.visible = false
		
	var acc_id = preview_costumes.get("accessories", "")
	if acc_id != "":
		var path = GameManager.get_costume_sprite_path(acc_id)
		if path != "" and (ResourceLoader.exists(path) or FileAccess.file_exists(path)):
			acc_rect.texture = load(path)
			acc_rect.visible = true
		else:
			acc_rect.visible = false
	else:
		acc_rect.visible = false
		
	# Tính điểm phong cách
	var score = _calc_preview_fashion_score()
	fashion_score_lbl.text = "%d Điểm" % score
	fashion_title_lbl.text = _calc_preview_fashion_title(score)
	if fashion_star_bar:
		fashion_star_bar.value = score
	
	var courage_buff = 0
	var mood_buff = 0
	for id in preview_costumes.values():
		if id != "":
			var it = GameManager.get_shop_item(id)
			var boost = it.get("stat_boost", {})
			courage_buff += boost.get("courage", 0)
			mood_buff += boost.get("mood", 0)
			
	fashion_buff_lbl.text = "Hiệu Quả: Dũng Cảm +%d  ·  Tâm Trạng +%d" % [courage_buff, mood_buff]

func _calc_preview_fashion_score() -> int:
	var score: int = 20
	var equipped_count: int = 0
	for slot in ["clothes", "hats", "bows", "accessories"]:
		var id = preview_costumes.get(slot, "")
		if id != "":
			equipped_count += 1
			var item = GameManager.get_shop_item(id)
			if not item.is_empty():
				score += item.get("price", 20)
				var boost = item.get("stat_boost", {})
				score += boost.get("courage", 5) + boost.get("mood", 5)
	if equipped_count >= 3:
		score += 35
	if equipped_count == 4:
		score += 25
	return score

func _calc_preview_fashion_title(score: int) -> String:
	if score < 50:
		return "Mộc Mạc Dễ Thương 🐱"
	elif score < 90:
		return "Tân Sinh Viên Gọn Gàng 🎒"
	elif score < 140:
		return "Fashionista Xóm Trọ 🌟"
	elif score < 200:
		return "Icon Thời Trang Học Đường 👑"
	else:
		return "Thủ Khoa Thời Trang Đỉnh Cao 💎"

func _render_dress_items() -> void:
	for child in dress_items_grid.get_children():
		dress_items_grid.remove_child(child)
		child.queue_free()
		
	if not GameManager.shop_catalog_data.has("items"):
		return
		
	var items = GameManager.shop_catalog_data["items"]
	for it in items:
		if it["category"] != "costumes":
			continue
		if current_dress_subcat != "all" and it["subcategory"] != current_dress_subcat:
			continue
			
		var card = _create_dress_item_card(it)
		dress_items_grid.add_child(card)

func _create_dress_item_card(item: Dictionary) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(245, 110)
	
	var c_style = StyleBoxFlat.new()
	c_style.bg_color = Color(1.0, 0.985, 0.96, 0.98)
	c_style.border_color = Color(0.88, 0.80, 0.72, 1.0)
	c_style.set_border_width_all(1)
	c_style.border_width_bottom = 2
	c_style.set_corner_radius_all(12)
	c_style.content_margin_left = 8
	c_style.content_margin_right = 8
	c_style.content_margin_top = 8
	c_style.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", c_style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	card.add_child(hbox)
	
	# Icon tròn bên trái
	var icon_box = PanelContainer.new()
	icon_box.custom_minimum_size = Vector2(50, 50)
	icon_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var ib_style = StyleBoxFlat.new()
	ib_style.bg_color = Color(0.95, 0.90, 0.85, 1.0)
	ib_style.set_corner_radius_all(25)
	icon_box.add_theme_stylebox_override("panel", ib_style)
	
	var sprite_path = GameManager.get_costume_sprite_path(item["id"])
	if sprite_path != "" and (ResourceLoader.exists(sprite_path) or FileAccess.file_exists(sprite_path)):
		var tex_rect = TextureRect.new()
		tex_rect.texture = load(sprite_path)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.custom_minimum_size = Vector2(36, 36)
		tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tex_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon_box.add_child(tex_rect)
	else:
		var icon_lbl = Label.new()
		icon_lbl.text = item.get("icon", "👔")
		icon_lbl.add_theme_font_size_override("font_size", 22)
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		icon_box.add_child(icon_lbl)
	hbox.add_child(icon_box)
	
	# Thông tin chi tiết bên phải
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(vbox)
	
	var name_lbl = Label.new()
	name_lbl.text = item.get("name", "Trang phục")
	name_lbl.add_theme_color_override("font_color", Color(0.3, 0.2, 0.15))
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_lbl)
	
	var stat_lbl = Label.new()
	var boost = item.get("stat_boost", {})
	stat_lbl.text = "+%d Dũng · +%d Mood" % [boost.get("courage", 0), boost.get("mood", 0)]
	stat_lbl.add_theme_color_override("font_color", Color(0.25, 0.60, 0.35))
	stat_lbl.add_theme_font_size_override("font_size", 10)
	vbox.add_child(stat_lbl)
	
	# Nút hành động (Thử đồ / Mặc / Chưa sở hữu)
	var subcat = item.get("subcategory", "clothes")
	var item_id = item["id"]
	var is_owned = GameManager.is_item_owned(item_id)
	var is_currently_on = (preview_costumes.get(subcat, "") == item_id)
	
	var btn_action = Button.new()
	btn_action.custom_minimum_size = Vector2(0, 26)
	btn_action.add_theme_font_size_override("font_size", 10)
	btn_action.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	var btn_style = StyleBoxFlat.new()
	btn_style.set_corner_radius_all(8)
	btn_style.border_width_bottom = 2
	
	if is_currently_on:
		btn_action.text = "✔ Đang Mặc"
		btn_style.bg_color = Color(0.28, 0.70, 0.44)
		btn_style.border_color = Color(0.18, 0.50, 0.30)
		btn_action.add_theme_color_override("font_color", Color.WHITE)
		btn_action.pressed.connect(func():
			# Bấm lại để tháo
			SoundManager.play_click()
			preview_costumes[subcat] = ""
			_render_stage_cat()
			_render_dress_items()
		)
	elif is_owned:
		btn_action.text = "👗 Thử Đồ"
		btn_style.bg_color = Color(0.95, 0.55, 0.15)
		btn_style.border_color = Color(0.75, 0.38, 0.08)
		btn_action.add_theme_color_override("font_color", Color.WHITE)
		btn_action.pressed.connect(func():
			SoundManager.play_bounce()
			preview_costumes[subcat] = item_id
			_render_stage_cat()
			_bounce_stage_cat()
			_render_dress_items()
		)
	else:
		btn_action.text = "🛒 Xem Shop (%d 🐟)" % item.get("price", 25)
		btn_style.bg_color = Color(0.90, 0.85, 0.78)
		btn_style.border_color = Color(0.75, 0.70, 0.62)
		btn_action.add_theme_color_override("font_color", Color(0.4, 0.3, 0.2))
		btn_action.pressed.connect(func():
			# Preview thử ngay trên bục và gợi ý mở shop
			SoundManager.play_click()
			preview_costumes[subcat] = item_id
			_render_stage_cat()
			_render_dress_items()
			GameManager.emit_signal("show_toast", "Đang thử mẫu %s! Mở Shop để mua vĩnh viễn nha!" % item.get("name", ""))
		)
		
	btn_action.add_theme_stylebox_override("normal", btn_style)
	btn_action.add_theme_stylebox_override("hover", btn_style)
	vbox.add_child(btn_action)
	
	return card

func _bounce_stage_cat() -> void:
	if cat_stage_avatar:
		cat_stage_avatar.pivot_offset = cat_stage_avatar.size * 0.5
		var tw = create_tween()
		tw.tween_property(cat_stage_avatar, "scale", Vector2(1.12, 1.12), 0.08)
		tw.tween_property(cat_stage_avatar, "scale", Vector2(1.0, 1.0), 0.08)
	if anim_stage_cat:
		anim_stage_cat.play("jump")
		var tw2 = create_tween()
		tw2.tween_callback(func():
			if anim_stage_cat:
				anim_stage_cat.play("idle2")
		).set_delay(0.35)

func _on_randomize_outfit() -> void:
	SoundManager.play_bounce()
	var slots = ["clothes", "hats", "bows", "accessories"]
	for slot in slots:
		var owned = GameManager.get_owned_costumes_for_slot(slot)
		if owned.size() > 0 and randf() > 0.15:
			var picked = owned[randi() % owned.size()]
			preview_costumes[slot] = picked["id"]
		else:
			preview_costumes[slot] = ""
			
	_render_stage_cat()
	_bounce_stage_cat()
	_render_dress_items()
	GameManager.emit_signal("show_toast", "🎲 Đã phối set thời trang ngẫu nhiên siêu cưng!")

func _on_unequip_all_outfits() -> void:
	SoundManager.play_click()
	for slot in ["clothes", "hats", "bows", "accessories"]:
		preview_costumes[slot] = ""
	_render_stage_cat()
	_render_dress_items()
	GameManager.emit_signal("show_toast", "Đã cởi bỏ toàn bộ trang phục thử!")

func _on_save_outfit() -> void:
	SoundManager.play_success()
	for slot in preview_costumes.keys():
		var id = preview_costumes[slot]
		# Nếu là món đã sở hữu hoặc cởi ra thì lưu
		if id == "" or GameManager.is_item_owned(id):
			GameManager.equip_costume_slot(slot, id)
		else:
			# Món chưa mua thì reset slot đó
			preview_costumes[slot] = GameManager.equipped_costumes.get(slot, "")
			
	_render_stage_cat()
	_render_dress_items()
	GameManager.emit_signal("show_toast", "✨ Đã lưu bộ trang phục cho Boss thành công!")

# ==============================================================================
# PHẦN 2: CHẾ ĐỘ TRANG TRÍ NHÀ CỬA (ROOM DECORATOR)
# ==============================================================================

func _build_decor_sub_tabs() -> void:
	for child in decor_sub_tabs_container.get_children():
		decor_sub_tabs_container.remove_child(child)
		child.queue_free()
		
	var sub_list = [
		{"id": "all", "name": "Tất Cả", "icon_res": "res://assets/UI/CatUIPaid/slices/cozy_dress/icon_subcat_all.tres"},
		{"id": "beds", "name": "Giường & Đệm", "icon_res": "res://assets/UI/CatUIPaid/slices/cozy_dress/icon_subcat_bed.tres"},
		{"id": "bowls", "name": "Bát Ăn Uống", "icon_res": "res://assets/UI/CatUIPaid/slices/toffee_hud/icon_food_bowl_16x16.tres"},
		{"id": "rugs", "name": "Thảm Lát Sàn", "icon_res": "res://assets/UI/CatUIPaid/slices/cozy_dress/icon_subcat_rug.tres"},
		{"id": "wall", "name": "Tranh & Đèn", "icon_res": "res://assets/UI/CatUIPaid/slices/cozy_dress/icon_subcat_wall.tres"},
		{"id": "plants", "name": "Cây Cảnh", "icon_res": "res://assets/UI/CatUIPaid/slices/cozy_dress/icon_subcat_plant.tres"}
	]
	
	for sub in sub_list:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 32)
		var icon_path = sub.get("icon_res", "")
		if icon_path != "" and (ResourceLoader.exists(icon_path) or FileAccess.file_exists(icon_path)):
			btn.icon = load(icon_path)
			btn.expand_icon = false
			btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text = " " + sub["name"]
		btn.add_theme_font_size_override("font_size", 11)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.pressed.connect(func():
			SoundManager.play_click()
			current_decor_subcat = sub["id"]
			_style_sub_tabs(decor_sub_tabs_container, current_decor_subcat, sub_list)
			_render_decor_items()
		)
		decor_sub_tabs_container.add_child(btn)
		
	_style_sub_tabs(decor_sub_tabs_container, current_decor_subcat, sub_list)

func _render_room_preview() -> void:
	# Cập nhật nhãn đồ nội thất đang đặt
	var bed_item = GameManager.get_shop_item(preview_decor.get("beds", ""))
	slot_bed_lbl.text = bed_item.get("name", "Đệm Thường") if not bed_item.is_empty() else "Trống"
	
	var bowl_item = GameManager.get_shop_item(preview_decor.get("bowls", ""))
	slot_bowl_lbl.text = bowl_item.get("name", "Khay Ăn Đôi") if not bowl_item.is_empty() else "Trống"
	
	var rug_item = GameManager.get_shop_item(preview_decor.get("rugs", ""))
	slot_rug_lbl.text = rug_item.get("name", "Thảm Len") if not rug_item.is_empty() else "Không Thảm"
	
	var wall_item = GameManager.get_shop_item(preview_decor.get("wall", ""))
	slot_wall_lbl.text = wall_item.get("name", "Tranh Monstera") if not wall_item.is_empty() else "Tường Trơn"
	
	var plant_item = GameManager.get_shop_item(preview_decor.get("plants", ""))
	slot_plant_lbl.text = plant_item.get("name", "Cây Bàng") if not plant_item.is_empty() else "Không Cây"
	
	# Tính điểm ấm cúng
	var score = _calc_preview_cozy_score()
	cozy_score_lbl.text = "%d Điểm" % score
	cozy_title_lbl.text = _calc_preview_cozy_title(score)
	if cozy_star_bar:
		cozy_star_bar.value = score
	cozy_buff_lbl.text = "Phúc Lợi: +%d Tâm Trạng mỗi sáng thức dậy ☀️" % int(score / 10)

func _calc_preview_cozy_score() -> int:
	var score: int = 30
	for slot in preview_decor.keys():
		var id = preview_decor[slot]
		if id != "":
			var item = GameManager.get_shop_item(id)
			if not item.is_empty():
				score += item.get("price", 25)
	return score

func _calc_preview_cozy_title(score: int) -> String:
	if score < 60:
		return "Phòng Trọ Đơn Sơ 📦"
	elif score < 110:
		return "Góc Nhỏ Ấm Cúng ☕"
	elif score < 180:
		return "Căn Hộ Sinh Viên Tiện Nghi 🏡"
	else:
		return "Thiên Đường Mèo Hoàng Gia 🏰"

func _render_decor_items() -> void:
	for child in decor_items_grid.get_children():
		decor_items_grid.remove_child(child)
		child.queue_free()
		
	if not GameManager.shop_catalog_data.has("items"):
		return
		
	var items = GameManager.shop_catalog_data["items"]
	for it in items:
		if it["category"] != "decor":
			continue
		if current_decor_subcat != "all" and it["subcategory"] != current_decor_subcat:
			continue
			
		var card = _create_decor_item_card(it)
		decor_items_grid.add_child(card)

func _create_decor_item_card(item: Dictionary) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(245, 110)
	
	var c_style = StyleBoxFlat.new()
	c_style.bg_color = Color(1.0, 0.985, 0.96, 0.98)
	c_style.border_color = Color(0.88, 0.80, 0.72, 1.0)
	c_style.set_border_width_all(1)
	c_style.border_width_bottom = 2
	c_style.set_corner_radius_all(12)
	c_style.content_margin_left = 8
	c_style.content_margin_right = 8
	c_style.content_margin_top = 8
	c_style.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", c_style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	card.add_child(hbox)
	
	# Icon tròn bên trái
	var icon_box = PanelContainer.new()
	icon_box.custom_minimum_size = Vector2(50, 50)
	icon_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var ib_style = StyleBoxFlat.new()
	ib_style.bg_color = Color(0.95, 0.90, 0.85, 1.0)
	ib_style.set_corner_radius_all(25)
	icon_box.add_theme_stylebox_override("panel", ib_style)
	
	var sprite_path = GameManager.get_furniture_sprite_path(item["id"])
	if sprite_path != "" and (ResourceLoader.exists(sprite_path) or FileAccess.file_exists(sprite_path)):
		var tex_rect = TextureRect.new()
		tex_rect.texture = load(sprite_path)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.custom_minimum_size = Vector2(36, 36)
		tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tex_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon_box.add_child(tex_rect)
	else:
		var icon_lbl = Label.new()
		icon_lbl.text = item.get("icon", "🏡")
		icon_lbl.add_theme_font_size_override("font_size", 22)
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		icon_box.add_child(icon_lbl)
	hbox.add_child(icon_box)
	
	# Thông tin chi tiết bên phải
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(vbox)
	
	var name_lbl = Label.new()
	name_lbl.text = item.get("name", "Nội thất")
	name_lbl.add_theme_color_override("font_color", Color(0.3, 0.2, 0.15))
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_lbl)
	
	var subcat = item.get("subcategory", "general")
	var subcat_name = _get_subcat_vietnamese(subcat)
	var type_lbl = Label.new()
	type_lbl.text = "Vị trí: %s" % subcat_name
	type_lbl.add_theme_color_override("font_color", Color(0.55, 0.45, 0.35))
	type_lbl.add_theme_font_size_override("font_size", 10)
	vbox.add_child(type_lbl)
	
	var item_id = item["id"]
	var is_owned = GameManager.is_item_owned(item_id)
	var is_currently_placed = (preview_decor.get(subcat, "") == item_id)
	
	var btn_action = Button.new()
	btn_action.custom_minimum_size = Vector2(0, 26)
	btn_action.add_theme_font_size_override("font_size", 10)
	btn_action.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	var btn_style = StyleBoxFlat.new()
	btn_style.set_corner_radius_all(8)
	btn_style.border_width_bottom = 2
	
	if is_currently_placed:
		btn_action.text = "✔ Đang Đặt"
		btn_style.bg_color = Color(0.28, 0.70, 0.44)
		btn_style.border_color = Color(0.18, 0.50, 0.30)
		btn_action.add_theme_color_override("font_color", Color.WHITE)
		btn_action.pressed.connect(func():
			SoundManager.play_click()
			preview_decor[subcat] = ""
			_render_room_preview()
			_render_decor_items()
		)
	elif is_owned:
		btn_action.text = "🛋️ Đặt Vào Phòng"
		btn_style.bg_color = Color(0.95, 0.55, 0.15)
		btn_style.border_color = Color(0.75, 0.38, 0.08)
		btn_action.add_theme_color_override("font_color", Color.WHITE)
		btn_action.pressed.connect(func():
			SoundManager.play_bounce()
			preview_decor[subcat] = item_id
			_render_room_preview()
			_render_decor_items()
		)
	else:
		btn_action.text = "🛒 Xem Shop (%d 🐟)" % item.get("price", 30)
		btn_style.bg_color = Color(0.90, 0.85, 0.78)
		btn_style.border_color = Color(0.75, 0.70, 0.62)
		btn_action.add_theme_color_override("font_color", Color(0.4, 0.3, 0.2))
		btn_action.pressed.connect(func():
			SoundManager.play_click()
			preview_decor[subcat] = item_id
			_render_room_preview()
			_render_decor_items()
			GameManager.emit_signal("show_toast", "Đang thử bài trí %s! Vào Shop sắm ngay nhé!" % item.get("name", ""))
		)
		
	btn_action.add_theme_stylebox_override("normal", btn_style)
	btn_action.add_theme_stylebox_override("hover", btn_style)
	vbox.add_child(btn_action)
	
	return card

func _get_subcat_vietnamese(subcat: String) -> String:
	match subcat:
		"beds": return "Giường & Đệm 🛏️"
		"bowls": return "Bát Ăn 🥣"
		"rugs": return "Thảm Sàn 🧶"
		"wall": return "Tranh & Đèn 🖼️"
		"plants": return "Cây Cảnh 🪴"
		_: return "Góc Phòng 🏡"

func _on_save_decor() -> void:
	SoundManager.play_success()
	for slot in preview_decor.keys():
		var id = preview_decor[slot]
		if id == "" or GameManager.is_item_owned(id):
			GameManager.equip_decor(slot, id)
		else:
			preview_decor[slot] = GameManager.equipped_decor.get(slot, "")
			
	_render_room_preview()
	_render_decor_items()
	GameManager.emit_signal("show_toast", "🏡 Đã lưu cách bài trí phòng trọ thành công!")

func _on_reset_decor() -> void:
	SoundManager.play_click()
	preview_decor = {
		"beds": "d_bed_terracotta",
		"bowls": "d_bowl_double_auto",
		"rugs": "d_rug_boho",
		"wall": "d_wall_anime_poster",
		"plants": "d_plant_pothos"
	}
	_render_room_preview()
	_render_decor_items()
	GameManager.emit_signal("show_toast", "Đã khôi phục cách bài trí phòng mặc định!")

func _on_snapshot_room() -> void:
	SoundManager.play_purr()
	GameManager.emit_signal("show_toast", "📸 Tách! Đã chụp ảnh lưu niệm căn phòng xinh xắn!")
