-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- select * from tbllctns
-- =============================================
Create   PROCEDURE [dbo].[sp_I_tblCstmrs]
(
    -- Add the parameters for the stored procedure here
			  @CstmrFN nvarchar(50)= null,
			  @CstmrLN nvarchar(50)=null,
			  @CstmrEml nvarchar(128)=null,
			  @CstmrPhn1 nvarchar(12)=null,
			  @CstmrPhn2 nvarchar(12)=null,
			  @CstmrCrtdBy nvarchar(128)=null,
			  @CstmrActv bit=null,
			  @CstmrID  int = null
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
	If @CstmrID > 0
	Begin
	UPDATE [dbo].[tblCstmrs]
   SET 
			[CstmrFN] =		@CstmrFN
           ,[CstmrLN] =		@CstmrLN
           ,[CstmrEml]=		@CstmrEml
           ,[CstmrPhn1]=	@CstmrPhn1
           ,[CstmrPhn2]=	@CstmrPhn2
           ,[CstmrCrtdDt]=  GETDATE()
           ,[CstmrCrtdBy]=  @CstmrCrtdBy
           ,[CstmrActv]= @CstmrActv
	WHERE CstmrID = @CstmrID
		
	End
	Else
	Begin
		INSERT INTO [dbo].[tblCstmrs]
           ([CstmrFN]
           ,[CstmrLN]
           ,[CstmrEml]
           ,[CstmrPhn1]
           ,[CstmrPhn2]
           ,[CstmrCrtdDt]
           ,[CstmrCrtdBy]
           ,[CstmrActv])
     VALUES
           ( @CstmrFN
			,@CstmrLN
			,@CstmrEml
			,@CstmrPhn1
			,@CstmrPhn2
			,GETDATE()
			,@CstmrCrtdBy
			,@CstmrActv
			)
	End
END

