extends Control

# FinanceSurvivalSimulation.gd - Module Giả Lập Hệ Thống & Xúc Giác: Trụ Cột Tài Chính & Chống Lừa Đảo
# Cấp độ 1: "Siêu Thị Thông Thái" (Price-per-100g & Expiry Date Inspection)
# Cấp độ 2: "Phòng Thủ Chốt Đơn" (30-Day Cashflow & 24h Impulse Cooling-off Box)
# Cấp độ 3: "Rà Soát Lừa Đảo Số" (Digital Scam Forensics & Virtual Smartphone)

signal minigame_completed(sim_steps)
signal back_requested

const JuicyButtonScript = preload("res://scripts/ui/JuicyButton.gd")

enum Level {
	LEVEL_1_SUPERMARKET = 1,
	LEVEL_2_CASHFLOW = 2,
	LEVEL_3_SCAM_FORENSICS = 3
}

# Node references
@onready var header_box: HBoxContainer = $Header
@onready var btn_back: Button = $Header/BtnBack
@onready var btn_help: Button = $Header/BtnHelp
@onready var title_lbl: Label = $Header/TitleLabel
@onready var level_badge_lbl: Label = $Header/LevelBadgeLabel

@onready var cat_speech_lbl: Label = $MascotBox/SpeechBubble/CatSpeechLabel
@onready var mascot_avatar: TextureRect = $MascotBox/CatAvatar

@onready var level1_container: Control = $Level1Container
@onready var level2_container: Control = $Level2Container
@onready var level3_container: Control = $Level3Container

@onready var victory_modal: Control = $VictoryModal
@onready var victory_dialogue_lbl: Label = $VictoryModal/ModalPanel/VBox/Scroll/DialogueLabel
@onready var btn_claim_reward: Button = $VictoryModal/ModalPanel/VBox/BtnClaimReward

var current_level: int = 1
var is_level_active: bool = false
var safe_failure_count: int = 0
var completed_levels: Dictionary = {}

# Level 1 State: Supermarket Shopping
const INITIAL_BUDGET: int = 200000
var current_budget: int = 200000
var cart_items: Dictionary = {} # id -> item_data
var inspected_items: Dictionary = {} # id -> true
var is_basket_checked_out: bool = false

# Level 2 State: 30-Day Cashflow & Impulse Cooling Box
var sim_day: int = 1
var cash_balance: int = 6000000
var is_impulse_cooling: bool = false
var impulse_cooled_off: bool = false
var is_cashflow_bankrupt: bool = false
var cashflow_completed: bool = false

# Level 3 State: Scam Forensics
var blocked_scams: Dictionary = {} # scam_id -> true
var selected_scam_id: String = ""

var polaroid_cert_panel: PanelContainer = null

func _ready() -> void:
	_setup_header_and_buttons()
	if victory_modal: victory_modal.visible = false
	if not is_level_active:
		load_level(1)

func _setup_header_and_buttons() -> void:
	if btn_back:
		btn_back.pressed.connect(func():
			SoundManager.play_click()
			emit_signal("back_requested")
		)
		JuicyButtonScript.attach_juice(btn_back, true)
		
	if btn_help:
		btn_help.pressed.connect(_on_help_pressed)
		JuicyButtonScript.attach_juice(btn_help, true)
		
	if btn_claim_reward:
		btn_claim_reward.pressed.connect(_on_claim_reward_pressed)
		JuicyButtonScript.attach_juice(btn_claim_reward, true)

func load_minigame(data: Dictionary = {}) -> void:
	var req_lvl = data.get("level", 1)
	load_level(req_lvl)

func load_level(lvl_idx: int) -> void:
	current_level = clampi(lvl_idx, 1, 3)
	is_level_active = true
	safe_failure_count = 0
	
	if level1_container: level1_container.visible = (current_level == 1)
	if level2_container: level2_container.visible = (current_level == 2)
	if level3_container: level3_container.visible = (current_level == 3)
	
	match current_level:
		1:
			level_badge_lbl.text = "CẤP ĐỘ 1 / 3: SIÊU THỊ THÔNG THÁI"
			title_lbl.text = "Soi Đơn Giá 100g & Hạn Sử Dụng Sản Phẩm"
			cat_speech_lbl.text = "Ngân sách 200k! Đừng để bị lừa bởi gói nhỏ giá rẻ, hãy lật mặt sau xem hạn dùng và tính đơn giá trên mỗi 100g nha Sen! 🛒"
			_init_level1_supermarket()
		2:
			level_badge_lbl.text = "CẤP ĐỘ 2 / 3: PHÒNG THỦ CHỐT ĐƠN"
			title_lbl.text = "Dòng Tiền 30 Ngày & Ngăn Đợi 24 Giờ"
			cat_speech_lbl.text = "Giữa tháng có Flash Sale giảm 50% giày sneaker 1.200.000đ! Kéo ngay vào Ngăn Đợi 24h để làm nguội cơn nghiện mua sắm nhé! ❄️"
			_init_level2_cashflow()
		3:
			level_badge_lbl.text = "CẤP ĐỘ 3 / 3: RÀ SOÁT LỪA ĐẢO SỐ"
			title_lbl.text = "Pháp Y Tin Nhắn & Bẫy Điện Thoại Ảo"
			cat_speech_lbl.text = "Smartphone ảo nhận 3 tin nhắn đe dọa và việc nhẹ lương cao! Dùng kính lúp soi link giả mạo và chặn báo cáo ngay! 🔍"
			_init_level3_scam_forensics()

