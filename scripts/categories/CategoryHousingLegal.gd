extends "res://scripts/categories/BaseCategoryView.gd"

# CategoryHousingLegal.gd - Danh mục 2: Nơi Ở & Pháp Lý Cư Trú ("Bình Yên Xóm Trọ")
# Quản lý 5 minigame cốt lõi về hợp đồng thuê nhà, PCCC, VNeID tạm trú, hiệp ước bạn cùng phòng

func _init() -> void:
	category_id = 2
	category_name = "NƠI Ở & PHÁP LÝ CƯ TRÚ"
	category_title = "Bình Yên Xóm Trọ"
	category_subtitle = "An cư lập nghiệp - Tránh bẫy hợp đồng, phòng cháy an toàn & hòa thuận"
	category_icon = "🏠"
	theme_color = Color(0.95, 0.45, 0.35)
	theme_bevel = Color(0.75, 0.25, 0.15)
	bg_color = Color(0.99, 0.95, 0.93)
	
	minigames_list = [
		{
			"id": "housing_legal_simulation",
			"lesson_id": 5,
			"icon": "🔍",
			"title": "Soi Phòng Trọ 2D: Tìm Điểm Khác Biệt & Lỗi Ẩn",
			"desc": "So sánh 2 căn phòng trọ bằng kính lúp, phát hiện 4 lỗi ngầm: vòi nước rò rỉ, công tơ điện quay lén, chốt cửa lỏng, vết dột trần.",
			"type_badge": "Tìm Điểm Khác Biệt 2D Pixel",
			"scene_path": "res://scenes/minigames/room_inspection_diff_game.tscn",
			"data_key": "5"
		},
		{
			"id": "rental_contract",
			"lesson_id": 5,
			"icon": "📜",
			"title": "Hiểu Biết Pháp Luật Hợp Đồng Thuê Nhà",
			"desc": "Soi lỗi hạ tầng phòng trọ thực tế trước khi đặt bút ký cọc.",
			"type_badge": "Soi Lỗi Hạ Tầng",
			"scene_path": "res://scenes/minigames/room_inspection_diff_game.tscn",
			"data_key": "5"
		},
		{
			"id": "pccc_audit",
			"lesson_id": 6,
			"icon": "🧯",
			"title": "Thám Tử PCCC: Khảo Sát An Toàn Phòng Trọ",
			"desc": "Soi kính lúp tìm các điểm nguy cơ cháy nổ, kiểm tra công tơ và ổ cắm điện.",
			"type_badge": "Soi Điểm Nguy Hiểm",
			"scene_path": "res://scenes/minigames/room_inspection_diff_game.tscn",
			"data_key": "6"
		},
		{
			"id": "public_admin",
			"lesson_id": 7,
			"icon": "🏛️",
			"title": "Thủ Tục Hành Chính Công & VNeID",
			"desc": "Nối đúng cơ quan hành chính & Sắp xếp 4 bước đăng ký tạm trú trực tuyến trên Cổng DVC / VNeID.",
			"type_badge": "Nối & Trình Tự VNeID",
			"scene_path": "res://scenes/minigames/PublicAdminGame.tscn",
			"data_key": "7"
		},
		{
			"id": "comm_conflict",
			"lesson_id": 8,
			"icon": "🤝",
			"title": "Giao Tiếp & Giải Quyết Mâu Thuẫn Phòng Trọ",
			"desc": "Xử lý 3 tình huống bạn cùng phòng & Phân loại câu nói Giao tiếp Xanh (tích cực) vs Đỏ (tiêu cực).",
			"type_badge": "Phân Loại Xanh / Đỏ",
			"scene_path": "res://scenes/minigames/CommunicationConflictGame.tscn",
			"data_key": "communication_conflict"
		},
		{
			"id": "dialogue_roommate",
			"lesson_id": 8,
			"icon": "🧋",
			"title": "Họp Phòng Trà Sữa: Hiệp Ước Bạn Cùng Phòng",
			"desc": "Đối thoại tình huống, thiết lập ranh giới cá nhân, phân chia dọn vệ sinh toilet và tiền sinh hoạt.",
			"type_badge": "Đối Thoại Đóng Vai",
			"scene_path": "res://scenes/minigames/DialogueMiniGame.tscn",
			"data_key": "8"
		}
	]
