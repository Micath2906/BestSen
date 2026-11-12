extends Node

# GameManager.gd - Singleton AutoLoad
# Quản lý 3 chỉ số sinh tồn, dữ liệu 16 bài học, tiến độ, chiến lợi phẩm, âm thanh

signal stats_changed
signal lesson_completed(lesson_id)
signal show_toast(message)
signal avatar_changed(avatar_id)
signal costume_changed(slot, item_id)
signal decor_changed(slot, item_id)
signal room_name_changed(new_name)
signal show_status_alert(alert_type)
signal avatar_frame_changed(frame_id)
signal classic_bg_changed(bg_id)
signal placed_decor_changed
signal minigame_hud_active(active: bool)
signal minigame_hud_updated(time_left: float, progress_pct: float)

# Hệ thống hội thoại Cozy (UI-03)
var cozy_dialogs: Dictionary = {}

# 3 CHỈ SỐ SINH TỒN CỐT LÕI & TÂM TRẠNG
var fish: int = 90        # Đồng Vàng (Khởi điểm 90 Đồng Vàng / chu kỳ 30 ngày)
var hunger: int = 70      # Độ No (0 - 100 Điểm)
var courage: int = 80     # Dũng Cảm (0 - 100 Điểm)
var mood: int = 85        # Tâm Trạng (0 - 100 Điểm) Vui vẻ / Hạnh phúc

# KHUNG AVATAR MÈO (6 kiểu khung tai mèo CatUIPaid)
var selected_avatar_frame: String = "beige"
var available_avatar_frames: Array = [
	{"id": "beige", "name": "Be Cổ Điển", "path": "res://assets/UI/CatUIPaid/slices/avatar_frames/frame_cat_ear_beige.png"},
	{"id": "cream", "name": "Kem Sữa", "path": "res://assets/UI/CatUIPaid/slices/avatar_frames/frame_cat_ear_cream.png"},
	{"id": "pink", "name": "Hồng Dễ Thương", "path": "res://assets/UI/CatUIPaid/slices/avatar_frames/frame_cat_ear_pink.png"},
	{"id": "dark", "name": "Đen Huyền Bí", "path": "res://assets/UI/CatUIPaid/slices/avatar_frames/frame_cat_ear_dark.png"},
	{"id": "blue", "name": "Xanh Pastel", "path": "res://assets/UI/CatUIPaid/slices/avatar_frames/frame_cat_ear_blue.png"},
	{"id": "gold", "name": "Vàng Hoàng Gia", "path": "res://assets/UI/CatUIPaid/slices/avatar_frames/frame_cat_ear_gold.png"}
]

# HÌNH NỀN PHÒNG CLASSIC (20 hình nền Classic từ PetMobileGameAsset)
var selected_classic_bg_id: int = 1

# AVATAR MÈO (8 Avatar từ RetroCats)
var selected_avatar_id: int = 0
var custom_cat_name: String = ""
var owner_name: String = "Tân Sinh Viên"
var has_completed_onboarding: bool = false
var avatar_list: Array = [
	{"id": 0, "name": "Mèo Mướp Cam", "desc": "Năng động, háu ăn, thích khám phá"},
	{"id": 1, "name": "Mèo Vàng Thông Thái", "desc": "Chăm chỉ học bài, tính toán chi tiêu giỏi"},
	{"id": 2, "name": "Mèo Tam Thể Xóm Trọ", "desc": "Tháo vát, quen mặt khắp ngõ hẻm phố xá"},
	{"id": 3, "name": "Mèo Xám Tro", "desc": "Trầm tĩnh, cẩn thận, không bao giờ để quên đồ"},
	{"id": 4, "name": "Mèo Tuxedo Quý Tộc", "desc": "Lịch sự, tự tin khi giao tiếp và phỏng vấn"},
	{"id": 5, "name": "Mèo Tuyết Trắng", "desc": "Ngây thơ, đáng yêu, luôn được mọi người giúp đỡ"},
	{"id": 6, "name": "Mèo Đen Ninja", "desc": "Nhanh nhẹn, đi xe buýt không sợ chen lấn"},
	{"id": 7, "name": "Mèo Xiêm Khởi Nghiệp", "desc": "Ý chí tự lập cao, biết tìm việc làm thêm an toàn"},
	{"id": 8, "name": "Mèo Mochi", "desc": "Bạch miêu mắt hai màu dị tật xinh xắn, quàng nơ hồng điệu đà"},
	{"id": 9, "name": "Mèo Pochi", "desc": "Mèo đốm vàng lanh lợi, luôn vui vẻ lạc quan tiếp sức cho Sen"}
]

# CÁC BIẾN TIẾN ĐỘ
var current_day: int = 1
var unlocked_lessons: Array = [1] # Mở sẵn bài 1
var completed_lessons: Array = []
var loot_collection: Array = []
var badges: Array = []

# HỆ THỐNG GACHA LOOT BOX & CAT MASTERY LEVEL
var cat_mastery_level: int = 1
var cat_mastery_exp: int = 0
var inventory_decor: Array = []
var inventory_costumes: Array = []
var inventory_toys: Array = []
var inventory_food: Array = []
var food_inventory: Dictionary = {
	"kibble": 5,
	"pate": 2,
	"dry_fish": 3
}
var equipped_costume: String = "" # Giữ tương thích ngược với trang phục chính
var equipped_costumes: Dictionary = {
	"clothes": "",
	"hats": "",
	"bows": "",
	"accessories": ""
}
var equipped_decor: Dictionary = {
	"beds": "d_bed_box",
	"bowls": "d_bowl_basic",
	"rugs": "",
	"wall": "",
	"plants": ""
}
var placed_room_decor: Array = []
var custom_room_name: String = ""

signal room_state_updated
const ROOM_SAVE_PATH = "user://room_save.json"
const HUNGER_DECAY_PER_HOUR: float = 5.0
var room_upgrades: Dictionary = {
	"heat_insulation": false,
	"mini_fan": false
}
var furniture_grid_positions: Dictionary = {}
var food_bowl_servings: int = 0
var last_active_unix: int = 0
var is_offline_auto_sleeping: bool = false
var last_offline_summary: Dictionary = {}
var _hunger_tick_accum: float = 0.0

# HỆ THỐNG CHI PHÍ HÀNG THÁNG SINH VIÊN (KTX / TRỌ)
var monthly_rent_cost: int = 50       # 50.000đ Tiền phòng KTX / trọ
var monthly_utility_cost: int = 15    # 15.000đ Điện nước wifi
var monthly_cat_food_cost: int = 20   # 20.000đ Quỹ thức ăn sinh tồn cho Mèo
var days_until_rent_due: int = 25     # Ngày đếm ngược đến hạn đóng tiền KTX
var is_rent_paid_this_month: bool = false
signal monthly_rent_paid

# HỆ THỐNG CHỨNG NHẬN PUZZLE (4 BỘ TRANH GHÉP SINH TỒN)
var claimed_certificates: Array = [] # Danh sách id chứng nhận đã nhận: ["cert_street", "cert_room", "cert_health", "cert_finance"]

# HỆ THỐNG CỨU TRỢ SINH VIÊN (PEER RELIEF)
var daily_relief_sent: int = 0      # Tối đa 20 Cá / ngày
var daily_relief_received: int = 0  # Tối đa 40 Cá / ngày

# TRẠNG THÁI SỨC KHỎE & TÂM LÝ
var is_fainted: bool = false # Mèo ngất xỉu khi hunger <= 0
var is_shy: bool = false     # Mèo tự ti khi courage <= 15

# DỮ LIỆU TỪ JSON
var skills_json_data: Dictionary = {}
var cards_json_data: Dictionary = {}
var loot_tables_data: Dictionary = {}
var peer_system_data: Dictionary = {}
var shop_catalog_data: Dictionary = {}
var minigames_data: Dictionary = {}
var story_lessons_data: Dictionary = {}
var debt_amount: int = 0  # Bẫy nợ ví trả sau
var debt_due_day: int = 0

