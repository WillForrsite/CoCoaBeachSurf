/****** Object:  View [dbo].[vw_FPADRunningBalance]    Script Date: 9/16/2025 8:51:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER view [dbo].[vw_FPADRunningBalance] as
-- Materialize filtered trip summary once
WITH 
AllDates AS (
    SELECT DISTINCT CAST(trpPckDate AS DATE) AS ReportDate
    FROM vw_FPTripInvoiceSummary
    WHERE trpPckDate IS NOT NULL

    UNION

    SELECT DISTINCT CAST(pmtCrtdDtTm AS DATE)
    FROM tblARpayments
    WHERE pmtCrtdDtTm > '2025-09-04'

    UNION

    SELECT DISTINCT CAST(invCrtdDtTm AS DATE)
    FROM tblARinvoice
    WHERE invCrtdDtTm > '2025-09-04'
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
        ad.ReportDate,
        SUM(ISNULL(jds.invAmt, 0)) AS amount
    FROM AllDates ad
    LEFT JOIN JulianDirectSales jds ON ad.ReportDate = jds.matchDate
    GROUP BY ad.ReportDate
),
TripRevenue AS (
    SELECT 
        ad.ReportDate,
        SUM(ISNULL(vts.price, 0)) AS TripRev
    FROM AllDates ad
    LEFT JOIN vw_FPTripInvoiceSummary vts ON vts.trpPckDate = ad.ReportDate
        AND vts.trpStatus IN ('c', 'e', 'p')
    GROUP BY ad.ReportDate
),
TripADRevenue AS (
    SELECT 
        ad.ReportDate,
        SUM(ISNULL(vts.price, 0)) AS TripADRev
    FROM AllDates ad
    LEFT JOIN vw_FPTripInvoiceSummary vts ON vts.trpPckDate = ad.ReportDate
        AND vts.trpStatus IN ('c', 'e', 'p')
        AND vts.RsrvtnSrcClean NOT IN ('Hotel')
    GROUP BY ad.ReportDate
),
TripADConsumption AS (
    SELECT 
        ad.ReportDate, 
        SUM(ISNULL(vts.price, 0)) AS TripADConsumedRev
    FROM AllDates ad
    LEFT JOIN vw_FPTripInvoiceSummary vts ON CAST(vts.trpPckDate AS DATE) = ad.ReportDate
        AND vts.RsrvtnSrcClean NOT IN ('Hotel')
    GROUP BY ad.ReportDate
),
DailyDeposits AS (
    SELECT 
        CAST(pmtCrtdDtTm AS DATE) AS ReportDate,
        SUM(pmtAmt) AS DepositAmt,
        sum(case 
            when cast(pmtCrtdDtTm as date) > '2025-09-04' then pmtAmt
            else 0
             end) AS FPDepositAmt
    FROM tblARpayments
    WHERE pmtType IN ('PD', 'FP')
    GROUP BY CAST(pmtCrtdDtTm AS DATE)
),
Combined AS (
    SELECT 
        ad.ReportDate,
        ISNULL(tr.TripRev, 0) AS TripRev,
        ISNULL(trad.TripADConsumedRev, 0) AS TripADRev,
        ISNULL(dd.DepositAmt, 0) AS DailyDepositAmt,
        ISNULL(dd.FPDepositAmt,0) as FPDailyDepositAmt
    FROM AllDates ad
    LEFT JOIN TripRevenue tr ON tr.ReportDate = ad.ReportDate
    LEFT JOIN TripADConsumption trad ON trad.ReportDate = ad.ReportDate
    LEFT JOIN DailyDeposits dd ON dd.ReportDate = ad.ReportDate
),
RunningBalance AS (
    SELECT 
        ReportDate,
        DailyDepositAmt,
        TripRev,
        FPDailyDepositAmt,
        TripADRev,
        SUM(DailyDepositAmt - TripRev) OVER (ORDER BY ReportDate ROWS UNBOUNDED PRECEDING) AS EndingBalance,
        SUM(FPDailyDepositAmt - TripADRev) OVER (ORDER BY ReportDate ROWS UNBOUNDED PRECEDING) AS ADEndingBalance
    FROM Combined
)
SELECT
    ReportDate,
    LAG(EndingBalance, 1, 0) OVER (ORDER BY ReportDate) AS BeginningBalance,
    DailyDepositAmt,
    TripRev,
    EndingBalance,
    LAG(ADEndingBalance, 1, 0) OVER (ORDER BY ReportDate) AS ADBeginningBalance,
    FPDailyDepositAmt,
    TripADRev,
    ADEndingBalance
FROM RunningBalance;
GO


