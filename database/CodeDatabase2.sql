-- Active: 1764922389757@@127.0.0.1@3306@mysql
-- =============================================
-- FULL SQL SCRIPT (MySQL 8+)
-- Schema + Triggers + Procedures + Functions
-- =============================================

-- -------------------------
-- 0. Cleanup if rerun
-- -------------------------
DROP DATABASE IF EXISTS EERD_Project;

CREATE DATABASE EERD_Project;

USE EERD_Project;

-- Drop lingering objects
DROP PROCEDURE IF EXISTS sp_InsertTransaction;

DROP PROCEDURE IF EXISTS sp_UpdateTransaction;

DROP PROCEDURE IF EXISTS sp_DeleteTransaction;

DROP PROCEDURE IF EXISTS sp_GetTransactionsByUser;

DROP PROCEDURE IF EXISTS sp_SummaryExpenseByCategory;

DROP FUNCTION IF EXISTS fn_TotalBalance;

DROP FUNCTION IF EXISTS fn_UserMonthlyExpense;

DROP TRIGGER IF EXISTS TRG_User_Disjoint_Free;

DROP TRIGGER IF EXISTS TRG_User_Disjoint_Premium;

DROP TRIGGER IF EXISTS TRG_User_Disjoint_Admin;

DROP TRIGGER IF EXISTS TRG_Wallet_Disjoint_Cash;

DROP TRIGGER IF EXISTS TRG_Wallet_Disjoint_Saving;

DROP TRIGGER IF EXISTS TRG_Wallet_Disjoint_Credit;

DROP TRIGGER IF EXISTS TRG_Wallet_Disjoint_Linked;

DROP TRIGGER IF EXISTS TRG_Wallet_Balance_Insert;

DROP TRIGGER IF EXISTS TRG_Wallet_Balance_Update;

DROP TRIGGER IF EXISTS TRG_Wallet_Balance_Delete;

DROP TRIGGER IF EXISTS TRG_Premium_User_DeviceLimit;

DROP TRIGGER IF EXISTS TRG_FreeUser_Limits;

DROP TRIGGER IF EXISTS TRG_FreeUser_BudgetLimit;

DROP TRIGGER IF EXISTS TRG_Transaction_Validate;

DROP TRIGGER IF EXISTS TRG_Budget_Category_TimeOverlap;

DROP TRIGGER IF EXISTS TRG_ExportedData_DateInsert;

DROP TRIGGER IF EXISTS TRG_ExportedData_DateUpdate;

-- -------------------------
-- 1. SCHEMA
-- -------------------------

CREATE TABLE `user` (
    userID INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    deviceCount INT DEFAULT 0,
    street NVARCHAR (255),
    city NVARCHAR (100),
    CONSTRAINT CHK_User_Email CHECK (email LIKE '%_@__%.__%'),
    CONSTRAINT CHK_User_Password CHECK (
        CHAR_LENGTH(password) >= 8
        AND password REGEXP '[A-Z]'
        AND password REGEXP '[a-z]'
        AND password REGEXP '[0-9]'
        AND password REGEXP '[^A-Za-z0-9]'
    )
);

CREATE TABLE FreeUser (
    userID INT PRIMARY KEY,
    CONSTRAINT FK_FreeUser_User FOREIGN KEY (userID) REFERENCES `user` (userID) ON DELETE CASCADE
);

CREATE TABLE PremiumUser (
    userID INT PRIMARY KEY,
    subscriptionDate DATE NOT NULL,
    CONSTRAINT FK_PremiumUser_User FOREIGN KEY (userID) REFERENCES `user` (userID) ON DELETE CASCADE
);

CREATE TABLE `Admin` (
    userID INT PRIMARY KEY,
    CONSTRAINT FK_Admin_User FOREIGN KEY (userID) REFERENCES `user` (userID) ON DELETE CASCADE
);

