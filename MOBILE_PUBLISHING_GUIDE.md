# 📱 HƯỚNG DẪN XUẤT BẢN APP GAME RIÊNG TRÊN GOOGLE PLAY (CH PLAY) & APPLE APP STORE
> **Dành riêng cho dự án:** Mèo Tự Lập (Cat's Life Quest) - BestSen  
> **Engine:** Godot Engine 4.3  
> **Gói ứng dụng:** `com.bestsen.catlifequest`

---

## 🧭 LỘ TRÌNH ĐƯA APP LÊN CH PLAY & APP STORE

```
[Dự Án Godot 4.3]
       │
       ├──► [Xuất Android (.aab / .apk)] ──► [Google Play Console] ──► CH PLAY (Android)
       │
       └──► [Xuất iOS Project (Xcode)]  ──► [App Store Connect]    ──► APP STORE (iPhone/iPad)
```

---

## 🛠️ PHẦN 1: CẤU HÌNH & XUẤT FILE NATIVE MOBILE TRÊN GODOT 4.3

### 1.1. Chuẩn bị môi trường Android trên máy tính:
1. **Cài đặt JDK (Java Development Kit 17):**
   - Tải và cài đặt **OpenJDK 17** (hoặc Microsoft OpenJDK 17).
2. **Cài đặt Android Studio:**
   - Cài đặt Android Studio để có **Android SDK**, **Android SDK Command-line Tools**, và **Android SDK Platform 34** (bắt buộc cho CH Play 2024–2026).
3. **Cấu hình đường dẫn trong Godot Engine:**
   - Mở Godot 4.3 -> Vào menu **Editor -> Editor Settings...** -> Chọn mục **Export -> Android**:
     - *Android SDK Path:* `C:/Users/<Tên_Bạn>/AppData/Local/Android/Sdk`
     - *Java SDK Path:* `C:/Program Files/Eclipse Adoptium/jdk-17...`

### 1.2. Tạo Keystore để ký số bản quyền ứng dụng (Bắt buộc):
Mở terminal PowerShell và gõ lệnh sau để tạo file khóa bí mật:
```powershell
keytool -genkey -v -keystore release.keystore -alias meotulap -keyalg RSA -keysize 2048 -validity 10000
```
*(Ghi nhớ mật khẩu bạn đặt và cất giữ file `release.keystore` cẩn thận, không được làm mất).*

### 1.3. Xuất file Android:
1. Mở dự án trong Godot 4.3 -> Vào menu **Project -> Export...**
2. Đã có sẵn preset **"Android (Google Play / CH Play)"**:
   - Điền đường dẫn file `release.keystore`, `keystore user`, và `mật khẩu` vào mục **Keystore**.
   - **Để cài thử nghiệm ngay vào điện thoại Android:** Chọn định dạng xuất là `.apk` (bấm *Export Project*). Bạn có thể gửi file `.apk` này qua Zalo/Drive vào điện thoại và bấm cài đặt ngay.
   - **Để tải lên CH Play:** Chọn định dạng xuất là `.aab` (Android App Bundle).

---

## 🍏 PHẦN 2: QUY TRÌNH XUẤT CHO APPLE APP STORE (iOS)

1. **Yêu cầu:** Cần có máy Mac chạy macOS và phần mềm **Xcode** (tải miễn phí từ Mac App Store).
2. **Tại máy tính Windows/Mac:**
   - Trong Godot 4.3 -> Vào **Project -> Export...** -> Chọn preset **"iOS (Apple App Store)"**.
   - Bấm **Export Project** để xuất ra thư mục chứa Xcode Project.
3. **Mở dự án trên Xcode:**
   - Mở file `.xcodeproj` bằng Xcode.
   - Chọn **Signing & Capabilities** -> Đăng nhập tài khoản Apple Developer của bạn.
   - Chọn Team và Provisioning Profile.
   - Chọn thiết bị đích là **Any iOS Device (arm64)** -> Vào menu **Product -> Archive**.
   - Sau khi hoàn thành, bấm **Distribute App** để tải thẳng lên **App Store Connect**.

---

## 🚀 PHẦN 3: ĐƯA APP LÊN GOOGLE PLAY (CH PLAY) TỪNG BƯỚC

### Bước 1: Đăng ký tài khoản Google Play Console
- Truy cập: [https://play.google.com/console](https://play.google.com/console)
- Phí đăng ký: 25 USD (thanh toán 1 lần duy nhất bằng thẻ Visa/Mastercard, sử dụng vĩnh viễn).

### Bước 2: Tạo ứng dụng mới
- Tên ứng dụng: `Mèo Tự Lập: Sinh Viên Kỹ Năng` (Dưới 30 ký tự)
- Ngôn ngữ mặc định: Tiếng Việt (vi)
- Thể loại: Trò chơi (Game) -> Giáo dục / Mô phỏng (Educational / Simulation)
- Miễn phí hay Trả phí: Miễn phí (Free)

### Bước 3: Cung cấp thông tin Store Listing (ASO Soạn Sẵn)

#### 📝 Tên Ứng Dụng (Max 30 ký tự):
```
Mèo Tự Lập: Kỹ Năng Sống
```

#### 📌 Mô Tả Ngắn (Max 80 ký tự):
```
Đồng hành cùng Boss mèo ngơ ngác rèn luyện 16 kỹ năng sinh tồn tự lập giữa thị thành!
```

#### 📖 Mô Tả Chi Tiết (Full Description):
```markdown
🐾 MÈO TỰ LẬP (CAT'S LIFE QUEST) - GAME CHĂM SÓC MÈO & RÈN LUYỆN KỸ NĂNG SỐNG TỰ LẬP ĐẦU ĐỜI!

Bạn là tân sinh viên lần đầu rời quê lên phố? Bạn lo sợ bỡ ngỡ trước ma trận xe buýt, bẫy hợp đồng phòng trọ, sốt cao đêm khuya hay cạm bẫy đa cấp? 
Đừng lo! Trong "Mèo Tự Lập", bạn không hề bị "lên lớp dạy đời" - mà chính bạn sẽ trở thành "Sen bảo hộ" thông thái, chăm sóc và hướng dẫn chú mèo cưng vượt qua mọi thử thách tự lập!

🌟 TÍNH NĂNG NỔI BẬT:

1. QUẢN LÝ 3 CHỈ SỐ SINH TỒN THỰC TẾ:
- Cá Khô: Cân đối ngân sách sinh hoạt 90 con cá trong 30 ngày (3 cá/ngày).
- Độ No: Cho ăn hạt sinh viên tiết kiệm hay thưởng lon pate xịn sò?
- Dũng Cảm: Vượt qua nỗi sợ bị la mắng, bỡ ngỡ giữa chốn đông người.

2. CÂY 16 BÀI HỌC KỸ NĂNG THIẾT YẾU:
- 🚗 Đi Lại: Bắt xe buýt liên quận số 08, tra cứu BusMap đổi tuyến, định vị Google Maps thoát bùng binh, cứu hộ xe máy cơ bản.
- 🏠 Nơi Ở: Soi hợp đồng trọ tránh mất cọc, kiểm tra an toàn PCCC chuồng cọp, đăng ký tạm trú trực tuyến VNeID, hiệp ước ở ghép hòa thuận.
- 🏥 Sức Khỏe: Xử lý sốt 39 độ giữa đêm, 6 bước khám BHYT đúng tuyến không sợ bị mắng, chuẩn bị túi thuốc sơ cứu, bảo vệ dạ dày mùa thi.
- 💰 Tiền Tài: Phân bổ 3 Hũ Cá, lật tẩy bẫy đa cấp Ponzi lãi khủng, phỏng vấn part-time không cọc tiền, thoát bẫy nợ Ví Trả Sau.

3. CƠ CHẾ THỬ SAI AN TOÀN (SAFE FAILURE):
Xếp sai chuỗi hành động? Không sao cả! Mèo chỉ "quê độ" chạy về phòng trọ và tụt chút dũng cảm. Bạn được thử nghiệm thoải mái mà không lo mất tiền hay gặp rủi ro ngoài đời thực!

4. THƯ VIỆN CỨU NGUY MỞ 24/7 (EMERGENCY SANDBOX):
Mở sẵn 100% tài liệu của cả 16 bài học ngay từ đầu! Đang đứng trước cổng bệnh viện lúc 7h sáng hay chuẩn bị ký hợp đồng trọ? Mở app tra cứu tức thì trong 30 giây!

Tải ngay "Mèo Tự Lập" để cùng Boss mèo tự tin làm chủ cuộc sống sinh viên! 🎓🐾
```

### Bước 4: Khảo sát nội dung & Chính sách bảo mật (Privacy Policy)
- **Độ tuổi (Content Rating):** Chọn danh mục Giáo dục -> Khảo sát không có bạo lực, không có ngôn từ kích động -> Được cấp chứng nhận **PEGI 3 / Everyone** (Mọi lứa tuổi).
- **Chính sách bảo mật:** Đã soạn sẵn file mẫu chuẩn GDPR/Google Play tại [`PRIVACY_POLICY.md`](file:///d:/BestSen/PRIVACY_POLICY.md). Bạn chỉ cần copy nội dung đưa lên website hoặc GitHub Pages.

### Bước 5: Tải file `.aab` và Phát hành
- Vào mục **Production** (hoặc **Closed testing**) -> Tải file `MeoTuLap.aab` lên.
- Đội ngũ Google sẽ duyệt app trong vòng 1–3 ngày làm việc. Sau khi duyệt, app sẽ chính thức xuất hiện trên **CH Play** cho tất cả người dùng tải về!

---

## 🍏 PHẦN 4: ĐƯA APP LÊN APPLE APP STORE TỪNG BƯỚC

1. Đăng ký tài khoản **Apple Developer Program** (99 USD/năm) tại [developer.apple.com](https://developer.apple.com).
2. Vào trang **App Store Connect** -> Tạo New App:
   - Name: `Mèo Tự Lập`
   - Primary Language: `Vietnamese`
   - Bundle ID: `com.bestsen.catlifequest`
   - SKU: `BESTSEN_CAT_01`
3. Tải các ảnh chụp màn hình (Screenshots) tỷ lệ 6.7" (iPhone 15 Pro Max) và 6.5".
4. Dán mô tả ASO và Privacy Policy URL tương tự như phần CH Play.
5. Chọn bản build đã upload từ Xcode -> Bấm **Submit for Review**.
6. Apple duyệt trong vòng 24–48 giờ, app sẽ có mặt trên **App Store** toàn cầu!
