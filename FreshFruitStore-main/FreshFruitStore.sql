-- ==================================================================================
-- Script Khởi tạo Cơ sở Dữ liệu cho Dự án FreshFruitStore (Chuẩn UTF-8)
-- Phù hợp chạy trực tiếp trên SQL Server Management Studio (SSMS) mọi phiên bản
-- ==================================================================================

USE master;
GO

-- 1. Tạo Database nếu chưa tồn tại (tránh lỗi hardcode đường dẫn ổ đĩa)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'FreshFruitStore')
BEGIN
    CREATE DATABASE [FreshFruitStore];
END
GO

USE [FreshFruitStore];
GO

-- 2. Xóa các khóa ngoại và bảng cũ nếu đã tồn tại để tránh xung đột khi chạy lại
IF OBJECT_ID(N'dbo.Payments', N'U') IS NOT NULL DROP TABLE dbo.Payments;
IF OBJECT_ID(N'dbo.OrderDetails', N'U') IS NOT NULL DROP TABLE dbo.OrderDetails;
IF OBJECT_ID(N'dbo.Orders', N'U') IS NOT NULL DROP TABLE dbo.Orders;
IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL DROP TABLE dbo.Products;
IF OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL DROP TABLE dbo.Users;
GO

-- ==================================================================================
-- BẢNG 1: Users (Tài khoản người dùng & Phân quyền)
-- Bổ sung đầy đủ Email và IsActive khớp 100% với UserDAO và Model
-- ==================================================================================
CREATE TABLE [dbo].[Users] (
    [UserID]   INT IDENTITY(1,1) NOT NULL,
    [Username] VARCHAR(50) NOT NULL UNIQUE,
    [Password] VARCHAR(255) NOT NULL,
    [FullName] NVARCHAR(100) NULL,
    [Email]    VARCHAR(100) NULL,
    [Phone]    VARCHAR(15) NULL,
    [Address]  NVARCHAR(255) NULL,
    [Role]     VARCHAR(20) NOT NULL DEFAULT 'Customer', -- 'Admin' hoặc 'Customer'
    [IsActive] BIT NOT NULL DEFAULT 1,                  -- 1: Hoạt động, 0: Bị khóa
    CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([UserID] ASC)
);
GO

-- ==================================================================================
-- BẢNG 2: Categories (Danh mục trái cây)
-- ==================================================================================
CREATE TABLE [dbo].[Categories] (
    [CategoryID]   INT IDENTITY(1,1) NOT NULL,
    [CategoryName] NVARCHAR(100) NOT NULL,
    CONSTRAINT [PK_Categories] PRIMARY KEY CLUSTERED ([CategoryID] ASC)
);
GO

-- ==================================================================================
-- BẢNG 3: Products (Thông tin sản phẩm hoa quả tươi)
-- ==================================================================================
CREATE TABLE [dbo].[Products] (
    [ProductID]     INT IDENTITY(1,1) NOT NULL,
    [CategoryID]    INT NULL,
    [ProductName]   NVARCHAR(150) NOT NULL,
    [Price]         DECIMAL(18, 2) NOT NULL,
    [Unit]          NVARCHAR(20) NOT NULL,              -- 'kg', 'hộp', 'quả', 'giỏ'
    [StockQuantity] INT NOT NULL DEFAULT 0,
    [ImageUrl]      NVARCHAR(500) NULL,
    [Description]   NVARCHAR(MAX) NULL,
    [CreatedDate]   DATETIME DEFAULT GETDATE(),
    [Status]        BIT DEFAULT 1,                      -- 1: Đang bán, 0: Tạm ngưng
    CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED ([ProductID] ASC),
    CONSTRAINT [FK_Products_Categories] FOREIGN KEY ([CategoryID]) REFERENCES [dbo].[Categories]([CategoryID]) ON DELETE SET NULL
);
GO