CREATE TABLE Advanced_Alert (
    alertID INT PRIMARY KEY AUTO_INCREMENT,
    userID INT NOT NULL UNIQUE,
    threshold DECIMAL(18, 2) NOT NULL,
    notificationType NVARCHAR (255),
    CONSTRAINT FK_Alert_PremiumUser FOREIGN KEY (userID) REFERENCES PremiumUser (userID) ON DELETE CASCADE
);

CREATE TABLE ExportedData (
    userID INT NOT NULL,
    exportID INT NOT NULL,
    exportDate DATETIME NOT NULL,
    fileFormat VARCHAR(10) NOT NULL,
    PRIMARY KEY (userID, exportID),
    CONSTRAINT FK_Export_PremiumUser FOREIGN KEY (userID) REFERENCES PremiumUser (userID) ON DELETE CASCADE
);

CREATE TABLE Wallet (
    walletID INT PRIMARY KEY AUTO_INCREMENT,
    userID INT NOT NULL,
    walletName NVARCHAR (100) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    balance DECIMAL(18, 2) DEFAULT 0,
    CONSTRAINT FK_Wallet_User FOREIGN KEY (userID) REFERENCES `user` (userID) ON DELETE CASCADE
);

CREATE TABLE CashWallet (
    walletID INT PRIMARY KEY,
    CONSTRAINT FK_CashWallet_Wallet FOREIGN KEY (walletID) REFERENCES Wallet (walletID) ON DELETE CASCADE
);

CREATE TABLE SavingWallet (
    walletID INT PRIMARY KEY,
    targetAmount DECIMAL(18, 2),
    goalDeadline DATE,
    CONSTRAINT FK_SavingWallet_Wallet FOREIGN KEY (walletID) REFERENCES Wallet (walletID) ON DELETE CASCADE
);

CREATE TABLE CreditWallet (
    walletID INT PRIMARY KEY,
    creditLimit DECIMAL(18, 2) NOT NULL,
    dueDate INT,
    minPayment DECIMAL(18, 2),
    CONSTRAINT FK_CreditWallet_Wallet FOREIGN KEY (walletID) REFERENCES Wallet (walletID) ON DELETE CASCADE,
    CONSTRAINT CHK_DueDate CHECK (dueDate BETWEEN 1 AND 31)
);

CREATE TABLE LinkedWallet (
    walletID INT PRIMARY KEY,
    connectionStatus VARCHAR(50) NOT NULL,
    CONSTRAINT FK_LinkedWallet_Wallet FOREIGN KEY (walletID) REFERENCES Wallet (walletID) ON DELETE CASCADE
);

CREATE TABLE BankLink_MVA (
    walletID INT NOT NULL,
    accountNumber VARCHAR(50) NOT NULL,
    bankName VARCHAR(100) NOT NULL,
    PRIMARY KEY (
        walletID,
        accountNumber,
        bankName
    ),
    CONSTRAINT FK_BankLink_Wallet FOREIGN KEY (walletID) REFERENCES LinkedWallet (walletID) ON DELETE CASCADE
);

CREATE TABLE Category (
    categoryID INT PRIMARY KEY AUTO_INCREMENT,
    categoryName NVARCHAR (100) NOT NULL,
    `type` VARCHAR(20) NOT NULL,
    parentCategoryID INT,
    CONSTRAINT FK_Category_Recursive FOREIGN KEY (parentCategoryID) REFERENCES Category (categoryID) ON DELETE SET NULL
);

CREATE TABLE `Transaction` (
    transactionID INT PRIMARY KEY AUTO_INCREMENT,
    amount DECIMAL(18, 2) NOT NULL,
    `description` NVARCHAR (500),
    transactionDate DATETIME NOT NULL,
    `type` VARCHAR(20) NOT NULL,
    `status` VARCHAR(20) NOT NULL,
    sourceWalletID INT,
    destinationWalletID INT,
    categoryID INT,
    CONSTRAINT FK_Transaction_SourceWallet FOREIGN KEY (sourceWalletID) REFERENCES Wallet (walletID) ON DELETE SET NULL,
    CONSTRAINT FK_Transaction_DestinationWallet FOREIGN KEY (destinationWalletID) REFERENCES Wallet (walletID) ON DELETE SET NULL,
    CONSTRAINT FK_Transaction_Category FOREIGN KEY (categoryID) REFERENCES Category (categoryID) ON DELETE RESTRICT,
    CONSTRAINT CHK_Transaction_Amount CHECK (amount > 0)
);