# DỮ LIỆU TOÀN BỘ 16 BÀI HỌC THUỘC 4 NHÁNH
var lessons_data: Dictionary = {
	1: {
		"id": 1,
		"branch": 1,
		"branch_name": "Kỹ Năng Chuẩn Bị (Hành Trang)",
		"title": "Lời Dặn Dò Của Mẹ Khi Chuẩn Bị Lên Đại Học",
		"context": "Tự chuẩn bị các loại thuốc thích hợp trong sinh hoạt hằng ngày và xếp vali đúng vị trí theo lời dặn của mẹ.",
		"guide": [
			"1. Xếp đồ ngăn nắp vào đúng 4 ngăn vali: Thuốc y tế, Giấy tờ nhập học, Trang phục cá nhân, Thiết bị học tập.",
			"2. Dán nhãn đúng công dụng từng loại thuốc: Paracetamol (Hạ sốt & giảm đau), Berberin (Đau bụng & tiêu hóa), Oresol (Bù nước & điện giải), Băng Urgo/Cồn đỏ (Sát trùng vết thương).",
			"3. Ghi nhớ lời mẹ dặn: Uống thuốc đúng liều lượng, pha Oresol đúng tỷ lệ 200ml, không mang đồ cồng kềnh vô bổ làm chật vali.",
			"4. Khóa vali tự tin lên đường: Hành trang sẵn sàng 100% tự lập bước vào giảng đường Đại học."
		],
		"cards": [
			{"code": "A", "meow": "Meo Xếp Vali 📦", "icon": "📦", "text": "Xếp đồ vào đúng 4 ngăn Vali", "step": 1},
			{"code": "B", "meow": "Meo Dán Nhãn 🏷️", "icon": "🏷️", "text": "Dán nhãn công dụng thuốc thiết yếu", "step": 2},
			{"code": "C", "meow": "Meo Lời Mẹ Dặn 📜", "icon": "📜", "text": "Điền khuyết ghi nhớ lưu ý của mẹ", "step": 3},
			{"code": "D", "meow": "Meo Lên Đường 🎒", "icon": "🎒", "text": "Khóa vali hành trang tự lập lên đường", "step": 4}
		],
		"fail_msg": "Quê xệ! Mèo chưa xếp vali và dán nhãn thuốc cẩn thận đã vội vã lên đường!",
		"success_msg": "Mẹ mỉm cười xoa đầu khen ngợi: Boss Mèo đã sẵn sàng hành trang tự lập lên Đại học!",
		"loot_name": "Túi Thuốc Y Tế Của Mẹ",
		"loot_desc": "Túi thuốc sơ cứu bỏ túi chứa đầy đủ thuốc hạ sốt, tiêu hóa và tình yêu thương của Mẹ.",
		"reward_fish": 35,
		"achievement": "Người Con Ngoan Của Mẹ",
		"cheat_sheet": "BÍ KÍP SEN: Xếp 4 ngăn vali -> Dán nhãn thuốc thiết yếu -> Nhớ lời mẹ dặn -> Khóa vali lên đường"
	},
	2: {
		"id": 2,
		"branch": 1,
		"branch_name": "Kỹ Năng Chuẩn Bị (Hành Trang)",
		"title": "Lựa Chọn Bệnh Viện Đúng Bệnh",
		"context": "Dựa trên tình hình của người bạn cùng phòng: trả lời các câu hỏi và chọn đúng bệnh viện chuyên khoa cấp cứu kịp thời.",
		"guide": [
			"1. Quan sát đánh giá chính xác triệu chứng của bạn cùng phòng (chấn thương xương khớp, sốt xuất huyết, bỏng mắt...).",
			"2. Xác định đúng chuyên khoa điều trị (Chấn thương chỉnh hình, Nhiệt đới, Mắt...).",
			"3. Tra cứu và chọn chính xác bệnh viện tuyến đầu có chuyên khoa đó, tránh đi lòng vòng làm mất thời gian vàng cấp cứu.",
			"4. Mang theo hồ sơ CCCD, thẻ BHYT và gọi xe cấp cứu chuyển viện an toàn."
		],
		"cards": [
			{"code": "A", "meow": "Meo Khám Bệnh 🤕", "icon": "🤕", "text": "Khám triệu chứng bạn cùng phòng", "step": 1},
			{"code": "B", "meow": "Meo Chuyên Khoa 🩺", "icon": "🩺", "text": "Xác định chuyên khoa điều trị", "step": 2},
			{"code": "C", "meow": "Meo Chọn Viện 🏥", "icon": "🏥", "text": "Chọn đúng bệnh viện chuyên sâu", "step": 3},
			{"code": "D", "meow": "Meo Cấp Cứu 🚑", "icon": "🚑", "text": "Cấp cứu kịp thời đúng nơi", "step": 4}
		],
		"fail_msg": "Quê xệ! Chọn sai bệnh viện khiến bạn cùng phòng phải chuyển viện lòng vòng mất thời gian vàng!",
		"success_msg": "Tuyệt vời! Mèo chọn chuẩn bệnh viện chuyên khoa, bác sĩ cấp cứu kịp thời cứu nguy cho bạn!",
		"loot_name": "Sổ Tay Danh Bạ Cấp Cứu 115",
		"loot_desc": "Danh bạ bỏ túi các bệnh viện chuyên khoa tuyến đầu và số điện thoại cấp cứu y tế.",
		"reward_fish": 35,
		"achievement": "Thổ Địa Cứu Cấp Bệnh Viện",
		"cheat_sheet": "BÍ KÍP CẤP CỨU: Khám triệu chứng -> Chọn chuyên khoa -> Đến đúng bệnh viện chuyên sâu -> Cứu chữa an toàn."
	},
	3: {
		"id": 3,
		"branch": 1,
		"branch_name": "Kỹ Năng Chuẩn Bị (Hành Trang)",
		"title": "Xác Định Đúng Bệnh Trước Khi Uống Thuốc",
		"context": "Dùng dụng cụ y tế chẩn đoán cơ thể, lập bảng thống kê thông tin và chọn đúng loại thuốc cần dùng.",
		"guide": [
			"1. Lượt 1: Dùng đúng dụng cụ y tế trong hộp cứu thương (nhiệt kế điện tử, bảng theo dõi) để đo đạc chỉ số chính xác.",
			"2. Đối chiếu Bảng thống kê thông tin để rút ra kết luận chẩn đoán sơ bộ (sốt cao, tiêu chảy, dị ứng...).",
			"3. Lượt 2: Tìm và chọn đúng lọ thuốc đặc trị cho bệnh đó (Paracetamol khi sốt cao, Berberin khi đau bụng, Clorpheniramin khi dị ứng).",
			"4. Uống thuốc đúng liều lượng, bù nước Oresol và theo dõi tiến triển sức khỏe."
		],
		"cards": [
			{"code": "A", "meow": "Meo Đo Chỉ Số 🌡️", "icon": "🌡️", "text": "Dùng dụng cụ đo chỉ số cơ thể", "step": 1},
			{"code": "B", "meow": "Meo Bảng Bệnh 📋", "icon": "📋", "text": "Lập bảng thống kê triệu chứng", "step": 2},
			{"code": "C", "meow": "Meo Chọn Thuốc 💊", "icon": "💊", "text": "Chọn đúng thuốc đặc trị", "step": 3},
			{"code": "D", "meow": "Meo Khỏi Bệnh ✨", "icon": "✨", "text": "Hồi phục sức khỏe an toàn", "step": 4}
		],
		"fail_msg": "Nguy hiểm! Đoán mò uống sai thuốc sẽ gây ngộ độc hoặc biến chứng nguy hiểm!",
		"success_msg": "Xuất sắc! Mèo đo nhiệt kế 38.8 độ xác định đúng sốt cao và uống đúng liều Paracetamol hạ sốt an toàn!",
		"loot_name": "Nhiệt Kế Điện Tử Đầu Mềm",
		"loot_desc": "Nhiệt kế điện tử kẹp nách chính xác, thiết bị chẩn đoán y tế quan trọng nhất của sinh viên.",
		"reward_fish": 35,
		"achievement": "Dược Sĩ Của Bản Thân",
		"cheat_sheet": "BÍ KÍP DÙNG THUỐC: Đo chỉ số -> Lập bảng triệu chứng -> Chọn đúng thuốc đặc trị -> Uống đủ liều."
	},
	4: {
		"id": 4,
		"branch": 1,
		"branch_name": "Đường Phố Thổ Địa (Di chuyển)",
		"title": "Cứu Hộ Xe Máy Cơ Bản",
		"context": "Xe máy phát ra tiếng kêu lạ xè xè ở gầm xích khi đang chở bạn đi học nhóm.",
		"guide": [
			"1. Dựng chống đứng kiểm tra độ chùng của xích (sên) và độ mòn gai lốp.",
			"2. Ghé tiệm sửa xe quen hoặc tiệm uy tín, hỏi giá tăng sên trước khi làm.",
			"3. Kiểm tra que thăm nhớt: nếu nhớt đen kịt hoặc dưới vạch min thì thay nhớt mới.",
			"4. Yêu cầu thợ giữ lại vỏ chai nhớt đã mở để đảm bảo không bị dùng nhớt tái chế."
		],
		"cards": [
			{"code": "A", "meow": "Meo Kiểm Tra Xích 🔍", "icon": "🔍", "text": "Dựng chân chống giữa, quan sát độ võng sên & lốp", "step": 1},
			{"code": "B", "meow": "Meo Hỏi Giá Trước 💬", "icon": "💬", "text": "Hỏi rõ giá tiền tăng sên / sửa chữa trước khi làm", "step": 2},
			{"code": "C", "meow": "Meo Thăm Dầu Nhớt 🛢️", "icon": "🛢️", "text": "Rút que thăm nhớt kiểm tra màu sắc & mức nhớt", "step": 3},
			{"code": "D", "meow": "Meo Soi Tem Nhãn 🛡️", "icon": "🛡️", "text": "Kiểm tra tem chai nhớt chính hãng khi thợ châm", "step": 4}
		],
		"fail_msg": "Mèo không hỏi giá trước, bị tiệm ven đường 'vẽ bệnh' đòi 500k thay đủ thứ phụ tùng linh tinh!",
		"success_msg": "Mèo tăng xích và thay đúng nhớt chuẩn với giá sinh viên 90k! Xe chạy êm ru!",
		"loot_name": "Ốc xả nhớt bằng đồng",
		"loot_desc": "Biểu tượng của tay lái tháo vát, không bao giờ bị thợ vẽ vời.",
		"reward_fish": 30,
		"cheat_sheet": "BÍ KÍP XE MÁY: Tự soi sên/nhớt -> Luôn hỏi giá trước -> Xem tem nhớt chính hãng."
	},
	5: {
		"id": 5,
		"branch": 2,
		"branch_name": "Bình Yên Xóm Trọ (Pháp lý & Cư trú)",
		"title": "Thám Tử Soi Hợp Đồng Thuê Trọ",
		"context": "Chủ nhà đưa tờ giấy hợp đồng thuê phòng giục ký ngay kẻo có người khác thuê mất.",
		"guide": [
			"1. Đọc kỹ điều khoản tiền cọc: Quy định hoàn cọc khi hết hạn hoặc báo trước bao nhiêu ngày.",
			"2. Kiểm tra đơn giá điện nước: Có tính đúng giá nhà nước hay tính giá lũy tiến tự biên tự diễn.",
			"3. Ghi rõ hiện trạng phòng (vết nứt tường, vòi nước rỉ, máy lạnh) vào phụ lục trước khi nhận phòng.",
			"4. Hai bên cùng ký tên, giữ 01 bản gốc có chữ ký sống của chủ nhà."
		],
		"cards": [
			{"code": "A", "meow": "Meo Đọc Tiền Cọc 📑", "icon": "📑", "text": "Soi kỹ điều khoản trả tiền cọc & thời hạn báo trước", "step": 1},
			{"code": "B", "meow": "Meo Chốt Điện Nước ⚡", "icon": "⚡", "text": "Chốt số điện/nước và đơn giá cố định theo kWh/khối", "step": 2},
			{"code": "C", "meow": "Meo Chụp Hiện Trạng 📸", "icon": "📸", "text": "Chụp ảnh hiện trạng vết nứt/thiết bị cũ kèm phụ lục", "step": 3},
			{"code": "D", "meow": "Meo Giữ Bản Gốc ✍️", "icon": "✍️", "text": "Ký tên và cầm chắc 01 bản hợp đồng gốc về tay", "step": 4}
		],
		"fail_msg": "Mèo ký vội không đọc, sau 6 tháng dọn đi bị chủ trừ sạch tiền cọc vì 'làm cũ tường'!",
		"success_msg": "Mèo soi ra 2 điều khoản bẫy phụ phí! Chủ nhà phải nể phục ký hợp đồng minh bạch!",
		"loot_name": "Bút bi xanh ký hợp đồng trọ",
		"loot_desc": "Cây bút mang lại bình yên suốt 4 năm đại học, cọc về nguyên vẹn.",
		"reward_fish": 35,
		"cheat_sheet": "BÍ KÍP HỢP ĐỒNG TRỌ: Đọc bẫy tiền cọc -> Chốt giá điện nước -> Chụp ảnh hiện trạng -> Giữ 1 bản gốc."
	},
	6: {
		"id": 6,
		"branch": 2,
		"branch_name": "Bình Yên Xóm Trọ (Pháp lý & Cư trú)",
		"title": "Khảo Sát An Toàn PCCC Phòng Trọ",
		"context": "Thuê phòng trọ tầng 3, ban công có gắn lồng sắt bảo vệ (chuồng cọp).",
		"guide": [
			"1. Kiểm tra lồng sắt chuồng cọp có cửa thoát hiểm khẩn cấp và có chìa khóa sẵn không.",
			"2. Tìm vị trí bình chữa cháy bột/CO2 ở hành lang và kiểm tra đồng hồ áp suất vạch xanh.",
			"3. Khảo sát lối thoát hiểm phụ lên sân thượng hoặc lối sang nhà kế bên khi cầu thang chính tắc khói.",
			"4. Chuẩn bị sẵn một chiếc búa thoát hiểm và khăn bông trong phòng ngủ."
		],
		"cards": [
			{"code": "A", "meow": "Meo Cửa Thoát Hiểm 🚪", "icon": "🚪", "text": "Kiểm tra chuồng cọp có mở được cửa thoát hiểm không", "step": 1},
			{"code": "B", "meow": "Meo Bình Chữa Cháy 🧯", "icon": "🧯", "text": "Soi kim đồng hồ bình chữa cháy hành lang ở vạch xanh", "step": 2},
			{"code": "C", "meow": "Meo Lối Sân Thượng 🪜", "icon": "🪜", "text": "Định vị lối thoát phụ lên sân thượng thông gió", "step": 3},
			{"code": "D", "meow": "Meo Khăn Phòng Thân 🧣", "icon": "🧣", "text": "Trang bị sẵn khăn mặt & đèn pin cạnh đầu giường", "step": 4}
		],
		"fail_msg": "Mèo thuê phòng kín bưng không có lối thoát, chuồng cọp bị hàn chết khóa gỉ sét!",
		"success_msg": "Mèo khảo sát PCCC chuẩn chỉnh! Yêu cầu chủ nhà gắn ổ khóa chuồng cọp thành công!",
		"loot_name": "Móc chìa khóa dạ quang thoát hiểm",
		"loot_desc": "Phát sáng trong bóng đêm, mở cửa ban công trong 3 giây.",
		"reward_fish": 30,
		"cheat_sheet": "BÍ KÍP PCCC: Cửa chuồng cọp mở được -> Bình cứu hỏa vạch xanh -> Lối thoát thượng -> Khăn mặt sẵn."
	},
	7: {
		"id": 7,
		"branch": 2,
		"branch_name": "Bình Yên Xóm Trọ (Pháp lý & Cư trú)",
		"title": "Đăng Ký Tạm Trú Dân Sinh Trực Tuyến",
		"context": "Chủ trọ lười không chịu đi làm tạm trú cho sinh viên, công an khu vực sắp đi kiểm tra.",
		"guide": [
			"1. Xin chủ trọ số căn cước công dân và thông tin chủ sở hữu căn nhà trọ.",
			"2. Đăng nhập Cổng Dịch vụ công Quốc gia bằng tài khoản định danh VNeID mức 2.",
			"3. Điền tờ khai đăng ký tạm trú CT01 trực tuyến và tải lên ảnh chụp Hợp đồng thuê nhà.",
			"4. Theo dõi mã hồ sơ trực tuyến đến khi nhận thông báo 'Đã phê duyệt' từ Công an Phường."
		],
		"cards": [
			{"code": "A", "meow": "Meo-info?", "icon": "🪪", "text": "Thu thập thông tin CCCD chủ trọ & địa chỉ thửa đất", "step": 1},
			{"code": "B", "meow": "Meo-app!", "icon": "📲", "text": "Mở cổng DVC Quốc gia / VNeID đăng nhập mức 2", "step": 2},
			{"code": "C", "meow": "Meo-upload!", "icon": "📤", "text": "Khai mẫu CT01 & đính kèm ảnh hợp đồng thuê nhà", "step": 3},
			{"code": "D", "meow": "Meow-done!", "icon": "✅", "text": "Nhận kết quả tạm trú hợp pháp, không lo bị phạt hành chính", "step": 4}
		],
		"fail_msg": "Mèo ở chui không khai báo tạm trú, bị lập biên bản phạt hành chính 500k!",
		"success_msg": "Mèo nhận giấy xác nhận tạm trú trực tuyến chỉ sau 2 ngày! Đàng hoàng tự tin sống giữa phố!",
		"loot_name": "Thông báo xác nhận tạm trú CT07",
		"loot_desc": "Tờ giấy bảo chứng cư trú hợp pháp, tha hồ thi bằng lái và làm giấy tờ.",
		"reward_fish": 30,
		"cheat_sheet": "BÍ KÍP TẠM TRÚ: Lấy CCCD chủ trọ -> Đăng nhập VNeID/DVC -> Đính kèm hợp đồng trọ -> Lưu mã hồ sơ."
	},
	8: {
		"id": 8,
		"branch": 2,
		"branch_name": "Bình Yên Xóm Trọ (Pháp lý & Cư trú)",
		"title": "Thiết Lập Hiệp Ước Bạn Cùng Phòng",
		"context": "Ở ghép 3 người, sau tuần đầu chén bát chất đống, tiền điện cãi nhau chí chóe.",
		"guide": [
			"1. Ngồi lại họp phòng trọ khi tất cả đều vui vẻ, không nói chuyện lúc đang tức giận.",
			"2. Lập lịch phân công dọn vệ sinh toilet, đổ rác và lau nhà luân phiên theo tuần.",
			"3. Lập quỹ chung cố định (gia vị, nước mắm, giấy vệ sinh) và app ghi nợ nhóm như MoneyLover/Splitwise.",
			"4. Quy định rõ giờ giới nghiêm tắt đèn và nguyên tắc xin phép trước khi dẫn người ngoài về ngủ lại."
		],
		"cards": [
			{"code": "A", "meow": "Meo-talk!", "icon": "🍵", "text": "Họp mặt trà sữa thảo luận nhẹ nhàng, không công kích", "step": 1},
			{"code": "B", "meow": "Meo-clean!", "icon": "🧹", "text": "Dán lịch trực nhật dọn toilet & đổ rác luân phiên lên tủ lạnh", "step": 2},
			{"code": "C", "meow": "Meo-split!", "icon": "📊", "text": "Lập nhóm chia tiền quỹ dùng chung minh bạch qua app", "step": 3},
			{"code": "D", "meow": "Meow-rule!", "icon": "🌙", "text": "Quy ước giờ tắt đèn yên tĩnh và dẫn bạn bè đến phòng", "step": 4}
		],
		"fail_msg": "Mèo im lặng chịu đựng ấm ức, cuối cùng cãi nhau to rồi bạn cùng phòng đùng đùng dọn đi bỏ lại tiền phòng!",
		"success_msg": "Căn phòng trọ hòa thuận ấm áp nhất xóm! Đồ ăn chung luôn đầy tủ, phòng ốc thơm tho!",
		"loot_name": "Bảng nội quy phòng vẽ tay hài hước",
		"loot_desc": "Bản cam kết tình đồng chí không đụng vào đồ của nhau trừ khi được mời.",
		"reward_fish": 30,
		"cheat_sheet": "BÍ KÍP Ở GHÉP: Họp mặt thẳng thắn -> Lịch dọn luân phiên -> App chia tiền minh bạch -> Giới nghiêm tắt đèn."
	},
	9: {
		"id": 9,
		"branch": 3,
		"branch_name": "Thân Thể Kim Cương (Y tế & Sức khỏe)",
		"title": "Hạ Sốt 39 Độ Giữa Đêm Vắng",
		"context": "2 giờ sáng dầm mưa về, Mèo trùm chăn run cầm cập, trán nóng ran như hòn than.",
		"guide": [
			"1. Kẹp nhiệt kế nách 5 phút để xác định nhiệt độ chính xác (không đoán mò bằng tay).",
			"2. Nếu trên 38.5 độ, uống Paracetamol đúng liều 10-15mg/kg cân nặng (cách nhau ít nhất 4-6 tiếng).",
			"3. Nhúng khăn vào nước ẤM (không dùng nước đá/cồn), lau mát các vị trí mạch lớn: nách, bẹn, trán.",
			"4. Uống từng ngụm nhỏ Oresol bù nước và điện giải, mặc quần áo mỏng thoáng khí."
		],
		"cards": [
			{"code": "A", "meow": "Meo-temp?", "icon": "🌡️", "text": "Kẹp nhiệt kế nách 5 phút đo nhiệt độ thực tế", "step": 1},
			{"code": "B", "meow": "Meo-pill!", "icon": "💊", "text": "Uống Paracetamol đúng liều theo cân nặng (10-15mg/kg)", "step": 2},
			{"code": "C", "meow": "Meo-wipe!", "icon": "💧", "text": "Lau mát bằng nước ẤM tại vùng nách và hai bên bẹn", "step": 3},
			{"code": "D", "meow": "Meow-water!", "icon": "🥤", "text": "Pha Oresol uống từng ngụm bù nước, mặc đồ thoáng khí", "step": 4}
		],
		"fail_msg": "Mèo lấy đá lạnh chườm trán và trùm chăn bông kín mít khiến nhiệt độ tăng vọt co giật nguy hiểm!",
		"success_msg": "Sau 45 phút, Mèo hạ sốt xuống 37.2 độ an toàn, ngủ một giấc thật sâu hồi phục sinh lực!",
		"loot_name": "Nhiệt kế điện tử đầu mềm",
		"loot_desc": "Thiết bị cứu mạng trong đêm lạnh, đo nhiệt độ chính xác từng 0.1 độ C.",
		"reward_fish": 35,
		"cheat_sheet": "BÍ KÍP HẠ SỐT: Kẹp nhiệt kế -> Paracetamol đúng liều -> Lau nước ẤM nách bẹn -> Bù Oresol."
	},
	10: {
		"id": 10,
		"branch": 3,
		"branch_name": "Thân Thể Kim Cương (Y tế & Sức khỏe)",
		"title": "6 Bước Đi Khám BHYT Không Bị Mắng",
		"context": "Sáng hôm sau Mèo đến Bệnh viện Đa khoa Quận khám BHYT một mình, sợ bị quát nạt.",
		"guide": [
			"1. Đến sớm lúc 7h sáng, lại máy bốc số thứ tự khu vực 'Khám Bảo Hiểm Y Tế'.",
			"2. Đưa CCCD gắn chip (đã tích hợp BHYT) hoặc thẻ BHYT giấy tại quầy Tiếp nhận nhận sổ.",
			"3. Ngồi chờ trước cửa phòng khám ghi trên phiếu, chờ màn hình gọi đúng số thứ tự.",
			"4. Bác sĩ khám, làm xét nghiệm (nếu có), quay lại quầy Thu ngân BHYT đóng phần chênh lệch.",
			"5. Sang quầy Dược bệnh viện nộp sổ nhận thuốc theo toa miễn phí/đúng tuyến."
		],
		"cards": [
			{"code": "A", "meow": "Meo-num!", "icon": "🎟️", "text": "Bốc số thứ tự tại khu vực Khám BHYT lúc sáng sớm", "step": 1},
			{"code": "B", "meow": "Meo-card!", "icon": "🪪", "text": "Xuất trình CCCD gắn chip / VssID tại quầy Tiếp nhận", "step": 2},
			{"code": "C", "meow": "Meo-doc!", "icon": "🩺", "text": "Ngồi chờ trước đúng phòng khám, vào gặp bác sĩ", "step": 3},
			{"code": "D", "meow": "Meow-pharm!", "icon": "💊", "text": "Ký xác nhận tại quầy thu ngân & nhận thuốc tại kho Dược", "step": 4}
		],
		"fail_msg": "Mèo đi nhầm sang khu khám dịch vụ quốc tế VIP, khám xong cầm hóa đơn 1 triệu rưỡi khóc thét!",
		"success_msg": "Mèo hoàn tất 6 bước đúng tuyến chỉ tốn 0 đồng tiền thuốc! Bác sĩ còn khen Mèo ngoan!",
		"loot_name": "Vỉ kẹo ngậm C bệnh viện",
		"loot_desc": "Chiến lợi phẩm sau khi khám đúng tuyến BHYT thành công, không tốn một xu oan uổng.",
		"reward_fish": 35,
		"cheat_sheet": "BÍ KÍP BHYT: Bốc số BHYT -> Quầy tiếp nhận CCCD -> Phòng khám chuyên khoa -> Quầy Dược nhận thuốc."
	},
	11: {
		"id": 11,
		"branch": 3,
		"branch_name": "Thân Thể Kim Cương (Y tế & Sức khỏe)",
		"title": "Xây Dựng Túi Sơ Cứu Phòng Trọ",
		"context": "Chuẩn bị một hộp y tế cá nhân để không phải chạy mua thuốc lúc nửa đêm mưa bão.",
		"guide": [
			"1. Nhóm hạ sốt - giảm đau: Paracetamol 500mg, nhiệt kế y tế.",
			"2. Nhóm tiêu hóa: Men vi sinh, Berberin trị tiêu chảy, gói bù nước Oresol.",
			"3. Nhóm sát trùng & thương tích: Cồn đỏ Povidine, nước muối sinh lý NaCl 0.9%, băng cá nhân.",
			"4. Dán nhãn hạn sử dụng và liều lượng lên nắp từng hộp thuốc, kiểm tra 6 tháng/lần."
		],
		"cards": [
			{"code": "A", "meow": "Meo-fever!", "icon": "🩹", "text": "Xếp nhóm thuốc hạ sốt Paracetamol & nhiệt kế vào ngăn 1", "step": 1},
			{"code": "B", "meow": "Meo-stomach!", "icon": "🧪", "text": "Bổ sung Berberin, men tiêu hóa & Oresol vào ngăn 2", "step": 2},
			{"code": "C", "meow": "Meo-wound!", "icon": "🩸", "text": "Chuẩn bị Povidine sát trùng, gạc vô trùng & băng dán", "step": 3},
			{"code": "D", "meow": "Meow-label!", "icon": "🏷️", "text": "Viết rõ liều dùng & hạn sử dụng lên nắp hộp y tế", "step": 4}
		],
		"fail_msg": "Mèo uống bừa viên thuốc không nhãn mác trong góc tủ, bị dị ứng mẩn ngứa khắp người!",
		"success_msg": "Túi y tế sinh tồn hoàn thành! Cả phòng trọ an tâm sống khỏe không sợ ốm đau bất ngờ!",
		"loot_name": "Hộp cứu thương mini bằng thiếc",
		"loot_desc": "Bảo bối phòng thân chứa đầy đủ các loại dược phẩm sinh tồn thiết yếu.",
		"reward_fish": 25,
		"cheat_sheet": "BÍ KÍP TỦ THUỐC: Hạ sốt + Nhiệt kế -> Tiêu hóa + Oresol -> Sát trùng + Băng gạc -> Dán nhãn liều."
	},
	12: {
		"id": 12,
		"branch": 3,
		"branch_name": "Thân Thể Kim Cương (Y tế & Sức khỏe)",
		"title": "Cứu Cái Dạ Dày Sinh Viên",
		"context": "Thói quen ăn mì tôm sống bóp vụn và cày deadline thâu đêm làm Mèo đau quặn bụng trên.",
		"guide": [
			"1. Nhận diện cơn đau: Đau âm ỉ vùng thượng vị (trên rốn), ợ chua, cồn cào lúc đói hoặc sau ăn.",
			"2. Cai ngay mì tôm sống, nước ngọt có ga và cà phê đậm đặc khi bụng đang rỗng.",
			"3. Ăn uống đúng giờ: Ưu tiên cháo ấm, cơm dẻo, chuối chín và uống một cốc nước ấm khi ngủ dậy.",
			"4. Nếu đau quặn dữ dội hoặc nôn ra dịch sẫm màu, phải đến bệnh viện nội soi ngay, không tự mua thuốc ức chế acid."
		],
		"cards": [
			{"code": "A", "meow": "Meo-pain?", "icon": "😣", "text": "Xác định vị trí đau vùng thượng vị & triệu chứng ợ chua", "step": 1},
			{"code": "B", "meow": "Meo-stop!", "icon": "🍜", "text": "Dừng ngay ăn mì tôm sống & uống nước ngọt lúc bụng đói", "step": 2},
			{"code": "C", "meow": "Meo-porridge!", "icon": "🥣", "text": "Ăn cháo ấm, uống nước ấm buổi sáng để bảo vệ niêm mạc", "step": 3},
			{"code": "D", "meow": "Meow-clinic!", "icon": "🏥", "text": "Khám chuyên khoa tiêu hóa nếu triệu chứng kéo dài quá 3 ngày", "step": 4}
		],
		"fail_msg": "Mèo tiếp tục cày xuyên đêm ăn gói mì tôm tẩm ớt thứ 3, cơn đau dạ dày cấp làm Mèo ngất xỉu!",
		"success_msg": "Mèo hồi phục đường tiêu hóa khỏe mạnh! Bụng êm ru, học bài thi đạt điểm cao!",
		"loot_name": "Bình giữ nhiệt giữ nước ấm 24h",
		"loot_desc": "Người bạn đồng hành bảo vệ dạ dày khỏi những cơn cồn cào mùa thi.",
		"reward_fish": 30,
		"cheat_sheet": "BÍ KÍP DẠ DÀY: Nhận biết đau thượng vị -> Bỏ mì tôm sống -> Cháo ấm đúng giờ -> Đi khám nếu đau kéo dài."
	},
	13: {
		"id": 13,
		"branch": 4,
		"branch_name": "Túi Tiền Thông Thái (Tài chính & Việc làm)",
		"title": "Phương Pháp Phân Bổ 3 Hũ Cá",
		"context": "Đầu tháng mẹ gửi 3 triệu (90 Cá Khô), ngày 10 đã thấy ví xẹp lép vì trà sữa và mua sắm.",
		"guide": [
			"1. Hũ 1 (Sống còn - 50% = 45 Cá): Tiền nhà trọ, tiền ăn hạt cơ bản, tiền xe buýt bắt buộc.",
			"2. Hũ 2 (Phát triển - 30% = 27 Cá): Sách vở, học phí chứng chỉ, giao lưu bạn bè bổ ích.",
			"3. Hũ 3 (Khẩn cấp - 20% = 18 Cá): Tuyệt đối không đụng vào, cất riêng để phòng khi ốm đau/hỏng xe.",
			"4. Rút tiền mặt hoặc chia thành 3 tài khoản ngân hàng riêng biệt ngay khi nhận tiền."
		],
		"cards": [
			{"code": "A", "meow": "Meo-split!", "icon": "🪙", "text": "Nhận trợ cấp lập tức chia ra 3 phần, không để chung một ví", "step": 1},
			{"code": "B", "meow": "Meo-survive!", "icon": "🏠", "text": "Khóa cứng 50% tiền ăn cơ bản và tiền trọ vào Hũ 1", "step": 2},
			{"code": "C", "meow": "Meo-study!", "icon": "📚", "text": "Phân bổ 30% cho tài liệu học tập & phát triển vào Hũ 2", "step": 3},
			{"code": "D", "meow": "Meow-lock!", "icon": "🔒", "text": "Gửi tiết kiệm 20% Hũ khẩn cấp phòng khi xe hư ốm đau", "step": 4}
		],
		"fail_msg": "Mèo để chung tiền trong một tài khoản, quẹt thẻ mua giày hiệu xong cuối tháng ăn mì gói cầm hơi!",
		"success_msg": "Mèo làm chủ dòng tiền xuất sắc! Cả tháng ăn no mà ví khẩn cấp vẫn nguyên vẹn 18 Cá!",
		"loot_name": "3 Hũ thủy tinh đựng cá khô",
		"loot_desc": "Bí kíp tài chính giúp sinh viên không bao giờ rơi vào cảnh rỗng túi cuối tháng.",
		"reward_fish": 35,
		"cheat_sheet": "BÍ KÍP 3 HŨ: Chia ngay ngày 1 -> 50% Sống còn -> 30% Phát triển -> 20% Khẩn cấp bất khả xâm phạm."
	},
	14: {
		"id": 14,
		"branch": 4,
		"branch_name": "Túi Tiền Thông Thái (Tài chính & Việc làm)",
		"title": "Bộ Lọc Bóc Trần Đa Cấp Ponzi",
		"context": "Người bạn cũ rủ Mèo dự hội thảo 'Khởi nghiệp 4.0', hứa hẹn lãi suất 1.5%/ngày không cần làm gì.",
		"guide": [
			"1. Nguyên tắc vàng: Lãi suất trên 15%/năm chắc chắn là bẫy tài chính hoặc mô hình lừa đảo.",
			"2. Kiểm tra dòng tiền: Doanh thu đến từ việc bán sản phẩm thật hay chủ yếu từ việc tuyển người mới nộp tiền vào.",
			"3. Không mang theo CCCD, thẻ ngân hàng hoặc tiền mặt khi đến các buổi hội thảo truyền lửa.",
			"4. Giữ vững lập trường từ chối: 'Em cần hỏi ý kiến gia đình' và rời khỏi phòng ngay lập tức."
		],
		"cards": [
			{"code": "A", "meow": "Meo-math?", "icon": "📉", "text": "Soi lãi suất: Hứa hẹn 1.5%/ngày (500%/năm) là bẫy lừa đảo", "step": 1},
			{"code": "B", "meow": "Meo-product?", "icon": "📦", "text": "Kiểm tra sản phẩm: Nếu chỉ chăm chăm tuyển người mới -> Đa cấp Ponzi", "step": 2},
			{"code": "C", "meow": "Meo-pocket!", "icon": "🚫", "text": "Tuyệt đối không ký cọc, không nộp tiền, cất chặt CCCD", "step": 3},
			{"code": "D", "meow": "Meow-escape!", "icon": "🏃", "text": "Dứt khoát từ chối và rời khỏi hội thảo đa cấp ngay lập tức", "step": 4}
		],
		"fail_msg": "Mèo bị thao túng tâm lý nộp sạch 90 Cá Khô tiền ăn để mua gói hội viên kim cương ảo!",
		"success_msg": "Mèo bóc trần sàn đa cấp trước mặt cả hội trường và thoát hiểm an toàn! Bảo toàn 100% tài sản!",
		"loot_name": "Kính lúp soi sàn ảo Ponzi",
		"loot_desc": "Soi thấu mọi lời đường mật làm giàu nhanh trên mạng xã hội.",
		"reward_fish": 35,
		"cheat_sheet": "BÍ KÍP LỌC PONZI: Lãi > 15%/năm là lừa -> Không có sản phẩm thật -> Cấm nộp cọc -> Rút lui dứt khoát."
	},
	15: {
		"id": 15,
		"branch": 4,
		"branch_name": "Túi Tiền Thông Thái (Tài chính & Việc làm)",
		"title": "Phỏng Vấn Việc Làm Part-Time Chuẩn",
		"context": "Mèo muốn làm phụ việc quán cà phê kiếm thêm tiền, gặp quản lý quán phỏng vấn.",
		"guide": [
			"1. Soạn CV ngắn gọn, trung thực về lịch học để tránh bị trùng ca học và thi cử.",
			"2. Hỏi rõ mức lương theo giờ (Gross hay Net), thời gian trả lương và chế độ phụ cấp ca gãy.",
			"3. Tuyệt đối TỪ CHỐI bất kỳ nơi nào bắt đóng 'tiền cọc giữ chỗ', 'tiền đồng phục', hoặc giữ bản gốc CCCD.",
			"4. Thử việc phải có biên nhận hoặc tin nhắn xác nhận thỏa thuận lương rõ ràng."
		],
		"cards": [
			{"code": "A", "meow": "Meo-cv!", "icon": "📄", "text": "Trình CV trung thực, chốt lịch làm không trùng giờ học", "step": 1},
			{"code": "B", "meow": "Meo-wage?", "icon": "💵", "text": "Hỏi rõ lương theo giờ (ví dụ 25k/h) & ngày thanh toán hàng tháng", "step": 2},
			{"code": "C", "meow": "Meo-id!", "icon": "🛡️", "text": "Từ chối đóng tiền cọc đồng phục & không giao bản gốc CCCD", "step": 3},
			{"code": "D", "meow": "Meow-agree!", "icon": "🤝", "text": "Yêu cầu hợp đồng hoặc thỏa thuận văn bản trước khi vào ca", "step": 4}
		],
		"fail_msg": "Mèo nộp bản gốc CCCD và cọc 300k tiền tạp dề, hôm sau đến thì quán đóng cửa mất hút!",
		"success_msg": "Mèo nhận việc phụ quán uy tín với mức lương 25k/h sòng phẳng! Cuối tuần có thêm tiền mua pate!",
		"loot_name": "Thẻ nhân viên pha chế xịn sò",
		"loot_desc": "Huy hiệu làm thêm chân chính đầu đời, tự lập tài chính đàng hoàng.",
		"reward_fish": 30,
		"cheat_sheet": "BÍ KÍP PART-TIME: Lịch theo giờ học -> Lương rõ ràng -> Cấm giao CCCD gốc & tiền cọc -> Ký thỏa thuận."
	},
	16: {
		"id": 16,
		"branch": 4,
		"branch_name": "Túi Tiền Thông Thái (Tài chính & Việc làm)",
		"title": "Thoát Bẫy Ví Trả Sau & Thấu Chi",
		"context": "App mua sắm mời chào kích hoạt hạn mức 3 triệu 'Mua trước trả sau 0% lãi suất', thấy áo đẹp muốn quẹt ngay.",
		"guide": [
			"1. Kích hoạt quy tắc 'Phanh Tiêu Dùng 48 Giờ': Chờ 2 ngày trước khi quyết định mua món đồ không thiết yếu.",
			"2. Đọc biểu phí phạt chậm trả: Nếu trễ 1 ngày sẽ bị phạt từ 50k đến 150k cộng lãi suất cắt cổ.",
			"3. Tự hỏi: 'Nếu không có ví trả sau, mình có đủ tiền mặt mua món này không?' Nếu không -> Bỏ giỏ hàng.",
			"4. Tắt tính năng tự động gia hạn hoặc hủy liên kết ví trả sau nếu không thực sự cần thiết."
		],
		"cards": [
			{"code": "A", "meow": "Meo-wait!", "icon": "⏳", "text": "Kích hoạt 'Phanh 48h': Để món đồ trong giỏ hàng chờ 2 ngày suy nghĩ", "step": 1},
			{"code": "B", "meow": "Meo-fine?", "icon": "🔍", "text": "Soi kỹ phí trễ hạn & lãi suất phạt ngầm ẩn sau chữ 0%", "step": 2},
			{"code": "C", "meow": "Meo-cash?", "icon": "🤔", "text": "Chỉ mua khi có đủ tiền mặt thanh toán ngay lập tức", "step": 3},
			{"code": "D", "meow": "Meow-lock!", "icon": "🔒", "text": "Khóa hạn mức ví trả sau, không tiêu xài trước tương lai", "step": 4}
		],
		"fail_msg": "Mèo bấm quẹt trả sau mua sắm vô tội vạ, tháng sau tiền lãi phạt nhảy lên 35 Cá Khô ngập đầu!",
		"success_msg": "Mèo kiềm chế thành công cơn nghiện mua sắm! Tiết kiệm được một khoản tiền lớn để đầu tư học tập!",
		"loot_name": "Chiếc kéo vàng cắt thẻ nợ",
		"loot_desc": "Biểu tượng của sự tự do tài chính, không làm nô lệ cho thấu chi.",
		"reward_fish": 35,
		"cheat_sheet": "BÍ KÍP THOÁT VÍ TRẢ SAU: Phanh 48h -> Đọc phí phạt chậm trả -> Không tiền mặt thì không mua -> Tắt ví."
	}
}