# =========================================================================
# LEVEL 1: SIÊU THỊ THÔNG THÁI (PRICE-PER-100G & EXPIRY INSPECTION)
# =========================================================================
var budget_label: Label = null
var cart_summary_label: Label = null
var btn_checkout: Button = null
var product_cards_map: Dictionary = {}

const PRODUCTS_DATA = [
	{
		"id": "rice_small",
		"name": "Túi Gạo Nhỏ 300g",
		"price": 45000,
		"weight": 300,
		"unit_price": 15000, # 15k / 100g
		"exp": "Còn 6 tháng",
		"is_good_deal": false,
		"icon": "🌾",
		"note": "Bẫy bao bì nhỏ: 45k/300g = 15k/100g (Đắt hơn 50%!)"
	},
	{
		"id": "rice_big",
		"name": "Túi Gạo Lớn 500g",
		"price": 50000,
		"weight": 500,
		"unit_price": 10000, # 10k / 100g
		"exp": "Còn 6 tháng",
		"is_good_deal": true,
		"icon": "🌾",
		"note": "Kinh tế: 50k/500g = 10k/100g (Tiết kiệm 5k mỗi 100g!)"
	},
	{
		"id": "eggs_spoiled",
		"name": "Vỉ Trứng Sale 50%",
		"price": 15000,
		"weight": 10,
		"unit_price": 1500,
		"exp": "HẾT HẠN HÔM NAY",
		"is_good_deal": false,
		"icon": "🥚",
		"note": "Bẫy xả hàng cận date: Trứng lòng vữa, ăn vào ngộ độc!"
	},
	{
		"id": "eggs_fresh",
		"name": "Vỉ Trứng Gà Tươi",
		"price": 30000,
		"weight": 10,
		"unit_price": 3000,
		"exp": "Còn hạn 20 ngày",
		"is_good_deal": true,
		"icon": "🥚",
		"note": "Tươi ngon, chuẩn VietGAP, bảo quản an toàn."
	},
	{
		"id": "pate_mochi",
		"name": "Pate Cá Ngừ Mochi",
		"price": 35000,
		"weight": 150,
		"unit_price": 2333,
		"exp": "Còn hạn 12 tháng",
		"is_good_deal": true,
		"icon": "🐟",
		"note": "Dinh dưỡng cho Boss Mochi, cá ngừ tươi giàu Omega-3!"
	}
]

func _init_level1_supermarket() -> void:
	current_budget = INITIAL_BUDGET
	cart_items.clear()
	inspected_items.clear()
	is_basket_checked_out = false
	_build_level1_ui()

func _build_level1_ui() -> void:
	if not level1_container: return
	for ch in level1_container.get_children(): ch.queue_free()
	
	var v_box = VBoxContainer.new()
	v_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	v_box.add_theme_constant_override("separation", 8)
	
	# Thanh ngân sách & Giỏ hàng
	var bar_panel = PanelContainer.new()
	var sb_bar = StyleBoxFlat.new()
	sb_bar.bg_color = Color(0.95, 0.93, 0.88, 1.0)
	sb_bar.border_color = Color(0.65, 0.50, 0.35, 1.0)
	sb_bar.set_border_width_all(2)
	sb_bar.set_corner_radius_all(8)
	bar_panel.add_theme_stylebox_override("panel", sb_bar)
	
	var bar_hbox = HBoxContainer.new()
	bar_hbox.add_theme_constant_override("separation", 10)
	
	budget_label = Label.new()
	budget_label.text = "💰 Ngân sách còn lại: 200.000đ"
	budget_label.add_theme_font_size_override("font_size", 10)
	budget_label.add_theme_color_override("font_color", Color(0.2, 0.55, 0.25, 1.0))
	bar_hbox.add_child(budget_label)
	
	cart_summary_label = Label.new()
	cart_summary_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cart_summary_label.text = "🛒 Giỏ hàng: 0 món (0đ)"
	cart_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cart_summary_label.add_theme_font_size_override("font_size", 10)
	cart_summary_label.add_theme_color_override("font_color", Color(0.4, 0.25, 0.15, 1.0))
	bar_hbox.add_child(cart_summary_label)
	
	bar_panel.add_child(bar_hbox)
	v_box.add_child(bar_panel)
	
	# Kệ hàng hóa (Scrollable Grid)
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 200)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var shelf_grid = GridContainer.new()
	shelf_grid.columns = 2
	shelf_grid.add_theme_constant_override("h_separation", 8)
	shelf_grid.add_theme_constant_override("v_separation", 8)
	
	product_cards_map.clear()
	for p in PRODUCTS_DATA:
		var p_card = _create_product_card(p)
		shelf_grid.add_child(p_card)
		product_cards_map[p["id"]] = p_card
		
	scroll.add_child(shelf_grid)
	v_box.add_child(scroll)
	
	# Nút Thanh Toán
	btn_checkout = Button.new()
	btn_checkout.name = "BtnCheckout"
	btn_checkout.text = "🛍️ THANH TOÁN GIỎ HÀNG THÔNG THÁI"
	btn_checkout.custom_minimum_size = Vector2(0, 42)
	btn_checkout.add_theme_font_size_override("font_size", 11)
	btn_checkout.pressed.connect(_on_checkout_pressed)
	JuicyButtonScript.attach_juice(btn_checkout, true)
	v_box.add_child(btn_checkout)
	
	level1_container.add_child(v_box)

