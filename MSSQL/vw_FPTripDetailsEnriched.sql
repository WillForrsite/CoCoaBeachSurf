/****** Object:  View [dbo].[vw_TripDetailsEnriched]    Script Date: 9/9/2025 3:41:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- 🔹 Business Logic View
-- =============================================
CREATE VIEW [dbo].[vw_FPTripDetailsEnriched] AS
SELECT 
    r.RsrvtnID,
    r.RsrvtnSrc,
    r.RsrvtnStatus,
    cast(r.rsrvtndate as date) as RsrvtnDt,
    r.RsrvtnCstmrID AS trpCstmrID,  -- ✅ needed for customer join
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
                        t.trpPckLctnTpe),
    --rn             = ROW_NUMBER() OVER (
    --                    PARTITION BY r.RsrvtnID
    --                    ORDER BY t.trpPckDate ASC),
    ROW_NUMBER() OVER (
    PARTITION BY r.RsrvtnID
    ORDER BY 
        CASE t.trpStatus
            WHEN 'c' THEN 1
            WHEN 'e' THEN 2
            WHEN 'p' THEN 3
            WHEN 'x' then 4
            ELSE 5
        END,
        t.trpPckDate ASC) AS rn,
    t.*
FROM dbo.tblTrps t
JOIN dbo.vw_FPValidReservations r ON r.RsrvtnID = t.trpRsrvtnID;
GO