func _ready() -> void:
	_setup_font_fallback()
	load_json_data()
	load_game()
	load_room_state()
	if last_active_unix <= 0:
		last_active_unix = int(Time.get_unix_time_from_system())
	
	# Đảm bảo có vật phẩm khởi đầu cho Boss để thay đồ & bài trí phòng
	var starter_costumes = ["c_hoodie_student", "c_hat_cap"]
	for sc in starter_costumes:
		if not (sc in inventory_costumes):
			inventory_costumes.append(sc)
			
	var starter_decor = ["d_bed_box", "d_bowl_basic"]
	for sd in starter_decor:
		if not (sd in inventory_decor):
			inventory_decor.append(sd)
			
	if equipped_costumes.get("clothes", "") == "":
		equipped_costumes["clothes"] = "c_hoodie_student"
		equipped_costume = "c_hoodie_student"
	if equipped_costumes.get("hats", "") == "":
		equipped_costumes["hats"] = "c_hat_cap"
		
	if not equipped_decor.has("beds") or equipped_decor["beds"] == "":
		equipped_decor["beds"] = "d_bed_box"
	if not equipped_decor.has("bowls") or equipped_decor["bowls"] == "":
		equipped_decor["bowls"] = "d_bowl_basic"
	if not equipped_decor.has("rugs"):
		equipped_decor["rugs"] = ""
	if not equipped_decor.has("plants"):
		equipped_decor["plants"] = ""
	if not equipped_decor.has("wall"):
		equipped_decor["wall"] = ""

func _setup_font_fallback() -> void:
	var font_path = "res://assets/font/SVN-Retron 2000.ttf"
	if ResourceLoader.exists(font_path):
		var font = load(font_path)
		if font and font is FontFile:
			var sys_font = SystemFont.new()
			sys_font.font_names = PackedStringArray(["Segoe UI Emoji", "Noto Color Emoji", "Apple Color Emoji", "sans-serif"])
			font.fallbacks = [sys_font]

func load_json_data() -> void:
	# 1. Life Skills (Ưu tiên nạp từ lifeskill.json / life_skills.json)
	var life_skills_path = ""
	if FileAccess.file_exists("res://assets/data/life_skills.json"):
		life_skills_path = "res://assets/data/life_skills.json"
	elif FileAccess.file_exists("res://assets/data/lifeskill.json"):
		life_skills_path = "res://assets/data/lifeskill.json"
	elif FileAccess.file_exists("res://data/life_skills.json"):
		life_skills_path = "res://data/life_skills.json"
	elif FileAccess.file_exists("res://data/lifeskill.json"):
		life_skills_path = "res://data/lifeskill.json"
		
	if life_skills_path != "":
		var f_life = FileAccess.open(life_skills_path, FileAccess.READ)
		var parsed = JSON.parse_string(f_life.get_as_text())
		if parsed is Dictionary and parsed.has("skill_groups"):
			skills_json_data = parsed
			_hydrate_lessons_from_life_skills(parsed)
			print("Loaded life skills from ", life_skills_path, " -> ", lessons_data.size(), " lessons active.")
	elif FileAccess.file_exists("res://data/skills.json"):
		var f = FileAccess.open("res://data/skills.json", FileAccess.READ)
		skills_json_data = JSON.parse_string(f.get_as_text())
		
	# 2. Cards
	if FileAccess.file_exists("res://data/cards.json"):
		var f = FileAccess.open("res://data/cards.json", FileAccess.READ)
		cards_json_data = JSON.parse_string(f.get_as_text())
		
	# 3. Loot Tables
	if FileAccess.file_exists("res://data/loot_tables.json"):
		var f = FileAccess.open("res://data/loot_tables.json", FileAccess.READ)
		loot_tables_data = JSON.parse_string(f.get_as_text())
		
	# 4. Peer System
	if FileAccess.file_exists("res://data/peer_system.json"):
		var f = FileAccess.open("res://data/peer_system.json", FileAccess.READ)
		peer_system_data = JSON.parse_string(f.get_as_text())
		
	# 5. Shop Catalog
	var shop_path = "res://assets/data/shop_catalog.json"
	if FileAccess.file_exists(shop_path):
		var f = FileAccess.open(shop_path, FileAccess.READ)
		var parsed = JSON.parse_string(f.get_as_text())
		if parsed is Dictionary and parsed.has("items"):
			shop_catalog_data = parsed
			print("Loaded shop catalog -> ", shop_catalog_data["items"].size(), " items.")

	# 6. Mini Games Data (5 dạng gameplay tương tác sinh viên)
	var mini_path = "res://assets/data/minigames_data.json"
	if FileAccess.file_exists(mini_path):
		var f_mini = FileAccess.open(mini_path, FileAccess.READ)
		var parsed_mini = JSON.parse_string(f_mini.get_as_text())
		if parsed_mini is Dictionary and parsed_mini.has("minigames"):
			minigames_data = parsed_mini["minigames"]
			print("Loaded minigames data -> ", minigames_data.size(), " interactive mini-games active.")

	# 7. Story Lessons Data (Interactive Storytelling Adventure)
	var story_path = "res://assets/data/story_lessons.json"
	if FileAccess.file_exists(story_path):
		var f_story = FileAccess.open(story_path, FileAccess.READ)
		var parsed_story = JSON.parse_string(f_story.get_as_text())
		if parsed_story is Dictionary and parsed_story.has("stories"):
			for st in parsed_story["stories"]:
				story_lessons_data[st.get("story_id", "")] = st
			print("Loaded story lessons data -> ", story_lessons_data.size(), " interactive stories active.")

	# 8. Cozy Dialog System Data (UI-03)
	var cozy_path = "res://data/cozy_dialogs.json"
	if FileAccess.file_exists(cozy_path):
		var f_cozy = FileAccess.open(cozy_path, FileAccess.READ)
		var parsed_cozy = JSON.parse_string(f_cozy.get_as_text())
		if parsed_cozy is Dictionary and parsed_cozy.has("dialogs"):
			cozy_dialogs.clear()
			for entry in parsed_cozy["dialogs"]:
				if entry is Dictionary and entry.has("dialog_id"):
					cozy_dialogs[str(entry["dialog_id"])] = entry
			print("Loaded cozy dialogs -> ", cozy_dialogs.size(), " entries active.")

