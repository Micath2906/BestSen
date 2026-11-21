# ĐỀ XUẤT THIẾT KẾ GAMIFICATION KỸ NĂNG THỰC TẾ & TÁI CẤU TRÚC GAMEPLAY (V2.0)
## DỰ ÁN: CAT'S LIFE QUEST (MÈO TỰ LẬP / BEST SEN)

**Phiên bản tài liệu**: 2.0.0 (Cập nhật toàn diện theo phản hồi & định hướng chi tiết của Người dùng)  
**Ngày cập nhật**: 2026-11-18  
**Tác giả**: Đội ngũ Thiết kế Gameplay & UX/UI  
**Trạng thái**: Đã cập nhật đầy đủ các danh mục gameplay con và định hướng Pixel 2D (Ready for User Review)  

---

## 1. TỔNG QUAN & ĐỊNH HƯỚNG MỸ THUẬT UX/UI PIXEL 2D

### 1.1 Triết lý thiết kế cốt lõi
- **Học qua trải nghiệm thực tế (Real-life Safe Failure)**: Mô phỏng chân thực các tình huống đời sống mà tân sinh viên, người trẻ lần đầu sống xa nhà phải đối mặt (tự đóng gói đồ đạc, ký hợp đồng thuê trọ, sốt cao đêm khuya, bắt xe buýt đô thị, bẫy nợ tài chính & tin nhắn lừa đảo).
- **Phân tách Scene độc lập (Modular Standalone Scenes)**: Mỗi danh mục kỹ năng được tách thành các scene Godot riêng biệt (.tscn), có thể chạy và kiểm thử độc lập mà không phụ thuộc chéo vào logic của các màn chơi khác.
- **Ưu tiên Tối ưu hóa UX/UI Pixel 2D (Flat Orthographic Grid)**:
  - Toàn bộ giao diện người dùng, khung minigame, bảng điều khiển và tương tác xúc giác được thiết kế trên hệ lưới Pixel Art 2D phẳng (độ phân giải chuẩn $360 \times 640$, tỉ lệ 9:16 dọc).
  - **Lợi thế của 2D ở giai đoạn này**: Thao tác chạm (tap), kéo thả (drag & drop), nối dây (cable routing) và tìm điểm khác biệt (spot difference) đạt độ chuẩn xác tuyệt đối, không bị lệch góc chiếu hay rối mắt như isometric.
  - **Lộ trình 2.5D**: Sau khi người dùng nghiệm thu hoàn chỉnh khung gameplay và bố cục 2D, các phân cảnh cần chiều sâu không gian (như phòng trọ chính) mới được cân nhắc chuyển đổi sang 2.5D.

---

## 2. NĂM CHỦ ĐỀ KỸ NĂNG THỰC TẾ VÀ CHI TIẾT TỪNG MINIGAME

```
                         +-----------------------------------+
                         |    CAT'S LIFE QUEST GAMIFICATION  |
                         +-----------------------------------+
                                           |
      +-----------------+------------------+-----------------+-----------------+
      |                 |                  |                 |                 |
 [1. HÀNH TRANG]   [2. THUÊ TRỌ]      [3. Y TẾ]        [4. GIAO THÔNG]   [5. TÀI CHÍNH]
  Xếp Vali 10kg     Tìm Khác Biệt     Bộ Ba Minigame    Bộ Đôi Minigame   Bẫy Nợ & SMS Lừa
 (Unpacking 2D)     (Spot Diff 2D)   (Tủ Thuốc - Sơ Cứu (Nối Dây Xe Buýt  (Chia Hũ 90 Cá
                                       - Khám BHYT)      - Mô Phỏng Đi Xe) Ở Màn Hình Chính)
```

---

### CHỦ ĐỀ 1: HÀNH TRANG SINH TỒN — XẾP VALI TÂN SINH VIÊN (UNPACKING 2D)

