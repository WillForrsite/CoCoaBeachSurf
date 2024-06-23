-- =============================================
-- Author:		Will Henderson
-- Create date: 05/05/2024
-- Description:	Get Ship by Date Function
-- =============================================
-- Select * from udfGetCstmrs()
Create         FUNCTION [dbo].[udfGetCstmrs]()
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT [CstmrID]
      ,[CstmrFN]
      ,[CstmrLN]
      ,[CstmrEml]
      ,[CstmrPhn1]
      ,[CstmrPhn2]
      ,[CstmrCrtdDt]
      ,[CstmrCrtdBy]
      ,[CstmrActv]
  FROM [dbo].[tblCstmrs]
)