CREATE TABLE Budget (
    budgetID INT PRIMARY KEY AUTO_INCREMENT,
    userID INT NOT NULL,
    budgetName NVARCHAR (100),
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    isRecurring TINYINT(1) DEFAULT 0,
    CONSTRAINT FK_Budget_User FOREIGN KEY (userID) REFERENCES `user` (userID) ON DELETE CASCADE,
    CONSTRAINT CHK_Budget_Dates CHECK (startDate < endDate)
);

CREATE TABLE Budget_Category_Link (
    budgetID INT NOT NULL,
    categoryID INT NOT NULL,
    limitAmount DECIMAL(18, 2) NOT NULL,
    PRIMARY KEY (budgetID, categoryID),
    CONSTRAINT FK_Link_Budget FOREIGN KEY (budgetID) REFERENCES Budget (budgetID) ON DELETE CASCADE,
    CONSTRAINT FK_Link_Category FOREIGN KEY (categoryID) REFERENCES Category (categoryID) ON DELETE CASCADE,
    CONSTRAINT CHK_Link_LimitAmount CHECK (limitAmount >= 0)
);

-- -------------------------
-- 2. TRIGGERS (Disjoint + Balance + Validation)
-- -------------------------
DELIMITER $$

-- User subtype disjoint triggers
CREATE TRIGGER TRG_User_Disjoint_Free
BEFORE INSERT ON FreeUser
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM PremiumUser WHERE userID = NEW.userID)
    OR EXISTS (SELECT 1 FROM `Admin` WHERE userID = NEW.userID)
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Disjoint violation: user already belongs to another subtype';
    END IF;
END$$

CREATE TRIGGER TRG_User_Disjoint_Premium
BEFORE INSERT ON PremiumUser
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM FreeUser WHERE userID = NEW.userID)
    OR EXISTS (SELECT 1 FROM `Admin` WHERE userID = NEW.userID)
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Disjoint violation: user already belongs to another subtype';
    END IF;
END$$

CREATE TRIGGER TRG_User_Disjoint_Admin
BEFORE INSERT ON `Admin`
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM FreeUser WHERE userID = NEW.userID)
    OR EXISTS (SELECT 1 FROM PremiumUser WHERE userID = NEW.userID)
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Disjoint violation: user already belongs to another subtype';
    END IF;
END$$

-- Wallet subtype disjoint triggers
CREATE TRIGGER TRG_Wallet_Disjoint_Cash
BEFORE INSERT ON CashWallet
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM SavingWallet WHERE walletID = NEW.walletID)
    OR EXISTS (SELECT 1 FROM CreditWallet WHERE walletID = NEW.walletID)
    OR EXISTS (SELECT 1 FROM LinkedWallet WHERE walletID = NEW.walletID)
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Disjoint violation: wallet already belongs to another subtype';
    END IF;
END$$

CREATE TRIGGER TRG_Wallet_Disjoint_Saving
BEFORE INSERT ON SavingWallet
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM CashWallet WHERE walletID = NEW.walletID)
    OR EXISTS (SELECT 1 FROM CreditWallet WHERE walletID = NEW.walletID)
    OR EXISTS (SELECT 1 FROM LinkedWallet WHERE walletID = NEW.walletID)
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Disjoint violation: wallet already belongs to another subtype';
    END IF;
END$$

