USE master;
GO

-- Đảm bảo không có kết nối nào đến cơ sở dữ liệu cần xóa
ALTER DATABASE QUANLYHAMRUOU SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

-- Xóa cơ sở dữ liệu
DROP DATABASE QUANLYHAMRUOU;
GO



-- Tạo và sử dụng cơ sở dữ liệu
USE master;
GO
CREATE DATABASE QUANLYHAMRUOU;
GO
USE QUANLYHAMRUOU;
GO

-- Tạo bảng phân loại rượu
CREATE TABLE LoaiRuou (
    LoaiRuouID INT PRIMARY KEY IDENTITY(1,1),
    TenLoai NVARCHAR(255) NOT NULL
);

-- Tạo bảng rượu
CREATE TABLE Ruou (
    RuouID INT PRIMARY KEY IDENTITY(1,1),
    Ten NVARCHAR(255) NOT NULL,
    LoaiRuouID INT,
    NamSanXuat INT,
    GiaCoBan DECIMAL(10, 2),
    FOREIGN KEY (LoaiRuouID) REFERENCES LoaiRuou(LoaiRuouID)
);

-- Tạo bảng khách hàng
CREATE TABLE KhachHang (
    KhachHangID INT PRIMARY KEY IDENTITY(1,1),
    Ten NVARCHAR(255) NOT NULL,
    DiaChi NVARCHAR(255),
    DienThoai NVARCHAR(20),
    Email NVARCHAR(255),
    NgaySinh DATE
);

-- Tạo bảng đơn đặt hàng
CREATE TABLE DonDatHang (
    DonDatHangID INT PRIMARY KEY IDENTITY(1,1),
    KhachHangID INT,
    NgayDat DATE,
    TongTien DECIMAL(10, 2),
    FOREIGN KEY (KhachHangID) REFERENCES KhachHang(KhachHangID)
);

-- Tạo bảng chi tiết đơn hàng
CREATE TABLE ChiTietDonHang (
    ChiTietDonHangID INT PRIMARY KEY IDENTITY(1,1),
    DonDatHangID INT,
    RuouID INT,
    SoLuong INT,
    GiaBan DECIMAL(10, 2),
    FOREIGN KEY (DonDatHangID) REFERENCES DonDatHang(DonDatHangID), 
    FOREIGN KEY (RuouID) REFERENCES Ruou(RuouID)
);

-- Tạo bảng hàng tồn kho
CREATE TABLE HangTonKho (
    HangTonKhoID INT PRIMARY KEY IDENTITY(1,1),
    RuouID INT,
    SoLuong INT,
    FOREIGN KEY (RuouID) REFERENCES Ruou(RuouID)
);




-- tác giả: Hoàng Hữu Chính 
-- ngày làm: 18/6/2024
-- Thêm loại rượu
INSERT INTO LoaiRuou (TenLoai) VALUES (N'Ruou Vang Do'), (N'Ruou Vang Trang'), (N'Champagne'), (N'Ruou Vang Phap'),(N'Ruou vang Y'),(N'Ruou Vang Hong');
-- 1-VD 2-VT 3-CP 4-VP 5-VY 6-VH

-- Thêm thông tin khách hàng
INSERT INTO KhachHang (Ten, DiaChi, DienThoai, Email, NgaySinh) VALUES 
(N'Cao Duc Thanh', N'123 Phan Dinh Phung, Hanoi', N'0123456789', N'cdt@gmail.com', '1999-01-02'),
(N'Nguyen Linh Chi', N'456 Le Loi, Ho Chi Minh', N'0987654321', N'lingcheese@gmail.com', '2011-02-03');      




-- thêm ck vào Năm sx và Giá cơ bản của bảng Ruou
ALTER TABLE Ruou
ADD CONSTRAINT CK_NamSanXuat CHECK (NamSanXuat <= YEAR(GETDATE()));
ALTER TABLE Ruou
ADD CONSTRAINT CK_GiaCoBan CHECK (GiaCoBan >= 0);

