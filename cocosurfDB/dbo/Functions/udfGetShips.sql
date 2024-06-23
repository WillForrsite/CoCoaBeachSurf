 CREATE     FUNCTION [dbo].[udfGetShips]()
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT distinct ship as ShipName from vwShips
	
)