func _create_product_card(data: Dictionary) -> PanelContainer:
	var pc = PanelContainer.new()
	pc.custom_minimum_size = Vector2(215, 88)
	
	var sb = StyleBoxFlat.new()
	sb.bg_color = Color(1.0, 0.99, 0.96, 1.0)
	sb.border_color = Color(0.8, 0.7, 0.6, 1.0)
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	pc.add_theme_stylebox_override("panel", sb)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	
	var name_lbl = Label.new()
	name_lbl.name = "NameLabel"
	name_lbl.text = "%s %s: %sđ" % [data["icon"], data["name"], _format_money(data["price"])]
	name_lbl.add_theme_font_size_override("font_size", 10)
	name_lbl.add_theme_color_override("font_color", Color(0.3, 0.2, 0.1, 1.0))
	vbox.add_child(name_lbl)
	
	var inspect_lbl = Label.new()
	inspect_lbl.name = "InspectLabel"
	inspect_lbl.text = "🔍 Chạm để lật mặt sau soi đơn giá / 100g & HSD"
	inspect_lbl.add_theme_font_size_override("font_size", 8)
	inspect_lbl.add_theme_color_override("font_color", Color(0.5, 0.45, 0.4, 1.0))
	vbox.add_child(inspect_lbl)
	
	var btn_hbox = HBoxContainer.new()
	btn_hbox.add_theme_constant_override("separation", 6)
	
	var btn_flip = Button.new()
	btn_flip.name = "BtnFlip"
	btn_flip.text = "🔍 Soi Chi Tiết"
	btn_flip.add_theme_font_size_override("font_size", 9)
	btn_flip.pressed.connect(func(): _on_flip_product(data["id"]))
	JuicyButtonScript.attach_juice(btn_flip, true)
	btn_hbox.add_child(btn_flip)
	
	var btn_cart = Button.new()
	btn_cart.name = "BtnAddToCart"
	btn_cart.text = "➕ Chọn Mua"
	btn_cart.add_theme_font_size_override("font_size", 9)
	btn_cart.pressed.connect(func(): _on_toggle_cart_item(data["id"]))
	JuicyButtonScript.attach_juice(btn_cart, true)
	btn_hbox.add_child(btn_cart)
	
	vbox.add_child(btn_hbox)
	pc.add_child(vbox)
	return pc

func _on_flip_product(prod_id: String) -> void:
	SoundManager.play_card_pop()
	inspected_items[prod_id] = true
	var p = _get_product_by_id(prod_id)
	if p.is_empty(): return
	
	var card = product_cards_map.get(prod_id) as PanelContainer
	if not card: return
	
	var inspect_lbl = card.find_child("InspectLabel", true, false) as Label
	if inspect_lbl:
		inspect_lbl.text = "🔎 Đơn giá: %sđ/100g | HSD: %s\n%s" % [_format_money(p["unit_price"]), p["exp"], p["note"]]
		if p["is_good_deal"]:
			inspect_lbl.add_theme_color_override("font_color", Color(0.15, 0.55, 0.25, 1.0))
		else:
			inspect_lbl.add_theme_color_override("font_color", Color(0.85, 0.25, 0.15, 1.0))
			
	cat_speech_lbl.text = "Soi kỹ lắm Sen! %s: Đơn giá %sđ/100g, HSD: %s." % [p["name"], _format_money(p["unit_price"]), p["exp"]]

func _on_toggle_cart_item(prod_id: String) -> void:
	SoundManager.play_click()
	var p = _get_product_by_id(prod_id)
	if p.is_empty(): return
	
	var card = product_cards_map.get(prod_id) as PanelContainer
	var btn_cart = card.find_child("BtnAddToCart", true, false) as Button if card else null
	
	if cart_items.has(prod_id):
		cart_items.erase(prod_id)
		if btn_cart: btn_cart.text = "➕ Chọn Mua"
	else:
		cart_items[prod_id] = p
		if btn_cart: btn_cart.text = "✔ Đã Chọn"
		
	_update_cart_display()

func _update_cart_display() -> void:
	var total_spent = 0
	for item_id in cart_items:
		total_spent += cart_items[item_id]["price"]
		
	current_budget = INITIAL_BUDGET - total_spent
	if budget_label:
		budget_label.text = "💰 Ngân sách còn lại: %sđ" % _format_money(current_budget)
		if current_budget < 0:
			budget_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.1, 1.0))
		else:
			budget_label.add_theme_color_override("font_color", Color(0.2, 0.55, 0.25, 1.0))
			
	if cart_summary_label:
		cart_summary_label.text = "🛒 Giỏ hàng: %d món (%sđ)" % [cart_items.size(), _format_money(total_spent)]

func _on_checkout_pressed() -> void:
	# Kiểm tra giỏ hàng
	if cart_items.size() == 0:
		SoundManager.play_fail()
		cat_speech_lbl.text = "Giỏ hàng đang trống trơn kìa Sen! Hãy chọn gạo, trứng và pate cho Boss nha! 🐾"
		return
		
	if current_budget < 0:
		SoundManager.play_fail()
		safe_failure_count += 1
		cat_speech_lbl.text = "ÚI! Tổng tiền vượt quá ngân sách 200k rồi! Bỏ bớt món không cần thiết ra nào Sen!"
		return
		
	# Bẫy 1: Mua trứng hết hạn
	if cart_items.has("eggs_spoiled"):
		SoundManager.play_fail()
		safe_failure_count += 1
		cat_speech_lbl.text = "❌ DỪNG LẠI! Trứng giảm giá 50% nhưng hết hạn hôm nay và bị vữa! Mua về ăn ngộ độc đau bụng nhập viện tốn tiền gấp 10 lần! Bỏ ra chọn trứng tươi nhé!"
		return
		
	# Bẫy 2: Mua túi gạo nhỏ đắt hơn
	if cart_items.has("rice_small"):
		SoundManager.play_fail()
		safe_failure_count += 1
		cat_speech_lbl.text = "❌ BẪY BAO BÌ NHỎ! Túi gạo nhỏ 45k/300g = 15k/100g, đắt hơn túi lớn 50k/500g = 10k/100g tới 50%! Đổi sang túi lớn tiết kiệm hơn nhiều nha Sen!"
		return
		
	# Giỏ hàng chuẩn: rice_big + eggs_fresh + pate_mochi
	if cart_items.has("rice_big") and cart_items.has("eggs_fresh") and cart_items.has("pate_mochi"):
		is_basket_checked_out = true
		completed_levels[1] = true
		SoundManager.play_success()
		cat_speech_lbl.text = "🎉 XUẤT SẮC! Giỏ hàng thông thái: Gạo túi lớn tiết kiệm 50%, trứng tươi chuẩn an toàn, lại có cả Pate cho Mochi! Hết có 115k còn dư 85k! Chuyển sang Level 2 nào! ✨"
		get_tree().create_timer(1.2).timeout.connect(func():
			load_level(2)
		)
	else:
		cat_speech_lbl.text = "Đừng quên mua đủ 3 món: Gạo lớn, Trứng tươi và Pate cá ngừ cho Mochi nha Sen! 🐾"

