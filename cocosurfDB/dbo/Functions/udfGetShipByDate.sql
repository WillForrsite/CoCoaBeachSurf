-- =============================================
-- Author:		Will Henderson
-- Create date: 05/05/2024
-- Description:	Get Ship by Date Function
-- =============================================
-- Select * from udfGetShipByDate('04-01-2024')
CREATE   FUNCTION udfGetShipByDate
(	
	-- Add the parameters for the function here
	@CrsDate date
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT ship from COCOABeach_Schedule where [Date] = @CrsDate
)
