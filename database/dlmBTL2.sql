USE EERD_Project;

INSERT INTO `user` (username, email, password, deviceCount, street, city) VALUES 

('u_free_1', 'free1@gmail.com', 'Pass@1234', 1, 'Street 1', 'Hanoi'),
('u_free_2', 'free2@gmail.com', 'Pass@1234', 1, 'Street 2', 'Hanoi'),
('u_free_3', 'free3@gmail.com', 'Pass@1234', 1, 'Street 3', 'Danang'),
('u_free_4', 'free4@gmail.com', 'Pass@1234', 1, 'Street 4', 'HCM'),
('u_free_5', 'free5@gmail.com', 'Pass@1234', 1, 'Street 5', 'HCM'),


('u_prem_1', 'prem1@gmail.com', 'Pass@1234', 3, 'Street 6', 'Hanoi'),
('u_prem_2', 'prem2@gmail.com', 'Pass@1234', 4, 'Street 7', 'HCM'),
('u_prem_3', 'prem3@gmail.com', 'Pass@1234', 2, 'Street 8', 'Can Tho'),
('u_prem_4', 'prem4@gmail.com', 'Pass@1234', 5, 'Street 9', 'Hai Phong'),
('u_prem_5', 'prem5@gmail.com', 'Pass@1234', 2, 'Street 10', 'Hue'),


('admin_1', 'admin1@sys.com', 'Admin@Root1', 1, 'HQ 1', 'Cloud'),
('admin_2', 'admin2@sys.com', 'Admin@Root2', 1, 'HQ 2', 'Cloud'),
('admin_3', 'admin3@sys.com', 'Admin@Root3', 1, 'HQ 3', 'Cloud'),
('admin_4', 'admin4@sys.com', 'Admin@Root4', 1, 'HQ 4', 'Cloud'),
('admin_5', 'admin5@sys.com', 'Admin@Root5', 1, 'HQ 5', 'Cloud');


INSERT INTO FreeUser (userID) VALUES (1), (2), (3), (4), (5);

INSERT INTO PremiumUser (userID, subscriptionDate) VALUES 
(6, '2024-01-01'), (7, '2024-02-15'), (8, '2024-03-20'), (9, '2024-05-01'), (10, '2024-06-01');

INSERT INTO `Admin` (userID) VALUES (11), (12), (13), (14), (15);


INSERT INTO Category (categoryName, `type`, parentCategoryID) VALUES 
('Thực phẩm', 'expense', NULL),      -- 1
('Di chuyển', 'expense', NULL),      -- 2
('Thu nhập', 'income', NULL),        -- 3
('Hóa đơn', 'expense', NULL),        -- 4
('Sức khỏe', 'expense', NULL),       -- 5
('Siêu thị', 'expense', 1),          -- 6
('Nhà hàng', 'expense', 1),          -- 7
('Grab/Taxi', 'expense', 2),         -- 8
('Lương cứng', 'income', 3),         -- 9
('Tiền điện', 'expense', 4);         -- 10


INSERT INTO Wallet (userID, walletName, currency, balance) VALUES 
(1, 'Ví Tiền Mặt 1', 'VND', 0),
(2, 'Ví Tiền Mặt 2', 'VND', 0),
(3, 'Ví Tiền Mặt 3', 'VND', 0),
(4, 'Ví Tiền Mặt 4', 'VND', 0),
(5, 'Ví Tiền Mặt 5', 'VND', 0);


INSERT INTO Wallet (userID, walletName, currency, balance) VALUES 
(6, 'Heo Đất Online', 'VND', 0),
(7, 'Quỹ Mua Nhà', 'VND', 0),
(8, 'Tiết Kiệm Cưới', 'VND', 0),
(9, 'Quỹ Du Lịch', 'USD', 0),
(10, 'Tiền Nhàn Rỗi', 'VND', 0);


INSERT INTO Wallet (userID, walletName, currency, balance) VALUES 
(6, 'Thẻ Visa Gold', 'VND', 0),
(7, 'Thẻ Master', 'VND', 0),
(8, 'Thẻ JCB', 'VND', 0),
(9, 'Thẻ Amex', 'USD', 0),
(10, 'Thẻ Visa Debit', 'VND', 0);


INSERT INTO Wallet (userID, walletName, currency, balance) VALUES 
(6, 'Ví Momo', 'VND', 0),
(7, 'ZaloPay', 'VND', 0),
(8, 'ViettelMoney', 'VND', 0),
(9, 'Paypal', 'USD', 0),
(10, 'ApplePay', 'VND', 0);


