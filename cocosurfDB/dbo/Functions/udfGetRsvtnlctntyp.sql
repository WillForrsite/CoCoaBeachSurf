-- =============================================
-- Author:		Will Henderson
-- Create date: 05/05/2024
-- Description:	Get Ship by Date Function
-- =============================================
-- Select * from udfGetLocationTypes()
CREATE       FUNCTION [dbo].[udfGetRsvtnlctntyp]()
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT 
			lctn_tpe,
			lctn_tpe_dsc,
			lctn_tpe_active,
			lctn_tpe_Id 
	  from 
			tbllctnTpe  
	 where 
			lctn_tpe in ('AP','CL','H','P') 
			--('AP','H') 
			--('AP','CL','H','P')
)