-- thêm ck vào ngày sinh - để đảm bảo ngày sinh không thể là tương lai vượt quá ngày hiện tại
ALTER TABLE KhachHang
ADD CONSTRAINT CK_NgaySinh CHECK (NgaySinh <= GETDATE());

-- thêm ck cho SoLuong để số lượng không âm
ALTER TABLE HangTonKho
ADD CONSTRAINT CK_SoLuong CHECK (SoLuong >= 0);                                           




INSERT INTO ChiTietDonHang(DonDatHangID, RuouID, SoLuong,GiaBan)
VALUES (1,1,100,5000);







-----------------------------------------PROC Thêm rượu vào kho------------------------------------
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










----------------------------------------RUN PROC thêm rượu vào kho----------------------------------


-- tác giả: Hoàng Hữu Chính 
-- ngày làm: 18/6/2024
-- Thêm rượu vào kho
EXEC ThemRuouVaoKho 
    @TenRuou = N'COLLEFRISO 10 VINTAGES',
    @LoaiRuouID = 5,  -- 1-VD 2-VT 3-CP 4-VP 5-VY 6-VH
    @NamSanXuat = 2004,
    @GiaCoBan = 4000,
    @SoLuong = 10;

EXEC ThemRuouVaoKho 
    @TenRuou = N'COLLEFRISO 10 VINTAGES',
    @LoaiRuouID = 5,  -- 1-VD 2-VT 3-CP 4-VP 5-VY 6-VH
    @NamSanXuat = 2004,
    @GiaCoBan = 4000,
    @SoLuong = 5;

EXEC ThemRuouVaoKho 
    @TenRuou = N'Cabernet Sauvignon',
    @LoaiRuouID = 1,  -- Loại rượu
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





---------------------------------------------------------------------------------------------------
SELECT * FROM Ruou
-- tác giả: Hoàng Hữu Chính 
-- ngày làm: 18/6/2024
-- hiện thông số rượu
SELECT Ruou.*, HangTonKho.SoLuong, LoaiRuou.TenLoai 
FROM Ruou LEFT JOIN HangTonKho ON Ruou.RuouID = HangTonKho.RuouID LEFT JOIN LoaiRuou ON Ruou.LoaiRuouID = LoaiRuou.LoaiRuouID;

------------------- exe-ed---------------
-------------------------
---------------------------------xóa để update lại--------------------
-- Vô hiệu hóa ràng buộc khóa ngoại
ALTER TABLE ChiTietDonHang NOCHECK CONSTRAINT ALL;
ALTER TABLE DonDatHang NOCHECK CONSTRAINT ALL;
ALTER TABLE HangTonKho NOCHECK CONSTRAINT ALL;
ALTER TABLE Ruou NOCHECK CONSTRAINT ALL;
ALTER TABLE KhachHang NOCHECK CONSTRAINT ALL;
ALTER TABLE LoaiRuou NOCHECK CONSTRAINT ALL;

-- Xóa dữ liệu từ các bảng
DELETE FROM ChiTietDonHang;
DELETE FROM DonDatHang;
DELETE FROM HangTonKho;
DELETE FROM Ruou;
DELETE FROM KhachHang;
DELETE FROM LoaiRuou;

-- Kích hoạt lại ràng buộc khóa ngoại
ALTER TABLE ChiTietDonHang CHECK CONSTRAINT ALL;
ALTER TABLE DonDatHang CHECK CONSTRAINT ALL;
ALTER TABLE HangTonKho CHECK CONSTRAINT ALL;
ALTER TABLE Ruou CHECK CONSTRAINT ALL;
ALTER TABLE KhachHang CHECK CONSTRAINT ALL;
ALTER TABLE LoaiRuou CHECK CONSTRAINT ALL;
---------------------------------------------------------------------------------------------------