CREATE TRIGGER TRG_Wallet_Disjoint_Credit
BEFORE INSERT ON CreditWallet
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM CashWallet WHERE walletID = NEW.walletID)
    OR EXISTS (SELECT 1 FROM SavingWallet WHERE walletID = NEW.walletID)
    OR EXISTS (SELECT 1 FROM LinkedWallet WHERE walletID = NEW.walletID)
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Disjoint violation: wallet already belongs to another subtype';
    END IF;
END$$

CREATE TRIGGER TRG_Wallet_Disjoint_Linked
BEFORE INSERT ON LinkedWallet
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM CashWallet WHERE walletID = NEW.walletID)
    OR EXISTS (SELECT 1 FROM SavingWallet WHERE walletID = NEW.walletID)
    OR EXISTS (SELECT 1 FROM CreditWallet WHERE walletID = NEW.walletID)
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Disjoint violation: wallet already belongs to another subtype';
    END IF;
END$$

-- Wallet balance triggers
CREATE TRIGGER TRG_Wallet_Balance_Insert
AFTER INSERT ON `Transaction`
FOR EACH ROW
BEGIN
    IF NEW.status = 'Completed' THEN
        IF NEW.sourceWalletID IS NOT NULL THEN UPDATE Wallet SET balance = balance - NEW.amount WHERE walletID = NEW.sourceWalletID; END IF;
        IF NEW.destinationWalletID IS NOT NULL THEN UPDATE Wallet SET balance = balance + NEW.amount WHERE walletID = NEW.destinationWalletID; END IF;
    END IF;
END$$

CREATE TRIGGER TRG_Wallet_Balance_Delete
AFTER DELETE ON `Transaction`
FOR EACH ROW
BEGIN
    IF OLD.status = 'Completed' THEN
        IF OLD.sourceWalletID IS NOT NULL THEN UPDATE Wallet SET balance = balance + OLD.amount WHERE walletID = OLD.sourceWalletID; END IF;
        IF OLD.destinationWalletID IS NOT NULL THEN UPDATE Wallet SET balance = balance - OLD.amount WHERE walletID = OLD.destinationWalletID; END IF;
    END IF;
END$$

CREATE TRIGGER TRG_Wallet_Balance_Update
AFTER UPDATE ON `Transaction`
FOR EACH ROW
BEGIN
    -- rollback old if it was completed
    IF OLD.status = 'Completed' THEN
        IF OLD.sourceWalletID IS NOT NULL THEN UPDATE Wallet SET balance = balance + OLD.amount WHERE walletID = OLD.sourceWalletID; END IF;
        IF OLD.destinationWalletID IS NOT NULL THEN UPDATE Wallet SET balance = balance - OLD.amount WHERE walletID = OLD.destinationWalletID; END IF;
    END IF;
    -- apply new if it's completed
    IF NEW.status = 'Completed' THEN
        IF NEW.sourceWalletID IS NOT NULL THEN UPDATE Wallet SET balance = balance - NEW.amount WHERE walletID = NEW.sourceWalletID; END IF;
        IF NEW.destinationWalletID IS NOT NULL THEN UPDATE Wallet SET balance = balance + NEW.amount WHERE walletID = NEW.destinationWalletID; END IF;
    END IF;
END$$

-- Premium user device limit
CREATE TRIGGER TRG_Premium_User_DeviceLimit
BEFORE UPDATE ON `user`
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM PremiumUser WHERE userID = NEW.userID) THEN
        IF NEW.deviceCount > 5 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Premium users may log in on max 5 devices';
        END IF;
    END IF;
END$$

-- Free user wallet & budget limits
CREATE TRIGGER TRG_FreeUser_Limits
BEFORE INSERT ON Wallet
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM FreeUser WHERE userID = NEW.userID) THEN
        IF (SELECT COUNT(*) FROM Wallet WHERE userID = NEW.userID) >= 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'FreeUser can only have 1 wallet';
        END IF;
    END IF;
END$$

