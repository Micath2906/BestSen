extends Control

# ShopView.gd - Cửa Hàng Tiệm Tạp Hóa & Phòng Thử Đồ Sen & Boss
# Phân chia 4 danh mục chính: Trang Phục, Trang Trí Nhà Cửa, Đồ Chơi, Đồ Ăn Cho Mèo
# Tích hợp Model Mèo 2/3 màn hình để mặc thử quần áo (Fitting Room Stage)

signal back_to_room
signal open_house_dress_requested(mode)

const CatAnimationFactory = preload("res://scripts/CatAnimationFactory.gd")

# --- HEADER NODES ---
@onready var btn_back: Button = $Header/BtnBack
@onready var fish_balance_lbl: Label = $Header/FishBadge/HBox/FishLabel

# --- FITTING STAGE NODES (2/3 MÀN HÌNH - TRANG PHỤC) ---
@onready var fitting_stage: Control = $FittingStage
@onready var speech_label: Label = get_node_or_null("FittingStage/StagePodium/SpeechBubble/SpeechLabel")
@onready var cat_avatar: TextureRect = $FittingStage/StagePodium/StageCenter/CatAvatar
@onready var hat_rect: TextureRect = $FittingStage/StagePodium/StageCenter/HatRect
@onready var bow_rect: TextureRect = $FittingStage/StagePodium/StageCenter/BowRect
@onready var clothes_rect: TextureRect = $FittingStage/StagePodium/StageCenter/ClothesRect
@onready var acc_rect: TextureRect = $FittingStage/StagePodium/StageCenter/AccRect
@onready var fashion_score_lbl: Label = get_node_or_null("FittingStage/StagePodium/StageCenter/FashionScoreTag/ScoreLabel")

var anim_stage_cat: AnimatedSprite2D = null

@onready var fitting_status_lbl: Label = get_node_or_null("FittingStage/StagePodium/StageFooter/FittingStatusLabel")
@onready var btn_revert_outfit: Button = $FittingStage/StagePodium/StageFooter/BtnRow/BtnRevertOutfit
@onready var btn_stage_action: Button = $FittingStage/StagePodium/StageFooter/BtnRow/BtnStageAction
@onready var lbl_stage_hint: Label = get_node_or_null("FittingStage/StagePodium/StageFooter/LblStageHint")

# --- FURNITURE STAGE NODES (2/3 MÀN HÌNH - XEM TRƯỚC NỘI THẤT) ---
@onready var furniture_stage: Control = $FurnitureStage
@onready var furn_speech_label: Label = $FurnitureStage/FurniturePodium/SpeechBubble/SpeechLabel
@onready var furn_sprite: TextureRect = $FurnitureStage/FurniturePodium/FurnitureCenter/FurnitureSprite
@onready var furn_info_label: Label = $FurnitureStage/FurniturePodium/FurnitureCenter/FurnitureInfoTag/InfoLabel
@onready var furn_status_lbl: Label = $FurnitureStage/FurniturePodium/FurnitureFooter/FurnitureStatusLabel
@onready var btn_apply_furniture: Button = $FurnitureStage/FurniturePodium/FurnitureFooter/BtnRow/BtnApplyFurniture
@onready var btn_buy_furniture: Button = $FurnitureStage/FurniturePodium/FurnitureFooter/BtnRow/BtnBuyFurniture

# --- CATALOG DRAWER NODES (1/3 MÀN HÌNH) ---
@onready var main_tabs_container: HBoxContainer = $CategoryBar/MainTabs
@onready var sub_scroll: ScrollContainer = $SubCategoryBar
@onready var sub_tabs_container: HBoxContainer = $SubCategoryBar/SubTabs
@onready var products_grid: GridContainer = $ProductsScroll/ProductsGrid

# --- MODAL CHI TIẾT ---
@onready var detail_modal: Control = $ItemDetailModal
@onready var detail_icon: Label = $ItemDetailModal/ModalPanel/VBox/IconBox/IconLabel
@onready var detail_tex: TextureRect = $ItemDetailModal/ModalPanel/VBox/IconBox.get_node_or_null("DetailTexture")
@onready var detail_title: Label = $ItemDetailModal/ModalPanel/VBox/TitleLabel
@onready var detail_subcat: Label = $ItemDetailModal/ModalPanel/VBox/SubcatLabel
@onready var detail_desc: Label = $ItemDetailModal/ModalPanel/VBox/DescBox/DescLabel
@onready var detail_boost: Label = $ItemDetailModal/ModalPanel/VBox/BoostBox/BoostLabel
@onready var btn_modal_action: Button = $ItemDetailModal/ModalPanel/VBox/BtnAction
@onready var btn_close_modal: Button = $ItemDetailModal/ModalPanel/VBox/BtnClose

# State
var current_main_cat: String = "costumes"
var current_sub_cat: String = "all"
var selected_item: Dictionary = {}