------------------------------------------PROC Sửa thông tin rượu----------------------------------
-- Hoàng Hữu Chính
-- 18/06/2024
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







-- tác giả: Hoàng Hữu Chính 
-- ngày làm: 18/6/2024
------------------------------------------RUN PROC Sửa thông tin rượu-----------------------------
-- Cập nhật thông tin của rượu có RuouID = 2
EXEC SuaThongTinRuou @RuouID = 2, @Ten = N'New Name', @LoaiRuouID = 2, @NamSanXuat = 2020, @GiaCoBan = 6000;

---------------------------------------------------------------------------------------------------
-- tác giả: Hoàng Hữu Chính 
-- ngày làm: 18/6/2024
-- hiện thông tin rượu
SELECT Ruou.*, HangTonKho.SoLuong, LoaiRuou.TenLoai 
FROM Ruou LEFT JOIN HangTonKho ON Ruou.RuouID = HangTonKho.RuouID LEFT JOIN LoaiRuou ON Ruou.LoaiRuouID = LoaiRuou.LoaiRuouID;


------------------------------------------PROC Xóa thông tin rượu----------------------------------
-- tác giả: Hoàng Hữu Chính 
-- ngày làm: 18/6/2024
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


------------------------------------------RUN PROC Xóa thông tin rượu-----------------------------
--Hoàng Hữu Chính
--18/06/2024
-- Xóa thông tin của rượu có RuouID = 1
EXEC XoaRuou @RuouID = 1;

---------------------------------------------------------------------------------------------------



----------------------------------PROC Kiểm tra Rượu còn/đã hết trong kho--------------------------
-- Tạo SP kiểm tra hàng đã hết trong kho
GO
CREATE PROCEDURE KiemTraHangHet
AS
BEGIN
    SELECT r.RuouID, r.Ten, l.TenLoai, h.SoLuong
    FROM Ruou r
    JOIN HangTonKho h ON r.RuouID = h.RuouID
    JOIN LoaiRuou l ON r.LoaiRuouID = l.LoaiRuouID
    WHERE h.SoLuong = 0;
END;


GO
-- Tạo SP kiểm tra hàng còn trong kho
CREATE PROCEDURE KiemTraHangCon
AS
BEGIN
    SELECT r.RuouID, r.Ten, l.TenLoai, h.SoLuong
    FROM Ruou r
    JOIN HangTonKho h ON r.RuouID = h.RuouID
    JOIN LoaiRuou l ON r.LoaiRuouID = l.LoaiRuouID
    WHERE h.SoLuong > 0;
END;
GO
------------------------------------RUN Kiểm tra Rượu còn/đã hết trong kho------------------------
-- Kiểm tra hàng đã hết trong kho
EXEC KiemTraHangHet;

-- Kiểm tra hàng còn trong kho
EXEC KiemTraHangCon;

--------------------------------------------------------------------------------------------------