CREATE TRIGGER TRG_FreeUser_BudgetLimit
BEFORE INSERT ON Budget
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM FreeUser WHERE userID = NEW.userID) THEN
        IF (SELECT COUNT(*) FROM Budget WHERE userID = NEW.userID) >= 2 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'FreeUser can only have 2 budgets';
        END IF;
    END IF;
END$$

-- Transaction validation (transfer & balance)
CREATE TRIGGER TRG_Transaction_Validate
BEFORE INSERT ON `Transaction`
FOR EACH ROW
BEGIN
    DECLARE srcUserID INT;
    DECLARE dstUserID INT;
    DECLARE srcBalance DECIMAL(18,2);
    DECLARE srcStatus VARCHAR(50);
    DECLARE dstStatus VARCHAR(50);
    DECLARE crLimit DECIMAL(18,2);

    IF NEW.type = 'transfer' THEN
        IF NEW.sourceWalletID IS NULL OR NEW.destinationWalletID IS NULL THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer requires both source and destination wallets';
        END IF;
        IF NEW.sourceWalletID = NEW.destinationWalletID THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source and destination wallets must be different';
        END IF;
        SELECT userID INTO srcUserID FROM Wallet WHERE walletID = NEW.sourceWalletID;
        SELECT userID INTO dstUserID FROM Wallet WHERE walletID = NEW.destinationWalletID;
        IF srcUserID <> dstUserID THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer wallets must belong to the same user';
        END IF;
    END IF;

    IF NEW.sourceWalletID IS NOT NULL THEN
        SELECT balance INTO srcBalance FROM Wallet WHERE walletID = NEW.sourceWalletID;
        SELECT connectionStatus INTO srcStatus FROM LinkedWallet WHERE walletID = NEW.sourceWalletID;
        IF srcStatus IS NOT NULL AND srcStatus <> 'Active' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source LinkedWallet is not Active';
        END IF;
        IF NEW.type IN ('expense','transfer') THEN
            IF EXISTS (SELECT 1 FROM CreditWallet WHERE walletID = NEW.sourceWalletID) THEN
                SELECT creditLimit INTO crLimit FROM CreditWallet WHERE walletID = NEW.sourceWalletID;
                IF crLimit IS NULL THEN SET crLimit = 0; END IF;
                IF (srcBalance - NEW.amount) < (crLimit * -1) THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient credit limit in source wallet';
                END IF;
            ELSE
                IF srcBalance < NEW.amount THEN
                    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance in source wallet';
                END IF;
            END IF;
        END IF;
    END IF;

    IF NEW.destinationWalletID IS NOT NULL THEN
        SELECT connectionStatus INTO dstStatus FROM LinkedWallet WHERE walletID = NEW.destinationWalletID;
        IF dstStatus IS NOT NULL AND dstStatus <> 'Active' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Destination LinkedWallet is not Active';
        END IF;
    END IF;
END$$

-- Budget-category time overlap
CREATE TRIGGER TRG_Budget_Category_TimeOverlap
BEFORE INSERT ON Budget_Category_Link
FOR EACH ROW
BEGIN
    DECLARE budgetStart DATE;
    DECLARE budgetEnd DATE;
    DECLARE overlapCount INT;

    SELECT startDate, endDate INTO budgetStart, budgetEnd FROM Budget WHERE budgetID = NEW.budgetID;
    IF budgetStart IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Budget not found';
    END IF;

    SELECT COUNT(*) INTO overlapCount
    FROM Budget_Category_Link BCL
    JOIN Budget B ON BCL.budgetID = B.budgetID
    WHERE B.userID = (SELECT userID FROM Budget WHERE budgetID = NEW.budgetID)
      AND BCL.categoryID = NEW.categoryID
      AND NEW.budgetID <> BCL.budgetID
      AND B.startDate <= budgetEnd
      AND B.endDate >= budgetStart;

    IF overlapCount > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Budget time overlaps with existing budget in same category';
    END IF;
END$$