# Mặc thử đồ tạm thời trên Model Mèo
var preview_costumes: Dictionary = {
	"clothes": "",
	"hats": "",
	"bows": "",
	"accessories": ""
}
var last_previewed_item: Dictionary = {}

const TAB_THEMES = {
	"costumes": {"name": "Trang Phục", "icon": "👔", "color": Color(0.70, 0.53, 0.92), "bg": Color(0.96, 0.92, 1.0)},
	"decor": {"name": "Trang Trí", "icon": "🏡", "color": Color(0.97, 0.50, 0.0), "bg": Color(1.0, 0.93, 0.88)},
	"toys": {"name": "Đồ Chơi", "icon": "🧸", "color": Color(0.02, 0.84, 0.63), "bg": Color(0.88, 0.98, 0.95)},
	"food": {"name": "Đồ Ăn", "icon": "🐟", "color": Color(1.0, 0.72, 0.01), "bg": Color(1.0, 0.96, 0.88)},
}

func _ready() -> void:
	btn_back.pressed.connect(func():
		SoundManager.play_click()
		emit_signal("back_to_room")
	)
	
	btn_close_modal.pressed.connect(func():
		SoundManager.play_click()
		detail_modal.visible = false
	)
	
	btn_modal_action.pressed.connect(_on_modal_action_pressed)
	detail_modal.visible = false
	
	# Đồng bộ trang phục ban đầu từ GameManager vào state mặc thử
	_sync_preview_from_equipped()
	
	# Kết nối các nút trên sân khấu mặc thử (2/3 màn hình)
	btn_revert_outfit.pressed.connect(_on_revert_outfit_pressed)
	btn_stage_action.pressed.connect(_on_stage_action_pressed)
	
	# Kết nối các nút trên sân khấu xem trước nội thất
	if btn_apply_furniture:
		btn_apply_furniture.pressed.connect(_on_apply_furniture_pressed)
	if btn_buy_furniture:
		btn_buy_furniture.pressed.connect(_on_buy_furniture_pressed)
	
	GameManager.stats_changed.connect(_update_fish_balance)
	GameManager.costume_changed.connect(func(_slot, _id):
		_sync_preview_from_equipped()
		_render_cat_model()
		_render_products()
	)
	GameManager.decor_changed.connect(func(_slot, _id):
		if not previewed_furniture_item.is_empty():
			_render_furniture_stage(previewed_furniture_item)
		_render_products()
	)
	
	_update_fish_balance()
	_render_cat_model()
	_build_main_category_tabs()
	_switch_main_category("costumes")

func _sync_preview_from_equipped() -> void:
	preview_costumes = GameManager.equipped_costumes.duplicate()
	last_previewed_item = {}

func _update_fish_balance() -> void:
	fish_balance_lbl.text = "💵 " + GameManager.format_currency(GameManager.fish)

# ==============================================================================
# HỆ THỐNG MODEL MÈO & PHÒNG THỬ ĐỒ 2/3 MÀN HÌNH (FITTING ROOM STAGE)
# ==============================================================================
func _render_cat_model() -> void:
	if anim_stage_cat == null:
		anim_stage_cat = AnimatedSprite2D.new()
		anim_stage_cat.name = "AnimStageCat"
		anim_stage_cat.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		anim_stage_cat.position = Vector2(85, 85)
		anim_stage_cat.scale = Vector2(4.6, 4.6)
		cat_avatar.add_child(anim_stage_cat)
		cat_avatar.self_modulate.a = 0.0

	var cur_avatar_id = GameManager.selected_avatar_id
	anim_stage_cat.sprite_frames = CatAnimationFactory.get_sprite_frames(cur_avatar_id)
	if not anim_stage_cat.is_playing() or anim_stage_cat.animation != "jump":
		anim_stage_cat.play("idle2")
		
	# 1. Cập nhật các lớp trang phục hiển thị pixel-art trên Model Mèo
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

	# 2. Tính toán điểm thời trang thực tế
	var score = _calc_fashion_score(preview_costumes)
	var title = _calc_fashion_title(score)
	if fashion_score_lbl:
		fashion_score_lbl.text = "⭐ Điểm Thời Trang: %d | %s" % [score, title]
	
	# 3. Cập nhật trạng thái thử đồ & Nút hành động trên bục sân khấu
	_update_stage_action_state()

# ==============================================================================
# HỆ THỐNG XEM TRƯỚC NỘI THẤT & PHỤ KIỆN 2/3 MÀN HÌNH (FURNITURE PREVIEW STAGE)
# ==============================================================================
var previewed_furniture_item: Dictionary = {}