func _get_product_by_id(id: String) -> Dictionary:
	for p in PRODUCTS_DATA:
		if p["id"] == id: return p
	return {}

# =========================================================================
# LEVEL 2: PHÒNG THỦ CHỐT ĐƠN (30-DAY CASHFLOW & 24H IMPULSE COOLING BOX)
# =========================================================================
var day_label: Label = null
var cash_balance_label: Label = null
var impulse_box_panel: PanelContainer = null
var btn_next_day: Button = null
var btn_buy_flash_sale: Button = null
var btn_drag_cooling_box: Button = null
var flash_sale_panel: PanelContainer = null

func _init_level2_cashflow() -> void:
	sim_day = 1
	cash_balance = 6000000
	is_impulse_cooling = false
	impulse_cooled_off = false
	is_cashflow_bankrupt = false
	cashflow_completed = false
	_build_level2_ui()

func _build_level2_ui() -> void:
	if not level2_container: return
	for ch in level2_container.get_children(): ch.queue_free()
	
	var v_box = VBoxContainer.new()
	v_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	v_box.add_theme_constant_override("separation", 8)
	
	# Thanh lịch trình & Số dư
	var header_panel = PanelContainer.new()
	var sb_h = StyleBoxFlat.new()
	sb_h.bg_color = Color(0.94, 0.96, 0.98, 1.0)
	sb_h.border_color = Color(0.3, 0.5, 0.8, 1.0)
	sb_h.set_border_width_all(2)
	sb_h.set_corner_radius_all(8)
	header_panel.add_theme_stylebox_override("panel", sb_h)
	
	var h_box = HBoxContainer.new()
	h_box.add_theme_constant_override("separation", 10)
	
	day_label = Label.new()
	day_label.text = "📅 Ngày: 1 / 30"
	day_label.add_theme_font_size_override("font_size", 11)
	day_label.add_theme_color_override("font_color", Color(0.1, 0.3, 0.6, 1.0))
	h_box.add_child(day_label)
	
	cash_balance_label = Label.new()
	cash_balance_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cash_balance_label.text = "💵 Quỹ chi tiêu: 6.000.000đ"
	cash_balance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cash_balance_label.add_theme_font_size_override("font_size", 11)
	cash_balance_label.add_theme_color_override("font_color", Color(0.15, 0.55, 0.25, 1.0))
	h_box.add_child(cash_balance_label)
	
	header_panel.add_child(h_box)
	v_box.add_child(header_panel)
	
	# Popup Cám dỗ Flash Sale (Ngày 12)
	flash_sale_panel = PanelContainer.new()
	flash_sale_panel.name = "FlashSalePanel"
	var sb_flash = StyleBoxFlat.new()
	sb_flash.bg_color = Color(1.0, 0.94, 0.94, 1.0)
	sb_flash.border_color = Color(0.9, 0.3, 0.3, 1.0)
	sb_flash.set_border_width_all(2)
	sb_flash.set_corner_radius_all(10)
	flash_sale_panel.add_theme_stylebox_override("panel", sb_flash)
	
	var f_vbox = VBoxContainer.new()
	f_vbox.add_theme_constant_override("separation", 6)
	
	var f_title = Label.new()
	f_title.text = "⚡ CÁM DỖ FLASH SALE: GIÀY SNEAKER LIMITED GIẢM 50%!"
	f_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	f_title.add_theme_font_size_override("font_size", 10)
	f_title.add_theme_color_override("font_color", Color(0.85, 0.2, 0.1, 1.0))
	f_vbox.add_child(f_title)
	
	var f_desc = Label.new()
	f_desc.text = "Giá gốc: 2.400.000đ ➔ Giá sốc: 1.200.000đ (Chỉ còn 15 phút đếm ngược! Mua ngay kẻo lỡ!)"
	f_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	f_desc.add_theme_font_size_override("font_size", 9)
	f_desc.add_theme_color_override("font_color", Color(0.3, 0.2, 0.2, 1.0))
	f_vbox.add_child(f_desc)
	
	var f_actions = HBoxContainer.new()
	f_actions.alignment = BoxContainer.ALIGNMENT_CENTER
	f_actions.add_theme_constant_override("separation", 10)
	
	btn_buy_flash_sale = Button.new()
	btn_buy_flash_sale.name = "BtnBuyFlashSale"
	btn_buy_flash_sale.text = "💳 CHỐT ĐƠN 1.200.000đ NGAY"
	btn_buy_flash_sale.add_theme_font_size_override("font_size", 9)
	btn_buy_flash_sale.pressed.connect(_on_buy_flash_sale_pressed)
	JuicyButtonScript.attach_juice(btn_buy_flash_sale, true)
	f_actions.add_child(btn_buy_flash_sale)
	
	btn_drag_cooling_box = Button.new()
	btn_drag_cooling_box.name = "BtnCoolingBox"
	btn_drag_cooling_box.text = "❄️ KÉO VÀO NGĂN ĐỢI 24 GIỜ"
	btn_drag_cooling_box.add_theme_font_size_override("font_size", 9)
	btn_drag_cooling_box.pressed.connect(_on_put_in_cooling_box_pressed)
	JuicyButtonScript.attach_juice(btn_drag_cooling_box, true)
	f_actions.add_child(btn_drag_cooling_box)
	
	f_vbox.add_child(f_actions)
	flash_sale_panel.add_child(f_vbox)
	flash_sale_panel.visible = false
	v_box.add_child(flash_sale_panel)
	
	# Ngăn Đợi 24 Giờ (24h Cooling-Off Box)
	impulse_box_panel = PanelContainer.new()
	impulse_box_panel.name = "ImpulseBoxPanel"
	var sb_ice = StyleBoxFlat.new()
	sb_ice.bg_color = Color(0.90, 0.96, 0.99, 1.0)
	sb_ice.border_color = Color(0.3, 0.7, 0.9, 1.0)
	sb_ice.set_border_width_all(2)
	sb_ice.set_corner_radius_all(10)
	impulse_box_panel.add_theme_stylebox_override("panel", sb_ice)
	
	var ice_vbox = VBoxContainer.new()
	ice_vbox.add_theme_constant_override("separation", 4)
	
	var ice_title = Label.new()
	ice_title.name = "IceTitleLabel"
	ice_title.text = "🧊 NGĂN ĐỢI 24 GIỜ: ĐANG ĐÓNG BĂNG CƠN THÈM MUA SẮM"
	ice_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ice_title.add_theme_font_size_override("font_size", 10)
	ice_title.add_theme_color_override("font_color", Color(0.1, 0.45, 0.7, 1.0))
	ice_vbox.add_child(ice_title)
	
	var ice_desc = Label.new()
	ice_desc.name = "IceDescLabel"
	ice_desc.text = "Sau 24 giờ, hormone dopamine hạ nhiệt. Nếu vẫn thật sự cần thiết mới mua!"
	ice_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ice_desc.add_theme_font_size_override("font_size", 9)
	ice_desc.add_theme_color_override("font_color", Color(0.2, 0.35, 0.45, 1.0))
	ice_vbox.add_child(ice_desc)
	
	impulse_box_panel.add_child(ice_vbox)
	impulse_box_panel.visible = false
	v_box.add_child(impulse_box_panel)
	
	# Nút Tiến Trình Ngày Tiếp Theo
	btn_next_day = Button.new()
	btn_next_day.name = "BtnNextDay"
	btn_next_day.text = "▶ TIẾN VÀO NGÀY TIẾP THEO"
	btn_next_day.custom_minimum_size = Vector2(0, 42)
	btn_next_day.add_theme_font_size_override("font_size", 11)
	btn_next_day.pressed.connect(_on_next_day_pressed)
	JuicyButtonScript.attach_juice(btn_next_day, true)
	v_box.add_child(btn_next_day)
	
	level2_container.add_child(v_box)

