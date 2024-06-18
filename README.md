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

    -- Kiểm tra xem rượu đã tồn tại trong bảng Ruou chưa
    IF EXISTS (SELECT 1 FROM Ruou WHERE Ten = @TenRuou AND LoaiRuouID = @LoaiRuouID AND NamSanXuat = @NamSanXuat AND GiaCoBan = @GiaCoBan)
    BEGIN
        -- Lấy RuouID của rượu đã tồn tại
        SELECT @RuouID = RuouID FROM Ruou WHERE Ten = @TenRuou AND LoaiRuouID = @LoaiRuouID AND NamSanXuat = @NamSanXuat AND GiaCoBan = @GiaCoBan;
        
        -- Cập nhật số lượng hàng tồn kho
        UPDATE HangTonKho
        SET SoLuong = SoLuong + @SoLuong
        WHERE RuouID = @RuouID;
    END
    ELSE
    BEGIN
        -- Thêm thông tin rượu mới vào bảng Ruou
        INSERT INTO Ruou (Ten, LoaiRuouID, NamSanXuat, GiaCoBan)
        VALUES (@TenRuou, @LoaiRuouID, @NamSanXuat, @GiaCoBan);

        -- Lấy RuouID vừa được sinh tự động
        SET @RuouID = SCOPE_IDENTITY();

        -- Thêm mới vào bảng HangTonKho
        INSERT INTO HangTonKho (RuouID, SoLuong)
        VALUES (@RuouID, @SoLuong);
    END
END
GO

```
>**Sử dụng thủ tục để thêm rượu**
```sql
EXEC ThemRuouVaoKho 
    @TenRuou = N'COLLEFRISO 10 VINTAGES',
    @LoaiRuouID = 5,  
    @NamSanXuat = 2004,
    @GiaCoBan = 4000,
    @SoLuong = 10;

-- Thử thêm 2 lần để proc kiểm tra đã tồn tại và + thêm vào số lượng
EXEC ThemRuouVaoKho 
    @TenRuou = N'COLLEFRISO 10 VINTAGES',
    @LoaiRuouID = 5,  
    @NamSanXuat = 2004,
    @GiaCoBan = 4000,
    @SoLuong = 5;

EXEC ThemRuouVaoKho 
    @TenRuou = N'Cabernet Sauvignon',
    @LoaiRuouID = 1,  
    @NamSanXuat = 2015,
    @GiaCoBan = 5000,
    @SoLuong = 20;

EXEC ThemRuouVaoKho 
    @TenRuou = N'Chardonnay',
    @LoaiRuouID = 2,  
    @NamSanXuat = 2018,
    @GiaCoBan = 3000,
    @SoLuong = 20;

EXEC ThemRuouVaoKho 
    @TenRuou = N'Moet & Chandon',
    @LoaiRuouID = 3,  
    @NamSanXuat = 2012,
    @GiaCoBan = 7000,
    @SoLuong = 12;

EXEC ThemRuouVaoKho 
    @TenRuou = N'Chile Santa Rita 3 Tres Medallas',
    @LoaiRuouID = 1,  
    @NamSanXuat = 2014,
    @GiaCoBan = 6000,
    @SoLuong = 24;

EXEC ThemRuouVaoKho 
    @TenRuou = N'Château D’Issan Blason D’Issan Margaux',
    @LoaiRuouID = 4,  
    @NamSanXuat = 2013,
    @GiaCoBan = 8000,
    @SoLuong = 11;

```
>**Thêm thông tin rượu thành công**
![image](https://github.com/hoanggchinh/QuanLyHamRuouVangNhoCuaToms/assets/168759759/98e7ef8f-87d2-4fc4-a8b1-cce030183dd6)

>### PROC Xóa thông tin rượu

```sql
GO
CREATE PROCEDURE XoaRuou
    @RuouID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Bắt đầu giao dịch
        BEGIN TRANSACTION;

        -- Xóa thông tin từ bảng ChiTietDonHang trước
        DELETE FROM ChiTietDonHang WHERE RuouID = @RuouID;

        -- Xóa thông tin từ bảng HangTonKho
        DELETE FROM HangTonKho WHERE RuouID = @RuouID;

        -- Xóa thông tin rượu từ bảng Ruou
        DELETE FROM Ruou WHERE RuouID = @RuouID;

        -- Hoàn thành giao dịch
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Nếu có lỗi, hủy giao dịch
        ROLLBACK TRANSACTION;

        -- Trả về thông báo lỗi
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO
```
>**Sử dụng thủ tục để xóa rượu**
```sql
-- Xóa thông tin của rượu có RuouID = 1
EXEC XoaRuou @RuouID = 1;
```

>**Xóa thông tin rượu thành công**
 ![image](https://github.com/hoanggchinh/QuanLyHamRuouVangNhoCuaToms/assets/168759759/2c3f7903-fb4b-4d3e-8c8f-03f9d5eb6d1a)
>### PROC Sửa thông tin rượu
```sql
GO
CREATE PROCEDURE SuaThongTinRuou
    @RuouID INT,
    @Ten NVARCHAR(255),
    @LoaiRuouID INT,
    @NamSanXuat INT,
    @GiaCoBan DECIMAL(10, 2)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Bắt đầu giao dịch
        BEGIN TRANSACTION;

        -- Cập nhật thông tin rượu
        UPDATE Ruou
        SET 
            Ten = @Ten,
            LoaiRuouID = @LoaiRuouID,
            NamSanXuat = @NamSanXuat,
            GiaCoBan = @GiaCoBan
        WHERE RuouID = @RuouID;

        -- Hoàn thành giao dịch
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Nếu có lỗi, hủy giao dịch
        ROLLBACK TRANSACTION;

        -- Trả về thông báo lỗi
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

```
>**Sử dụng thủ tục để sửa rượu**
```sql
-- Cập nhật thông tin của rượu có RuouID = 2
EXEC SuaThongTinRuou @RuouID = 2, @Ten = N'New Name', @LoaiRuouID = 2, @NamSanXuat = 2020, @GiaCoBan = 6000;
```
>**Sửa thông tin rượu thành thành công**
![image](https://github.com/hoanggchinh/QuanLyHamRuouVangNhoCuaToms/assets/168759759/018db90f-e86e-462c-bb44-673eb7d5017e)