INSERT INTO CashWallet (walletID) VALUES (1), (2), (3), (4), (5);

INSERT INTO SavingWallet (walletID, targetAmount, goalDeadline) VALUES 
(6, 10000000, '2025-12-31'),
(7, 500000000, '2030-01-01'),
(8, 50000000, '2026-06-01'),
(9, 2000, '2025-08-01'),
(10, 10000000, '2025-12-31');

INSERT INTO CreditWallet (walletID, creditLimit, dueDate, minPayment) VALUES 
(11, 20000000, 15, 1000000),
(12, 30000000, 20, 1500000),
(13, 15000000, 10, 500000),
(14, 5000, 1, 100),
(15, 25000000, 25, 1000000);

INSERT INTO LinkedWallet (walletID, connectionStatus) VALUES 
(16, 'Active'), (17, 'Active'), (18, 'Active'), (19, 'Active'), (20, 'Inactive');


INSERT INTO BankLink_MVA (walletID, accountNumber, bankName) VALUES 
(16, '0987654321', 'MB Bank'),
(17, '0912345678', 'Vietinbank'),
(18, '0345678910', 'Agribank'),
(19, 'user@paypal.com', 'Paypal Inc'),
(20, '0011223344', 'TPBank');

-- Advanced_Alert (User 6-10)
INSERT INTO Advanced_Alert (userID, threshold, notificationType) VALUES 
(6, 500000, 'Email'),
(7, 1000000, 'SMS'),
(8, 200000, 'Push'),
(9, 100, 'Email'),
(10, 3000000, 'SMS');

-- ExportedData (User 6-10)
INSERT INTO ExportedData (userID, exportID, exportDate, fileFormat) VALUES 
(6, 1, DATE_SUB(NOW(), INTERVAL 1 DAY), 'PDF'),
(7, 1, DATE_SUB(NOW(), INTERVAL 2 DAY), 'CSV'),
(8, 1, DATE_SUB(NOW(), INTERVAL 3 DAY), 'EXCEL'),
(9, 1, DATE_SUB(NOW(), INTERVAL 4 DAY), 'PDF'),
(10, 1, DATE_SUB(NOW(), INTERVAL 5 DAY), 'JSON');


INSERT INTO Budget (userID, budgetName, startDate, endDate, isRecurring) VALUES 
(1, 'Budget Free U1', '2025-12-01', '2025-12-31', 1),
(2, 'Budget Free U2', '2025-12-01', '2025-12-31', 0),
(6, 'Budget Prem U6', '2025-11-01', '2025-11-30', 1),
(7, 'Budget Prem U7', '2025-10-01', '2025-12-31', 0),
(8, 'Budget Prem U8', '2025-12-01', '2026-01-01', 1);

INSERT INTO Budget_Category_Link (budgetID, categoryID, limitAmount) VALUES 
(1, 1, 2000000), 
(2, 2, 500000),  
(3, 6, 3000000), 
(4, 7, 5000000), 
(5, 4, 1500000); 


INSERT INTO `Transaction` (amount, description, transactionDate, type, status, sourceWalletID, destinationWalletID, categoryID) VALUES 
(10000000, 'Lương U1', '2025-12-01 08:00:00', 'income', 'Completed', NULL, 1, 9),
(12000000, 'Lương U2', '2025-12-01 08:00:00', 'income', 'Completed', NULL, 2, 9),
(15000000, 'Lương U3', '2025-12-01 08:00:00', 'income', 'Completed', NULL, 3, 9),
(20000000, 'Lương U6', '2025-12-01 08:00:00', 'income', 'Completed', NULL, 6, 9), 
(50000000, 'Lương U7', '2025-12-01 08:00:00', 'income', 'Completed', NULL, 7, 9);


INSERT INTO `Transaction` (amount, description, transactionDate, type, status, sourceWalletID, destinationWalletID, categoryID) VALUES 
(50000, 'Ăn sáng U1', '2025-12-02 07:00:00', 'expense', 'Completed', 1, NULL, 7),
(100000, 'Xăng xe U2', '2025-12-02 08:00:00', 'expense', 'Completed', 2, NULL, 8),
(2000000, 'Mua sắm Credit U6', '2025-12-03 19:00:00', 'expense', 'Completed', 11, NULL, 6), 
(1500000, 'Thanh toán Credit U7', '2025-12-03 20:00:00', 'expense', 'Completed', 12, NULL, 10), 
(500000, 'Cafe U3', '2025-12-04 09:00:00', 'expense', 'Completed', 3, NULL, 7);