func _on_next_day_pressed() -> void:
	SoundManager.play_click()
	sim_day += 1
	
	# Sự kiện dòng tiền cố định
	match sim_day:
		5:
			cash_balance -= 2500000 # Tiền thuê trọ
			cat_speech_lbl.text = "📅 Ngày 5: Đã tự động chuyển tiền phòng trọ -2.500.000đ. Quỹ còn: %sđ" % _format_money(cash_balance)
		12:
			# Xuất hiện Flash Sale
			flash_sale_panel.visible = true
			btn_next_day.disabled = true
			cat_speech_lbl.text = "🚨 TING TING! Ngày 12: Đột ngột xuất hiện Flash Sale Giày Sneaker 1.200.000đ! Cẩn thận bẫy tâm lý 'sợ bỏ lỡ' (FOMO) nha Sen!"
		13:
			if is_impulse_cooling:
				impulse_cooled_off = true
				impulse_box_panel.visible = true
				var desc = impulse_box_panel.find_child("IceDescLabel", true, false) as Label
				if desc:
					desc.text = "✨ Đã qua 24 giờ làm nguội! Giày cũ vẫn đi rất êm, mua thêm đôi này sẽ làm thủng quỹ khẩn cấp. Quyết định: HỦY MUA & BẢO TOÀN DÒNG TIỀN! 🛡️"
				cat_speech_lbl.text = "Tuyệt cú mèo! Sau 24h Sen đã hết thèm mua giày rồi! Tiết kiệm được 1.200.000đ cho quỹ dự phòng!"
		15:
			cash_balance -= 500000 # Điện nước
			cat_speech_lbl.text = "📅 Ngày 15: Đóng tiền điện nước sinh hoạt -500.000đ. Quỹ còn: %sđ" % _format_money(cash_balance)
		25:
			cash_balance -= 1500000 # Ăn uống & Mochi
			if cash_balance < 0:
				is_cashflow_bankrupt = true
				SoundManager.play_fail()
				safe_failure_count += 1
				cat_speech_lbl.text = "💥 TOI RỒI SEN ƠI! Tiền âm %sđ rồi! Tiền mua giày ngày 12 làm cuối tháng không còn tiền ăn, Mochi bị đói meo rồi nè! Thử lại và dùng Ngăn Đợi 24h nhé!" % _format_money(cash_balance)
				btn_next_day.text = "🔄 THỬ LẠI DÒNG TIỀN TỪ ĐẦU"
				btn_next_day.pressed.disconnect(_on_next_day_pressed)
				btn_next_day.pressed.connect(_init_level2_cashflow)
				return
			else:
				cat_speech_lbl.text = "📅 Ngày 25: Mua thức ăn cả tháng & Pate Mochi -1.500.000đ. Vẫn còn dư %sđ an toàn!" % _format_money(cash_balance)
		30:
			cashflow_completed = true
			completed_levels[2] = true
			SoundManager.play_success()
			cat_speech_lbl.text = "🎉 CHÚC MỪNG SEN! Kết thúc tháng 30 ngày an toàn, quỹ khẩn cấp vẫn còn nguyên %sđ! Bậc thầy phòng thủ chốt đơn! Chuyển sang Level 3 nào! ✨" % _format_money(cash_balance)
			get_tree().create_timer(1.2).timeout.connect(func():
				load_level(3)
			)
			
	if day_label: day_label.text = "📅 Ngày: %d / 30" % sim_day
	if cash_balance_label: cash_balance_label.text = "💵 Quỹ chi tiêu: %sđ" % _format_money(cash_balance)

