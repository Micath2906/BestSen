# BẢNG ĐẶC TẢ CHI TIẾT TÀI NGUYÊN HÌNH ẢNH CẦN BỔ SUNG (MISSING ASSETS SPECIFICATION V2.0)
## DỰ ÁN: CAT'S LIFE QUEST (MÈO TỰ LẬP / BEST SEN)

**Mã tài liệu**: SPEC-ASSET-02  
**Phiên bản**: 2.0.0 (Cập nhật toàn diện theo danh mục gameplay phân tách V2.0)  
**Ngày phát hành**: 2026-11-18  
**Mục đích**: Cung cấp danh mục thông số kỹ thuật chuẩn xác (kích thước pixel WxH, mô tả trực quan, danh mục, mức độ ưu tiên) để người dùng có thể tự tìm kiếm hoặc họa sĩ vẽ thay thế; đồng thời kết nối trực tiếp với bộ sinh placeholder tự động `PixelPlaceholderFactory.gd`.

---

## 1. QUY CHUẨN KỸ THUẬT PIXEL ART 2D

1. **Định dạng file**: `.png` với kênh alpha trong suốt (Transparent 32-bit RGBA).
2. **Quy tắc Pixel 2D (Flat Orthographic Grid)**:
   - Tỷ lệ hiển thị integer 1:1, không khử răng cưa làm mờ viền (Nearest Neighbor filter).
   - Viền nét (Outlines): Màu nâu sẫm cà phê `#3E2723` hoặc màu xám đen `#263238` dày đúng 1 pixel.
   - Thẩm mỹ: Ấm cúng (Cozy), dễ thương, phong cách pixel 16-bit / 32-bit cổ điển.
3. **Bảng màu chủ đạo**:
   - Y tế & Cứu thương: Đỏ thập tự `#D32F2F`, Trắng tuyết `#FFFFFF`, Bạc nhôm vỉ thuốc `#B0BEC5`, Xanh ngọc Oresol `#4DB6AC`.
   - Giao thông & Xe buýt: Xanh dương tuyến buýt `#1976D2`, Vàng chuông dừng `#FBC02D`, Đỏ Stop `#D32F2F`.
   - Tài chính & Hũ cá: Vàng hổ phách `#FFA000`, Nâu gỗ `#6D4C41`, Xanh lá tiết kiệm `#388E3C`.
   - Cảnh báo lừa đảo: Đỏ dấu son `#C62828`, Vàng cảnh giác `#F57F17`.

---

## 2. BẢNG DANH MỤC ASSETS ĐẶC TẢ THEO TỪNG MINIGAME