-- ==================================================================================
-- BẢNG 4: Orders (Đơn đặt hàng)
-- ==================================================================================
CREATE TABLE [dbo].[Orders] (
    [OrderID]         INT IDENTITY(1,1) NOT NULL,
    [UserID]          INT NULL,                         -- NULL nếu khách mua vãng lai
    [ReceiverName]    NVARCHAR(100) NOT NULL,
    [ReceiverPhone]   VARCHAR(15) NOT NULL,
    [ShippingAddress] NVARCHAR(255) NOT NULL,
    [OrderNote]       NVARCHAR(500) NULL,
    [TotalAmount]     DECIMAL(18, 2) NOT NULL,
    [PaymentMethod]   NVARCHAR(50) NOT NULL DEFAULT N'COD', -- 'COD' hoặc 'BANK_TRANSFER'
    [OrderStatus]     NVARCHAR(50) NOT NULL DEFAULT N'Chờ xác nhận', 
    -- Các trạng thái: N'Chờ xác nhận', N'Đã xác nhận', N'Đã thanh toán', N'Đang giao hàng', N'Hoàn thành', N'Đã hủy'
    [OrderDate]       DATETIME DEFAULT GETDATE(),
    CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED ([OrderID] ASC),
    CONSTRAINT [FK_Orders_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users]([UserID]) ON DELETE SET NULL
);
GO

-- ==================================================================================
-- BẢNG 5: OrderDetails (Chi tiết mặt hàng trong đơn)
-- ==================================================================================
CREATE TABLE [dbo].[OrderDetails] (
    [OrderDetailID] INT IDENTITY(1,1) NOT NULL,
    [OrderID]       INT NOT NULL,
    [ProductID]     INT NOT NULL,
    [Quantity]      INT NOT NULL,
    [UnitPrice]     DECIMAL(18, 2) NOT NULL,
    CONSTRAINT [PK_OrderDetails] PRIMARY KEY CLUSTERED ([OrderDetailID] ASC),
    CONSTRAINT [FK_OrderDetails_Orders] FOREIGN KEY ([OrderID]) REFERENCES [dbo].[Orders]([OrderID]) ON DELETE CASCADE,
    CONSTRAINT [FK_OrderDetails_Products] FOREIGN KEY ([ProductID]) REFERENCES [dbo].[Products]([ProductID])
);
GO

-- ==================================================================================
-- BẢNG 6: Payments (Thông tin thanh toán & VietQR)
-- ==================================================================================
CREATE TABLE [dbo].[Payments] (
    [PaymentID]     INT IDENTITY(1,1) NOT NULL,
    [OrderID]       INT NOT NULL,
    [TransactionID] VARCHAR(100) NULL,
    [Amount]        DECIMAL(18, 2) NOT NULL,
    [PaymentDate]   DATETIME DEFAULT GETDATE(),
    [PaymentMethod] VARCHAR(50) NOT NULL DEFAULT 'COD',
    [PaymentStatus] NVARCHAR(50) NOT NULL DEFAULT N'Chờ xác nhận', -- N'Chờ xác nhận', N'Đã thanh toán', N'Thất bại'
    CONSTRAINT [PK_Payments] PRIMARY KEY CLUSTERED ([PaymentID] ASC),
    CONSTRAINT [FK_Payments_Orders] FOREIGN KEY ([OrderID]) REFERENCES [dbo].[Orders]([OrderID]) ON DELETE CASCADE
);
GO

-- ==================================================================================
-- NẠP DỮ LIỆU MẪU (SEED DATA CHUẨN)
-- ==================================================================================

