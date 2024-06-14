# Quản lý hầm rượu vang nhỏ của Tom
Hầm rượu vang, dù nhỏ, vẫn đòi hỏi một hệ thống quản lý chi tiết để theo dõi số lượng, loại rượu, năm sản xuất và các thông tin khác về mỗi chai rượu. Điều này tạo cơ hội để em thiết kế một cơ sở dữ liệu đa bảng với các mối quan hệ phong phú. Đồng thời, quy mô nhỏ giúp dự án vừa sức trong khuôn khổ một bài tập lớn, cho phép tập trung vào việc áp dụng các nguyên tắc thiết kế cơ sở dữ liệu, xây dựng truy vấn, thủ tục hợp lý. Ngoài ra, đề tài này cũng mở ra khả năng mở rộng trong tương lai, như tích hợp các tính năng vị trí lưu trữ hoặc phát triển nâng cao hệ thống đặt hàng, làm cho nó trở thành một dự án thú vị và có giá trị học tập cao.

# Table
1. Bảng Ruou

||Column Name|Data Type|Allow Null|
|--|--|--|--|
|PK|RuouID|INT|NOT NULL|
||Ten|NVARCHAR(255)||
|FK|LoaiRuouID|INT||
||NamSanXuat|INT|| 
||GiaCoBan|DECIMAL(10,2) ||

2. Bảng LoaiRuou

||Column Name|Data Type|Allow Null|
|--|--|--|--|
|PK|LoaiRuouID|INT| NOT NULL|
||TenLoai|NVARCHAR(255)|NOT NULL|

3. Bảng KhachHang

| |Column Name|Data Type|Allow Null|
|--|--|--|--|
|PK|KhachHangID|INT|NOT NULL|
||Ten|NVARCHAR(255)|NOT NULL|
||DiaChi|NVARCHAR(255)||
||DienThoai|NVARCHAR(20)||
||Email|NVARCHAR(255)|| 
||NgaySinh|DATE||

4. Bảng DonDatHang

| |Column Name|Data Type|Allow Null|
|--|--|--|--|
|PK|DonDatHangID|INT|NOT NULL|
|FK|KhachHangID|INT||
||NgayDat|DATE||
||TongTien|DECIMAL(10,2)||

5. Bảng ChiTietDonHang

||Column Name|Data Type|Allow Null|
|--|--|--|--|
|PK|ChiTietDonHangID|INT|NOT NULL|
|FK|DonDatHangID|INT||
|FK|RuouID|INT||
||SoLuong|INT||
||GiaBan|DECIMAL(10,2)||

6. Bảng HangTonKho

| |Column Name|Data Type|Allow Null|
|--|--|--|--|
|PK|HangTonKhoID|INT||
|FK|RuouID|INT||
||SoLuong|INT||

Tạo sơ đồ thực thể 
![image](https://github.com/hoanggchinh/QuanLyHamRuouVangLX/assets/168759759/ed27f4b1-948d-494e-8c61-5ef6a3fd0b90)

