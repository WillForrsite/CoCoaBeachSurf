CREATE SEQUENCE dbo.Seq_ARInvoiceID
    AS int
    START WITH 25000231  -- Adjust based on your current max ID
    INCREMENT BY 1;
CREATE SEQUENCE dbo.Seq_ARPaymentID
    AS int
    START WITH 25000052  -- Adjust based on your current max ID
    INCREMENT BY 1;
GO
SELECT name, current_value, start_value, increment
FROM sys.sequences;
select * from sys.sequences