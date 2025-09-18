/****** Object:  View [dbo].[iVwGstInf]    Script Date: 9/18/2025 3:57:53 AM ******/
-- 250918: Will Henderson  increased phone field sizes to 24 from 16
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[iVwGstInf]
AS
-- Changed 250106 Will Henderson Expanded Phone fields to Varchar(16)
SELECT CONVERT(nvarchar(50), '') AS Gst_fnme, CONVERT(nvarchar(50), '') AS Gst_lnme, CONVERT(nvarchar(128), '') AS Gst_eml, CONVERT(nvarchar(128), '') AS Gst_eml2, CONVERT(nvarchar(24), '') AS Gst_cphn1, CONVERT(nvarchar(24), '') 
                  AS Gst_cphn2, CONVERT(nvarchar(16), '') AS rsrvtn_id, CONVERT(nvarchar(128), '') AS Gst_user
FROM     dbo.tblDummy4View
GO


