
-- =============================================
-- Author:      MICHAEL WALDHELM
-- Create Date: 06/13/2024
-- Description: INSERT OR UPDATE tblTrps 
-- =============================================
CREATE PROCEDURE [dbo].[sp_I_VwTrps]
(
    -- Add the parameters for the stored procedure here
	@trpID				[int],
	@trpRsrvtnID		[nvarchar](8),
	@trpPckDate			[date],
	@trpPckTm			[time](7),
	@trpPssngrs			[tinyint],
	@trpCst				[money],
	@trpPckLctnTpe		[smallint],
	@trpPckLctnUnqID	[varchar](24),
	@trpPckLctnSubUnqID [varchar](24) NULL,
	@trpPckLctnTm		[time](7) NULL,
	@trpDrpLctnTpe		[smallint],
	@trpDrpLctnUnqID	[varchar](24),
	@trpDrpLctnSubUnqID [nchar](10) NULL,
	@trpDrpLctnTm		[time](7) NULL,
	@trpWC				[bit] NULL,
	@trpWCfld			[nchar](10) NULL,
	@trpAddtnfo			[varchar](256) NULL,
	@trpCrtdDtTm		[smalldatetime],
	@trpCrtdBy			[nvarchar](128),
	@trpUpdt			[smalldatetime] NULL,
	@trpUpdtBy			[nvarchar](128) NULL
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
    INSERT INTO [dbo].[iVwTrps]
           		(trpID
				,[trpRsrvtnID]
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
     VALUES
	 (
			@trpID,
			@trpRsrvtnID,
			@trpPckDate,
			@trpPckTm,
			@trpPssngrs,
			@trpCst,
			@trpPckLctnTpe,
			@trpPckLctnUnqID,
			@trpPckLctnSubUnqID,
			@trpPckLctnTm,
			@trpDrpLctnTpe,
			@trpDrpLctnUnqID,
			@trpDrpLctnSubUnqID,
			@trpDrpLctnTm,
			@trpWC,
			@trpWCfld,
			@trpAddtnfo,
			@trpCrtdDtTm,
			@trpCrtdBy,
			@trpUpdt,
			@trpUpdtBy)

END