-- 1. Nạp Tài khoản Users (Có cả Admin, Khách hàng, User bị khóa để test)
SET IDENTITY_INSERT [dbo].[Users] ON;
INSERT INTO [dbo].[Users] ([UserID], [Username], [Password], [FullName], [Email], [Phone], [Address], [Role], [IsActive]) VALUES 
(1, 'admin', '123456', N'Quản Trị Viên Hệ Thống', 'admin@freshfruit.com', '0901234567', N'Tòa nhà Công nghệ, Cầu Giấy, Hà Nội', 'Admin', 1),
(2, 'customer', '123', N'Nguyễn Văn Khách', 'customer@gmail.com', '0912345678', N'Số 12 ngõ 45 Kim Mã, Ba Đình, Hà Nội', 'Customer', 1),
(3, 'hoangnam', '123', N'Lê Hoàng Nam', 'namlh@gmail.com', '0988776655', N'72 Nguyễn Trãi, Thanh Xuân, Hà Nội', 'Customer', 1),
(4, 'spammer', '123', N'Tài Khoản Bị Khóa Demo', 'locked@spam.com', '0999888777', N'Địa chỉ chưa xác thực', 'Customer', 0);
SET IDENTITY_INSERT [dbo].[Users] OFF;
GO

-- 2. Nạp Danh mục Categories
SET IDENTITY_INSERT [dbo].[Categories] ON;
INSERT INTO [dbo].[Categories] ([CategoryID], [CategoryName]) VALUES
(1, N'Trái Cây Nhập Khẩu'),
(2, N'Trái Cây Nội Địa'),
(3, N'Giỏ Quà Trái Cây'),
(4, N'Nước Ép & Trái Cây Sấy');
SET IDENTITY_INSERT [dbo].[Categories] OFF;
GO

-- 3. Nạp Sản phẩm Products (Ảnh thật rõ nét, chuẩn bị cho Bước 1)
SET IDENTITY_INSERT [dbo].[Products] ON;
INSERT INTO [dbo].[Products] ([ProductID], [CategoryID], [ProductName], [Price], [Unit], [StockQuantity], [ImageUrl], [Description], [CreatedDate], [Status]) VALUES
(1, 1, N'Táo Envy New Zealand (Size 70)', 185000, N'kg', 50, 
 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=600&q=80', 
 N'Táo Envy vỏ đỏ ruby sang trọng, thịt quả giòn đanh, vị ngọt đậm đà đặc trưng khó quên.', GETDATE(), 1),

(2, 1, N'Nho Mẫu Đơn Shine Muscat Hàn Quốc', 450000, N'hộp', 30, 
 'https://images.unsplash.com/photo-1596363505729-4190a9506133?auto=format&fit=crop&w=600&q=80', 
 N'Nho chùm to đều, không hạt, mọng nước, hương thơm thoang thoảng mùi hoa sữa tự nhiên.', GETDATE(), 1),

(3, 2, N'Cam Sành Tiền Giang Hái Sớm', 45000, N'kg', 120, 
 'https://images.unsplash.com/photo-1611080626919-7cf5a9dbab5b?auto=format&fit=crop&w=600&q=80', 
 N'Cam sành mọng nước, vỏ sần tự nhiên, giàu Vitamin C hỗ trợ tăng cường sức đề kháng mỗi ngày.', GETDATE(), 1),

(4, 2, N'Xoài Cát Hòa Lộc Loại 1', 95000, N'kg', 65, 
 'https://images.unsplash.com/photo-1553279768-865429fa0078?auto=format&fit=crop&w=600&q=80', 
 N'Xoài chín thơm nức mũi, thịt quả vàng ươm, dẻo ngọt và không hề có xơ.', GETDATE(), 1),

(5, 2, N'Dâu Tây Giống Nhật Đà Lạt', 160000, N'hộp', 40, 
 'https://images.unsplash.com/photo-1464965911861-746a04b4bca6?auto=format&fit=crop&w=600&q=80', 
 N'Dâu tây trồng thủy canh VietGAP công nghệ cao, quả đỏ au, vị ngọt thanh mát.', GETDATE(), 1),

(6, 2, N'Bơ Sáp 034 Đắk Lắk Dẻo Béo', 65000, N'kg', 80, 
 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?auto=format&fit=crop&w=600&q=80', 
 N'Bơ sáp dài hạt lép, cơm bơ dày đặc màu vàng mỡ gà, béo ngậy tự nhiên.', GETDATE(), 1),

