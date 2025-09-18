/****** Object:  StoredProcedure [dbo].[spProcessReservation]    Script Date: 5/22/2025 7:25:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:      WILL HENDERSON
-- Create Date: 09/26/2024
-- Description: INSERT OR UPDATE Reservation from JSON Data from the WebForm 
-- exec spProcessReservation '{"Rsrvtndtl":{"RsrvtnID":"v6cmbg","RsrvtnSrc":"agent","RsrvtnStatus":"e","Gst_eml":"BOB1@AOL.COM","RsrvtnDscnt":"10.00","RsrvtnFees":"20.00","RsrvtnTot":"110.00"},"GstInfo":{"Gst_fnme":"BOB","Gst_lnme":"BOB","Gst_eml":"BOB1@AOL.COM","Gst_eml2":"BOB1@AOL.COM","Gst_cphn1":"8135551212","Gst_cphn2":null,"rsrvtn_id":"v6cmbg"},"TripDtls":[{"trpRsrvtnID":"v6cmbg","trpID":"-911","trpPckDate":null,"trpPckTm":null,"trpPssngrs":null,"trpLug":null,"trpCst":null,"trpPckLctnTpe":null,"trpPckLctnUnqID":null,"trpPckLctnSubUnqID":null,"trpPckflght":null,"trpPckLctnTm":null,"trpDrpLctnTpe":null,"trpDrpLctnUnqID":null,"trpDrpLctnSubUnqID":null,"trpDrpflght":null,"trpDrpLctnTm":null,"trpWC":null,"trpWCfld":null,"trpAddtnfo":null},{"trpRsrvtnID":"v6cmbg","trpID":"1","trpPckDate":"2024-09-26","trpPckTm":"10:00","trpPssngrs":"1","trpLug":"1","trpCst":"100.00","trpPckLctnTpe":"AP","trpPckLctnUnqID":"MCO","trpPckLctnSubUnqID":"HP","trpPckflght":"qwer","trpPckLctnTm":"09:28","trpDrpLctnTpe":"H","trpDrpLctnUnqID":"htl015","trpDrpLctnSubUnqID":"0","trpDrpflght":null,"trpDrpLctnTm":null,"trpWC":"True","trpWCfld":"False","trpAddtnfo":"Hopeful Test"}]}','will@forrsite.com'
-- =============================================
-- 250106 Will Henderson Expanded Phone fields to Varchar(16)
-- 250106 Will Henderson Added LogDate to the Log_JSON table changed inserts to specify JSON field
-- =============================================
ALTER   PROCEDURE [dbo].[spProcessReservation]
    @JsonPayload NVARCHAR(MAX),
	@UserEmail	NVARCHAR(128)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON
    BEGIN TRY
		declare @debug bit = 1, @RC int = 0,
				@GuestInfo nvarchar(max), @RsrvtnDtl nvarchar(max),@TripInfos nvarchar(max)
		-- these next two lines are for interactive development.  comment them out when saving the procedure
		--declare @JsonPayload NVARCHAR(MAX),	@UserEmail	NVARCHAR(128) = 'testing@forrsite.com', 
		--set @JsonPayload = '{"Rsrvtndtl":{"RsrvtnID":"v6cmbg","Gst_eml":"BOB1@AOL.COM","RsrvtnDscnt":"10.00","RsrvtnFees":"20.00","RsrvtnTot":"110.00"},"GstInfo":{"Gst_fnme":"BOB","Gst_lnme":"BOB","Gst_eml":"BOB1@AOL.COM","Gst_eml2":"BOB1@AOL.COM","Gst_cphn1":"8135551212","Gst_cphn2":null,"rsrvtn_id":"v6cmbg"},"TripDtls":[{"trpRsrvtnID":"v6cmbg","trpID":"-911","trpPckDate":null,"trpPckTm":null,"trpPssngrs":null,"trpLug":null,"trpCst":null,"trpPckLctnTpe":null,"trpPckLctnUnqID":null,"trpPckLctnSubUnqID":null,"trpPckflght":null,"trpPckLctnTm":null,"trpDrpLctnTpe":null,"trpDrpLctnUnqID":null,"trpDrpLctnSubUnqID":null,"trpDrpflght":null,"trpDrpLctnTm":null,"trpWC":null,"trpWCfld":null,"trpAddtnfo":null},{"trpRsrvtnID":"v6cmbg","trpID":"1","trpPckDate":"2024-09-26","trpPckTm":"10:00","trpPssngrs":"1","trpLug":"1","trpCst":"100.00","trpPckLctnTpe":"AP","trpPckLctnUnqID":"MCO","trpPckLctnSubUnqID":"HP","trpPckflght":"qwer","trpPckLctnTm":"09:28","trpDrpLctnTpe":"H","trpDrpLctnUnqID":"htl015","trpDrpLctnSubUnqID":"0","trpDrpflght":null,"trpDrpLctnTm":null,"trpWC":"True","trpWCfld":"False","trpAddtnfo":"Hopeful Test"}]}'
		--Declare all variables 
		-- Reservation Details
		Declare
			@RsrvtnID			nvarchar(6),
			@RsrvtnSrc			varchar(16),
			@RsrvtnStatus		varchar(1),
			@Gst_eml			nvarchar(128),
			@RsrvtnDscnt		money,
			@RsrvtnFees			money,
			@RsrvtnTot			money,
			@RsrvtnActive		bit = null,
			@RsvrtnCreatedBy	nvarchar(128)

		-- Guest Info
		DECLARE 
			@Gst_fnme nvarchar(50),
			@Gst_lnme nvarchar(50),
			@Gst_eml2 nvarchar(128),
			@Gst_cphn1 nvarchar(16),
			@Gst_cphn2 nvarchar(16),
			@rsrvtn_id char(6),
			@CreatedBy nvarchar(128)

		-- Trip Info

		-- Declare table variable for JSON payload
		DECLARE @tblJSONPayLoad TABLE (
		  RsrvtnID NVARCHAR(50),
		  RsrvtnSrc VARCHAR(16),
		  RsrvtnStatus VARCHAR(1),
		  Gst_eml NVARCHAR(100),
		  RsrvtnDscnt DECIMAL(10, 2),
		  RsrvtnFees DECIMAL(10, 2),
		  RsrvtnTot DECIMAL(10, 2),
		  Gst_fnme NVARCHAR(50),
		  Gst_lnme NVARCHAR(50),
		  Gst_eml2 NVARCHAR(100),
		  Gst_cphn1 NVARCHAR(20),
		  Gst_cphn2 NVARCHAR(20),
		  trpRsrvtnID NVARCHAR(50),
		  trpID NVARCHAR(50),
		  trpStatus varchar(1),
		  trpPckDate DATE,
		  trpPckTm TIME,
		  trpPssngrs NVARCHAR(50),
		  trpLug NVARCHAR(50),
		  trpCst DECIMAL(10, 2),
		  trpPckLctnTpe NVARCHAR(50),
		  trpPckLctnUnqID NVARCHAR(50),
		  trpPckLctnSubUnqID NVARCHAR(50),
		  trpPckflght NVARCHAR(50),
		  trpPckLctnTm NVARCHAR(50),
		  trpDrpLctnTpe NVARCHAR(50),
		  trpDrpLctnUnqID NVARCHAR(50),
		  trpDrpLctnSubUnqID NVARCHAR(50),
		  trpDrpflght NVARCHAR(50),
		  trpDrpLctnTm NVARCHAR(50),
		  trpWC NVARCHAR(50),
		  trpWCfld NVARCHAR(50),
		  trpAddtnfo NVARCHAR(100)
		)

        -- Parse the JSON payload

		if @debug = 1
			begin
				insert into Debug_ReservationData
				  SELECT
					  getdate() as GEN_DATE,
					  Rsrvtndtl.RsrvtnID,
					  Rsrvtndtl.RsrvtnSrc,
					  Rsrvtndtl.RsrvtnStatus,
					  Rsrvtndtl.Gst_eml as RsrvtnEml,
					  Rsrvtndtl.RsrvtnDscnt,
					  Rsrvtndtl.RsrvtnFees,
					  Rsrvtndtl.RsrvtnTot,
					  GstInfo.Gst_fnme,
					  GstInfo.Gst_lnme,
					  GstInfo.Gst_eml,
					  GstInfo.Gst_eml2,
					  GstInfo.Gst_cphn1,
					  GstInfo.Gst_cphn2,
					  TripDtls.trpRsrvtnID,
					  TripDtls.trpID,
					  TripDtls.trpStatus,
					  TripDtls.trpPckDate,
					  TripDtls.trpPckTm,
					  TripDtls.trpPssngrs,
					  TripDtls.trpLug,
					  TripDtls.trpCst,
					  TripDtls.trpPckLctnTpe,
					  TripDtls.trpPckLctnUnqID,
					  TripDtls.trpPckLctnSubUnqID,
					  TripDtls.trpPckflght,
					  TripDtls.trpPckLctnTm,
					  TripDtls.trpDrpLctnTpe,
					  TripDtls.trpDrpLctnUnqID,
					  TripDtls.trpDrpLctnSubUnqID,
					  TripDtls.trpDrpflght,
					  TripDtls.trpDrpLctnTm,
					  TripDtls.trpWC,
					  TripDtls.trpWCfld,
					  TripDtls.trpAddtnfo
					FROM OPENJSON(@jsonpayload)
					WITH (
					  Rsrvtndtl NVARCHAR(MAX) AS JSON,
					  GstInfo NVARCHAR(MAX) AS JSON,
					  TripDtls NVARCHAR(MAX) AS JSON
					) AS Root
					CROSS APPLY OPENJSON(Root.Rsrvtndtl)
					WITH (
					  RsrvtnID NVARCHAR(50) '.RsrvtnID',
					  RsrvtnSrc VARCHAR(16) '.RsrvtnSrc',
					  RsrvtnStatus VARCHAR(1) '.RsrvtnStatus',
					  Gst_eml NVARCHAR(100) '.Gst_eml',
					  RsrvtnDscnt DECIMAL(10, 2) '.RsrvtnDscnt',
					  RsrvtnFees DECIMAL(10, 2) '.RsrvtnFees',
					  RsrvtnTot DECIMAL(10, 2) '.RsrvtnTot'
					) AS Rsrvtndtl
					CROSS APPLY OPENJSON(Root.GstInfo)
					WITH (
					  Gst_fnme NVARCHAR(50) '.Gst_fnme',
					  Gst_lnme NVARCHAR(50) '.Gst_lnme',
					  Gst_eml NVARCHAR(100) '.Gst_eml',
					  Gst_eml2 NVARCHAR(100) '.Gst_eml2',
					  Gst_cphn1 NVARCHAR(20) '.Gst_cphn1',
					  Gst_cphn2 NVARCHAR(20) '.Gst_cphn2'
					) AS GstInfo
					CROSS APPLY OPENJSON(Root.TripDtls) 
					WITH (
					  trpRsrvtnID NVARCHAR(50) '.trpRsrvtnID',
					  trpID NVARCHAR(50) '.trpID',
					  trpStatus VARCHAR(1) '.trpStatus',
					  trpPckDate DATE '.trpPckDate',
					  trpPckTm TIME '.trpPckTm',
					  trpPssngrs NVARCHAR(50) '.trpPssngrs',
					  trpLug NVARCHAR(50) '.trpLug',
					  trpCst DECIMAL(10, 2) '.trpCst',
					  trpPckLctnTpe NVARCHAR(50) '.trpPckLctnTpe',
					  trpPckLctnUnqID NVARCHAR(50) '.trpPckLctnUnqID',
					  trpPckLctnSubUnqID NVARCHAR(50) '.trpPckLctnSubUnqID',
					  trpPckflght NVARCHAR(50) '.trpPckflght',
					  trpPckLctnTm NVARCHAR(50) '.trpPckLctnTm',
					  trpDrpLctnTpe NVARCHAR(50) '.trpDrpLctnTpe',
					  trpDrpLctnUnqID NVARCHAR(50) '.trpDrpLctnUnqID',
					  trpDrpLctnSubUnqID NVARCHAR(50) '.trpDrpLctnSubUnqID',
					  trpDrpflght NVARCHAR(50) '.trpDrpflght',
					  trpDrpLctnTm NVARCHAR(50) '.trpDrpLctnTm',
					  trpWC NVARCHAR(50) '.trpWC',
					  trpWCfld NVARCHAR(50) '.trpWCfld',
					  trpAddtnfo NVARCHAR(100) '.trpAddtnfo'
					) AS TripDtls;
			end
        --DECLARE @GuestInfo NVARCHAR(MAX)
        --DECLARE @RsrvtnDtl NVARCHAR(MAX)
        --DECLARE @TripInfos NVARCHAR(MAX)
        --DECLARE @GuestInfo1 NVARCHAR(MAX)
        --DECLARE @RsrvtnDtl1 NVARCHAR(MAX)
        --DECLARE @TripInfos1 NVARCHAR(MAX)
		-- Declare the table variable

		-- Insert data into the table variable
		INSERT INTO @tblJSONPayLoad
		  SELECT
			  Rsrvtndtl.RsrvtnID,
			  Rsrvtndtl.RsrvtnSrc,
			  Rsrvtndtl.RsrvtnStatus,
			  Rsrvtndtl.Gst_eml as RsrvtnEml,
			  Rsrvtndtl.RsrvtnDscnt,
			  Rsrvtndtl.RsrvtnFees,
			  Rsrvtndtl.RsrvtnTot,
			  GstInfo.Gst_fnme,
			  GstInfo.Gst_lnme,
			  --GstInfo.Gst_eml,
			  GstInfo.Gst_eml2,
			  GstInfo.Gst_cphn1,
			  GstInfo.Gst_cphn2,
			  TripDtls.trpRsrvtnID,
			  TripDtls.trpID,
			  TripDtls.trpStatus,
			  TripDtls.trpPckDate,
			  TripDtls.trpPckTm,
			  TripDtls.trpPssngrs,
			  TripDtls.trpLug,
			  TripDtls.trpCst,
			  TripDtls.trpPckLctnTpe,
			  TripDtls.trpPckLctnUnqID,
			  TripDtls.trpPckLctnSubUnqID,
			  TripDtls.trpPckflght,
			  TripDtls.trpPckLctnTm,
			  TripDtls.trpDrpLctnTpe,
			  TripDtls.trpDrpLctnUnqID,
			  TripDtls.trpDrpLctnSubUnqID,
			  TripDtls.trpDrpflght,
			  TripDtls.trpDrpLctnTm,
			  TripDtls.trpWC,
			  TripDtls.trpWCfld,
			  TripDtls.trpAddtnfo
		FROM OPENJSON(@jsonpayload)
		WITH (
		  Rsrvtndtl NVARCHAR(MAX) AS JSON,
		  GstInfo NVARCHAR(MAX) AS JSON,
		  TripDtls NVARCHAR(MAX) AS JSON
		) AS Root
		CROSS APPLY OPENJSON(Root.Rsrvtndtl)
		WITH (
		  RsrvtnID NVARCHAR(50) '.RsrvtnID',
		  RsrvtnSrc VARCHAR(16) '.RsrvtnSrc',
		  RsrvtnStatus VARCHAR(1) '.RsrvtnStatus',
		  Gst_eml NVARCHAR(100) '.Gst_eml',
		  RsrvtnDscnt DECIMAL(10, 2) '.RsrvtnDscnt',
		  RsrvtnFees DECIMAL(10, 2) '.RsrvtnFees',
		  RsrvtnTot DECIMAL(10, 2) '.RsrvtnTot'
		) AS Rsrvtndtl
		CROSS APPLY OPENJSON(Root.GstInfo)
		WITH (
		  Gst_fnme NVARCHAR(50) '.Gst_fnme',
		  Gst_lnme NVARCHAR(50) '.Gst_lnme',
		  Gst_eml NVARCHAR(100) '.Gst_eml',
		  Gst_eml2 NVARCHAR(100) '.Gst_eml2',
		  Gst_cphn1 NVARCHAR(20) '.Gst_cphn1',
		  Gst_cphn2 NVARCHAR(20) '.Gst_cphn2'
		) AS GstInfo
		CROSS APPLY OPENJSON(Root.TripDtls) 
		WITH (
		  trpRsrvtnID NVARCHAR(50) '.trpRsrvtnID',
		  trpID NVARCHAR(50) '.trpID',
		  trpStatus VARCHAR(1) '.trpStatus',
		  trpPckDate DATE '.trpPckDate',
		  trpPckTm TIME '.trpPckTm',
		  trpPssngrs NVARCHAR(50) '.trpPssngrs',
		  trpLug NVARCHAR(50) '.trpLug',
		  trpCst DECIMAL(10, 2) '.trpCst',
		  trpPckLctnTpe NVARCHAR(50) '.trpPckLctnTpe',
		  trpPckLctnUnqID NVARCHAR(50) '.trpPckLctnUnqID',
		  trpPckLctnSubUnqID NVARCHAR(50) '.trpPckLctnSubUnqID',
		  trpPckflght NVARCHAR(50) '.trpPckflght',
		  trpPckLctnTm NVARCHAR(50) '.trpPckLctnTm',
		  trpDrpLctnTpe NVARCHAR(50) '.trpDrpLctnTpe',
		  trpDrpLctnUnqID NVARCHAR(50) '.trpDrpLctnUnqID',
		  trpDrpLctnSubUnqID NVARCHAR(50) '.trpDrpLctnSubUnqID',
		  trpDrpflght NVARCHAR(50) '.trpDrpflght',
		  trpDrpLctnTm NVARCHAR(50) '.trpDrpLctnTm',
		  trpWC NVARCHAR(50) '.trpWC',
		  trpWCfld NVARCHAR(50) '.trpWCfld',
		  trpAddtnfo NVARCHAR(100) '.trpAddtnfo'
		) AS TripDtls
		if @debug = 1		
			insert into log_json(JSON) select @JsonPayload

        -- Extract and Load GuestInfo
        if @debug = 1
			begin
				SET @GuestInfo = JSON_QUERY(@JsonPayload, '$.GstInfo')
				insert into log_json(JSON) select @GuestInfo
			end
		INSERT INTO [dbo].[iVwGstInf]
			   ([Gst_fnme]
			   ,[Gst_lnme]
			   ,[Gst_eml]
			   ,[Gst_eml2]
			   ,[Gst_cphn1]
			   ,[Gst_cphn2]
			   ,[rsrvtn_id]
			   ,[Gst_user])
		select distinct
			   Gst_fnme
			  ,Gst_lnme
			  ,Gst_eml
			  ,Gst_eml2
			  ,Gst_cphn1
			  ,Gst_cphn2
			  ,RsrvtnID
			  ,@UserEmail
		from
				@tblJSONPayLoad

        -- Extract and Load RsrvtnDtl
		if @debug = 1
			begin
				SET @RsrvtnDtl = JSON_QUERY(@JsonPayload, '$.Rsrvtndtl')
				insert into log_json(JSON) select @RsrvtnDtl
			end
    INSERT INTO [dbo].iVwRsvrtnDtl
			  (
           	    RsrvtnID,
				RsrvtnSrc,
				RsrvtnStatus,
				Gst_eml,	
				RsrvtnDscnt,
				RsrvtnFees,	
				RsrvtnTot,	
				RsrvtnActive,
				RsvrtnCreatedBy)
		select	distinct
           	    RsrvtnID,
				RsrvtnSrc,
				RsrvtnStatus,
				Gst_eml,	
				RsrvtnDscnt,
				RsrvtnFees,	
				RsrvtnTot,	
				1,
				@UserEmail				
		  from
				@tblJSONPayLoad
        -- Extract TripInfos
		if @debug = 1
			begin
				SET @TripInfos = JSON_QUERY(@JsonPayload, '$.TripDtls')
				insert into log_json(JSON) select @TripInfos
			end
         --Process TripInfo
		 INSERT INTO [dbo].[iVwTrps]
			   (trpID
			   ,trpStatus
			   ,trpRsrvtnID
			   ,trpPckDate
			   ,trpPckTm
			   ,trpPssngrs
			   ,trpLug
			   ,trpCst
			   ,trpPckLctnTpe
			   ,trpPckLctnUnqID
			   ,trpPckLctnSubUnqID
			   ,trpPckflght
			   ,trpPckLctnTm
			   ,trpDrpLctnTpe
			   ,trpDrpLctnUnqID
			   ,trpDrpLctnSubUnqID
			   ,trpDrpflght
			   ,trpDrpLctnTm
			   ,trpWC
			   ,trpWCfld
			   ,trpAddtnfo
			   ,trpCrtdBy)
		select
				trpID
				,trpStatus
				,trpRsrvtnID
				,trpPckDate
				,trpPckTm
				,trpPssngrs
				,trpLug
				,trpCst
				,trpPckLctnTpe
				,trpPckLctnUnqID
				,trpPckLctnSubUnqID
				,trpPckflght
				,trpPckLctnTm
				,trpDrpLctnTpe
				,trpDrpLctnUnqID
				,trpDrpLctnSubUnqID
				,trpDrpflght
				,trpDrpLctnTm
				,trpWC
				,trpWCfld
				,trpAddtnfo
				,@UserEmail
		from
			@tblJSONPayLoad
		order by
			trpID asc
    END TRY
    BEGIN CATCH
        -- Handle the error
        DECLARE @ErrorMessage NVARCHAR(4000)
        DECLARE @ErrorSeverity INT
        DECLARE @ErrorState INT
        DECLARE @ErrorProcedure NVARCHAR(128)
        DECLARE @ErrorLine INT

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE(),
            @ErrorProcedure = ERROR_PROCEDURE(),
            @ErrorLine = ERROR_LINE()

        -- Log the error
        EXEC LogError @ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorProcedure, @ErrorLine

        -- Optionally, re-raise the error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
    END CATCH
END