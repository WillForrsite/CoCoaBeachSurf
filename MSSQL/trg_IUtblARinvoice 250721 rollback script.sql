-- 1. Drop the updated trigger
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_IUtblARinvoice')
BEGIN
    DROP TRIGGER [dbo].[trg_IUtblARinvoice];
    PRINT 'Trigger [trg_IUtblARinvoice] dropped.';
END

-- 2. Drop the sequence used for invID generation
IF EXISTS (SELECT * FROM sys.sequences WHERE name = 'Seq_ARInvoiceID')
BEGIN
    DROP SEQUENCE dbo.Seq_ARInvoiceID;
    PRINT 'Sequence [Seq_ARInvoiceID] dropped.';
END

-- 3. Recreate the original trigger
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[trg_IUtblARinvoice]
ON [dbo].[iVwARinvoice]
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    UPDATE a 
    SET invStatus = '0'
    FROM tblARinvoice a
    WHERE invStatus = 2
      AND CAST(invCrtdDtTm AS date) <> CAST(DATEADD(HOUR, -5, GETUTCDATE()) AS date); 

    DECLARE @invNbr VARCHAR(20)

    SET @invNbr = ISNULL((
        SELECT a.invNbr 
        FROM tblARinvoice a
        JOIN inserted i ON i.invNbr = a.invNbr AND a.invType = i.invType
        WHERE a.invStatus = 2
    ), '')

    IF @invNbr <> ''
    BEGIN
        UPDATE r
        SET
            r.invAmt = CASE 
                          WHEN i.invStatus = 2 THEN i.invAmt + r.invAmt
                          ELSE i.invAmt 
                      END,
            r.invStatus = CASE 
                              WHEN i.invType = 'DM' THEN 0
                              ELSE i.invStatus 
                          END,
            r.invRefDoc = CASE
                              WHEN i.invStatus = 2 THEN i.invRefDoc + ',' + r.invRefDoc
                              ELSE i.invRefDoc 
                          END,
            r.invUpdt = GETUTCDATE(),
            r.invUpdtBy = CASE 
                              WHEN i.invStatus = 2 THEN i.invCrtdBy
                              ELSE i.invUpdtBy 
                          END,
            r.invClsDt = i.invClsDt
        FROM dbo.tblARinvoice r
        JOIN inserted i ON i.invID = r.invID
    END
    ELSE
    BEGIN
        DECLARE @invID VARCHAR(8)

        UPDATE tblARSqnc
        SET Invinc = Invinc + 1
        WHERE InvYr = RIGHT(CAST(YEAR(GETUTCDATE()) AS CHAR(4)), 2)

        SET @invID = (
            SELECT InvYr + RIGHT('000000' + CAST(Invinc AS VARCHAR(6)), 6)
            FROM tblARSqnc  
            WHERE InvYr = RIGHT(CAST(YEAR(GETUTCDATE()) AS CHAR(4)), 2)
        )

        INSERT INTO [dbo].[tblARinvoice] (
            [invID], [invNbr], [invType], [invCstmID], [invRefDoc], [invPrcMtx],
            [invAmt], [invStatus], [invCrtdDtTm], [invCrtdBy]
        )
        SELECT
            @invID,
            i.invNbr,
            i.invType,
            CASE 
                WHEN i.invStatus = 2 THEN i.invCstmID
                ELSE CAST(r.RsrvtnCstmrID AS VARCHAR(50)) 
            END,
            CASE
                WHEN i.invCrtdBy = 'Web' THEN 
                    RIGHT(CAST(FORMAT(t.trpPckDate, 'yy') AS VARCHAR), 2) +
                    RIGHT('000' + CAST(DATEPART(DAYOFYEAR, t.trpPckDate) AS VARCHAR), 3) + 
                    r.RsrvtnSrc +
                    CAST(t.trpPckLctnTpe AS VARCHAR) + 
                    CAST(t.trpDrpLctnTpe AS VARCHAR)
                ELSE ISNULL(i.invRefDoc, '') 
            END,
            ISNULL(i.invPrcMtx, ''),
            CASE
                WHEN i.invCrtdBy = 'Web' THEN p.pmtAmt
                ELSE i.invAmt 
            END,
            CASE
                WHEN i.invCrtdBy = 'Web' THEN 1
                WHEN i.invType = 'DM' THEN 0
                ELSE ISNULL(i.invStatus, 0) 
            END,
            GETUTCDATE(),
            i.invCrtdBy
        FROM inserted i
        JOIN tblRsvrtns r ON r.RsrvtnID = i.invRefDoc
        LEFT JOIN tblRsvrtnPmt p ON p.pmtRsrvtnID = i.invRefDoc
        JOIN tblTrps t ON t.trpRsrvtnID = r.RsrvtnID
        WHERE t.trpID = 1
    END

    IF (SELECT invCrtdBy FROM INSERTED) = 'Web'
    BEGIN
        INSERT INTO [dbo].[iVwARpayments] (
            [pmtinvID], [pmtType], [pmtRefDoc], [pmtAmt], [pmtCrtdBy]
        )
        SELECT 
            i.invNbr,
            'FP',
            p.pmtRequestID,
            p.pmtAmt,
            i.invCrtdBy
        FROM inserted i
        JOIN tblRsvrtnPmt p ON p.pmtRsrvtnID = i.invRefDoc
    END
END
GO
