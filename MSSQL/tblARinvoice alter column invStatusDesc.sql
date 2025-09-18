-- Step 1: Drop the existing computed column
IF EXISTS (
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID('dbo.tblARInvoice')
      AND name = 'invStatusDesc'
)
BEGIN
    ALTER TABLE dbo.tblARInvoice
    DROP COLUMN invStatusDesc;
END

-- Step 2: Add the computed column with updated logic
ALTER TABLE dbo.tblARInvoice
ADD invStatusDesc AS (
    CASE [invStatus]
        WHEN 0 THEN 'Open'
        WHEN 1 THEN 'Paid'
        WHEN 2 THEN 'In Process'
        WHEN 9 THEN 'Void'
        ELSE 'In Dispute'
    END
);