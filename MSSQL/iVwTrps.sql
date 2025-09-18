/****** Object:  View [dbo].[iVwTrps]    Script Date: 8/29/2025 7:59:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER   view [dbo].[iVwTrps] as 
select
	0									as trpID,
	''									as trpStatus,
	convert(nvarchar(8),' ')			as trpRsrvtnID,
	Convert(date,'01/01/1971')			as trpPckDate,
	'00:00:00'							as trpPckTm,
	0									as trpPssngrs,
	0									as trpLug,
	convert(money,0.00)					as trpCst,
	convert(nvarchar(2),'')				as trpPckLctnTpe,
	Convert(varchar(24),' ')			as trpPckLctnUnqID,
	Convert(varchar(24),' ')			as trpPckLctnSubUnqID,
	Convert(varchar(12),'')				as trpPckflght, 
	convert(varchar(16),'')				as trpPckLctnTm,
	convert(nvarchar(2),'')				as trpDrpLctnTpe,
	Convert(varchar (24),' ')			as trpDrpLctnUnqID,
	Convert(nchar(10),' ')				as trpDrpLctnSubUnqID,
	Convert(varchar(12),'')				as trpDrpflght, 
	'00:00:00'							as trpDrpLctnTm,
	convert(bit,0)						as trpWC,
	Convert(nchar(10),' ')				as trpWCfld,
	Convert(varchar(256),' ')			as trpAddtnfo,
	--Convert(smalldatetime,'01/01/1971 00:00:00') as trpCrtdDtTm,
    Convert(nvarchar(128),' ')			as trpCrtdBy
	--Convert(smalldatetime,'01/01/1971 00:00:00') as trpUpdt, 
 --   Convert(nvarchar(128),' ')			as trpUpdtBy
	from
	tblDummy4View
GO


