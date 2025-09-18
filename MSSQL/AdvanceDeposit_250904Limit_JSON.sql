DECLARE @ReportDate date      = '2025-09-06';
DECLARE @ReportJson nvarchar(max);

WITH
AllDates AS (
    SELECT DISTINCT CAST(trpPckDate AS date) AS ReportDate
    FROM (select * from vw_TripInvoiceSummary
            where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') as vw_TripInvoiceSummary
    WHERE trpPckDate IS NOT NULL
    UNION
    SELECT DISTINCT CAST(pmtCrtdDtTm AS date)
    FROM tblARpayments
    WHERE pmtCrtdDtTm IS NOT NULL
      and cast(pmtcrtddttm as date) > '2025-09-04'
    UNION
    SELECT @ReportDate
),
TripRevenue AS (
    SELECT 
        ad.ReportDate,
        SUM(ISNULL(vts.price, 0)) AS TripRev
    FROM AllDates ad
    LEFT JOIN (select * from vw_TripInvoiceSummary
            where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') vts
        ON vts.trpPckDate = ad.ReportDate
       AND vts.trpStatus IN ('c','e','p')
    GROUP BY ad.ReportDate
),
TripADRevenue AS (
    SELECT 
        ad.ReportDate,
        SUM(ISNULL(vts.price, 0)) AS TripADRev
    FROM AllDates ad
    LEFT JOIN tblARpayments arp
        ON CAST(arp.pmtCrtdDtTm AS DATE) = ad.ReportDate
    LEFT JOIN (select * from vw_TripInvoiceSummary
            where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') vts
        ON vts.RsrvtnID = arp.pmtinvID
       AND vts.trpStatus IN ('c','e','p')
       AND vts.RsrvtnSrcClean NOT IN ('Hotel')  -- AD rule
       AND cast(arp.pmtcrtddttm as date) > '2025-09-04'
    GROUP BY ad.ReportDate
),
TripADConsumption AS (
    SELECT 
        ad.ReportDate,
        SUM(ISNULL(vts.price, 0)) AS TripADConsumedRev
    FROM AllDates ad
    LEFT JOIN (select * from vw_TripInvoiceSummary
            where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') vts
        ON CAST(vts.trpPckDate AS DATE) = ad.ReportDate
       AND vts.trpStatus IN ('c','e','p')
       AND vts.RsrvtnSrcClean NOT IN ('Hotel')  -- AD rule
    GROUP BY ad.ReportDate
),
DailyDeposits AS (
    SELECT 
        --CAST(pmtCrtdDtTm AS date),*
        CAST(pmtCrtdDtTm AS date) AS ReportDate,
        SUM(pmtAmt) AS DepositAmt
    FROM tblARpayments
    WHERE pmtType IN ('PD','FP')
      and cast(pmtCrtdDtTm as date) > '2025-09-04'
    --order BY CAST(pmtCrtdDtTm AS date)
    GROUP BY CAST(pmtCrtdDtTm AS date)
),
Combined AS (
    SELECT 
        ad.ReportDate,
        ISNULL(tr.TripRev, 0)     AS TripRev,
        ISNULL(trad.TripADRev, 0) AS TripADRev,
        ISNULL(trac.TripADConsumedRev, 0) as TripADRevConsumed,
        ISNULL(dd.DepositAmt, 0)  AS DailyDepositAmt
    FROM AllDates ad
    LEFT JOIN TripRevenue    tr   ON tr.ReportDate   = ad.ReportDate
    LEFT JOIN TripADRevenue  trad ON trad.ReportDate = ad.ReportDate
    LEFT JOIN TripADConsumption trac ON trac.ReportDate = ad.ReportDate
    LEFT JOIN DailyDeposits  dd   ON dd.ReportDate   = ad.ReportDate
),
RunningBalance AS (
    SELECT 
        ReportDate,
        DailyDepositAmt,
        TripRev,
        TripADRev,
        TripADRevConsumed,
        SUM(DailyDepositAmt - TripRev)
            OVER (ORDER BY ReportDate ROWS UNBOUNDED PRECEDING) AS EndingBalance,
        SUM(DailyDepositAmt - TripADRevConsumed)
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
        (SELECT TOP (1) DailyDepositAmt FROM AdvancedDepositTable WHERE ReportDate = @ReportDate),
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
ADEndingBalanceDetail AS (
    SELECT
        vts.RsrvtnID,
        vts.REVGRP,
        vts.trpStatus,
        pmt.pmtAmt,
        vts.price,
        vts.trpPssngrs,
        vts.trpPckDate,
        CAST(pmt.pmtCrtdDtTm AS date) AS pmtDate
    FROM tblARpayments pmt
    LEFT JOIN (select * from vw_TripInvoiceSummary
            where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') vts
        ON pmt.pmtInvID = vts.RsrvtnID
    WHERE vts.RsrvtnSrcClean NOT IN ('Hotel')  -- AD rule
      AND vts.trpStatus IN ('c','p','e')
      AND CAST(pmt.pmtCrtdDtTm AS date) <= @ReportDate
      AND CAST(vts.trpPckDate as date) > @ReportDate
      AND cast(pmt.pmtcrtddttm as date) > '2025-09-04'
),
ADEndingBalanceSummary AS (
select
        REVGRP,
        transactions = COUNT_BIG(*),
        pax          = SUM(ISNULL(trpPssngrs,0)),
        totalPrice   = SUM(ISNULL(price,0))
from
    ADEndingBalanceDetail
group by REVGRP
),
CurrentDayRevenue AS (
    SELECT
        vts.RsrvtnID,
        vts.REVGRP,
        vts.trpStatus,
        pmt.pmtAmt,
        vts.price,
        vts.trpPssngrs,
        vts.trpPckDate,
        CAST(pmt.pmtCrtdDtTm AS date) AS pmtDate
    FROM tblARpayments pmt
    left JOIN (select * from vw_TripInvoiceSummary
            where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') vts
      ON pmt.pmtInvID = vts.RsrvtnID
    WHERE vts.RsrvtnSrcClean NOT IN ('Hotel') -- AD rule
      AND vts.trpStatus IN ('c','p','e')
      AND CAST(pmt.pmtCrtdDtTm AS date) = @ReportDate
      AND CAST(pmt.pmtCrtdDtTm AS date) > '2025-09-04'
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
CDRSummarized AS (
    SELECT
        RsrvtnID,
        -- Calculate total passengers per reservation
        totalPax = SUM(trpPssngrs),
        -- Assuming pmtAmt is already reservation total, pick it once
        price    = SUM(price),
        REVGRP_Base = MAX(REVGRP),       -- If stored in the source
        pmtDate  = MAX(pmtDate)          -- Or MIN if you want earliest payment date
    FROM CurrentDayRevenue
    GROUP BY RsrvtnID
),
CurrentDayRevenueFinal AS (
    SELECT
        REVGRP = CASE
                     WHEN price / NULLIF(totalPax,0) = 25 THEN 'RoundTrip '
                     WHEN price / NULLIF(totalPax,0) = 28 THEN 'OneWay '
                     ELSE 'OneWay '
                 END + REVGRP_Base,
        trpPssngrs = totalPax,
        price,
        trpPckDate = pmtDate
    FROM CDRSummarized

    --UNION ALL

    --SELECT
    --    'No Advanced Deposits', 0, 0, @ReportDate
    --WHERE NOT EXISTS (SELECT 1 FROM CDRSummarized)
),
PreArrangedSales AS (
    SELECT
        REVGRP,
        transactions = COUNT_BIG(*),
        pax          = SUM(ISNULL(trpPssngrs,0)),
        totalPrice   = SUM(ISNULL(price,0))
    FROM CurrentDayRevenueFinal 
    GROUP BY REVGRP
),
CurrentDayCancelFinal AS (
    SELECT
        REVGRP,
        transactions = COUNT_BIG(*),
        pax          = SUM(ISNULL(trpPssngrs,0)),
        totalPrice   = SUM(ISNULL(price,0))    FROM CurrentDayCancel
    WHERE ReportDate = @ReportDate
    GROUP BY REVGRP
    UNION ALL
    SELECT 'No Cancellations or Refunds', 0, 0, 0 -- @ReportDate
    WHERE NOT EXISTS (SELECT 1 FROM CurrentDayCancel)
),
PreArrangedSalesFinal AS (
    SELECT 
        description = REVGRP,
        transactions,
        pax,
        amount = CONCAT('$ ', FORMAT(totalPrice, 'N2'))
    FROM PreArrangedSales
    UNION ALL
    SELECT 'No Pre-Sales', 0, 0, '$ 0.00'
    WHERE NOT EXISTS (SELECT 1 FROM PreArrangedSales)
),
BalanceDetailFinal AS (
    SELECT 
        REVGRP,
        transactions,
        pax,
        totalPrice
    FROM ADEndingBalanceSummary
    UNION ALL
    SELECT 'No Details', 0, 0, '$ 0.00'
    WHERE NOT EXISTS (SELECT 1 FROM ADEndingBalanceSummary)
),
DailyTransferFinal AS (
    SELECT
        REVGRP = CASE 
                    WHEN price / NULLIF(trpPssngrs,0) = 25 THEN 'RoundTrip '
                    WHEN price / NULLIF(trpPssngrs,0) = 28 THEN 'OneWay '
                    ELSE 'OneWay ' 
                 END + REVGRP,
        transactions = COUNT_BIG(*),
        pax          = SUM(ISNULL(trpPssngrs,0)),
        totalPrice   = SUM(ISNULL(price,0))
    FROM (select * from vw_TripInvoiceSummary
            where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') as vw_TripInvoiceSummary
    WHERE RsrvtnSrcClean NOT IN ('Hotel')
      AND trpPckDate = @ReportDate
    GROUP BY CASE 
                WHEN price / NULLIF(trpPssngrs,0) = 25 THEN 'RoundTrip '
                WHEN price / NULLIF(trpPssngrs,0) = 28 THEN 'OneWay '
                ELSE 'OneWay ' 
             END + REVGRP

    UNION ALL

    SELECT 'No Transfers', 0, 0, 0
    WHERE NOT EXISTS (
        SELECT 1
        FROM (select * from vw_TripInvoiceSummary
            where rsrvtndt > '2025-09-04' or RsrvtnSrcClean = 'Hotel') as vw_TripInvoiceSummary
        WHERE RsrvtnSrcClean NOT IN ('Hotel')
          AND trpPckDate = @ReportDate
    )
)
-- Final JSON Output
SELECT @ReportJson = (
  SELECT
    @ReportDate              AS reportDate,
    bb.amount                AS beginningBalance,
    bb.EndingAmt             AS endingBalance,
    bb.ADAmt                 AS advancedDeposit,
    sds.amount               AS sameDayService,
    ad.amount                AS advanceDeposits,

    -- Arrays
    (SELECT * FROM CurrentDayRevenueFinal FOR JSON PATH, INCLUDE_NULL_VALUES) AS currentDayRevenue,
    (SELECT * FROM CurrentDayCancelFinal  FOR JSON PATH, INCLUDE_NULL_VALUES) AS currentDayCancel,
    (SELECT * FROM PreArrangedSalesFinal  FOR JSON PATH, INCLUDE_NULL_VALUES) AS preArrangedSales,
    (SELECT * FROM BalanceDetailFinal     FOR JSON PATH, INCLUDE_NULL_VALUES) AS balanceDetail,
    (SELECT * FROM DailyTransferFinal     FOR JSON PATH, INCLUDE_NULL_VALUES) AS dailyTransfer

  FROM BeginningBalance bb
  CROSS JOIN SameDayService sds
  CROSS JOIN AdvanceDeposits ad
  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
);
-- Return the JSON
SELECT @ReportJson AS reportData;