(7, 1, N'Cherry Đỏ Mỹ Size 9.0 Premium', 420000, N'hộp', 25, 
 'https://images.unsplash.com/photo-1528825871115-3581a5387919?auto=format&fit=crop&w=600&q=80', 
 N'Cherry cuống xanh tươi rói, quả chắc nịch, vị ngọt sâu lắng cực kỳ bổ dưỡng.', GETDATE(), 1),

(8, 3, N'Giỏ Quà Trái Cây Phú Quý Sum Vầy', 680000, N'giỏ', 15, 
 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?auto=format&fit=crop&w=600&q=80', 
 N'Kết hợp tinh tế giữa Táo Envy, Nho mẫu đơn, Cam Úc và Lê Hàn Quốc kèm nơ sang trọng.', GETDATE(), 1);
SET IDENTITY_INSERT [dbo].[Products] OFF;
GO

-- 4. Nạp Đơn hàng mẫu Orders (Sẵn sàng test Bước 5 Quản lý đơn hàng)
SET IDENTITY_INSERT [dbo].[Orders] ON;
INSERT INTO [dbo].[Orders] ([OrderID], [UserID], [ReceiverName], [ReceiverPhone], [ShippingAddress], [OrderNote], [TotalAmount], [PaymentMethod], [OrderStatus], [OrderDate]) VALUES
(1001, 2, N'Nguyễn Văn Khách', '0912345678', N'Số 12 ngõ 45 Kim Mã, Ba Đình, Hà Nội', N'Giao hàng trong giờ hành chính', 370000, N'COD', N'Chờ xác nhận', DATEADD(HOUR, -3, GETDATE())),
(1002, 3, N'Lê Hoàng Nam', '0988776655', N'72 Nguyễn Trãi, Thanh Xuân, Hà Nội', N'Chọn quả chín giúp em', 450000, N'BANK_TRANSFER', N'Đã xác nhận', DATEADD(HOUR, -6, GETDATE())),
(1003, NULL, N'Trần Thị Mai (Khách vãng lai)', '0933221100', N'Số 8 Tràng Thi, Hoàn Kiếm, Hà Nội', N'Gọi trước khi giao', 160000, N'COD', N'Hoàn thành', DATEADD(DAY, -1, GETDATE()));
SET IDENTITY_INSERT [dbo].[Orders] OFF;
GO

-- 5. Nạp Chi tiết đơn hàng OrderDetails
SET IDENTITY_INSERT [dbo].[OrderDetails] ON;
INSERT INTO [dbo].[OrderDetails] ([OrderDetailID], [OrderID], [ProductID], [Quantity], [UnitPrice]) VALUES
(1, 1001, 1, 2, 185000), -- 2 kg Táo Envy
(2, 1002, 2, 1, 450000), -- 1 hộp Nho Mẫu Đơn
(3, 1003, 5, 1, 160000); -- 1 hộp Dâu Tây Đà Lạt
SET IDENTITY_INSERT [dbo].[OrderDetails] OFF;
GO

-- 6. Nạp Thanh toán Payments
SET IDENTITY_INSERT [dbo].[Payments] ON;
INSERT INTO [dbo].[Payments] ([PaymentID], [OrderID], [TransactionID], [Amount], [PaymentDate], [PaymentMethod], [PaymentStatus]) VALUES
(1, 1001, 'COD-1001', 370000, DATEADD(HOUR, -3, GETDATE()), 'COD', N'Chờ xác nhận'),
(2, 1002, 'VQR-MB-1002-8899', 450000, DATEADD(HOUR, -6, GETDATE()), 'BANK_TRANSFER', N'Đã thanh toán'),
(3, 1003, 'COD-1003', 160000, DATEADD(DAY, -1, GETDATE()), 'COD', N'Đã thanh toán');
SET IDENTITY_INSERT [dbo].[Payments] OFF;
GO

PRINT N'>>> KHỞI TẠO VÀ NẠP DỮ LIỆU CSDL FRESHFRUITSTORE THÀNH CÔNG! <<<';
GO
