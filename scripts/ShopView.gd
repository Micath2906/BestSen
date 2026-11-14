extends Control

# ShopView.gd - Cửa Hàng Tiệm Tạp Hóa & Phòng Thử Đồ Sen & Boss
# Phân chia 4 danh mục chính: Trang Phục, Trang Trí Nhà Cửa, Đồ Chơi, Đồ Ăn Cho Mèo
# Tích hợp Model Mèo 2/3 màn hình để mặc thử quần áo (Fitting Room Stage)
# Tích hợp Sprite Pixel Art vẽ tay độc quyền & Phản hồi xúc giác JuicyButton

signal back_to_room
signal open_house_dress_requested(mode)

const CatAnimationFactory = preload("res://scripts/CatAnimationFactory.gd")
const JuicyButtonScript = preload("res://scripts/ui/JuicyButton.gd")

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

const SUBCAT_NAMES = {
	"all": "Tất Cả",
	"clothes": "Quần Áo",
	"hats": "Mũ Nón",
	"bows": "Nơ & Khăn",
	"accessories": "Phụ Kiện",
	"beds": "Giường Đệm",
	"bowls": "Bát Ăn",
	"rugs": "Thảm Trải",
	"wall": "Treo Tường",
	"plants": "Cây Cảnh",
	"comfort": "Tiện Ích",
	"wands": "Cần Câu",
	"balls": "Bóng Len",
	"scratchers": "Cây Cào",
	"boxes": "Thùng Chui",
	"kibble": "Hạt Khô",
	"pate": "Pate Tươi",
	"treats": "Bánh Thưởng",
	"catnip": "Bạc Hà Mèo"
}

