# 🐾 MÈO TỰ LẬP (CAT'S LIFE QUEST) - BESTSEN
> **Dự án App Game Độc Lập Hoàn Toàn (Standalone App) Trên Godot Engine 4.3**  
> *Đã tạo sẵn Shortcut chạy game trực tiếp 1-click ngoài Desktop!*

---

## ⚡ 1. KHỞI ĐỘNG NHANH 1-CLICK TỪ MÀN HÌNH CHÍNH (DESKTOP)

Đã tạo sẵn biểu tượng Shortcut ngoài màn hình Desktop của bạn:
- **Tên biểu tượng:** `Mèo Tự Lập - BestSen`
- **Icon:** Chú mèo pixel đội nón cử nhân tự lập xịn sò.
- **Thao tác:** Chỉ cần **nhấp đúp chuột vào biểu tượng ngoài Desktop**, game Godot sẽ khởi chạy trực tiếp ngay lập tức dưới dạng một App độc lập (không cần mở qua trình duyệt web hay editor)!

---

## 📱 2. ĐỊNH HƯỚNG PHÁT HÀNH: STANDALONE NATIVE APP

Đây là **Ứng Dụng Game Độc Lập Hoàn Toàn (Native Mobile App)**, người dùng có thể tìm kiếm và cài đặt trực tiếp từ:
- 🛒 **Google Play Store (CH Play):** Gói cài đặt `.aab` / `.apk` chuẩn quy định của Google (`com.bestsen.catlifequest`).
- 🍏 **Apple App Store:** Dự án Xcode Archive hỗ trợ trọn vẹn cả iPhone và iPad.
- 🚫 **Hoàn toàn KHÔNG phụ thuộc:** Không phải là Web View hay Mini App tích hợp trong Zalo hay bất kỳ mạng xã hội nào. App có thể hoạt động ngoại tuyến (Offline-First) 100%.

