-- =============================================
-- Author:		Will Henderson
-- Create date: 05/05/2024
-- Description:	Get Ship by Date Function
-- =============================================
-- Select * from udfGetHotels()
CREATE   FUNCTION [dbo].[udfGetHotels]()
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT htl_id, htl_nme, htl_srt_ordr from tblHotels where htl_isactive = 1
)
