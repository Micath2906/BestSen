const fs = require('fs');
const path = './assets/data/minigames_data.json';

const data = JSON.parse(fs.readFileSync(path, 'utf8'));

// Lưu QTE từ key 7 sang key 12
if (data.minigames['7']) {
  data.minigames['12'] = JSON.parse(JSON.stringify(data.minigames['7']));
  data.minigames['12'].lesson_id = 12;
}

// Cập nhật key 10: bhyt_process
data.minigames['10'] = {
  "type": "bhyt_process",
  "lesson_id": 10,
  "title": "Khám BHYT đúng tuyến từng bước & Chuẩn bị hồ sơ",
  "subtitle": "Kỹ năng: Chuẩn bị 4 giấy tờ BHYT cốt lõi & Quy trình 6 bước tại bệnh viện",
  "instruction": "Giai đoạn 1: Chuẩn bị đủ 4 giấy tờ BHYT vào Túi hồ sơ. Giai đoạn 2: Kéo thả đi khám 6 chặng đúng quy trình!",
  "cat_prompt": "Đi khám BHYT lúc 7h sáng cần mang đúng 4 giấy tờ cốt lõi và tuân thủ quy trình 6 chặng để hưởng 80-100% viện phí nhé Sen!",
  "success_msg": "🎉 Xuất sắc! Mèo con đã hoàn tất thủ tục khám BHYT đúng tuyến, được thanh toán viện phí đầy đủ và nhận thuốc an toàn!",
  "sim_steps": [
    { "icon": "🪪", "text": "Chuẩn bị 4 giấy tờ cốt lõi BHYT" },
    { "icon": "🎟️", "text": "Bốc số thứ tự & Đăng ký phòng khám" },
    { "icon": "🩺", "text": "Bác sĩ khám lâm sàng & Xét nghiệm" },
    { "icon": "💊", "text": "Đọc kết quả & Lấy thuốc quầy BHYT" }
  ]
};

// Cập nhật key 5: rental_contract
data.minigames['5'] = {
  "type": "rental_contract",
  "lesson_id": 5,
  "title": "Hiểu biết pháp luật cơ bản về Hợp đồng thuê nhà",
  "subtitle": "Kỹ năng: Nhận diện vi phạm hợp đồng thuê nhà & Quy trình 4 bước ký kết an toàn",
  "instruction": "Game 1: Nối tình huống vi phạm với giải pháp đúng. Game 2: Sắp xếp thứ tự 4 bước ký hợp đồng thuê trọ an toàn!",
  "cat_prompt": "Meo meo! Hãy nối các tình huống vi phạm với giải pháp pháp lý đúng, sau đó sắp xếp quy trình ký kết hợp đồng an toàn nhé Sen!",
  "success_msg": "🎉 Chúc mừng Thám Tử Soi Hợp Đồng! Nắm chắc giải pháp pháp lý và quy trình ký kết an toàn không lo bị lừa cọc!",
  "sim_steps": [
    { "icon": "🔍", "text": "Xác minh giấy tờ chủ sở hữu nhà" },
    { "icon": "📑", "text": "Đọc thỏa thuận cọc, điện nước" },
    { "icon": "✍️", "text": "Ký hợp đồng & lập biên bản bàn giao" },
    { "icon": "🪪", "text": "Đăng ký tạm trú đúng luật" }
  ]
};

// Cập nhật key 15: labor_rights
data.minigames['15'] = {
  "type": "labor_rights",
  "lesson_id": 15,
  "title": "Quyền lao động và Hợp đồng lao động cho người trẻ",
  "subtitle": "Kỹ năng: Nắm chắc thời hạn thử việc, mức lương & Phân loại hành vi đúng luật vs vi phạm",
  "instruction": "Game 1: Nối chế định pháp lý với con số / thời hạn. Game 2: Phân loại tình huống vào 2 nhóm Đúng luật vs Vi phạm!",
  "cat_prompt": "Meo meo! Hãy ghi nhớ các mốc thời gian luật định và phân loại các chiêu trò bóc lột của chủ việc làm nhé!",
  "success_msg": "🎉 Chúc mừng Người Lao Động Thông Thái! Nắm vững Bộ luật Lao động, tự tin đi làm thêm part-time không sợ bị ép lương!",
  "sim_steps": [
    { "icon": "⏳", "text": "Thử việc đúng thời hạn & 85% lương" },
    { "icon": "🪪", "text": "Không để NSDLĐ giữ bản gốc CCCD/Bằng" },
    { "icon": "📈", "text": "Hưởng đúng lương thêm giờ Lễ Tết 300%" },
    { "icon": "🛡️", "text": "Đóng BHXH, BHYT từ 1 tháng hợp đồng" }
  ]
};

