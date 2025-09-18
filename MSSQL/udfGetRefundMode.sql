CREATE FUNCTION dbo.udfGetRefundMode
(
    @pmtCrtdDt DATETIME
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        CASE 
            WHEN @pmtCrtdDt IS NULL
                THEN 'unknown'
            WHEN CONVERT(DATE, @pmtCrtdDt AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time') =
                 CONVERT(DATE, GETUTCDATE() AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time')
                THEN 'void'
            ELSE 'refund'
        END AS mode
);