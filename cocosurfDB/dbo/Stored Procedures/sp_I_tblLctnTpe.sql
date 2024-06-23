-- =============================================
-- Author:      <Author, , Name>
-- Create Date: <Create Date, , >
-- Description: <Description, , >
-- exec sp_I_tblLctnTpe @lctn_tpe='Z',@lctn_tpe_dsc='z111'
-- Select * from  tblLctnTpe
-- =============================================
CREATE   PROCEDURE [dbo].[sp_I_tblLctnTpe]
(
    -- Add the parameters for the stored procedure here
			  @lctn_tpe char(2) = null,
			  @lctn_tpe_dsc varchar(50) = null,
			  @lctn_tpe_active bit =null,
			  @lctn_tpe_Id smallint = 0
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON

    -- Insert statements for procedure here
	If @lctn_tpe_Id > 0
	Begin
		Update [tblLctnTpe] 
		set [lctn_tpe] = @lctn_tpe,
		[lctn_tpe_dsc] = @lctn_tpe_dsc,
		[lctn_tpe_active] = @lctn_tpe_active
		Where lctn_tpe_Id = @lctn_tpe_Id
	End
	Else
	Begin
		
		Insert INTO [dbo].[tblLctnTpe]
           ([lctn_tpe]
           ,[lctn_tpe_dsc]
		   ,[lctn_tpe_active])
     VALUES
           (@lctn_tpe
           ,@lctn_tpe_dsc
		   ,@lctn_tpe_active)
	End
END