- **Tên Scene**: `scenes/minigames/packing_minigame.tscn`
- **Mục tiêu giáo dục**: Rèn luyện kỹ năng phân loại hành lý khoa học, mang đúng đồ thiết yếu, không mang đồ cồng kềnh/vi phạm nội quy KTX.
- **Cơ chế Gameplay**:
  1. **Khung Vali 4 Ngăn 2D**:
     - *Ngăn 1 - Hồ sơ & Giấy tờ (Túi Zipper chống nước)*: CCCD gắn chip, thẻ BHYT, giấy báo trúng tuyển, học bạ bản gốc.
     - *Ngăn 2 - Thuốc & Y tế (Hộp cứu thương)*: Paracetamol, Berberin, Oresol, băng cá nhân Urgo, dầu gió.
     - *Ngăn 3 - Trang phục cá nhân*: Áo thun cuộn tròn, quần jean cuộn, khăn tắm bông.
     - *Ngăn 4 - Thiết bị học tập (Túi chống sốc)*: Laptop, sạc đa năng, ổ cắm nối dài 3 chấu an toàn.
  2. **Kiểm soát Tải trọng 10kg & Bẫy Thử Sai**:
     - Thước đo cân nặng thời gian thực: Giới hạn tối đa 10kg.
     - *Vật phẩm bẫy*: Gấu bông 1.5m (chiếm hết chỗ, vali không kéo khóa được), Nồi lẩu 2000W (nguy cơ cháy nổ KTX), Loa kéo karaoke (gây mất trật tự).
  3. **Lời dặn Polaroid**: Chạm vào từng món đồ để xem lời dặn thực tế của phụ huynh.

---

### CHỦ ĐỀ 2: THUÊ TRỌ AN TOÀN — TÌM ĐIỂM KHÁC BIỆT PHÒNG TRỌ (SPOT THE DIFFERENCE 2D)

- **Tên Scene**: `scenes/minigames/room_inspection_diff_game.tscn`
- **Mục tiêu giáo dục**: Giúp sinh viên không bị "mắc bẫy" hình ảnh phòng trọ quảng cáo trên mạng; học cách quan sát tỉ mỉ từng chi tiết an toàn, kết cấu và điện nước trước khi đặt cọc.
- **Cơ chế Gameplay (Dạng game Tìm Điểm Khác Biệt 2D)**:
  1. **Bố cục So sánh Song song (Side-by-Side Comparison)**:
     - *Bức ảnh A (Bên trên / Bên trái)*: "ẢNH QUẢNG CÁO CỦA CHỦ TRỌ" — Phòng trọ mẫu sạch sẽ, trần phẳng mịn, tường trắng tinh tươm, vòi nước sáng bóng, cửa khóa nguyên vẹn.
     - *Bức ảnh B (Bên dưới / Bên phải)*: "PHÒNG TRỌ THỰC TẾ KHI TỚI XEM" — Căn phòng thực tế tồn tại 5-6 khiếm khuyết rủi ro ẩn giấu.
  2. **Thao tác Phát hiện Điểm Khác Biệt**:
     - Người chơi chạm/click vào các vị trí sai lệch trên bức ảnh thực tế:
       * **Điểm 1 - Vòi nước rò rỉ**: Nước nhỏ giọt tí tách (Thực tế: mất 3-5m³ nước/tháng, tốn thêm 150k-250k tiền nước).
       * **Điểm 2 - Mảng ố dột trần nhà**: Thạch cao mủn loang lổ (Thực tế: mùa mưa nước tràn hỏng laptop và chăn đệm).
       * **Điểm 3 - Ổ khóa cửa bung ốc**: Tay nắm xệ, ốc vít lỏng (Thực tế: nguy cơ trộm cạy cửa trong 10 giây).
       * **Điểm 4 - Chuồng cọp khóa chết**: Lưới sắt ban công hàn kín mít không có cửa thoát hiểm PCCC (Thực tế: cực kỳ nguy hiểm khi hỏa hoạn).
       * **Điểm 5 - Ổ cắm cháy đen / Quá tải**: Nhựa ổ cắm chảy biến dạng, cắm chuyền nguy hiểm.
       * **Điểm 6 - Đĩa công tơ điện ma**: Dù đã gạt át-tô-mát tổng trong phòng về OFF, đĩa công tơ ngoài hành lang vẫn quay (vạch trần chiêu câu trộm điện).
  3. **Phản hồi Tức thì (Juicy Feedback)**:
     - Chạm đúng: Xuất hiện vòng tròn pixel đỏ khoanh vùng điểm lỗi + âm thanh phát hiện thành công + hiển thị popup *"Biên bản khiếm khuyết"* phân tích tác hại và quyền lợi pháp lý (yêu cầu chủ sửa trước khi cọc).
     - Chạm sai: Rung lắc nhẹ khung hình và trừ thời gian/lượt bấm.
  4. **Phán Quyết Nghiệm Thu**: Tìm đủ các lỗi để mở khóa 3 lựa chọn: Lập biên bản yêu cầu sửa, Từ chối thuê phòng không an toàn PCCC, hoặc Ký bừa nhận phòng (kèm cảnh báo hậu quả).