# Kho thoại cảm xúc độc quyền cho từng món đồ trong tiệm
const ITEM_SPEECHES = {
	# Trang phục
	"c_hoodie_student": "Áo hoodie sinh viên ấm áp ghê! Đi học sáng sớm không lo gió lạnh Sen ơi! 🎒",
	"c_sweater_wool": "Áo len đan tay mềm ơi là mềm! Mặc vào như được cuộn trong chăn bông! 🧶",
	"c_grad_robe": "Meo! Boss sắp thành Thạc Sĩ Bắt Chuột rồi! Áo cử nhân uy quyền ghê chưa! 🎓",
	"c_hat_cap": "Mũ lưỡi trai xoay ngược một phát là Boss biến thành Rapper xóm trọ liền! 🧢",
	"c_hat_bunny": "Đội tai thỏ vào Boss nhảy tưng tưng như thỏ con luôn nè Sen! Dễ thương xỉu! 🐰",
	"c_hat_helmet": "An toàn là bạn! Lên xe máy chở Boss đi dạo nhớ cài quai nón nha Sen! 🛵",
	"c_bow_red": "Nơ đỏ bảnh bao quý tộc! Hôm nay Boss là quý ông lịch thiệp nhất khu trọ! 🎀",
	"c_scarf_volunteer": "Khăn rằn Mùa Hè Xanh! Boss sẵn sàng cùng Sen đi tình nguyện dọn dẹp xóm làng! 🌿",
	"c_glasses_smart": "Đeo kính tròn vào trông Boss thông thái hẳn ra! 1 cộng 1 bằng 1 bát pate! 🤓",
	"c_backpack_yellow": "Balo cóc vàng nhỏ xinh! Đựng vừa 2 thanh churu và 1 nắm hạt cá hồi! 🎒",

	# Nội thất & Trang trí
	"d_bed_box": "Thùng carton là chân ái của cuộc đời Boss! Mùi giấy thơm nức mũi! 📦",
	"d_bowl_basic": "Bát ăn màu xanh mát mắt! Đựng hạt hay pate nhìn cũng thấy ngon miệng hơn! 🥣",
	"d_bed_mobile_blue": "Nệm nỉ êm ái! Đặt góc phòng là Boss có ngay chỗ ngủ trưa đón nắng! 🛋️",
	"d_scratch_mobile_tan": "Cây cào móng gỗ sisal! Cào đã đời không sợ Boss cào xước sofa của chủ trọ nữa! 🪵",
	"d_bed_terracotta": "Đệm nhung tròn màu gốm nung ấm áp! Cuộn tròn ngủ ở đây thì hết sẩy! 🛏️",
	"d_bed_bunk": "Giường tầng mini xịn đét! Boss nằm tầng 2 quan sát toàn bộ phòng trọ như một vị vua! 🏰",
	"d_tray_ceramic": "Khay sứ đôi kiểu Nhật sang trọng! Một bên pate, một bên súp thưởng, tuyệt vời! 🍽️",
	"d_tray_fountain": "Thác nước tuần hoàn róc rách! Nước chảy liên tục kích thích Boss uống nhiều nước hơn! ⛲",
	"d_rug_boho": "Thảm thổ cẩm dệt tay vintage! Trải trước cửa phòng nhìn ấm cúng như quán cà phê! 🎨",
	"d_rug_paw": "Thảm lông cừu dấu chân mèo mềm mịn! Đặt chân lên là thấy êm ái thư thái! 🐾",
	"d_wall_cactus": "Tranh xương rồng mộc mạc! Tạo cảm giác xanh mát, kiên cường sinh tồn nơi đất khách! 🌵",
	"d_wall_window_sun": "Cửa sổ kính đón nắng sớm rực rỡ! Boss tha hồ nằm sưởi lông và ngắm chim sẻ! 🪟",
	"d_plant_fig": "Chậu bàng Singapore xanh mướt! Lọc không khí trong lành cho căn phòng trọ nhỏ! 🪴",
	"d_plant_succulent": "Sen đá để bàn nhỏ xinh! Dễ chăm sóc, mang lại may mắn và tài lộc cho Sen thi cử! 🌱",
	"d_insulation_curtain": "Rèm cách nhiệt chống nắng trưa gắt gao! Phòng trọ mát rượi Boss ngủ ngon lành! ☀️",
	"d_mini_fan": "Quạt gió mini để bàn kêu ro ro mát rượi! Cứu cánh những buổi trưa hè oi ả! 💨",

	# Đồ chơi
	"t_wand_feather": "Cần câu lông vũ chuông leng keng! Vung một cái là Boss nhảy phắt lên chụp liền! 🪶",
	"t_wand_mouse": "Chuột bông nhấp nháy đèn! Con mồi ảo này Boss sẽ rượt đuổi không tha! 🐭",
	"t_ball_rainbow": "Cuộn len cầu vồng tinh nghịch! Boss vần quanh phòng cả ngày không biết chán! 🧶",
	"t_yarn_ball": "Cuộn len nâu mộc mạc! Vần một cái là lăn tít vào gầm giường, Sen nhặt hộ Boss với! 🧶",
	"t_ball_bell": "Bóng chuông lục lạc rộn rã! Lắc lắc nghe vui tai, xả stress sau giờ học căng thẳng! 🔔",
	"t_scratch_post": "Trụ cào sisal kèm bệ nhảy! Boss vừa mài móng vừa nhảy lên ngắm Sen học bài! 🪜",
	"t_scratch_mushroom": "Cây nấm đỏ cổ tích! Cào móng mà cảm giác như đang lạc vào xứ sở thần tiên! 🍄",
	"t_box_mochi": "Thùng carton Mochi thần thánh! Vừa vặn dáng mèo, chui vào là an toàn tuyệt đối! 📦",
	"t_tunnel_spring": "Ống chui lò xo gấp gọn! Boss phục kích từ trong đường hầm vồ chân Sen nè! 🌀",

	# Đồ ăn & Thực phẩm
	"f_kibble_salmon": "Hạt cá hồi sốt kem béo ngậy! Cung cấp omega-3 giúp lông Boss mượt như nhung! 🐟",
	"f_kibble_chicken": "Hạt thịt gà và ngũ cốc giòn tan! Nạp đầy năng lượng cho Boss chạy nhảy cả ngày! 🍗",
	"f_pate_tuna": "Lon pate cá ngừ thạch sương sáo thanh mát! Mùi thơm nức mũi, Boss thèm nhỏ dãi rồi! 🥫",
	"f_pate_beef": "Pate bò hầm rau củ thượng hạng! Dinh dưỡng đậm đà bồi bổ sức khỏe cho Boss! 🥩",
	"f_treat_churu": "Súp thưởng churu cá hồi béo ngậy! Món khoái khẩu nhất trần đời, Sen bóp là Boss liếm sạch! 🥄",
	"f_treat_freeze_dry": "Ức gà sấy thăng hoa giòn rụm! Nguyên chất 100% không chất bảo quản, ăn là mê! 🍗",
	"f_catnip_grass": "Cỏ lúa mạch tươi mát! Giúp thanh lọc ruột và tiêu búi lông hiệu quả cho Boss! 🌾",
	"f_catnip_ball": "Quả lăn bạc hà mèo xoay 360 độ! Boss liếm một hơi là ngất ngây phê pha luôn Sen ơi! 🌿"
}

