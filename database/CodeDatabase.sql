CREATE DATABASE EERD_Project;
GO
USE EERD_Project;
GO

-- 1. Bảng User
CREATE TABLE [User] (
    userID INT PRIMARY KEY IDENTITY(1,1),
    username NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    CONSTRAINT CHK_User_Email CHECK (email LIKE '%_@__%.__%'), -- Ràng buộc định dạng Email
    deviceCount INT DEFAULT 0,
    street NVARCHAR(255),
    city NVARCHAR(100)
);

-- 2. Các loại User (Subtypes)
CREATE TABLE FreeUser (
    userID INT PRIMARY KEY,
    CONSTRAINT FK_FreeUser_User FOREIGN KEY (userID) REFERENCES [User](userID)
);

CREATE TABLE PremiumUser (
    userID INT PRIMARY KEY,
    subscriptionDate DATE NOT NULL,
    CONSTRAINT FK_PremiumUser_User FOREIGN KEY (userID) REFERENCES [User](userID)
);

CREATE TABLE Admin (
    userID INT PRIMARY KEY,
    CONSTRAINT FK_Admin_User FOREIGN KEY (userID) REFERENCES [User](userID)
);

-- 3. Các tính năng nâng cao (Cho Premium)
CREATE TABLE Advanced_Alert (
    alertID INT PRIMARY KEY IDENTITY(1,1),
    userID INT NOT NULL UNIQUE, 
    threshold DECIMAL(18, 2) NOT NULL,
    notificationType NVARCHAR(50),
    CONSTRAINT FK_Alert_PremiumUser FOREIGN KEY (userID) REFERENCES PremiumUser(userID)
);

CREATE TABLE ExportedData (
    userID INT,
    exportID INT IDENTITY(1,1),
    exportDate DATETIME NOT NULL,
    fileFormat NVARCHAR(10) NOT NULL, 
    PRIMARY KEY (userID, exportID),
    CONSTRAINT FK_Export_PremiumUser FOREIGN KEY (userID) REFERENCES PremiumUser(userID)
);

-- 4. Bảng Wallet (Supertype) - Đã thêm cột BALANCE
CREATE TABLE Wallet (
    walletID INT PRIMARY KEY IDENTITY(1,1),
    userID INT NOT NULL,
    walletName NVARCHAR(100) NOT NULL,
    currency NVARCHAR(10) NOT NULL,
    createdDate DATETIME DEFAULT GETDATE(),
    balance DECIMAL(18, 2) DEFAULT 0, -- Cột mới thêm để phục vụ Trigger tính toán
    CONSTRAINT FK_Wallet_User FOREIGN KEY (userID) REFERENCES [User](userID)
);

-- 5. Các loại Wallet (Subtypes)
CREATE TABLE CashWallet (
    walletID INT PRIMARY KEY,
    CONSTRAINT FK_CashWallet_Wallet FOREIGN KEY (walletID) REFERENCES Wallet(walletID)
);

CREATE TABLE SavingWallet (
    walletID INT PRIMARY KEY,
    targetAmount DECIMAL(18, 2),
    goalDeadline DATE,
    CONSTRAINT FK_SavingWallet_Wallet FOREIGN KEY (walletID) REFERENCES Wallet(walletID)
);

CREATE TABLE CreditWallet (
    walletID INT PRIMARY KEY,
    creditLimit DECIMAL(18, 2) NOT NULL,
    dueDate INT, 
    minPayment DECIMAL(18, 2),
    CONSTRAINT FK_CreditWallet_Wallet FOREIGN KEY (walletID) REFERENCES Wallet(walletID)
);

CREATE TABLE LinkedWallet (
    walletID INT PRIMARY KEY,
    connectionStatus NVARCHAR(50),
    bankName NVARCHAR(100),
    accountNumber NVARCHAR(50),
    CONSTRAINT FK_LinkedWallet_Wallet FOREIGN KEY (walletID) REFERENCES Wallet(walletID)
);

-- 6. Danh mục (Category)
CREATE TABLE Category (
    categoryID INT PRIMARY KEY IDENTITY(1,1),
    categoryName NVARCHAR(100) NOT NULL,
    type NVARCHAR(20) NOT NULL, -- Income/Expense
    parentCategoryID INT,
    CONSTRAINT FK_Category_Recursive FOREIGN KEY (parentCategoryID) REFERENCES Category(categoryID)
);

-- 7. Giao dịch (Transaction) - Đã thêm CHECK Amount > 0
CREATE TABLE [Transaction] (
    transactionID INT PRIMARY KEY IDENTITY(1,1),
    amount DECIMAL(18, 2) NOT NULL,
    description NVARCHAR(500),
    transactionDate DATETIME NOT NULL,
    type NVARCHAR(20) NOT NULL, -- Income/Expense/Transfer
    status NVARCHAR(20),
    
    sourceWalletID INT, 
    destinationWalletID INT, 
    categoryID INT NOT NULL, 
    
    CONSTRAINT FK_Transaction_SourceWallet FOREIGN KEY (sourceWalletID) REFERENCES Wallet(walletID),
    CONSTRAINT FK_Transaction_DestinationWallet FOREIGN KEY (destinationWalletID) REFERENCES Wallet(walletID),
    CONSTRAINT FK_Transaction_Category FOREIGN KEY (categoryID) REFERENCES Category(categoryID),
    
    CONSTRAINT CHK_TransferWallets CHECK (sourceWalletID <> destinationWalletID OR type <> 'transfer'),
    CONSTRAINT CHK_Transaction_Amount CHECK (amount > 0) -- Ràng buộc mới: Tiền phải dương
);

-- 8. Ngân sách (Budget)
CREATE TABLE Budget (
    budgetID INT PRIMARY KEY IDENTITY(1,1),
    walletID INT NOT NULL, 
    budgetName NVARCHAR(100),
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    isRecurring BIT DEFAULT 0,
    
    CONSTRAINT FK_Budget_Wallet FOREIGN KEY (walletID) REFERENCES Wallet(walletID),
    CONSTRAINT CHK_Budget_Dates CHECK (startDate < endDate) -- Ràng buộc ngày bắt đầu < kết thúc
);

-- 9. Chi tiết Ngân sách (Budget Category Link)
CREATE TABLE Budget_Category_Link (
    budgetID INT,
    categoryID INT,
    limitAmount DECIMAL(18, 2) NOT NULL,
    
    PRIMARY KEY (budgetID, categoryID),
    CONSTRAINT FK_Link_Budget FOREIGN KEY (budgetID) REFERENCES Budget(budgetID),
    CONSTRAINT FK_Link_Category FOREIGN KEY (categoryID) REFERENCES Category(categoryID),
    
    CONSTRAINT CHK_Link_LimitAmount CHECK (limitAmount >= 0) -- Ràng buộc hạn mức không âm
);