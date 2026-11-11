extends "res://scripts/categories/BaseCategoryView.gd"

# CategoryMobility.gd - Danh mục 1: Đi Lại & Di Chuyển ("Đường Phố Thổ Địa")
# Quản lý 6 minigame cốt lõi về kỹ năng di chuyển, xe buýt, metro, bùng binh, xe máy & luật giao thông

func _init() -> void:
	category_id = 1
	category_name = "ĐI LẠI & GIAO THÔNG"
	category_title = "Đường Phố Thổ Địa"
	category_subtitle = "Cơ động vững vàng - Không sợ lạc lối giữa thị thành rộng lớn"
	category_icon = "🚌"
	theme_color = Color(0.20, 0.60, 0.95)
	theme_bevel = Color(0.12, 0.45, 0.75)
	bg_color = Color(0.93, 0.96, 0.99)
	
	minigames_list = [
		{
			"id": "civilized_ride",
			"lesson_id": 1,
			"icon": "🚍",
			"title": "Chuyến Đi Văn Minh - Xe Buýt Số 08",
			"desc": "Quy tắc lên xuống xe buýt, chuẩn bị tiền lẻ, bấm chuông xuống trạm và cảnh giác chống móc túi.",
			"type_badge": "Văn Hóa Xe Bus",
			"scene_path": "res://scenes/minigames/CivilizedRideGame.tscn",
			"data_key": "civilized_ride"
		},
		{
			"id": "route_master",
			"lesson_id": 2,
			"icon": "🗺️",
			"title": "Thổ Địa Lập Route - Đọc Tuyến BusMap",
			"desc": "Tìm trạm, chọn tuyến xe buýt chuyển tuyến khi đi học xa không lo trễ giờ điểm danh.",
			"type_badge": "Lập Lộ Trình",
			"scene_path": "res://scenes/minigames/RouteMasterMiniGame.tscn",
			"data_key": "route_master"
		},
		{
			"id": "checkin_rush",
			"lesson_id": 3,
			"icon": "🎫",
			"title": "Check-in Thần Tốc - Ga Metro & Trạm Xe Bus",
			"desc": "Soát vé tự động, quẹt thẻ sinh viên / vé điện tử đúng làn và giữ trật tự tại cổng kiểm soát.",
			"type_badge": "Soát Vé Metro",
			"scene_path": "res://scenes/minigames/CheckInRushGame.tscn",
			"data_key": "checkin_rush"
		},
		{
			"id": "qte_roundabout",
			"lesson_id": 12,
			"icon": "🔄",
			"title": "Bật Xi-Nhan Thoát Bùng Binh An Toàn",
			"desc": "Định vị la bàn và phản xạ bật đèn tín hiệu thoát bùng binh / vòng xuyến lớn an toàn.",
			"type_badge": "Phản Xạ QTE",
			"scene_path": "res://scenes/minigames/QteMiniGame.tscn",
			"data_key": "12"
		},
		{
			"id": "motorbike_maintenance",
			"lesson_id": 4,
			"icon": "🛵",
			"title": "Bảo Dưỡng & Sự Cố Xe Máy",
			"desc": "Nối 5 dấu hiệu hỏng hóc (sên chùng, xả nhớt máy, đo áp suất lốp...) & 4 tình huống chẩn đoán sự cố.",
			"type_badge": "Nối & Chẩn Đoán",
			"scene_path": "res://scenes/minigames/MotorbikeMaintenanceGame.tscn",
			"data_key": "motorbike_maintenance"
		},
		{
			"id": "traffic_safety",
			"lesson_id": 4,
			"icon": "🚦",
			"title": "An Toàn Giao Thông & Xử Lý Vi Phạm CSGT",
			"desc": "Nối mức phạt vi phạm nồng độ cồn/không mũ & Sắp xếp 4 bước xử lý an toàn khi va chạm giao thông.",
			"type_badge": "Nối & Trình Tự",
			"scene_path": "res://scenes/minigames/TrafficSafetyGame.tscn",
			"data_key": "4"
		}
	]