func _ready() -> void:
	# Gắn phản hồi xúc giác JuicyButton cho các nút cố định
	JuicyButtonScript.attach_juice(btn_back, true)
	JuicyButtonScript.attach_juice(btn_close_modal, true)
	JuicyButtonScript.attach_juice(btn_modal_action, true)
	JuicyButtonScript.attach_juice(btn_revert_outfit, true)
	JuicyButtonScript.attach_juice(btn_stage_action, true)
	if btn_apply_furniture:
		JuicyButtonScript.attach_juice(btn_apply_furniture, true)
	if btn_buy_furniture:
		JuicyButtonScript.attach_juice(btn_buy_furniture, true)

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
	
	# Đảm bảo cấu hình TextureFilter gần nhất (Pixel Perfect) cho các lớp quần áo
	for r in [hat_rect, bow_rect, clothes_rect, acc_rect, furn_sprite]:
		if r:
			r.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
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
		
	# 1. Cập nhật các lớp trang phục hiển thị pixel-art trên Model Mèo dùng GameManager.load_texture
	var hat_id = preview_costumes.get("hats", "")
	if hat_id != "":
		var path = GameManager.get_costume_sprite_path(hat_id)
		if path != "" and (ResourceLoader.exists(path) or FileAccess.file_exists(path)):
			hat_rect.texture = GameManager.load_texture(path)
			hat_rect.visible = true
		else:
			hat_rect.visible = false
	else:
		hat_rect.visible = false
		
	var bow_id = preview_costumes.get("bows", "")
	if bow_id != "":
		var path = GameManager.get_costume_sprite_path(bow_id)
		if path != "" and (ResourceLoader.exists(path) or FileAccess.file_exists(path)):
			bow_rect.texture = GameManager.load_texture(path)
			bow_rect.visible = true
		else:
			bow_rect.visible = false
	else:
		bow_rect.visible = false
		
	var clothes_id = preview_costumes.get("clothes", "")
	if clothes_id != "":
		var path = GameManager.get_costume_sprite_path(clothes_id)
		if path != "" and (ResourceLoader.exists(path) or FileAccess.file_exists(path)):
			clothes_rect.texture = GameManager.load_texture(path)
			clothes_rect.visible = true
		else:
			clothes_rect.visible = false
	else:
		clothes_rect.visible = false
		
	var acc_id = preview_costumes.get("accessories", "")
	if acc_id != "":
		var path = GameManager.get_costume_sprite_path(acc_id)
		if path != "" and (ResourceLoader.exists(path) or FileAccess.file_exists(path)):
			acc_rect.texture = GameManager.load_texture(path)
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
	
	# Lấy câu thoại riêng biệt của Mochi
	var speech_text = ITEM_SPEECHES.get(item_id, "")
	
	if is_food:
		if speech_text == "":
			speech_text = "Túi đồ ăn %s này thơm ngon bổ dưỡng lắm Sen ơi! 😋" % item.get("name", "")
		furn_speech_label.text = speech_text
		furn_info_label.text = "🍲 %s • %s" % [item.get("name", ""), boost_str]
		furn_status_lbl.text = "Đồ ăn tươi ngon • Dùng ngay để tăng chỉ số cho Boss"
		btn_buy_furniture.visible = true
		btn_apply_furniture.visible = false
		btn_buy_furniture.text = "🛒 Mua Cho Boss Ăn [%s] (%s)" % [item.get("name", ""), GameManager.format_currency(item.get("price", 0))]
		btn_buy_furniture.disabled = (GameManager.fish < item.get("price", 0))
		_style_btn(btn_buy_furniture, Color(1.0, 0.55, 0.12), Color(1, 1, 1))
		return
		
	if is_toy:
		if speech_text == "":
			speech_text = "Đồ chơi [%s] này cho Boss vờn bắt vui hết sẩy Sen ơi! 🧶" % item.get("name", "")
		furn_speech_label.text = speech_text
		furn_info_label.text = "🧸 %s • %s" % [item.get("name", ""), boost_str]
		furn_status_lbl.text = "Đồ chơi xả stress • Giúp Mèo tăng Dũng Cảm & Tâm Trạng"
		btn_buy_furniture.visible = true
		btn_apply_furniture.visible = false
		btn_buy_furniture.text = "🛒 Mua Cho Boss Chơi [%s] (%s)" % [item.get("name", ""), GameManager.format_currency(item.get("price", 0))]
		btn_buy_furniture.disabled = (GameManager.fish < item.get("price", 0))
		_style_btn(btn_buy_furniture, Color(0.08, 0.72, 0.52), Color(1, 1, 1))
		return
	
	if speech_text == "":
		speech_text = "Món %s này bài trí vào phòng nhìn xịn xò lắm Sen ơi! 🛋️" % item.get("name", "")
	furn_speech_label.text = speech_text
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