---

### CHỦ ĐỀ 3: BỘ ĐÔI MINIGAME Y TẾ & BHYT (HEALTHCARE & CLINIC SIMULATION)

Theo gợi ý tối ưu từ người dùng, hai phần chọn thuốc và điều trị tại chỗ được **ghép thành một minigame duy nhất theo phong cách "Game Giả Lập Bác Sĩ Của Trẻ Em" (Little Doctor Clinic Simulation)**, tạo nên trải nghiệm liền mạch, trực quan và giàu xúc giác; tách riêng phần thủ tục BHYT:

```
[CHỦ ĐỀ 3: Y TẾ]
       |
       +---> Game 3.1: Giả lập Bác Sĩ Cứu Thương Mèo Con (Little Doctor Clinic Sim)
       |               (Khám bệnh -> Soi tủ thuốc -> Chườm mát -> Uống đúng liều & Bù Oresol)
       |
       +---> Game 3.2: Quy trình đi khám BHYT đúng tuyến (VNeID & 4 Trạm bệnh viện)
```

#### Minigame 3.1: Giả Lập Bác Sĩ Cứu Thương Mèo Con (Little Cat Doctor Clinic Sim)
- **Tên Scene**: `scenes/minigames/doctor_simulation_game.tscn`
- **Mục tiêu giáo dục**: Học trọn vẹn quy trình chẩn đoán, chọn đúng thuốc theo bệnh, hạ sốt khoa học và cho uống thuốc đúng liều theo cân nặng; cấm lạm dụng kháng sinh.
- **Phong cách Gameplay (Kids Doctor / Pet Hospital Simulation)**:
  - **Sân khấu 2D Pixel**: Bé Mèo nằm trên giường trùm chăn bông, hai má đỏ ửng sốt cao, có bóng đèn và bảng theo dõi nhịp tim/nhiệt độ cạnh giường. Dưới chân là khay dụng cụ bác sĩ tương tác đa năng.
  - **Chuỗi 4 bước khám & chữa bệnh tương tác liên hoàn**:
    1. *Bước 1 - Khám & Chẩn đoán thân nhiệt*:
       - Kéo nhiệt kế điện tử kẹp vào nách Mèo, giữ 3 giây nghe tiếng "Tít tít", màn hình nhảy số $39.0^\circ\text{C}$ báo động đỏ. Mèo thều thào khó chịu.
    2. *Bước 2 - Điều trị vật lý hạ sốt (Lau mát)*:
       - Kéo khăn bông cotton nhúng vào thau nước ấm ($32–35^\circ\text{C}$), vắt ráo rồi kéo đắp/lau nhẹ nhàng lên trán, nách, bẹn của Mèo. Có làn hơi nước mát bay lên, nét mặt Mèo giãn ra dễ chịu.
       - *Thử sai an toàn*: Nếu kéo đá lạnh hoặc cồn vào $\rightarrow$ Mèo run bắn người co mạch, hiện thông báo cấm của bác sĩ.
    3. *Bước 3 - Mở tủ thuốc & Chọn thuốc đúng bệnh, đúng liều*:
       - Chạm vào tủ thuốc gia đình đặt ngay đầu giường để mở cánh cửa tủ 2D.
       - Trong tủ có nhiều loại: Paracetamol 500mg, Men tiêu hóa Berberin, Kháng sinh Amoxicillin, Oresol.
       - Mèo đang bị sốt cao $\rightarrow$ Người chơi phải chọn đúng vỉ **Paracetamol 500mg** (chuẩn cân nặng Mèo 40kg).
       - *Thử sai hài hước*: Nếu chọn Berberin $\rightarrow$ Mèo xua tay *"Mèo đâu có bị đau bụng đâu Sen!"*. Nếu chọn Kháng sinh $\rightarrow$ Chuông cảnh báo vang lên: *"Cảm sốt do virus, tự ý uống kháng sinh sẽ gây kháng thuốc nguy hiểm!"*.
       - Sau khi chọn đúng Paracetamol, kéo viên thuốc thả vào thìa nước cho Mèo uống.
    4. *Bước 4 - Pha Oresol bù điện giải*:
       - Kéo gói bột Oresol đổ vào ly nước đúng vạch 200ml nước ấm đun sôi để nguội.
       - Kéo thìa khuấy vòng tròn tạo hiệu ứng sủi bọt tan đều $\rightarrow$ Nghiêng ly cho Mèo uống từng ngụm nhỏ.
  - **Khoảnh khắc Hồi phục (Juicy Recovery)**:
    - Nhiệt độ hạ về $37.0^\circ\text{C}$ bình thường, má Mèo hết đỏ, Mèo vui vẻ nhảy bật dậy, đội mũ bác sĩ kêu "Meo meo!", thưởng huy hiệu *"Bác Sĩ Nhí Tự Lập"* và 15 Cá Khô.