func _render_furniture_stage(item: Dictionary) -> void:
	if item.is_empty():
		return
	previewed_furniture_item = item
	var item_id = item.get("id", "")
	var path = GameManager.get_furniture_sprite_path(item_id)
	if path == "":
		path = GameManager.get_item_sprite_path(item_id)
		
	if path != "" and (ResourceLoader.exists(path) or FileAccess.file_exists(path)):
		furn_sprite.texture = GameManager.load_texture(path)
		furn_sprite.visible = true
	else:
		furn_sprite.visible = false
		
	var is_food = (item.get("category", "") == "food")
	var is_toy = (item.get("category", "") == "toys")
	
	# Hiệu ứng nảy juicy squash & stretch
	var base_scale = Vector2(1.2, 1.2) if (is_food or is_toy) else Vector2(0.9, 0.9)
	furn_sprite.scale = base_scale
	var tw = create_tween()
	var pop_scale = Vector2(1.35, 1.35) if (is_food or is_toy) else Vector2(1.1, 1.1)
	tw.tween_property(furn_sprite, "scale", pop_scale, 0.1)
	tw.tween_property(furn_sprite, "scale", base_scale, 0.08)
	
	var boost = item.get("stat_boost", {})
	var boost_str = _format_stat_boost(boost)
	
	if is_food:
		furn_speech_label.text = "Túi đồ ăn %s này thơm ngon bổ dưỡng lắm Sen ơi! 😋" % item.get("name", "")
		furn_info_label.text = "🍲 %s • %s" % [item.get("name", ""), boost_str]
		furn_status_lbl.text = "Đồ ăn tươi ngon • Dùng ngay để tăng chỉ số"
		btn_buy_furniture.visible = true
		btn_apply_furniture.visible = false
		btn_buy_furniture.text = "🛒 Mua Cho Boss Ăn [%s] (%s)" % [item.get("name", ""), GameManager.format_currency(item.get("price", 0))]
		btn_buy_furniture.disabled = (GameManager.fish < item.get("price", 0))
		_style_btn(btn_buy_furniture, Color(1.0, 0.55, 0.12), Color(1, 1, 1))
		return
		
	if is_toy:
		furn_speech_label.text = "Đồ chơi / Cuộn len [%s] này cho Boss vờn bắt vui hết sẩy Sen ơi! 🧶" % item.get("name", "")
		furn_info_label.text = "🧸 %s • %s" % [item.get("name", ""), boost_str]
		furn_status_lbl.text = "Đồ chơi xả stress • Giúp Mèo tăng Dũng Cảm & Tâm Trạng"
		btn_buy_furniture.visible = true
		btn_apply_furniture.visible = false
		btn_buy_furniture.text = "🛒 Mua Cho Boss Chơi [%s] (%s)" % [item.get("name", ""), GameManager.format_currency(item.get("price", 0))]
		btn_buy_furniture.disabled = (GameManager.fish < item.get("price", 0))
		_style_btn(btn_buy_furniture, Color(0.08, 0.72, 0.52), Color(1, 1, 1))
		return
	
	furn_speech_label.text = "Món %s này bài trí vào phòng nhìn xịn xò lắm Sen ơi! 🛋️" % item.get("name", "")
	furn_info_label.text = "🏡 %s • %s" % [item.get("name", ""), boost_str]
	
	var is_owned = GameManager.is_item_owned(item_id)
	var subcat = item.get("subcategory", "")
	var is_equipped = (GameManager.equipped_decor.get(subcat, "") == item_id)
	var req_lvl = item.get("required_level", 1)
	var is_unlocked = (GameManager.cat_mastery_level >= req_lvl)
	
	if is_owned:
		furn_status_lbl.text = "✅ Đã có trong kho đồ phòng trọ KTX"
		btn_buy_furniture.visible = false
		btn_apply_furniture.visible = true
		if is_equipped:
			btn_apply_furniture.text = "✔ Đang Đặt Trong Phòng"
			btn_apply_furniture.disabled = true
			_style_btn(btn_apply_furniture, Color(0.85, 0.82, 0.78), Color(0.5, 0.45, 0.4))
		else:
			btn_apply_furniture.text = "🏡 Đặt Vào Phòng Ngay"
			btn_apply_furniture.disabled = false
			_style_btn(btn_apply_furniture, Color(0.25, 0.72, 0.42), Color(1, 1, 1))
	else:
		furn_status_lbl.text = "Chưa sở hữu • Mở khóa từ Cấp %d (%s)" % [req_lvl, GameManager.get_mastery_info().get("title", "")]
		btn_buy_furniture.visible = true
		btn_apply_furniture.visible = false
		if not is_unlocked:
			btn_buy_furniture.text = "🔒 Cần Cấp %d" % req_lvl
			btn_buy_furniture.disabled = true
			_style_btn(btn_buy_furniture, Color(0.85, 0.82, 0.78), Color(0.5, 0.45, 0.4))
		else:
			btn_buy_furniture.text = "🛒 Mua Ngay [%s] (%s)" % [item.get("name", ""), GameManager.format_currency(item.get("price", 0))]
			btn_buy_furniture.disabled = (GameManager.fish < item.get("price", 0))
			_style_btn(btn_buy_furniture, Color(1.0, 0.55, 0.12), Color(1, 1, 1))

