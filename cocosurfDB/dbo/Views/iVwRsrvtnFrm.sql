




CREATE       view [dbo].[iVwRsrvtnFrm] as 
select
	0									as htl_id,
	Convert(varchar(50),' ')			as htl_nme	,
	Convert(varchar(50),' ')			as htl_clrk,
	Convert(varchar(50),' ')			as htl_rsrvtn_nmbr,
	0									as shp_id,
	Convert(varchar(50),' ')			as shp_nme,
	Convert(date,'01/01/1971')			as shp_dt,
	Convert(varchar(50),' ')			as shp_fc,
	0									as shp_pd,
	0.00								as	shp_cst,
--	0									as rsrvtn_ctgry,
	convert(varchar(128),' ')			as rsrvtn_nbr,
	0									as rsrvtn_addon,
	0									as rsrvtn_pckg,
	0									as rsrvtn_type,
	--Convert(varchar(50),' ')			as gst_nme,
	Convert(varchar(50),' ')			as gst_fnme,
	Convert(varchar(50),' ')			as gst_lnme,
	Convert(varchar(50),' ')			as gst_eml,
	Convert(varchar(50),' ')			as gst_cphn1,
	Convert(varchar(50),' ')			as gst_cphn2,
	Convert(date,'01/01/1971')			as arrvl_dt,
	'00:00:00'							as arrvl_tm,
	Convert(varchar(50),' ')			as arrvl_arprt,
	Convert(varchar(50),' ')			as arrvl_arln,
	Convert(varchar(50),' ')			as arrvl_flght_nmbr,
	0									as arrvl_nmbr_pssngrs,
	'00:00:00'							as arrvl_pckup_tm,
	Convert(varchar(50),' ')			as arrvl_drpoff_loc,
	Convert(date,'01/01/1971')			as dep_dt,
	'00:00:00'							as dep_tm,
	Convert(varchar(50),' ')			as dep_arprt,
	Convert(varchar(50),' ')			as dep_arln,
	Convert(varchar(50),' ')			as dep_flght_nmbr,
	0									as dep_nmbr_pssngrs,
	'00:00:00'							as dep_pckup_tm,
	Convert(varchar(50),' ')			as dep_drpoff_loc,
	0									as whlchr,
	0									as whlchr_cnfld,
	Convert(varchar(256),' ')			as addtnl_inf,
	Convert(varchar(128),' ')			as CrtdBy
	from
	tblDummy4View
	--Line 275:             <select name="htl_nme" title="Hotel">
	--Line 285:             <label4 id="nopadding">Clerk: <input type="text" name="htl_clrk"></label4>
	--Line 286:             <label4 id="nopadding">Reservation #: <input type="text" name="htl_rsrvtn_nmbr"></label4>
	--Line 292: 				<tr><td id="td-nopad"><label4>Ship:<input type="text" name="shp_name"></label4></td><td>     </td><td id="td-nopad"><label4>FC Added:<input type="text" name="shp_fc"></label4></td></tr>
	--Line 293: 				<tr><td id="td-nopad"><label4>Time:<input type="time" name="shp_tm"></label4></td><td>     </td><td id="td-nopad"><label4>Paid:<input type="text" name="shp_pd"></label4></td></tr>
	--Line 294: 				<tr><td id="td-nopad"><label4>Dates:<input type="date" name="shp_dt"></label4></td><td>     </td><td id="td-nopad"><label4>Cost:<span class="currencyinput">$<input type="text" name="shp_cst"></span></label4></td></tr>
	--Line 298: 			<label3 id="verified-info">Guest Verified Email Received<input type="checkbox" name="vrfd_eml_rcfd"></label3></br>
	--Line 301: 			<label3 id="verified-info">Guest Verified Correct Info Entered<input type="checkbox" name="vrfd_inf"></label3>
	--Line 305: 				<label4><input type="radio" name="rsrvtn_ctgry" value="add_on"> ADD-ON</label4>
	--Line 306:             	<label4><input type="radio" name="rsrvtn_ctgry" value="package"> PACKAGE</label4>
	--Line 307:             	<label4><input type="radio" name="rsrvtn_tpe" value="one_way"> ONE-WAY</label4></br>
	--Line 308:             	<label4><input type="radio" name="rsrvtn_tpe" value="round_trip"> ROUND-TRIP</label4>
	--Line 309:             	<label4><input type="radio" name="rsrvtn_tpe" value="round_trip"> PORT 2 PORT</label4>
	--Line 314:             <tr id="td-nopad"><td><label4 id="nopadding">Name: <input type="text" name="gst_nme"></label4> / <label4 id="nopadding">Email: <input type="email" name="gst_eml"></label4></td></tr>
	--Line 315: 			<tr id="td-nopad"><td><label4 id="nopadding">Cell Phone: <input type="tel" name="gst_cphn1"></label4> / <label4 id="nopadding">2nd Cell Phone: <input type="tel" name="gst_cphn2"></label4></td></tr>
	--Line 322:             <label4>Date: <input type="date" name="arrvl_dt"></label4>
	--Line 323:             <label4>Time: <input type="time" name="arrvl_tm"></label4>
	--Line 324:             <label4>Airport: <input type="text" name="arrvl_arprt" value="MCO"></label4>
	--Line 325:             <label4>Airline: <input type="text" name="arrvl_arln"></label4>
	--Line 326:             <label4>Flight #: <input type="text" name="arrvl_flght_nmbr"></label4>
	--Line 327:             <label4># Of Passengers: <input type="number" name="arrvl_nmbr_pssngrs"></label4>
	--Line 328:             <label4>Pick-Up Time: <input type="time" name="arrvl_pckup_tm"></label4>
	--Line 329:             <label4>Drop-off location: <input type="text" name="arrvl_drpoff_loc"></label4>
	--Line 333:             <label4>Date: <input type="date" name="dep_dt"></label4>
	--Line 334:             <label4>Time: <input type="time" name="dep_tm"></label4>
	--Line 335:             <label4>Airport: <input type="text" name="dep_arprt" value="MCO"></label4>
	--Line 336:             <label4>Airline: <input type="text" name="dep_arln"></label4>
	--Line 337:             <label4>Flight #: <input type="text" name="dep_flght_nmbr"></label4>
	--Line 338:             <label4># Of Passengers: <input type="number" name="dep_nmbr_pssngrs"></label4>
	--Line 339:             <label4>Pick-Up Time: <input type="time" name="dep_pckup_tm"></label4>
	--Line 340:             <label4>Drop-off location: <input type="text" name="dep_drpoff_loc"></label4>
	--Line 346: 		<label4 id="nopadding">Passenger has wheelchair:</label4><input type="checkbox" name="whlchr">
	--Line 347: 	   	<label4>It can fold up:</label4><input type="checkbox" name="whlchr_cnfld">
	--Line 349:              <label4 id="addtnl-inf">Additional Info: <textarea name="addtnl_inf"></textarea></label4>

GO

CREATE   TRIGGER [dbo].[trCCBS_rsrvtn_frm]
   ON  [dbo].[iVwRsrvtnFrm] 
  Instead of INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for trigger here
	-- Insert the Customer Info Data into tblCstmr
	if not exists (select * from tblCstmrs join inserted on [gst_eml] = CstmrEml)
		insert into tblCstmrs (CstmrFN, CstmrLN, CstmrEml, CstmrPhn1, CstmrPhn2) 
		select [gst_fnme],[gst_lnme],[gst_eml],[gst_cphn1],[gst_cphn2]
		  from inserted
	 
END
