# Quản lý hầm rượu vang nhỏ của Tom
### Sinh viên thực hiện
**Hoàng Hữu Chính**
**K215480106007**
**57KMT.01**
### Các chức năng cơ bản
>1. Thêm, sửa, xóa thông tin rượu
>2. Kiểm tra số lượng còn lại
>3. Kiểm tra số lượng đã hết
>4. Tạo hóa đơn
>5. Trigger check tuổi khách hàng và ngày đặt hàng
### Báo cáo
>6. Báo cáo hóa đơn theo ngày / theo tháng

# Các table được sử dụng
**Bảng Ruou**

||Column Name|Data Type|Allow Null|CK|
|--|--|--|--|--|
|PK|RuouID|INT|NOT NULL||
||Ten|NVARCHAR(255)|||
|FK|LoaiRuouID|INT|||
||NamSanXuat|INT||<= YEAR(GETDATE)| 
||GiaCoBan|DECIMAL(10,2) ||>=0|

**Bảng LoaiRuou**

||Column Name|Data Type|Allow Null|
|--|--|--|--|
|PK|LoaiRuouID|INT| NOT NULL|
||TenLoai|NVARCHAR(255)|NOT NULL|

**Bảng KhachHang**

| |Column Name|Data Type|Allow Null|CK|
|--|--|--|--|--|
|PK|KhachHangID|INT|NOT NULL||
||Ten|NVARCHAR(255)|NOT NULL||
||DiaChi|NVARCHAR(255)|||
||DienThoai|NVARCHAR(20)|||
||Email|NVARCHAR(255)|||
||NgaySinh|DATE||<=GETDATE()|

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

| |Column Name|Data Type|Allow Null|CK|
|--|--|--|--|--|
|PK|HangTonKhoID|INT|||
|FK|RuouID|INT|||
||SoLuong|INT||>=0|

**Tạo sơ đồ thực thể** 
![image](https://github.com/hoanggchinh/QuanLyHamRuouVangLX/assets/168759759/ed27f4b1-948d-494e-8c61-5ef6a3fd0b90)


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
**Xử lý thủ tục**
```sql
-- Thêm rượu vào kho
EXEC ThemRuouVaoKho 
    @TenRuou = N'COLLEFRISO 10 VINTAGES',
    @LoaiRuouID = 5,  -- 1-VD 2-VT 3-CP 4-VP 5-VY 6-VH
    @NamSanXuat = 2004,
    @GiaCoBan = 4000,
    @SoLuong = 10;
```
**Thêm thông tin rượu thành công**
![image](https://github.com/hoanggchinh/QuanLyHamRuouVangNhoCuaToms/assets/168759759/25c6555a-4645-4fa1-a45e-fb308dcfa488)

>### PROC Xóa thông tin rượu
 
