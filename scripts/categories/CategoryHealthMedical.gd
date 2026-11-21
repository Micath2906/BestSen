extends "res://scripts/categories/BaseCategoryView.gd"

# CategoryHealthMedical.gd - Danh mục 3: Y Tế & Sức Khỏe Tự Thân ("Thân Thể Kim Cương")
# Quản lý 6 minigame cốt lõi về vali thuốc, chọn bệnh viện, chẩn đoán sốt đêm, 6 bước BHYT, giặt giũ dinh dưỡng

func _init() -> void:
	category_id = 3
	category_name = "Y TẾ & SỨC KHỎE TỰ THÂN"
	category_title = "Thân Thể Kim Cương"
	category_subtitle = "Tự chăm sóc bản thân - Vững vàng vượt qua những đêm ốm đau đất khách"
	category_icon = "🩺"
	theme_color = Color(0.18, 0.75, 0.55)
	theme_bevel = Color(0.10, 0.55, 0.38)
	bg_color = Color(0.93, 0.98, 0.95)
	
	minigames_list = [
		{
			"id": "healthcare_wellness_simulation",
			"lesson_id": 3,
			"icon": "🩺",
			"title": "Giả Lập Bác Sĩ Mèo Nhí: Chẩn Đoán & Kê Đơn",
			"desc": "3 Chặng thực chiến: Chẩn đoán 3 ca bệnh học đường, kê đơn đúng thuốc vào tủ sơ cứu & thủ tục khám BHYT đúng tuyến.",
			"type_badge": "Giả Lập Bác Sĩ 2D Pixel",
			"scene_path": "res://scenes/minigames/doctor_simulation_game.tscn",
			"data_key": "3"
		},
		{
			"id": "preparation_vali",
			"lesson_id": 1,
			"icon": "🧳",
			"title": "Lời Dặn Dò Của Mẹ Khi Chuẩn Bị Lên Đại Học",
			"desc": "Kéo thả xếp đồ vào Vali tân sinh viên phong cách Unpacking 2D Pixel ấm cúng.",
			"type_badge": "Xếp Vali Unpacking 2D",
			"scene_path": "res://scenes/minigames/packing_minigame.tscn",
			"data_key": "1"
		},
		{
			"id": "hospital_choice",
			"lesson_id": 2,
			"icon": "🏥",
			"title": "Lựa Chọn Bệnh Viện Chuyên Khoa Đúng Bệnh",
			"desc": "Dựa trên tình hình bạn cùng phòng, trả lời câu hỏi và chọn đúng bệnh viện chuyên khoa.",
			"type_badge": "Chọn Bệnh Viện Chuyên Khoa",
			"scene_path": "res://scenes/minigames/doctor_simulation_game.tscn",
			"data_key": "2"
		},
		{
			"id": "self_diagnosis",
			"lesson_id": 3,
			"icon": "🌡️",
			"title": "Xác Định Đúng Bệnh Trước Khi Uống Thuốc",
			"desc": "Chẩn đoán triệu chứng sốt cảm, kê đúng liều hạ sốt và bù nước.",
			"type_badge": "Chẩn Đoán & Chọn Thuốc",
			"scene_path": "res://scenes/minigames/doctor_simulation_game.tscn",
			"data_key": "3"
		},
		{
			"id": "bhyt_process",
			"lesson_id": 10,
			"icon": "📋",
			"title": "Quy Trình Khám BHYT Đúng Tuyến",
			"desc": "Chuẩn bị CCCD/VNeID, xuất trình thẻ BHYT và hoàn tất thủ tục khám.",
			"type_badge": "Quy Trình BHYT Chuẩn",
			"scene_path": "res://scenes/minigames/doctor_simulation_game.tscn",
			"data_key": "10"
		},
		{
			"id": "first_aid_packing",
			"lesson_id": 11,
			"icon": "💊",
			"title": "Xếp Hộp Thuốc Cứu Thương Sinh Viên",
			"desc": "Xếp 4 món y tế khẩn cấp vào hộp sơ cứu phòng trọ: hạ sốt, men tiêu hóa, băng gạc, oresol bù nước.",
			"type_badge": "Kéo Thả Hộp Thuốc",
			"scene_path": "res://scenes/minigames/doctor_simulation_game.tscn",
			"data_key": "11"
		},
		{
			"id": "self_care_living",
			"lesson_id": 9,
			"icon": "🥗",
			"title": "Tự Chăm Sóc Bản Thân & Quản Lý Sinh Hoạt",
			"desc": "Sắp xếp 4 bước giặt giũ đồ (Đảm đang không khó) & Trắc nghiệm Hôm nay ăn gì cân bằng dinh dưỡng, cai mì tôm.",
			"type_badge": "Giặt Giũ & Dinh Dưỡng",
			"scene_path": "res://scenes/minigames/SelfCareLivingGame.tscn",
			"data_key": "self_care_living"
		}
	]
