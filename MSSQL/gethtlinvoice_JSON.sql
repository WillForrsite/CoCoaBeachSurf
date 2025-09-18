DECLARE @ReportJson nvarchar(max);
with
AllCstmrs as(
    select 
        lctn_UnqID,
        lctn_Display_Name,
        lctn_address
    from 
            tblLctns
    Where lctn_tpe = 'H'
      and lctn_Display_Name is not null
),
balanceInvoices as (  --- These are used as the Hotel Statment Headers
select 
        lctn_UnqID as RsrvtnSrc,
        lctn_Display_Name as [lctn_Display_Name],
        lctn_address as lctn_address,
        Sum(isnull(invAmt,0)) Balance
  from 
        AllCstmrs tl 
LEFT JOIN
         tblARinvoice ar on ar.invCstmID = tl.lctn_UnqID
and InvJulDate is not null and invStatusDesc = 'OPEN'
group by lctn_UnqID, lctn_Display_Name, lctn_address
),
firstInv AS (
    SELECT
        inv.invNbr,
        LEFT(inv.invRefDoc, 
             CHARINDEX(',', inv.invRefDoc + ',') - 1) AS firstRsrvtnID
    FROM tblARinvoice inv
    WHERE invJulDate is not null
),
summaryInvoices as ( --- These are used as Hotel Invoices
    SELECT 
            ar.invAmt as Balance,
            ar.invCstmID as RsrvtnSrc,
            b.lctn_Display_Name,
            ar.invNbr,
            ar.InvJulDate as trpPckDate,
            ar.invStatusDesc as [Status],
            ar.invRefDoc,
            b.lctn_address,
            concat(dbo.udfGetLctnType(vts.trpPckLctnTpe),' to ',dbo.udfGetLctnType(vts.trpDrpLctnTpe),' Shuttle Service') as [description]
      FROM
            tblARinvoice ar
      JOIN  
            firstInv fi on fi.invNbr = ar.invNbr
                       and  InvJulDate is not null 
                       and  invStatusDesc = 'OPEN'
 LEFT JOIN
            vw_TripInvoiceSummary vts on vts.RsrvtnID = fi.firstRsrvtnID
      JOIN  balanceInvoices b on b.RsrvtnSrc = ar.invCstmID
),
summaryPayments as (
    SELECT
            pmt.pmtID,
            pmt.pmtChkNo,
            pmt.pmtAmt,
            pmt.pmtRefDoc,
            pmt.pmtNotes
      FROM
            tblARpayments pmt
      JOIN
            summaryInvoices si on si.invNbr = pmt.pmtinvID
),
latestInvoices as (
    SELECT
            ar.invNbr,
            ar.invJulDate,
            ar.invStatusDesc,
            t.Customer,
            t.RsrvtnSrc,
            --l.lctn_Display_Name,
            t.price,
            t.trpPckDate,
            t.trpPckTm,
            t.trpStatus,
            t.trpPssngrs
            --c.CstmrLNFN as 'Customer',
            --ROW_NUMBER() OVER (
            --    PARTITION BY r.RsrvtnID 
            --    ORDER BY t.trpPckDate ASC
            --) AS rn
      FROM
            tblARinvoice ar
      CROSS APPLY STRING_SPLIT(ar.invRefDoc, ',') AS split
  LEFT JOIN
             vw_TripInvoiceSummary t on t.RsrvtnID = split.value
      WHERE ar.InvJulDate is not null
)
SELECT @ReportJson = (
SELECT
    (SELECT * FROM balanceInvoices FOR JSON PATH, INCLUDE_NULL_VALUES) AS balanceInvoices,
    (SELECT * FROM summaryInvoices FOR JSON PATH, INCLUDE_NULL_VALUES) AS summaryInvoices,
    (SELECT * FROM latestInvoices  FOR JSON PATH, INCLUDE_NULL_VALUES) AS latestInvoices
    FOR JSON PATH, INCLUDE_NULL_VALUES
)
-- Return the JSON
SELECT @ReportJson AS InvoiceData;