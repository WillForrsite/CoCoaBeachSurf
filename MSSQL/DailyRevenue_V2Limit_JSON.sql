/*
Daily Revenue Report Logic
-- Programmer:Will Henderson
-- Date Created:2025-07-17
-- 2025-09-16 Updated JulianDirectSales Query to use invARinvoice Table and removed calculation logic for both
              performance and simplification.
-- 2025-09-16 Added Refunds to Payments section
*/
DECLARE @ReportDate date      = '2025-09-16';
DECLARE @ReportJson nvarchar(max);

WITH
AllDates AS (
    SELECT DISTINCT CAST(trpPckDate AS date) AS ReportDate
    FROM vw_FPTripInvoiceSummary
    WHERE trpPckDate IS NOT NULL
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
        invJulDate AS matchDate
    FROM dbo.tblARinvoice ar
    WHERE invJulDate IS NOT NULL
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
BeginningBalance AS (
    SELECT amount = COALESCE(
        (SELECT TOP (1) ADBeginningBalance AS BeginningBalance FROM vw_FPADRunningBalance WHERE ReportDate = @ReportDate),
        0.0
    ),
    EndingAmt = COALESCE(
        (SELECT TOP (1) ADEndingBalance AS EndingBalance FROM vw_FPADRunningBalance WHERE ReportDate = @ReportDate),
        0.0
    ),
    ADAmt = COALESCE(
        (SELECT TOP (1) TripADRev FROM vw_FPADRunningBalance WHERE ReportDate = @ReportDate),
        0.0
    ),
    DSAmt = COALESCE(
        (SELECT TOP (1) amount FROM DirectSales WHERE ReportDate = @ReportDate),
        0.0
    ),
    Refunds = COALESCE(
        (SELECT sum(pmtAmt) FROM tblARPayments 
        where cast(pmtCrtdDtTm AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' as Date) = @ReportDate
          and pmtType = 'RF'),
        0.0
    )
),
AdvanceDeposits AS (
    SELECT amount = COALESCE(
        (SELECT TOP (1) DailyDepositAmt FROM vw_FPADRunningBalance WHERE ReportDate = @ReportDate),
        0.0
    )
),
SameDayService AS (
    SELECT amount = ISNULL(SUM(price), 0.0)
    FROM vw_FPTripInvoiceSummary
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
    left JOIN vw_FPTripInvoiceSummary vts 
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
LEFT JOIN vw_FPTripInvoiceSummary vts
    ON vts.trpRsrvtnID = split.value
  --and vts.RsrvtnSrcClean = 'Hotel'
  --AND vts.trpStatus = 'c'
  where ad.ReportDate = @ReportDate
),
CDRSummarized AS (
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
    bb.Refunds               AS Refunds,
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