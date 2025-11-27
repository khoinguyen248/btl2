USE EERD_Project;
GO
-- =============================================
-- 1. BẢNG USER (Tạo 20 Users để chia đủ cho các bảng con)
-- =============================================
INSERT INTO [User] (username, email, deviceCount, street, city) VALUES
-- Nhóm Free (ID 1-5)
('user_free1', 'free1@test.com', 1, 'Street 1', 'HCM'),
('user_free2', 'free2@test.com', 1, 'Street 2', 'HCM'),
('user_free3', 'free3@test.com', 1, 'Street 3', 'HN'),
('user_free4', 'free4@test.com', 1, 'Street 4', 'DN'),
('user_free5', 'free5@test.com', 1, 'Street 5', 'Hue'),
-- Nhóm Premium (ID 6-10)
('user_prem1', 'prem1@test.com', 2, 'Street 6', 'HCM'),
('user_prem2', 'prem2@test.com', 3, 'Street 7', 'HN'),
('user_prem3', 'prem3@test.com', 2, 'Street 8', 'DN'),
('user_prem4', 'prem4@test.com', 4, 'Street 9', 'HCM'),
('user_prem5', 'prem5@test.com', 5, 'Street 10', 'HN'),
-- Nhóm Admin (ID 11-15)
('admin_01', 'admin1@sys.com', 1, 'HQ 1', 'HCM'),
('admin_02', 'admin2@sys.com', 1, 'HQ 2', 'HCM'),
('admin_03', 'admin3@sys.com', 1, 'HQ 3', 'HN'),
('admin_04', 'admin4@sys.com', 1, 'HQ 4', 'DN'),
('admin_05', 'admin5@sys.com', 1, 'HQ 5', 'Hue');
GO

-- =============================================
-- 2. PHÂN LOẠI USER (Mỗi bảng con >= 5 dòng)
-- =============================================
-- Bảng FreeUser (5 dòng)
INSERT INTO FreeUser (userID) VALUES (1), (2), (3), (4), (5);

-- Bảng PremiumUser (5 dòng)
INSERT INTO PremiumUser (userID, subscriptionDate) VALUES 
(6, '2024-01-01'), (7, '2024-02-01'), (8, '2024-03-01'), (9, '2024-04-01'), (10, '2024-05-01');

-- Bảng Admin (5 dòng)
INSERT INTO Admin (userID) VALUES (11), (12), (13), (14), (15);
GO

-- =============================================
-- 3. CÁC TÍNH NĂNG PREMIUM (Mỗi bảng >= 5 dòng)
-- =============================================
-- Bảng Advanced_Alert (5 dòng - gắn với User Premium)
INSERT INTO Advanced_Alert (userID, threshold, notificationType) VALUES
(6, 500000, 'Email'),
(7, 1000000, 'SMS'),
(8, 2000000, 'App Notification'),
(9, 5000000, 'Email'),
(10, 100000, 'SMS');

-- Bảng ExportedData (5 dòng)
INSERT INTO ExportedData (userID, exportDate, fileFormat) VALUES
(6, GETDATE(), 'PDF'),
(6, GETDATE(), 'Excel'),
(7, GETDATE(), 'CSV'),
(8, GETDATE(), 'PDF'),
(9, GETDATE(), 'Excel');
GO

-- =============================================
-- 4. BẢNG WALLET (Tạo 20 Ví để chia đủ loại)
-- =============================================
INSERT INTO Wallet (userID, walletName, currency, createdDate, balance) VALUES
-- Ví Tiền mặt (1-5)
(1, 'Cash Wallet 1', 'VND', GETDATE(), 1000000),
(2, 'Cash Wallet 2', 'VND', GETDATE(), 2000000),
(3, 'Cash Wallet 3', 'VND', GETDATE(), 3000000),
(4, 'Cash Wallet 4', 'USD', GETDATE(), 100),
(5, 'Cash Wallet 5', 'VND', GETDATE(), 500000),
-- Ví Tiết kiệm (6-10)
(6, 'Saving Wallet 1', 'VND', GETDATE(), 50000000),
(6, 'Saving Wallet 2', 'VND', GETDATE(), 20000000),
(7, 'Saving Wallet 3', 'VND', GETDATE(), 10000000),
(8, 'Saving Wallet 4', 'VND', GETDATE(), 5000000),
(9, 'Saving Wallet 5', 'USD', GETDATE(), 5000),
-- Ví Tín dụng (11-15)
(6, 'Credit Wallet 1', 'VND', GETDATE(), 0),
(7, 'Credit Wallet 2', 'VND', GETDATE(), 0),
(8, 'Credit Wallet 3', 'VND', GETDATE(), 0),
(9, 'Credit Wallet 4', 'VND', GETDATE(), 0),
(10, 'Credit Wallet 5', 'VND', GETDATE(), 0),
-- Ví Liên kết (16-20)
(6, 'Bank Wallet 1', 'VND', GETDATE(), 15000000),
(7, 'Bank Wallet 2', 'VND', GETDATE(), 12000000),
(8, 'Bank Wallet 3', 'VND', GETDATE(), 3000000),
(9, 'Bank Wallet 4', 'VND', GETDATE(), 9000000),
(10, 'Bank Wallet 5', 'VND', GETDATE(), 4500000);
GO

