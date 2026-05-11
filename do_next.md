profile_onboarding_screen.dart
1. Đổi field năm cấp trong từ nhập thủ công thành mở dialog chọn năm sau đó lại parse sang int như ban đầu.
2. Nơi cấp tạo 1 dropdown gồm 3 field để chọn gồm: Bộ công an, Công an tỉnh, Cục cảnh sát quản lý hành chính về trật tự xã hội.
3. Validate field số điện thoại trong liên hệ khẩn cấp.
4. Mỗi quan hệ tạo dropdown gồm các trường: Bố, Mẹ, Anh, Chị, Em, Con, Cháu, Ông, Bà, Chú, Bác, Thím, Cô, Cậu, Mợ, Dì, Vợ, Chồng, Con dâu, Con rể.
5. Phần cư trú cả địa chỉ thường trú và hiện tại đều sử dụng api provinces.open-api.vn và xây dựng dropdown để chọn địa chỉ tỉnh/ thành phố, quận/huyện, phường/xã giống như các app có chọn địa chỉ.
6. Tình trạng sức khỏe tạo dropdown gồm: Tốt, Bình thường, Yếu.
7. Tình trạng hôn nhân bổ sung vào dropdown các trường sau: Độc thân, Đã kết hôn, Đã ly hôn, Góa, Ly thân, Đính hôn, Tái hôn.
8. Trình độ học vấn tạo Dropdown các trường như sau: Mầm non, Tiểu học, Trung học cơ cở, Trung học phổ thông, Cao đẳng, Đại học, Thạc sĩ, Tiến sĩ, Phó giáo sư, Giáo sư.
