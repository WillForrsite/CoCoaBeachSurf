DECLARE @report NVARCHAR(MAX);
DECLARE @reportDate DATE = '2025-07-24'; -- Example date

-- Define AdvancedDeposit
WITH AdvancedDeposit AS (
  SELECT
    SUM(p.pmtAmt) AS amount
  FROM tblARpayments p
  WHERE CAST(p.pmtCrtdDtTm AS DATE) = @reportDate
),

-- Define DirectSales
DirectSales AS (
SELECT SUM(price) AS amount
  FROM vw_TripInvoiceSummary
  WHERE trpStatus IN ('c','e','p') AND trppckdate = @reportDate
  and RsrvtnSrcClean = 'Hotel'
),

-- Define NoShowRevenue
NoShowRevenue AS (
  SELECT
    RsrvtnSrcClean,
    REVGRP = 
      CASE
        WHEN trpStatus = 'e' then 'No Show '
        else '' end +
      CASE 
        WHEN price / trppssngrs = 25 THEN 'RoundTrip '
        WHEN price / trppssngrs = 28 THEN 'OneWay '
        ELSE '' END
      + REVGRP,
    COUNT(*) AS transactions,
    SUM(trppssngrs) AS pax,
    SUM(price) AS totalPrice
  FROM vw_TripInvoiceSummary
  WHERE trppckdate = @reportDate
    and RsrvtnSrcClean = 'Direct'
    and trpStatus = 'e'
  GROUP BY
      RsrvtnSrcClean,
      CASE
        WHEN trpStatus = 'e' then 'No Show '
        else '' end +
      CASE 
        WHEN price / trppssngrs = 25 THEN 'RoundTrip '
        WHEN price / trppssngrs = 28 THEN 'OneWay '
        ELSE '' END
      + REVGRP
),

-- Define HotelSales
HotelSales AS (
  SELECT
  concat(RsrvtnSrcClean,' ',PckupType) as RevSrc ,
    REVGRP = concat(lctn_Display_Name,' -',
      CASE
        WHEN trpStatus = 'e' then ' No Show '
        else '' end,
      CASE 
        WHEN price / trppssngrs = 25 THEN 'RoundTrip '
        WHEN price / trppssngrs = 28 THEN 'OneWay '
        ELSE '' END, ' Shuttle ',
       PckupType),
    COUNT(*) AS transactions,
    SUM(trppssngrs) AS pax,
    SUM(price) AS totalPrice
  FROM vw_TripInvoiceSummary
  WHERE trppckdate = @reportDate
    and RsrvtnSrcClean = 'Hotel'
--    and trpStatus = 'c'
  GROUP BY
    concat(RsrvtnSrcClean,' ',PckupType),
concat(lctn_Display_Name,' -',
      CASE
        WHEN trpStatus = 'e' then ' No Show '
        else '' end,
      CASE 
        WHEN price / trppssngrs = 25 THEN 'RoundTrip '
        WHEN price / trppssngrs = 28 THEN 'OneWay '
        ELSE '' END, ' Shuttle ',
       PckupType)
),

-- Define PreArrangedSales
PreArrangedSales AS (
  SELECT
    RsrvtnSrcClean,
    REVGRP = 
      CASE
        WHEN trpStatus = 'e' then 'No Show '
        else '' end +
      CASE 
        WHEN price / trppssngrs = 25 THEN 'RoundTrip '
        WHEN price / trppssngrs = 28 THEN 'OneWay '
        ELSE '' END
      + REVGRP,
    COUNT(*) AS transactions,
    SUM(trppssngrs) AS pax,
    SUM(price) AS totalPrice
  FROM vw_TripInvoiceSummary
  WHERE trppckdate = @reportDate
    and RsrvtnSrcClean = 'Direct'
    and trpStatus = 'c'
  GROUP BY
      RsrvtnSrcClean,
      CASE
        WHEN trpStatus = 'e' then 'No Show '
        else '' end +
      CASE 
        WHEN price / trppssngrs = 25 THEN 'RoundTrip '
        WHEN price / trppssngrs = 28 THEN 'OneWay '
        ELSE '' END
      + REVGRP
)

-- Final JSON Assembly
SELECT @report = (
  SELECT
    @reportDate AS reportDate,

    -- Top-level values
    ISNULL(bb.amount, 0) AS AdvancedDeposit,
    ISNULL(sds.amount, 0) AS DirectSales,

    -- NoShowRevenue
    ISNULL(nsr_json.[JSON], nsr_fallback.[JSON]) AS NoShowRevenue,

    -- HotelSales
    ISNULL(hs_json.[JSON], hs_fallback.[JSON]) AS HotelSales,

    -- PreArrangedSales
    ISNULL(pas_json.[JSON], pas_fallback.[JSON]) AS preArrangedSales

  FROM AdvancedDeposit bb
  CROSS JOIN DirectSales sds

  -- NoShowRevenue JSON
  OUTER APPLY (
    SELECT [JSON] = (
      SELECT
        RsrvtnSrcClean,
        REVGRP,
        ISNULL(transactions, 0) AS transactions,
        ISNULL(pax, 0) AS pax,
        ISNULL(totalPrice, 0) AS totalPrice
      FROM NoShowRevenue
      FOR JSON PATH, INCLUDE_NULL_VALUES
    )
  ) AS nsr_json

  OUTER APPLY (
    SELECT [JSON] = (
      SELECT
        RsrvtnSrcClean = NULL,
        REVGRP = NULL,
        transactions = 0,
        pax = 0,
        totalPrice = 0
      FOR JSON PATH, INCLUDE_NULL_VALUES
    )
  ) AS nsr_fallback

  OUTER APPLY (
    SELECT dummyCheck = 1
    WHERE NOT EXISTS (SELECT 1 FROM NoShowRevenue)
  ) AS nsr_condition

  -- HotelSales JSON
  OUTER APPLY (
    SELECT [JSON] = (
      SELECT
        RevSrc,
        REVGRP,
        ISNULL(transactions, 0) AS transactions,
        ISNULL(pax, 0) AS pax,
        ISNULL(totalPrice, 0) AS totalPrice
      FROM HotelSales
      FOR JSON PATH, INCLUDE_NULL_VALUES
    )
  ) AS hs_json

  OUTER APPLY (
    SELECT [JSON] = (
      SELECT
        RevSrc = NULL,
        REVGRP = NULL,
        transactions = 0,
        pax = 0,
        totalPrice = 0
      FOR JSON PATH, INCLUDE_NULL_VALUES
    )
  ) AS hs_fallback

  OUTER APPLY (
    SELECT dummyCheck = 1
    WHERE NOT EXISTS (SELECT 1 FROM HotelSales)
  ) AS hs_condition

  -- PreArrangedSales JSON
  OUTER APPLY (
    SELECT [JSON] = (
      SELECT
        REVGRP AS description,
        ISNULL(transactions, 0) AS transactions,
        ISNULL(pax, 0) AS pax,
        CONCAT('$ ', FORMAT(ISNULL(totalPrice, 0), 'N2')) AS amount
      FROM PreArrangedSales
      FOR JSON PATH, INCLUDE_NULL_VALUES
    )
  ) AS pas_json

  OUTER APPLY (
    SELECT [JSON] = (
      SELECT
        description = NULL,
        transactions = 0,
        pax = 0,
        amount = '$ 0.00'
      FOR JSON PATH, INCLUDE_NULL_VALUES
    )
  ) AS pas_fallback

  OUTER APPLY (
    SELECT dummyCheck = 1
    WHERE NOT EXISTS (SELECT 1 FROM PreArrangedSales)
  ) AS pas_condition

  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
);

-- Output the JSON
SELECT @report AS FinalJson;