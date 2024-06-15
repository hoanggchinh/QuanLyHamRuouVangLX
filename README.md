# Quản lý hầm rượu vang nhỏ của Tom
Hầm rượu vang, dù nhỏ, vẫn đòi hỏi một hệ thống quản lý chi tiết để theo dõi số lượng, loại rượu, năm sản xuất và các thông tin khác về mỗi chai rượu. Điều này tạo cơ hội để em thiết kế một cơ sở dữ liệu đa bảng với các mối quan hệ phong phú. Đồng thời, quy mô nhỏ giúp dự án vừa sức trong khuôn khổ một bài tập lớn, cho phép tập trung vào việc áp dụng các nguyên tắc thiết kế cơ sở dữ liệu, xây dựng truy vấn, thủ tục hợp lý. Ngoài ra, đề tài này cũng mở ra khả năng mở rộng trong tương lai, như tích hợp các tính năng vị trí lưu trữ hoặc phát triển nâng cao hệ thống đặt hàng, làm cho nó trở thành một dự án thú vị và có giá trị học tập cao.

# Table
**Bảng Ruou**

||Column Name|Data Type|Allow Null|
|--|--|--|--|
|PK|RuouID|INT|NOT NULL|
||Ten|NVARCHAR(255)||
|FK|LoaiRuouID|INT||
|CK|NamSanXuat|INT|| 
|CK|GiaCoBan|DECIMAL(10,2) ||

**Bảng LoaiRuou**

||Column Name|Data Type|Allow Null|
|--|--|--|--|
|PK|LoaiRuouID|INT| NOT NULL|
||TenLoai|NVARCHAR(255)|NOT NULL|

**Bảng KhachHang**

| |Column Name|Data Type|Allow Null|
|--|--|--|--|
|PK|KhachHangID|INT|NOT NULL|
||Ten|NVARCHAR(255)|NOT NULL|
||DiaChi|NVARCHAR(255)||
||DienThoai|NVARCHAR(20)||
||Email|NVARCHAR(255)|| 
|CK|NgaySinh|DATE||

**Bảng DonDatHang**

| |Column Name|Data Type|Allow Null|
|--|--|--|--|
|PK|DonDatHangID|INT|NOT NULL|
|FK|KhachHangID|INT||
||NgayDat|DATE||
||TongTien|DECIMAL(10,2)||

**Bảng ChiTietDonHang**

||Column Name|Data Type|Allow Null|
|--|--|--|--|
|PK|ChiTietDonHangID|INT|NOT NULL|
|FK|DonDatHangID|INT||
|FK|RuouID|INT||
||SoLuong|INT||
||GiaBan|DECIMAL(10,2)||

**Bảng HangTonKho**

| |Column Name|Data Type|Allow Null|
|--|--|--|--|
|PK|HangTonKhoID|INT||
|FK|RuouID|INT||
|CK|SoLuong|INT||

**Tạo sơ đồ thực thể** 
![image](https://github.com/hoanggchinh/QuanLyHamRuouVangLX/assets/168759759/ed27f4b1-948d-494e-8c61-5ef6a3fd0b90)

## Những chức năng cơ bản trong bài
>1. Thêm thông tin rượu
>2. Xóa thông tin rượu
>3. Sửa thông tin rượu
>4. Kiểm tra số lượng còn lại
>5. Kiểm tra số lượng đã hết
>6. Tạo hóa đơn
>7. Trigger check tuổi khách hàng và ngày đặt hàng
>8. Báo cáo hóa đơn theo ngày / theo tháng

>### PROCEDURE Thêm thông tin rượu

```sql
GO
CREATE PROCEDURE ThemRuouVaoKho
    @TenRuou NVARCHAR(255),
    @LoaiRuouID INT,
    @NamSanXuat INT,
    @GiaCoBan DECIMAL(10, 2),
    @SoLuong INT
AS
BEGIN

    SET NOCOUNT ON;
    
    DECLARE @RuouID INT;

    -- Thêm thông tin rượu vào bảng Ruou
    INSERT INTO Ruou (Ten, LoaiRuouID, NamSanXuat, GiaCoBan)
    VALUES (@TenRuou, @LoaiRuouID, @NamSanXuat, @GiaCoBan);

    -- Lấy RuouID vừa được sinh tự động
    SET @RuouID = SCOPE_IDENTITY();

    -- Kiểm tra xem rượu đã tồn tại trong bảng HangTonKho chưa
    IF EXISTS (SELECT 1 FROM HangTonKho WHERE RuouID = @RuouID)
    BEGIN
        -- Nếu đã tồn tại, cập nhật số lượng hàng tồn kho
        UPDATE HangTonKho
        SET SoLuong = SoLuong + @SoLuong
        WHERE RuouID = @RuouID;
    END
    ELSE
    BEGIN
        -- Nếu chưa tồn tại, thêm mới vào bảng HangTonKho
        INSERT INTO HangTonKho (RuouID, SoLuong)
        VALUES (@RuouID, @SoLuong);
    END
END
GO
```
