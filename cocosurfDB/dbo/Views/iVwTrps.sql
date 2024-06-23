



CREATE         view [dbo].[iVwTrps] as 
select
	0									as trpID,
	convert(nvarchar(8),' ')			as trpRsrvtnID,
	Convert(date,'01/01/1971')			as trpPckDate,
	'00:00:00'							as trpPckTm,
	0									as trpPssngrs,
	0									as trpCst,
	0									as trpPckLctnTpe,
	Convert(varchar(24),' ')			as trpPckLctnUnqID,
	Convert(varchar(24),' ')			as trpPckLctnSubUnqID,
	'00:00:00'							as trpPckLctnTm,
	0									as trpDrpLctnTpe,
	Convert(varchar (24),' ')			as trpDrpLctnUnqID,
	Convert(nchar(10),' ')				as trpDrpLctnSubUnqID,
	'00:00:00'							as trpDrpLctnTm,
	convert(bit,0)						as trpWC,
	Convert(nchar(10),' ')				as trpWCfld,
	Convert(varchar(256),' ')			as trpAddtnfo,
	Convert(smalldatetime,'01/01/1971 00:00:00') as trpCrtdDtTm,
    Convert(nvarchar(128),' ')			as trpCrtdBy,
	Convert(smalldatetime,'01/01/1971 00:00:00') as trpUpdt, 
    Convert(nvarchar(128),' ')			as trpUpdtBy
	from
	tblDummy4View

GO



CREATE     TRIGGER [dbo].[trTrps]
   ON  [dbo].[iVwTrps] 
  Instead of INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for trigger here
	-- Insert the Trip Info Data into tblTrps
	if not exists (select * from tblTrps t join inserted i on t.trpRsrvtnID = i.trpRsrvtnID and t.trpID = i.trpID)
		BEGIN
			insert into [dbo].[tblTrps]
			   ([trpRsrvtnID]
			   ,[trpPckDate]
			   ,[trpPckTm]
			   ,[trpPssngrs]
			   ,[trpCst]
			   ,[trpPckLctnTpe]
			   ,[trpPckLctnUnqID]
			   ,[trpPckLctnSubUnqID]
			   ,[trpPckLctnTm]
			   ,[trpDrpLctnTpe]
			   ,[trpDrpLctnUnqID]
			   ,[trpDrpLctnSubUnqID]
			   ,[trpDrpLctnTm]
			   ,[trpWC]
			   ,[trpWCfld]
			   ,[trpAddtnfo]
			   ,[trpCrtdDtTm]
			   ,[trpCrtdBy]
			   ,[trpUpdt]
			   ,[trpUpdtBy]) 
			select           
				[trpRsrvtnID]
			   ,[trpPckDate]
			   ,[trpPckTm]
			   ,[trpPssngrs]
			   ,[trpCst]
			   ,[trpPckLctnTpe]
			   ,[trpPckLctnUnqID]
			   ,[trpPckLctnSubUnqID]
			   ,[trpPckLctnTm]
			   ,[trpDrpLctnTpe]
			   ,[trpDrpLctnUnqID]
			   ,[trpDrpLctnSubUnqID]
			   ,[trpDrpLctnTm]
			   ,[trpWC]
			   ,[trpWCfld]
			   ,[trpAddtnfo]
			   ,getdate()
			   ,[trpCrtdBy]
			   ,getdate()
			   ,[trpUpdtBy]
			  from inserted
		  END
	ELSE
		BEGIN
			UPDATE [dbo].tblTrps 
		   SET trpRsrvtnID = i.trpRsrvtnID
			  ,trpPckDate = i.trpPckDate
			  ,trpPckTm = i.trpPckTm
			  ,trpPssngrs = i.trpPssngrs
			  ,trpCst = i.trpCst
			  ,trpPckLctnTpe = i.trpPckLctnTpe
			  ,trpPckLctnUnqID = i.trpPckLctnUnqID
			  ,trpPckLctnSubUnqID = i.trpPckLctnSubUnqID
			  ,trpPckLctnTm = i.trpPckLctnTm
			  ,trpDrpLctnTpe = i.trpDrpLctnTpe
			  ,trpDrpLctnUnqID = i.trpDrpLctnUnqID
			  ,trpDrpLctnSubUnqID = i.trpDrpLctnSubUnqID
			  ,trpDrpLctnTm = i.trpDrpLctnTm
			  ,trpWC = i.trpWC
			  ,trpWCfld = i.trpWCfld
			  ,trpAddtnfo = i.trpAddtnfo
			  ,trpUpdt = getdate()
			  ,trpUpdtBy = i.trpUpdtBy
			FROM tblTrps t
			join inserted i
				on	t.trpRsrvtnID = i.trpRsrvtnID 
				and t.trpID = i.trpID
		END

	 
END