func _on_buy_flash_sale_pressed() -> void:
	SoundManager.play_card_pop()
	cash_balance -= 1200000
	flash_sale_panel.visible = false
	btn_next_day.disabled = false
	cat_speech_lbl.text = "Sen vừa quẹt thẻ 1.200.000đ mua giày! Cảm giác sướng được 10 phút, nhưng coi chừng cuối tháng nhảy số âm tiền nhé!"
	if cash_balance_label: cash_balance_label.text = "💵 Quỹ chi tiêu: %sđ" % _format_money(cash_balance)

func _on_put_in_cooling_box_pressed() -> void:
	SoundManager.play_success()
	is_impulse_cooling = true
	flash_sale_panel.visible = false
	impulse_box_panel.visible = true
	btn_next_day.disabled = false
	cat_speech_lbl.text = "Đã bỏ đôi giày vào Ngăn Đợi 24 Giờ! Bấm 'Tiến Vào Ngày Tiếp Theo' để xem cảm xúc thay đổi thế nào sau 24h nha!"

# =========================================================================
# LEVEL 3: RÀ SOÁT LỪA ĐẢO SỐ (DIGITAL SCAM FORENSICS)
# =========================================================================
const SCAMS_DATA = [
	{
		"id": "bank_phishing",
		"sender": "Vietcombank (SMS Brandname Giả Mạo)",
		"content": "TB: Tai khoan VCB Digibank cua quy khach bi khoa. Vui long dang nhap tai link: http://vcb-digibank.cc/xacminh de xac thuc ngay.",
		"law": "Nghị định 15/2020/NĐ-CP & Khuyến cáo Ngân hàng Nhà nước",
		"red_flag": "Đuôi tên miền giả mạo .cc thay vì .vietcombank.com.vn chính thức; Ngân hàng không bao giờ gửi link bắt nhập mật khẩu/OTP!",
		"action_text": "🛡️ CHẶN & BÁO CÁO TIN NHẮN RÁC (TỔNG ĐÀI 156)"
	},
	{
		"id": "job_deposit_trap",
		"sender": "Tuyển Dụng Online (Telegram/Zalo)",
		"content": "Việc nhẹ lương cao tại nhà: Xem video TikTok nhận 50.000đ/lần. Cần nạp cọc 200.000đ vào ví nhiệm vụ để kích hoạt tài khoản VIP.",
		"law": "Điều 290 Bộ luật Hình sự (Tội lừa đảo chiếm đoạt tài sản trên mạng)",
		"red_flag": "Bẫy việc nhẹ lương cao và bắt nạp cọc trước. Nạp 200k xong sẽ bị ép nạp thêm hàng chục triệu rồi khóa tài khoản!",
		"action_text": "🚫 TỪ CHỐI & CHẶN SỐ LẬP TỨC"
	},
	{
		"id": "police_impersonation",
		"sender": "Số Lạ (+84 98xxx - Xưng Viện Kiểm Sát)",
		"content": "Anh/chị đang có lệnh bắt tạm giam vì dính líu đường dây rửa tiền ma túy. Yêu cầu chuyển 20.000.000đ vào tài khoản tạm giữ để chứng minh trong sạch.",
		"law": "Bộ luật Tố tụng Hình sự: Cơ quan CA/VKS không làm việc qua điện thoại",
		"red_flag": "Công an triệu tập phải bằng giấy mời/giấy triệu tập trực tiếp tại địa phương, tuyệt đối không bao giờ yêu cầu chuyển tiền vào tài khoản!",
		"action_text": "🚔 BÁO CÁO CÔNG AN & GỌI 113"
	}
]

var scam_list_vbox: VBoxContainer = null
var scam_detail_panel: PanelContainer = null
var scam_law_lbl: Label = null
var scam_flag_lbl: Label = null
var btn_scam_action: Button = null

func _init_level3_scam_forensics() -> void:
	blocked_scams.clear()
	selected_scam_id = ""
	_build_level3_ui()

