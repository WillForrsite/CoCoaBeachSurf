DECLARE @ReportDate date      = '2025-09-16';
DECLARE @ReportJson nvarchar(max);

SELECT 
       [pmtRsrvtnID]
      ,[pmtTrnKey]
      ,[pmtCardName]
      ,[pmtAttributes]
      ,[pmtDt]
      ,[pmtFPAmt]
      ,[pmtTrnDesc]
      ,[pmtStatus]
      ,[pmtStatusDesc]
      ,pmtCrtdDt AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' as pmtCrtdDt 
      ,pmtModDt AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' as pmtModDt 
      ,[pmtAmt]
      ,[pmtDecision]
      ,[pmtAuthCode]
      ,[pmtPRMessage]
      ,[pmtReasonCode]
      ,[pmtRequestID]
      ,[pmtxWorkflowID]
      ,[pmtTransactionID]
  FROM [dbo].[tblRsvrtnPmt]
 where  pmtTransactionID is not null
        and cast(isnull(pmtModDt,pmtCrtdDt) AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' as date) = @ReportDate