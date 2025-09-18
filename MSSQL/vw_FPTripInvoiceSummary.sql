/****** Object:  View [dbo].[vw_TripInvoiceSummary]    Script Date: 9/9/2025 4:18:05 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- 🔹 Presentation View
-- =============================================

CREATE Or ALTER VIEW [dbo].[vw_FPTripInvoiceSummary] AS
SELECT 
    e.*,
    Customer           = c.CstmrLNFN,
    lctn_Display_Name  = ISNULL(l.lctn_Display_Name, c.CstmrLNFN),
    tinvno             = 
        RIGHT(CAST(FORMAT(e.trpPckDate, 'yy') AS VARCHAR),2) +
        RIGHT('000' + CAST(DATEPART(DAYOFYEAR, e.trpPckDate) AS VARCHAR), 3) + 
        e.RsrvtnSrc + 
        CAST(e.trpPckLctnTpe AS VARCHAR) + 
        CAST(e.trpDrpLctnTpe AS VARCHAR),
    Category           = e.PckupType + ' to ' + e.DrpType,
    price              = dbo.udf_CalculateTripPrice(e.RsrvtnSrcClean, e.trpPssngrs, e.trpStatus ,e.trpCst)
FROM dbo.vw_FPTripDetailsEnriched e
LEFT JOIN dbo.tblCstmrs c ON c.CstmrID = e.trpCstmrID
LEFT JOIN dbo.tblLctns l ON l.lctn_UnqID = e.RsrvtnSrc
WHERE 
    CASE 
        WHEN e.RsrvtnSrcClean = 'direct' THEN 1
        WHEN e.RsrvtnSrcClean = 'Hotel' AND e.rn = 1 THEN 1
        ELSE 0
    END = 1;
GO