// Cập nhật key 14: cyber_security
data.minigames['14'] = {
  "type": "cyber_security",
  "lesson_id": 14,
  "title": "Luật An ninh mạng & Bảo vệ dữ liệu cá nhân",
  "subtitle": "Kỹ năng: Nhận diện chế tài xử lý vi phạm mạng & Trắc nghiệm Đúng/Sai bảo mật thông tin",
  "instruction": "Game 1: Nối hành vi vi phạm với hình thức xử lý. Game 2: Trả lời 4 câu trắc nghiệm Đúng/Sai an toàn số!",
  "cat_prompt": "Meo meo! Cùng Mèo tìm hiểu các chế tài An ninh mạng và rèn luyện kỹ năng nhận diện lừa đảo trên mạng xã hội nhé!",
  "success_msg": "🎉 Xuất sắc! Bạn đã sở hữu 'Lá Chắn An Ninh Mạng', làm chủ không gian mạng an toàn và đúng pháp luật!",
  "sim_steps": [
    { "icon": "🛡️", "text": "Bảo vệ thông tin CCCD & dữ liệu số" },
    { "icon": "🔑", "text": "Bật xác thực 2FA & giữ bí mật OTP" },
    { "icon": "🌐", "text": "Soi kỹ tên miền web ngân hàng chính thức" },
    { "icon": "⚖️", "text": "Tuân thủ nghiêm Luật An ninh mạng" }
  ]
};

// Cập nhật key 4: traffic_safety
data.minigames['4'] = {
  "type": "traffic_safety",
  "lesson_id": 4,
  "title": "An toàn giao thông & Xử lý vi phạm hành chính",
  "subtitle": "Kỹ năng: Mức xử phạt vi phạm giao thông & Quy trình 4 bước ứng phó va chạm văn minh",
  "instruction": "Game 1: Nối lỗi vi phạm giao thông với mức xử phạt. Game 2: Sắp xếp 4 bước xử lý khi xảy ra va chạm nhẹ!",
  "cat_prompt": "Meo meo! Tham gia giao thông an toàn, thuộc lòng mức phạt và cách ứng phó va chạm văn minh trên đường nhé!",
  "success_msg": "🎉 Tuyệt vời! Bạn đã trở thành 'Hiệp Sĩ Giao Thông', nắm rõ luật đi đường và xử lý va chạm chuẩn mực!",
  "sim_steps": [
    { "icon": "🛑", "text": "Dừng xe giữ hiện trường & bật đèn" },
    { "icon": "🩺", "text": "Hỏi thăm sức khỏe & sơ cứu" },
    { "icon": "📸", "text": "Chụp ảnh quay video bằng chứng" },
    { "icon": "🤝", "text": "Hòa giải văn minh hoặc gọi CSGT 113" }
  ]
};

// Cập nhật key 7: public_admin
data.minigames['7'] = {
  "type": "public_admin",
  "lesson_id": 7,
  "title": "Nhận biết thủ tục Hành chính công cơ bản",
  "subtitle": "Kỹ năng: Phân định thẩm quyền cơ quan hành chính & Quy trình 4 bước nộp hồ sơ qua VNeID",
  "instruction": "Game 1: Nối thủ tục giấy tờ với cơ quan thẩm quyền. Game 2: Sắp xếp 4 bước nộp hồ sơ DVC trực tuyến!",
  "cat_prompt": "Meo meo! Cùng Mèo khám phá cách giải quyết thủ tục hành chính công trực tuyến nhanh gọn qua VNeID nhé!",
  "success_msg": "🎉 Chúc mừng Công Dân Số 4.0! Thành thạo nộp hồ sơ trực tuyến, làm thủ tục tạm trú và giấy tờ cá nhân chuẩn xác!",
  "sim_steps": [
    { "icon": "🪪", "text": "Đăng nhập VNeID Mức 2" },
    { "icon": "🔍", "text": "Chọn thủ tục & điền biểu mẫu" },
    { "icon": "📎", "text": "Đính kèm giấy tờ thuê nhà hợp lệ" },
    { "icon": "📑", "text": "Nộp hồ sơ & nhận kết quả online" }
  ]
};

fs.writeFileSync(path, JSON.stringify(data, null, 2), 'utf8');
console.log('Successfully updated minigames_data.json!');