func _on_apply_furniture_pressed() -> void:
	if previewed_furniture_item.is_empty():
		return
	SoundManager.play_click()
	var item_id = previewed_furniture_item.get("id", "")
	var subcat = previewed_furniture_item.get("subcategory", "general")
	GameManager.equip_decor(subcat, item_id)
	SoundManager.play_success()
	GameManager.emit_signal("show_toast", "🎉 Đã bài trí [%s] vào phòng trọ thành công! 🏡" % previewed_furniture_item.get("name", ""))
	_render_furniture_stage(previewed_furniture_item)
	_render_products()

func _on_buy_furniture_pressed() -> void:
	if previewed_furniture_item.is_empty():
		return
	_open_detail(previewed_furniture_item)

func _calc_fashion_score(costumes_dict: Dictionary) -> int:
	var score = 40 # Điểm tự tin gốc của Boss
	for slot in ["clothes", "hats", "bows", "accessories"]:
		var id = costumes_dict.get(slot, "")
		if id != "":
			var it = GameManager.get_shop_item(id)
			var boost = it.get("stat_boost", {})
			score += boost.get("mood", 15) + boost.get("courage", 10)
	return score

func _calc_fashion_title(score: int) -> String:
	if score < 50:
		return "Mộc Mạc Dễ Thương 🐱"
	elif score < 90:
		return "Tân Sinh Viên Gọn Gàng 🎒"
	elif score < 140:
		return "Fashionista Xóm Trọ 🌟"
	elif score < 200:
		return "Icon Thời Trang Học Đường 👑"
	else:
		return "Thủ Khoa Phong Cách Đỉnh Cao 💎"

func _update_stage_action_state() -> void:
	# Kiểm tra xem có món nào đang mặc thử mà chưa sở hữu không
	var unowned_item_in_preview: Dictionary = {}
	for slot in ["clothes", "hats", "bows", "accessories"]:
		var id = preview_costumes.get(slot, "")
		if id != "" and not GameManager.is_item_owned(id):
			unowned_item_in_preview = GameManager.get_shop_item(id)
			break
			
	if not fitting_status_lbl or not btn_stage_action:
		return
		
	var is_same_as_equipped = (preview_costumes == GameManager.equipped_costumes)
	
	if not unowned_item_in_preview.is_empty():
		# Đang mặc thử đồ trong tiệm (chưa mua)
		fitting_status_lbl.text = "👗 Đang Thử: %s (+%s ⭐)" % [
			unowned_item_in_preview.get("name", ""),
			unowned_item_in_preview.get("stat_boost", {}).get("mood", 15)
		]
		btn_stage_action.text = "🛒 Mua Ngay [%s] (%s)" % [
			unowned_item_in_preview.get("name", ""),
			GameManager.format_currency(unowned_item_in_preview.get("price", 0))
		]
		btn_stage_action.disabled = false
		_style_btn(btn_stage_action, Color(1.0, 0.55, 0.12), Color(1, 1, 1))
	elif not is_same_as_equipped:
		# Toàn bộ đồ thử đều đã sở hữu nhưng chưa lưu thành trang phục chính
		fitting_status_lbl.text = "✨ Đã phối xong set đồ mới từ tủ đồ của Boss!"
		btn_stage_action.text = "💾 Mặc Luôn Set Này"
		btn_stage_action.disabled = false
		_style_btn(btn_stage_action, Color(0.25, 0.72, 0.42), Color(1, 1, 1))
	else:
		fitting_status_lbl.text = "🐾 Boss Đang Mặc Trang Phục Hiện Tại"
		btn_stage_action.text = "✔ Đang Mặc Bộ Này"
		btn_stage_action.disabled = true
		_style_btn(btn_stage_action, Color(0.85, 0.82, 0.78), Color(0.5, 0.45, 0.4))