func _build_level3_ui() -> void:
	if not level3_container: return
	for ch in level3_container.get_children(): ch.queue_free()
	
	var v_box = VBoxContainer.new()
	v_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	v_box.add_theme_constant_override("separation", 8)
	
	# Khung chia 2 cột: Danh sách tin nhắn giả lập & Bảng phân tích pháp y số
	var h_split = HBoxContainer.new()
	h_split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	h_split.add_theme_constant_override("separation", 8)
	
	# Cột trái: Điện thoại ảo với 3 tin nhắn
	var phone_panel = PanelContainer.new()
	phone_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb_ph = StyleBoxFlat.new()
	sb_ph.bg_color = Color(0.97, 0.96, 0.93, 1.0)
	sb_ph.border_color = Color(0.4, 0.35, 0.3, 1.0)
	sb_ph.set_border_width_all(2)
	sb_ph.set_corner_radius_all(10)
	phone_panel.add_theme_stylebox_override("panel", sb_ph)
	
	scam_list_vbox = VBoxContainer.new()
	scam_list_vbox.add_theme_constant_override("separation", 6)
	
	var ph_title = Label.new()
	ph_title.text = "📱 HỘP THƯ ĐẾN CẦN RÀ SOÁT LỪA ĐẢO:"
	ph_title.add_theme_font_size_override("font_size", 10)
	ph_title.add_theme_color_override("font_color", Color(0.3, 0.2, 0.1, 1.0))
	scam_list_vbox.add_child(ph_title)
	
	for s in SCAMS_DATA:
		var btn = Button.new()
		btn.name = "BtnScam_" + s["id"]
		btn.text = "📩 %s\n%s" % [s["sender"], s["content"].substr(0, 38) + "..."]
		btn.custom_minimum_size = Vector2(0, 48)
		btn.add_theme_font_size_override("font_size", 9)
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.pressed.connect(func(): _on_select_scam(s["id"]))
		JuicyButtonScript.attach_juice(btn, true)
		scam_list_vbox.add_child(btn)
		
	phone_panel.add_child(scam_list_vbox)
	h_split.add_child(phone_panel)
	
	# Cột phải: Kính lúp pháp y số
	scam_detail_panel = PanelContainer.new()
	scam_detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var sb_dt = StyleBoxFlat.new()
	sb_dt.bg_color = Color(0.95, 0.97, 0.99, 1.0)
	sb_dt.border_color = Color(0.2, 0.5, 0.8, 1.0)
	sb_dt.set_border_width_all(2)
	sb_dt.set_corner_radius_all(10)
	scam_detail_panel.add_theme_stylebox_override("panel", sb_dt)
	
	var dt_vbox = VBoxContainer.new()
	dt_vbox.add_theme_constant_override("separation", 6)
	
	var dt_title = Label.new()
	dt_title.text = "🔍 PHÂN TÍCH DẤU HIỆU LỪA ĐẢO:"
	dt_title.add_theme_font_size_override("font_size", 10)
	dt_title.add_theme_color_override("font_color", Color(0.1, 0.35, 0.65, 1.0))
	dt_vbox.add_child(dt_title)
	
	scam_flag_lbl = Label.new()
	scam_flag_lbl.text = "👈 Chọn một tin nhắn bên trái để soi bẫy lừa đảo..."
	scam_flag_lbl.add_theme_font_size_override("font_size", 9)
	scam_flag_lbl.add_theme_color_override("font_color", Color(0.25, 0.25, 0.25, 1.0))
	scam_flag_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dt_vbox.add_child(scam_flag_lbl)
	
	scam_law_lbl = Label.new()
	scam_law_lbl.text = ""
	scam_law_lbl.add_theme_font_size_override("font_size", 9)
	scam_law_lbl.add_theme_color_override("font_color", Color(0.15, 0.5, 0.2, 1.0))
	scam_law_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dt_vbox.add_child(scam_law_lbl)
	
	btn_scam_action = Button.new()
	btn_scam_action.name = "BtnScamAction"
	btn_scam_action.text = "🛡️ HÀNH ĐỘNG BẢO VỆ"
	btn_scam_action.custom_minimum_size = Vector2(0, 38)
	btn_scam_action.add_theme_font_size_override("font_size", 9)
	btn_scam_action.disabled = true
	btn_scam_action.pressed.connect(_on_execute_scam_action)
	JuicyButtonScript.attach_juice(btn_scam_action, true)
	dt_vbox.add_child(btn_scam_action)
	
	scam_detail_panel.add_child(dt_vbox)
	h_split.add_child(scam_detail_panel)
	v_box.add_child(h_split)
	
	level3_container.add_child(v_box)

func _on_select_scam(scam_id: String) -> void:
	SoundManager.play_click()
	selected_scam_id = scam_id
	var s = _get_scam_by_id(scam_id)
	if s.is_empty(): return
	
	if scam_flag_lbl:
		scam_flag_lbl.text = "🚩 Dấu Hiệu Bẫy: %s" % s["red_flag"]
	if scam_law_lbl:
		scam_law_lbl.text = "⚖️ Căn Cứ Pháp Lý: %s" % s["law"]
		
	if btn_scam_action:
		btn_scam_action.text = s["action_text"]
		btn_scam_action.disabled = blocked_scams.has(scam_id)
		
	cat_speech_lbl.text = "Phát hiện bẫy lừa đảo: %s! Nhấn nút hành động để xử lý triệt để!" % s["sender"]

func _on_execute_scam_action() -> void:
	if selected_scam_id == "": return
	SoundManager.play_success()
	blocked_scams[selected_scam_id] = true
	
	var btn = scam_list_vbox.find_child("BtnScam_" + selected_scam_id, true, false) as Button
	if btn:
		btn.text = "✔ ĐÃ CHẶN & BÁO CÁO AN TOÀN"
		btn.add_theme_color_override("font_color", Color(0.15, 0.6, 0.25, 1.0))
		
	btn_scam_action.disabled = true
	cat_speech_lbl.text = "ĐÃ CHẶN AN TOÀN! Tuyệt đối không bấm link lạ, không chuyển tiền cọc và không làm theo đe dọa qua điện thoại!"
	
	if blocked_scams.size() >= 3 and not completed_levels.has(3):
		completed_levels[3] = true
		_show_finance_victory()

