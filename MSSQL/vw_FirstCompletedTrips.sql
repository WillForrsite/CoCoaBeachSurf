/****** Object:  View [dbo].[vw_FirstCompletedTrips]    Script Date: 8/19/2025 9:58:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   VIEW [dbo].[vw_FirstCompletedTrips] AS
SELECT *,
    Category      = PckupType + ' to ' + DrpType,
    PckupLctn     = PckupType,
    DrpLctn       = DrpType
FROM (
    SELECT 
        RsrvtnSrcClean = ISNULL(dbo.udfGetRsrvtnSrc(r.RsrvtnSrc), 'Direct'),
        PckupType      = dbo.udfGetLctnType(t.trpPckLctnTpe),
        DrpType        = dbo.udfGetLctnType(t.trpDrpLctnTpe),
        SameDay        = CASE 
                           WHEN ISNULL(dbo.udfGetRsrvtnSrc(r.RsrvtnSrc), 'Direct') = 'Direct' 
                                AND CAST(r.RsrvtnDateTm AS DATE) = CAST(t.trpPckDate AS DATE) THEN 1 
                           ELSE 0 
                        END,
        REVGRP         = dbo.udf_GetRevGroup(
                            ISNULL(dbo.udfGetRsrvtnSrc(r.RsrvtnSrc), 'Direct'),
                            CAST(r.RsrvtnDateTm AS DATE),
                            CAST(t.trpPckDate AS DATE),
                            t.trpStatus,
                            t.trpPckLctnTpe
                        ),
        RsrvtnType     = ISNULL(dbo.udfGetRsrvtnSrc(r.RsrvtnSrc), 'Direct'),
        r.RsrvtnSrc,
        cast(r.RsrvtnDateTm as Date) as RsrvtnDt,
        lctn_Display_Name = ISNULL(l.lctn_Display_Name, c.CstmrLNFN),
        lctn_dsc       = ISNULL(l.lctn_dsc, c.CstmrLNFN),
        l.lctn_address,
        Customer       = c.CstmrLNFN,
        tinvno         = 
            RIGHT(CAST(FORMAT(t.trpPckDate, 'yy') AS VARCHAR),2) +
            RIGHT('000' + CAST(DATEPART(DAYOFYEAR, t.trpPckDate) AS VARCHAR), 3) + 
            r.RsrvtnSrc + 
            CAST(t.trpPckLctnTpe AS VARCHAR) + 
            CAST(t.trpDrpLctnTpe AS VARCHAR),
        ROW_NUMBER() OVER (PARTITION BY r.RsrvtnID
                               ORDER BY 
                                        CASE t.trpStatus
                                            WHEN 'c' THEN 1
                                            WHEN 'e' THEN 2
                                            WHEN 'p' THEN 3
                                            ELSE 4
                                        END,
                                        t.trpPckDate ASC
) AS rn,
        t.*
    FROM 
        tblTrps t
        JOIN tblRsvrtns r ON r.RsrvtnID = t.trpRsrvtnID
        LEFT JOIN tblLctns l ON l.lctn_UnqID = r.RsrvtnSrc
        LEFT JOIN tblCstmrs c ON c.CstmrID = r.RsrvtnCstmrID
    WHERE 
--        t.trpStatus IN ('c', 'e')
--        AND 
        r.RsrvtnStatus IN ('a', 'c')
) AS TripCore

GO