func _set_cat_speech(text: String) -> void:
	if speech_label:
		speech_label.text = text

func _try_on_costume(item: Dictionary) -> void:
	if item.is_empty() or not item.has("id"):
		return
	SoundManager.play_card_pop()
	last_previewed_item = item
	var subcat = item.get("subcategory", "clothes")
	
	# Nếu đang mặc đúng món này, bấm lại sẽ tháo ra (toggle)
	if preview_costumes.get(subcat, "") == item["id"]:
		preview_costumes[subcat] = ""
		_set_cat_speech("Đã tháo %s rồi Sen ơi! 🐾" % item["name"])
	else:
		preview_costumes[subcat] = item["id"]
		var speech = ITEM_SPEECHES.get(item["id"], "")
		if speech != "":
			_set_cat_speech(speech)
		else:
			match subcat:
				"hats":
					_set_cat_speech("Chiếc %s này đội lên chuẩn style Boss ngầu đét! 🧢" % item["name"])
				"clothes":
					_set_cat_speech("Áo %s vừa vặn mà tôn dáng Boss ghê Sen ơi! 🧥" % item["name"])
				"bows":
					_set_cat_speech("Thắt %s xinh xắn này vào nhìn cưng xỉu luôn! 🎀" % item["name"])
				"accessories":
					_set_cat_speech("Kính/Balo %s phối vào trông như thủ khoa xóm trọ! 🕶️" % item["name"])
				_:
					_set_cat_speech("Sen thấy Boss mặc %s có hợp gu không? ✨" % item["name"])
				
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
	_set_cat_speech("Đã quay về set đồ gốc của Boss! 🐾")
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
		JuicyButtonScript.attach_juice(btn, true)
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
		JuicyButtonScript.attach_juice(btn, true)
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
	card.custom_minimum_size = Vector2(264, 112)
	
	var is_owned = GameManager.is_item_owned(item["id"])
	var is_trying = (preview_costumes.values().has(item["id"]))
	var req_lvl = item.get("required_level", 1)
	var is_level_unlocked = (GameManager.cat_mastery_level >= req_lvl)
	var category = item.get("category", "")
	var subcategory = item.get("subcategory", "")
	
	# Thiết kế thẻ dạng Toffee 9-Patch ấm áp
	var c_style = StyleBoxFlat.new()
	c_style.bg_color = Color(0.99, 0.97, 0.94, 0.98)
	if is_trying:
		c_style.bg_color = Color(1.0, 0.95, 0.90, 1.0)
		c_style.border_color = Color(1.0, 0.55, 0.12, 1.0)
		c_style.set_border_width_all(2)
		c_style.border_width_bottom = 3
	else:
		c_style.border_color = Color(0.86, 0.78, 0.70, 1.0)
		c_style.set_border_width_all(1)
		c_style.border_width_bottom = 3
	c_style.set_corner_radius_all(14)
	c_style.content_margin_left = 8
	c_style.content_margin_right = 8
	c_style.content_margin_top = 8
	c_style.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", c_style)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	
	# 1. Cột trái: Khung Squircle Pastel chứa Sprite Pixel Art vẽ tay độc quyền
	var icon_box = PanelContainer.new()
	icon_box.custom_minimum_size = Vector2(54, 54)
	icon_box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var ib_style = StyleBoxFlat.new()
	
	# Màu nền pastel dịu mắt theo danh mục
	match category:
		"costumes":
			ib_style.bg_color = Color(0.94, 0.90, 0.98, 1.0)
			ib_style.border_color = Color(0.80, 0.70, 0.92, 1.0)
		"decor":
			ib_style.bg_color = Color(1.0, 0.93, 0.88, 1.0)
			ib_style.border_color = Color(0.92, 0.76, 0.65, 1.0)
		"toys":
			ib_style.bg_color = Color(0.88, 0.97, 0.93, 1.0)
			ib_style.border_color = Color(0.68, 0.88, 0.80, 1.0)
		"food":
			ib_style.bg_color = Color(1.0, 0.95, 0.85, 1.0)
			ib_style.border_color = Color(0.95, 0.82, 0.60, 1.0)
		_:
			ib_style.bg_color = Color(0.96, 0.92, 0.86, 1.0)
			ib_style.border_color = Color(0.85, 0.75, 0.65, 1.0)
			
	ib_style.set_border_width_all(1)
	ib_style.border_width_bottom = 2
	ib_style.set_corner_radius_all(14)
	icon_box.add_theme_stylebox_override("panel", ib_style)
	
	var sprite_path = GameManager.get_item_sprite_path(item["id"])
	if sprite_path != "" and (ResourceLoader.exists(sprite_path) or FileAccess.file_exists(sprite_path)):
		var tex_rect = TextureRect.new()
		tex_rect.texture = GameManager.load_texture(sprite_path)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.custom_minimum_size = Vector2(40, 40)
		tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		tex_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		tex_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		icon_box.add_child(tex_rect)
	else:
		var icon_lbl = Label.new()
		icon_lbl.text = item.get("icon", "📦")
		icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		icon_lbl.add_theme_font_size_override("font_size", 24)
		icon_box.add_child(icon_lbl)
	hbox.add_child(icon_box)
	
	# 2. Cột phải: Thông tin sản phẩm, Thẻ phân loại, Buff chỉ số & Nút thao tác
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	
	# Hàng 1: Tên sản phẩm + Chip phân loại con
	var title_row = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 4)
	
	var name_lbl = Label.new()
	name_lbl.text = item["name"]
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.add_theme_color_override("font_color", Color(0.26, 0.18, 0.12))
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title_row.add_child(name_lbl)
	
	var chip_sub = Label.new()
	chip_sub.text = "[%s]" % SUBCAT_NAMES.get(subcategory, subcategory.capitalize())
	chip_sub.add_theme_font_size_override("font_size", 9)
	chip_sub.add_theme_color_override("font_color", Color(0.60, 0.48, 0.38))
	title_row.add_child(chip_sub)
	vbox.add_child(title_row)
	
	# Hàng 2: Giá & Buff chỉ số
	var boost_str = _format_stat_boost(item.get("stat_boost", {}))
	var meta_row = HBoxContainer.new()
	meta_row.add_theme_constant_override("separation", 6)
	
	var price_lbl = Label.new()
	if is_owned and category != "food":
		price_lbl.text = "✔ Đã có"
		price_lbl.add_theme_color_override("font_color", Color(0.20, 0.65, 0.35))
	else:
		price_lbl.text = "🐟 %s" % GameManager.format_currency(item["price"])
		price_lbl.add_theme_color_override("font_color", Color(0.92, 0.46, 0.05))
	price_lbl.add_theme_font_size_override("font_size", 10)
	meta_row.add_child(price_lbl)
	
	var dot_lbl = Label.new()
	dot_lbl.text = "•"
	dot_lbl.add_theme_font_size_override("font_size", 9)
	dot_lbl.add_theme_color_override("font_color", Color(0.7, 0.65, 0.6))
	meta_row.add_child(dot_lbl)
	
	var boost_lbl = Label.new()
	boost_lbl.text = boost_str
	boost_lbl.add_theme_font_size_override("font_size", 9)
	boost_lbl.add_theme_color_override("font_color", Color(0.35, 0.55, 0.40))
	meta_row.add_child(boost_lbl)
	vbox.add_child(meta_row)
	
	# Hàng 3: Các nút hành động có JuicyButton haptic
	var btn_row = HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 6)
	btn_row.size_flags_vertical = Control.SIZE_SHRINK_END
	
	if category == "costumes":
		# Nút Mặc Thử trực tiếp lên Model Mèo 2/3 màn hình
		var try_btn = Button.new()
		try_btn.custom_minimum_size = Vector2(0, 26)
		try_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		try_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		JuicyButtonScript.attach_juice(try_btn, true)
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
		JuicyButtonScript.attach_juice(buy_btn, true)
		
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
		JuicyButtonScript.attach_juice(preview_btn, true)
		if category == "food":
			preview_btn.text = "🍲 Xem Món"
		elif category == "toys":
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
		JuicyButtonScript.attach_juice(act_btn, true)
		
		if not is_level_unlocked:
			act_btn.text = "🔒 Cần Cấp %d" % req_lvl
			act_btn.disabled = true
			_style_btn(act_btn, Color(0.85, 0.82, 0.78), Color(0.5, 0.45, 0.4))
		elif is_owned and category == "decor":
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
		elif category == "food":
			act_btn.text = "%s Mua Ăn" % GameManager.format_currency(item["price"])
			_style_btn(act_btn, Color(1.0, 0.55, 0.10), Color(1, 1, 1))
			act_btn.pressed.connect(func(): _open_detail(item))
		elif category == "toys":
			act_btn.text = "%s Mua Chơi" % GameManager.format_currency(item["price"])
			_style_btn(act_btn, Color(0.08, 0.72, 0.52), Color(1, 1, 1))
			act_btn.pressed.connect(func(): _open_detail(item))
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
			detail_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
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
	
	var sub_name = SUBCAT_NAMES.get(item.get("subcategory", ""), item.get("subcategory", "").capitalize())
	detail_subcat.text = "Phân Loại: %s • Yêu Cầu Cấp %d" % [sub_name, item.get("required_level", 1)]
	
	# Kết hợp mô tả và lời thoại đặc sắc của Mochi
	var desc_str = item.get("desc", "")
	var speech = ITEM_SPEECHES.get(item.get("id", ""), "")
	if speech != "":
		desc_str += "\n\n💬 Mochi: \"%s\"" % speech
	detail_desc.text = desc_str
	
	detail_boost.text = "Hiệu Quả: %s" % _format_stat_boost(item.get("stat_boost", {}))
	
	var cat = item.get("category", "")
	if cat == "food":
		btn_modal_action.text = "🍲 MUA & CHO BOSS ĂN NGAY [%s] 🟡" % GameManager.format_currency(item["price"])
	elif cat == "toys":
		btn_modal_action.text = "🎁 MUA & CHO BOSS CHƠI NGAY [%s] 🟡" % GameManager.format_currency(item["price"])
	else:
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
		
		var custom_speech = ITEM_SPEECHES.get(selected_item["id"], "")
		if custom_speech != "":
			_set_cat_speech(custom_speech)
		else:
			_set_cat_speech("Tuyệt vời Sen ơi! Boss có [%s] mới rồi! 💖" % selected_item["name"])
			
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
