extends "res://scripts/categories/BaseCategoryView.gd"

# CategoryFinanceCareer.gd - Danh mục 4: Tài Chính & Việc Làm ("Túi Tiền Thông Thái")
# Quản lý 6 minigame cốt lõi về ngân sách 5 triệu, 3 hũ tiền, đa cấp ponzi, ví trả sau, HĐLĐ, quản lý thời gian

func _init() -> void:
	category_id = 4
	category_name = "TÀI CHÍNH & VIỆC LÀM"
	category_title = "Túi Tiền Thông Thái"
	category_subtitle = "Quản lý ngân sách - Thoát bẫy nợ nần & Tự tin bước vào thao trường xã hội"
	category_icon = "💰"
	theme_color = Color(0.95, 0.65, 0.15)
	theme_bevel = Color(0.75, 0.45, 0.08)
	bg_color = Color(0.99, 0.97, 0.92)
	
	minigames_list = [
		{
			"id": "personal_finance",
			"lesson_id": 13,
			"icon": "💵",
			"title": "Quản Lý Tài Chính & Sống Sót 5 Triệu Đồng",
			"desc": "Nối 5 khoản chi phí (thiết yếu, sinh hoạt, tích lũy) & Tình huống sống sót với ngân sách 5 triệu/tháng.",
			"type_badge": "Nối Chi Phí & Sinh Tồn",
			"scene_path": "res://scenes/minigames/PersonalFinanceGame.tscn",
			"data_key": "personal_finance"
		},
		{
			"id": "three_jars_budget",
			"lesson_id": 13,
			"icon": "🏺",
			"title": "Quy Tắc 3 Hũ Tiền: Giữ Thăng Bằng Ngân Sách",
			"desc": "Phân bổ 90 Cá Khô theo tỷ lệ 50-30-20: Sống còn (Hạt) - Phát triển (Học) - Dự phòng khẩn cấp.",
			"type_badge": "Cân Bằng 3 Hũ Tiền",
			"scene_path": "res://scenes/minigames/BudgetMiniGame.tscn",
			"data_key": "13"
		},
		{
			"id": "cyber_security",
			"lesson_id": 14,
			"icon": "🛡️",
			"title": "Luật An Ninh Mạng & Tránh Bẫy Lừa Đảo",
			"desc": "Nối hành vi vi phạm mạng với hình thức xử lý & Trắc nghiệm Đúng/Sai đánh giá tính hợp pháp.",
			"type_badge": "Nối Chế Tài & Đúng/Sai",
			"scene_path": "res://scenes/minigames/CyberSecurityGame.tscn",
			"data_key": "14"
		},
		{
			"id": "labor_rights",
			"lesson_id": 15,
			"icon": "⚖️",
			"title": "Quyền Lao Động & Hợp Đồng Cho Người Trẻ",
			"desc": "Nối con số pháp lý (thử việc 60 ngày, 85% lương, báo trước 45 ngày) & Kéo thả Đúng vs Vi phạm luật.",
			"type_badge": "Nối & Phân Loại Luật",
			"scene_path": "res://scenes/minigames/LaborRightsGame.tscn",
			"data_key": "15"
		},
		{
			"id": "bnpl_debt_trap",
			"lesson_id": 16,
			"icon": "💳",
			"title": "Thoát Bẫy Nợ Ví Trả Sau BNPL & Thấu Chi",
			"desc": "Kích hoạt bộ lọc 'Phanh tiêu dùng 48h' trước khi chốt đơn online, tránh bẫy nợ tín dụng và đa cấp.",
			"type_badge": "Phanh Tiêu Dùng 48H",
			"scene_path": "res://scenes/minigames/BudgetMiniGame.tscn",
			"data_key": "16"
		},
		{
			"id": "time_management",
			"lesson_id": 15,
			"icon": "⏰",
			"title": "Quản Lý Thời Gian & Xử Lý Ma Trận Deadline",
			"desc": "Sắp xếp 7 mốc sinh hoạt hợp lý cho 1 ngày tự lập & Xử lý tình huống ma trận Deadline đang đến.",
			"type_badge": "Sắp Xếp & Ma Trận Deadline",
			"scene_path": "res://scenes/minigames/TimeManagementGame.tscn",
			"data_key": "time_management"
		}
	]
