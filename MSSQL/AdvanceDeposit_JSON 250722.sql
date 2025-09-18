DECLARE @report NVARCHAR(MAX); 
DECLARE @reportDate DATE = CAST('07/15/2025' AS DATE);

WITH 

-- 1. Beginning Balance  
BeginningBalance AS (
  SELECT SUM(price) AS amount
  FROM vw_TripInvoiceSummary
  WHERE CASE
    WHEN RsrvtnSrcClean = 'Hotel'           THEN 0
    WHEN REVGRP       LIKE '%Same Day%'    THEN 1
    WHEN trpStatus    = 'p'                THEN 1
    WHEN trpStatus IN ('c','e') THEN 1
    ELSE 0 END = 1
     AND trppckdate <= CAST('07/19/2025' AS DATE)
     AND RsrvtnStatus in ('a','c')

),

-- 2. Pre-Arranged Sales  
PreArrangedSales AS (
  SELECT
    REVGRP = 
      CASE 
        WHEN price / trppssngrs = 25 THEN 'RoundTrip '
        WHEN price / trppssngrs = 28 THEN 'OneWay '
        ELSE '' END
      + REVGRP,
    COUNT(*)        AS transactions,
    SUM(trppssngrs) AS pax,
    SUM(price)      AS totalPrice
  FROM vw_TripInvoiceSummary
  --WHERE trppckdate = CAST(@reportDate AS DATE)
  --  AND RsrvtnSrcClean NOT IN ('Hotel','Same Day Reservations')
  WHERE CASE
    WHEN RsrvtnSrcClean = 'Hotel'           THEN 0
    WHEN REVGRP       LIKE '%Same Day%'    THEN 0
    WHEN trppckdate = CAST('07/19/2025' AS DATE) THEN 1
    ELSE 0 END = 1
  GROUP BY
    CASE 
      WHEN price / trppssngrs = 25 THEN 'RoundTrip '
      WHEN price / trppssngrs = 28 THEN 'OneWay '
      ELSE '' END
    + REVGRP
),

-- 3. Same-Day Service  
SameDayService AS (
  SELECT SUM(price) AS amount
  FROM vw_TripInvoiceSummary
  WHERE REVGRP LIKE '%Same Day%'
    AND trppckdate = CAST(@reportDate AS DATE)
),

-- 4. Advance Deposits  
AdvanceDeposits AS (
  SELECT SUM(price) AS amount
  FROM vw_TripInvoiceSummary
  WHERE RsrvtnSrcClean NOT IN ('Hotel') --,'Same Day Reservations')  Same Day still Deposits into Advanced Deposit
    AND RsrvtnDt = CAST(@reportDate AS DATE)
),

-- 5. Same Day Revenue  
SameDayRevenue AS (
  SELECT
    REVGRP,
    trpStatus,
    price,
    trppssngrs,
    trppckdate
  FROM vw_TripInvoiceSummary
  WHERE REVGRP LIKE '%Same Day%'
    AND trppckdate = CAST('07/19/2025' AS DATE)
),
-- 5. Current Day Revenue  
CurrentDayRevenue AS (
  SELECT
    REVGRP,
    trpStatus,
    price,
    trppssngrs,
    trppckdate
  FROM vw_TripInvoiceSummary
  WHERE trppckdate = CAST('07/19/2025' AS DATE)
--    AND trppckdate = CAST(@reportDate AS DATE)
)

-- Build the full JSON payload in @report
SELECT
  @report = (
    SELECT
      CAST(@reportDate AS DATE)        AS reportDate,
      bb.amount                           AS beginningBalance,
      sds.amount                          AS sameDayService,
      ad.amount                           AS advanceDeposits,

      -- Same‐day detail array
      (
        SELECT
          REVGRP = 
            CASE 
              WHEN price / trppssngrs = 25 THEN 'RoundTrip '
              WHEN price / trppssngrs = 28 THEN 'OneWay '
              ELSE '' END
            + REVGRP,
          trpStatus,
          price,
          trppckdate
        FROM SameDayRevenue
        FOR JSON PATH
      )                                   AS currentDayRevenue,

      -- Pre‐arranged sales array
      (
        SELECT
          REVGRP      AS description,
          transactions,
          pax,
          CONCAT('$ ', FORMAT(totalPrice, 'N2')) AS amount
        FROM PreArrangedSales
        FOR JSON PATH
      )                                   AS preArrangedSales,

      -- Balance‐detail array
      (
        SELECT
          REVGRP = 
            CASE 
              WHEN price / trppssngrs = 25 THEN 'RoundTrip '
              WHEN price / trppssngrs = 28 THEN 'OneWay '
              ELSE '' END
            + REVGRP,
          COUNT(*)       AS transactions,
          SUM(trppssngrs) AS pax,
          SUM(price)     AS totalPrice
        FROM vw_TripInvoiceSummary
        WHERE CASE
            WHEN RsrvtnSrcClean = 'Hotel'           THEN 0
            WHEN REVGRP       LIKE '%Same Day%'    THEN 1
            WHEN trpStatus    = 'p'                THEN 1
            WHEN trpStatus IN ('c','e') AND trppckdate = CAST('07/19/2025' AS DATE) THEN 1
            ELSE 0 END = 1
        GROUP BY
          CASE 
            WHEN price / trppssngrs = 25 THEN 'RoundTrip '
            WHEN price / trppssngrs = 28 THEN 'OneWay '
            ELSE '' END
          + REVGRP
        FOR JSON PATH
      )                                   AS balanceDetail,

      -- Daily revenue transfer array
      (
        SELECT
        RsrvtnSrcClean,
          REVGRP = 
            CASE 
              WHEN price / trppssngrs = 25 THEN 'RoundTrip '
              WHEN price / trppssngrs = 28 THEN 'OneWay '
              ELSE '' END
            + REVGRP,
          COUNT(*)       AS transactions,
          SUM(trppssngrs) AS pax,
          SUM(price)     AS totalPrice
        FROM vw_TripInvoiceSummary
        WHERE CASE
            WHEN RsrvtnSrcClean = 'Hotel'           THEN 0
            WHEN REVGRP       LIKE '%Same Day%'    THEN 1
            WHEN trpStatus    = 'p'                THEN 1
            WHEN trpStatus IN ('c','e')  THEN 1
            ELSE 0 END = 1
            AND trppckdate = CAST('07/19/2025' AS DATE)
        GROUP BY
        RsrvtnSrcClean,
          CASE 
            WHEN price / trppssngrs = 25 THEN 'RoundTrip '
            WHEN price / trppssngrs = 28 THEN 'OneWay '
            ELSE '' END
          + REVGRP
        FOR JSON PATH
      )                                   AS dailyTransfer

    FROM BeginningBalance bb
    CROSS JOIN SameDayService sds
    CROSS JOIN AdvanceDeposits ad

    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
  );

-- Return the JSON under a clean column name
SELECT @report AS reportData;