func get_cozy_dialog(dialog_id: String) -> Dictionary:
	return cozy_dialogs.get(dialog_id, {})

const LESSON_IMAGE_DATA = {
	1: [
		{"title": "Xếp đồ đúng ngăn Vali", "clue": "Phân loại 4 ngăn vali", "asset": "res://assets/sprites/skills/lesson_01_step_1.png", "icon": "📦"},
		{"title": "Dán nhãn công dụng thuốc", "clue": "Hộp thuốc sơ cứu", "asset": "res://assets/sprites/skills/lesson_01_step_2.png", "icon": "🏷️"},
		{"title": "Điền khuyết lời mẹ dặn", "clue": "Ghi nhớ cách dùng & lưu ý", "asset": "res://assets/sprites/skills/lesson_01_step_3.png", "icon": "📜"},
		{"title": "Khóa vali tự tin lên đường", "clue": "Hành trang sẵn sàng 100%", "asset": "res://assets/sprites/skills/lesson_01_step_4.png", "icon": "🎒"},
	],
	2: [
		{"title": "Khám triệu chứng bạn cùng phòng", "clue": "Đánh giá tình trạng", "asset": "res://assets/sprites/skills/lesson_02_step_1.png", "icon": "🤕"},
		{"title": "Xác định chuyên khoa điều trị", "clue": "Chọn khoa phù hợp", "asset": "res://assets/sprites/skills/lesson_02_step_2.png", "icon": "🩺"},
		{"title": "Chọn đúng bệnh viện chuyên sâu", "clue": "Bệnh viện tuyến đầu", "asset": "res://assets/sprites/skills/lesson_02_step_3.png", "icon": "🏥"},
		{"title": "Cấp cứu kịp thời đúng nơi", "clue": "Cứu chữa an toàn", "asset": "res://assets/sprites/skills/lesson_02_step_4.png", "icon": "🚑"},
	],
	3: [
		{"title": "Dùng dụng cụ đo chỉ số cơ thể", "clue": "Nhiệt kế điện tử 38.8 độ", "asset": "res://assets/sprites/skills/lesson_03_step_1.png", "icon": "🌡️"},
		{"title": "Lập bảng thống kê triệu chứng", "clue": "Bảng theo dõi chỉ số", "asset": "res://assets/sprites/skills/lesson_03_step_2.png", "icon": "📋"},
		{"title": "Chọn đúng thuốc đặc trị", "clue": "Uống đúng Paracetamol", "asset": "res://assets/sprites/skills/lesson_03_step_3.png", "icon": "💊"},
		{"title": "Hồi phục sức khỏe an toàn", "clue": "Hạ sốt thành công", "asset": "res://assets/sprites/skills/lesson_03_step_4.png", "icon": "✨"},
	],
	4: [
		{"title": "Dừng xe bật đèn báo", "clue": "Báo hiệu chết máy", "asset": "res://assets/sprites/skills/lesson_04_step_1.png", "icon": "🛑"},
		{"title": "Kiểm tra bugi & xăng", "clue": "Soi lỗi cơ bản", "asset": "res://assets/sprites/skills/lesson_04_step_2.png", "icon": "🔍"},
		{"title": "Gọi đội SOS sinh viên", "clue": "Tìm cứu trợ uy tín", "asset": "res://assets/sprites/skills/lesson_04_step_3.png", "icon": "📞"},
		{"title": "Giám sát sửa xe trực tiếp", "clue": "Tránh bị chặt chém", "asset": "res://assets/sprites/skills/lesson_04_step_4.png", "icon": "👀"},
	],
	5: [
		{"title": "Soi điều khoản cọc", "clue": "Đọc kỹ hợp đồng", "asset": "res://assets/sprites/skills/lesson_05_step_1.png", "icon": "📑"},
		{"title": "Chốt giá điện nước", "clue": "Ghi nhận công tơ", "asset": "res://assets/sprites/skills/lesson_05_step_2.png", "icon": "⚡"},
		{"title": "Chụp hiện trạng phòng", "clue": "Lưu bằng chứng bàn giao", "asset": "res://assets/sprites/skills/lesson_05_step_3.png", "icon": "📸"},
		{"title": "Ký giữ hợp đồng gốc", "clue": "Giữ căn cứ pháp lý", "asset": "res://assets/sprites/skills/lesson_05_step_4.png", "icon": "✍️"},
	],
	6: [
		{"title": "Kiểm tra chuồng cọp", "clue": "Khảo sát ban công", "asset": "res://assets/sprites/skills/lesson_06_step_1.png", "icon": "🚪"},
		{"title": "Soi kim bình cứu hỏa", "clue": "Kim ở vạch xanh", "asset": "res://assets/sprites/skills/lesson_06_step_2.png", "icon": "🧯"},
		{"title": "Định vị lối sân thượng", "clue": "Đường thoát hiểm thứ 2", "asset": "res://assets/sprites/skills/lesson_06_step_3.png", "icon": "🪜"},
		{"title": "Chuẩn bị khăn & đèn pin", "clue": "Vật phẩm sinh tồn", "asset": "res://assets/sprites/skills/lesson_06_step_4.png", "icon": "🔦"},
	],
	7: [
		{"title": "Lấy CCCD chủ trọ", "clue": "Thu thập hồ sơ", "asset": "res://assets/sprites/skills/lesson_07_step_1.png", "icon": "🪪"},
		{"title": "Đăng nhập VNeID mức 2", "clue": "Cổng DVC Quốc gia", "asset": "res://assets/sprites/skills/lesson_07_step_2.png", "icon": "📲"},
		{"title": "Tải ảnh hợp đồng trọ", "clue": "Tải chứng từ hợp lệ", "asset": "res://assets/sprites/skills/lesson_07_step_3.png", "icon": "📤"},
		{"title": "Lưu mã hồ sơ phê duyệt", "clue": "Theo dõi phê duyệt", "asset": "res://assets/sprites/skills/lesson_07_step_4.png", "icon": "✅"},
	],
	8: [
		{"title": "Họp phòng trà sữa", "clue": "Không khí cởi mở", "asset": "res://assets/sprites/skills/lesson_08_step_1.png", "icon": "🍵"},
		{"title": "Dán lịch trực nhật", "clue": "Trách nhiệm rõ ràng", "asset": "res://assets/sprites/skills/lesson_08_step_2.png", "icon": "🧹"},
		{"title": "Tạo app chia tiền quỹ", "clue": "Minh bạch tài chính", "asset": "res://assets/sprites/skills/lesson_08_step_3.png", "icon": "📊"},
		{"title": "Chốt giờ giới nghiêm", "clue": "Tôn trọng giấc ngủ", "asset": "res://assets/sprites/skills/lesson_08_step_4.png", "icon": "🌙"},
	],
	9: [
		{"title": "Kẹp nhiệt kế 38.5°C", "clue": "Đo đúng thân nhiệt", "asset": "res://assets/sprites/skills/lesson_09_step_1.png", "icon": "🌡️"},
		{"title": "Uống đúng liều Para", "clue": "10-15mg/kg cân nặng", "asset": "res://assets/sprites/skills/lesson_09_step_2.png", "icon": "💊"},
		{"title": "Lau khăn nước ấm", "clue": "Hạ nhiệt vật lý", "asset": "res://assets/sprites/skills/lesson_09_step_3.png", "icon": "💧"},
		{"title": "Uống từng ngụm Oresol", "clue": "Bù nước điện giải", "asset": "res://assets/sprites/skills/lesson_09_step_4.png", "icon": "🥤"},
	],
	10: [
		{"title": "Bốc số BHYT sớm", "clue": "Tránh chờ đợi lâu", "asset": "res://assets/sprites/skills/lesson_10_step_1.png", "icon": "🎟️"},
		{"title": "Xuất trình CCCD & BHYT", "clue": "Tiếp nhận hồ sơ", "asset": "res://assets/sprites/skills/lesson_10_step_2.png", "icon": "🪪"},
		{"title": "Vào gặp bác sĩ khám", "clue": "Khám và chẩn đoán", "asset": "res://assets/sprites/skills/lesson_10_step_3.png", "icon": "🩺"},
		{"title": "Lấy thuốc kho Dược BHYT", "clue": "Nhận thuốc chuẩn viện", "asset": "res://assets/sprites/skills/lesson_10_step_4.png", "icon": "💊"},
	],
	11: [
		{"title": "Xếp hạ sốt & nhiệt kế", "clue": "Xử lý cảm sốt", "asset": "res://assets/sprites/skills/lesson_11_step_1.png", "icon": "🩹"},
		{"title": "Bổ sung Berberin tiêu hóa", "clue": "Bảo vệ đường ruột", "asset": "res://assets/sprites/skills/lesson_11_step_2.png", "icon": "🧪"},
		{"title": "Chuẩn bị cồn đỏ & gạc", "clue": "Sát khuẩn vết thương", "asset": "res://assets/sprites/skills/lesson_11_step_3.png", "icon": "🩸"},
		{"title": "Dán nhãn hạn sử dụng", "clue": "Định kỳ kiểm tra", "asset": "res://assets/sprites/skills/lesson_11_step_4.png", "icon": "🏷️"},
	],
	12: [
		{"title": "Nói không với mì sống", "clue": "Bảo vệ dạ dày", "asset": "res://assets/sprites/skills/lesson_12_step_1.png", "icon": "🚫"},
		{"title": "Nấu sôi chần bỏ nước đầu", "clue": "Giảm dầu chiên", "asset": "res://assets/sprites/skills/lesson_12_step_2.png", "icon": "🍲"},
		{"title": "Thêm trứng & rau xanh", "clue": "Bổ sung dinh dưỡng", "asset": "res://assets/sprites/skills/lesson_12_step_3.png", "icon": "🥚"},
		{"title": "Ăn đúng giờ bảo vệ bao tử", "clue": "Nạp năng lượng học tập", "asset": "res://assets/sprites/skills/lesson_12_step_4.png", "icon": "🥗"},
	],
	13: [
		{"title": "Chia ngay 3 phần tiền", "clue": "Nhận tiền sinh hoạt", "asset": "res://assets/sprites/skills/lesson_13_step_1.png", "icon": "🪙"},
		{"title": "Khóa 50% tiền trọ & ăn", "clue": "Nhu cầu thiết yếu", "asset": "res://assets/sprites/skills/lesson_13_step_2.png", "icon": "🏠"},
		{"title": "Dành 30% học & phát triển", "clue": "Đầu tư bản thân", "asset": "res://assets/sprites/skills/lesson_13_step_3.png", "icon": "📚"},
		{"title": "Niêm phong 20% khẩn cấp", "clue": "Quỹ dự phòng an toàn", "asset": "res://assets/sprites/skills/lesson_13_step_4.png", "icon": "🔒"},
	],
	14: [
		{"title": "Soi lãi khủng phi lý", "clue": "Cảnh giác 300%", "asset": "res://assets/sprites/skills/lesson_14_step_1.png", "icon": "📉"},
		{"title": "Kiểm tra sản phẩm thật", "clue": "Hàng không rõ nguồn", "asset": "res://assets/sprites/skills/lesson_14_step_2.png", "icon": "📦"},
		{"title": "Cất chặt ví & CCCD", "clue": "Tuyệt đối không giao", "asset": "res://assets/sprites/skills/lesson_14_step_3.png", "icon": "🚫"},
		{"title": "Rời hội thảo dứt khoát", "clue": "Thoát bẫy tâm lý", "asset": "res://assets/sprites/skills/lesson_14_step_4.png", "icon": "🏃"},
	],
	15: [
		{"title": "Trình CV khớp lịch học", "clue": "Ưu tiên việc học", "asset": "res://assets/sprites/skills/lesson_15_step_1.png", "icon": "📄"},
		{"title": "Chốt lương giờ & ngày trả", "clue": "Rõ ràng minh bạch", "asset": "res://assets/sprites/skills/lesson_15_step_2.png", "icon": "💵"},
		{"title": "Từ chối nộp cọc & CCCD", "clue": "Bảo vệ quyền lợi", "asset": "res://assets/sprites/skills/lesson_15_step_3.png", "icon": "🛡️"},
		{"title": "Ký thỏa thuận trước ca", "clue": "Có căn cứ bảo vệ", "asset": "res://assets/sprites/skills/lesson_15_step_4.png", "icon": "🤝"},
	],
	16: [
		{"title": "Kích hoạt phanh 48 giờ", "clue": "Hạ nhiệt bốc đồng", "asset": "res://assets/sprites/skills/lesson_16_step_1.png", "icon": "⏳"},
		{"title": "Soi phí trễ hạn & phạt", "clue": "Tính lãi kép BNPL", "asset": "res://assets/sprites/skills/lesson_16_step_2.png", "icon": "🔍"},
		{"title": "Chỉ mua khi có tiền mặt", "clue": "Kỷ luật chi tiêu", "asset": "res://assets/sprites/skills/lesson_16_step_3.png", "icon": "🤔"},
		{"title": "Khóa hạn mức ví trả sau", "clue": "Cắt nguồn nợ nần", "asset": "res://assets/sprites/skills/lesson_16_step_4.png", "icon": "🔒"},
	]
}

func get_story_data(story_id: String) -> Dictionary:
	return story_lessons_data.get(story_id, {})

func get_story_by_lesson_id(lesson_id: int) -> Dictionary:
	for st in story_lessons_data.values():
		if st.get("lesson_id", -1) == lesson_id:
			return st
	if lessons_data.has(lesson_id):
		return generate_story_for_lesson(lesson_id)
	return {}

func generate_story_for_lesson(lesson_id: int) -> Dictionary:
	var lesson = lessons_data.get(lesson_id, {})
	if lesson.is_empty():
		return {}
		
	var title = lesson.get("title", "Kỹ năng sống")
	var context = lesson.get("context", "")
	var cards = lesson.get("cards", []).duplicate()
	cards.sort_custom(func(a, b): return a.get("step", 1) < b.get("step", 1))
	
	var img_info_list = LESSON_IMAGE_DATA.get(lesson_id, [])
	var steps_array: Array = []
	
	for i in range(cards.size()):
		var card = cards[i]
		var step_num: int = int(card.get("step", i + 1))
		var img_data = img_info_list[i] if i < img_info_list.size() else {}
		var img_path = img_data.get("asset", "res://assets/sprites/skills/lesson_%02d_step_%d.png" % [lesson_id, step_num])
		var step_title = img_data.get("title", card.get("text", "Chặng %d" % step_num))
		
		var blank_id = "blank_%d" % step_num
		var correct_card_id = "card_%d_%d" % [lesson_id, step_num]
		
		var text_template = ""
		match step_num:
			1:
				if context != "":
					text_template = "%s. Trước tiên, Mèo con cần phải {blank_%d}." % [context, step_num]
				else:
					text_template = "Để bắt đầu xử lý tình huống này, việc đầu tiên Mèo con cần làm là {blank_%d}." % step_num
			2:
				text_template = "Tiếp theo ở chặng 2, để kiểm soát tình hình đúng cách, Mèo con cần {blank_%d}." % step_num
			3:
				text_template = "Đến chặng 3 rất quan trọng, để đảm bảo an toàn tối đa, Mèo liền {blank_%d}." % step_num
			4:
				text_template = "Cuối cùng ở chặng 4, Mèo con nhanh nhẹn {blank_%d} để hoàn tất xử lý trọn vẹn tình huống." % step_num
			_:
				text_template = "Ở chặng %d, Mèo con cần thực hiện {blank_%d}." % [step_num, step_num]
				
		var step_cards: Array = []
		step_cards.append({
			"id": correct_card_id,
			"cat_sound": card.get("meow", "Meo meo!"),
			"label": card.get("text", ""),
			"icon": card.get("icon", "🐾"),
			"is_correct": true,
			"step": step_num
		})
		
		for j in range(cards.size()):
			if j != i:
				var other_c = cards[j]
				var other_step = other_c.get("step", j + 1)
				var fake_id = "card_%d_%d_dist_%d" % [lesson_id, other_step, step_num]
				var hint = "Chưa phải lúc làm việc này đâu Sen ơi! Hãy quan sát kỹ tình huống và chọn đúng bước nhé!"
				if other_step < step_num:
					hint = "Hành động này Mèo đã làm ở bước trước rồi nè! Giờ hãy chọn hành động tiếp theo nhé Sen!"
				elif other_step > step_num:
					hint = "Vội quá rồi Sen ơi! Chưa giải quyết bước này mà đã nhảy cóc sang bước sau là nguy hiểm lắm!"
				step_cards.append({
					"id": fake_id,
					"cat_sound": other_c.get("meow", "Meo meo!"),
					"label": other_c.get("text", ""),
					"icon": other_c.get("icon", "🐾"),
					"is_correct": false,
					"fail_hint": hint,
					"step": other_step
				})
				
		step_cards.shuffle()
		
		steps_array.append({
			"step_index": step_num,
			"step_title": "Chặng %d: %s" % [step_num, step_title],
			"illustration": img_path,
			"text_template": text_template,
			"blanks": [
				{
					"blank_id": blank_id,
					"placeholder": "..... [ Ô TRỐNG %d: Chọn hành động ] ....." % step_num,
					"correct_card_id": correct_card_id
				}
			],
			"cards": step_cards,
			"success_prompt": "Méo-tick! Tuyệt vời! Mèo con đã hoàn thành xong Chặng %d!" % step_num
		})
		
	return {
		"story_id": "story_lesson_%02d" % lesson_id,
		"lesson_id": lesson_id,
		"title": title,
		"context": context,
		"achievement": lesson.get("loot_name", "Kỹ năng %s" % title),
		"reward_fish": lesson.get("reward_fish", 30),
		"reward_exp": 40,
		"handbook_tip": lesson.get("cheat_sheet", ""),
		"steps": steps_array
	}