func _try_on_costume(item: Dictionary) -> void:
	if item.is_empty() or not item.has("id"):
		return
	SoundManager.play_card_pop()
	last_previewed_item = item
	var subcat = item.get("subcategory", "clothes")
	
	# Nếu đang mặc đúng món này, bấm lại sẽ tháo ra (toggle)
	if preview_costumes.get(subcat, "") == item["id"]:
		preview_costumes[subcat] = ""
		speech_label.text = "Đã tháo %s rồi Sen ơi! 🐾" % item["name"]
	else:
		preview_costumes[subcat] = item["id"]
		# Phản hồi thoại siêu đáng yêu theo từng nhóm đồ
		match subcat:
			"hats":
				speech_label.text = "Chiếc %s này đội lên chuẩn style Boss ngầu đét! 🧢" % item["name"]
			"clothes":
				speech_label.text = "Áo %s vừa vặn mà tôn dáng Boss ghê Sen ơi! 🧥" % item["name"]
			"bows":
				speech_label.text = "Thắt %s xinh xắn này vào nhìn cưng xỉu luôn! 🎀" % item["name"]
			"accessories":
				speech_label.text = "Kính/Balo %s phối vào trông như thủ khoa xóm trọ! 🕶️" % item["name"]
			_:
				speech_label.text = "Sen thấy Boss mặc %s có hợp gu không? ✨" % item["name"]
				
	# Hiệu ứng nảy avatar mèo khi mặc thử
	var tw = create_tween()
	tw.tween_property(cat_avatar, "scale", Vector2(1.15, 1.15), 0.08)
	tw.tween_property(cat_avatar, "scale", Vector2(1.0, 1.0), 0.08)
	if anim_stage_cat:
		anim_stage_cat.play("jump")
		tw.tween_callback(func():
			if anim_stage_cat:
				anim_stage_cat.play("idle2")
		).set_delay(0.35)
	
	_render_cat_model()
	_render_products()

func _on_revert_outfit_pressed() -> void:
	SoundManager.play_click()
	_sync_preview_from_equipped()
	speech_label.text = "Đã quay về set đồ gốc của Boss! 🐾"
	_render_cat_model()
	_render_products()

func _on_stage_action_pressed() -> void:
	# Tìm món chưa sở hữu để mua
	var unowned_item: Dictionary = {}
	for slot in ["clothes", "hats", "bows", "accessories"]:
		var id = preview_costumes.get(slot, "")
		if id != "" and not GameManager.is_item_owned(id):
			unowned_item = GameManager.get_shop_item(id)
			break
			
	if not unowned_item.is_empty():
		_open_detail(unowned_item)
	else:
		# Mặc luôn set đồ này
		for slot in ["clothes", "hats", "bows", "accessories"]:
			var id = preview_costumes.get(slot, "")
			GameManager.equip_costume_slot(slot, id)
		SoundManager.play_success()
		GameManager.emit_signal("show_toast", "🎉 Đã đổi sang set đồ mới thành công! ✨")
		_sync_preview_from_equipped()
		_render_cat_model()
		_render_products()

# ==============================================================================
# HỆ THỐNG DANH MỤC & DANH SÁCH MẶT HÀNG 1/3 MÀN HÌNH (SHOP CATALOG DRAWER)
# ==============================================================================
func _build_main_category_tabs() -> void:
	for child in main_tabs_container.get_children():
		main_tabs_container.remove_child(child)
		child.queue_free()
		
	var cat_keys = ["costumes", "decor", "toys", "food"]
	for key in cat_keys:
		var theme_data = TAB_THEMES[key]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 36)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.text = "%s %s" % [theme_data["icon"], theme_data["name"]]
		btn.add_theme_font_size_override("font_size", 11)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.pressed.connect(func(): _switch_main_category(key))
		main_tabs_container.add_child(btn)

func _switch_main_category(cat_id: String) -> void:
	SoundManager.play_click()
	current_main_cat = cat_id
	current_sub_cat = "all"
	
	# Chuyển đổi giữa 2 sân khấu 2/3 màn hình: Thử Quần Áo Mèo vs Xem Trước Nội Thất
	if current_main_cat == "costumes":
		fitting_stage.visible = true
		furniture_stage.visible = false
		$Header/Title.text = "🛍️ PHÒNG THỬ ĐỒ BOSS"
		_render_cat_model()
	else:
		fitting_stage.visible = false
		furniture_stage.visible = true
		$Header/Title.text = "🛋️ XEM TRƯỚC NỘI THẤT & PHỤ KIỆN"
		var first_item = _get_first_item_for_cat(cat_id)
		if not first_item.is_empty():
			_render_furniture_stage(first_item)
	
	# Cập nhật style nút chính
	var cat_keys = ["costumes", "decor", "toys", "food"]
	var children = main_tabs_container.get_children()
	var n = mini(children.size(), cat_keys.size())
	for i in range(n):
		var btn: Button = children[i]
		var key = cat_keys[i]
		var theme_data = TAB_THEMES[key]
		var is_active = (key == current_main_cat)
		
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(10)
		style.set_border_width_all(1)
		style.border_width_bottom = 2
		style.content_margin_top = 4
		style.content_margin_bottom = 4
		
		if is_active:
			style.bg_color = theme_data["color"]
			style.border_color = theme_data["color"].darkened(0.2)
			btn.add_theme_color_override("font_color", Color(1, 1, 1))
		else:
			style.bg_color = theme_data["bg"]
			style.border_color = theme_data["color"].lightened(0.3)
			btn.add_theme_color_override("font_color", Color(0.35, 0.28, 0.22))
			
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)

	# Lời chào / phản hồi thoại của Boss khi đổi danh mục
	match cat_id:
		"costumes":
			if speech_label:
				speech_label.text = "Sen ơi, thử đồ cho Boss đi nào! Quần áo xịn lắm! ✨"
		"decor":
			if furn_speech_label:
				furn_speech_label.text = "Nội thất ấm cúng trang trí cho phòng trọ xịn mịn nè! 🏡"
		"toys":
			if furn_speech_label:
				furn_speech_label.text = "Đồ chơi xả stress, vần nhau là Boss thích mê! 🧶"
		"food":
			if furn_speech_label:
				furn_speech_label.text = "Toàn món ngon hảo hạng, mua tẩm bổ cho Boss nha Sen! 🐟"

	_build_sub_category_tabs()
	_render_products()

