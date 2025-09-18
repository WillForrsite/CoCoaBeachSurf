/****** Object:  View [dbo].[Manifest]    Script Date: 9/10/2025 10:50:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   view [dbo].[Manifest] as
select 
		 R.RsrvtnID
		,t.trpID
        ,t.trpStatus
		,trppckdate as 'Pickup Date'
		,RIGHT(CONVERT(VARCHAR(20), trppcktm, 100), 7) AS 'Pickup Time'
		,trppcktm as 'Sort Time'
		,c.CstmrLNFN as 'Customer'
		,c.CstmrNumPh1 as 'Cust Phn'
		,t.trpPssngrs as '#gst'
		,t.trpLug as '#Lug'
--		,t.trpPckLctnTpe
		,plt.lctn_tpe_dsc 'Pkup From'
--		,t.trpPckLctnUnqID
		,pltn.lctn_dsc 'Pkup Location'
--		,t.trpPckLctnSubUnqID
		,psltn.lctn_dsc 'Pickup Location Name'
		,t.trpPckflght 'Pck Loc Det'
		,RIGHT(CONVERT(VARCHAR(20), t.trpPckLctnTm, 100), 7) AS 'Arrival Time'
		,dlt.lctn_tpe_dsc 'Drop Off'
		,dltn.lctn_dsc 'Drop Location'
		,dsltn.lctn_dsc 'Destination Location Name'
		,t.trpDrpflght 'Drp Loc Det'
		,t.trpDrpLctnTm 'Departure Time'
		,t.trpAddtnfo 'Additional Info'
        ,t.trpmnfstDrvr 'DriverName'
		,r.RsrvtnSrc
		,case when cast(r.RsrvtnDateTm as date) < '2025-09-05' then 1 else 0 end OPERA
  from 
		tblTrps T
  join	tblRsvrtns R on r.RsrvtnID = t.trpRsrvtnID
  join	tblCstmrs C	 on c.CstmrID = r.RsrvtnCstmrID
  join	tblLctnTpe PLT on plt.lctn_tpe = t.trpPckLctnTpe
  left join	tblLctns pltn on pltn.lctn_UnqID = t.trppckLctnUnqID
  left join	tblLctns psltn on psltn.lctn_UnqID = t.trpPckLctnSubUnqID
  join	tblLctnTpe DLT on dlt.lctn_tpe = t.trpDrpLctnTpe
  left join	tblLctns dltn on dltn.lctn_UnqID = t.trpDrpLctnUnqID
  left join	tblLctns dsltn on dsltn.lctn_UnqID = t.trpDrpLctnSubUnqID
  where
		 r.RsrvtnStatus in ('a','e') and RsrvtnID in (select pmtinvID from tblARpayments)
	 or (r.RsrvtnStatus in ('a','e') and RsrvtnSrc like '%htl%')
	 or (r.RsrvtnDateTm < '2025-09-05' and r.RsrvtnStatus in ('a','e'))
GO

--select * from tblARpayments 
--select GETUTCDATE()