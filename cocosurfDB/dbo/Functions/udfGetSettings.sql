 CREATE       FUNCTION [dbo].[udfGetSettings]
	(
 	@property nvarchar(64) = null
	)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT 
		[property],
		[value],
		[date_last_updated]
	from vwSettings
	where property = isnull(@property,property)
	
)