func _get_first_item_for_cat(cat_id: String) -> Dictionary:
	if not GameManager.shop_catalog_data.has("items"):
		return {}
	for it in GameManager.shop_catalog_data["items"]:
		if it["category"] == cat_id:
			return it
	return {}

func _build_sub_category_tabs() -> void:
	for child in sub_tabs_container.get_children():
		sub_tabs_container.remove_child(child)
		child.queue_free()
		
	var cat_info = _get_cat_data(current_main_cat)
	var sub_list = cat_info.get("subcategories", [])
	
	for sub in sub_list:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(0, 28)
		btn.text = "%s %s" % [sub["icon"], sub["name"]]
		btn.add_theme_font_size_override("font_size", 10)
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		btn.pressed.connect(func(): _switch_sub_category(sub["id"]))
		sub_tabs_container.add_child(btn)
		
	_style_sub_tabs()

func _switch_sub_category(sub_id: String) -> void:
	SoundManager.play_click()
	current_sub_cat = sub_id
	_style_sub_tabs()
	_render_products()

func _style_sub_tabs() -> void:
	var cat_info = _get_cat_data(current_main_cat)
	var sub_list = cat_info.get("subcategories", [])
	var children = sub_tabs_container.get_children()
	var n = mini(children.size(), sub_list.size())
	
	for i in range(n):
		var btn: Button = children[i]
		var sub_id = sub_list[i]["id"]
		var is_active = (sub_id == current_sub_cat)
		
		var style = StyleBoxFlat.new()
		style.set_corner_radius_all(12)
		style.set_border_width_all(1)
		style.border_width_bottom = 2
		style.content_margin_left = 8
		style.content_margin_right = 8
		style.content_margin_top = 2
		style.content_margin_bottom = 2
		
		if is_active:
			style.bg_color = Color(0.35, 0.25, 0.18, 0.9)
			style.border_color = Color(0.2, 0.15, 0.1)
			btn.add_theme_color_override("font_color", Color(1, 1, 1))
		else:
			style.bg_color = Color(1.0, 0.97, 0.92, 0.9)
			style.border_color = Color(0.85, 0.78, 0.70)
			btn.add_theme_color_override("font_color", Color(0.4, 0.32, 0.25))
			
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)

func _get_cat_data(cat_id: String) -> Dictionary:
	if not GameManager.shop_catalog_data.has("main_categories"):
		return {}
	for c in GameManager.shop_catalog_data["main_categories"]:
		if c["id"] == cat_id:
			return c
	return {}

func _render_products() -> void:
	for child in products_grid.get_children():
		products_grid.remove_child(child)
		child.queue_free()
		
	if not GameManager.shop_catalog_data.has("items"):
		return
		
	var items = GameManager.shop_catalog_data["items"]
	for it in items:
		if it["category"] != current_main_cat:
			continue
		if current_sub_cat != "all" and it["subcategory"] != current_sub_cat:
			continue
			
		var card = _create_product_card(it)
		products_grid.add_child(card)

