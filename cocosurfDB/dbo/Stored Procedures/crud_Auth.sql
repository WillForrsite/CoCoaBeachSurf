/****** Script for SelectTopNRows command from SSMS  ******/
Create PROCEDURE [dbo].[crud_Auth] 
	-- Add the parameters for the stored procedure here
	@Opr varchar(1),
	@Userid varchar(50)='',
	@Email  varchar(50)='',
	@Token nvarchar(1000),
	@DeviceID nvarchar(128)='Web',
	@AppId int=0,
	@SignIn tinyint=1,
	@SignOut tinyint=0,
	@LastUsed varchar(50)
AS
BEGIN

   IF @Opr = 'I'
     BEGIN
	  --IF NOT EXISTS (SELECT * FROM [dbo].[Authentication] where [Token]=@Token)
	  --  Begin
	       -- Insert statements for procedure here
		   INSERT INTO [dbo].[Authentication]
           ([Userid]
           ,[Email]
           ,[Token]
		   ,[DeviceID]
           ,[AppId]
           ,[SignIn]
           ,[SignOut]
           ,[LastUsed])
     VALUES
           (@Userid,
            @Email,
            @Token,
			@DeviceID,
            @AppId, 
            @SignIn, 
            @SignOut, 
            @LastUsed)
		--End
		--else
		--    BEGIN
		--	     Update [dbo].[Authentication]
		--	 set SignIn= @SignIn         
  --           ,SignOut=0
  --           ,LastUsed=@LastUsed		   
		--     where [Token]=@Token
		--	END
		 
	 END
	 else
	  BEGIN
	         Update [dbo].[Authentication]
			 set SignIn= @SignIn         
             ,SignOut=@SignOut
             ,LastUsed=@LastUsed		   
		     where [Token]=@Token
	  END
	   

    
	
END