-- ExportedData date validation triggers
CREATE TRIGGER TRG_ExportedData_DateInsert
BEFORE INSERT ON ExportedData
FOR EACH ROW
BEGIN
    IF NEW.exportDate > NOW() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'exportDate cannot be in the future';
    END IF;
END$$

CREATE TRIGGER TRG_ExportedData_DateUpdate
BEFORE UPDATE ON ExportedData
FOR EACH ROW
BEGIN
    IF NEW.exportDate > NOW() THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'exportDate cannot be in the future';
    END IF;
END$$

-- -------------------------
-- 3. STORED PROCEDURES (CRUD + Reports)
-- -------------------------

-- 3.1 Insert Transaction procedure (wraps insert + allow triggers to validate)
CREATE PROCEDURE sp_InsertTransaction(
    IN p_amount DECIMAL(18,2),
    IN p_description VARCHAR(500),
    IN p_transactionDate DATETIME,
    IN p_type VARCHAR(20),
    IN p_status VARCHAR(20),
    IN p_sourceWalletID INT,
    IN p_destinationWalletID INT,
    IN p_categoryID INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- on error, rethrow
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error inserting transaction (validation failed)';
    END;

    START TRANSACTION;

    -- Basic checks here (redundant with triggers but give clearer messages)
    IF p_amount <= 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Amount must be > 0';
    END IF;

    IF p_sourceWalletID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Wallet WHERE walletID = p_sourceWalletID) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source wallet not found';
    END IF;

    IF p_destinationWalletID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Wallet WHERE walletID = p_destinationWalletID) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Destination wallet not found';
    END IF;

    IF p_categoryID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Category WHERE categoryID = p_categoryID) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Category not found';
    END IF;

    INSERT INTO `Transaction` (amount, description, transactionDate, type, status, sourceWalletID, destinationWalletID, categoryID)
    VALUES (p_amount, p_description, p_transactionDate, p_type, p_status, p_sourceWalletID, p_destinationWalletID, p_categoryID);

    COMMIT;
END$$

-- 3.2 Update Transaction procedure
CREATE PROCEDURE sp_UpdateTransaction(
    IN p_transactionID INT,
    IN p_amount DECIMAL(18,2),
    IN p_description VARCHAR(500),
    IN p_transactionDate DATETIME,
    IN p_type VARCHAR(20),
    IN p_status VARCHAR(20),
    IN p_sourceWalletID INT,
    IN p_destinationWalletID INT,
    IN p_categoryID INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error updating transaction (validation failed)';
    END;

    START TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM `Transaction` WHERE transactionID = p_transactionID) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction not found';
    END IF;

    -- To safely modify balances, we will:
    -- 1) perform update (triggers will revert old effect and apply new effect)
    UPDATE `Transaction`
    SET amount = p_amount,
        description = p_description,
        transactionDate = p_transactionDate,
        type = p_type,
        status = p_status,
        sourceWalletID = p_sourceWalletID,
        destinationWalletID = p_destinationWalletID,
        categoryID = p_categoryID
    WHERE transactionID = p_transactionID;

    COMMIT;
END$$

-- 3.3 Delete Transaction procedure with 30-day rule
CREATE PROCEDURE sp_DeleteTransaction(IN p_transactionID INT)
BEGIN
    DECLARE txDate DATETIME;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error deleting transaction';
    END;

    START TRANSACTION;

    SELECT transactionDate INTO txDate FROM `Transaction` WHERE transactionID = p_transactionID;
    IF txDate IS NULL THEN
        ROLLBACK; SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction not found';
    END IF;

    -- only allow delete within 30 days
    IF DATEDIFF(CURDATE(), DATE(txDate)) > 30 THEN
        ROLLBACK; SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete transactions older than 30 days. Set status=Void instead.';
    END IF;

    DELETE FROM `Transaction` WHERE transactionID = p_transactionID;

    COMMIT;
END$$