#### Minigame 3.2: Quy Trình Đi Khám BHYT (Hospital BHYT Workflow)
- **Tên Scene**: `scenes/minigames/hospital_bhyt_game.tscn`
- **Mục tiêu giáo dục**: Thành thạo quy trình khám bệnh bằng BHYT đúng tuyến tại trạm y tế / bệnh viện công, tận dụng thẻ BHYT số trên VNeID.
- **Gameplay**: Di chuyển nhân vật qua 4 quầy hành chính mô phỏng 2D:
  1. *Quầy 1 - Tiếp đón & Xuất trình giấy tờ*: Mở điện thoại, chọn đúng icon Thẻ BHYT tích hợp VNeID/VssID + CCCD gắn chip để nhân viên quét mã QR.
  2. *Quầy 2 - Lấy số thứ tự*: Chạm vào trụ bốc số tự động, chọn đúng phân khoa: "Khám Nội Tổng Quát".
  3. *Quầy 3 - Bác sĩ thăm khám & Chỉ định*: Trao đổi triệu chứng sốt kéo dài trên 48h, nhận phiếu chỉ định xét nghiệm máu sàng lọc sốt xuất huyết Dengue.
  4. *Quầy 4 - Quầy Dược BHYT*: Nộp đơn thuốc, nhận thông báo BHYT thanh toán 80% chi phí, nhận đúng số lượng thuốc theo đơn và nghe hướng dẫn sử dụng.

---

### CHỦ ĐỀ 4: BỘ ĐÔI MINIGAME GIAO THÔNG & XE BUÝT (URBAN TRANSIT DUO)

```
[CHỦ ĐỀ 4: GIAO THÔNG XE BUÝT]
       |
       +---> Game 4.1: Tìm tuyến xe đi hợp lý (Nối dây bản đồ app BusMap)
       |
       +---> Game 4.2: Simulation hành trình xe buýt (VNeID/Thẻ - Vẫy xe - Quẹt vé - Canh trạm)
```