👉 **Xem hướng dẫn chi tiết quy trình đăng ký tài khoản dev và đưa app lên Store:** [`MOBILE_PUBLISHING_GUIDE.md`](file:///d:/BestSen/MOBILE_PUBLISHING_GUIDE.md)  
👉 **Mẫu chính sách bảo mật bắt buộc của Google/Apple:** [`PRIVACY_POLICY.md`](file:///d:/BestSen/PRIVACY_POLICY.md)

- **Thể loại:** Cozy Life-Sim / Resource Management kết hợp Sequence Logic Puzzle.
- **Phong cách mỹ thuật:** 2D Flat Doodle / Retro Pixel Cozy aesthetic (tối giản, ấm cúng, biểu cảm tự trào hóm hỉnh).
- **Nền tảng hỗ trợ:** Multi-platform (Mobile Android/iOS, Web Mobile Responsive, Zalo Mini App, PC Windows).
- **Triết lý cốt lõi (Ego-Swapping & Safe Failure):**
  - **Hoán đổi bản ngã (Ego-Swapping):** Người chơi không bị "lên lớp dạy đời" như một sinh viên thiếu kinh nghiệm, mà đóng vai một **"Sen bảo hộ"** chăm lo và truyền thụ kỹ năng cho chú mèo con ngơ ngác mới từ quê lên phố.
  - **Thử sai an toàn (Safe Failure):** Khi xếp sai thứ tự các bước thực tế (ví dụ: bấm chuông khi chưa lên xe buýt, hoặc uống thuốc hạ sốt trước khi đo nhiệt độ), Mèo chỉ bị "quê độ" chạy về phòng trọ và tụt nhẹ 10 điểm dũng cảm. Game hoàn toàn không phán xét, không trừng phạt nặng nề, giúp người chơi tự tin sửa sai và ghi nhớ kiến thức sâu sắc.

---

## 🎮 3. TÍNH NĂNG TƯƠNG TÁC THÚ ẢO & CĂN PHÒNG KHỞI ĐẦU

### 🏠 Căn Phòng Khởi Đầu Tự Lập True 2.5D Isometric (Starter Dimetric Room):
Đúng chuẩn góc nhìn 2.5D Isometric Top-Down Dimetric (tỷ lệ 2:1), không dùng 2D Flat phẳng bệt:
- **Mặt sàn hình thoi khép kín 8x8 ô lưới:** Lát gỗ parquet xen kẽ hai tông màu ấm `#EDE0CE` và `#DFD0BC`, có viền bo chân tường và đổ bóng chiều sâu 3D 14px.
- **Tường hậu Tây Bắc & Đông Bắc:** Cao 175px với **Cửa chính phòng trọ P.102 🐾** và **Cửa sổ đón nắng** có rèm pastel cùng vệt nắng chiếu nghiêng qua sàn nhà.
- **4 Đồ nội thất tương tác Isometric:**
  - 🛋️ **Đệm ngủ sinh viên:** Chạm vào để Mèo đi đến cuộn tròn ngủ nướng (`STATE_SLEEP`), phát tiếng `Zzz`.
  - 🥣 **Khay ăn & nước 2 ngăn:** Đế gỗ dimetric nâng đỡ bát Hạt sinh viên và bát Nước mát giải nhiệt.
  - 🪵 **Cây cào móng mèo:** Trụ gỗ quấn dây thừng sisal với chóp nỉ và lục lạc treo lơ lửng (`+10 Dũng | +15 Mood`).
  - 📦 **Hộp Carton mở nắp:** Nơi chú mèo phóng vào trốn tìm (`STATE_BOX`).
  - 🪴 **Vị trí Decor Gacha:** Trưng bày chậu cây trầu bà, đèn vintage nhận được từ Loot Box.
- **Mèo 4 chân Isometric có bóng đổ động:** Tự do di chuyển 8 hướng trong phòng, bóng đổ co giãn theo độ cao nhảy, và chạy lon ton vồ lấy cuộn len khi chạm sàn!

### 🐾 Tương Tác Xúc Giác & Thanh Dock Tinh Gọn:
- **Vuốt ve đầu / tai (Head Petting):** Mèo lim dim mắt, phát tiếng kêu gừ gừ (`Purr purr`), tim bay phấp phới `💖 +2 Dũng cảm`.
- **Chọc bụng / Cù lét (Belly Poke):** Mèo nảy lên co giãn (Squish & Squash bounce), phát ra tiếng cười khúc khích `😹 Hi hi!`.
- **Chọc chân / Kéo đuôi (Feet Poke):** Mèo nhảy tưng tưng (`✨ Boing!`) né đòn nghịch ngợm của Sen.
- **Thanh Công Cụ Dock 6 nút bàn chân mèo chuẩn tính năng**:
  - `🏠 Phòng Trọ`: Quay về căn phòng trọ ấm cúng từ bất kỳ đâu.
  - `🍗 Cho Ăn`: Khay ăn uống gồm Hạt sinh viên, Pate thượng hạng, Nước sạch, Cá khô quê gửi.
  - `🧶 Đồ Chơi`: Khay đồ chơi gồm Hộp carton, Cần câu lông, Gãi cằm, Ví trả sau BNPL.
  - `🎓 Kỹ Năng`: Mở cây 16 bài học kỹ năng sống sinh tồn 4 nhánh.
  - `📖 Cẩm Nang`: Sổ tay sinh tồn cấp cứu 24/7 tra cứu khẩn cấp ngoài đời.
  - `🏆 Chiến Tích`: Bộ sưu tập 16 chiến lợi phẩm và huy hiệu quê xệ.
- **Bảng Thông Tin Mèo Trên Cùng Với Tên Đầy Đủ**:
  - `🍗 Độ No`: Thanh thể lực (70/100)
  - `💖 Dũng Cảm`: Thanh bản lĩnh (80/100)
  - `✨ Tâm Trạng`: Thanh tinh thần vui vẻ (85/100)
  - `🐟 Cá Khô`: Số dư tiền tệ sinh viên (90 Cá Khô)
- **Đổi Avatar Trực Tiếp Trên HUD**: Bấm vào khung avatar có tai mèo ở góc trên cùng để chọn 1 trong 8 avatar chú mèo pixel đáng yêu.

---

## 📊 4. HỆ THỐNG CHỈ SỐ SINH TỒN & TÂM TRẠNG & BẢNG ĐÁNH ĐỔI (TRADE-OFFS)

| Chỉ số | Phạm vi | Ý nghĩa trong game | Cơ chế cân bằng |
| :--- | :---: | :--- | :--- |
| **🐟 Cá Khô** | 0 - ∞ (Gốc 90) | Ngân sách sinh hoạt tháng (90 Cá / 30 ngày = 3 Cá/ngày) | Dùng mua thức ăn, đồ chơi, chữa bệnh. Thâm hụt sẽ không thể nuôi mèo. |
| **🍗 Độ No** | 0 - 100 | Thể lực và sức khỏe thể chất | Tiêu hao khi học và sinh hoạt. Nếu `< 20`: Mèo đói lả từ chối học. Nếu `= 0`: Cấp cứu tốn 25 Cá. |
| **💖 Dũng Cảm** | 0 - 100 | Sự tự tin và bản lĩnh xã hội | Tăng khi ăn ngon, chơi vui, vuốt ve. Giảm khi sai sót (-10) hoặc thiếu tiền. Nếu `< 20`: Mèo hoảng sợ không dám ra đường. |
| **✨ Tâm Trạng** | 0 - 100 | Tinh thần vui vẻ, lạc quan của Mèo | Tăng khi được vuốt ve (+5), chọc bụng (+8), đuổi bắt cuộn len (+10), uống nước (+5). Giảm khi bị bỏ rơi hoặc đói lả. |

### Bảng Ma Trận Đánh Đổi (Care & Survival Matrix):
- **🍚 Hạt Sinh Viên:** `-3 Cá`, `+15 Độ No`, `+5 Tâm Trạng` (Ăn chắc mặc bền, bảo toàn ngân sách cả tháng).
- **🥫 Pate Thượng Hạng:** `-18 Cá`, `+35 Độ No`, `+25 Dũng Cảm`, `+20 Tâm Trạng` (Mèo cực kỳ vui vẻ, nhưng tiêu tốn 6 ngày tiền ăn cơ bản).
- **💧 Nước Sạch Mát Lành:** `0 Cá`, `+10 Tâm Trạng`, `+5 Dũng Cảm` (Rót nước giải nhiệt, tỉnh táo).
- **🐟 Cá Khô Quê Gửi:** `0 Cá`, `+20 Độ No`, `+20 Tâm Trạng` (Quà mẹ gửi từ quê ấm áp tình thương).
- **📦 Thùng Carton Tự Chế:** `0 Cá`, `+15 Dũng Cảm`, `+15 Tâm Trạng` (Rèn tính tháo vát, mèo chui tọt vào hộp carton đáng yêu).
- **🪶 Cần Câu Lông Vũ:** `-20 Cá`, `+40 Dũng Cảm`, `+20 Tâm Trạng` (Mèo hưng phấn tột đỉnh, cảnh báo cạn ví cuối tháng).
- **✨ Vuốt Ve Boss:** `0 Cá`, `+5 Dũng Cảm`, `+10 Tâm Trạng`, mèo phát ra tiếng kêu gừ gừ purr purr thư giãn.
- **💳 Ví Trả Sau (BNPL):** `0 Cá` lúc quẹt, `+30 Dũng Cảm` tức thì, nhưng đến hạn ngày 28 sẽ bị phạt trừ nặng `35 Cá Khô`!

---

## 🗺️ 3. HỆ SINH THÁI 16 BÀI HỌC THUỘC 4 NHÁNH SINH TỒN

### 🚗 Nhánh 1: Đường Phố Thổ Địa (Di chuyển & Cơ động)
1. **Bài 1: Bắt xe buýt liên quận** (Vẫy tay 50m -> Tiền lẻ 5k cửa trước -> Ôm ba lô trước ngực -> Bấm chuông 100m).
2. **Bài 2: Đọc BusMap & Đổi tuyến** (Tìm tuyến tối ưu -> Xem mã trạm & giờ đến -> Đến đúng cột trung chuyển -> Trình thẻ sinh viên).
3. **Bài 3: Định vị Google Maps & Thoát bùng binh** (Tấp lề an toàn -> Xoay la bàn -> Đếm số thứ tự lối ra -> Xi-nhan dứt khoát).
4. **Bài 4: Cứu hộ xe máy cơ bản** (Dựng chân chống soi sên/lốp -> Hỏi rõ giá trước -> Kiểm tra nhớt -> Xem tem chính hãng).

### 🏠 Nhánh 2: Bình Yên Xóm Trọ (Pháp lý cư trú & Sinh hoạt)
5. **Bài 5: Soi hợp đồng thuê trọ** (Điều khoản hoàn cọc -> Chốt số điện nước -> Chụp ảnh hiện trạng vết nứt -> Giữ 1 bản gốc).
6. **Bài 6: Khảo sát an toàn PCCC** (Kiểm tra cửa chuồng cọp -> Bình chữa cháy vạch xanh -> Lối thoát sân thượng -> Khăn mặt sẵn).
7. **Bài 7: Đăng ký tạm trú trực tuyến** (Xin CCCD chủ trọ -> Đăng nhập VNeID/DVC -> Nộp mẫu CT01 & hợp đồng -> Nhận CT07).
8. **Bài 8: Hiệp ước bạn cùng phòng** (Họp mặt trà sữa thẳng thắn -> Lịch trực nhật toilet luân phiên -> App chia tiền -> Giờ giới nghiêm).

### 🏥 Nhánh 3: Thân Thể Kim Cương (Y tế & Sức khỏe tự thân)
9. **Bài 9: Hạ sốt 39 độ giữa đêm** (Kẹp nhiệt kế 5 phút -> Uống Paracetamol đúng liều mg/kg -> Lau nước ẤM nách bẹn -> Bù Oresol).
10. **Bài 10: 6 Bước khám BHYT đúng tuyến** (Bốc số BHYT -> Quầy Tiếp nhận CCCD -> Gặp bác sĩ chuyên khoa -> Quầy Dược nhận thuốc).
11. **Bài 11: Xây dựng túi sơ cứu trọ** (Hạ sốt & Nhiệt kế -> Tiêu hóa & Oresol -> Sát trùng & Gạc -> Dán nhãn hạn dùng).
12. **Bài 12: Cứu cái dạ dày sinh viên** (Nhận biết đau thượng vị -> Cai mì tôm sống & nước có ga -> Ăn cháo ấm -> Khám chuyên khoa).

### 💰 Nhánh 4: Túi Tiền Thông Thái (Tài chính & Việc làm thêm)
13. **Bài 13: Phương pháp 3 Hũ Cá** (Chia ngay ngày 1 -> 50% Sống còn -> 30% Phát triển -> 20% Khẩn cấp bất khả xâm phạm).
14. **Bài 14: Bộ lọc bóc trần Đa cấp Ponzi** (Lãi > 15%/năm là lừa -> Không sản phẩm thật -> Cấm nộp cọc -> Rút lui dứt khoát).
15. **Bài 15: Phỏng vấn việc làm Part-time** (Lịch làm không trùng lịch học -> Lương Gross/Net rõ ràng -> Cấm cọc đồng phục & giữ CCCD).
16. **Bài 16: Thoát bẫy Ví trả sau (BNPL)** (Phanh tiêu dùng 48h -> Đọc phí phạt chậm trả -> Không tiền mặt thì không mua -> Tắt ví).

---

## ⚡ 4. VÒNG LẶP GAMEPLAY CỐT LÕI (CORE GAMEPLAY LOOP)

1. **Giai đoạn 1: Dạy học tại phòng (Sequence Puzzle):**
   - Mở **"Cẩm Nang Cứu Sen"** xem tóm tắt quy trình chuẩn đời thực trong 20 giây.
   - Sắp xếp các thẻ bài tiếng Mèo (`Meo-o?`, `Méo meo!`, `Meo-wrr`, `Meoo!!`) vào các ô Bước 1, Bước 2, Bước 3, Bước 4.
2. **Giai đoạn 2: Thả ra ngoài đời (Simulation & Safe Failure):**
   - Nhấn *"Xong rồi, đi đi Boss!"*, Mèo bước ra phố thực hiện các bước.
   - **Nếu ĐÚNG:** Mèo hoàn thành trót lọt, purr purr ăn mừng!
   - **Nếu SAI:** Mèo gặp sự cố dở khóc dở cười ("Quê xệ"), hiển thị thông điệp an ủi không phán xét, cho phép thử lại ngay.
3. **Giai đoạn 3: Thu hoạch phần thưởng:**
   - Nhận Chiến lợi phẩm kẹp trong ba lô (vé xe buýt, thẻ BHYT, bút ký trọ...) lưu vào Bảo Tàng.
   - Thưởng nóng `+25` đến `+35` Cá Khô vào ví.
   - Mở khóa Thẻ Bảo Bối Infographic lưu vào điện thoại.

---

## 🚑 5. CHẾ ĐỘ THƯ VIỆN CỨU NGUY MỞ 24/7 (EMERGENCY SANDBOX)
- Không khóa cấp độ (No level-lock): Cả 16 bài học đều được **mở sẵn 100% tài liệu ngay từ giây đầu tiên**.
- Khi một bạn sinh viên đang đứng trước cổng bệnh viện lúc 7:00 sáng hoặc chuẩn bị ký hợp đồng trọ, chỉ cần mở mục **"Cẩm Nang 24/7"** là có thể tra cứu tức thì trong 30 giây!

---

## 🚀 6. HƯỚNG DẪN CÀI ĐẶT & CHẠY GAME

### Cách 1: Chơi Ngay Trên Web Trình Duyệt / Điện Thoại (Zero-Install)
1. Nhấp đúp chuột vào file: `run_web.bat`
2. Trình duyệt sẽ tự động mở địa chỉ: `http://localhost:3000`
3. Trải nghiệm đầy đủ 16 bài học, hệ thống âm thanh tiếng mèo meo meo, và giao diện cảm ứng mượt mà!

### Cách 2: Mở & Phát Triển Bằng Godot Engine 4.3
1. Nhấp đúp chuột vào file: `run_godot.bat` (Hoặc mở Godot 4.3 và import thư mục `D:\BestSen`).
2. Nhấn `F5` hoặc nút Play để chạy game.
3. Để xuất game ra các nền tảng:
   - Vào menu **Project -> Export...**
   - Chọn preset: **Windows Desktop**, **Web HTML5**, hoặc **Android** để tạo file `.exe`, `.html`, hoặc `.apk`.

### Cách 3: Chạy Trực Tiếp Game (Không Cần Mở Editor)
- Nhấp đúp chuột vào file: `run_game_direct.bat`

---

## 📁 7. CẤU TRÚC DỰ ÁN

```
D:\BestSen\
├── assets\
│   └── sprites\             # Toàn bộ spritesheet pixel art tối ưu (cat_idle, cat_box, furnitures, cat_ui)
├── scenes\
│   ├── Main.tscn            # Màn hình chính điều phối & Top Bar 3 chỉ số
│   ├── RoomView.tscn        # Phòng trọ sinh viên & Chăm sóc Boss
│   ├── SkillTree.tscn       # Cây kỹ năng 16 bài học thuộc 4 nhánh
│   ├── LessonView.tscn      # Sequence Puzzle giải mã tiếng mèo & Cẩm nang cứu Sen
│   ├── SimulationView.tscn  # Mô phỏng ngoài đời & Thử sai an toàn (Safe Failure)
│   ├── HandbookView.tscn    # Thư viện cứu nguy mở 24/7 tra cứu khẩn cấp
│   └── MuseumView.tscn      # Bảo tàng chiến lợi phẩm & Huy hiệu quê độ
├── scripts\
│   ├── GameManager.gd       # Singleton quản lý biến số, dữ liệu 16 bài học & lưu trữ
│   ├── SoundManager.gd      # Hệ thống âm thanh thủ tục (Procedural Synth WAV)
│   ├── Main.gd              # Logic điều phối giao diện
│   ├── RoomView.gd          # Tương tác phòng trọ & hoạt hình Mèo
│   ├── SkillTree.gd         # Lọc & mở khóa bài học
│   ├── LessonView.gd        # Kéo thả xếp thẻ tiếng mèo
│   ├── SimulationView.gd    # Diễn hoạt mô phỏng kết quả
│   ├── HandbookView.gd      # Tìm kiếm tra cứu 24/7
│   └── MuseumView.gd        # Trưng bày huy hiệu & tặng thẻ bạn bè
├── tests\
│   └── test_game.gd         # Bộ kiểm thử tự động toàn diện
├── index.html               # Bản Web Mobile Responsive chơi ngay trên mọi thiết bị
├── server.js                # Máy chủ cục bộ phục vụ Web App
├── run_web.bat              # 1-click mở Web App
├── run_godot.bat            # 1-click mở Godot Engine
├── run_game_direct.bat      # 1-click chạy game Godot trực tiếp
├── project.godot            # Cấu hình dự án Godot 4.3
└── export_presets.cfg       # Cấu hình xuất file đa nền tảng (Windows, Web, Android)
```

---
*Phát triển với tất cả tình yêu thương dành cho loài Mèo và các bạn Tân Sinh Viên!* 🐾🎓