func _create_product_card(item: Dictionary) -> PanelContainer:
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(248, 100)
	
	var is_owned = GameManager.is_item_owned(item["id"])
	var is_trying = (preview_costumes.values().has(item["id"]))
	var req_lvl = item.get("required_level", 1)
	var is_level_unlocked = (GameManager.cat_mastery_level >= req_lvl)
	
	var c_style = StyleBoxFlat.new()
	c_style.bg_color = Color(1.0, 0.985, 0.96, 0.98)
	if is_trying:
		c_style.bg_color = Color(1.0, 0.95, 0.90, 1.0)
		c_style.border_color = Color(1.0, 0.55, 0.1, 1.0)
		c_style.set_border_width_all(2)
	else:
		c_style.border_color = Color(0.88, 0.82, 0.75, 1.0)
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
	
	# 1. Cột trái: Khung tròn Icon lớn (Hiển thị sprite pixel gốc nếu có)
	var icon_box = PanelContainer.new()
	icon_box.custom_minimum_size = Vector2(44, 44)
	icon_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var ib_style = StyleBoxFlat.new()
	ib_style.bg_color = Color(0.96, 0.92, 0.86, 1.0)
	ib_style.border_color = Color(0.85, 0.75, 0.65, 1.0)
	ib_style.set_border_width_all(1)
	ib_style.set_corner_radius_all(22)
	icon_box.add_theme_stylebox_override("panel", ib_style)
	
	var sprite_path = GameManager.get_item_sprite_path(item["id"])
	if sprite_path != "" and (ResourceLoader.exists(sprite_path) or FileAccess.file_exists(sprite_path)):
		var tex_rect = TextureRect.new()
		tex_rect.texture = GameManager.load_texture(sprite_path)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.custom_minimum_size = Vector2(34, 34)
		tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tex_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon_box.add_child(tex_rect)
	else:
		var icon_lbl = Label.new()
		icon_lbl.text = item.get("icon", "📦")
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		icon_lbl.add_theme_font_size_override("font_size", 20)
		icon_box.add_child(icon_lbl)
	hbox.add_child(icon_box)
	
	# 2. Cột phải: Thông tin sản phẩm & Nút thao tác
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 3)
	
	var name_lbl = Label.new()
	name_lbl.text = item["name"]
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.add_theme_color_override("font_color", Color(0.3, 0.22, 0.15))
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	vbox.add_child(name_lbl)
	
	# Giá & Buff
	var boost_str = _format_stat_boost(item.get("stat_boost", {}))
	var price_lbl = Label.new()
	price_lbl.text = "%s • %s" % [GameManager.format_currency(item["price"]), boost_str]
	price_lbl.add_theme_font_size_override("font_size", 9)
	price_lbl.add_theme_color_override("font_color", Color(0.85, 0.45, 0.05))
	vbox.add_child(price_lbl)
	
	# Hàng nút thao tác
	var btn_row = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 6)
	btn_row.size_flags_vertical = Control.SIZE_SHRINK_END
	
	if item["category"] == "costumes":
		# Nút Mặc Thử trực tiếp lên Model Mèo 2/3 màn hình
		var try_btn = Button.new()
		try_btn.custom_minimum_size = Vector2(0, 26)
		try_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		try_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if is_trying:
			try_btn.text = "👗 Đang Thử"
			_style_btn(try_btn, Color(1.0, 0.55, 0.12), Color(1, 1, 1))
		else:
			try_btn.text = "👗 Mặc Thử"
			_style_btn(try_btn, Color(0.70, 0.55, 0.90), Color(1, 1, 1))
		try_btn.pressed.connect(func(): _try_on_costume(item))
		btn_row.add_child(try_btn)
		
		# Nút Mua / Sở hữu
		var buy_btn = Button.new()
		buy_btn.custom_minimum_size = Vector2(0, 26)
		buy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buy_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		if not is_level_unlocked:
			buy_btn.text = "🔒 Cấp %d" % req_lvl
			buy_btn.disabled = true
			_style_btn(buy_btn, Color(0.85, 0.82, 0.78), Color(0.5, 0.45, 0.4))
		elif is_owned:
			buy_btn.text = "✔ Đã Có"
			buy_btn.disabled = true
			_style_btn(buy_btn, Color(0.25, 0.72, 0.42), Color(1, 1, 1))
		else:
			buy_btn.text = "%s Mua" % GameManager.format_currency(item["price"])
			_style_btn(buy_btn, Color(0.95, 0.45, 0.05), Color(1, 1, 1))
			buy_btn.pressed.connect(func(): _open_detail(item))
		btn_row.add_child(buy_btn)
	else:
		# Các danh mục Nội Thất, Đồ Chơi, Đồ Ăn: Xem trước trên sân khấu FurnitureStage
		var preview_btn = Button.new()
		preview_btn.custom_minimum_size = Vector2(0, 26)
		preview_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		preview_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if item.get("category") == "food":
			preview_btn.text = "🍲 Xem Món"
		elif item.get("category") == "toys":
			preview_btn.text = "🧶 Xem Mẫu"
		else:
			preview_btn.text = "🛋️ Xem Mẫu"
		_style_btn(preview_btn, Color(0.85, 0.65, 0.35), Color(1, 1, 1))
		preview_btn.pressed.connect(func():
			SoundManager.play_click()
			_render_furniture_stage(item)
		)
		btn_row.add_child(preview_btn)
		
		var act_btn = Button.new()
		act_btn.custom_minimum_size = Vector2(0, 26)
		act_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		act_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		if not is_level_unlocked:
			act_btn.text = "🔒 Cần Cấp %d" % req_lvl
			act_btn.disabled = true
			_style_btn(act_btn, Color(0.85, 0.82, 0.78), Color(0.5, 0.45, 0.4))
		elif is_owned and item["category"] == "decor":
			var subcat = item.get("subcategory", "")
			if GameManager.equipped_decor.get(subcat, "") == item["id"]:
				act_btn.text = "✔ Đang Đặt"
				act_btn.disabled = true
				_style_btn(act_btn, Color(0.85, 0.82, 0.78), Color(0.5, 0.45, 0.4))
			else:
				act_btn.text = "🏡 Đặt Phòng"
				_style_btn(act_btn, Color(0.25, 0.72, 0.42), Color(1, 1, 1))
				act_btn.pressed.connect(func():
					GameManager.equip_decor(subcat, item["id"])
					_render_furniture_stage(item)
					_render_products()
				)
		else:
			act_btn.text = "%s Mua" % GameManager.format_currency(item["price"])
			_style_btn(act_btn, Color(1.0, 0.55, 0.10), Color(1, 1, 1))
			act_btn.pressed.connect(func(): _open_detail(item))
		btn_row.add_child(act_btn)
		
		# Nhấp vào thẻ lập tức xem mẫu trên sân khấu FurnitureStage
		card.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
				SoundManager.play_purr()
				_render_furniture_stage(item)
		)
		
	vbox.add_child(btn_row)
	hbox.add_child(vbox)
	card.add_child(hbox)
	return card

