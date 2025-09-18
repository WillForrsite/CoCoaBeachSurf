/*
Name: Paid Reservation Status
Author: Will Henderson
2025-09-18: Paid Reservation Status



*/
create view vwPdRsrvtnStatus as 
select 
		r.RsrvtnDateTm, 
		r.RsrvtnID, 
		r.RsrvtnStatusDsc, 
		pmtCardName, 
		pmtAttributes, 
		cast(pmtModDt  AT TIME ZONE 'UTC' AT TIME ZONE 'Eastern Standard Time' as DATE) as pmtDate, 
		pmtTransactionID 
  from 
		tblRsvrtns r 
  join 
		tblRsvrtnPmt p on p.pmtRsrvtnID = r.RsrvtnID
where 
		p.pmtAuthCode = 'Accept' 
  and 
		pmtTransactionID is not null