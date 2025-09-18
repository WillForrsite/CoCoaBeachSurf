DECLARE @ReportDate date      = '2025-09-07';
DECLARE @ReportJson nvarchar(max);

WITH
AllDates AS (
    SELECT DISTINCT CAST(trpPckDate AS date) AS ReportDate
    FROM (select * from vw_TripInvoiceSummary
            where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') as vw_TripInvoiceSummary
    WHERE trpPckDate IS NOT NULL
      --or (rsrvtndt > '2025-09-04' and RsrvtnSrcClean = 'Direct')
      --or (RsrvtnSrcClean = 'hotel')
    UNION
    SELECT DISTINCT CAST(pmtCrtdDtTm AS date)
    FROM tblARpayments
    WHERE pmtCrtdDtTm IS NOT NULL
      and pmtcrtddttm > '2025-09-04'
    UNION
    SELECT DISTINCT CAST(invCrtdDtTm AS date)
    FROM tblARinvoice
    WHERE invCrtdDtTm IS NOT NULL
      and invCrtdDtTm > '2025-09-04'
    UNION
    SELECT @ReportDate
),
JulianDirectSales AS (
    -- Gold copy logic from earlier
    SELECT
        ar.invNbr,
        ar.invAmt,
        LEFT(ar.invNbr, 5) AS julianCode,

        -- Safe Julian conversion using TRY_CAST
        CASE 
            WHEN TRY_CAST(LEFT(ar.invNbr, 5) AS INT) IS NOT NULL THEN
                DATEADD(DAY, TRY_CAST(SUBSTRING(ar.invNbr, 3, 3) AS INT) - 1,
                        DATEFROMPARTS(2000 + TRY_CAST(SUBSTRING(ar.invNbr, 1, 2) AS INT), 1, 1))
            ELSE NULL
        END AS matchDate
    FROM dbo.tblARinvoice ar
    WHERE TRY_CAST(LEFT(ar.invNbr, 5) AS INT) IS NOT NULL
),
DirectSales AS (
    SELECT
        ad.reportDate,
        sum(isnull(jds.invAmt,0)) AS amount
    FROM AllDates ad
    LEFT JOIN JulianDirectSales jds
        ON ad.reportDate = jds.matchDate
    GROUP BY ad.ReportDate
    -- other joins and logic...
),
TripRevenue AS (
    SELECT 
        ad.ReportDate,
        SUM(ISNULL(vts.price, 0)) AS TripRev
    FROM AllDates ad
    LEFT JOIN (select * from vw_TripInvoiceSummary
where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') vts --vw_TripInvoiceSummary vts
        ON vts.trpPckDate = ad.ReportDate
       AND vts.trpStatus IN ('c','e','p')
       --and ((rsrvtndt > '2025-09-04' and RsrvtnSrcClean = 'Direct')
       -- or (RsrvtnSrcClean = 'hotel'))
    GROUP BY ad.ReportDate
),
TripADRevenue AS (
    SELECT 
        ad.ReportDate,
        SUM(ISNULL(vts.price, 0)) AS TripADRev
    FROM AllDates ad
    LEFT JOIN (select * from vw_TripInvoiceSummary
where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') vts --vw_TripInvoiceSummary vts
        ON vts.trpPckDate = ad.ReportDate
       AND vts.trpStatus IN ('c','e','p')
       AND vts.RsrvtnSrcClean NOT IN ('Hotel') -- AD rule
       --((rsrvtndt > '2025-09-04' and RsrvtnSrcClean = 'Direct')
       -- or (RsrvtnSrcClean = 'hotel'))
    GROUP BY ad.ReportDate
),
TripADConsumption AS (
    SELECT 
        ad.ReportDate, 
        SUM(ISNULL(vts.price, 0)) AS TripADConsumedRev
    FROM AllDates ad
    LEFT JOIN vw_FPTripInvoiceSummary vts
        ON CAST(vts.trpPckDate AS DATE) = ad.ReportDate
       --AND vts.trpStatus IN ('c','e','p')
       AND vts.RsrvtnSrcClean NOT IN ('Hotel')  -- AD rule
--    WHERE ad.ReportDate = @ReportDate
    GROUP BY ad.ReportDate
),
DailyDeposits AS (
    SELECT 
        CAST(pmtCrtdDtTm AS date) AS ReportDate,
        SUM(pmtAmt) AS DepositAmt
    FROM tblARpayments
    WHERE pmtType IN ('PD','FP')
      --and pmtCrtdDtTm > '2025-09-05'
    GROUP BY CAST(pmtCrtdDtTm AS date)
),
Combined AS (
    SELECT 
        ad.ReportDate,
        ISNULL(tr.TripRev, 0)     AS TripRev,
        ISNULL(trad.TripADConsumedRev, 0) AS TripADRev,
        ISNULL(dd.DepositAmt, 0)  AS DailyDepositAmt
    FROM AllDates ad
    LEFT JOIN TripRevenue    tr   ON tr.ReportDate   = ad.ReportDate
    LEFT JOIN TripADConsumption  trad ON trad.ReportDate = ad.ReportDate
    LEFT JOIN DailyDeposits  dd   ON dd.ReportDate   = ad.ReportDate
),
RunningBalance AS (
    SELECT 
        ReportDate,
        DailyDepositAmt,
        TripRev,
        TripADRev,
        SUM(DailyDepositAmt - TripRev)
            OVER (ORDER BY ReportDate ROWS UNBOUNDED PRECEDING) AS EndingBalance,
        SUM(DailyDepositAmt - TripADRev)
            OVER (ORDER BY ReportDate ROWS UNBOUNDED PRECEDING) AS ADEndingBalance
    FROM Combined
),
AdvancedDepositTable AS (
    SELECT
        ReportDate,
        LAG(EndingBalance,     1, 0) OVER (ORDER BY ReportDate) AS BeginningBalance,
        LAG(ADEndingBalance,   1, 0) OVER (ORDER BY ReportDate) AS ADBeginningBalance,
        DailyDepositAmt,
        TripRev,
        TripADRev,
        EndingBalance,
        ADEndingBalance
    FROM RunningBalance
),
BeginningBalance AS (
    SELECT amount = COALESCE(
        (SELECT TOP (1) ADBeginningBalance AS BeginningBalance FROM AdvancedDepositTable WHERE ReportDate = @ReportDate),
        0.0
    ),
    EndingAmt = COALESCE(
        (SELECT TOP (1) ADEndingBalance AS EndingBalance FROM AdvancedDepositTable WHERE ReportDate = @ReportDate),
        0.0
    ),
    ADAmt = COALESCE(
        (SELECT TOP (1) TripADRev FROM AdvancedDepositTable WHERE ReportDate = @ReportDate),
        0.0
    ),
    DSAmt = COALESCE(
        (SELECT TOP (1) amount FROM DirectSales WHERE ReportDate = @ReportDate),
        0.0
    )
),
AdvanceDeposits AS (
    SELECT amount = COALESCE(
        (SELECT TOP (1) DailyDepositAmt FROM AdvancedDepositTable WHERE ReportDate = @ReportDate),
        0.0
    )
),
SameDayService AS (
    SELECT amount = ISNULL(SUM(price), 0.0)
    FROM (select * from vw_TripInvoiceSummary
where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') as vw_TripInvoiceSummary
    WHERE REVGRP LIKE '%Same Day%'
      AND trpPckDate = @ReportDate
),
CurrentDayRevenue AS (
    SELECT
        vts.RsrvtnID,
        REVGRP = concat(
                  CASE
                    WHEN trpStatus = 'e' then ' No Show '
                    else '' end,
                  CASE 
                    WHEN price / trppssngrs = 25 THEN 'RoundTrip'
                    WHEN price / trppssngrs = 28 THEN 'OneWay'
                    ELSE 'OneWay' END, ' Shuttle ',
                   PckupType),
        vts.trpStatus,
        vts.price,
        vts.trpPssngrs,
        ad.ReportDate
    FROM AllDates ad
    left JOIN (select * from vw_TripInvoiceSummary
where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') vts --vw_TripInvoiceSummary vts 
      ON vts.trpPckDate = ad.ReportDate
     AND vts.RsrvtnSrcClean NOT IN ('Hotel') -- AD rule
     AND vts.trpStatus IN ('c','p','e')
   WHERE
         ad.ReportDate = @ReportDate
),
HotelDayRevenue AS (
SELECT
    ad.ReportDate,
    vts.RsrvtnID,
    ar.invrefdoc,
    'HotelDayRevenue' AS RowSource,
    CONCAT(vts.RsrvtnSrcClean, ' ', vts.PckupType) AS RevSrc,
    CONCAT(
        vts.lctn_Display_Name, ' - ',
        CASE WHEN vts.trpStatus = 'e' THEN 'No Show ' ELSE '' END,
        CASE 
            WHEN TRY_CAST(vts.price AS float) / NULLIF(vts.trpPssngrs, 0) = 25 THEN 'RoundTrip '
            WHEN TRY_CAST(vts.price AS float) / NULLIF(vts.trpPssngrs, 0) = 28 THEN 'OneWay '
            ELSE 'OneWay '
        END,
        ' Shuttle ',
        vts.PckupType
    ) AS REVGRP,
    vts.trpStatus,
    vts.price,
    ar.invJulDate,
    ar.invAmt,
    vts.trpPssngrs,
    vts.trpPckDate,
    vts.RsrvtnSrcClean,
    split.*
FROM AllDates ad
LEFT JOIN tblARInvoice ar
    ON ar.InvJulDate = ad.ReportDate
CROSS APPLY STRING_SPLIT(ar.invRefDoc, ',') AS split
LEFT JOIN (select * from vw_TripInvoiceSummary
where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') vts
    ON vts.trpRsrvtnID = split.value
  --and vts.RsrvtnSrcClean = 'Hotel'
  --AND vts.trpStatus = 'c'
  where ad.ReportDate = @ReportDate
),
CurrentDayCancel AS (
    SELECT
        RsrvtnID = isnull(RsrvtnID,''),
        REVGRP = isnull(REVGRP,''),
        trpStatus = isnull(trpStatus,''),
        --trpStatus,
        price = isnull(price,0),
        trpPssngrs = isnull(trpPssngrs,0),
        ad.ReportDate
    FROM AllDates ad
    left join (select * from vw_TripInvoiceSummary
where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') vts on vts.trpPckDate = ad.ReportDate
    WHERE RsrvtnSrcClean NOT IN ('Hotel') -- AD rule
      AND trpStatus = 'x'
      AND trpPckDate = @ReportDate
),
CDRSummarized AS
(
    SELECT
        RsrvtnID,
        -- Calculate total passengers per reservation
        trpStatus = MAX(trpStatus),
        totalPax = SUM(trpPssngrs),
        -- Assuming pmtAmt is already reservation total, pick it once
        price    = SUM(price),
        REVGRP_Base = MAX(REVGRP)       -- If stored in the source
    FROM CurrentDayRevenue
    GROUP BY RsrvtnID
),
CurrentDayRevenueFinal AS (
    SELECT
        description = concat(CASE 
                    WHEN price / NULLIF(trpPssngrs,0) = 25 THEN 'RoundTrip '
                    WHEN price / NULLIF(trpPssngrs,0) = 28 THEN 'OneWay '
                    ELSE 'OneWay ' 
                 END,REVGRP,
                 case
                 when REVGRP like '%same day%' then concat(' ',PckupType)
                 else ''
                 end),
        transactions = COUNT_BIG(distinct RsrvtnID),
        pax          = SUM(ISNULL(trpPssngrs,0)),
        amount   = SUM(ISNULL(price,0))
    FROM vw_FPTripInvoiceSummary
    WHERE RsrvtnSrcClean NOT IN ('Hotel')
      AND trpStatus <> 'e'
      AND trpPckDate = @ReportDate
      --AND trpPckDate = @ReportDate
    GROUP BY concat(CASE 
                    WHEN price / NULLIF(trpPssngrs,0) = 25 THEN 'RoundTrip '
                    WHEN price / NULLIF(trpPssngrs,0) = 28 THEN 'OneWay '
                    ELSE 'OneWay ' 
                 END,REVGRP,
                 case
                 when REVGRP like '%same day%' then concat(' ',PckupType)
                 else ''
                 end)
--SELECT
--    description = 
--        CASE WHEN trpStatus = 'e' THEN 'No Show ' ELSE '' END + ISNULL(REVGRP_Base, 'Unknown'),
--    transactions = COUNT_BIG(*),
--    pax          = SUM(ISNULL(totalPax, 0)),
--    amount       = SUM(ISNULL(price, 0))
--FROM CDRSummarized 
--WHERE trpStatus <> 'e'
--GROUP BY CASE WHEN trpStatus = 'e' THEN 'No Show ' ELSE '' END + ISNULL(REVGRP_Base, 'Unknown')

UNION ALL

SELECT
    'No Revenue',
    0,
    0,
    0
WHERE NOT EXISTS (SELECT 1 FROM CDRSummarized WHERE trpStatus <> 'e')
),
NoShowRevenue AS (
    SELECT
        REVGRP = concat(CASE 
                    WHEN price / NULLIF(trpPssngrs,0) = 25 THEN 'RoundTrip '
                    WHEN price / NULLIF(trpPssngrs,0) = 28 THEN 'OneWay '
                    ELSE 'OneWay ' 
                 END,REVGRP,
                 case
                 when REVGRP like '%same day%' then concat(' ',PckupType)
                 else ''
                 end),
        transactions = COUNT_BIG(distinct RsrvtnID),
        pax          = SUM(ISNULL(trpPssngrs,0)),
        totalPrice   = SUM(ISNULL(price,0))
    FROM vw_FPTripInvoiceSummary
    WHERE RsrvtnSrcClean NOT IN ('Hotel')
      AND trpStatus = 'e'
      AND trpPckDate = @ReportDate
      --AND trpPckDate = @ReportDate
    GROUP BY concat(CASE 
                    WHEN price / NULLIF(trpPssngrs,0) = 25 THEN 'RoundTrip '
                    WHEN price / NULLIF(trpPssngrs,0) = 28 THEN 'OneWay '
                    ELSE 'OneWay ' 
                 END,REVGRP,
                 case
                 when REVGRP like '%same day%' then concat(' ',PckupType)
                 else ''
                 end)
    --SELECT
    --    --REVGRP = 
    --    --    CASE
    --    --    WHEN trpStatus = 'e' then 'No Show '
    --    --    else '' end + REVGRP_Base,
    --    REVGRP = REVGRP_Base,
    --    transactions = COUNT_BIG(distinct RsrvtnID),
    --    pax          = SUM(ISNULL(totalPax,0)),
    --    totalPrice   = SUM(ISNULL(price,0))
    --FROM CDRSummarized 
    --where trpStatus = 'e'
    --GROUP BY REVGRP_Base --CASE WHEN trpStatus = 'e' then 'No Show ' else '' end + REVGRP_Base
),
CurrentDayCancelFinal AS (
    SELECT
        REVGRP,
        transactions = COUNT_BIG(distinct RsrvtnID),
        pax          = SUM(ISNULL(trpPssngrs,0)),
        totalPrice   = SUM(ISNULL(price,0))    FROM CurrentDayCancel
    WHERE ReportDate = @ReportDate
    GROUP BY REVGRP
    UNION ALL
    SELECT 'No Cancellations or Refunds', 0, 0, 0 -- @ReportDate
    WHERE NOT EXISTS (SELECT 1 FROM CurrentDayCancel)
),
HotelSalesFinal AS (
    SELECT
        RevSrc,
        REVGRP,
        transactions = COUNT_BIG(distinct RsrvtnID),
        pax          = SUM(ISNULL(trpPssngrs,0)),
        totalPrice   = SUM(ISNULL(price,0))    
    FROM HotelDayRevenue
    GROUP BY RevSrc, REVGRP
    UNION ALL
    SELECT 'No Hotel Revenue', 'No Hotel Revenue', 0, 0, 0 -- @ReportDate
    WHERE NOT EXISTS (SELECT 1 FROM HotelDayRevenue)
),
NoShowRevenueFinal AS (
    SELECT 
        REVGRP,
        transactions,
        pax,
        amount = totalPrice --CONCAT('$ ', FORMAT(totalPrice, 'N2'))
    FROM NoShowRevenue
    UNION ALL
    SELECT 'No Revenue', 0, 0, '$ 0.00'
    WHERE NOT EXISTS (SELECT 1 FROM NoShowRevenue)
)
-- Final JSON Output
SELECT @ReportJson = (
  SELECT
    @ReportDate              AS reportDate,
    --bb.amount                AS beginningBalance,
    --bb.EndingAmt             AS endingBalance,
    bb.ADAmt                 AS AdvancedDeposit,
    bb.DSAmt                 AS DirectSales,
    --sds.amount               AS sameDayService,
    --ad.amount                AS advanceDeposits,

    -- Arrays
    (SELECT * FROM CurrentDayRevenueFinal FOR JSON PATH, INCLUDE_NULL_VALUES) AS currentDayRevenue,
    --(SELECT * FROM CurrentDayCancelFinal  FOR JSON PATH, INCLUDE_NULL_VALUES) AS currentDayCancel,
    --(SELECT * FROM PreArrangedSalesFinal  FOR JSON PATH, INCLUDE_NULL_VALUES) AS preArrangedSales,
    (SELECT * FROM NoShowRevenueFinal     FOR JSON PATH, INCLUDE_NULL_VALUES) AS NoShowRevenue,
    (SELECT * FROM HotelSalesFinal        FOR JSON PATH, INCLUDE_NULL_VALUES) AS HotelSales
    --(SELECT * FROM BalanceDetailFinal     FOR JSON PATH, INCLUDE_NULL_VALUES) AS balanceDetail,
    --(SELECT * FROM DailyTransferFinal     FOR JSON PATH, INCLUDE_NULL_VALUES) AS dailyTransfer

  FROM BeginningBalance bb
  CROSS JOIN SameDayService sds
  CROSS JOIN AdvanceDeposits ad
  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
);
-- Return the JSON
SELECT @ReportJson AS reportData;