-- 3.4 Report: Get Transactions By User (WHERE + ORDER BY)
CREATE PROCEDURE sp_GetTransactionsByUser(
    IN p_userID INT,
    IN p_startDate DATE,
    IN p_endDate DATE
)
BEGIN
    SELECT T.transactionID, T.amount, T.type, T.status, T.transactionDate, C.categoryName,
           COALESCE(Ws.walletName, Wd.walletName) AS WalletAffected,
           CASE
             WHEN T.type = 'income' THEN T.amount
             WHEN T.type = 'expense' THEN -T.amount
             WHEN T.type = 'transfer' AND T.sourceWalletID IS NOT NULL AND Ws.userID = p_userID THEN -T.amount
             WHEN T.type = 'transfer' AND T.destinationWalletID IS NOT NULL AND Wd.userID = p_userID THEN T.amount
             ELSE 0
           END AS NetFlowImpact
    FROM `Transaction` T
    LEFT JOIN Wallet Ws ON T.sourceWalletID = Ws.walletID
    LEFT JOIN Wallet Wd ON T.destinationWalletID = Wd.walletID
    LEFT JOIN Category C ON C.categoryID = T.categoryID
    WHERE ( (Ws.userID = p_userID) OR (Wd.userID = p_userID) )
      AND DATE(T.transactionDate) BETWEEN p_startDate AND p_endDate
    ORDER BY T.transactionDate DESC, T.transactionID;
END$$

-- 3.5 Report: Summary Expense By Category (GROUP BY + HAVING)
CREATE PROCEDURE sp_SummaryExpenseByCategory(
    IN p_userID INT,
    IN p_minAmount DECIMAL(18,2)
)
BEGIN
    SELECT C.categoryName, SUM(T.amount) AS totalExpense
    FROM `Transaction` T
    JOIN Category C ON C.categoryID = T.categoryID
    JOIN Wallet W ON T.sourceWalletID = W.walletID
    WHERE W.userID = p_userID
      AND T.type = 'expense'
      AND T.status = 'Completed'
    GROUP BY C.categoryName
    HAVING SUM(T.amount) >= p_minAmount
    ORDER BY totalExpense DESC;
END$$

DELIMITER;

-- -------------------------
-- 4. FUNCTIONS
-- -------------------------
DELIMITER $$

-- 4.1 fn_TotalBalance (uses CURSOR to iterate balances)
CREATE FUNCTION fn_TotalBalance(p_userID INT)
RETURNS DECIMAL(18,2)
DETERMINISTIC
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE w_bal DECIMAL(18,2);
    DECLARE tot DECIMAL(18,2) DEFAULT 0;
    DECLARE cur CURSOR FOR SELECT balance FROM Wallet WHERE userID = p_userID;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO w_bal;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;
        SET tot = tot + IFNULL(w_bal,0);
    END LOOP;
    CLOSE cur;
    RETURN tot;
END$$

-- 4.2 fn_UserMonthlyExpense (IF + LOOP)
CREATE FUNCTION fn_UserMonthlyExpense(p_userID INT, p_month INT, p_year INT)
RETURNS DECIMAL(18,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(18,2) DEFAULT 0;
    DECLARE d INT DEFAULT 1;
    DECLARE daySum DECIMAL(18,2);

    IF p_month < 1 OR p_month > 12 OR p_year < 1900 THEN
        RETURN NULL;
    END IF;

    loop_days: LOOP
        IF d > 31 THEN
            LEAVE loop_days;
        END IF;

        SELECT COALESCE(SUM(T.amount),0) INTO daySum
        FROM `Transaction` T
        JOIN Wallet W ON T.sourceWalletID = W.walletID
        WHERE W.userID = p_userID
          AND T.type = 'expense'
          AND T.status = 'Completed'
          AND DAY(T.transactionDate) = d
          AND MONTH(T.transactionDate) = p_month
          AND YEAR(T.transactionDate) = p_year;

        SET total = total + daySum;
        SET d = d + 1;
    END LOOP;

    RETURN total;
END$$

DELIMITER;