#### Minigame 4.1: Tìm Tuyến Xe Đi Hợp Lý (Bus Route Cable Connect)
- **Tên Scene**: `scenes/minigames/bus_route_finder_game.tscn`
- **Mục tiêu giáo dục**: Học cách đọc bản đồ tuyến xe buýt đô thị, tìm lộ trình di chuyển tối ưu, tránh bắt nhầm tuyến xe ngược chiều.
- **Gameplay (Dạng nối dây dẫn đường trên màn hình App)**:
  - Khung cảnh mô phỏng giao diện ứng dụng xe buýt (như BusMap) trên điện thoại 2D Pixel.
  - NPC Mèo xuất hiện kèm bong bóng thoại nói điểm xuất phát và đích đến (Ví dụ: *"Sen ơi, từ trọ ở KTX Khu B ĐHQG, mình muốn đến Trường ĐH KHXH&NV Cơ sở Đinh Tiên Hoàng thì đi xe nào?"*).
  - Bản đồ xuất hiện các Node trạm dừng và các tuyến đường buýt mang màu sắc khác nhau (Tuyến 08 Xanh dương, Tuyến 19 Xanh lá, Tuyến 33 Đỏ, Tuyến 53 Vàng).
  - Người chơi kéo sợi dây hướng dẫn từ vị trí xuất phát của NPC nối qua các trạm dừng phù hợp để tới đích:
    * *Nối chuẩn*: Chọn tuyến 19 chạy thẳng hoặc tuyến 08 chuyển 1 trạm ngắn nhất $\rightarrow$ Hoàn thành với 3 sao và chi phí tiết kiệm.
    * *Nối sai*: Nối vào tuyến chạy ngược chiều hoặc tuyến không có trạm dừng $\rightarrow$ App báo lộ trình không khả dụng, NPC thốt lên *"Đi nhầm đường rồi Sen ơi!"*.

#### Minigame 4.2: Simulation Hành Trình Đi Xe Buýt Thực Tế (Bus Ride Life-Sim)
- **Tên Scene**: `scenes/minigames/bus_journey_sim_game.tscn`
- **Mục tiêu giáo dục**: Rèn luyện văn hóa đi xe buýt công cộng, sự chủ động về phương tiện thanh toán và kỹ năng an toàn khi lên xuống xe.
- **Gameplay (Chuỗi trải nghiệm 4 chặng mô phỏng thực tế)**:
  1. *Chặng 1 - Chuẩn bị*: Mở ba lô, chọn sẵn thẻ xe buýt HSSV / thẻ ATM ngân hàng / app VNeID hoặc chuẩn bị sẵn tiền lẻ 7.000đ cầm trên tay (Tránh tình huống lên xe mới lục tìm ví hoặc đưa tờ 500k làm tắc nghẽn cửa).
  2. *Chặng 2 - Đón xe & Vẫy xe*: Mèo đứng tại nhà chờ trạm buýt 2D. Các xe buýt chạy ngang qua. Khi xe buýt mang số hiệu cần đi (ví dụ xe 19) tiến vào cự ly 30m, người chơi bấm nút *"Vẫy Xe"* đúng lúc (Timing Bar) để xe tấp vào lề đón.
  3. *Chặng 3 - Lên xe & Ứng xử văn minh*:
     - Chạm quẹt thẻ vào máy POS cạnh tài xế (nghe tiếng "Tít" xác nhận).
     - Kéo ba lô xoay ra trước ngực (phòng ngừa móc túi rạch ba lô nơi đông người và tránh va quẹt người khác).
     - Bám chắc vào thanh tay vịn xe khi xe tăng tốc; nhường ghế cho cụ già / phụ nữ mang thai nếu có xuất hiện.
  4. *Chặng 4 - Canh trạm & Xuống xe an toàn*:
     - Quan sát bảng đèn LED và loa thông báo trên xe: *"Trạm tiếp theo: Đại học Khoa học Xã hội và Nhân văn..."*.
     - Bấm nút **CHUÔNG XUỐNG XE (STOP)** trước khi xe đến trạm 50m để tài xế chuẩn bị tấp lề.
     - Đợi xe dừng hẳn mới bước xuống cửa sau, quan sát gương cầu lồi tránh xe máy chạy chen làn bên phải.