func _style_btn(btn: Button, bg_color: Color, text_color: Color) -> void:
	var s = StyleBoxFlat.new()
	s.bg_color = bg_color
	s.border_color = bg_color.darkened(0.25)
	s.set_border_width_all(1)
	s.border_width_bottom = 2
	s.set_corner_radius_all(8)
	s.content_margin_left = 6
	s.content_margin_right = 6
	btn.add_theme_stylebox_override("normal", s)
	btn.add_theme_stylebox_override("hover", s)
	btn.add_theme_stylebox_override("pressed", s)
	btn.add_theme_stylebox_override("disabled", s)
	btn.add_theme_color_override("font_color", text_color)
	btn.add_theme_color_override("font_disabled_color", text_color)
	btn.add_theme_font_size_override("font_size", 10)

func _format_stat_boost(boost: Dictionary) -> String:
	var parts = []
	if boost.has("hunger"): parts.append("No +%d" % boost["hunger"])
	if boost.has("courage"): parts.append("Dũng +%d" % boost["courage"])
	if boost.has("mood"): parts.append("Mood +%d" % boost["mood"])
	return " • ".join(parts) if parts.size() > 0 else "Thời Trang"

func _open_detail(item: Dictionary) -> void:
	SoundManager.play_card_pop()
	selected_item = item
	
	var sprite_path = GameManager.get_item_sprite_path(item.get("id", ""))
	if sprite_path != "" and (ResourceLoader.exists(sprite_path) or FileAccess.file_exists(sprite_path)):
		var tex = GameManager.load_texture(sprite_path)
		if tex and detail_tex:
			detail_tex.texture = tex
			detail_tex.visible = true
			detail_icon.visible = false
		elif detail_icon:
			detail_icon.visible = true
			detail_icon.text = item.get("icon", "📦")
	elif detail_icon:
		if detail_tex:
			detail_tex.visible = false
		detail_icon.visible = true
		detail_icon.text = item.get("icon", "📦")
		
	detail_title.text = item["name"]
	
	var sub_name = item.get("subcategory", "")
	detail_subcat.text = "Phân Loại: %s • Yêu Cầu Cấp %d" % [sub_name.capitalize(), item.get("required_level", 1)]
	detail_desc.text = item.get("desc", "")
	detail_boost.text = "Hiệu Quả: %s" % _format_stat_boost(item.get("stat_boost", {}))
	
	btn_modal_action.text = "🛒 MUA NGAY [%s] 🟡" % GameManager.format_currency(item["price"])
	detail_modal.visible = true
	
	var panel = $ItemDetailModal/ModalPanel
	panel.scale = Vector2(0.9, 0.9)
	var tw = create_tween()
	tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.15).set_trans(Tween.TRANS_BACK)

func _on_modal_action_pressed() -> void:
	if selected_item.is_empty():
		return
	var res = GameManager.buy_shop_item(selected_item["id"])
	if res["ok"]:
		SoundManager.play_success()
		GameManager.emit_signal("show_toast", "🎉 Mua thành công [%s]! 🐾" % selected_item["name"])
		speech_label.text = "Tuyệt vời Sen ơi! Boss có [%s] mới rồi! 💖" % selected_item["name"]
		detail_modal.visible = false
		
		# Nếu là trang phục, tự động mặc luôn lên Model Mèo
		if selected_item["category"] == "costumes":
			var subcat = selected_item.get("subcategory", "clothes")
			preview_costumes[subcat] = selected_item["id"]
			GameManager.equip_costume_slot(subcat, selected_item["id"])
		elif selected_item["category"] == "decor":
			_render_furniture_stage(selected_item)
			
		_render_cat_model()
		_render_products()
	else:
		SoundManager.play_fail()
		GameManager.emit_signal("show_toast", "❌ " + res["reason"])