func _hydrate_lessons_from_life_skills(json_data: Dictionary) -> void:
	if not json_data.has("skill_groups"):
		return
	var groups = json_data["skill_groups"]
	var lesson_counter = 1
	var letters = ["A", "B", "C", "D"]
	
	for g_idx in range(groups.size()):
		var group = groups[g_idx]
		var branch_idx = g_idx + 1
		var branch_name = group.get("group_name", "Kỹ năng sống")
		var group_desc = group.get("group_desc", "")
		var skills = group.get("skills", [])
		
		for s_idx in range(skills.size()):
			var sk = skills[s_idx]
			var cards_arr = []
			var puzzle_cards = sk.get("puzzle_cards", [])
			for c_idx in range(puzzle_cards.size()):
				var pc = puzzle_cards[c_idx]
				var code_letter = letters[c_idx] if c_idx < letters.size() else str(c_idx + 1)
				cards_arr.append({
					"code": code_letter,
					"meow": pc.get("cat_sound", "Meow!"),
					"icon": pc.get("action_icon", "🐾"),
					"text": pc.get("card_label", ""),
					"step": pc.get("order", c_idx + 1),
					"error_hint": pc.get("error_hint", "")
				})
			
			var loot = sk.get("reward_loot", {})
			var guide_steps = sk.get("handbook_content", [])
			var cheat_summary = "BÍ KÍP SEN: " + " -> ".join(guide_steps)
			
			lessons_data[lesson_counter] = {
				"id": lesson_counter,
				"skill_id": sk.get("skill_id", "skill_%d" % lesson_counter),
				"branch": branch_idx,
				"branch_name": branch_name,
				"title": sk.get("skill_name", "Kỹ Năng %d" % lesson_counter),
				"context": group_desc if group_desc != "" else "Thử thách kỹ năng thực tế của Mèo",
				"guide": guide_steps,
				"cards": cards_arr,
				"fail_msg": "Quê xệ! Mèo làm sai thứ tự rồi Sen ơi! Xem lại cẩm nang nhé!",
				"success_msg": sk.get("cutscene_desc", "Mèo hoàn thành thử thách xuất sắc!"),
				"loot_name": loot.get("item_reward_name", "Chiến lợi phẩm Mèo"),
				"loot_desc": "Phần thưởng hoàn thành: " + sk.get("reward_achievement", ""),
				"reward_fish": loot.get("fish_amount", 30),
				"achievement": sk.get("reward_achievement", "Thổ Địa Kỹ Năng"),
				"cheat_sheet": cheat_summary
			}
			lesson_counter += 1

# HỆ THỐNG CẤP ĐỘ MÈO & ĐIỀU KIỆN THĂNG CẤP (CAT MASTERY LEVELS)
const MASTERY_CONFIG = [
	{
		"level": 1,
		"title": "Mèo Rụt Rè (Novice)",
		"min_exp": 0,
		"max_exp": 100,
		"req_text": "Cấp khởi điểm của tân sinh viên",
		"skills_unlocked": "Mở sẵn 4 kỹ năng nhập môn: Bài 1, 5, 9, 13"
	},
	{
		"level": 2,
		"title": "Mèo Tháo Vát (Learner)",
		"min_exp": 100,
		"max_exp": 250,
		"req_text": "Tích lũy 100 EXP + hoàn thành tối thiểu 2 bài học",
		"skills_unlocked": "Mở khóa 4 kỹ năng trung cấp: Bài 2, 6, 10, 14"
	},
	{
		"level": 3,
		"title": "Mèo Dạn Dĩ (Adept)",
		"min_exp": 250,
		"max_exp": 450,
		"req_text": "Tích lũy 250 EXP + hoàn thành tối thiểu 5 bài học",
		"skills_unlocked": "Mở khóa 4 kỹ năng nâng cao: Bài 3, 7, 11, 15"
	},
	{
		"level": 4,
		"title": "Mèo Bản Lĩnh (Master)",
		"min_exp": 450,
		"max_exp": 700,
		"req_text": "Tích lũy 450 EXP + hoàn thành tối thiểu 9 bài học",
		"skills_unlocked": "Mở khóa 4 kỹ năng chuyên sâu: Bài 4, 8, 12, 16"
	},
	{
		"level": 5,
		"title": "Mèo Thổ Địa (Champion)",
		"min_exp": 700,
		"max_exp": 700,
		"req_text": "Tích lũy 700 EXP + hoàn thành toàn bộ 16 bài học",
		"skills_unlocked": "Tốt nghiệp Xuất Sắc: Danh hiệu Thổ Địa Vàng 🏆"
	}
]

func get_mastery_info() -> Dictionary:
	var idx = clampi(cat_mastery_level - 1, 0, 4)
	return MASTERY_CONFIG[idx]

func get_skill_required_level(lesson_id: int) -> int:
	if lesson_id in [1, 5, 9, 13]:
		return 1
	elif lesson_id in [2, 6, 10, 14]:
		return 2
	elif lesson_id in [3, 7, 11, 15]:
		return 3
	else:
		return 4

# --- QUẢN LÝ KHUNG AVATAR TAI MÈO & HÌNH NỀN PHÒNG CLASSIC ---
func get_avatar_frame_path(frame_id: String = "") -> String:
	if frame_id == "":
		frame_id = selected_avatar_frame
	var p = "res://assets/UI/CatUIPaid/slices/avatar_frames/frame_cat_ear_%s.png" % frame_id
	if ResourceLoader.exists(p):
		return p
	return "res://assets/UI/CatUIPaid/slices/avatar_frames/frame_cat_ear_beige.png"

func set_avatar_frame(frame_id: String) -> void:
	selected_avatar_frame = frame_id
	emit_signal("avatar_frame_changed", frame_id)
	save_game()

func get_classic_bg_path(bg_id: int = -1) -> String:
	if bg_id <= 0:
		bg_id = selected_classic_bg_id
	var p1 = "res://assets/furnitures/PetMobileGameAsset/PetMobileGameAsset/Backgrounds/Classic/%d.png" % bg_id
	if ResourceLoader.exists(p1) or FileAccess.file_exists(p1):
		return p1
	var p2 = "res://assets/UI/PetMobileGameAsset/PetMobileGameAsset/Backgrounds/Classic/%d.png" % bg_id
	if ResourceLoader.exists(p2) or FileAccess.file_exists(p2):
		return p2
	return p1

func set_classic_bg(bg_id: int) -> void:
	selected_classic_bg_id = clampi(bg_id, 1, 20)
	emit_signal("classic_bg_changed", selected_classic_bg_id)
	save_game()

func get_currency_name() -> String:
	return "Đồng Vàng"

func format_gold(amount: int) -> String:
	return "%d 🟡" % amount

func load_texture(path: String) -> Texture2D:
	if path.ends_with(".tres") or path.ends_with(".res"):
		if ResourceLoader.exists(path):
			var res = load(path)
			if res is Texture2D: return res
	if ResourceLoader.exists(path) and not path.ends_with(".png"):
		var res = load(path)
		if res is Texture2D: return res
	var global_path = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(global_path):
		var img = Image.load_from_file(global_path)
		if img: return ImageTexture.create_from_image(img)
	if FileAccess.file_exists(path):
		var img = Image.load_from_file(path)
		if img: return ImageTexture.create_from_image(img)
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is Texture2D: return res
	return null

func check_skill_unlock_status(lesson_id: int) -> Dictionary:
	var req_lvl = get_skill_required_level(lesson_id)
	var prev_id = lesson_id - 1 if (lesson_id - 1) % 4 != 0 else 0
	
	if lesson_id in completed_lessons:
		return {
			"is_unlocked": true,
			"req_level": req_lvl,
			"req_title": MASTERY_CONFIG[req_lvl - 1]["title"],
			"reason": ""
		}
		
	# Kiểm tra cấp độ Mèo
	if cat_mastery_level < req_lvl:
		var lvl_info = MASTERY_CONFIG[req_lvl - 1]
		return {
			"is_unlocked": false,
			"req_level": req_lvl,
			"req_title": lvl_info["title"],
			"reason": "Yêu cầu Mèo đạt Cấp %d: %s (%s)!" % [req_lvl, lvl_info["title"], lvl_info["req_text"]]
		}
		
	# Kiểm tra bài trước trong cùng nhánh
	if prev_id > 0 and not (prev_id in completed_lessons):
		var prev_title = lessons_data.get(prev_id, {}).get("title", "Bài %d" % prev_id)
		return {
			"is_unlocked": false,
			"req_level": req_lvl,
			"req_title": MASTERY_CONFIG[req_lvl - 1]["title"],
			"reason": "Cần hoàn thành Bài %d: '%s' trước!" % [prev_id, prev_title]
		}
		
	return {
		"is_unlocked": true,
		"req_level": req_lvl,
		"req_title": MASTERY_CONFIG[req_lvl - 1]["title"],
		"reason": ""
	}

func _refresh_unlocked_lessons() -> void:
	for id in range(1, 17):
		var st = check_skill_unlock_status(id)
		if st["is_unlocked"] and not (id in unlocked_lessons):
			unlocked_lessons.append(id)

func add_mastery_exp(exp_val: int) -> void:
	cat_mastery_exp += exp_val
	# Cập nhật level dựa trên EXP (100, 250, 450, 700)
	var new_lvl = 1
	if cat_mastery_exp >= 700:
		new_lvl = 5
	elif cat_mastery_exp >= 450:
		new_lvl = 4
	elif cat_mastery_exp >= 250:
		new_lvl = 3
	elif cat_mastery_exp >= 100:
		new_lvl = 2
		
	if new_lvl > cat_mastery_level:
		cat_mastery_level = new_lvl
		var lvl_info = get_mastery_info()
		_play_sound_level_up()
		emit_signal("show_toast", "🎉 CHÚC MỪNG! Mèo đã thăng cấp lên CẤP %d: %s! %s" % [cat_mastery_level, lvl_info["title"], lvl_info["skills_unlocked"]])
		_refresh_unlocked_lessons()
	save_game()

# Quay Gacha mở Hộp Quà theo Cat Mastery Level
func roll_gacha_loot() -> Dictionary:
	if not loot_tables_data or not loot_tables_data.has("mastery_levels"):
		return {"name": "Hộp Quà Cá Khô", "icon": "🐟", "type": "fish", "amount": 30}
		
	var lvl_info = loot_tables_data["mastery_levels"][clampi(cat_mastery_level - 1, 0, 4)]
	var weights = lvl_info["loot_drop_weights"]
	
	var total_w = weights["soft_currency"] + weights["basic_food"] + weights["decor_common"] + weights["cat_costume"] + weights["legendary"]
	var rand_w = randi() % total_w
	
	var selected_category = "soft_currency"
	var cumulative = weights["soft_currency"]
	if rand_w < cumulative:
		selected_category = "soft_currency"
	elif rand_w < cumulative + weights["basic_food"]:
		selected_category = "basic_food"
		cumulative += weights["basic_food"]
	elif rand_w < cumulative + weights["decor_common"]:
		selected_category = "decor_common"
		cumulative += weights["decor_common"]
	elif rand_w < cumulative + weights["cat_costume"]:
		selected_category = "cat_costume"
		cumulative += weights["cat_costume"]
	else:
		selected_category = "legendary"
		
	var pool = loot_tables_data["items_pool"].get(selected_category, [])
	if pool.is_empty():
		return {"name": "Túi Cá Khô May Mắn", "icon": "🐟", "amount": 25}
		
	var item = pool[randi() % pool.size()]
	
	# Xử lý trao thưởng
	if selected_category == "soft_currency":
		var amt = item.get("amount", 20)
		update_stats(amt, 0, +5, +5)
	elif selected_category == "decor_common":
		if not item["item_id"] in inventory_decor:
			inventory_decor.append(item["item_id"])
		update_stats(0, 0, +10, +15)
	elif selected_category == "cat_costume":
		if not item["item_id"] in inventory_costumes:
			inventory_costumes.append(item["item_id"])
		update_stats(0, 0, +15, +20)
		
	save_game()
	return item

# HỆ THỐNG CỨU TRỢ BẠN BÈ (PEER SYSTEM)
func can_send_peer_relief(amount: int) -> Dictionary:
	if amount <= 0:
		return {"ok": false, "reason": "Số tiền cứu trợ không hợp lệ!"}
	if daily_relief_sent + amount > 20:
		return {"ok": false, "reason": "Vượt quá giới hạn gửi cứu trợ! Tối đa %s/ngày (Đã gửi: %s)." % [format_currency(20), format_currency(daily_relief_sent)]}
	if fish < amount:
		return {"ok": false, "reason": "Bạn không đủ tiền để gửi cứu trợ!"}
	return {"ok": true, "reason": ""}

func send_peer_relief(friend_id: String, amount: int) -> bool:
	var check = can_send_peer_relief(amount)
	if not check["ok"]:
		emit_signal("show_toast", check["reason"])
		return false
	daily_relief_sent += amount
	update_stats(-amount, 0, +5, +10)
	emit_signal("show_toast", "Đã gửi %d Cá cứu trợ cho %s! Tinh thần tương thân tương ái (+10 Mood)!" % [amount, friend_id])
	save_game()
	return true

func can_receive_peer_relief(amount: int) -> Dictionary:
	if daily_relief_received + amount > 40:
		return {"ok": false, "reason": "Đã đạt giới hạn nhận cứu trợ 40 Cá/ngày (Đã nhận: %d/40)!" % daily_relief_received}
	return {"ok": true, "reason": ""}

func receive_peer_relief(from_friend: String, amount: int) -> bool:
	var check = can_receive_peer_relief(amount)
	if not check["ok"]:
		emit_signal("show_toast", check["reason"])
		return false
	daily_relief_received += amount
	update_stats(amount, 0, +10, +15)
	emit_signal("show_toast", "Nhận được %d Cá cứu trợ từ %s! Ấm lòng sinh viên (+15 Mood)!" % [amount, from_friend])
	save_game()
	return true

func update_stats(delta_fish: int, delta_hunger: int, delta_courage: int, delta_mood: int = 0) -> void:
	var old_hunger = hunger
	var old_courage = courage
	var old_mood = mood
	
	fish = maxi(0, fish + delta_fish)
	hunger = clampi(hunger + delta_hunger, 0, 100)
	courage = clampi(courage + delta_courage, 0, 100)
	mood = clampi(mood + delta_mood, 0, 100)
	
	# 1. Kiểm tra trạng thái Xỉu vì hạ đường huyết
	if hunger <= 0:
		is_fainted = true
		emit_signal("show_toast", "🚨 NGUY CẤP: Mèo đã ngất xỉu vì hạ đường huyết (Độ No = 0)! Hãy cho Boss ăn cấp cứu ngay!")
	elif old_hunger <= 0 and hunger > 0:
		is_fainted = false
		emit_signal("show_toast", "✨ Hú hồn! Boss đã hồi tỉnh sau khi được tiếp tế kịp thời! 🎉")
	elif hunger < 25 and old_hunger >= 25:
		emit_signal("show_toast", "⚠️ CẢNH BÁO: Mèo đang đói lả (Độ No: %d/100)! Hãy cho Boss ăn trước khi ngất xỉu!" % hunger)
		
	# 2. Kiểm tra trạng thái Tự ti / Hoảng loạn không muốn đi học
	if courage <= 15:
		is_shy = true
		if old_courage > 15:
			emit_signal("show_toast", "😿 CẢNH BÁO: Mèo đang quá tự ti và hoảng sợ (Dũng Cảm: %d/100)! Boss trốn trong phòng không dám đi học!" % courage)
	elif old_courage <= 15 and courage > 15:
		is_shy = false
		emit_signal("show_toast", "🦁 Tuyệt vời! Mèo đã lấy lại tự tin và sẵn sàng bước ra đời học kỹ năng!")
	elif courage < 25 and old_courage >= 25:
		emit_signal("show_toast", "⚠️ CẢNH BÁO: Dũng Cảm của Mèo đang tụt dốc (%d/100)! Boss bắt đầu thấy lo lắng, tự ti!" % courage)
		
	# 3. Kiểm tra Tâm trạng ủ rũ
	if mood < 20 and old_mood >= 20:
		emit_signal("show_toast", "😿 CẢNH BÁO: Mèo đang ủ rũ buồn bã (Tâm Trạng: %d/100)! Hãy vuốt ve hoặc cho Boss chơi đồ chơi!" % mood)
		
	emit_signal("stats_changed")
	save_game()

func can_feed() -> Dictionary:
	if hunger >= 100:
		emit_signal("show_status_alert", "too_full")
		return {"ok": false, "reason": "🤢 Ục ục... Mèo đã no căng bụng (100/100) rồi Sen ơi! Đừng ép Boss ăn nữa kẻo bội thực!"}
	return {"ok": true, "reason": ""}

func can_start_lesson() -> Dictionary:
	if hunger <= 0:
		emit_signal("show_status_alert", "fainted")
		return {"ok": false, "reason": "🚨 Mèo đã ngất xỉu vì đói lả (Độ No = 0)! Hãy cho Boss ăn cấp cứu hồi phục trước khi học nhé Sen!"}
	if hunger < 20:
		return {"ok": false, "reason": "😿 Mèo đang đói lả kiệt sức (Độ No < 20)! Cho Boss ăn no bụng rồi mới học được nhé Sen!"}
	if courage <= 15 or mood <= 20:
		emit_signal("show_status_alert", "too_stressed")
		return {"ok": false, "reason": "😿 Mèo đang quá tự ti và hoảng sợ (Dũng Cảm <= 15)! Boss trốn trong phòng không dám ra đường. Hãy dùng Cần câu lông vũ hoặc vỗ về Boss trước đã!"}
	return {"ok": true, "reason": ""}