func _get_scam_by_id(id: String) -> Dictionary:
	for s in SCAMS_DATA:
		if s["id"] == id: return s
	return {}

# =========================================================================
# VICTORY MODAL & CERTIFICATE
# =========================================================================
func _show_finance_victory() -> void:
	SoundManager.play_success()
	var speech = "🎉 CHÚC MỪNG BẬC THẦY TÀI CHÍNH & AN TOÀN SỐ!\n\n"
	speech += "Mèo con đã hoàn thành xuất sắc toàn bộ 3 Cấp độ Quản trị Tài chính & Không gian mạng:\n\n"
	speech += "✔ Cấp độ 1: Soi đơn giá 100g, né bẫy bao bì nhỏ và hàng cận date ngộ độc.\n"
	speech += "✔ Cấp độ 2: Làm chủ dòng tiền 30 ngày & dùng 'Ngăn Đợi 24h' đập tan cơn nghiện Flash Sale.\n"
	speech += "✔ Cấp độ 3: Pháp y 3 thủ đoạn lừa đảo tinh vi (link ngân hàng giả mạo, cọc việc làm, đe dọa).\n\n"
	speech += "🎖️ Nhận danh hiệu 'Chiến Binh Quản Trị Tài Chính & An Toàn Số' & Thưởng +45 Cá Khô!"
	if victory_dialogue_lbl:
		victory_dialogue_lbl.text = speech
		
	_build_polaroid_finance_pass()
	if victory_modal:
		victory_modal.visible = true

func _build_polaroid_finance_pass() -> void:
	if polaroid_cert_panel and is_instance_valid(polaroid_cert_panel):
		polaroid_cert_panel.queue_free()
		
	polaroid_cert_panel = PanelContainer.new()
	polaroid_cert_panel.name = "PolaroidFinancePass"
	polaroid_cert_panel.custom_minimum_size = Vector2(0, 115)
	
	var sb = load("res://assets/UI/CatUIPaid/slices/cozy_achievements/parchment_scroll_stylebox.tres")
	if sb:
		polaroid_cert_panel.add_theme_stylebox_override("panel", sb)
	else:
		var flat = StyleBoxFlat.new()
		flat.bg_color = Color(0.98, 0.96, 0.92, 1.0)
		flat.border_color = Color(0.65, 0.45, 0.30, 1.0)
		flat.set_border_width_all(2)
		flat.set_corner_radius_all(10)
		polaroid_cert_panel.add_theme_stylebox_override("panel", flat)
		
	var v = VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 4)
	
	var owner_name = GameManager.owner_name if "owner_name" in GameManager and GameManager.owner_name != "" else "Sen Thông Thái"
	
	var title = Label.new()
	title.text = "📜 CHỨNG NHẬN: CHỦ NHÂN TÀI CHÍNH & AN TOÀN SỐ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color(0.42, 0.22, 0.08, 1.0))
	v.add_child(title)
	
	var desc = Label.new()
	desc.text = "Cấp cho: %s\nHoàn tất 3 Cấp độ Giả lập Siêu Thị, Dòng Tiền 24h & Phòng Thủ Lừa Đảo Số • Tự lập tài chính vững vàng!" % [owner_name]
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 9)
	desc.add_theme_color_override("font_color", Color(0.35, 0.28, 0.22, 1.0))
	v.add_child(desc)
	
	polaroid_cert_panel.add_child(v)
	
	var vbox = victory_modal.get_node_or_null("ModalPanel/VBox")
	if vbox:
		var scroll = vbox.get_node_or_null("Scroll")
		if scroll:
			vbox.add_child(polaroid_cert_panel)
			vbox.move_child(polaroid_cert_panel, scroll.get_index())
		else:
			vbox.add_child(polaroid_cert_panel)

func _on_claim_reward_pressed() -> void:
	SoundManager.play_click()
	if victory_modal: victory_modal.visible = false
	GameManager.complete_lesson(11)
	var sim_steps = [
		{"icon": "🛒", "text": "Soi đơn giá 100g & HSD tránh bẫy siêu thị"},
		{"icon": "❄️", "text": "Bảo vệ dòng tiền 30 ngày bằng Ngăn Đợi 24h"},
		{"icon": "🛡️", "text": "Pháp y bóc trần 3 thủ đoạn lừa đảo không gian mạng"},
		{"icon": "💰", "text": "Giữ vững quỹ dự phòng khẩn cấp 1.500.000đ"}
	]
	emit_signal("minigame_completed", sim_steps)

func _on_help_pressed() -> void:
	SoundManager.play_click()
	match current_level:
		1:
			cat_speech_lbl.text = "💡 MẸO SIÊU THỊ: Lấy giá chia cho số gram nhân 100 để so sánh đơn giá thật. Luôn kiểm tra HSD để tránh ngộ độc!"
		2:
			cat_speech_lbl.text = "💡 MẸO CHỐT ĐƠN: Đưa món hàng muốn mua vào ngăn chờ 24 tiếng. 80% trường hợp sau 24h bạn sẽ nhận ra mình không cần nó!"
		3:
			cat_speech_lbl.text = "💡 MẸO AN TOÀN SỐ: Tên miền lạ, việc nhẹ lương cao nạp cọc, hay đe dọa bắt bớ qua điện thoại đều là lừa đảo!"

func _format_money(val: int) -> String:
	var s = str(absi(val))
	var res = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		count += 1
		if count % 3 == 0 and i > 0:
			res = "." + res
	return ("-" if val < 0 else "") + res