-- =============================================
-- 5. PHÂN LOẠI WALLET (Mỗi bảng con >= 5 dòng)
-- =============================================
-- CashWallet (5 dòng)
INSERT INTO CashWallet (walletID) VALUES (1), (2), (3), (4), (5);

-- SavingWallet (5 dòng)
INSERT INTO SavingWallet (walletID, targetAmount, goalDeadline) VALUES 
(6, 100000000, '2025-12-31'), (7, 50000000, '2026-01-01'), (8, 20000000, '2025-06-30'), (9, 10000000, '2025-09-30'), (10, 10000, '2026-12-31');

-- CreditWallet (5 dòng)
INSERT INTO CreditWallet (walletID, creditLimit, dueDate, minPayment) VALUES 
(11, 20000000, 15, 1000000), (12, 30000000, 20, 1500000), (13, 50000000, 25, 2000000), (14, 100000000, 5, 5000000), (15, 15000000, 10, 750000);

-- LinkedWallet (5 dòng)
INSERT INTO LinkedWallet (walletID, connectionStatus, bankName, accountNumber) VALUES
(16, 'Connected', 'VCB', '001'), (17, 'Connected', 'ACB', '002'), (18, 'Error', 'Techcom', '003'), (19, 'Connected', 'VPB', '004'), (20, 'Connected', 'BIDV', '005');
GO

-- =============================================
-- 6. BẢNG CATEGORY (>= 5 dòng)
-- =============================================
INSERT INTO Category (categoryName, type, parentCategoryID) VALUES
(N'Ăn uống', 'Expense', NULL),      -- 1
(N'Di chuyển', 'Expense', NULL),    -- 2
(N'Nhà cửa', 'Expense', NULL),      -- 3
(N'Lương', 'Income', NULL),         -- 4
(N'Thưởng', 'Income', NULL),        -- 5
(N'Cà phê', 'Expense', 1),          -- 6
(N'Xăng xe', 'Expense', 2),         -- 7
(N'Tiền điện', 'Expense', 3);       -- 8
GO

-- =============================================
-- 7. BẢNG TRANSACTION (>= 5 dòng)
-- =============================================
INSERT INTO [Transaction] (amount, description, transactionDate, type, status, sourceWalletID, destinationWalletID, categoryID) VALUES
(50000, 'Cafe sang', GETDATE(), 'expense', 'completed', 1, NULL, 6),
(30000, 'Banh mi', GETDATE(), 'expense', 'completed', 2, NULL, 1),
(500000, 'Do xang', GETDATE(), 'expense', 'completed', 3, NULL, 7),
(1000000, 'Tien dien thang nay', GETDATE(), 'expense', 'completed', 16, NULL, 8),
(20000000, 'Nhan luong', GETDATE(), 'income', 'completed', NULL, 16, 4),
(5000000, 'Chuyen khoan', GETDATE(), 'transfer', 'completed', 16, 6, 4);
GO

-- =============================================
-- 8. BẢNG BUDGET & LINK (Mỗi bảng >= 5 dòng)
-- =============================================
-- Tạo 5 ngân sách
INSERT INTO Budget (walletID, budgetName, startDate, endDate, isRecurring) VALUES
(1, 'Budget 1', '2025-10-01', '2025-10-31', 0),
(2, 'Budget 2', '2025-10-01', '2025-10-31', 0),
(6, 'Budget 3', '2025-11-01', '2025-11-30', 0),
(16, 'Budget 4', '2025-10-01', '2025-12-31', 1),
(17, 'Budget 5', '2025-01-01', '2025-12-31', 1);

-- Chi tiết ngân sách (5 dòng)
INSERT INTO Budget_Category_Link (budgetID, categoryID, limitAmount) VALUES
(1, 1, 2000000), (2, 2, 500000), (3, 3, 3000000), (4, 1, 5000000), (5, 6, 1000000);
GO