func complete_lesson(lesson_id: int) -> Dictionary:
	var lesson = lessons_data.get(lesson_id)
	if not lesson:
		return {}
	
	if not lesson_id in completed_lessons:
		completed_lessons.append(lesson_id)
		# Mở bài tiếp theo
		if lesson_id + 1 <= 16 and not (lesson_id + 1) in unlocked_lessons:
			unlocked_lessons.append(lesson_id + 1)
		
		# Thêm loot
		loot_collection.append({
			"id": lesson_id,
			"name": lesson["loot_name"],
			"desc": lesson["loot_desc"]
		})
		
		# Thưởng cá khô & EXP thăng cấp
		update_stats(lesson["reward_fish"], -5, +15)
		add_mastery_exp(35)
	else:
		# Học lại thì thưởng nhẹ & EXP
		update_stats(10, -5, +5)
		add_mastery_exp(10)
		
	_refresh_unlocked_lessons()
	emit_signal("lesson_completed", lesson_id)
	save_game()
	return lesson

func _play_sound_fail() -> void:
	var sm = get_node_or_null("/root/SoundManager")
	if sm and sm.has_method("play_fail"):
		sm.play_fail()

func _play_sound_level_up() -> void:
	var sm = get_node_or_null("/root/SoundManager")
	if sm and sm.has_method("play_level_up"):
		sm.play_level_up()

func get_food_count(food_type: String) -> int:
	return food_inventory.get(food_type, 0)

func add_food_stock(food_type: String, amount: int = 1) -> void:
	food_inventory[food_type] = food_inventory.get(food_type, 0) + amount
	save_game()
	save_room_state()
	emit_signal("stats_changed")

func feed_kibble() -> bool:
	var check = can_feed()
	if not check["ok"]:
		emit_signal("show_toast", check["reason"])
		_play_sound_fail()
		return false
	if food_inventory.get("kibble", 0) <= 0:
		emit_signal("show_toast", "❌ Đã hết Hạt Sinh Viên! Vào Cửa Hàng để mua thêm nha Sen! 🛒")
		_play_sound_fail()
		return false
	food_inventory["kibble"] -= 1
	update_stats(0, +15, 0, +5)
	save_game()
	emit_signal("show_toast", "🍚 Mèo ăn Hạt sinh viên (+15 No, +5 Tâm Trạng). Còn %d bát!" % food_inventory["kibble"])
	return true

func feed_basic() -> bool:
	return feed_kibble()

func feed_dry_fish() -> bool:
	var check = can_feed()
	if not check["ok"]:
		emit_signal("show_toast", check["reason"])
		_play_sound_fail()
		return false
	if food_inventory.get("dry_fish", 0) <= 0:
		emit_signal("show_toast", "❌ Đã hết Cá Khô Quê Gửi! Vào Cửa Hàng để mua thêm nha Sen! 🛒")
		_play_sound_fail()
		return false
	food_inventory["dry_fish"] -= 1
	update_stats(0, +20, +5, +20)
	save_game()
	emit_signal("show_toast", "🐟 Boss ăn Cá Khô mẹ gửi (+20 No, +20 Mood, +5 Dũng)! Còn %d con!" % food_inventory["dry_fish"])
	return true

func feed_pate() -> bool:
	var check = can_feed()
	if not check["ok"]:
		emit_signal("show_toast", check["reason"])
		_play_sound_fail()
		return false
	if food_inventory.get("pate", 0) <= 0:
		emit_signal("show_toast", "❌ Đã hết Pate Thượng Hạng! Vào Cửa Hàng để mua thêm nha Sen! 🛒")
		_play_sound_fail()
		return false
	food_inventory["pate"] -= 1
	update_stats(0, +35, +25, +20)
	save_game()
	emit_signal("show_toast", "🥫 Boss thưởng thức lon Pate thơm ngon (+35 No, +25 Dũng, +20 Mood)! Còn %d lon!" % food_inventory["pate"])
	return true

func play_box() -> void:
	update_stats(0, 0, +15, +15)
	emit_signal("show_toast", "Mèo chui vào Thùng Carton tự chế (+15 Dũng cảm, +15 Tâm Trạng)! Tốn 0 Cá, rèn tính tháo vát!")

func play_cardboard() -> void:
	play_box()

func play_feather() -> bool:
	if fish < 20:
		emit_signal("show_toast", "Không đủ tiền! Cần %s để mua Cần câu lông vũ." % format_currency(20))
		return false
	update_stats(-20, 0, +40)
	emit_signal("show_toast", "Mèo hưng phấn vờn lông vũ (+40 Dũng cảm, -%s 💵)! Cẩn thận thâm hụt ngân sách!" % format_currency(20))
	return true

func use_bnpl() -> void:
	debt_amount += 35
	debt_due_day = current_day + 5
	update_stats(0, 0, +30)
	emit_signal("show_toast", "Quẹt 'Ví Trả Sau' sắm đệm êm (+30 Dũng cảm)! CẢNH BÁO: Phải trả %s sau 5 ngày!" % format_currency(35))

func pet_cat() -> void:
	update_stats(0, -1, +5)
	emit_signal("show_toast", "Gãi cằm Boss, Mèo kêu gừ gừ sung sướng (+5 Dũng cảm)!")

func check_debt_status() -> void:
	if debt_amount > 0 and current_day >= debt_due_day:
		if fish >= debt_amount:
			update_stats(-debt_amount, 0, -20)
			emit_signal("show_toast", "Đến hạn ví trả sau! Bị trừ %s và -20 Dũng cảm!" % format_currency(debt_amount))
		else:
			update_stats(-fish, 0, -35)
			emit_signal("show_toast", "Vỡ nợ ví trả sau! Bị tịch thu toàn bộ tiền tiết kiệm và hoảng loạn (-35 Dũng cảm)!")
		debt_amount = 0

func set_avatar(new_id: int) -> void:
	if new_id >= 0 and new_id < avatar_list.size():
		selected_avatar_id = new_id
		emit_signal("avatar_changed", selected_avatar_id)
		emit_signal("room_name_changed", get_room_name())
		save_game()
		emit_signal("show_toast", "Đã đổi thành: %s 🐾" % avatar_list[new_id]["name"])

func get_cat_name() -> String:
	if custom_cat_name != "":
		return custom_cat_name
	if selected_avatar_id >= 0 and selected_avatar_id < avatar_list.size():
		return avatar_list[selected_avatar_id]["name"]
	return "Mèo"

func set_cat_name(new_name: String) -> void:
	custom_cat_name = new_name.strip_edges()
	emit_signal("avatar_changed", selected_avatar_id)
	emit_signal("room_name_changed", get_room_name())
	save_game()

func get_cat_breed() -> String:
	if selected_avatar_id >= 0 and selected_avatar_id < avatar_list.size():
		return avatar_list[selected_avatar_id]["name"]
	return "Mèo Mướp Cam"

func get_cat_desc() -> String:
	if selected_avatar_id >= 0 and selected_avatar_id < avatar_list.size():
		return avatar_list[selected_avatar_id]["desc"]
	return "Năng động, háu ăn, thích khám phá"

func get_owner_name() -> String:
	if owner_name != "":
		return owner_name
	return "Tân Sinh Viên"

func set_owner_name(new_name: String) -> void:
	owner_name = new_name.strip_edges()
	save_game()

func get_room_name() -> String:
	if custom_room_name != "":
		return custom_room_name
	return "Phòng của %s" % get_cat_name()

func set_room_name(new_name: String) -> void:
	custom_room_name = new_name.strip_edges()
	save_game()
	emit_signal("room_name_changed", get_room_name())
	emit_signal("show_toast", "Đã đổi tên thành: %s 🏠" % get_room_name())

# --- ĐỊNH DẠNG TIỀN TỆ & HỆ THỐNG PUZZLE CHỨNG NHẬN ---
func format_currency(amount: int) -> String:
	if amount >= 1000:
		return "%sđ" % format_number_with_commas(amount)
	return "%d.000đ" % amount

func format_number_with_commas(val: int) -> String:
	var s = str(val)
	var res = ""
	var count = 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		count += 1
		if count % 3 == 0 and i > 0:
			res = "." + res
	return res

func is_certificate_claimed(cert_id: String) -> bool:
	return cert_id in claimed_certificates

func claim_certificate(cert_id: String) -> Dictionary:
	if cert_id in claimed_certificates:
		return {}
	claimed_certificates.append(cert_id)
	var reward_money = 50 # 50.000đ
	if cert_id == "cert_finance":
		reward_money = 100 # 100.000đ
	update_stats(+reward_money, 0, +25)
	save_game()
	return {"money": reward_money, "cert_id": cert_id}

# --- HỆ THỐNG CỬA HÀNG (SHOP SYSTEM) ---
func get_shop_item(item_id: String) -> Dictionary:
	if not shop_catalog_data.has("items"):
		return {}
	for it in shop_catalog_data["items"]:
		if it["id"] == item_id:
			return it
	return {}

func is_item_owned(item_id: String) -> bool:
	return (item_id in inventory_costumes) or (item_id in inventory_decor) or (item_id in inventory_toys) or (item_id in inventory_food)

func buy_shop_item(item_id: String) -> Dictionary:
	var item = get_shop_item(item_id)
	if item.is_empty():
		return {"ok": false, "reason": "Không tìm thấy vật phẩm!"}
		
	var price = item.get("price", 0)
	var req_lvl = item.get("required_level", 1)
	
	if cat_mastery_level < req_lvl:
		return {"ok": false, "reason": "Cần đạt Cấp %d Mèo để mở khóa vật phẩm này!" % req_lvl}
		
	if fish < price:
		return {"ok": false, "reason": "Không đủ tiền! Cần thêm %s nữa." % format_currency(price - fish)}
		
	if is_item_owned(item_id) and item["category"] in ["costumes", "decor", "toys"]:
		return {"ok": false, "reason": "Bạn đã sở hữu vật phẩm này rồi!"}
		
	fish -= price
	var cat = item["category"]
	if cat == "costumes":
		if not (item_id in inventory_costumes):
			inventory_costumes.append(item_id)
		var subcat = item.get("subcategory", "clothes")
		equipped_costumes[subcat] = item_id
		if subcat == "clothes":
			equipped_costume = item_id
		emit_signal("costume_changed", subcat, item_id)
	elif cat == "decor":
		if not (item_id in inventory_decor):
			inventory_decor.append(item_id)
		var subcat = item.get("subcategory", "general")
		equipped_decor[subcat] = item_id
		var upg_type: String = str(item.get("upgrade_type", ""))
		if upg_type != "":
			room_upgrades[upg_type] = true
			save_room_state()
		emit_signal("decor_changed", subcat, item_id)
	elif cat == "toys":
		if not (item_id in inventory_toys):
			inventory_toys.append(item_id)
		var boost = item.get("stat_boost", {})
		update_stats(0, 0, boost.get("courage", 15), boost.get("mood", 20))
	elif cat == "food":
		inventory_food.append(item_id)
		var subcat = item.get("subcategory", "kibble")
		var boost = item.get("stat_boost", {})
		update_stats(0, boost.get("hunger", 25), boost.get("courage", 10), boost.get("mood", 15))
		
		# Tăng số lượng thức ăn vào kho lưu trữ của Sen
		if subcat == "kibble":
			food_inventory["kibble"] = food_inventory.get("kibble", 0) + 2
		elif subcat == "pate":
			food_inventory["pate"] = food_inventory.get("pate", 0) + 1
		else:
			food_inventory["dry_fish"] = food_inventory.get("dry_fish", 0) + 2
		
	save_game()
	save_room_state()
	emit_signal("stats_changed")
	return {"ok": true, "item": item}

func equip_costume(item_id: String) -> void:
	if item_id in inventory_costumes or item_id == "":
		var it = get_shop_item(item_id)
		var subcat = it.get("subcategory", "clothes") if not it.is_empty() else "clothes"
		equipped_costumes[subcat] = item_id
		if subcat == "clothes":
			equipped_costume = item_id
		save_game()
		emit_signal("costume_changed", subcat, item_id)
		emit_signal("show_toast", "Đã trang bị trang phục cho Boss! 👔")

func equip_costume_slot(slot: String, item_id: String) -> void:
	if item_id == "" or (item_id in inventory_costumes):
		equipped_costumes[slot] = item_id
		if slot == "clothes":
			equipped_costume = item_id
		save_game()
		emit_signal("costume_changed", slot, item_id)
		if item_id != "":
			var it = get_shop_item(item_id)
			emit_signal("show_toast", "Mặc %s cho Boss! ✨" % it.get("name", "trang phục"))
		else:
			emit_signal("show_toast", "Đã tháo trang phục slot %s!" % slot)

func unequip_costume_slot(slot: String) -> void:
	equip_costume_slot(slot, "")

func unequip_all_costumes() -> void:
	for slot in ["clothes", "hats", "bows", "accessories"]:
		equipped_costumes[slot] = ""
	equipped_costume = ""
	save_game()
	emit_signal("costume_changed", "all", "")
	emit_signal("show_toast", "Đã cởi bỏ toàn bộ trang phục, Boss mộc mạc dễ thương! 🐾")

func randomize_fashion() -> Dictionary:
	var slots = ["clothes", "hats", "bows", "accessories"]
	for slot in slots:
		var owned = get_owned_costumes_for_slot(slot)
		if owned.size() > 0 and randf() > 0.2:
			var picked = owned[randi() % owned.size()]
			equipped_costumes[slot] = picked["id"]
			if slot == "clothes":
				equipped_costume = picked["id"]
		else:
			equipped_costumes[slot] = ""
			if slot == "clothes":
				equipped_costume = ""
	save_game()
	emit_signal("costume_changed", "all", "")
	emit_signal("show_toast", "🎲 Đã phối set đồ ngẫu nhiên siêu cưng cho Boss!")
	return equipped_costumes

func get_fashion_score() -> int:
	var score: int = 20 # Điểm mộc mạc cơ bản
	var equipped_count: int = 0
	for slot in ["clothes", "hats", "bows", "accessories"]:
		var id = equipped_costumes.get(slot, "")
		if id != "":
			equipped_count += 1
			var item = get_shop_item(id)
			if not item.is_empty():
				score += item.get("price", 20)
				var boost = item.get("stat_boost", {})
				score += boost.get("courage", 5) + boost.get("mood", 5)
	if equipped_count >= 3:
		score += 35 # Set bonus phong cách hoàn chỉnh
	if equipped_count == 4:
		score += 25 # Full set ngôi sao
	return score

func get_fashion_title() -> String:
	var score = get_fashion_score()
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

func get_cozy_score() -> int:
	var score: int = 30 # Điểm phòng cơ bản
	for slot in equipped_decor.keys():
		var id = equipped_decor[slot]
		if id != "":
			var item = get_shop_item(id)
			if not item.is_empty():
				score += item.get("price", 25)
	return score

func get_cozy_title() -> String:
	var score = get_cozy_score()
	if score < 60:
		return "Phòng Trọ Đơn Sơ 📦"
	elif score < 110:
		return "Góc Nhỏ Ấm Cúng ☕"
	elif score < 180:
		return "Căn Hộ Sinh Viên Tiện Nghi 🏡"
	else:
		return "Thiên Đường Mèo Hoàng Gia 🏰"

func get_owned_costumes_for_slot(slot: String) -> Array:
	var res = []
	if not shop_catalog_data.has("items"):
		return res
	for it in shop_catalog_data["items"]:
		if it["category"] == "costumes":
			if slot == "all" or it["subcategory"] == slot:
				if it["id"] in inventory_costumes:
					res.append(it)
	return res

func get_owned_decor_for_slot(slot: String) -> Array:
	var res = []
	if not shop_catalog_data.has("items"):
		return res
	for it in shop_catalog_data["items"]:
		if it["category"] == "decor":
			if slot == "all" or it["subcategory"] == slot:
				if it["id"] in inventory_decor:
					res.append(it)
	return res

func equip_decor(subcategory: String, item_id: String) -> void:
	if item_id in inventory_decor or item_id == "":
		equipped_decor[subcategory] = item_id
		save_game()
		emit_signal("decor_changed", subcategory, item_id)
		emit_signal("show_toast", "Đã bài trí nội thất phòng trọ! 🏡")

func unequip_decor(subcategory: String) -> void:
	if equipped_decor.has(subcategory):
		equipped_decor.erase(subcategory)
		save_game()
		emit_signal("decor_changed", subcategory, "")
		emit_signal("show_toast", "Đã cất đồ trang trí vào kho! 📦")

func save_placed_decor(decor_list: Array) -> void:
	placed_room_decor = decor_list.duplicate(true)
	save_game()
	save_room_state()
	emit_signal("placed_decor_changed")

func get_placed_decor() -> Array:
	return placed_room_decor.duplicate(true)

func clear_placed_decor() -> void:
	placed_room_decor.clear()
	save_game()
	save_room_state()
	emit_signal("placed_decor_changed")