---

### CHỦ ĐỀ 5: BẪY TÀI CHÍNH & HỆ THỐNG QUẢN LÝ 90 CÁ CỐ ĐỊNH

```
[CHỦ ĐỀ 5: TÀI CHÍNH SINH VIÊN]
       |
       +---> Minigame 5.1: Vượt cạm bẫy tài chính (Bẫy nợ BNPL & Tin nhắn SMS lừa đảo)
       |
       +---> Hệ thống Màn hình chính: Quản lý 3 Hũ Chi Tiêu (Ngân sách cố định 90 Cá/tháng)
```

#### Minigame 5.1: Cạm Bẫy Tài Chính Đô Thị & Thám Tử Tin Nhắn Lừa Đảo (Finance Traps & Scam Alert)
- **Tên Scene**: `scenes/minigames/finance_scam_hunter_game.tscn`
- **Mục tiêu giáo dục**: Trang bị "sức đề kháng" trước các chiêu trò bẫy nợ tín dụng đen, mua trước trả sau và lừa đảo công nghệ cao nhắm vào sinh viên.
- **Gameplay**:
  1. *Tình huống 1 - Bẫy Mua Trước Trả Sau (BNPL) & Trả Góp 0%*:
     - Xuất hiện banner quảng cáo: *"Sở hữu ngay tai nghe xịn giá 0đ, mỗi ngày chỉ trả 2 Cá Khô!"*.
     - Người chơi lật mặt sau hợp đồng tín dụng để dùng kính lúp soi các "dòng chữ li ti":
       * Phí bảo hiểm khoản vay ẩn 30%.
       * Phí phạt chậm 1 ngày tính 15 Cá (cắt cổ).
       * Lãi suất thực tế lên tới 60%/năm.
     - Thao tác: Dùng bút gạch chéo hợp đồng, đóng dấu **"TỪ CHỐI BẪY NỢ"**.
  2. *Tình huống 2 - Soi Tin Nhắn Lừa Đảo (SMS / Zalo / Telegram Scam)*:
     - Màn hình điện thoại hiển thị liên tiếp các tin nhắn gửi đến:
       * *Tin 1*: *"Tài khoản ngân hàng của bạn bị tạm khóa vì giao dịch bất thường. Đăng nhập ngay tại: http://vietcombank-verify-sec.top để mở khóa"*.
       * *Tin 2*: *"Tuyển CTV gõ mã đơn hàng Shopee/Lazada tại nhà, lương 500k/ngày, yêu cầu cọc 200k phí phần mềm"*.
       * *Tin 3*: *"Thông báo nhận học bổng sinh viên khó khăn 5 triệu đồng, liên hệ Zalo cán bộ để nộp phí hồ sơ 300k"*.
     - Người chơi có 2 nút hành động lớn: **[ĐÓNG DẤU LỪA ĐẢO & CHẶN]** và **[BẤM VÀO LINK / CHUYỂN TIỀN]**.
     - Chọn đúng: Nhận điểm Cảnh Giác Số; chọn sai: Bị trừ sạch tiền trong tài khoản và hiện thông điệp cảnh báo các thủ đoạn mạo danh ngân hàng/cơ quan công an.