| STT | Mã Asset (Asset ID) | Tên Vật Phẩm | Kích Thước (WxH) | Vị Trí Sử Dụng | Mức Độ Ưu Tiên | Mô Tả Trực Quan Chi Tiết | Giải Pháp Placeholder Tạm Thời |
|---|---|---|---|---|---|---|---|
| **I** | **CHỦ ĐỀ 1: XẾP VALI HÀNH TRANG (PACKING UNPACKING 2D)** | | | | | | |
| 1 | `pack_suitcase_open` | Lòng Vali Mở Nắp 2D | `320 x 400` | Khung sân khấu chính | **P0 (Bắt buộc)** | Lòng vali da cổ điển màu nâu/xanh rêu nhìn từ trên xuống, chia 4 khoang có dây đai co giãn | Khung 9-patch màu da bò sẫm viền pixel 2px |
| 2 | `pack_clothes_folded_shirt` | Chồng Áo Thun Gấp Gọn | `32 x 32` | Ngăn Trang phục | **P0 (Bắt buộc)** | Chồng 3 áo phông cotton gấp gọn gàng để lộ viền cổ áo | Chữ nhật `32x32` nền Xanh denim, nhãn "ÁO THUN" |
| 3 | `pack_clothes_rolled_pants` | Quần Jean Cuộn Tròn | `48 x 24` | Ngăn Trang phục | **P0 (Bắt buộc)** | 2 ống quần jeans xanh đậm cuộn tròn tiết kiệm diện tích | Chữ nhật `48x24` nền Xanh chàm, nhãn "QUẦN JEAN" |
| 4 | `pack_clothes_towel` | Khăn Tắm Bông Cuộn | `32 x 16` | Ngăn Trang phục | P1 | Cuộn khăn bông mềm màu trắng kem sọc vàng nhạt | Chữ nhật `32x16` nền Trắng kem, nhãn "KHĂN TẮM" |
| 5 | `pack_doc_dossier` | Bìa Hồ Sơ Nhập Học Chống Nước | `32 x 48` | Ngăn Hồ sơ | **P0 (Bắt buộc)** | Bìa hồ sơ màu cam đất kẹp giấy báo trúng tuyển có dấu đỏ | Chữ nhật `32x48` nền Cam đất có con dấu son |
| 6 | `pack_doc_id_wallet` | Ví Đựng Thẻ CCCD & BHYT | `32 x 24` | Ngăn Hồ sơ | **P0 (Bắt buộc)** | Ví da mini màu nâu lấp ló góc thẻ CCCD gắn chip và thẻ BHYT | Chữ nhật `32x24` nền Xanh ngọc, nhãn "CCCD/BHYT" |
| 7 | `pack_med_mother_box` | Hộp Thuốc Của Mẹ | `48 x 32` | Ngăn Y tế | **P0 (Bắt buộc)** | Hộp nhựa y tế màu trắng sứ in dấu thập đỏ nổi bật | Chữ nhật `48x32` nền Trắng sứ, dấu `+` đỏ |
| 8 | `pack_med_paracetamol` | Vỉ Thuốc Paracetamol 500mg | `32 x 16` | Ngăn Y tế | P1 | Vỉ thuốc nhôm ánh bạc 10 viên nén tròn | Chữ nhật `32x16` nền Bạc kim loại, nhãn "PARA 500" |
| 9 | `pack_med_oresol_pack` | Gói Bột Oresol Bù Điện Giải | `24 x 24` | Ngăn Y tế | P1 | 2 gói bột oresol cam/xanh lá có hình giọt nước | Vuông `24x24` nền Cam sáng, nhãn "ORESOL" |
| 10 | `pack_tech_laptop_sleeve` | Laptop Trong Túi Chống Sốc | `64 x 48` | Ngăn Công nghệ | **P0 (Bắt buộc)** | Máy tính xách tay đặt gọn trong túi nỉ chống sốc màu xám đen | Chữ nhật `64x48` nền Xám than, nhãn "LAPTOP" |
| 11 | `pack_tech_power_strip` | Ổ Cắm Nối Dài 3 Chấu | `48 x 24` | Ngăn Công nghệ | **P0 (Bắt buộc)** | Ổ cắm 4 cổng màu trắng kem có công tắc đỏ an toàn | Chữ nhật `48x24` nền Vàng nhạt có icon phích cắm |
| 12 | `pack_bad_giant_teddy` | Gấu Bông Khổng Lồ (Vật cấm) | `64 x 64` | Đồ vật bẫy | **P0 (Bắt buộc)** | Chú gấu bông bự chảng chiếm hết diện tích vali | Vuông `64x64` viền đỏ, nhãn "GẤU BÔNG ❌" |
| 13 | `pack_bad_hotpot_cooker` | Nồi Lẩu Điện Siêu To (Vật cấm) | `48 x 48` | Đồ vật bẫy | **P0 (Bắt buộc)** | Nồi lẩu kim loại tròn cồng kềnh vi phạm an toàn điện KTX | Vuông `48x48` nền Đỏ bầm, nhãn "NỒI LẨU ❌" |
| **II** | **CHỦ ĐỀ 2: TÌM ĐIỂM KHÁC BIỆT PHÒNG TRỌ (SPOT THE DIFFERENCE 2D)** | | | | | | |
| 14 | `diff_room_clean_photo` | Bức Ảnh Phòng Mẫu Quảng Cáo | `280 x 180` | Nửa trên màn hình | **P0 (Bắt buộc)** | Căn phòng trọ 2D phẳng chuẩn sạch sẽ, tường trắng phẳng mịn, vòi nước sáng, cửa khóa mới | Khung tranh pixel 2D phòng trọ màu pastel tươi sáng |
| 15 | `diff_room_actual_photo` | Bức Ảnh Phòng Thực Tế Khi Xem | `280 x 180` | Nửa dưới màn hình | **P0 (Bắt buộc)** | Căn phòng trọ 2D góc nhìn y hệt nhưng có 5-6 điểm hư hại (nước rỉ, ố trần, khóa lỏng, v.v.) | Khung tranh pixel 2D kèm các vùng lỗi chấm mờ |
| 16 | `diff_red_marker_circle` | Vòng Tròn Đỏ Khoanh Điểm Lỗi | `32 x 32` | Hiệu ứng khi bấm trúng | **P0 (Bắt buộc)** | Vòng tròn nét cọ màu đỏ vẽ tay phong cách pixel đánh dấu điểm khác biệt | Vòng tròn đỏ pixel rỗng ruột nhấp nháy |
| 17 | `diff_handover_report_ui` | Biên Bản Khiếm Khuyết Phòng | `240 x 300` | Popup phán quyết | P1 | Mẫu biên bản ghi chú các lỗi đã phát hiện để ép giá hoặc yêu cầu sửa chữa | Khung giấy A4 vàng ngà có dấu tích checklist |
| **III** | **CHỦ ĐỀ 3: BỘ BA MINIGAME Y TẾ (HEALTHCARE TRILOGY)** | | | | | | |
| 18 | `med_cabinet_shelf_bg` | Kệ Tủ Thuốc Gia Đình 2D | `300 x 360` | `doctor_simulation_game` | **P0 (Bắt buộc)** | Tủ thuốc treo tường bằng gỗ 3 tầng mở cửa kính để lộ các ngăn thuốc | Khung tủ gỗ 3 tầng viền pixel nâu |
| 19 | `med_blister_berberin` | Vỉ Thuốc Berberin Vàng | `32 x 16` | Tủ thuốc phòng khám | P1 | Vỉ thuốc nhôm gồm các viên nang màu vàng trị tiêu chảy đau bụng | Chữ nhật `32x16` màu Vàng nghệ `#FBC02D` |
| 20 | `med_bottle_povidone` | Chai Cồn Đỏ Povidone 20ml | `16 x 24` | Tủ thuốc phòng khám | P1 | Chai nhựa màu nâu nắp vàng có nhãn chữ thập sát trùng | Chai trụ `16x24` màu Nâu đỏ sát khuẩn |
| 21 | `med_saline_nacl` | Chai Nước Muối Sinh Lý 500ml | `20 x 40` | Tủ thuốc phòng khám | P1 | Chai nhựa trong suốt đựng dung dịch NaCl 0.9% rửa vết thương | Chai trụ `20x40` màu Lam nhạt trong suốt |
| 22 | `med_antibiotic_trap` | Vỉ Thuốc Kháng Sinh (Vật bẫy) | `32 x 16` | Tủ thuốc phòng khám | **P0 (Bắt buộc)** | Vỉ thuốc con nhộng 2 màu xanh-đỏ có cảnh báo không tự ý dùng bừa | Chữ nhật `32x16` 2 màu tương phản, viền cảnh báo |
| 23 | `health_thermo_lcd_39` | Nhiệt Kế Điện Tử Số 39.0°C | `48 x 20` | `doctor_simulation_game` | **P0 (Bắt buộc)** | Nhiệt kế màn hình LCD phát sáng số đỏ nhấp nháy `39.0°C` | Chữ nhật xám hiển thị số pixel `39.0°C` |
| 24 | `health_wet_towel_warm` | Khăn Nhúng Nước Ấm | `32 x 16` | `doctor_simulation_game` | P1 | Khăn cotton ẩm bốc làn hơi nước ấm nhẹ nhàng dùng lau mát | Chữ nhật lam ngọc có icon làn hơi nước |
| 25 | `bhyt_phone_vneid_card` | Màn Hình Thẻ BHYT App VNeID | `64 x 96` | `hospital_bhyt_game` | **P0 (Bắt buộc)** | Màn hình điện thoại hiển thị thẻ BHYT số kèm ảnh mèo và mã QR xác thực | Khung điện thoại có thẻ màu Xanh BHYT + mã QR |
| 26 | `bhyt_queue_ticket` | Phiếu Số Thứ Tự Khám Bệnh | `24 x 32` | `hospital_bhyt_game` | P1 | Cuống phiếu in nhiệt màu trắng có số thứ tự to rõ "STT: 042" | Giấy trắng răng cưa in số pixel đen |
| 27 | `bhyt_prescription_sheet` | Toa Thuốc Bác Sĩ Có Dấu BHYT | `32 x 48` | `hospital_bhyt_game` | P1 | Tờ đơn thuốc chữ bác sĩ có dấu mộc tròn đỏ của bệnh viện | Tờ giấy có dòng chữ kẻ ngang và con dấu đỏ |
| **IV** | **CHỦ ĐỀ 4: BỘ ĐÔI MINIGAME XE BUÝT (TRANSIT DUO)** | | | | | | |
| 28 | `bus_app_map_interface` | Giao Diện Bản Đồ BusMap 2D | `300 x 420` | `bus_route_finder_game` | **P0 (Bắt buộc)** | Khung màn hình app điện thoại có bản đồ đường phố 2D, các trạm dừng và tuyến buýt | Khung app di động viền pixel với nền bản đồ ô cờ |
| 29 | `bus_stop_station_sign` | Biển Báo Nhà Chờ Xe Buýt | `32 x 64` | `bus_journey_sim_game` | **P0 (Bắt buộc)** | Biển báo hình chữ nhật màu xanh dương có hình xe buýt trắng gắn trên cột kim loại | Cột biển báo xanh lam chuẩn hiệu lệnh giao thông |
| 30 | `bus_bell_stop_button` | Nút Chuông Báo Xuống Xe (STOP) | `32 x 32` | `bus_journey_sim_game` | **P0 (Bắt buộc)** | Hộp nút bấm tròn màu vàng có nút bấm đỏ nổi chữ "STOP" | Khối vuông viền vàng, nút bấm đỏ giữa |
| 31 | `bus_pos_tap_machine` | Máy Quẹt Thẻ POS Cạnh Cửa Xe | `32 x 32` | `bus_journey_sim_game` | P1 | Máy quét thẻ hình chữ nhật màu đen có màn hình xanh và biểu tượng sóng NFC | Khối màu đen có vạch sóng xanh lá phát sáng |
| 32 | `bus_student_pass_card` | Thẻ Xe Buýt Sinh Viên Thông Minh | `32 x 20` | `bus_journey_sim_game` | P1 | Thẻ nhựa màu xanh dương in logo trường đại học và ảnh thẻ mèo sinh viên | Thẻ hình chữ nhật xanh viền trắng |
| **V** | **CHỦ ĐỀ 5: BẪY TÀI CHÍNH & HỆ THỐNG 3 HŨ 90 CÁ (FINANCE & BUDGET JARS)** | | | | | | |
| 33 | `scam_sms_phone_screen` | Điện Thoại Nhận Tin Nhắn Rác | `160 x 240` | `finance_scam_hunter_game` | **P0 (Bắt buộc)** | Màn hình tin nhắn SMS có bong bóng chat chứa link lừa đảo ngân hàng/việc nhẹ | Khung tin nhắn điện thoại với dòng link đỏ cảnh báo |
| 34 | `stamp_scam_red_badge` | Con Dấu "LỪA ĐẢO / SCAM" Đỏ | `48 x 24` | `finance_scam_hunter_game` | **P0 (Bắt buộc)** | Con dấu chữ nhật viền đôi màu đỏ son in hoa chữ "LỪA ĐẢO" nằm nghiêng 15 độ | Con dấu đỏ chữ trắng đậm nét pixel |
| 35 | `contract_bnpl_paper` | Hợp Đồng Vay Mua Trước Trả Sau | `48 x 64` | `finance_scam_hunter_game` | P1 | Tờ giấy hợp đồng có dòng chữ li ti phóng to chữ "PHÍ PHẠT 150%" | Tờ giấy viền xám có kính lúp soi chữ nhỏ |
| 36 | `jar_essential_50` | Hũ 1: Thiết Yếu (50% = 45 Cá) | `32 x 48` | `BudgetJarsWidget` (Phòng trọ) | **P0 (Bắt buộc)** | Hũ thủy tinh trong suốt nắp bần chứa 45 con cá khô vàng, nhãn "THIẾT YẾU" | Hũ thủy tinh viền lam nhạt đầy ắp cá |
| 37 | `jar_growth_30` | Hũ 2: Phát Triển (30% = 27 Cá) | `32 x 48` | `BudgetJarsWidget` (Phòng trọ) | **P0 (Bắt buộc)** | Hũ thủy tinh chứa 27 con cá khô, nhãn "PHÁT TRIỂN / HỌC TẬP" | Hũ thủy tinh chứa 2/3 lượng cá |
| 38 | `jar_emergency_20` | Hũ 3: Khẩn Cấp (20% = 18 Cá) | `32 x 48` | `BudgetJarsWidget` (Phòng trọ) | **P0 (Bắt buộc)** | Hũ thủy tinh có dấu chữ thập đỏ chứa 18 con cá khô dự phòng ốm đau | Hũ thủy tinh chứa 1/3 lượng cá kèm dấu thập đỏ |

---

## 3. CƠ CHẾ NẠP AN TOÀN TỰ ĐỘNG
- Khi bạn chưa kịp tìm đủ các asset trên, hệ thống `PixelPlaceholderFactory.gd` sẽ tự động tạo ảnh giữ chỗ chuẩn pixel art với màu sắc và nhãn tương ứng.
- Khi bạn tìm được file hình ảnh `.png`, chỉ cần chép vào các thư mục:
  * `res://assets/sprites/minigames/packing/`
  * `res://assets/sprites/minigames/inspection/`
  * `res://assets/sprites/minigames/healthcare/`
  * `res://assets/sprites/minigames/transit/`
  * `res://assets/sprites/minigames/finance/`
  Game sẽ tự động nhận diện và thay thế ảnh placeholder bằng sprite thật của bạn mà không cần phải sửa một dòng code nào!