func _process(delta: float) -> void:
	if is_offline_auto_sleeping or hunger <= 0:
		return
	_hunger_tick_accum += delta
	var secs_per_point: float = 3600.0 / HUNGER_DECAY_PER_HOUR # 720s = 5/giờ
	if _hunger_tick_accum >= secs_per_point:
		var steps: int = int(floor(_hunger_tick_accum / secs_per_point))
		_hunger_tick_accum -= float(steps) * secs_per_point
		update_stats(0, -steps, 0, 0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		last_active_unix = int(Time.get_unix_time_from_system())
		save_game()
		save_room_state()
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		var now_unix: int = int(Time.get_unix_time_from_system())
		if last_active_unix > 0 and now_unix > last_active_unix:
			apply_offline_hunger_decay(float(now_unix - last_active_unix), true)
		last_active_unix = now_unix

static func calculate_hunger_decay(hours: float, auto_sleep: bool = false) -> int:
	if hours <= 0.0:
		return 0
	var rate: float = HUNGER_DECAY_PER_HOUR * (0.5 if auto_sleep else 1.0)
	return maxi(0, int(round(hours * rate)))

func apply_offline_hunger_decay(elapsed_seconds: float, auto_sleep_conserve: bool = true) -> Dictionary:
	if elapsed_seconds < 60.0:
		return {"hunger_lost": 0, "auto_sleep": false, "hours": 0.0}
	var hours: float = elapsed_seconds / 3600.0
	var decay: int = calculate_hunger_decay(hours, auto_sleep_conserve)
	is_offline_auto_sleeping = auto_sleep_conserve
	var prev_hunger: int = hunger
	# Chế độ tự động ngủ bảo toàn năng lượng khi chủ đi vắng: không bao giờ để ngất xỉu/ốm/phạt (<10)
	if auto_sleep_conserve:
		hunger = clampi(maxf(10.0, float(prev_hunger - decay)), 10, 100)
	else:
		hunger = clampi(prev_hunger - decay, 0, 100)
	var actual_loss: int = maxi(0, prev_hunger - hunger)
	last_offline_summary = {
		"hours": hours,
		"hunger_lost": actual_loss,
		"auto_sleep": auto_sleep_conserve,
		"cat_sprite": "res://assets/UI/CatUIPaid/slices/cat_sleep_cream.png"
	}
	if actual_loss > 0:
		emit_signal("stats_changed")
	return last_offline_summary

func set_furniture_grid_pos(furn_key: String, cell: Vector2i) -> void:
	furniture_grid_positions[furn_key] = {"u": cell.x, "v": cell.y}
	save_room_state()

func get_room_comfort_summary() -> Dictionary:
	var cooling_bonus: int = 0
	if room_upgrades.get("heat_insulation", false) or ("d_insulation_curtain" in inventory_decor):
		room_upgrades["heat_insulation"] = true
		cooling_bonus += 5
	if room_upgrades.get("mini_fan", false) or ("d_mini_fan" in inventory_decor):
		room_upgrades["mini_fan"] = true
		cooling_bonus += 5
	return {
		"heat_insulation": room_upgrades.get("heat_insulation", false),
		"mini_fan": room_upgrades.get("mini_fan", false),
		"cooling_bonus_c": cooling_bonus
	}

func save_room_state() -> bool:
	var payload := {
		"version": 1,
		"placed_room_decor": placed_room_decor,
		"furniture_grid_positions": furniture_grid_positions,
		"room_upgrades": room_upgrades,
		"food_bowl_servings": food_bowl_servings,
		"last_active_unix": int(Time.get_unix_time_from_system())
	}
	var f = FileAccess.open(ROOM_SAVE_PATH, FileAccess.WRITE)
	if not f:
		return false
	f.store_string(JSON.stringify(payload))
	emit_signal("room_state_updated")
	return true

func load_room_state() -> Dictionary:
	if not FileAccess.file_exists(ROOM_SAVE_PATH):
		return {}
	var f = FileAccess.open(ROOM_SAVE_PATH, FileAccess.READ)
	if not f:
		return {}
	var json = JSON.new()
	if json.parse(f.get_as_text()) != OK:
		return {}
	var parsed = json.get_data()
	if not (parsed is Dictionary):
		return {}
	if parsed.has("placed_room_decor") and parsed["placed_room_decor"] is Array and parsed["placed_room_decor"].size() > 0:
		placed_room_decor = parsed["placed_room_decor"]
	if parsed.has("furniture_grid_positions") and parsed["furniture_grid_positions"] is Dictionary:
		furniture_grid_positions = parsed["furniture_grid_positions"]
	if parsed.has("room_upgrades") and parsed["room_upgrades"] is Dictionary:
		for k in parsed["room_upgrades"]:
			room_upgrades[k] = bool(parsed["room_upgrades"][k])
	if parsed.has("food_bowl_servings"):
		food_bowl_servings = maxi(0, int(parsed["food_bowl_servings"]))
	if "d_insulation_curtain" in inventory_decor:
		room_upgrades["heat_insulation"] = true
	if "d_mini_fan" in inventory_decor:
		room_upgrades["mini_fan"] = true
	return parsed

# --- HỆ THỐNG CHI PHÍ SINH VIÊN & SỔ CHI PHÍ KTX HÀNG THÁNG ---
func get_total_monthly_expenses() -> int:
	return monthly_rent_cost + monthly_utility_cost + monthly_cat_food_cost # 85.000đ

func get_monthly_budget_status() -> Dictionary:
	return {
		"rent": monthly_rent_cost,
		"utilities": monthly_utility_cost,
		"cat_food": monthly_cat_food_cost,
		"total": get_total_monthly_expenses(),
		"days_left": days_until_rent_due,
		"is_paid": is_rent_paid_this_month,
		"can_afford": fish >= get_total_monthly_expenses()
	}

func pay_monthly_expenses() -> bool:
	var total = get_total_monthly_expenses()
	if is_rent_paid_this_month:
		emit_signal("show_toast", "✅ Bạn đã đóng đủ tiền sinh hoạt tháng này rồi!")
		return false
	if fish >= total:
		fish -= total
		is_rent_paid_this_month = true
		save_game()
		emit_signal("stats_changed")
		emit_signal("monthly_rent_paid")
		emit_signal("show_toast", "🎉 Đã đóng đủ %s tiền KTX tháng này! An tâm học tập! ✨" % format_currency(total))
		return true
	else:
		emit_signal("show_toast", "⚠️ Chưa đủ tiền đóng KTX! Cần thêm %s nữa!" % format_currency(total - fish))
		return false

# --- BẢNG ÁNH XẠ SPRITE GỐC PIXEL ART CHUẨN (COSTUMES & FURNITURE) ---
const COSTUME_SPRITE_PATHS = {
	"c_hoodie_student": "res://assets/sprites/costumes/cloth_hoodie.png",
	"c_sweater_wool": "res://assets/sprites/costumes/cloth_sweater.png",
	"c_grad_robe": "res://assets/sprites/costumes/cloth_dracula_cape.png",
	"c_hat_cap": "res://assets/sprites/costumes/hat_cap_blue.png",
	"c_hat_beret": "res://assets/sprites/costumes/hat_witch.png",
	"c_hat_chef": "res://assets/sprites/costumes/hat_witch.png",
	"c_bow_red": "res://assets/sprites/costumes/bow_red.png",
	"c_bow_blue": "res://assets/sprites/costumes/bow_blue.png",
	"c_bow_bell": "res://assets/sprites/costumes/bow_bell.png",
	"c_acc_glasses": "res://assets/sprites/costumes/acc_glasses.png",
	"c_acc_batman": "res://assets/sprites/costumes/acc_batman_mask.png",
	"c_acc_backpack": "res://assets/sprites/costumes/acc_batman_mask.png",
}

const FURNITURE_SPRITE_PATHS = {
	"d_bed_box": "res://assets/sprites/room_items/cat_box_new.png",
	"d_bed_terracotta": "res://assets/sprites/room_items/mobile/bed_mobile_pink.png",
	"d_bed_bunk": "res://assets/sprites/room_items/mobile/bed_mobile_blue.png",
	"d_bed_mobile_blue": "res://assets/sprites/room_items/mobile/bed_mobile_blue.png",
	"d_bed_mobile_pink": "res://assets/sprites/room_items/mobile/bed_mobile_pink.png",
	"d_bed_mobile_green": "res://assets/sprites/room_items/mobile/bed_mobile_green.png",
	"d_bed_mobile_dark": "res://assets/sprites/room_items/mobile/bed_mobile_dark.png",
	"d_bed_mobile_teal": "res://assets/sprites/room_items/mobile/bed_mobile_teal.png",
	"d_bowl_basic": "res://assets/sprites/room_items/mobile/bowl_mobile_blue_food.png",
	"d_tray_ceramic": "res://assets/sprites/room_items/mobile/bowl_mobile_green_water.png",
	"d_tray_fountain": "res://assets/sprites/room_items/mobile/bowl_mobile_dual.png",
	"d_bowl_double_auto": "res://assets/sprites/room_items/mobile/bowl_mobile_dual.png",
	"d_bowl_mobile_food": "res://assets/sprites/room_items/mobile/bowl_mobile_blue_food.png",
	"d_bowl_mobile_water": "res://assets/sprites/room_items/mobile/bowl_mobile_green_water.png",
	"d_bowl_mobile_dual": "res://assets/sprites/room_items/mobile/bowl_mobile_dual.png",
	"t_scratcher_post": "res://assets/sprites/room_items/mobile/scratch_tree_mobile_tan.png",
	"d_scratch_mobile_tan": "res://assets/sprites/room_items/mobile/scratch_tree_mobile_tan.png",
	"d_scratch_mobile_green": "res://assets/sprites/room_items/mobile/scratch_tree_mobile_green.png",
	"d_scratch_mobile_blue": "res://assets/sprites/room_items/mobile/scratch_tree_mobile_blue.png",
	"d_plant_pothos": "res://assets/sprites/room_items/mobile/plant_mobile_pot.png",
	"d_plant_fig": "res://assets/sprites/room_items/mobile/plant_mobile_tall.png",
	"d_plant_succulent": "res://assets/sprites/room_items/mobile/plant_mobile_monstera.png",
	"d_plant_mobile_pot": "res://assets/sprites/room_items/mobile/plant_mobile_pot.png",
	"d_plant_mobile_tall": "res://assets/sprites/room_items/mobile/plant_mobile_tall.png",
	"d_plant_mobile_monstera": "res://assets/sprites/room_items/mobile/plant_mobile_monstera.png",
	"d_wall_window_sun": "res://assets/sprites/room_items/mobile/window_mobile_blue_curtains.png",
	"d_window_mobile_blue": "res://assets/sprites/room_items/mobile/window_mobile_blue_curtains.png",
	"d_window_mobile_yellow": "res://assets/sprites/room_items/mobile/window_mobile_yellow_curtains.png",
	"t_carrier_brown": "res://assets/sprites/room_items/mobile/carrier_mobile_brown.png",
	"d_carrier_mobile_brown": "res://assets/sprites/room_items/mobile/carrier_mobile_brown.png",
	"d_carrier_mobile_purple": "res://assets/sprites/room_items/mobile/carrier_mobile_purple.png",
	"d_cushion_bed": "res://assets/sprites/room_items/cushion_bed.png",
	"d_cushion_bed_blue": "res://assets/sprites/room_items/cushion_bed_blue.png",
	"d_cushion_bed_green": "res://assets/sprites/room_items/cushion_bed_green.png",
	"d_cat_bed_pink": "res://assets/sprites/room_items/cat_bed_pink_iso.png",
	"d_single_home": "res://assets/sprites/room_items/single_cat_home.png",
	"d_bookshelf": "res://assets/sprites/room_items/bookshelf.png",
	"d_scratch_post": "res://assets/sprites/room_items/scratch_post.png",
	"d_cat_ladder": "res://assets/sprites/room_items/cat_gym_ladder.png",
	"d_potted_monstera": "res://assets/sprites/room_items/potted_monstera.png",
	"d_bonsai_pot": "res://assets/sprites/room_items/bonsai_pot.png",
	"d_potted_ficus_blue": "res://assets/sprites/room_items/potted_ficus_blue.png",
	"d_potted_plant": "res://assets/sprites/room_items/potted_plant.png",
	"d_rug_boho": "res://assets/sprites/room_items/rug_boho.png",
	"d_wall_art": "res://assets/sprites/room_items/wall_art.png",
	"d_wall_cactus": "res://assets/sprites/room_items/wall_cactus_poster.png",
	"d_window_curtains": "res://assets/sprites/room_items/window_curtains.png",
	"d_food_bowl_clean": "res://assets/sprites/room_items/food_bowl_clean.png",
	"d_water_bowl_clean": "res://assets/sprites/room_items/water_bowl_clean.png",
	"d_dual_bowl": "res://assets/sprites/room_items/dual_bowl_pair.png",
	"d_water_fountain": "res://assets/sprites/room_items/water_fountain.png",
	"d_litter_box": "res://assets/sprites/room_items/litter_box.png",
	"d_cat_food_bag": "res://assets/sprites/room_items/cat_food_bag.png",
	"d_toy_yarn_ball": "res://assets/sprites/room_items/toy_yarn_ball.png",
	"d_insulation_curtain": "res://assets/sprites/room_items/window_curtains.png",
	"d_mini_fan": "res://assets/sprites/room_items/single_cat_home.png",
}

const FOOD_SPRITE_PATHS = {
	"f_kibble_salmon": "res://assets/sprites/room_items/cat_food_bag.png",
	"f_kibble_chicken": "res://assets/sprites/room_items/cat_food_bag.png",
	"f_pate_tuna": "res://assets/sprites/room_items/cat_food_bag.png",
	"f_pate_beef": "res://assets/sprites/room_items/cat_food_bag.png",
	"f_treat_churu": "res://assets/sprites/room_items/cat_food_bag.png",
	"f_treat_freeze_dry": "res://assets/sprites/room_items/cat_food_bag.png",
	"f_catnip_grass": "res://assets/sprites/room_items/cat_food_bag.png",
	"f_catnip_ball": "res://assets/sprites/room_items/cat_food_bag.png",
}

const TOY_SPRITE_PATHS = {
	"t_ball_rainbow": "res://assets/sprites/room_items/toy_yarn_ball.png",
	"t_ball_bell": "res://assets/sprites/room_items/toy_yarn_ball.png",
	"t_yarn_ball": "res://assets/sprites/room_items/toy_yarn_ball.png",
	"t_wand_feather": "res://assets/sprites/room_items/toy_yarn_ball.png",
	"t_wand_mouse": "res://assets/sprites/room_items/toy_yarn_ball.png",
	"t_scratch_post": "res://assets/sprites/room_items/mobile/scratching_post_mobile.png",
	"t_scratch_mushroom": "res://assets/sprites/room_items/mobile/scratching_post_mobile.png",
	"t_box_mochi": "res://assets/sprites/room_items/mobile/box_mobile.png",
	"t_tunnel_spring": "res://assets/sprites/room_items/mobile/carrier_mobile_purple.png",
}

func get_costume_sprite_path(costume_id: String) -> String:
	return COSTUME_SPRITE_PATHS.get(costume_id, "")

func get_furniture_sprite_path(furniture_id: String) -> String:
	return FURNITURE_SPRITE_PATHS.get(furniture_id, "")

func get_food_sprite_path(food_id: String = "") -> String:
	return FOOD_SPRITE_PATHS.get(food_id, "res://assets/sprites/room_items/cat_food_bag.png")

func get_toy_sprite_path(toy_id: String = "") -> String:
	return TOY_SPRITE_PATHS.get(toy_id, "res://assets/sprites/room_items/toy_yarn_ball.png")

func get_item_sprite_path(item_id: String) -> String:
	if COSTUME_SPRITE_PATHS.has(item_id):
		return COSTUME_SPRITE_PATHS[item_id]
	if FURNITURE_SPRITE_PATHS.has(item_id):
		return FURNITURE_SPRITE_PATHS[item_id]
	if FOOD_SPRITE_PATHS.has(item_id):
		return FOOD_SPRITE_PATHS[item_id]
	if TOY_SPRITE_PATHS.has(item_id):
		return TOY_SPRITE_PATHS[item_id]
	if item_id.begins_with("f_"):
		return "res://assets/sprites/room_items/cat_food_bag.png"
	if item_id.begins_with("t_"):
		return "res://assets/sprites/room_items/toy_yarn_ball.png"
	return ""

func get_minigame_data(lesson_id: int) -> Dictionary:
	return minigames_data.get(str(lesson_id), {})

func has_minigame(lesson_id: int) -> bool:
	return minigames_data.has(str(lesson_id))

const SAVE_SALT = "BestSen_CatLifeQuest_v43_2026_SecureKey"
const BEST_SEN_SAVE_PATH: String = "user://best_sen_data.save"
const BEST_SEN_TMP_PATH: String = "user://best_sen_data.tmp"
const SAVE_CRYPTO_KEY: String = "BestSen_AES256_ToffeeCraft_2026_Key!"

var _aes_key_cache: PackedByteArray = PackedByteArray()

var saved_audio_settings: Dictionary = {
	"master_volume": 1.0,
	"sfx_volume": 1.0,
	"bgm_volume": 0.8,
	"bgm_enabled": true,
	"sfx_enabled": true,
	"haptic_enabled": true
}
var last_save_duration_usec: int = 0
var last_encrypted_write_usec: int = 0
var last_save_loaded_source: String = "default"
var was_migrated_from_legacy: bool = false

func _get_aes_key_bytes() -> PackedByteArray:
	if _aes_key_cache.size() != 32:
		# SHA-256 chuẩn 32 byte cho AES-256 (không lặp PBKDF2 gây trễ I/O mỗi lần save)
		_aes_key_cache = SAVE_CRYPTO_KEY.sha256_buffer()
	return _aes_key_cache

func _calculate_save_checksum(json_str: String) -> String:
	return (json_str + SAVE_SALT).sha256_text()

## Tiến tới ngày tiếp theo trong chu kỳ sinh hoạt sinh viên
func advance_day() -> void:
	current_day += 1
	daily_relief_sent = 0
	daily_relief_received = 0
	
	# Đếm ngược ngày đóng tiền trọ
	days_until_rent_due = maxi(0, days_until_rent_due - 1)
	if days_until_rent_due == 0:
		if is_rent_paid_this_month:
			days_until_rent_due = 30
			is_rent_paid_this_month = false
			emit_signal("show_toast", "🗓️ Bắt đầu tháng mới! Chu kỳ sinh hoạt 30 ngày tiếp theo.")
		else:
			emit_signal("show_toast", "⚠️ HÔM NAY ĐẾN HẠN ĐÓNG TIỀN TRỌ! Hãy gom đủ %s nhé!" % format_currency(get_total_monthly_expenses()))
	elif days_until_rent_due == 3 and not is_rent_paid_this_month:
		emit_signal("show_toast", "⏰ Còn 3 ngày nữa đến hạn đóng tiền KTX/phòng trọ! Hãy chú ý ngân sách!")

	# Kiểm tra trạng thái nợ ví trả sau (BNPL)
	check_debt_status()
	
	save_game()
	save_room_state()
	emit_signal("stats_changed")

func build_player_profile() -> Dictionary:
	return {
		"schema_version": 3,
		"identity": {
			"owner_name": owner_name,
			"custom_cat_name": custom_cat_name,
			"selected_avatar_id": selected_avatar_id,
			"selected_avatar_frame": selected_avatar_frame
		},
		"stats": {
			"fish": fish,
			"hunger": hunger,
			"courage": courage,
			"mood": mood,
			"cat_mastery_level": cat_mastery_level,
			"cat_mastery_exp": cat_mastery_exp,
			"current_day": current_day,
			"streak_days": current_day
		},
		"progress": {
			"unlocked_lessons": unlocked_lessons,
			"completed_lessons": completed_lessons,
			"badges": badges,
			"claimed_certificates": claimed_certificates
		},
		"room": {
			"custom_room_name": custom_room_name,
			"selected_classic_bg_id": selected_classic_bg_id,
			"placed_room_decor": placed_room_decor,
			"room_upgrades": room_upgrades,
			"furniture_grid_positions": furniture_grid_positions
		},
		"audio_settings": saved_audio_settings.duplicate(true)
	}

func _sync_audio_settings_from_sound_manager() -> void:
	var sm := get_node_or_null("/root/SoundManager")
	if sm:
		saved_audio_settings = {
			"master_volume": sm.master_volume,
			"sfx_volume": sm.sfx_volume,
			"bgm_volume": sm.bgm_volume,
			"bgm_enabled": sm.bgm_enabled if "bgm_enabled" in sm else true,
			"sfx_enabled": sm.sfx_enabled if "sfx_enabled" in sm else true,
			"haptic_enabled": sm.haptic_enabled
		}

func _apply_audio_settings_to_sound_manager() -> void:
	var sm := get_node_or_null("/root/SoundManager")
	if not sm:
		return
	if sm.has_method("set_master_volume"):
		sm.set_master_volume(float(saved_audio_settings.get("master_volume", 1.0)))
	if sm.has_method("set_sfx_volume"):
		sm.set_sfx_volume(float(saved_audio_settings.get("sfx_volume", 1.0)))
	if sm.has_method("set_bgm_volume"):
		sm.set_bgm_volume(float(saved_audio_settings.get("bgm_volume", 0.8)))
	if sm.has_method("set_bgm_enabled"):
		sm.set_bgm_enabled(bool(saved_audio_settings.get("bgm_enabled", true)))
	if sm.has_method("set_sfx_enabled"):
		sm.set_sfx_enabled(bool(saved_audio_settings.get("sfx_enabled", true)))
	if sm.has_method("set_haptic_enabled"):
		sm.set_haptic_enabled(bool(saved_audio_settings.get("haptic_enabled", true)))

func _build_save_dict() -> Dictionary:
	_sync_audio_settings_from_sound_manager()
	return {
		"fish": fish,
		"hunger": hunger,
		"courage": courage,
		"mood": mood,
		"selected_avatar_id": selected_avatar_id,
		"current_day": current_day,
		"unlocked_lessons": unlocked_lessons,
		"completed_lessons": completed_lessons,
		"loot_collection": loot_collection,
		"badges": badges,
		"debt_amount": debt_amount,
		"debt_due_day": debt_due_day,
		"cat_mastery_level": cat_mastery_level,
		"cat_mastery_exp": cat_mastery_exp,
		"inventory_decor": inventory_decor,
		"inventory_costumes": inventory_costumes,
		"inventory_toys": inventory_toys,
		"inventory_food": inventory_food,
		"food_inventory": food_inventory,
		"equipped_costume": equipped_costume,
		"equipped_costumes": equipped_costumes,
		"equipped_decor": equipped_decor,
		"custom_room_name": custom_room_name,
		"custom_cat_name": custom_cat_name,
		"owner_name": owner_name,
		"has_completed_onboarding": has_completed_onboarding,
		"claimed_certificates": claimed_certificates,
		"daily_relief_sent": daily_relief_sent,
		"daily_relief_received": daily_relief_received,
		"monthly_rent_cost": monthly_rent_cost,
		"monthly_utility_cost": monthly_utility_cost,
		"monthly_cat_food_cost": monthly_cat_food_cost,
		"days_until_rent_due": days_until_rent_due,
		"is_rent_paid_this_month": is_rent_paid_this_month,
		"selected_avatar_frame": selected_avatar_frame,
		"selected_classic_bg_id": selected_classic_bg_id,
		"placed_room_decor": placed_room_decor,
		"room_upgrades": room_upgrades,
		"furniture_grid_positions": furniture_grid_positions,
		"food_bowl_servings": food_bowl_servings,
		"audio_settings": saved_audio_settings.duplicate(true),
		"last_active_unix": int(Time.get_unix_time_from_system())
	}

func _write_encrypted_atomic_save(save_dict: Dictionary, cached_payload_json: String = "") -> bool:
	var t0 := Time.get_ticks_usec()
	var payload_json := cached_payload_json if cached_payload_json != "" else JSON.stringify(save_dict)
	var wire_text := "BS3|%s|%s" % [payload_json.md5_text(), payload_json]
	var tmp_file := FileAccess.open_encrypted(BEST_SEN_TMP_PATH, FileAccess.WRITE, _get_aes_key_bytes())
	if not tmp_file:
		return false
	tmp_file.store_string(wire_text)
	tmp_file.close()

	var abs_tmp := ProjectSettings.globalize_path(BEST_SEN_TMP_PATH)
	var abs_dst := ProjectSettings.globalize_path(BEST_SEN_SAVE_PATH)
	var rename_err := DirAccess.rename_absolute(abs_tmp, abs_dst)
	if rename_err != OK:
		if FileAccess.file_exists(BEST_SEN_SAVE_PATH):
			DirAccess.remove_absolute(abs_dst)
		rename_err = DirAccess.rename_absolute(abs_tmp, abs_dst)
	last_encrypted_write_usec = Time.get_ticks_usec() - t0
	return rename_err == OK

func _try_load_encrypted_save(path: String = BEST_SEN_SAVE_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	# Kiểm tra nhanh 4 byte header GDEC trước khi mở AES để tránh báo lỗi C++ khi file hỏng
	var peek := FileAccess.open(path, FileAccess.READ)
	if not peek or peek.get_length() < 16:
		return {}
	var magic := peek.get_buffer(4)
	peek.close()
	if magic != PackedByteArray([0x47, 0x44, 0x45, 0x43]):
		return {}

	var enc_file := FileAccess.open_encrypted(path, FileAccess.READ, _get_aes_key_bytes())
	if not enc_file:
		return {}
	var raw_text := enc_file.get_as_text()
	enc_file.close()
	if not raw_text.begins_with("BS3|"):
		return {}
	var parts := raw_text.split("|", true, 2)
	if parts.size() != 3:
		return {}
	var expected_md5 := parts[1]
	var payload_json := parts[2]
	if payload_json.md5_text() != expected_md5:
		printerr("CẢNH BÁO SYS-01: MD5 không khớp trong %s! Từ chối dữ liệu lỗi." % path)
		return {}
	var data = JSON.parse_string(payload_json)
	return data if data is Dictionary else {}

func is_encrypted_save_valid(path: String = BEST_SEN_SAVE_PATH) -> bool:
	return not _try_load_encrypted_save(path).is_empty()

func save_game() -> void:
	var t0_usec: int = Time.get_ticks_usec()
	var save_dict := _build_save_dict()
	var raw_json := JSON.stringify(save_dict)

	# 1. Ghi file mã hóa AES-256 + MD5 nguyên tử (.tmp -> rename -> best_sen_data.save)
	_write_encrypted_atomic_save(save_dict, raw_json)

	# 2. Duy trì bản sao lưu dự phòng (.bak) & Envelope v2 SHA-256 (tương thích ngược)
	if FileAccess.file_exists("user://save_game.json"):
		var read_src = FileAccess.open("user://save_game.json", FileAccess.READ)
		if read_src:
			var prev_content = read_src.get_as_text()
			var backup_file = FileAccess.open("user://save_game.bak", FileAccess.WRITE)
			if backup_file:
				backup_file.store_string(prev_content)

	var envelope = {
		"version": 2,
		"timestamp": Time.get_unix_time_from_system(),
		"checksum": _calculate_save_checksum(raw_json),
		"data": save_dict
	}

	var file = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(envelope))
	last_save_duration_usec = Time.get_ticks_usec() - t0_usec

func load_game() -> void:
	was_migrated_from_legacy = false
	var enc_data := _try_load_encrypted_save(BEST_SEN_SAVE_PATH)
	if not enc_data.is_empty():
		last_save_loaded_source = "encrypted_v3"
		_apply_loaded_save_dict(enc_data)
		return

	var target_path = "user://save_game.json"
	if not FileAccess.file_exists(target_path):
		if FileAccess.file_exists("user://save_game.bak"):
			target_path = "user://save_game.bak"
		else:
			return
			
	var file = FileAccess.open(target_path, FileAccess.READ)
	if not file:
		return
		
	var json_str = file.get_as_text()
	var json = JSON.new()
	if json.parse(json_str) != OK:
		# Nếu file chính bị hỏng cú pháp, tự động phục hồi từ backup
		if target_path == "user://save_game.json" and FileAccess.file_exists("user://save_game.bak"):
			var bak_file = FileAccess.open("user://save_game.bak", FileAccess.READ)
			if bak_file and json.parse(bak_file.get_as_text()) == OK:
				print("Đã tự động khôi phục dữ liệu từ user://save_game.bak!")
			else:
				return
		else:
			return
			
	var parsed_data = json.get_data()
	var data: Dictionary = {}
	
	if parsed_data is Dictionary:
		if parsed_data.has("version") and parsed_data.has("data") and parsed_data.has("checksum"):
			# Envelope Version 2: Kiểm tra tính toàn vẹn Checksum
			var inner_data = parsed_data["data"]
			var inner_str = JSON.stringify(inner_data)
			var expected_checksum = _calculate_save_checksum(inner_str)
			if parsed_data["checksum"] == expected_checksum:
				data = inner_data
			else:
				print("CẢNH BÁO: Checksum file save không khớp! Khôi phục từ backup...")
				if FileAccess.file_exists("user://save_game.bak"):
					var bak_file = FileAccess.open("user://save_game.bak", FileAccess.READ)
					var bak_json = JSON.new()
					if bak_file and bak_json.parse(bak_file.get_as_text()) == OK:
						var b_parsed = bak_json.get_data()
						if b_parsed is Dictionary and b_parsed.has("data"):
							data = b_parsed["data"]
						else:
							data = inner_data
					else:
						data = inner_data
				else:
					data = inner_data
		else:
			# Legacy format Version 1
			data = parsed_data

	if data.is_empty():
		return

	_apply_loaded_save_dict(data)
	# Tự động nâng cấp dữ liệu cũ sang định dạng mã hóa AES-256 atomic (SYS-01)
	if _write_encrypted_atomic_save(_build_save_dict()):
		was_migrated_from_legacy = true
		last_save_loaded_source = "legacy_migrated"

func _apply_loaded_save_dict(data: Dictionary) -> void:
	if data.is_empty():
		return

	fish = data.get("fish", 90)
	hunger = clampi(data.get("hunger", 70), 0, 100)
	courage = clampi(data.get("courage", 80), 0, 100)
	mood = clampi(data.get("mood", 85), 0, 100)
	selected_avatar_id = data.get("selected_avatar_id", 0)
	current_day = data.get("current_day", 1)
	unlocked_lessons = data.get("unlocked_lessons", [1])
	completed_lessons = data.get("completed_lessons", [])
	loot_collection = data.get("loot_collection", [])
	badges = data.get("badges", [])
	debt_amount = data.get("debt_amount", 0)
	debt_due_day = data.get("debt_due_day", 0)
	cat_mastery_level = data.get("cat_mastery_level", 1)
	cat_mastery_exp = data.get("cat_mastery_exp", 0)
	inventory_decor = data.get("inventory_decor", ["d_bed_box", "d_bowl_basic"])
	inventory_costumes = data.get("inventory_costumes", ["c_hoodie_student", "c_hat_cap"])
	inventory_toys = data.get("inventory_toys", [])
	inventory_food = data.get("inventory_food", [])
	food_inventory = data.get("food_inventory", {
		"kibble": 5,
		"pate": 2,
		"dry_fish": 3
	})
	equipped_costume = data.get("equipped_costume", "c_hoodie_student")
	equipped_costumes = data.get("equipped_costumes", {
		"clothes": equipped_costume,
		"hats": "c_hat_cap",
		"bows": "",
		"accessories": ""
	})
	if equipped_costumes.get("clothes", "") == "" and equipped_costume != "":
		equipped_costumes["clothes"] = equipped_costume
	var loaded_decor = data.get("equipped_decor", {})
	if not (loaded_decor is Dictionary):
		loaded_decor = {}
	if not loaded_decor.has("beds") or loaded_decor["beds"] == "":
		loaded_decor["beds"] = "d_bed_box"
	if not loaded_decor.has("bowls") or loaded_decor["bowls"] == "":
		loaded_decor["bowls"] = "d_bowl_basic"
	if not loaded_decor.has("rugs"):
		loaded_decor["rugs"] = ""
	if not loaded_decor.has("wall"):
		loaded_decor["wall"] = ""
	if not loaded_decor.has("plants"):
		loaded_decor["plants"] = ""
	equipped_decor = loaded_decor
	custom_room_name = data.get("custom_room_name", "")
	custom_cat_name = data.get("custom_cat_name", "")
	owner_name = data.get("owner_name", "Tân Sinh Viên")
	has_completed_onboarding = data.get("has_completed_onboarding", false)
	claimed_certificates = data.get("claimed_certificates", [])
	daily_relief_sent = data.get("daily_relief_sent", 0)
	daily_relief_received = data.get("daily_relief_received", 0)
	monthly_rent_cost = data.get("monthly_rent_cost", 50)
	monthly_utility_cost = data.get("monthly_utility_cost", 15)
	monthly_cat_food_cost = data.get("monthly_cat_food_cost", 20)
	days_until_rent_due = data.get("days_until_rent_due", 25)
	is_rent_paid_this_month = data.get("is_rent_paid_this_month", false)
	selected_avatar_frame = data.get("selected_avatar_frame", "beige")
	selected_classic_bg_id = data.get("selected_classic_bg_id", 1)
	placed_room_decor = data.get("placed_room_decor", [])
	var loaded_upgrades = data.get("room_upgrades", {})
	if loaded_upgrades is Dictionary:
		room_upgrades["heat_insulation"] = bool(loaded_upgrades.get("heat_insulation", false)) or ("d_insulation_curtain" in inventory_decor)
		room_upgrades["mini_fan"] = bool(loaded_upgrades.get("mini_fan", false)) or ("d_mini_fan" in inventory_decor)
	var loaded_grid_pos = data.get("furniture_grid_positions", {})
	if loaded_grid_pos is Dictionary:
		furniture_grid_positions = loaded_grid_pos
	food_bowl_servings = maxi(0, int(data.get("food_bowl_servings", 0)))
	var loaded_audio = data.get("audio_settings", {})
	if loaded_audio is Dictionary and not loaded_audio.is_empty():
		saved_audio_settings["master_volume"] = float(loaded_audio.get("master_volume", saved_audio_settings["master_volume"]))
		saved_audio_settings["sfx_volume"] = float(loaded_audio.get("sfx_volume", saved_audio_settings["sfx_volume"]))
		saved_audio_settings["bgm_volume"] = float(loaded_audio.get("bgm_volume", saved_audio_settings["bgm_volume"]))
		saved_audio_settings["bgm_enabled"] = bool(loaded_audio.get("bgm_enabled", saved_audio_settings["bgm_enabled"]))
		saved_audio_settings["sfx_enabled"] = bool(loaded_audio.get("sfx_enabled", saved_audio_settings["sfx_enabled"]))
		saved_audio_settings["haptic_enabled"] = bool(loaded_audio.get("haptic_enabled", saved_audio_settings["haptic_enabled"]))
		_apply_audio_settings_to_sound_manager()
	last_active_unix = int(data.get("last_active_unix", 0))
	if last_active_unix > 0:
		var now_unix: int = int(Time.get_unix_time_from_system())
		var away_sec: float = float(now_unix - last_active_unix)
		if away_sec >= 60.0:
			apply_offline_hunger_decay(away_sec, true)
		last_active_unix = now_unix

func reset_save_data() -> void:
	fish = 90
	hunger = 70
	courage = 80
	mood = 85
	selected_avatar_id = 0
	selected_avatar_frame = "beige"
	selected_classic_bg_id = 1
	placed_room_decor = []
	room_upgrades = {"heat_insulation": false, "mini_fan": false}
	furniture_grid_positions = {}
	food_bowl_servings = 0
	is_offline_auto_sleeping = false
	last_offline_summary = {}
	last_active_unix = int(Time.get_unix_time_from_system())
	custom_cat_name = ""
	owner_name = "Tân Sinh Viên"
	custom_room_name = ""
	has_completed_onboarding = false
	claimed_certificates = []
	current_day = 1
	unlocked_lessons = [1]
	completed_lessons = []
	loot_collection = []
	badges = []
	debt_amount = 0
	debt_due_day = 0
	cat_mastery_level = 1
	cat_mastery_exp = 0
	inventory_decor = ["d_bed_box", "d_bowl_basic"]
	inventory_costumes = ["c_hoodie_student", "c_hat_cap"]
	inventory_toys = []
	inventory_food = []
	food_inventory = {
		"kibble": 5,
		"pate": 2,
		"dry_fish": 3
	}
	equipped_costume = "c_hoodie_student"
	equipped_costumes = {
		"clothes": "c_hoodie_student",
		"hats": "c_hat_cap",
		"bows": "",
		"accessories": ""
	}
	equipped_decor = {
		"beds": "d_bed_box",
		"bowls": "d_bowl_basic",
		"rugs": "",
		"wall": "",
		"plants": ""
	}
	days_until_rent_due = 25
	is_rent_paid_this_month = false
	daily_relief_sent = 0
	daily_relief_received = 0
	is_fainted = false
	is_shy = false
	save_game()
	save_room_state()
	emit_signal("stats_changed")
	emit_signal("avatar_changed", 0)
	emit_signal("room_name_changed", get_room_name())
