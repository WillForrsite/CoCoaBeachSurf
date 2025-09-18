/****** Object:  View [dbo].[vw_ValidReservations]    Script Date: 9/9/2025 3:33:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- 🔹 Base Views
-- =============================================

CREATE OR ALTER VIEW [dbo].[vw_FPValidReservations] AS
SELECT 
case 
when pmtcrtddt is not null then cast(case
                         when p.pmtModDt is not null then p.pmtModDt AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time'
                         else p.pmtCrtdDt AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time'
                          end AS date)
else cast(RsrvtnDateTm as date)
 end as rsrvtndate,*
FROM dbo.tblRsvrtns r
left join dbo.tblRsvrtnPmt p on p.pmtRsrvtnID = r.RsrvtnID 
WHERE
	(p.pmtAuthCode = 'ACCEPT'
	and pmtTransactionID is not null)
   or (rsrvtnsrc like 'htl%' and Rsrvtnstatus IN ('a', 'c'));
GO


