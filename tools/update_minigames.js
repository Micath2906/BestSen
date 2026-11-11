const fs = require('fs');
const path = require('path');

const filePath = path.join(__dirname, '../assets/data/minigames_data.json');
const data = JSON.parse(fs.readFileSync(filePath, 'utf8'));

// 1. Relocate existing QTE (key 3) to key 7 if present
if (data.minigames['3'] && data.minigames['3'].type === 'qte') {
  const qteGame = data.minigames['3'];
  qteGame.lesson_id = 7;
  data.minigames['7'] = qteGame;
}

// 2. Define Key 2: hospital_choice (Kỹ năng 2: Lựa chọn bệnh viện đúng bệnh)
data.minigames['2'] = {
  type: 'hospital_choice',
  lesson_id: 2,
  title: 'Lựa chọn bệnh viện đúng bệnh',
  subtitle: 'Kỹ năng: Đánh giá tình hình bạn cùng phòng & Chọn đúng chuyên khoa và bệnh viện',
  instruction: 'Quan sát triệu chứng của Bạn Cùng Phòng, chọn đúng Chuyên Khoa điều trị và Bệnh Viện chuyên sâu tuyến đầu!',
  cat_prompt: 'Sen ơi! Bạn cùng phòng đang đau đớn kêu cứu kìa! Hãy chọn đúng chuyên khoa và bệnh viện để đưa bạn đi cấp cứu ngay nhé!',
  warning_rule: '⚠️ LƯU Ý SỐNG CÒN: Chọn sai bất kỳ câu nào sẽ phải QUAY LẠI TỪ ĐẦU vì nguy cơ bỏ lỡ thời gian vàng cấp cứu!',
  success_msg: '🎉 CẤP CỨU THÀNH CÔNG! Bác sĩ đã kịp thời điều trị, bạn cùng phòng đã an toàn và hồi phục ngoạn mục! 🌟',
  sim_steps: [
    { icon: '🤕', text: 'Khám triệu chứng bạn cùng phòng' },
    { icon: '🩺', text: 'Xác định chuyên khoa điều trị' },
    { icon: '🏥', text: 'Chọn đúng bệnh viện chuyên sâu' },
    { icon: '🚑', text: 'Cấp cứu kịp thời đúng nơi' }
  ],
  cases: [
    {
      case_id: 'case_fracture',
      patient_name: 'Mèo Mướp Cùng Phòng',
      patient_avatar: 'res://assets/sprites/skills/lesson_02_step_1.png',
      situation_desc: "Mèo Mướp vừa trượt chân ngã từ cầu thang gác xép trọ xuống, ôm cổ chân khóc thét: 'Aaaaa! Chân tớ sưng vù biến dạng lệch hẳn sang một bên, đau buốt không cử động được nữa rồi! Cứu tớ với!'",
      vital_status: 'Chấn thương cơ xương khớp cấp - Nghi gãy kín xương cẳng chân',
      phase_1_question: 'Với tình trạng cổ chân biến dạng đau dữ dội nghi gãy xương, cần đưa bạn vào Chuyên Khoa nào?',
      phase_1_options: [
        {
          id: 'p1_opt_bone',
          icon: '🦴',
          title: 'Chuyên Khoa Chấn Thương Chỉnh Hình & X-Quang',
          desc: 'Chuyên chụp phim chẩn đoán nứt gãy xương, bó bột và phẫu thuật chỉnh hình khớp.',
          is_correct: true
        },
        {
          id: 'p1_opt_skin',
          icon: '💅',
          title: 'Chuyên Khoa Da Liễu & Thẩm Mỹ',
          desc: 'Chuyên điều trị mụn nhọt, viêm da cơ địa và chăm sóc sắc đẹp.',
          is_correct: false,
          fail_reason: 'Gãy xương sưng vù mà đưa sang Da Liễu thì bác sĩ cũng bó tay! Mất thời gian vàng cấp cứu!'
        },
        {
          id: 'p1_opt_dental',
          icon: '🦷',
          title: 'Chuyên Khoa Răng Hàm Mặt',
          desc: 'Chuyên nhổ răng khôn, trám răng sâu và niềng răng thẩm mỹ.',
          is_correct: false,
          fail_reason: 'Bạn đau chân gãy xương chứ có đau răng đâu! Đưa nhầm khoa làm bạn đau đớn thêm!'
        }
      ],
      phase_2_question: 'Xác định được Chuyên Khoa Chấn Thương Chỉnh Hình, bạn nên chọn Bệnh Viện chuyên sâu nào?',
      phase_2_options: [
        {
          id: 'p2_opt_ortho',
          icon: '🏥',
          title: 'Bệnh Viện Chấn Thương Chỉnh Hình TP',
          desc: 'Bệnh viện tuyến cuối chuyên khoa sâu về xương khớp, vi phẫu và cấp cứu chấn thương.',
          is_correct: true
        },
        {
          id: 'p2_opt_derma',
          icon: '🏥',
          title: 'Bệnh Viện Da Liễu TP',
          desc: 'Cơ sở điều trị các bệnh lý ngoài da và dị ứng tiếp xúc.',
          is_correct: false,
          fail_reason: 'Bệnh viện Da Liễu không có phòng mổ chấn thương xương! Phải làm thủ tục chuyển viện rất lâu!'
        },
        {
          id: 'p2_opt_clinic',
          icon: '🦷',
          title: 'Phòng Khám Nha Khoa Tư Nhân Ven Đường',
          desc: 'Cơ sở nha khoa tư nhân không có máy chụp X-quang toàn thân.',
          is_correct: false,
          fail_reason: 'Phòng khám nha khoa tư nhân hoàn toàn không có chức năng cấp cứu gãy xương!'
        }
      ]
    },
    {
      case_id: 'case_dengue',
      patient_name: 'Mèo Vàng Cùng Phòng',
      patient_avatar: 'res://assets/sprites/skills/lesson_02_step_2.png',
      situation_desc: "Mèo Vàng nằm li bì trên giường ngày thứ 3, sốt cao 39.5°C không hạ, hai mắt đỏ ngầu, người run rẩy: 'Người tớ nóng rực như lửa đốt, nhức buốt hai hốc mắt, dưới da tay bắt đầu nổi nhiều nốt chấm đỏ li ti không lặn...'",
      vital_status: 'Dấu hiệu cảnh báo Sốt Xuất Huyết Dengue ngày thứ 3 - Nguy cơ sốc giảm tiểu cầu',
      phase_1_question: 'Sốt cao li bì kèm xuất huyết dưới da và đau nhức hốc mắt cần cấp cứu tại Chuyên Khoa nào?',
      phase_1_options: [
        {
          id: 'p1_opt_tropical',
          icon: '🦟',
          title: 'Chuyên Khoa Truyền Nhiễm & Bệnh Nhiệt Đới',
          desc: 'Chuyên xét nghiệm máu đếm tiểu cầu, điều trị sốt xuất huyết, cúm và nhiễm virus cấp.',
          is_correct: true
        },
        {
          id: 'p1_opt_rehab',
          icon: '🏋️',
          title: 'Chuyên Khoa Phục Hồi Chức Năng',
          desc: 'Chuyên tập vật lý trị liệu sau tai biến, thoái hóa khớp.',
          is_correct: false,
          fail_reason: 'Đang sốt cao xuất huyết cấp tính mà đưa đi tập vật lý trị liệu là nguy hiểm tính mạng!'
        },
        {
          id: 'p1_opt_ent',
          icon: '👂',
          title: 'Chuyên Khoa Tai Mũi Họng',
          desc: 'Chuyên nội soi tai, hút mũi xoang và cắt amidan.',
          is_correct: false,
          fail_reason: 'Nốt xuất huyết dưới da là bệnh toàn thân do virus, không phải viêm amidan thông thường!'
        }
      ],
      phase_2_question: 'Cần đưa ngay Mèo Vàng tới Bệnh Viện chuyên sâu nào để xét nghiệm tiểu cầu và truyền dịch cấp cứu?',
      phase_2_options: [
        {
          id: 'p2_opt_trop_hosp',
          icon: '🏥',
          title: 'Bệnh Viện Bệnh Nhiệt Đới TP',
          desc: 'Bệnh viện tuyến đầu chuyên sâu về bệnh truyền nhiễm, dịch tễ và hồi sức sốt xuất huyết.',
          is_correct: true
        },
        {
          id: 'p2_opt_tcm',
          icon: '🌿',
          title: 'Viện Y Học Cổ Truyền',
          desc: 'Chuyên châm cứu, bấm huyệt và sắc thuốc bắc bồi bổ cơ thể.',
          is_correct: false,
          fail_reason: 'Sốt xuất huyết tiểu cầu tụt dốc rất nhanh, châm cứu hay sắc thuốc bắc sẽ gây trễ cấp cứu!'
        },
        {
          id: 'p2_opt_spa',
          icon: '✨',
          title: 'Viện Thẩm Mỹ Trẻ Hóa Da Quốc Tế',
          desc: 'Cơ sở làm đẹp, triệt lông và massage thư giãn.',
          is_correct: false,
          fail_reason: 'Bạn đang nguy kịch vì sốt virus mà đưa vào thẩm mỹ viện là trò đùa nguy hiểm!'
        }
      ]
    },
    {
      case_id: 'case_chemical_eye',
      patient_name: 'Mèo Mun Cùng Phòng',
      patient_avatar: 'res://assets/sprites/skills/lesson_02_step_3.png',
      situation_desc: "Mèo Mun vừa dọn bồn cầu phòng trọ thì chai nước tẩy cực mạnh bị bung nắp bắn thẳng vào mắt, Mèo ôm mặt quằn quại: 'Á á á! Nước tẩy bắn vào mắt tớ rát bỏng như lửa thiêu, mắt nhắm nghiền không mở ra được, chảy nước mắt xối xả!'",
      vital_status: 'Bỏng hóa chất kiềm/axit ở mắt cấp tính - Nguy cơ tổn thương giác mạc vĩnh viễn',
      phase_1_question: 'Hóa chất tẩy rửa bắn trực tiếp vào mắt cần sơ cứu xả nước sạch và đưa ngay tới Chuyên Khoa nào?',
      phase_1_options: [
        {
          id: 'p1_opt_eye',
          icon: '👁️',
          title: 'Chuyên Khoa Nhãn Khoa (Mắt) Cấp Cứu',
          desc: 'Chuyên rửa mắt khử trùng hóa chất, soi đáy mắt và cấp cứu giác mạc 24/7.',
          is_correct: true
        },
        {
          id: 'p1_opt_cardio',
          icon: '❤️',
          title: 'Chuyên Khoa Tim Mạch Can Thiệp',
          desc: 'Chuyên đo điện tim, nong mạch vành và đặt stent tim.',
          is_correct: false,
          fail_reason: 'Bị bỏng mắt do hóa chất lại đưa vào khoa Tim mạch là nhầm lẫn tai hại!'
        },
        {
          id: 'p1_opt_gastro',
          icon: '🍔',
          title: 'Chuyên Khoa Tiêu Hóa Gan Mật',
          desc: 'Chuyên nội soi dạ dày, đại tràng và men gan.',
          is_correct: false,
          fail_reason: 'Khoa Tiêu Hóa không có dụng cụ đo thị lực và rửa trung hòa hóa chất giác mạc!'
        }
      ],
      phase_2_question: 'Bệnh viện chuyên khoa mắt đầu ngành nào có đội ngũ bác sĩ cấp cứu giác mạc 24/24 tốt nhất?',
      phase_2_options: [
        {
          id: 'p2_opt_eye_hosp',
          icon: '🏥',
          title: 'Bệnh Viện Mắt TP',
          desc: 'Bệnh viện chuyên khoa mắt tuyến đầu, đầy đủ phòng cấp cứu giác mạc và máy rửa hóa chất chuyên dụng.',
          is_correct: true
        },
        {
          id: 'p2_opt_dent_center',
          icon: '🦷',
          title: 'Bệnh Viện Răng Hàm Mặt Trung Ương',
          desc: 'Cơ sở chuyên phẫu thuật hàm mặt và nha khoa tổng quát.',
          is_correct: false,
          fail_reason: 'Bệnh viện Răng Hàm Mặt không có chuyên khoa sâu về giác mạc và rửa hóa chất mắt!'
        },
        {
          id: 'p2_opt_vax_center',
          icon: '💉',
          title: 'Trung Tâm Tiêm Chủng Vắc-xin',
          desc: 'Cơ sở chỉ tiếp nhận tiêm ngừa theo lịch hẹn.',
          is_correct: false,
          fail_reason: 'Trung tâm tiêm chủng không nhận cấp cứu chấn thương hay bỏng hóa chất!'
        }
      ]
    }
  ]
};

