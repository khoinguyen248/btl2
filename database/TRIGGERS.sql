USE EERD_Project;
GO

-- =======================================================================================
-- PHẦN 2.2.1: TRIGGER NGHIỆP VỤ
-- Yêu cầu: Kiểm tra Ràng buộc Ngữ nghĩa R2 (Giới hạn 1 Ví cho Free User)
-- =======================================================================================
CREATE OR ALTER TRIGGER trg_LimitFreeUserWallet
ON Wallet
FOR INSERT
AS
BEGIN
    -- Kiểm tra nếu User trong bảng Inserted là FreeUser
    IF EXISTS (
        SELECT 1 
        FROM Inserted i
        JOIN FreeUser f ON i.userID = f.userID
    )
    BEGIN
        -- Đếm số lượng ví hiện có của user đó (bao gồm cả cái vừa định thêm)
        DECLARE @UserID INT;
        SELECT @UserID = userID FROM Inserted;

        IF (SELECT COUNT(*) FROM Wallet WHERE userID = @UserID) > 1
        BEGIN
            RAISERROR(N'Lỗi: Người dùng Free chỉ được phép tạo tối đa 1 Ví!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
    END
END;
GO

-- =======================================================================================
-- PHẦN 2.2.2: TRIGGER DẪN XUẤT
-- Yêu cầu: Tự động tính toán lại Wallet.balance khi bảng Transaction thay đổi
-- Xử lý: INSERT (trừ/cộng tiền mới), DELETE (hoàn tiền cũ), UPDATE (bù trừ)
-- =======================================================================================
CREATE OR ALTER TRIGGER trg_UpdateWalletBalance
ON [Transaction]
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. XỬ LÝ KHI XÓA (DELETE) HOẶC SỬA (UPDATE - phần cũ): Hoàn lại tác động cũ
    -- Nếu là Expense/Transfer (nguồn ra) -> Cộng lại tiền vào Source
    UPDATE w
    SET w.balance = w.balance + d.amount
    FROM Wallet w
    JOIN deleted d ON w.walletID = d.sourceWalletID
    WHERE d.type IN ('expense', 'transfer');

    -- Nếu là Income/Transfer (đích đến) -> Trừ lại tiền khỏi Destination
    UPDATE w
    SET w.balance = w.balance - d.amount
    FROM Wallet w
    JOIN deleted d ON w.walletID = d.destinationWalletID
    WHERE d.type IN ('income', 'transfer');

    -- 2. XỬ LÝ KHI THÊM MỚI (INSERT) HOẶC SỬA (UPDATE - phần mới): Áp dụng tác động mới
    -- Nếu là Expense/Transfer -> Trừ tiền Source
    UPDATE w
    SET w.balance = w.balance - i.amount
    FROM Wallet w
    JOIN inserted i ON w.walletID = i.sourceWalletID
    WHERE i.type IN ('expense', 'transfer');

    -- Nếu là Income/Transfer -> Cộng tiền Destination
    UPDATE w
    SET w.balance = w.balance + i.amount
    FROM Wallet w
    JOIN inserted i ON w.walletID = i.destinationWalletID
    WHERE i.type IN ('income', 'transfer');
END;
GO

-- =======================================================================================
-- PHẦN 2.1: PROCEDURES CRUD (Thêm, Sửa, Xóa) cho bảng TRANSACTION
-- Yêu cầu: Kiểm tra ràng buộc ngữ nghĩa (Số dư, Nguồn != Đích)
-- =======================================================================================

-- 1. Thủ tục THÊM Giao dịch (INSERT)
CREATE OR ALTER PROCEDURE sp_InsertTransaction
    @Amount DECIMAL(18, 2),
    @Description NVARCHAR(500),
    @Type NVARCHAR(20), -- 'income', 'expense', 'transfer'
    @SourceWalletID INT = NULL,
    @DestinationWalletID INT = NULL,
    @CategoryID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Kiểm tra 1: Ràng buộc Nguồn != Đích (R5)
        IF @SourceWalletID IS NOT NULL AND @DestinationWalletID IS NOT NULL AND @SourceWalletID = @DestinationWalletID
        BEGIN
            RAISERROR(N'Lỗi: Ví nguồn và ví đích không được trùng nhau.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Kiểm tra 2: Nếu là Expense/Transfer, ví nguồn phải đủ số dư
        IF @Type IN ('expense', 'transfer')
        BEGIN
            DECLARE @CurrentBalance DECIMAL(18,2);
            SELECT @CurrentBalance = balance FROM Wallet WHERE walletID = @SourceWalletID;

            IF @CurrentBalance < @Amount
            BEGIN
                RAISERROR(N'Lỗi: Số dư ví không đủ để thực hiện giao dịch.', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END

        -- Kiểm tra 3: Logic loại giao dịch và tham số ví
        IF @Type = 'expense' AND @SourceWalletID IS NULL
        BEGIN
             RAISERROR(N'Lỗi: Giao dịch chi tiêu phải có Ví nguồn.', 16, 1);
             ROLLBACK TRANSACTION; RETURN;
        END
        IF @Type = 'income' AND @DestinationWalletID IS NULL
        BEGIN
             RAISERROR(N'Lỗi: Giao dịch thu nhập phải có Ví đích.', 16, 1);
             ROLLBACK TRANSACTION; RETURN;
        END

        -- Thực hiện Insert (Trigger 2.2.2 sẽ tự động chạy để cập nhật số dư)
        INSERT INTO [Transaction] (amount, description, transactionDate, type, status, sourceWalletID, destinationWalletID, categoryID)
        VALUES (@Amount, @Description, GETDATE(), @Type, 'completed', @SourceWalletID, @DestinationWalletID, @CategoryID);

        COMMIT TRANSACTION;
        PRINT N'Thêm giao dịch thành công!';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- 2. Thủ tục CẬP NHẬT Giao dịch (UPDATE)
CREATE OR ALTER PROCEDURE sp_UpdateTransaction
    @TransactionID INT,
    @NewAmount DECIMAL(18, 2),
    @NewDescription NVARCHAR(500),
    @NewCategoryID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Lấy thông tin cũ
        DECLARE @OldAmount DECIMAL(18,2);
        DECLARE @Type NVARCHAR(20);
        DECLARE @SourceWalletID INT;
        
        SELECT @OldAmount = amount, @Type = type, @SourceWalletID = sourceWalletID 
        FROM [Transaction] WHERE transactionID = @TransactionID;

        IF @OldAmount IS NULL
        BEGIN
            RAISERROR(N'Lỗi: Giao dịch không tồn tại.', 16, 1);
            ROLLBACK TRANSACTION; RETURN;
        END

        -- Kiểm tra số dư mới (Nếu là Expense/Transfer và số tiền tăng lên)
        -- Logic: (Số dư hiện tại + Tiền cũ hoàn lại) phải >= Tiền mới
        IF @Type IN ('expense', 'transfer')
        BEGIN
            DECLARE @CurrentBalance DECIMAL(18,2);
            SELECT @CurrentBalance = balance FROM Wallet WHERE walletID = @SourceWalletID;

            IF (@CurrentBalance + @OldAmount) < @NewAmount
            BEGIN
                RAISERROR(N'Lỗi: Số dư không đủ để cập nhật số tiền mới.', 16, 1);
                ROLLBACK TRANSACTION; RETURN;
            END
        END

        -- Thực hiện Update (Trigger 2.2.2 sẽ tự động tính lại tiền)
        UPDATE [Transaction]
        SET amount = @NewAmount,
            description = @NewDescription,
            categoryID = @NewCategoryID
        WHERE transactionID = @TransactionID;

        COMMIT TRANSACTION;
        PRINT N'Cập nhật giao dịch thành công!';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

-- 3. Thủ tục XÓA Giao dịch (DELETE)
CREATE OR ALTER PROCEDURE sp_DeleteTransaction
    @TransactionID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM [Transaction] WHERE transactionID = @TransactionID)
        BEGIN
            RAISERROR(N'Lỗi: Giao dịch không tồn tại.', 16, 1);
            ROLLBACK TRANSACTION; RETURN;
        END

        -- Chỉ cần xóa, Trigger 2.2.2 sẽ hoàn tiền lại ví
        DELETE FROM [Transaction] WHERE transactionID = @TransactionID;

        COMMIT TRANSACTION;
        PRINT N'Xóa giao dịch thành công! Số dư đã được hoàn lại (nếu có).';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO