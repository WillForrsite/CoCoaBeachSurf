DECLARE @report NVARCHAR(MAX);
DECLARE @reportDate DATE = CAST('07/15/2025' AS DATE);

WITH 
AdvancedDeposit AS (
  SELECT SUM(price) AS amount
  FROM vw_TripInvoiceSummary
  WHERE trpStatus IN ('c','e','p') AND trppckdate = @reportDate
  and RsrvtnSrcClean <> 'Hotel'
),
DirectSales AS (
  SELECT SUM(price) AS amount
  FROM vw_TripInvoiceSummary
  WHERE trpStatus IN ('c','e','p') AND trppckdate = @reportDate
  and RsrvtnSrcClean = 'Hotel'
),
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

),
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
)
-- Final JSON payload
SELECT @report = (
  SELECT
    @reportDate AS reportDate,
    bb.amount AS AdvancedDeposit,
    sds.amount AS DirectSales,
    (
      SELECT
            *
        FROM NoShowRevenue
      FOR JSON PATH
    ) AS NoShowRevenue,
    (
      SELECT
            *
        FROM HotelSales
      FOR JSON PATH
    ) AS HotelSales,
    -- Pre-Arranged Sales
    (
      SELECT
        REVGRP AS description,
        transactions,
        pax,
        CONCAT('$ ', FORMAT(totalPrice, 'N2')) AS amount
      FROM PreArrangedSales
      FOR JSON PATH
    ) AS preArrangedSales

 FROM AdvancedDeposit bb
  CROSS JOIN DirectSales sds
  --CROSS JOIN AdvanceDeposits ad
  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
);

-- Return JSON
SELECT @report AS reportData;