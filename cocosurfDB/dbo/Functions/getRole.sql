CREATE FUNCTION [dbo].[getRole]
(
	-- Add the parameters for the function here
	@Token nvarchar(1000)
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Userid nvarchar(128),@AppId int
	SELECT @Userid=userid,@AppId=AppId FROM [dbo].[Authentication] where Token=@Token
	--C:\Bluechip Development\CoCoaBeachSurf\cocosurfDB\dbo\Functions\udfGetCstmrByEml.sql
	IF EXISTS(select id from [dbo].[AppUserValidation] where [UserId]=@Userid and [IsGlobalAdmin]=1)
	BEGIN
	    RETURN 0;
	End
	Else
	
	IF EXISTS(select id from [dbo].[AppUserValidation] where [UserId]=@Userid and [AppId]=@AppId and  [IsAppAdmin]=1 )
	BEGIN
	   RETURN 1;
	End
	Else	
	IF EXISTS(select id from [dbo].[AppUserValidation] where [UserId]=@Userid and [AppId]=@AppId and  [IsAppAdmin]=0)
	BEGIN
	      RETURN 2
	End
	
	
	     RETURN -1
		

END


