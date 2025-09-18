/****** Object:  View [dbo].[iVwARinvoice]    Script Date: 8/29/2025 7:55:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[iVwARinvoice]
AS
SELECT   CONVERT(varchar(8), '') AS invID, CONVERT(varchar(20), '') AS invNbr, CONVERT(varchar(2), '') AS invType, CONVERT(varchar(50), '') AS invCstmID, CONVERT(varchar(1000), '') AS invRefDoc, CONVERT(varchar(6), '') AS invPrcMtx, CONVERT(money, 0) AS invAmt, CONVERT(smallint, 0) AS invStatus, CONVERT(smalldatetime, '') AS invCrtdDtTm, 
             CONVERT(nvarchar(128), '') AS invCrtdBy, CONVERT(smalldatetime, '') AS invUpdt, CONVERT(nvarchar(128), '') AS invUpdtBy, CONVERT(smalldatetime, '') AS invClsDt, CONVERT(VARCHAR(MAX), '') AS invNotes
FROM     dbo.tblDummy4View
GO


