/****** Object:  View [dbo].[iVwARpayments]    Script Date: 8/29/2025 7:56:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER      view [dbo].[iVwARpayments] as
select
		CONVERT(nvarchar(8),'')  [pmtID],
		CONVERT(nvarchar(20),'')   [pmtinvID],
		convert(nvarchar(16),'')   [pmtChkNo],
		CONVERT(nvarchar(2),'')   [pmtType],
		CONVERT(nvarchar(1000),'')  [pmtRefDoc],
		CONVERT(money,0)  [pmtAmt],
		CONVERT(smalldatetime,'')  [pmtCrtdDtTm],
		CONVERT(nvarchar(128),'')  [pmtCrtdBy],
		CONVERT(smalldatetime,'')  [pmtUpdt],
		CONVERT(nvarchar(128),'')  [pmtUpdtBy],
		convert(varchar(max),'') [pmtNotes]
	from
	tblDummy4View
GO


