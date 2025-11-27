USE EERD_Project;
GO

CREATE OR ALTER PROCEDURE sp_GetTransactionsByWalletAndDate
    @WalletID INT = NULL,
    @FromDate DATE = NULL,
    @ToDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        t.transactionID,
        t.amount,
        t.description,
        t.transactionDate,
        t.type,
        t.status,
        w.walletID,
        w.walletName,
        c.categoryID,
        c.categoryName
    FROM [Transaction] t
    JOIN Wallet w 
         ON t.sourceWalletID = w.walletID 
         OR t.destinationWalletID = w.walletID
    JOIN Category c 
         ON t.categoryID = c.categoryID
    WHERE
        (@WalletID IS NULL OR w.walletID = @WalletID)
        AND (@FromDate IS NULL OR CAST(t.transactionDate AS DATE) >= @FromDate)
        AND (@ToDate   IS NULL OR CAST(t.transactionDate AS DATE) <= @ToDate)
    ORDER BY t.transactionDate DESC;
END;
GO
