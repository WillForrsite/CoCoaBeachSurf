-- =============================================
-- Author:		Will Henderson
-- Create date: 05/05/2024
-- Description:	Get Ship by Date Function
-- =============================================
-- Select * from udfGetCstmrByEml('r@gmail.com')
Create     FUNCTION [dbo].[udfGetCstmrByEml]
(
	@Email nvarchar(128) = null
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT CstmrID,CstmrFN,CstmrLN,CstmrPhn1,CstmrPhn2,CstmrFllNme,CstmrLNFN from tblCstmrs where CstmrEml = @Email
)
