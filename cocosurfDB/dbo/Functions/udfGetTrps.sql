-- =============================================
-- Author:		Michael Waldhelm
-- Create date: 06/11/2024
-- Description:	Get Trip by Reservation ID
-- =============================================
-- Select * from udGetTrps(123456,)
CREATE     FUNCTION [dbo].[udfGetTrps]
(
	@RSVRTNID nvarchar(128) = null
	,@ID int NULL
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT [trpID]
      ,[trpRsrvtnID]
      ,[trpPckDate]
      ,[trpPckTm]
      ,[trpPssngrs]
      ,[trpCst]
      ,[trpPckLctnTpe]
      ,[trpPckLctnUnqID]
      ,[trpPckLctnSubUnqID]
      ,[trpPckLctnTm]
      ,[trpDrpLctnTpe]
      ,[trpDrpLctnUnqID]
      ,[trpDrpLctnSubUnqID]
      ,[trpDrpLctnTm]
      ,[trpWC]
      ,[trpWCfld]
      ,[trpAddtnfo]
      ,[trpCrtdDtTm]
      ,[trpCrtdBy]
      ,[trpUpdt]
      ,[trpUpdtBy]
  FROM [dbo].[vwTrps]
  where [trpRsrvtnID] = ISNULL(@RSVRTNID,[trpRsrvtnID])
	AND [trpID] =ISNULL(@ID,[trpID])
)