-----------------------------------------PROC Tạo hóa đơn------------------------------------------
GO
CREATE PROCEDURE TaoHoaDon
    @KhachHangID INT,
    @NgayDat DATE,
    @TongTien DECIMAL(10, 2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DonDatHangID INT;
    DECLARE @RuouID INT;
    DECLARE @SoLuong INT;
    DECLARE @GiaCoBan DECIMAL(10, 2);
    DECLARE @GiaBan DECIMAL(10, 2);
    DECLARE @NamSanXuat INT;
    DECLARE @NamHienTai INT;
    DECLARE @TuoiRuou INT;
    DECLARE @NgaySinh DATE;
    DECLARE @TuoiKhachHang INT;
    DECLARE @done INT;

    -- Khởi tạo giá trị ban đầu cho biến done
    SET @done = 0;

    -- Kiểm tra tuổi khách hàng
    SELECT @NgaySinh = NgaySinh FROM KhachHang WHERE KhachHangID = @KhachHangID;
    SET @TuoiKhachHang = YEAR(@NgayDat) - YEAR(@NgaySinh);
    IF (@NgayDat < DATEADD(YEAR, @TuoiKhachHang, @NgaySinh)) 
    BEGIN
        SET @TuoiKhachHang = @TuoiKhachHang - 1;
    END

    -- Nếu khách hàng dưới 18 tuổi, ngừng thực hiện
    IF @TuoiKhachHang < 18 
    BEGIN
        RAISERROR ('Khach hang duoi 18 tuoi, khong the tao hoa don.', 16, 1);
        RETURN;
    END

    -- Tạo đơn đặt hàng
    INSERT INTO DonDatHang (KhachHangID, NgayDat, TongTien) VALUES (@KhachHangID, @NgayDat, 0);
    SET @DonDatHangID = SCOPE_IDENTITY();

    -- Sử dụng CURSOR Duyệt qua các loại rượu và thêm chi tiết đơn hàng
    DECLARE cur CURSOR FOR SELECT RuouID, SoLuong FROM HangTonKho WHERE SoLuong > 0;
    OPEN cur;
    
    FETCH NEXT FROM cur INTO @RuouID, @SoLuong;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Lấy thông tin rượu
        SELECT @NamSanXuat = NamSanXuat, @GiaCoBan = GiaCoBan FROM Ruou WHERE RuouID = @RuouID;
        SET @NamHienTai = YEAR(@NgayDat);
        SET @TuoiRuou = @NamHienTai - @NamSanXuat;
        SET @GiaBan = @GiaCoBan * (1 + @TuoiRuou * 0.05); -- Tăng giá 5% mỗi năm

        -- Thêm chi tiết đơn hàng
        INSERT INTO ChiTietDonHang (DonDatHangID, RuouID, SoLuong, GiaBan) VALUES (@DonDatHangID, @RuouID, @SoLuong, @GiaBan);

        -- Cập nhật tổng tiền
        SET @TongTien = @TongTien + @SoLuong * @GiaBan;

        -- Cập nhật số lượng hàng tồn kho
        UPDATE HangTonKho SET SoLuong = SoLuong - @SoLuong WHERE RuouID = @RuouID;

        FETCH NEXT FROM cur INTO @RuouID, @SoLuong;
    END

    CLOSE cur;
    DEALLOCATE cur;

    -- Cập nhật tổng tiền trong đơn đặt hàng
    UPDATE DonDatHang SET TongTien = @TongTien WHERE DonDatHangID = @DonDatHangID;
END
GO



------------------------------------RUN proc Tao hoa don--------
-- Khởi tạo tổng tiền
DECLARE @TongTien DECIMAL(10, 2);
SET @TongTien = 0;

-- Thử tạo hóa đơn cho khách hàng dưới 18 tuổi 
BEGIN TRY
	-- thử với ID khách = 2
    EXEC TaoHoaDon @KhachHangID = 2, @NgayDat = GETDATE(), @TongTien = @TongTien OUTPUT;
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH

-- Thử tạo hóa đơn cho khách hàng trên 18 tuổi
SET @TongTien = 0;
-- thử với ID khách = 1
EXEC TaoHoaDon @KhachHangID = 1, @NgayDat = GETDATE(), @TongTien = @TongTien OUTPUT;

-- Xem kết quả
SELECT * FROM DonDatHang;
SELECT * FROM ChiTietDonHang WHERE DonDatHangID IN (SELECT DonDatHangID FROM DonDatHang WHERE KhachHangID = 1);






-- test thêm thông tin dưới 18 tuổi
--INSERT INTO KhachHang(Ten, DiaChi, DienThoai, Email, NgaySinh) VALUES
--(N'Nguyen Linh Chi',N'332 Quan Hoan Kiem, Hanoi',N'0942412525',N'linhcheese@gmail.com','2010-09-12');

-----------------------------------------------------------------------------------------------------------------

-----------------------------------SP tạo hóa đơn---------------------------------------------------------------
GO
CREATE PROCEDURE TaoHoaDon
    @KhachHangID INT,
    @NgayDat DATE,
    @TongTien DECIMAL(10, 2) OUTPUT
AS
BEGIN
    DECLARE @DonDatHangID INT;
    DECLARE @RuouID INT;
    DECLARE @SoLuong INT;
    DECLARE @GiaCoBan DECIMAL(10, 2);
    DECLARE @GiaBan DECIMAL(10, 2);
    DECLARE @NamSanXuat INT;
    DECLARE @NamHienTai INT;
    DECLARE @TuoiRuou INT;

    -- Tạo đơn đặt hàng
    INSERT INTO DonDatHang (KhachHangID, NgayDat, TongTien)
    VALUES (@KhachHangID, @NgayDat, 0);

    SET @DonDatHangID = SCOPE_IDENTITY();

    -- Khai báo cursor để duyệt qua bảng ChiTietDonHang
    DECLARE cur CURSOR FOR
    SELECT RuouID, SoLuong FROM ChiTietDonHang WHERE DonDatHangID = @DonDatHangID;

    OPEN cur;

    FETCH NEXT FROM cur INTO @RuouID, @SoLuong;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Lấy thông tin rượu
        SELECT @NamSanXuat = NamSanXuat, @GiaCoBan = GiaCoBan FROM Ruou WHERE RuouID = @RuouID;
        SET @NamHienTai = YEAR(@NgayDat);
        SET @TuoiRuou = @NamHienTai - @NamSanXuat;
        SET @GiaBan = @GiaCoBan * (1 + @TuoiRuou * 0.05); -- Tăng giá 5% mỗi năm

        -- Thêm chi tiết đơn hàng
        INSERT INTO ChiTietDonHang (DonDatHangID, RuouID, SoLuong, GiaBan)
        VALUES (@DonDatHangID, @RuouID, @SoLuong, @GiaBan);

        -- Cập nhật tổng tiền
        SET @TongTien = @TongTien + @SoLuong * @GiaBan;

        -- Cập nhật số lượng hàng tồn kho
        UPDATE HangTonKho SET SoLuong = SoLuong - @SoLuong WHERE RuouID = @RuouID;

        FETCH NEXT FROM cur INTO @RuouID, @SoLuong;
    END;

    CLOSE cur;
    DEALLOCATE cur;

    -- Cập nhật tổng tiền trong đơn đặt hàng
    UPDATE DonDatHang SET TongTien = @TongTien WHERE DonDatHangID = @DonDatHangID;
END;
GO
---------------------------trigger check tuổi khách và ngày tạo hóa đơn-------------
CREATE TRIGGER trg_CheckDonDatHang
ON DonDatHang
AFTER INSERT
AS
BEGIN
    DECLARE @KhachHangID INT;
    DECLARE @NgayDat DATE;
    DECLARE @NgaySinh DATE;
    DECLARE @TuoiKhachHang INT;

    SELECT @KhachHangID = i.KhachHangID, @NgayDat = i.NgayDat
    FROM inserted i;

    -- Lấy ngày sinh của khách hàng
    SELECT @NgaySinh = NgaySinh FROM KhachHang WHERE KhachHangID = @KhachHangID;

    -- Tính tuổi khách hàng
    SET @TuoiKhachHang = DATEDIFF(YEAR, @NgaySinh, @NgayDat);

    IF @NgayDat < DATEADD(YEAR, @TuoiKhachHang, @NgaySinh)
    BEGIN
        SET @TuoiKhachHang = @TuoiKhachHang - 1;
    END

    -- Kiểm tra tuổi khách hàng phải >= 18
    IF @TuoiKhachHang < 18
    BEGIN
        ROLLBACK;
        RAISERROR ('Khach hang duoi 18 tuoi, khong the tao hoa don.', 16, 1);
        RETURN;
    END

    -- Kiểm tra ngày hóa đơn phải <= ngày hiện tại
    IF @NgayDat > GETDATE()
    BEGIN
        ROLLBACK;
        RAISERROR ('Ngay dat hang khong hop le, phai nho hon hoac bang ngay hien tai.', 16, 1);
        RETURN;
    END
END;
GO
-----------------------------------------test cả 2---------------------------------
DECLARE @TongTien DECIMAL(10, 2);

-- Gọi stored procedure TaoHoaDon
EXEC TaoHoaDon @KhachHangID = 1, @NgayDat = '2023-06-14', @TongTien = @TongTien OUTPUT;
PRINT @TongTien;

-- Thử thêm đơn đặt hàng với khách hàng dưới 18 tuổi (trigger sẽ không cho phép)
INSERT INTO DonDatHang (KhachHangID, NgayDat, TongTien)
VALUES (2, '2024-06-14', 0);


-------------------------------Báo cáo hóa đơn theo ngày hoặc tháng------------------
GO
CREATE PROCEDURE BaoCaoHoaDon
    @LoaiBaoCao NVARCHAR(10),  -- 'Ngay' hoặc 'Thang'
    @Ngay DATE = NULL,          -- Chỉ dùng khi LoaiBaoCao = 'Ngay'
    @Nam INT = NULL,            -- Chỉ dùng khi LoaiBaoCao = 'Thang'
    @Thang INT = NULL           -- Chỉ dùng khi LoaiBaoCao = 'Thang'
AS
BEGIN
    IF @LoaiBaoCao = 'Ngay'
    BEGIN
        SELECT 
            d.DonDatHangID,
            d.NgayDat,
            k.Ten AS TenKhachHang,
            SUM(ct.SoLuong * ct.GiaBan) AS TongTienHoaDon
        FROM DonDatHang d
        JOIN KhachHang k ON d.KhachHangID = k.KhachHangID
        JOIN ChiTietDonHang ct ON d.DonDatHangID = ct.DonDatHangID
        WHERE d.NgayDat = @Ngay
        GROUP BY d.DonDatHangID, d.NgayDat, k.Ten;
    END
    ELSE IF @LoaiBaoCao = 'Thang'
    BEGIN
        SELECT 
            d.DonDatHangID,
            d.NgayDat,
            k.Ten AS TenKhachHang,
            SUM(ct.SoLuong * ct.GiaBan) AS TongTienHoaDon
        FROM DonDatHang d
        JOIN KhachHang k ON d.KhachHangID = k.KhachHangID
        JOIN ChiTietDonHang ct ON d.DonDatHangID = ct.DonDatHangID
        WHERE YEAR(d.NgayDat) = @Nam AND MONTH(d.NgayDat) = @Thang
        GROUP BY d.DonDatHangID, d.NgayDat, k.Ten;
    END
END;
GO
------------------------------Báo cáo dựa theo      Ngày------------------------
EXEC BaoCaoHoaDon @LoaiBaoCao = 'Ngay', @Ngay = '2023-06-14';
------------------------------Báo cáo dựa theo      Tháng-----------------------
EXEC BaoCaoHoaDon @LoaiBaoCao = 'Thang', @Nam = 2023, @Thang = 6;

--- để thử nghiệm thì phải thêm dữ liệu mẫu-------------------------------------
-- Thêm dữ liệu mẫu vào bảng DonDatHang
INSERT INTO DonDatHang (KhachHangID, NgayDat, TongTien) VALUES
(1, '2023-06-14', 0),
(1, '2023-06-15', 0),
(2, '2023-06-14', 0);

-- Thêm dữ liệu mẫu vào bảng ChiTietDonHang
INSERT INTO ChiTietDonHang (DonDatHangID, RuouID, SoLuong, GiaBan) VALUES
(1, 1, 2, 5500),
(1, 2, 1, 3150),
(2, 3, 3, 7350),
(3, 4, 4, 6300);