#### Tính Năng Ngoài Gameplay: Quản Lý 3 Hũ Ngân Sách 90 Cá (Main Screen Budget Jars)
- **Vị trí**: Nằm trực tiếp tại Màn hình chính (Căn phòng của Mèo) hoặc Tab Tài Chính (`MainRoomHUD` / `BottomPawMenu`).
- **Bối cảnh kinh tế trong game**: Mỗi tháng người chơi được cấp ngân sách sinh hoạt cố định là **90 Cá Khô**.
- **Cơ chế 3 Chiếc Hũ Pixel (50/30/20 Rule)**:
  - *Hũ 1 - Hũ Thiết Yếu (50% = 45 Cá)*: Dùng để chi trả tiền thức ăn hạt hàng ngày cho Mèo, tiền cát vệ sinh, tiền trọ cố định.
  - *Hũ 2 - Hũ Tự Lập & Nuôi Dưỡng (30% = 27 Cá)*: Mua sách học kỹ năng mới, đồ chơi cuộn len xả stress, quần áo phụ kiện trong Shop.
  - *Hũ 3 - Hũ Dự Phòng Khẩn Cấp (20% = 18 Cá)*: Dành riêng cho các biến cố bất ngờ phát sinh trong game (tiền mua thuốc khi Mèo ốm sốt, tiền vá xe khi thủng lốp, tiền phạt hợp đồng).
- **Tác động tương hỗ với Gameplay (Game Loop Integration)**:
  - Khi người chơi mua đồ ăn hoặc sắm phụ kiện, hệ thống trừ trực tiếp vào hũ tương ứng.
  - Nếu phân bổ sai khiến hũ Thiết Yếu hết cá $\rightarrow$ Mèo bị đói, thanh năng lượng tụt đỏ.
  - Người chơi học được kỹ năng cân đối chi tiêu thực tế ngay trong vòng lặp chăm sóc mèo hàng ngày.

---

## 3. DANH SÁCH CÁC SCENE CẦN DỰNG PROTOTYPE ĐỘC LẬP

| STT | Tên Scene (.tscn) | Script điều khiển (.gd) | Thể loại Gameplay | Trạng thái hiện tại |
|---|---|---|---|---|
| 1 | `packing_minigame.tscn` | `packing_minigame.gd` | Xếp Vali 4 ngăn 2D (Unpacking) | **Đã hoàn thành prototype** |
| 2 | `room_inspection_diff_game.tscn` | `room_inspection_diff_game.gd` | Tìm điểm khác biệt phòng trọ 2D (Spot Diff) | **Sẵn sàng triển khai** |
| 3 | `doctor_simulation_game.tscn` | `doctor_simulation_game.gd` | Giả lập Bác Sĩ Mèo Nhí (Khám - Thuốc - Hạ sốt) | **Sẵn sàng triển khai** |
| 4 | `hospital_bhyt_game.tscn` | `hospital_bhyt_game.gd` | Mô phỏng quy trình 4 trạm BHYT bệnh viện | **Sẵn sàng triển khai** |
| 5 | `bus_route_finder_game.tscn` | `bus_route_finder_game.gd` | Nối dây tìm tuyến xe buýt trên app BusMap | **Sẵn sàng triển khai** |
| 6 | `bus_journey_sim_game.tscn` | `bus_journey_sim_game.gd` | Simulation chặng xe buýt 4 bước thực tế | **Sẵn sàng triển khai** |
| 7 | `finance_scam_hunter_game.tscn` | `finance_scam_hunter_game.gd` | Bẫy nợ BNPL & Soi tin nhắn lừa đảo SMS | **Sẵn sàng triển khai** |
| 8 | `BudgetJarsWidget.tscn` | `BudgetJarsWidget.gd` | Widget 3 Hũ 90 Cá tại màn hình chính | **Sẵn sàng triển khai** |

---

## 4. KẾT LUẬN & ĐỀ XUẤT PHÊ DUYỆT
Tài liệu V2.0 đã chuyển hóa toàn bộ các đóng góp quý báu của người dùng thành thông số kỹ thuật chi tiết. Mọi minigame đều tập trung vào **tính thực tiễn cao, lối chơi tương tác hấp dẫn, bố cục Pixel 2D rõ ràng** và có thể khởi chạy độc lập để người dùng duyệt từng phân cảnh trước khi hợp nhất.
