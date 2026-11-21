extends PanelContainer

const PixelPlaceholderFactory = preload("res://scripts/utils/PixelPlaceholderFactory.gd")

## BudgetJarsWidget.gd
## Gamification 5: 3-Jar 2.000.000 VNĐ Monthly Budgeting System (50/30/20 Rule)
## Designed for the Main Room HUD / Financial Management View.
##
## Distribution of 2.000.000 VNĐ Monthly Budget:
## - Jar 1: Essential (50% = 1.000.000 VNĐ): Food, cat litter, rent/utilities.
## - Jar 2: Self-Growth (30% = 600.000 VNĐ): Skill books, toys, treats, accessories.
## - Jar 3: Emergency (20% = 400.000 VNĐ): Medicine, repairs, unexpected fees.

signal budget_changed(category: String, remaining: int, max_amount: int)
signal essential_depleted
signal budget_reset_completed

const MONTHLY_TOTAL_FISH: int = 2000000
const MAX_ESSENTIAL: int = 1000000
const MAX_GROWTH: int = 600000
const MAX_EMERGENCY: int = 400000

var fish_essential: int = 1000000
var fish_growth: int = 600000
var fish_emergency: int = 400000

# Nodes
@onready var lbl_total_summary: Label = $VBox/HeaderHBox/LblTotalSummary
@onready var btn_reset_month: Button = $VBox/HeaderHBox/BtnResetMonth

# Jar 1 Nodes
@onready var lbl_jar1_count: Label = $VBox/JarsHBox/JarEssential/VBox/LblCount
@onready var bar_jar1: ProgressBar = $VBox/JarsHBox/JarEssential/VBox/ProgressBar
@onready var icon_jar1: TextureRect = $VBox/JarsHBox/JarEssential/VBox/Icon

# Jar 2 Nodes
@onready var lbl_jar2_count: Label = $VBox/JarsHBox/JarGrowth/VBox/LblCount
@onready var bar_jar2: ProgressBar = $VBox/JarsHBox/JarGrowth/VBox/ProgressBar
@onready var icon_jar2: TextureRect = $VBox/JarsHBox/JarGrowth/VBox/Icon

# Jar 3 Nodes
@onready var lbl_jar3_count: Label = $VBox/JarsHBox/JarEmergency/VBox/LblCount
@onready var bar_jar3: ProgressBar = $VBox/JarsHBox/JarEmergency/VBox/ProgressBar
@onready var icon_jar3: TextureRect = $VBox/JarsHBox/JarEmergency/VBox/Icon

@onready var lbl_alert: Label = $VBox/LblAlert

func _ready() -> void:
	if btn_reset_month:
		btn_reset_month.pressed.connect(reset_monthly_budget)

	_setup_icons()
	update_ui()

func _setup_icons() -> void:
	if icon_jar1:
		icon_jar1.texture = PixelPlaceholderFactory.get_or_create(
			"jar_essential_50",
			Vector2i(32, 40),
			PixelPlaceholderFactory.Category.BUDGET_JAR,
			"50%"
		)
	if icon_jar2:
		icon_jar2.texture = PixelPlaceholderFactory.get_or_create(
			"jar_growth_30",
			Vector2i(32, 40),
			PixelPlaceholderFactory.Category.BUDGET_JAR,
			"30%"
		)
	if icon_jar3:
		icon_jar3.texture = PixelPlaceholderFactory.get_or_create(
			"jar_emergency_20",
			Vector2i(32, 40),
			PixelPlaceholderFactory.Category.BUDGET_JAR,
			"20%"
		)

## Checks whether a given jar has enough fish
func can_spend(category: String, amount: int) -> bool:
	match category.to_lower():
		"essential", "food", "rent", "thiet_yeu":
			return fish_essential >= amount
		"growth", "shop", "toys", "books", "phat_trien":
			return fish_growth >= amount
		"emergency", "medicine", "repair", "khan_cap":
			return fish_emergency >= amount
		_:
			return (fish_essential + fish_growth + fish_emergency) >= amount

## Spends fish from designated jar with automatic bounds checking
func spend_fish(category: String, amount: int) -> bool:
	if not can_spend(category, amount):
		_show_alert("⚠️ Không đủ cá trong hũ %s! Hãy cân đối lại chi tiêu." % category)
		return false

	match category.to_lower():
		"essential", "food", "rent", "thiet_yeu":
			fish_essential -= amount
			budget_changed.emit("essential", fish_essential, MAX_ESSENTIAL)
			if fish_essential <= 0:
				essential_depleted.emit()
				_show_alert("🚨 HŨ THIẾT YẾU ĐÃ HẾT CÁ! Mèo có nguy cơ bị đói!")
		"growth", "shop", "toys", "books", "phat_trien":
			fish_growth -= amount
			budget_changed.emit("growth", fish_growth, MAX_GROWTH)
		"emergency", "medicine", "repair", "khan_cap":
			fish_emergency -= amount
			budget_changed.emit("emergency", fish_emergency, MAX_EMERGENCY)

	update_ui()
	return true

## Deposit / earn fish back into a jar
func deposit_fish(category: String, amount: int) -> void:
	match category.to_lower():
		"essential", "thiet_yeu":
			fish_essential = mini(MAX_ESSENTIAL, fish_essential + amount)
		"growth", "phat_trien":
			fish_growth = mini(MAX_GROWTH, fish_growth + amount)
		"emergency", "khan_cap":
			fish_emergency = mini(MAX_EMERGENCY, fish_emergency + amount)
	update_ui()

## Resets to 2.000.000 VNĐ at the start of a new month
func reset_monthly_budget(total: int = MONTHLY_TOTAL_FISH) -> void:
	fish_essential = MAX_ESSENTIAL
	fish_growth = MAX_GROWTH
	fish_emergency = MAX_EMERGENCY
	_show_alert("✨ Đã cấp ngân sách tháng mới: 1.000.000đ Thiết Yếu, 600.000đ Phát Triển, 400.000đ Khẩn Cấp.")
	update_ui()
	budget_reset_completed.emit()

func format_amount(amount: int) -> String:
	var s = str(amount)
	var res = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		count += 1
		if count % 3 == 0 and i > 0:
			res = "." + res
	return "%sđ" % res

func update_ui() -> void:
	var total_current: int = fish_essential + fish_growth + fish_emergency
	if lbl_total_summary:
		lbl_total_summary.text = "Tổng Ngân Sách Tháng: %s / 2.000.000đ" % format_amount(total_current)

	if lbl_jar1_count:
		lbl_jar1_count.text = "%s / %s" % [format_amount(fish_essential), format_amount(MAX_ESSENTIAL)]
	if bar_jar1:
		bar_jar1.max_value = MAX_ESSENTIAL
		bar_jar1.value = fish_essential

	if lbl_jar2_count:
		lbl_jar2_count.text = "%s / %s" % [format_amount(fish_growth), format_amount(MAX_GROWTH)]
	if bar_jar2:
		bar_jar2.max_value = MAX_GROWTH
		bar_jar2.value = fish_growth

	if lbl_jar3_count:
		lbl_jar3_count.text = "%s / %s" % [format_amount(fish_emergency), format_amount(MAX_EMERGENCY)]
	if bar_jar3:
		bar_jar3.max_value = MAX_EMERGENCY
		bar_jar3.value = fish_emergency

func _show_alert(msg: String) -> void:
	if lbl_alert:
		lbl_alert.text = msg
		lbl_alert.visible = true
