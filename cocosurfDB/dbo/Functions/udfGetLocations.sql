
-- =============================================
-- Author:		Will Henderson
-- Create date: 05/05/2024
-- Description:	Get Ship by Date Function
-- =============================================
-- Select * from udfGetLocations()
CREATE        FUNCTION [dbo].[udfGetLocations](@lctntpe char(2) = null)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT 
			lctn_tpe,
			lctn_nme,
			lctn_dsc,
			lctn_UnqID,
			lctn_address,
			lctn_active,
			lctn_dflt,
			lctn_Id 
	  from 
			tblLctns
	 WHERE
			lctn_tpe = isnull(@lctntpe,lctn_tpe)
)