// 3. Define Key 3: medicine_diagnosis (Kỹ năng 3: Xác định đúng bệnh của bản thân trước khi uống thuốc)
data.minigames['3'] = {
  type: 'medicine_diagnosis',
  lesson_id: 3,
  title: 'Xác định đúng bệnh của bản thân trước khi uống thuốc',
  subtitle: 'Kỹ năng: Chọn vật phẩm chẩn đoán trong hộp cứu thương & Tìm đúng thuốc đặc trị',
  instruction: 'Lượt 1: Chọn vật phẩm chẩn đoán chính xác ➔ Xem bảng thống kê thông tin. Lượt 2: Tìm đúng thuốc đặc trị tương ứng!',
  cat_prompt: 'Meo meo! Tuyệt đối không đoán mò uống thuốc bừa bãi! Hãy dùng dụng cụ y tế kiểm tra rồi chọn đúng thuốc chữa bệnh nhé Sen!',
  warning_rule: '🚨 CẢNH BÁO Y TẾ: Sai ở bất kỳ lượt nào = GAME OVER ngay lập tức vì uống sai thuốc cực kỳ nguy hiểm!',
  success_msg: '🎉 CHẨN ĐOÁN & UỐNG THUỐC CHUẨN XÁC! Chỉ số sức khỏe đã ổn định, Mèo hồi phục an toàn tuyệt đối! 🌟',
  sim_steps: [
    { icon: '🌡️', text: 'Dùng dụng cụ đo chỉ số cơ thể' },
    { icon: '📋', text: 'Lập bảng thống kê triệu chứng' },
    { icon: '💊', text: 'Chọn đúng thuốc đặc trị' },
    { icon: '✨', text: 'Hồi phục sức khỏe an toàn' }
  ],
  cases: [
    {
      case_id: 'case_fever',
      case_title: 'Ca 1: Cơ thể nóng rực, nhức đầu lúc nửa đêm',
      situation_desc: 'Đồng hồ điểm 23:30, Mèo con thấy người nóng bừng bừng, hai má đỏ ửng, đầu đau như búa bổ và rét run trong chăn. Mèo cần kiểm tra chính xác nhiệt độ trước khi quyết định uống thuốc.',
      turn_1_prompt: 'LƯỢT 1: Chọn vật phẩm chẩn đoán phù hợp trong Hộp Cứu Thương:',
      turn_1_items: [
        {
          id: 'tool_thermometer',
          name: 'Nhiệt kế điện tử kẹp nách',
          icon: '🌡️',
          desc: 'Đo chính xác thân nhiệt cơ thể sau tiếng bíp',
          is_correct: true
        },
        {
          id: 'tool_bandaid',
          name: 'Băng keo cá nhân Urgo',
          icon: '🩹',
          desc: 'Bảo vệ vết trầy xước nông ngoài da',
          is_correct: false,
          fail_msg: 'Đang nóng bừng sốt cao mà dán băng Urgo thì làm sao biết sốt bao nhiêu độ! GAME OVER!'
        },
        {
          id: 'tool_scissor',
          name: 'Kéo y tế đầu tù',
          icon: '✂️',
          desc: 'Dùng cắt băng gạc và quần áo cấp cứu',
          is_correct: false,
          fail_msg: 'Lấy kéo y tế làm gì khi đang nóng đầu sốt cao? Chẩn đoán sai lầm! GAME OVER!'
        },
        {
          id: 'tool_magnifier',
          name: 'Kính lúp soi da cầm tay',
          icon: '🔍',
          desc: 'Quan sát dị vật hoặc nốt côn trùng cắn',
          is_correct: false,
          fail_msg: 'Kính lúp không đo được thân nhiệt! Không biết nhiệt độ mà uống thuốc là ngộ độc! GAME OVER!'
        }
      ],
      diagnosis_stat_sheet: {
        title: '📋 BẢNG THỐNG KÊ CHỈ SỐ Y TẾ (CA 1)',
        tool_used: 'Nhiệt kế điện tử kẹp nách (bíp báo hiệu)',
        measured_value: '38.9°C (Báo động sốt cao cấp tính)',
        vital_signs: 'Nhịp tim: 98 bpm • Huyết áp: 115/75 mmHg • Môi khô khát nước',
        clinical_notes: 'Sốt trên 38.5°C gây nguy cơ co giật và mất nước nhanh.',
        conclusion: 'KẾT LUẬN: SỐT CAO CẤP TÍNH & MẤT NƯỚC ĐIỆN GIẢI',
        treatment_goal: 'Cần thuốc hạ sốt giảm đau Paracetamol (10-15mg/kg) + Bù nước Oresol.'
      },
      turn_2_prompt: 'LƯỢT 2: Dựa trên Bảng Thống Kê, hãy chọn đúng lọ thuốc đặc trị cần dùng:',
      turn_2_items: [
        {
          id: 'med_para_oresol',
          name: 'Paracetamol 500mg + Gói Oresol bù nước',
          icon: '💊',
          desc: 'Hạ nhiệt độ an toàn, xoa dịu đau đầu và bù lượng nước mất do mồ hôi.',
          is_correct: true
        },
        {
          id: 'med_antibiotic',
          name: 'Kháng sinh Amoxicillin 500mg',
          icon: '💊',
          desc: 'Thuốc tiêu diệt vi khuẩn theo đơn bác sĩ',
          is_correct: false,
          fail_msg: 'NGUY HIỂM TỘT ĐỘ! Mới chớm sốt đã tự ý uống kháng sinh bừa bãi sẽ hủy hoại đường ruột và gây siêu vi khuẩn kháng thuốc! GAME OVER!'
        },
        {
          id: 'med_berberin',
          name: 'Berberin Vàng trị đau bụng',
          icon: '💊',
          desc: 'Chữa tiêu chảy và nhiễm khuẩn ruột',
          is_correct: false,
          fail_msg: 'Bạn đang sốt 38.9°C chứ không hề bị tiêu chảy! Uống sai thuốc không hạ sốt được! GAME OVER!'
        },
        {
          id: 'med_cooling_oil',
          name: 'Dầu gió cay nóng bôi trán',
          icon: '🧴',
          desc: 'Dầu xoa bóp sinh nhiệt',
          is_correct: false,
          fail_msg: 'SAI LẦM! Đang sốt cao mà bôi dầu nóng vào trán sẽ làm cơ thể tích nhiệt không thoát được mồ hôi! GAME OVER!'
        }
      ]
    },
    {
      case_id: 'case_stomach',
      case_title: 'Ca 2: Đau quặn bụng và tiêu chảy sau bữa ốc vỉa hè',
      situation_desc: 'Sau khi ăn đĩa ốc luộc và nghêu hấp vỉa hè lúc chập tối, đến 2 giờ sáng Mèo con ôm bụng quằn quại, bụng sôi ùng ục, chạy vào toilet 4 lần liên tiếp, người lả đi vì mất nước.',
      turn_1_prompt: 'LƯỢT 1: Chọn vật phẩm chẩn đoán phù hợp trong Hộp Cứu Thương:',
      turn_1_items: [
        {
          id: 'tool_digestive_chart',
          name: 'Bảng theo dõi triệu chứng tiêu hóa & mất nước',
          icon: '📋',
          desc: 'Đánh giá số lần đi ngoài, tính chất phân và mức độ mất nước',
          is_correct: true
        },
        {
          id: 'tool_stethoscope',
          name: 'Ống nghe tim phổi y tế',
          icon: '🩺',
          desc: 'Nghe tiếng tim đập và phế âm phổi',
          is_correct: false,
          fail_msg: 'Ống nghe tim phổi không giúp định lượng mức độ mất nước hay vi khuẩn đường ruột! GAME OVER!'
        },
        {
          id: 'tool_flashlight',
          name: 'Đèn pin y tế soi họng',
          icon: '🔦',
          desc: 'Soi niêm mạc vòm họng và đáy mắt',
          is_correct: false,
          fail_msg: 'Đau bụng đi ngoài mà đi soi họng là khám nhầm vị trí hoàn toàn! GAME OVER!'
        },
        {
          id: 'tool_pain_patch',
          name: 'Miếng dán giảm đau Salonpas',
          icon: '🩹',
          desc: 'Dán giảm đau nhức cơ bắp',
          is_correct: false,
          fail_msg: 'Đau bụng nhiễm trùng mà dán salonpas nóng rát bụng là sai phác đồ! GAME OVER!'
        }
      ],
      diagnosis_stat_sheet: {
        title: '📋 BẢNG THỐNG KÊ CHỈ SỐ Y TẾ (CA 2)',
        tool_used: 'Bảng nhật ký tiêu hóa & Thước đo mất nước',
        measured_value: 'Đi ngoài phân lỏng: 4 lần / 2 giờ • Đau quặn quắt rốn',
        vital_signs: 'Nhiệt độ: 37.1°C • Mạch: 92 bpm • Dấu hiệu khát nước rõ',
        clinical_notes: 'Ngộ độc thực phẩm đường ruột nhẹ do vi khuẩn thức ăn vỉa hè.',
        conclusion: 'KẾT LUẬN: NHIỄM KHUẨN TIÊU HÓA CẤP TÍNH & MẤT NƯỚC',
        treatment_goal: 'Dùng thảo dược kháng khuẩn ruột Berberin + Pha Oresol bù nước chuẩn 200ml.'
      },
      turn_2_prompt: 'LƯỢT 2: Dựa trên Bảng Thống Kê, hãy chọn đúng lọ thuốc đặc trị cần dùng:',
      turn_2_items: [
        {
          id: 'med_berberin_oresol',
          name: 'Berberin Vàng (Vàng Đắng) + Gói Oresol',
          icon: '💊',
          desc: 'Kháng khuẩn thực vật lành tính ức chế vi khuẩn đường ruột, kết hợp bù nước điện giải.',
          is_correct: true
        },
        {
          id: 'med_sedative',
          name: 'Thuốc ngủ / Thuốc an thần',
          icon: '💊',
          desc: 'Gây ngủ sâu ức chế thần kinh',
          is_correct: false,
          fail_msg: 'CỰC KỲ NGUY HIỂM! Uống thuốc ngủ khi đang tiêu chảy sẽ làm liệt ruột ứ độc tố vi khuẩn nguy kịch! GAME OVER!'
        },
        {
          id: 'med_paracetamol',
          name: 'Viên sủi Paracetamol 500mg',
          icon: '💊',
          desc: 'Thuốc hạ nhiệt giảm đau',
          is_correct: false,
          fail_msg: 'Bụng đang loét kích ứng mà uống viên sủi giảm đau sẽ làm hại dạ dày thêm! GAME OVER!'
        },
        {
          id: 'med_throat_spray',
          name: 'Chai xịt sát trùng vòm họng',
          icon: '🧴',
          desc: 'Xịt thơm và kháng khuẩn hầu họng',
          is_correct: false,
          fail_msg: 'Nhiễm khuẩn ở ruột non ruột già chứ không phải ở họng! Chọn sai thuốc! GAME OVER!'
        }
      ]
    },
    {
      case_id: 'case_allergy',
      case_title: 'Ca 3: Nổi mề đay mẩn ngứa và hắt hơi sau dọn bụi trọ',
      situation_desc: 'Dọn dẹp căn gác trọ bụi bặm nhiều năm, Mèo con liên tục hắt hơi đỏ mũi. Vừa ngồi xuống thì khắp hai cánh tay và đùi nổi cộm các mảng sẩn đỏ ngứa rát, càng gãi càng lan rộng.',
      turn_1_prompt: 'LƯỢT 1: Chọn vật phẩm chẩn đoán phù hợp trong Hộp Cứu Thương:',
      turn_1_items: [
        {
          id: 'tool_allergy_ruler',
          name: 'Thước đo sẩn phù & Bảng nhận diện dị ứng da',
          icon: '🔍',
          desc: 'Soi hình thái nốt sẩn phù gồ mặt da, phân biệt với nốt côn trùng đốt',
          is_correct: true
        },
        {
          id: 'tool_thermometer_axilla',
          name: 'Nhiệt kế thủy ngân',
          icon: '🌡️',
          desc: 'Đo thân nhiệt cơ thể',
          is_correct: false,
          fail_msg: 'Dị ứng mề đay không gây sốt, đo nhiệt kế không giải quyết được nguồn gốc mẩn ngứa! GAME OVER!'
        },
        {
          id: 'tool_povidine',
          name: 'Lọ cồn đỏ sát trùng Povidine',
          icon: '🧪',
          desc: 'Sát khuẩn vết thương rách da chảy máu',
          is_correct: false,
          fail_msg: 'Bôi cồn đỏ lên khắp vùng mề đay sẽ gây kích ứng bỏng rát da nặng hơn! GAME OVER!'
        },
        {
          id: 'tool_weight_scale',
          name: 'Cân sức khỏe điện tử',
          icon: '⚖️',
          desc: 'Cân trọng lượng cơ thể',
          is_correct: false,
          fail_msg: 'Đang ngứa điên cuồng vì mề đay mà đi leo lên cân sức khỏe? Chẩn đoán vô lý! GAME OVER!'
        }
      ],
      diagnosis_stat_sheet: {
        title: '📋 BẢNG THỐNG KÊ CHỈ SỐ Y TẾ (CA 3)',
        tool_used: 'Thước đo sẩn phù & Bảng phân loại mề đay',
        measured_value: 'Mảng sẩn gồ đỏ: 2 - 5 cm • Phân bố rải rác tay chân',
        vital_signs: 'Thân nhiệt: 36.8°C (Bình thường) • Hắt xì sổ mũi nước trong',
        clinical_notes: 'Phản ứng giải phóng Histamin dưới da do tiếp xúc mạt bụi và nấm mốc.',
        conclusion: 'KẾT LUẬN: VIÊM MŨI DỊ ỨNG & MỀ ĐAY CẤP TÍNH (DO HISTAMIN)',
        treatment_goal: 'Dùng thuốc kháng Histamin H1 (Clorpheniramin 4mg) + Rửa da bằng nước mát.'
      },
      turn_2_prompt: 'LƯỢT 2: Dựa trên Bảng Thống Kê, hãy chọn đúng lọ thuốc đặc trị cần dùng:',
      turn_2_items: [
        {
          id: 'med_clorpheniramin',
          name: 'Clorpheniramin 4mg (Kháng Histamin H1)',
          icon: '💊',
          desc: 'Ngăn chặn Histamin, dập tắt nhanh cơn ngứa sẩn phù mề đay và ngưng hắt hơi sổ mũi.',
          is_correct: true
        },
        {
          id: 'med_antibiotic_cephalexin',
          name: 'Kháng sinh Cephalexin 500mg',
          icon: '💊',
          desc: 'Diệt khuẩn đường hô hấp',
          is_correct: false,
          fail_msg: 'Dị ứng mạt bụi không phải do vi khuẩn! Uống kháng sinh lúc này cực kỳ dễ gây sốc phản vệ! GAME OVER!'
        },
        {
          id: 'med_mouthwash',
          name: 'Chai nước súc miệng diệt khuẩn',
          icon: '🧴',
          desc: 'Súc sạch khoang miệng',
          is_correct: false,
          fail_msg: 'Mề đay ngứa toàn thân mà súc miệng thì làm sao lặn nốt sẩn được! GAME OVER!'
        },
        {
          id: 'med_weight_pill',
          name: 'Viên uống tăng cân dinh dưỡng',
          icon: '💊',
          desc: 'Bổ sung calo',
          is_correct: false,
          fail_msg: 'Uống thuốc tăng cân khi dị ứng cấp tính là sai sót y khoa nghiêm trọng! GAME OVER!'
        }
      ]
    }
  ]
};

fs.writeFileSync(filePath, JSON.stringify(data, null, 2), 'utf8');
console.log('Successfully updated minigames_data.json!');
console.log('Total minigames: ' + Object.keys(data.minigames).length);
console.log('Keys: ' + Object.keys(data.minigames).join(', '));
