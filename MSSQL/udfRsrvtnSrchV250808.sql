CREATE OR ALTER FUNCTION [dbo].[udfRsrvtnSrchV250808]
(
    @SrchPrm NVARCHAR(24) = NULL,
    @SrchVal NVARCHAR(128) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 25
)
RETURNS TABLE
AS
RETURN
(
    WITH CleanInput AS (
        SELECT 
            SrchPrm = ISNULL(@SrchPrm, '*'),
            SrchVal = ISNULL(@SrchVal, '*'),
            CleanPhone = TRY_CAST(dbo.UDFRemoveNonNumeric(@SrchVal) AS BIGINT),
            SoundVal = SOUNDEX(@SrchVal)
    ),
    BaseResults AS (
        SELECT 
            c.CstmrFllNme AS FullName,
            c.CstmrEml AS Email,
            c.CstmrPhn1 AS Phone,
            r.RsrvtnID AS RsrvtnCode,
            r.RsrvtnSrc,
            r.RsrvtnStatus,
            CONVERT(VARCHAR(10), r.RsrvtnDateTm, 101) AS [Date],
            CONCAT('$', r.RsrvtnTot) AS Cost,
            Srchvrtxt = ISNULL(l.lctn_dsc, ''),
            Stshvrtxt = ISNULL(r.RsrvtnStatusDsc, ''),
            RelevanceScore = 
                CASE WHEN @SrchVal = '*' THEN 0
                     WHEN r.RsrvtnID = @SrchVal THEN 100
                     WHEN r.RsrvtnID LIKE '%' + @SrchVal + '%' THEN 80
                     WHEN DIFFERENCE(r.RsrvtnID, @SrchVal) >= 3 THEN 60
                     WHEN c.CstmrEml = @SrchVal THEN 100
                     WHEN c.CstmrEml LIKE '%' + @SrchVal + '%' THEN 80
                     WHEN DIFFERENCE(c.CstmrEml, @SrchVal) >= 3 THEN 60
                     WHEN c.CstmrFllNme LIKE '%' + @SrchVal + '%' THEN 80
                     WHEN DIFFERENCE(c.CstmrFllNme, @SrchVal) >= 3 THEN 60
                     ELSE 10 END
        FROM 
            tblRsvrtns r
        INNER JOIN 
            tblCstmrs c ON c.CstmrID = r.RsrvtnCstmrID
        LEFT JOIN 
            tblLctns l ON l.lctn_UnqID = r.RsrvtnSrc
        CROSS APPLY 
            CleanInput ci
        WHERE
            (
                ci.SrchPrm = '*' OR
                (
                    ci.SrchPrm = 'RsrvtnID' AND (
                        ci.SrchVal = '*' OR
                        r.RsrvtnID = ci.SrchVal OR
                        r.RsrvtnID LIKE '%' + ci.SrchVal + '%' OR
                        DIFFERENCE(r.RsrvtnID, ci.SrchVal) >= 3
                    )
                )
                OR (
                    ci.SrchPrm = 'Gst_eml' AND (
                        ci.SrchVal = '*' OR
                        c.CstmrEml = ci.SrchVal OR
                        c.CstmrEml LIKE '%' + ci.SrchVal + '%' OR
                        DIFFERENCE(c.CstmrEml, ci.SrchVal) >= 3
                    )
                )
                OR (
                    ci.SrchPrm = 'Gst_Phone' AND (
                        ci.SrchVal = '*' OR
                        c.CstmrNumPh1 = ci.CleanPhone OR
                        c.CstmrNumPh1 LIKE '%' + CAST(ci.CleanPhone AS VARCHAR)
                    )
                )
                OR (
                    ci.SrchPrm = 'Gst_Name' AND (
                        ci.SrchVal = '*' OR
                        c.CstmrFllNme LIKE '%' + ci.SrchVal + '%' OR
                        DIFFERENCE(c.CstmrFllNme, ci.SrchVal) >= 3
                    )
                )
                OR (
                    ci.SrchPrm = 'RsrvtnSrc' AND (
                        ci.SrchVal = '*' OR
                        r.RsrvtnSrc = ci.SrchVal OR
                        r.RsrvtnSrc LIKE '%' + ci.SrchVal + '%' OR
                        ISNULL(l.lctn_dsc, '') LIKE '%' + ci.SrchVal + '%'
                    )
                )
                OR (
                    ci.SrchPrm = 'RsrvtnSts' AND (
                        ci.SrchVal = '*' OR
                        r.RsrvtnStatus = ci.SrchVal OR
                        r.RsrvtnStatus LIKE '%' + ci.SrchVal + '%' OR
                        ISNULL(r.RsrvtnStatusDsc, '') LIKE '%' + ci.SrchVal + '%'
                    )
                )
            )
    )
    SELECT *
    FROM BaseResults
    ORDER BY RelevanceScore DESC, [Date] DESC
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY
)